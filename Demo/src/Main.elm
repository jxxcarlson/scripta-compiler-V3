port module Main exposing (main)

{-| Demo app for testing the Scripta compiler.

Three side-by-side panels:
- Left: document sidebar
- Center: source text editor
- Right: rendered HTML output

Documents are persisted to localStorage.

-}

import Browser
import Browser.Dom
import Browser.Events
import Compiler
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as Decode
import Json.Encode as Encode
import Task
import Types exposing (CompilerOutput, Filter(..), Msg(..), Theme(..))



-- PORTS


port saveDocuments : Encode.Value -> Cmd msg



-- DOCUMENT


type alias Document =
    { id : String
    , title : String
    , content : String
    }


type alias Flags =
    { documents : Decode.Value
    }


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { documents : List Document
    , currentDocumentId : String
    , sourceText : String
    , windowWidth : Int
    , windowHeight : Int
    , theme : Theme
    , editCount : Int
    }


initialSource : String
initialSource =
    """This is a test paragraph with [strong bold text] and [italic italics].

| section
Introduction

This section introduces the basic concepts.

| equation
a^2 + b^2 = c^2

| theorem
There are infinitely many primes.

Here is some inline math: $x^2 + 1$.

| code elm
factorial : Int -> Int
factorial n =
    if n <= 1 then 1
    else n * factorial (n - 1)

| section
Conclusion

That's all for now.
"""


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        documents =
            case Decode.decodeValue documentsDecoder flags.documents of
                Ok docs ->
                    if List.isEmpty docs then
                        [ defaultDocument ]

                    else
                        docs

                Err _ ->
                    [ defaultDocument ]

        currentDoc =
            List.head documents |> Maybe.withDefault defaultDocument
    in
    ( { documents = documents
      , currentDocumentId = currentDoc.id
      , sourceText = currentDoc.content
      , windowWidth = 1200
      , windowHeight = 800
      , theme = Light
      , editCount = 1
      }
    , Task.perform GotViewport Browser.Dom.getViewport
    )


defaultDocument : Document
defaultDocument =
    { id = "doc-1"
    , title = extractTitle initialSource
    , content = initialSource
    }


extractTitle : String -> String
extractTitle content =
    case String.split "| title\n" content of
        _ :: rest :: _ ->
            rest
                |> String.lines
                |> List.head
                |> Maybe.withDefault "Untitled"
                |> String.trim

        _ ->
            "Untitled"



-- JSON ENCODING/DECODING


documentDecoder : Decode.Decoder Document
documentDecoder =
    Decode.map3 Document
        (Decode.field "id" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "content" Decode.string)


documentsDecoder : Decode.Decoder (List Document)
documentsDecoder =
    Decode.list documentDecoder


encodeDocument : Document -> Encode.Value
encodeDocument doc =
    Encode.object
        [ ( "id", Encode.string doc.id )
        , ( "title", Encode.string doc.title )
        , ( "content", Encode.string doc.content )
        ]


encodeDocuments : List Document -> Encode.Value
encodeDocuments docs =
    Encode.list encodeDocument docs



-- UPDATE


type Msg
    = SourceChanged String
    | SelectDocument String
    | NewDocument
    | DeleteDocument String
    | GotViewport Browser.Dom.Viewport
    | WindowResized Int Int
    | ToggleTheme
    | CompilerMsg Types.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SourceChanged newSource ->
            let
                updatedDocuments =
                    List.map
                        (\doc ->
                            if doc.id == model.currentDocumentId then
                                { doc
                                    | content = newSource
                                    , title = extractTitle newSource
                                }

                            else
                                doc
                        )
                        model.documents
            in
            ( { model
                | sourceText = newSource
                , documents = updatedDocuments
                , editCount = model.editCount + 1
              }
            , saveDocuments (encodeDocuments updatedDocuments)
            )

        SelectDocument docId ->
            let
                selectedDoc =
                    model.documents
                        |> List.filter (\doc -> doc.id == docId)
                        |> List.head
            in
            case selectedDoc of
                Just doc ->
                    ( { model
                        | currentDocumentId = docId
                        , sourceText = doc.content
                        , editCount = model.editCount + 1
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        NewDocument ->
            let
                newId =
                    "doc-" ++ String.fromInt (model.editCount + 1)

                newDoc =
                    { id = newId
                    , title = "Untitled"
                    , content = "| title\nUntitled\n\nStart writing here...\n"
                    }

                updatedDocuments =
                    model.documents ++ [ newDoc ]
            in
            ( { model
                | documents = updatedDocuments
                , currentDocumentId = newId
                , sourceText = newDoc.content
                , editCount = model.editCount + 1
              }
            , saveDocuments (encodeDocuments updatedDocuments)
            )

        DeleteDocument docId ->
            let
                updatedDocuments =
                    List.filter (\doc -> doc.id /= docId) model.documents

                -- If we deleted the current document, switch to another
                ( newCurrentId, newSourceText ) =
                    if docId == model.currentDocumentId then
                        case List.head updatedDocuments of
                            Just doc ->
                                ( doc.id, doc.content )

                            Nothing ->
                                -- Create a new default doc if all deleted
                                ( defaultDocument.id, defaultDocument.content )

                    else
                        ( model.currentDocumentId, model.sourceText )

                finalDocuments =
                    if List.isEmpty updatedDocuments then
                        [ defaultDocument ]

                    else
                        updatedDocuments
            in
            ( { model
                | documents = finalDocuments
                , currentDocumentId = newCurrentId
                , sourceText = newSourceText
                , editCount = model.editCount + 1
              }
            , saveDocuments (encodeDocuments finalDocuments)
            )

        GotViewport viewport ->
            ( { model
                | windowWidth = round viewport.viewport.width
                , windowHeight = round viewport.viewport.height
              }
            , Cmd.none
            )

        WindowResized width height ->
            ( { model
                | windowWidth = width
                , windowHeight = height
              }
            , Cmd.none
            )

        ToggleTheme ->
            ( { model
                | theme =
                    case model.theme of
                        Light ->
                            Dark

                        Dark ->
                            Light
              }
            , Cmd.none
            )

        CompilerMsg _ ->
            -- Handle compiler messages (selection, etc.)
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize WindowResized



-- VIEW


sidebarWidth : Int
sidebarWidth =
    200


view : Model -> Html Msg
view model =
    let
        params =
            { filter = NoFilter
            , windowWidth = panelWidth model
            , selectedId = ""
            , theme = model.theme
            , editCount = model.editCount
            , width = panelWidth model
            , showTOC = False
            , paragraphSpacing = 18
            }

        output =
            Compiler.compile params (String.lines model.sourceText)

        bgColor =
            case model.theme of
                Light ->
                    "#f5f5f5"

                Dark ->
                    "#1a1a1a"

        textColor =
            case model.theme of
                Light ->
                    "#333"

                Dark ->
                    "#e0e0e0"

        panelBg =
            case model.theme of
                Light ->
                    "#fff"

                Dark ->
                    "#2a2a2a"
    in
    Html.div
        [ HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        , HA.style "height" "100vh"
        , HA.style "width" "100vw"
        , HA.style "background-color" bgColor
        , HA.style "color" textColor
        , HA.style "font-family" "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
        , HA.style "overflow" "hidden"
        ]
        [ viewHeader model
        , Html.div
            [ HA.style "display" "flex"
            , HA.style "flex" "1"
            , HA.style "overflow" "hidden"
            , HA.style "padding" "10px"
            , HA.style "gap" "10px"
            ]
            [ viewSidebar model panelBg textColor
            , viewEditor model panelBg textColor
            , viewPreview model panelBg textColor output
            ]
        ]


viewSidebar : Model -> String -> String -> Html Msg
viewSidebar model panelBg textColor =
    let
        hoverBg =
            case model.theme of
                Light ->
                    "#e8e8e8"

                Dark ->
                    "#3a3a3a"

        selectedBg =
            case model.theme of
                Light ->
                    "#d0d0d0"

                Dark ->
                    "#4a4a4a"
    in
    Html.div
        [ HA.style "width" (String.fromInt sidebarWidth ++ "px")
        , HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        , HA.style "flex-shrink" "0"
        ]
        [ Html.div
            [ HA.style "font-weight" "bold"
            , HA.style "margin-bottom" "8px"
            , HA.style "font-size" "0.9em"
            , HA.style "display" "flex"
            , HA.style "justify-content" "space-between"
            , HA.style "align-items" "center"
            ]
            [ Html.text "Documents"
            , Html.button
                [ HE.onClick NewDocument
                , HA.style "padding" "4px 8px"
                , HA.style "cursor" "pointer"
                , HA.style "border" "1px solid #ccc"
                , HA.style "border-radius" "4px"
                , HA.style "background-color" panelBg
                , HA.style "color" textColor
                , HA.style "font-size" "0.85em"
                ]
                [ Html.text "+ New" ]
            ]
        , Html.div
            [ HA.style "flex" "1"
            , HA.style "border" "1px solid #ccc"
            , HA.style "border-radius" "4px"
            , HA.style "overflow-y" "auto"
            , HA.style "background-color" panelBg
            ]
            (List.map
                (\doc ->
                    Html.div
                        [ HE.onClick (SelectDocument doc.id)
                        , HA.style "padding" "8px 12px"
                        , HA.style "cursor" "pointer"
                        , HA.style "border-bottom" "1px solid #ccc"
                        , HA.style "display" "flex"
                        , HA.style "justify-content" "space-between"
                        , HA.style "align-items" "center"
                        , HA.style "background-color"
                            (if doc.id == model.currentDocumentId then
                                selectedBg

                             else
                                panelBg
                            )
                        ]
                        [ Html.span
                            [ HA.style "overflow" "hidden"
                            , HA.style "text-overflow" "ellipsis"
                            , HA.style "white-space" "nowrap"
                            , HA.style "flex" "1"
                            , HA.style "font-size" "0.9em"
                            ]
                            [ Html.text
                                (if doc.id == model.currentDocumentId then
                                    "▸ " ++ doc.title

                                 else
                                    doc.title
                                )
                            ]
                        , Html.button
                            [ HE.stopPropagationOn "click"
                                (Decode.succeed ( DeleteDocument doc.id, True ))
                            , HA.style "padding" "2px 6px"
                            , HA.style "cursor" "pointer"
                            , HA.style "border" "1px solid #ccc"
                            , HA.style "border-radius" "3px"
                            , HA.style "background-color" "transparent"
                            , HA.style "color" "#999"
                            , HA.style "font-size" "0.75em"
                            , HA.title "Delete document"
                            ]
                            [ Html.text "×" ]
                        ]
                )
                model.documents
            )
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    Html.div
        [ HA.style "display" "flex"
        , HA.style "justify-content" "space-between"
        , HA.style "align-items" "center"
        , HA.style "padding" "10px 20px"
        , HA.style "border-bottom" "1px solid #ccc"
        ]
        [ Html.h1
            [ HA.style "margin" "0"
            , HA.style "font-size" "1.2em"
            ]
            [ Html.text "ScriptaV3 Compiler Demo" ]
        , Html.button
            [ HE.onClick ToggleTheme
            , HA.style "padding" "8px 16px"
            , HA.style "cursor" "pointer"
            , HA.style "border" "1px solid #ccc"
            , HA.style "border-radius" "4px"
            , HA.style "background-color"
                (case model.theme of
                    Light ->
                        "#fff"

                    Dark ->
                        "#444"
                )
            , HA.style "color"
                (case model.theme of
                    Light ->
                        "#333"

                    Dark ->
                        "#e0e0e0"
                )
            ]
            [ Html.text
                (case model.theme of
                    Light ->
                        "Dark Mode"

                    Dark ->
                        "Light Mode"
                )
            ]
        ]


viewEditor : Model -> String -> String -> Html Msg
viewEditor model panelBg textColor =
    Html.div
        [ HA.style "flex" "1"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        , HA.style "min-width" "0"
        ]
        [ Html.div
            [ HA.style "font-weight" "bold"
            , HA.style "margin-bottom" "8px"
            , HA.style "font-size" "0.9em"
            ]
            [ Html.text "Source" ]
        , Html.textarea
            [ HA.value model.sourceText
            , HE.onInput SourceChanged
            , HA.style "flex" "1"
            , HA.style "width" "100%"
            , HA.style "padding" "12px"
            , HA.style "font-family" "monospace"
            , HA.style "font-size" "14px"
            , HA.style "line-height" "1.5"
            , HA.style "border" "1px solid #ccc"
            , HA.style "border-radius" "4px"
            , HA.style "resize" "none"
            , HA.style "background-color" panelBg
            , HA.style "color" textColor
            , HA.style "box-sizing" "border-box"
            ]
            []
        ]


viewPreview : Model -> String -> String -> CompilerOutput Types.Msg -> Html Msg
viewPreview model panelBg textColor output =
    Html.div
        [ HA.style "flex" "1"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        , HA.style "min-width" "0"
        ]
        [ Html.div
            [ HA.style "font-weight" "bold"
            , HA.style "margin-bottom" "8px"
            , HA.style "font-size" "0.9em"
            ]
            [ Html.text "Rendered Output" ]
        , Html.div
            [ HA.style "flex" "1"
            , HA.style "padding" "12px"
            , HA.style "border" "1px solid #ccc"
            , HA.style "border-radius" "4px"
            , HA.style "overflow-y" "auto"
            , HA.style "background-color" panelBg
            , HA.style "color" textColor
            , HA.style "line-height" "1.6"
            ]
            (List.map (Html.map CompilerMsg) output.body)
        ]


panelWidth : Model -> Int
panelWidth model =
    -- Account for sidebar (200px), padding (10px * 2), and gaps (10px * 2)
    (model.windowWidth - sidebarWidth - 50) // 2
