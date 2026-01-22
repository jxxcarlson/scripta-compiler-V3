port module Main exposing (main)

{-| Demo app for testing the Scripta compiler.

Two side-by-side panels:
- Left: source text editor
- Right: rendered HTML output

Source text is persisted to localStorage.

-}

import Browser
import Browser.Dom
import Browser.Events
import Compiler
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as Decode
import Task
import Types exposing (CompilerOutput, Filter(..), Msg(..), Theme(..))



-- PORTS


port saveSource : String -> Cmd msg


type alias Flags =
    { savedSource : Maybe String
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
    { sourceText : String
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
    ( { sourceText = flags.savedSource |> Maybe.withDefault initialSource
      , windowWidth = 1200
      , windowHeight = 800
      , theme = Light
      , editCount = 0
      }
    , Task.perform GotViewport Browser.Dom.getViewport
    )



-- UPDATE


type Msg
    = SourceChanged String
    | GotViewport Browser.Dom.Viewport
    | WindowResized Int Int
    | ToggleTheme
    | CompilerMsg Types.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SourceChanged newSource ->
            ( { model
                | sourceText = newSource
                , editCount = model.editCount + 1
              }
            , saveSource newSource
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


view : Model -> Html Msg
view model =
    let
        params =
            { filter = NoFilter
            , windowWidth = panelWidth model
            , selectedId = ""
            , theme = model.theme
            , editCount = model.editCount
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
            [ viewEditor model panelBg textColor
            , viewPreview model panelBg textColor output
            ]
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
    (model.windowWidth - 50) // 2
