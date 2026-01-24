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
import Types exposing (Accumulator, CompilerParameters, ExpressionBlock, Msg(..), Theme(..))


{-| Render a verbatim block by name.
-}
render : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
render params acc name block children =
    case Dict.get name blockDict of
        Just renderer ->
            renderer params acc name block children

        Nothing ->
            renderDefault params acc name block children


{-| Dictionary of verbatim block renderers.
-}
blockDict : Dict String (CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg))
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
          -- Chemistry
        , ( "chem", renderChem )
          -- Arrays/tables
        , ( "array", renderArray )
        , ( "textarray", renderTextArray )
        , ( "table", renderTextArray )
        , ( "csvtable", renderCsvTable )
          -- Raw verbatim
        , ( "verbatim", renderVerbatim )
          -- No-op/hidden blocks
        , ( "settings", renderNothing )
        , ( "load-data", renderNothing )
        , ( "hide", renderNothing )
        , ( "texComment", renderNothing )
        , ( "docinfo", renderNothing )
        , ( "load-files", renderNothing )
        , ( "include", renderNothing )
        , ( "setup", renderNothing )
        ]


{-| Default rendering for unknown verbatim block names.
-}
renderDefault : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDefault params _ name block _ =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (String.fromInt params.paragraphSpacing ++ "px")
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
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


renderMath : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderMath params acc _ block _ =
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
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ mathText params.editCount block.meta.id DisplayMathMode content ]
    ]


renderEquation : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderEquation params acc _ block _ =
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
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.div [ HA.style "flex" "1" ] []
        , Html.div []
            [ mathText params.editCount block.meta.id DisplayMathMode content ]
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


renderAligned : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderAligned params acc _ block _ =
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
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ mathText params.editCount block.meta.id DisplayMathMode content ]
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


renderCode : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCode params _ _ block _ =
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
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.pre
            [ HA.style "background-color"
                (case params.theme of
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


renderVerse : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderVerse params _ _ block _ =
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
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.text content ]
    ]



-- MACRO DEFINITIONS


renderMathMacros : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderMathMacros _ _ _ block _ =
    -- Math macros are processed at parse time, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


renderTextMacros : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTextMacros _ _ _ block _ =
    -- Text macros are processed at parse time, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]



-- DATA AND CHARTS


renderDataTable : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDataTable params _ _ block _ =
    let
        content =
            getVerbatimContent block
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.pre [ HA.style "font-family" "monospace" ]
            [ Html.text content ]
        ]
    ]


renderChart : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderChart params _ _ block _ =
    -- Chart rendering requires external JS library integration
    [ Html.div
        ([ idAttr block.meta.id
         , HA.class "chart-placeholder"
         , HA.style "margin" "1em 0"
         , HA.style "min-height" "200px"
         , HA.style "border" "1px dashed #ccc"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.text "[Chart]" ]
    ]



-- GRAPHICS


renderSvg : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSvg params _ _ block _ =
    -- SVG rendering requires embedding raw HTML, which isn't directly
    -- supported in Elm. This is a placeholder that shows SVG content.
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "1em 0"
         , HA.class "svg-container"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.pre
            [ HA.style "font-family" "monospace"
            , HA.style "font-size" "0.8em"
            ]
            [ Html.text "[SVG content - requires JS integration]" ]
        ]
    ]


renderQuiver : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderQuiver params _ _ block _ =
    -- Quiver diagrams require external integration
    [ Html.div
        ([ idAttr block.meta.id
         , HA.class "quiver-placeholder"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.text "[Quiver Diagram]" ]
    ]


renderTikz : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTikz params _ _ block _ =
    -- TikZ requires external integration
    [ Html.div
        ([ idAttr block.meta.id
         , HA.class "tikz-placeholder"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.text "[TikZ Diagram]" ]
    ]



-- MEDIA


renderImage : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderImage params _ _ block _ =
    let
        -- For verbatim blocks, the URL is in body (Left String), not firstLine
        src =
            case block.body of
                Left content ->
                    String.trim content

                Right _ ->
                    block.firstLine

        -- Width: supports "fill", "to-edges", or pixel value
        widthStyle =
            case Dict.get "width" block.properties of
                Nothing ->
                    [ HA.style "max-width" (String.fromInt params.width ++ "px") ]

                Just "fill" ->
                    [ HA.style "width" "100%" ]

                Just "to-edges" ->
                    [ HA.style "max-width" (String.fromInt (round (1.2 * toFloat params.width)) ++ "px") ]

                Just w ->
                    case String.toInt w of
                        Just pixels ->
                            [ HA.style "max-width" (String.fromInt pixels ++ "px") ]

                        Nothing ->
                            [ HA.style "max-width" (String.fromInt params.width ++ "px") ]

        -- Placement: left, right, center
        placement =
            case Dict.get "placement" block.properties of
                Just "left" ->
                    "left"

                Just "right" ->
                    "right"

                _ ->
                    "center"

        -- Vertical padding
        ypadding =
            Dict.get "ypadding" block.properties
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 18

        -- Description (alt text)
        description =
            Dict.get "description" block.properties
                |> Maybe.withDefault ""

        -- Figure label and caption
        figureLabel =
            case ( Dict.get "figure" block.properties, Dict.get "caption" block.properties ) of
                ( Nothing, Nothing ) ->
                    Html.text ""

                ( Nothing, Just cap ) ->
                    Html.div
                        [ HA.style "font-size" "0.9em"
                        , HA.style "font-style" "italic"
                        , HA.style "margin-top" "0.5em"
                        , HA.style "color" "#555"
                        ]
                        [ Html.text cap ]

                ( Just fig, Nothing ) ->
                    Html.div
                        [ HA.style "font-size" "0.9em"
                        , HA.style "margin-top" "0.5em"
                        , HA.style "color" "#555"
                        ]
                        [ Html.text ("Figure " ++ fig) ]

                ( Just fig, Just cap ) ->
                    Html.div
                        [ HA.style "font-size" "0.9em"
                        , HA.style "margin-top" "0.5em"
                        , HA.style "color" "#555"
                        ]
                        [ Html.span [ HA.style "font-weight" "bold" ] [ Html.text ("Figure " ++ fig ++ ". ") ]
                        , Html.span [ HA.style "font-style" "italic" ] [ Html.text cap ]
                        ]

        -- The image element
        imageElement =
            Html.img
                ([ HA.src src
                 , HA.alt description
                 ]
                    ++ widthStyle
                )
                []

        -- Wrap in link to open in new tab
        linkedImage =
            Html.a
                [ HA.href src
                , HA.target "_blank"
                , HA.style "display" "inline-block"
                ]
                [ imageElement ]
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" placement
         , HA.style "padding-top" (String.fromInt ypadding ++ "px")
         , HA.style "padding-bottom" (String.fromInt ypadding ++ "px")
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ linkedImage
        , figureLabel
        ]
    ]


renderIframe : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIframe params _ _ block _ =
    let
        src =
            block.firstLine

        width =
            Dict.get "width" block.properties
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault params.width

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
            ++ selectedStyle params.selectedId block.meta.id params.theme
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


renderLoad : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderLoad _ _ _ block _ =
    -- Load blocks are processed at a higher level, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]



-- CHEMISTRY


renderChem : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderChem params acc _ block children =
    let
        content =
            getVerbatimContent block
                |> (\s -> "\\ce{" ++ s ++ "}")
                |> applyMathMacros acc.mathMacroDict
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ mathText params.editCount block.meta.id DisplayMathMode content ]
    ]



-- ARRAYS


renderArray : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderArray params acc _ block _ =
    let
        format =
            List.head block.args |> Maybe.withDefault "c"

        content =
            getVerbatimContent block
                |> applyMathMacros acc.mathMacroDict

        -- Wrap in array environment
        arrayContent =
            "\\begin{array}{" ++ format ++ "}\n" ++ content ++ "\n\\end{array}"
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ mathText params.editCount block.meta.id DisplayMathMode arrayContent ]
    ]


renderTextArray : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTextArray params _ _ block _ =
    let
        content =
            getVerbatimContent block

        rows =
            content
                |> String.lines
                |> List.filter (\line -> String.trim line /= "")
                |> List.map parseTableRow
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.table
            [ HA.style "border-collapse" "collapse"
            , HA.style "margin" "0 auto"
            ]
            [ Html.tbody [] (List.map renderTextArrayRow rows) ]
        ]
    ]


parseTableRow : String -> List String
parseTableRow line =
    String.split "&" line
        |> List.map String.trim


renderTextArrayRow : List String -> Html Msg
renderTextArrayRow cells =
    Html.tr []
        (List.map
            (\cell ->
                Html.td
                    [ HA.style "padding" "4px 12px"
                    , HA.style "border" "1px solid #ddd"
                    ]
                    [ Html.text cell ]
            )
            cells
        )


renderCsvTable : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCsvTable params _ _ block _ =
    let
        content =
            getVerbatimContent block

        title =
            Dict.get "title" block.properties

        rows =
            content
                |> String.lines
                |> List.filter (\line -> String.trim line /= "")
                |> List.map parseCsvRow

        headerRow =
            List.head rows |> Maybe.withDefault []

        dataRows =
            List.drop 1 rows
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (case title of
            Just t ->
                [ Html.div [ HA.style "font-weight" "bold", HA.style "margin-bottom" "0.5em" ] [ Html.text t ]
                , renderCsvTableHtml headerRow dataRows
                ]

            Nothing ->
                [ renderCsvTableHtml headerRow dataRows ]
        )
    ]


parseCsvRow : String -> List String
parseCsvRow line =
    String.split "," line
        |> List.map String.trim


renderCsvTableHtml : List String -> List (List String) -> Html Msg
renderCsvTableHtml headers rows =
    Html.table
        [ HA.style "border-collapse" "collapse" ]
        [ Html.thead []
            [ Html.tr []
                (List.map
                    (\h ->
                        Html.th
                            [ HA.style "padding" "4px 12px"
                            , HA.style "border-bottom" "2px solid #333"
                            , HA.style "text-align" "left"
                            ]
                            [ Html.text h ]
                    )
                    headers
                )
            ]
        , Html.tbody []
            (List.map
                (\row ->
                    Html.tr []
                        (List.map
                            (\cell ->
                                Html.td
                                    [ HA.style "padding" "4px 12px"
                                    , HA.style "border-bottom" "1px solid #ddd"
                                    ]
                                    [ Html.text cell ]
                            )
                            row
                        )
                )
                rows
            )
        ]



-- RAW VERBATIM


renderVerbatim : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderVerbatim params _ _ block _ =
    let
        content =
            getVerbatimContent block
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.pre
            [ HA.style "font-family" "monospace"
            , HA.style "font-size" "13px"
            , HA.style "background-color" "#f5f5f5"
            , HA.style "padding" "1em"
            , HA.style "padding-left" "2em"
            , HA.style "white-space" "pre-wrap"
            ]
            [ Html.text content ]
        ]
    ]



-- NO-OP BLOCKS


renderNothing : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderNothing _ _ _ block _ =
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]
