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
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.Keyed as Keyed
import Json.Decode as Decode
import Json.Encode as Encode
import Task
import V3.Compiler
import V3.Types exposing (CompilerOutput, Filter(..), Msg(..), Theme(..))



-- PORTS


port saveDocuments : Encode.Value -> Cmd msg


{-| Send selection position to the editor.
The record contains lineNumber, begin (char offset), end (char offset),
and numberOfLines (for block-level selection of multi-line elements).
-}
port selectInEditor : { lineNumber : Int, begin : Int, end : Int, numberOfLines : Int } -> Cmd msg


{-| Scroll an element into view, centered in the viewport.
-}
port scrollToElement : String -> Cmd msg


{-| Blur the currently focused element to prevent focus-based scrolling.
-}
port blurActiveElement : () -> Cmd msg


{-| Preserve current scroll position (captures and immediately restores).
-}
port preserveScrollPosition : () -> Cmd msg


{-| Trigger a file download with the current documents as JSON.
The value contains { filename: String, documents: List Document }
-}
port exportDocuments : { filename : String, documents : Encode.Value } -> Cmd msg


{-| Request the browser to open a file picker for importing documents.
-}
port requestImport : () -> Cmd msg


{-| Receive imported documents from JavaScript.
-}
port importedDocuments : (Decode.Value -> msg) -> Sub msg



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


type SortMode
    = ByDate -- Most recent first (creation order)
    | Alphabetical -- A to Z, ignoring case and noise words


type alias Model =
    { documents : List Document
    , currentDocumentId : String
    , sourceText : String
    , windowWidth : Int
    , windowHeight : Int
    , theme : Theme
    , editCount : Int
    , selectedId : String
    , previousId : String -- For ESC-to-return scroll navigation
    , debugClickCount : Int
    , deleteConfirmation : Maybe String -- Document ID pending deletion confirmation
    , sortMode : SortMode
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
        -- Re-extract titles from content to handle title blocks with properties
        refreshTitle : Document -> Document
        refreshTitle doc =
            { doc | title = extractTitle doc.content }

        documents =
            case Decode.decodeValue documentsDecoder flags.documents of
                Ok docs ->
                    if List.isEmpty docs then
                        [ defaultDocument ]

                    else
                        List.map refreshTitle docs

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
      , selectedId = ""
      , previousId = ""
      , debugClickCount = 0
      , deleteConfirmation = Nothing
      , sortMode = ByDate
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
    let
        lines =
            String.lines content

        -- Find index of line starting with "| title" (with or without properties)
        titleLineIndex =
            lines
                |> List.indexedMap Tuple.pair
                |> List.filter (\( _, line ) -> String.startsWith "| title" (String.trim line))
                |> List.head
                |> Maybe.map Tuple.first

        -- Get the line after the title block header
        titleText =
            case titleLineIndex of
                Just idx ->
                    lines
                        |> List.drop (idx + 1)
                        |> List.head
                        |> Maybe.map String.trim
                        |> Maybe.withDefault "Untitled"

                Nothing ->
                    "Untitled"
    in
    if String.isEmpty titleText then
        "Untitled"

    else
        titleText


{-| Convert a title to a valid filename.
Lowercases, removes non-alphanumeric characters (except spaces),
compresses runs of spaces, and replaces spaces with underscores.
-}
titleToFilename : String -> String
titleToFilename title =
    title
        |> String.toLower
        |> String.toList
        |> List.map
            (\c ->
                if Char.isAlphaNum c || c == ' ' then
                    c

                else
                    ' '
            )
        |> String.fromList
        |> String.words
        |> String.join "_"



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
    | RequestDeleteDocument String
    | ConfirmDelete
    | CancelDelete
    | SetSortMode SortMode
    | GotViewport Browser.Dom.Viewport
    | WindowResized Int Int
    | ToggleTheme
    | EscapePressed
    | ShiftEscapePressed
    | ExportDocuments
    | RequestImportDocuments
    | GotImportedDocuments Decode.Value
    | CompilerMsg V3.Types.Msg


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

        RequestDeleteDocument docId ->
            ( { model | deleteConfirmation = Just docId }, Cmd.none )

        CancelDelete ->
            ( { model | deleteConfirmation = Nothing }, Cmd.none )

        SetSortMode mode ->
            ( { model | sortMode = mode }, Cmd.none )

        ConfirmDelete ->
            case model.deleteConfirmation of
                Nothing ->
                    ( model, Cmd.none )

                Just docId ->
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
                        , deleteConfirmation = Nothing
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

        EscapePressed ->
            -- Return to previous position if available
            if model.previousId /= "" then
                ( { model
                    | selectedId = model.previousId
                    , previousId = model.selectedId
                  }
                , scrollToElement model.previousId
                )

            else
                ( model, Cmd.none )

        ShiftEscapePressed ->
            -- Clear all highlighting, preserve scroll position
            ( { model
                | selectedId = ""
                , previousId = ""
              }
            , Cmd.batch [ blurActiveElement (), preserveScrollPosition () ]
            )

        ExportDocuments ->
            let
                currentDoc =
                    model.documents
                        |> List.filter (\doc -> doc.id == model.currentDocumentId)
                        |> List.head

                filename =
                    case currentDoc of
                        Just doc ->
                            titleToFilename doc.title ++ ".json"

                        Nothing ->
                            "scripta-documents.json"
            in
            ( model
            , exportDocuments
                { filename = filename
                , documents = encodeDocuments model.documents
                }
            )

        RequestImportDocuments ->
            ( model, requestImport () )

        GotImportedDocuments value ->
            case Decode.decodeValue documentsDecoder value of
                Ok importedDocs ->
                    let
                        -- Merge imported docs, avoiding duplicates by id
                        existingIds =
                            List.map .id model.documents

                        newDocs =
                            List.filter (\doc -> not (List.member doc.id existingIds)) importedDocs

                        mergedDocuments =
                            model.documents ++ newDocs
                    in
                    ( { model
                        | documents = mergedDocuments
                        , editCount = model.editCount + 1
                      }
                    , saveDocuments (encodeDocuments mergedDocuments)
                    )

                Err _ ->
                    ( model, Cmd.none )

        CompilerMsg compilerMsg ->
            let
                newClickCount =
                    model.debugClickCount + 1
            in
            case compilerMsg of
                V3.Types.SelectId id ->
                    -- Save current position before navigating
                    ( { model
                        | selectedId = id
                        , previousId = model.selectedId
                        , debugClickCount = newClickCount
                      }
                    , scrollToElement id
                    )

                V3.Types.SendMeta meta ->
                    -- SendMeta contains source position info for editor sync
                    -- Extract line number from id format "e-{lineNumber}.{tokenIndex}"
                    let
                        lineNumber =
                            meta.id
                                |> String.dropLeft 2
                                -- drop "e-"
                                |> String.split "."
                                |> List.head
                                |> Maybe.andThen String.toInt
                                |> Maybe.withDefault 0

                        cmd =
                            selectInEditor
                                { lineNumber = lineNumber
                                , begin = meta.begin
                                , end = meta.end
                                , numberOfLines = 0
                                }
                    in
                    ( { model | selectedId = meta.id, debugClickCount = newClickCount }, cmd )

                V3.Types.SendBlockMeta blockMeta ->
                    let
                        cmd =
                            selectInEditor
                                { lineNumber = blockMeta.lineNumber
                                , begin = 0
                                , end = 0
                                , numberOfLines = blockMeta.numberOfLines
                                }
                    in
                    ( { model | selectedId = blockMeta.id, debugClickCount = newClickCount }, cmd )

                V3.Types.HighlightId id ->
                    ( { model | selectedId = id, debugClickCount = newClickCount }, Cmd.none )

                V3.Types.ExpandImage _ ->
                    -- Image expansion not implemented in Demo app
                    ( { model | debugClickCount = newClickCount }, Cmd.none )

                V3.Types.FootnoteClick { targetId } ->
                    ( { model | selectedId = targetId, debugClickCount = newClickCount }, scrollToElement targetId )

                V3.Types.CitationClick { targetId } ->
                    ( { model | selectedId = targetId, debugClickCount = newClickCount }, scrollToElement targetId )

                V3.Types.GoToDocument _ _ ->
                    ( { model | debugClickCount = newClickCount }, Cmd.none )

                V3.Types.NoOp ->
                    ( { model | debugClickCount = newClickCount }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize WindowResized
        , Browser.Events.onKeyUp escapeKeyDecoder
        , importedDocuments GotImportedDocuments
        ]


{-| Decode ESC key press. Shift+ESC clears highlighting, ESC alone returns to previous position.
-}
escapeKeyDecoder : Decode.Decoder Msg
escapeKeyDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "key" Decode.string)
        (Decode.field "shiftKey" Decode.bool)
        |> Decode.andThen
            (\( key, shiftKey ) ->
                if key == "Escape" then
                    if shiftKey then
                        Decode.succeed ShiftEscapePressed

                    else
                        Decode.succeed EscapePressed

                else
                    Decode.fail "not escape"
            )



-- VIEW


sidebarWidth : Int
sidebarWidth =
    200


view : Model -> Html Msg
view model =
    let
        sizing =
            { baseFontSize = 14.0
            , paragraphSpacing = 18.0
            , marginLeft = 0.0
            , marginRight = 120.0
            , indentation = 20.0
            , indentUnit = 2
            , scale = 1.0
            }

        params : V3.Types.CompilerParameters
        params =
            { filter = NoFilter
            , windowWidth = panelWidth model
            , selectedId = model.selectedId
            , theme = model.theme
            , editCount = model.editCount
            , width = panelWidth model
            , showTOC = False
            , sizing = sizing
            , maxLevel = 0
            }

        output =
            V3.Compiler.compile params (String.lines model.sourceText)

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
        , viewDeleteConfirmation model
        ]


viewSidebar : Model -> String -> String -> Html Msg
viewSidebar model panelBg textColor =
    let
        selectedBg =
            case model.theme of
                Light ->
                    "#d0d0d0"

                Dark ->
                    "#4a4a4a"

        sortedDocs =
            sortDocuments model.sortMode model.documents

        sortButtonStyle isActive =
            [ HA.style "padding" "2px 6px"
            , HA.style "cursor" "pointer"
            , HA.style "border" "1px solid #ccc"
            , HA.style "border-radius" "3px"
            , HA.style "font-size" "0.75em"
            , HA.style "background-color"
                (if isActive then
                    case model.theme of
                        Light ->
                            "#007bff"

                        Dark ->
                            "#0056b3"

                 else
                    panelBg
                )
            , HA.style "color"
                (if isActive then
                    "#fff"

                 else
                    textColor
                )
            ]
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
            [ HA.style "display" "flex"
            , HA.style "gap" "4px"
            , HA.style "margin-bottom" "8px"
            , HA.style "font-size" "0.8em"
            ]
            [ Html.span
                [ HA.style "margin-right" "4px"
                , HA.style "color" textColor
                ]
                [ Html.text "Sort:" ]
            , Html.button
                (HE.onClick (SetSortMode ByDate) :: sortButtonStyle (model.sortMode == ByDate))
                [ Html.text "Date" ]
            , Html.button
                (HE.onClick (SetSortMode Alphabetical) :: sortButtonStyle (model.sortMode == Alphabetical))
                [ Html.text "A-Z" ]
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
                                (Decode.succeed ( RequestDeleteDocument doc.id, True ))
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
                sortedDocs
            )
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    let
        buttonStyle =
            [ HA.style "padding" "8px 16px"
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
    in
    Html.div
        [ HA.style "display" "flex"
        , HA.style "justify-content" "space-between"
        , HA.style "align-items" "center"
        , HA.style "padding" "10px 20px"
        , HA.style "border-bottom" "1px solid #ccc"
        , HA.style "flex-shrink" "0"
        , HA.style "min-height" "50px"
        , HA.style "overflow" "visible"
        ]
        [ Html.h1
            [ HA.style "margin" "0"
            , HA.style "font-size" "1.2em"
            , HA.style "white-space" "nowrap"
            ]
            [ Html.text "ScriptaV3 Demo" ]
        , Html.div
            [ HA.style "display" "flex"
            , HA.style "gap" "8px"
            , HA.style "flex-shrink" "0"
            ]
            [ Html.button
                (HE.onClick ExportDocuments :: buttonStyle)
                [ Html.text "Export" ]
            , Html.button
                (HE.onClick RequestImportDocuments :: buttonStyle)
                [ Html.text "Import" ]
            , Html.button
                (HE.onClick ToggleTheme :: buttonStyle)
                [ Html.text
                    (case model.theme of
                        Light ->
                            "Dark Mode"

                        Dark ->
                            "Light Mode"
                    )
                ]
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
        , Html.div
            [ HA.style "flex" "1"
            , HA.style "border" "1px solid #ccc"
            , HA.style "border-radius" "4px"
            , HA.style "overflow" "hidden"
            , HA.style "background-color" panelBg
            ]
            [ -- Use Keyed.node to force recreation when document changes
              Keyed.node "div"
                [ HA.style "height" "100%"
                , HA.style "width" "100%"
                ]
                [ ( model.currentDocumentId
                  , Html.node "codemirror-editor"
                        [ HA.attribute "load" model.sourceText
                        , onTextChange
                        , HA.style "height" "100%"
                        , HA.style "width" "100%"
                        ]
                        []
                  )
                ]
            ]
        ]


{-| Decode the text-change custom event from CodeMirror.
The event detail contains { position: Int, source: String }.
-}
onTextChange : Html.Attribute Msg
onTextChange =
    HE.on "text-change"
        (Decode.at [ "detail", "source" ] Decode.string
            |> Decode.map SourceChanged
        )


viewPreview : Model -> String -> String -> CompilerOutput V3.Types.Msg -> Html Msg
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
            [ HA.id "rendered-output"
            , HA.style "flex" "1"
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


viewDeleteConfirmation : Model -> Html Msg
viewDeleteConfirmation model =
    case model.deleteConfirmation of
        Nothing ->
            Html.text ""

        Just _ ->
            Html.div
                [ HA.style "position" "fixed"
                , HA.style "top" "0"
                , HA.style "left" "0"
                , HA.style "width" "100vw"
                , HA.style "height" "100vh"
                , HA.style "background-color" "rgba(0, 0, 0, 0.5)"
                , HA.style "display" "flex"
                , HA.style "justify-content" "center"
                , HA.style "align-items" "center"
                , HA.style "z-index" "1000"
                ]
                [ Html.div
                    [ HA.style "background-color" "#fff"
                    , HA.style "padding" "24px"
                    , HA.style "border-radius" "8px"
                    , HA.style "box-shadow" "0 4px 20px rgba(0, 0, 0, 0.3)"
                    , HA.style "max-width" "400px"
                    , HA.style "text-align" "center"
                    ]
                    [ Html.p
                        [ HA.style "margin" "0 0 20px 0"
                        , HA.style "color" "#333"
                        , HA.style "font-size" "1em"
                        , HA.style "line-height" "1.5"
                        ]
                        [ Html.text "Do you want to delete this document? This action cannot be undone." ]
                    , Html.div
                        [ HA.style "display" "flex"
                        , HA.style "justify-content" "center"
                        , HA.style "gap" "12px"
                        ]
                        [ Html.button
                            [ HE.onClick ConfirmDelete
                            , HA.style "padding" "8px 24px"
                            , HA.style "cursor" "pointer"
                            , HA.style "border" "none"
                            , HA.style "border-radius" "4px"
                            , HA.style "background-color" "#dc3545"
                            , HA.style "color" "#fff"
                            , HA.style "font-size" "0.95em"
                            ]
                            [ Html.text "Yes" ]
                        , Html.button
                            [ HE.onClick CancelDelete
                            , HA.style "padding" "8px 24px"
                            , HA.style "cursor" "pointer"
                            , HA.style "border" "1px solid #ccc"
                            , HA.style "border-radius" "4px"
                            , HA.style "background-color" "#fff"
                            , HA.style "color" "#333"
                            , HA.style "font-size" "0.95em"
                            ]
                            [ Html.text "No" ]
                        ]
                    ]
                ]


panelWidth : Model -> Int
panelWidth model =
    -- Account for sidebar (200px), padding (10px * 2), and gaps (10px * 2)
    (model.windowWidth - sidebarWidth - 50) // 2



-- SORTING


{-| Noise words to ignore when sorting alphabetically.
-}
noiseWords : List String
noiseWords =
    [ "a", "an", "the" ]


{-| Get the sort key for a document title, ignoring case and leading noise words.
-}
sortKey : String -> String
sortKey title =
    let
        lowerTitle =
            String.toLower (String.trim title)

        words =
            String.words lowerTitle

        -- Remove leading noise word if present
        significantWords =
            case words of
                first :: rest ->
                    if List.member first noiseWords then
                        rest

                    else
                        words

                [] ->
                    []
    in
    String.join " " significantWords


{-| Sort documents according to the current sort mode.
-}
sortDocuments : SortMode -> List Document -> List Document
sortDocuments mode docs =
    case mode of
        ByDate ->
            -- Keep original order (most recent last in the list, but we display newest first)
            List.reverse docs

        Alphabetical ->
            List.sortBy (\doc -> sortKey doc.title) docs
