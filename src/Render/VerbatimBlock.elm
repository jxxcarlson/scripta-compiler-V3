module Render.VerbatimBlock exposing (render)

{-| Render verbatim blocks to HTML.
-}

import Dict exposing (Dict)
import ETeX.Transform
import Either exposing (Either(..))
import Html exposing (Html)
import Html.Attributes as HA
import Render.Math exposing (DisplayMode(..), mathText)
import Render.Utility exposing (idAttr, selectedStyle)
import Types exposing (Accumulator, CompilerParameters, ExpressionBlock, Msg(..), RenderSettings, Theme(..))


{-| Render a verbatim block by name.
-}
render : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
render params settings acc name block children =
    case Dict.get name blockDict of
        Just renderer ->
            renderer params settings acc name block children

        Nothing ->
            renderDefault params settings acc name block children


{-| Dictionary of verbatim block renderers.
-}
blockDict : Dict String (CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg))
blockDict =
    Dict.fromList
        [ ( "math", renderMath )
        , ( "equation", renderEquation )
        , ( "aligned", renderAligned )
        , ( "code", renderCode )
        , ( "verse", renderVerse )
        , ( "mathmacros", renderMathMacros )
        , ( "textmacros", renderTextMacros )
        , ( "datatable", renderDataTable )
        , ( "chart", renderChart )
        , ( "svg", renderSvg )
        , ( "quiver", renderQuiver )
        , ( "tikz", renderTikz )
        , ( "image", renderImage )
        , ( "iframe", renderIframe )
        , ( "load", renderLoad )
        ]


{-| Default rendering for unknown verbatim block names.
-}
renderDefault : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDefault _ settings _ name block _ =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (String.fromInt settings.paragraphSpacing ++ "px")
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.span [ HA.style "font-weight" "bold", HA.style "color" "purple" ]
            [ Html.text ("[verbatim:" ++ name ++ "]") ]
        , Html.pre [ HA.style "margin" "0.5em 0" ]
            [ Html.text (getVerbatimContent block) ]
        ]
    ]


{-| Get verbatim content from block body.
-}
getVerbatimContent : ExpressionBlock -> String
getVerbatimContent block =
    case block.body of
        Left content ->
            content

        Right _ ->
            ""



-- MATH BLOCKS


renderMath : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderMath _ settings acc _ block _ =
    let
        content =
            getVerbatimContent block
                |> applyMathMacros acc.mathMacroDict
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ mathText settings.editCount block.meta.id DisplayMathMode content ]
    ]


renderEquation : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderEquation _ settings acc _ block _ =
    let
        rawContent =
            getVerbatimContent block
                |> applyMathMacros acc.mathMacroDict

        -- If content contains &, wrap in aligned environment for KaTeX
        content =
            if String.contains "&" rawContent then
                wrapInAligned rawContent

            else
                rawContent

        equationNumber =
            case Dict.get block.meta.id acc.reference of
                Just { numRef } ->
                    numRef

                Nothing ->
                    ""
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "display" "flex"
         , HA.style "justify-content" "center"
         , HA.style "align-items" "center"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.div [ HA.style "flex" "1" ] []
        , Html.div []
            [ mathText settings.editCount block.meta.id DisplayMathMode content ]
        , Html.div
            [ HA.style "flex" "1"
            , HA.style "text-align" "right"
            , HA.style "padding-right" "1em"
            ]
            [ Html.text
                (if equationNumber /= "" then
                    "(" ++ equationNumber ++ ")"

                 else
                    ""
                )
            ]
        ]
    ]


renderAligned : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderAligned _ settings acc _ block _ =
    let
        content =
            getVerbatimContent block
                |> applyMathMacros acc.mathMacroDict
                |> wrapInAligned
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ mathText settings.editCount block.meta.id DisplayMathMode content ]
    ]


wrapInAligned : String -> String
wrapInAligned content =
    "\\begin{aligned}\n" ++ content ++ "\n\\end{aligned}"


{-| Transform ETeX notation to LaTeX using ETeX.Transform.evalStr.

Converts notation like `int_0^2`, `frac(1,n+1)` to `\int_0^2`, `\frac{1}{n+1}`.

-}
applyMathMacros : Dict String String -> String -> String
applyMathMacros _ content =
    -- Use ETeX.Transform.evalStr to transform ETeX notation to LaTeX
    -- Pass empty dict for user-defined macros (TODO: integrate with accumulator)
    ETeX.Transform.evalStr Dict.empty content



-- CODE BLOCKS


renderCode : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCode _ settings _ _ block _ =
    let
        language =
            List.head block.args |> Maybe.withDefault ""

        content =
            getVerbatimContent block
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.pre
            [ HA.style "background-color"
                (case settings.theme of
                    Light ->
                        "#f5f5f5"

                    Dark ->
                        "#1e1e1e"
                )
            , HA.style "padding" "1em"
            , HA.style "border-radius" "4px"
            , HA.style "overflow-x" "auto"
            , HA.style "font-family" "monospace"
            , HA.style "font-size" "0.9em"
            ]
            [ Html.code
                [ HA.class ("language-" ++ language) ]
                [ Html.text content ]
            ]
        ]
    ]



-- VERSE


renderVerse : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderVerse _ settings _ _ block _ =
    let
        content =
            getVerbatimContent block
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 2em"
         , HA.style "font-style" "italic"
         , HA.style "white-space" "pre-wrap"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.text content ]
    ]



-- MACRO DEFINITIONS


renderMathMacros : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderMathMacros _ _ _ _ block _ =
    -- Math macros are processed at parse time, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


renderTextMacros : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTextMacros _ _ _ _ block _ =
    -- Text macros are processed at parse time, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]



-- DATA AND CHARTS


renderDataTable : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDataTable _ settings _ _ block _ =
    let
        content =
            getVerbatimContent block
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.pre [ HA.style "font-family" "monospace" ]
            [ Html.text content ]
        ]
    ]


renderChart : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderChart _ settings _ _ block _ =
    -- Chart rendering requires external JS library integration
    [ Html.div
        ([ idAttr block.meta.id
         , HA.class "chart-placeholder"
         , HA.style "margin" "1em 0"
         , HA.style "min-height" "200px"
         , HA.style "border" "1px dashed #ccc"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.text "[Chart]" ]
    ]



-- GRAPHICS


renderSvg : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSvg _ settings _ _ block _ =
    -- SVG rendering requires embedding raw HTML, which isn't directly
    -- supported in Elm. This is a placeholder that shows SVG content.
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "1em 0"
         , HA.class "svg-container"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.pre
            [ HA.style "font-family" "monospace"
            , HA.style "font-size" "0.8em"
            ]
            [ Html.text "[SVG content - requires JS integration]" ]
        ]
    ]


renderQuiver : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderQuiver _ settings _ _ block _ =
    -- Quiver diagrams require external integration
    [ Html.div
        ([ idAttr block.meta.id
         , HA.class "quiver-placeholder"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.text "[Quiver Diagram]" ]
    ]


renderTikz : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTikz _ settings _ _ block _ =
    -- TikZ requires external integration
    [ Html.div
        ([ idAttr block.meta.id
         , HA.class "tikz-placeholder"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.text "[TikZ Diagram]" ]
    ]



-- MEDIA


renderImage : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderImage _ settings _ _ block _ =
    let
        src =
            block.firstLine

        width =
            Dict.get "width" block.properties
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault settings.width
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.img
            [ HA.src src
            , HA.style "max-width" (String.fromInt width ++ "px")
            ]
            []
        ]
    ]


renderIframe : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIframe _ settings _ _ block _ =
    let
        src =
            block.firstLine

        width =
            Dict.get "width" block.properties
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault settings.width

        height =
            Dict.get "height" block.properties
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 400
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        [ Html.iframe
            [ HA.src src
            , HA.style "width" (String.fromInt width ++ "px")
            , HA.style "height" (String.fromInt height ++ "px")
            , HA.style "border" "none"
            ]
            []
        ]
    ]



-- INCLUDES


renderLoad : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderLoad _ _ _ _ block _ =
    -- Load blocks are processed at a higher level, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]
