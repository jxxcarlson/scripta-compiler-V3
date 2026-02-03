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
import Types exposing (Accumulator, CompilerParameters, ExpressionBlock, MathMacroDict, Msg(..), Theme(..))


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
          -- Book/document info
        , ( "book", renderBook )
        , ( "article", renderArticle )
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


{-| Render a display math block (unnumbered).

    | math
    \int_0^1 x^n dx = \frac{1}{n+1}

-}
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


{-| Render a numbered equation block.

    | equation
    E = mc^2

Supports alignment with & for multi-line equations:

    | equation
    a &= b + c \\
    &= d

-}
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

        -- Get equation number from block properties (set by transformBlock when label is present)
        equationNumber =
            Dict.get "equation-number" block.properties |> Maybe.withDefault ""
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


{-| Render an aligned math block (unnumbered, multi-line).

    | aligned
    a &= b + c \\
    &= d + e

-}
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
Also expands user-defined macros from mathmacros blocks.

-}
applyMathMacros : MathMacroDict -> String -> String
applyMathMacros macroDict content =
    ETeX.Transform.evalStr macroDict content



-- CODE BLOCKS


{-| Render a code block with syntax highlighting style.

    | code
    function hello() {
        console.log("Hello!");
    }

-}
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
            , HA.style "font-size" "13px"
            ]
            [ Html.code
                [ HA.class ("language-" ++ language) ]
                [ Html.text content ]
            ]
        ]
    ]



-- VERSE


{-| Render a verse/poetry block preserving line breaks.

    | verse
    Roses are red,
    Violets are blue,
    Sugar is sweet,
    And so are you.

-}
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


{-| Define math macros for use in math blocks. Hidden in output.

    | mathmacros
    \newcommand{\R}{\mathbb{R}}
    \newcommand{\norm}[1]{\left\| #1 \right\|}

-}
renderMathMacros : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderMathMacros _ _ _ block _ =
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


{-| Define text macros for use in document. Hidden in output.

    | textmacros
    \newcommand{\version}{2.0}

-}
renderTextMacros : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTextMacros _ _ _ block _ =
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]



-- DATA AND CHARTS


{-| Render raw data in a preformatted block.

    | datatable
    x, y, z
    1, 2, 3
    4, 5, 6

-}
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


{-| Render a chart (placeholder, requires external JS library).

    | chart
    type: bar
    data: ...

-}
renderChart : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderChart params _ _ block _ =
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


{-| Render inline SVG content (placeholder, requires JS integration).

    | svg
    <svg width="100" height="100">
      <circle cx="50" cy="50" r="40" fill="red" />
    </svg>

-}
renderSvg : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSvg params _ _ block _ =
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
            , HA.style "font-size" "13px"
            ]
            [ Html.text "[SVG content - requires JS integration]" ]
        ]
    ]


{-| Render a Quiver commutative diagram (placeholder, requires external integration).

    | quiver
    [quiver diagram data]

-}
renderQuiver : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderQuiver params _ _ block _ =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.class "quiver-placeholder"
         , HA.style "margin" "1em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.text "[Quiver Diagram]" ]
    ]


{-| Render a TikZ diagram (placeholder, requires external integration).

    | tikz
    \begin{tikzpicture}
    \draw (0,0) -- (1,1);
    \end{tikzpicture}

-}
renderTikz : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTikz params _ _ block _ =
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


{-| Render an image block.

    | image [arguments] [properties]
    <url>

Arguments:

  - expandable: Click thumbnail to open full-size overlay; click overlay to close

Properties:

  - width: Image width. Values: pixel number, "fill" (100%), or "to-edges" (120% of panel)
  - float: Float image with text wrap. Values: "left" or "right"
  - ypadding: Vertical padding in pixels (default 18, ignored when floated)
  - description: Alt text for accessibility
  - figure: Figure number (displays "Figure N")
  - caption: Caption text (italic, below image)

Examples:

    | image
    https://example.com/photo.jpg

    | image expandable width:400 caption:A lovely sunset
    https://example.com/sunset.jpg

    | image float:left width:200
    https://example.com/portrait.jpg

-}
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

        -- Vertical padding (used for non-floated images)
        ypadding =
            Dict.get "ypadding" block.properties
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 18

        -- Float: left or right (small top margin to align with text baseline)
        floatStyle =
            case Dict.get "float" block.properties of
                Just "left" ->
                    [ HA.style "float" "left"
                    , HA.style "margin-right" "1em"
                    , HA.style "margin-top" "4px"
                    , HA.style "margin-bottom" "0.5em"
                    ]

                Just "right" ->
                    [ HA.style "float" "right"
                    , HA.style "margin-left" "1em"
                    , HA.style "margin-top" "4px"
                    , HA.style "margin-bottom" "0.5em"
                    ]

                _ ->
                    [ HA.style "text-align" "center"
                    , HA.style "padding-top" (String.fromInt ypadding ++ "px")
                    , HA.style "padding-bottom" (String.fromInt ypadding ++ "px")
                    ]

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

        -- Check if expandable (as an argument)
        isExpandable =
            List.member "expandable" block.args

        lightboxId =
            "lightbox-" ++ block.meta.id

        -- Expandable: click to show overlay
        expandableImage =
            Html.span []
                [ -- Clickable thumbnail
                  Html.a
                    [ HA.href ("#" ++ lightboxId)
                    , HA.style "cursor" "zoom-in"
                    , HA.style "display" "inline-block"
                    ]
                    [ imageElement ]

                -- Lightbox overlay (hidden until targeted)
                , Html.a
                    [ HA.id lightboxId
                    , HA.href "#"
                    , HA.style "position" "fixed"
                    , HA.style "top" "0"
                    , HA.style "left" "0"
                    , HA.style "width" "100vw"
                    , HA.style "height" "100vh"
                    , HA.style "background" "rgba(0, 0, 0, 0.85)"
                    , HA.style "display" "flex"
                    , HA.style "align-items" "center"
                    , HA.style "justify-content" "center"
                    , HA.style "z-index" "9999"
                    , HA.style "opacity" "0"
                    , HA.style "pointer-events" "none"
                    , HA.style "transition" "opacity 0.2s"
                    , HA.style "cursor" "zoom-out"
                    ]
                    [ -- Full-size image (pointer-events:none so clicks go to parent)
                      Html.img
                        [ HA.src src
                        , HA.alt description
                        , HA.style "max-width" "90vw"
                        , HA.style "max-height" "90vh"
                        , HA.style "object-fit" "contain"
                        , HA.style "pointer-events" "none"
                        ]
                        []
                    ]

                -- CSS for :target (inline style element)
                , Html.node "style"
                    []
                    [ Html.text ("#" ++ lightboxId ++ ":target { opacity: 1 !important; pointer-events: auto !important; }") ]
                ]

        -- Choose which image display to use
        imageDisplay =
            if isExpandable then
                expandableImage

            else
                imageElement
    in
    [ Html.div
        ([ idAttr block.meta.id ]
            ++ floatStyle
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ imageDisplay
        , figureLabel
        ]
    ]


{-| Render an embedded iframe.

    | iframe
    https://www.youtube.com/embed/dQw4w9WgXcQ

Properties:

  - width: Width in pixels (default: panel width)
  - height: Height in pixels (default: 400)

-}
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


{-| Load external content (processed at higher level, hidden in output).

    | load
    /path/to/file.md

-}
renderLoad : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderLoad _ _ _ block _ =
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]



-- CHEMISTRY


{-| Render chemical equations using mhchem notation.

    | chem
    2H2 + O2 -> 2H2O

-}
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


{-| Render a LaTeX-style math array.

    | array ccc
    a & b & c \\
    d & e & f

Arguments:

  - Column format (e.g., "ccc" for 3 centered columns, "lcr" for left/center/right)

-}
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


{-| Render a text table with & as column separator.

    | textarray
    Name & Age & City
    Alice & 30 & NYC
    Bob & 25 & LA

Also available as `| table`.

-}
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


{-| Render a CSV table with comma-separated values.

    | csvtable title:Sales Data
    Product,Q1,Q2,Q3
    Widgets,100,150,200
    Gadgets,50,75,100

Properties:

  - title: Optional table title

-}
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


{-| Render raw verbatim text in a preformatted block.

    | verbatim
    This text is displayed exactly as written,
    with all spacing and formatting preserved.

-}
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


{-| Render a book block.

    | book
    title: Nature
    author: Phineas Peabody
    publication-date: 2026

Renders as:

    Nature

    by Phineas Peabody

-}
renderBook : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderBook params _ _ block _ =
    let
        title =
            Dict.get "title" block.properties |> Maybe.withDefault "Untitled"

        author =
            Dict.get "author" block.properties |> Maybe.withDefault ""

        authorLine =
            if author /= "" then
                [ Html.div
                    [ HA.style "margin-top" "0.5em"
                    , HA.style "font-size" "1.2em"
                    ]
                    [ Html.text ("by " ++ author) ]
                ]

            else
                []
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin" "2em 0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.div
            [ HA.style "font-size" "2.5em"
            , HA.style "margin-bottom" "0.5em"
            ]
            [ Html.text title ]
            :: authorLine
        )
    ]


{-| Render an article block.

    | article
    title: On the Nature of Things
    author: Jane Smith

Renders the same as a book block.

-}
renderArticle : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderArticle params acc name block children =
    renderBook params acc name block children



-- NO-OP BLOCKS


{-| Render nothing (for hidden/configuration blocks).

Used for: settings, load-data, hide, texComment, docinfo, load-files, include, setup

-}
renderNothing : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderNothing _ _ _ block _ =
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]
