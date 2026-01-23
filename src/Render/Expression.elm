module Render.Expression exposing (renderList)

{-| Render expressions to HTML.
-}

import Dict exposing (Dict)
import ETeX.Transform
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Render.Math exposing (DisplayMode(..), mathText)
import Types exposing (Accumulator, CompilerParameters, Expr(..), ExprMeta, Expression, Msg(..))


{-| Render a list of expressions.
-}
renderList : CompilerParameters -> Accumulator -> List Expression -> List (Html Msg)
renderList params acc expressions =
    List.map (render params acc) expressions


{-| Render a single expression.
-}
render : CompilerParameters -> Accumulator -> Expression -> Html Msg
render params acc expr =
    case expr of
        Text str meta ->
            renderText str meta

        Fun name args meta ->
            renderFun params acc name args meta

        VFun name content meta ->
            renderVFun params acc name content meta

        ExprList _ exprs meta ->
            Html.span [ HA.id meta.id ]
                (renderList params acc exprs)


{-| Render plain text.
-}
renderText : String -> ExprMeta -> Html Msg
renderText str meta =
    Html.span
        [ HA.id meta.id
        , HE.onClick (SelectId meta.id)
        ]
        [ Html.text str ]


{-| Render a function application.
-}
renderFun : CompilerParameters -> Accumulator -> String -> List Expression -> ExprMeta -> Html Msg
renderFun params acc name args meta =
    case Dict.get name markupDict of
        Just renderer ->
            renderer params acc args meta

        Nothing ->
            -- Default rendering for unknown functions
            renderDefaultFun params acc name args meta


{-| Render a verbatim function.
-}
renderVFun : CompilerParameters -> Accumulator -> String -> String -> ExprMeta -> Html Msg
renderVFun params acc name content meta =
    case name of
        "$" ->
            -- Inline math (legacy) - apply ETeX transform
            mathText params.editCount meta.id InlineMathMode (applyETeXTransform content)

        "math" ->
            -- Inline math - apply ETeX transform
            mathText params.editCount meta.id InlineMathMode (applyETeXTransform content)

        "m" ->
            -- Inline math (short alias) - apply ETeX transform
            mathText params.editCount meta.id InlineMathMode (applyETeXTransform content)

        "chem" ->
            -- Chemistry formula - render as math with mhchem
            mathText params.editCount meta.id InlineMathMode ("\\ce{" ++ content ++ "}")

        "code" ->
            Html.code [ HA.id meta.id ] [ Html.text content ]

        "`" ->
            -- Backtick code (alias for code)
            Html.code [ HA.id meta.id ] [ Html.text content ]

        _ ->
            -- Default: just show the content
            Html.span [ HA.id meta.id ] [ Html.text content ]


{-| Transform ETeX notation to LaTeX using ETeX.Transform.evalStr.

Converts notation like `int_0^2`, `frac(1,n+1)` to `\int_0^2`, `\frac{1}{n+1}`.

-}
applyETeXTransform : String -> String
applyETeXTransform content =
    ETeX.Transform.evalStr Dict.empty content


{-| Default rendering for unknown function names.
-}
renderDefaultFun : CompilerParameters -> Accumulator -> String -> List Expression -> ExprMeta -> Html Msg
renderDefaultFun params acc name args meta =
    Html.span [ HA.id meta.id ]
        (Html.span [ HA.style "color" "blue" ] [ Html.text ("[" ++ name ++ " ") ]
            :: renderList params acc args
            ++ [ Html.text "]" ]
        )



-- MARKUP DICTIONARY


{-| Dictionary of markup function renderers.
-}
markupDict : Dict String (CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg)
markupDict =
    Dict.fromList
        [ ( "strong", renderStrong )
        , ( "bold", renderStrong )
        , ( "b", renderStrong )
        , ( "italic", renderItalic )
        , ( "i", renderItalic )
        , ( "emph", renderItalic )
        , ( "strike", renderStrike )
        , ( "underline", renderUnderline )
        , ( "red", renderColor "red" )
        , ( "blue", renderColor "blue" )
        , ( "green", renderColor "green" )
        , ( "pink", renderColor "#ff6464" )
        , ( "magenta", renderColor "#ff33c0" )
        , ( "violet", renderColor "#9664ff" )
        , ( "gray", renderColor "#808080" )
        , ( "comment", renderColor "blue" )
        , ( "highlight", renderHighlight )
        , ( "errorHighlight", renderErrorHighlight )
        , ( "link", renderLink )
        , ( "href", renderHref )
        , ( "image", renderImage )
        , ( "ilink", renderIlink )
        , ( "index", renderIndex )
        , ( "ref", renderRef )
        , ( "eqref", renderEqRef )
        , ( "cite", renderCite )
        , ( "sup", renderSup )
        , ( "sub", renderSub )
        , ( "term", renderTerm )
        , ( "term_", renderTermHidden )
        , ( "vspace", renderVspace )
        , ( "break", renderVspace )
          -- Aliases
        , ( "textbf", renderStrong )
        , ( "textit", renderItalic )
        , ( "u", renderUnderline )
        , ( "underscore", renderUnderline )
          -- Text styling
        , ( "bi", renderBoldItalic )
        , ( "boldItalic", renderBoldItalic )
        , ( "var", renderVar )
        , ( "title", renderTitle )
        , ( "subheading", renderSubheading )
        , ( "sh", renderSubheading )
        , ( "smallsubheading", renderSmallSubheading )
        , ( "ssh", renderSmallSubheading )
        , ( "large", renderLarge )
        , ( "qed", renderQed )
          -- Special characters
        , ( "mdash", renderChar "—" )
        , ( "ndash", renderChar "–" )
        , ( "dollarSign", renderChar "$" )
        , ( "dollar", renderChar "$" )
        , ( "ds", renderChar "$" )
        , ( "backTick", renderChar "`" )
        , ( "bt", renderChar "`" )
        , ( "rb", renderChar "]" )
        , ( "lb", renderChar "[" )
        , ( "brackets", renderBrackets )
          -- Checkbox symbols
        , ( "box", renderBox )
        , ( "cbox", renderCbox )
        , ( "rbox", renderRbox )
        , ( "crbox", renderCrbox )
        , ( "fbox", renderFbox )
        , ( "frbox", renderFrbox )
          -- Hidden/no-op
        , ( "hide", renderHidden )
        , ( "author", renderHidden )
        , ( "date", renderHidden )
        , ( "today", renderHidden )
        , ( "lambda", renderHidden )
        , ( "setcounter", renderHidden )
        , ( "label", renderHidden )
        , ( "tags", renderHidden )
          -- Structure
        , ( "//", renderPar )
        , ( "par", renderPar )
        , ( "indent", renderIndent )
        , ( "quote", renderQuote )
        , ( "abstract", renderAbstract )
        , ( "anchor", renderAnchor )
        , ( "footnote", renderFootnote )
        , ( "marked", renderMarked )
          -- Tables
        , ( "table", renderTable )
        , ( "tableRow", renderTableRow )
        , ( "tableItem", renderTableItem )
          -- Images
        , ( "inlineimage", renderInlineImage )
          -- Bibliography
        , ( "bibitem", renderBibitem )
          -- Links (specialized)
        , ( "ulink", renderUlink )
        , ( "reflink", renderReflink )
        , ( "cslink", renderCslink )
        , ( "newPost", renderHidden )
          -- Special/Interactive (simplified)
        , ( "scheme", renderScheme )
        , ( "compute", renderCompute )
        , ( "data", renderData )
        , ( "button", renderButton )
          -- Misc
        , ( "hrule", renderHrule )
        , ( "mark", renderMark )
        ]



-- MARKUP RENDERERS


renderStrong : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderStrong params acc args meta =
    Html.strong [ HA.id meta.id ] (renderList params acc args)


renderItalic : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderItalic params acc args meta =
    Html.em [ HA.id meta.id ] (renderList params acc args)


renderStrike : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderStrike params acc args meta =
    Html.span [ HA.id meta.id, HA.style "text-decoration" "line-through" ] (renderList params acc args)


renderUnderline : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderUnderline params acc args meta =
    Html.span [ HA.id meta.id, HA.style "text-decoration" "underline" ] (renderList params acc args)


renderColor : String -> CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderColor color params acc args meta =
    Html.span [ HA.id meta.id, HA.style "color" color ] (renderList params acc args)


renderHighlight : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderHighlight params acc args meta =
    let
        -- Extract color name from [color colorname] if present
        colorName =
            args
                |> filterExpressionsOnName "color"
                |> List.head
                |> Maybe.andThen getTextFromExpr
                |> Maybe.withDefault "yellow"
                |> String.trim

        -- Filter out the color expression from display
        displayArgs =
            filterOutExpressionsOnName "color" args

        -- Map color name to CSS color value
        cssColor =
            Dict.get colorName highlightColorDict |> Maybe.withDefault "#ffff00"
    in
    Html.span
        [ HA.id meta.id
        , HA.style "background-color" cssColor
        ]
        (renderList params acc displayArgs)


highlightColorDict : Dict String String
highlightColorDict =
    Dict.fromList
        [ ( "yellow", "#ffff00" )
        , ( "blue", "#b4b4ff" )
        , ( "green", "#b4ffb4" )
        , ( "pink", "#ffb4b4" )
        , ( "orange", "#ffd494" )
        , ( "purple", "#d4b4ff" )
        , ( "cyan", "#b4ffff" )
        , ( "gray", "#d4d4d4" )
        ]


filterExpressionsOnName : String -> List Expression -> List Expression
filterExpressionsOnName name exprs =
    List.filter (hasName name) exprs


filterOutExpressionsOnName : String -> List Expression -> List Expression
filterOutExpressionsOnName name exprs =
    List.filter (hasName name >> not) exprs


hasName : String -> Expression -> Bool
hasName name expr =
    case expr of
        Fun n _ _ ->
            n == name

        _ ->
            False


getTextFromExpr : Expression -> Maybe String
getTextFromExpr expr =
    case expr of
        Fun _ args _ ->
            args |> List.filterMap getTextContent |> List.head

        _ ->
            Nothing


renderLink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderLink params acc args meta =
    case args of
        [ Text label _, Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text label ]

        [ Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text url ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params acc args)


renderHref : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderHref params acc args meta =
    case args of
        [ Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text url ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params acc args)


renderImage : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderImage params _ args meta =
    case args of
        [ Text src _ ] ->
            Html.img
                [ HA.id meta.id
                , HA.src src
                , HA.style "max-width" (String.fromInt params.width ++ "px")
                ]
                []

        _ ->
            Html.text "[image: invalid args]"


renderIlink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderIlink params acc args meta =
    -- Internal link - render as link with SelectId message
    case args of
        [ Text label _, Text targetId _ ] ->
            Html.a
                [ HA.id meta.id
                , HA.href ("#" ++ targetId)
                , HE.onClick (SelectId targetId)
                ]
                [ Html.text label ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params acc args)


renderIndex : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderIndex _ _ _ meta =
    -- Index entries are invisible in the output
    Html.span [ HA.id meta.id, HA.style "display" "none" ] []


renderRef : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderRef _ acc args meta =
    case args of
        [ Text refId _ ] ->
            case Dict.get refId acc.reference of
                Just { numRef } ->
                    Html.a
                        [ HA.id meta.id
                        , HA.href ("#" ++ refId)
                        , HE.onClick (SelectId refId)
                        ]
                        [ Html.text numRef ]

                Nothing ->
                    Html.span [ HA.id meta.id, HA.style "color" "red" ] [ Html.text ("??" ++ refId) ]

        _ ->
            Html.span [ HA.id meta.id ] [ Html.text "[ref: invalid]" ]


renderEqRef : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderEqRef _ acc args meta =
    case args of
        [ Text refId _ ] ->
            case Dict.get refId acc.reference of
                Just { numRef } ->
                    Html.a
                        [ HA.id meta.id
                        , HA.href ("#" ++ refId)
                        , HE.onClick (SelectId refId)
                        ]
                        [ Html.text ("(" ++ numRef ++ ")") ]

                Nothing ->
                    Html.span [ HA.id meta.id, HA.style "color" "red" ] [ Html.text ("(??" ++ refId ++ ")") ]

        _ ->
            Html.span [ HA.id meta.id ] [ Html.text "[eqref: invalid]" ]


renderCite : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderCite params acc args meta =
    case args of
        [ Text key _ ] ->
            Html.span [ HA.id meta.id ] [ Html.text ("[" ++ key ++ "]") ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params acc args)


renderSup : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderSup params acc args meta =
    Html.sup [ HA.id meta.id ] (renderList params acc args)


renderSub : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderSub params acc args meta =
    Html.sub [ HA.id meta.id ] (renderList params acc args)


renderTerm : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderTerm params acc args meta =
    Html.em
        [ HA.id meta.id
        , HA.style "padding-right" "2px"
        ]
        (renderList params acc args)


renderTermHidden : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderTermHidden _ _ _ meta =
    -- Hidden term for index entries that shouldn't display inline
    Html.span [ HA.id meta.id, HA.style "display" "none" ] []


renderVspace : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderVspace _ _ args meta =
    let
        h =
            args
                |> List.filterMap getTextContent
                |> String.concat
                |> String.toInt
                |> Maybe.withDefault 1
    in
    Html.div
        [ HA.id meta.id
        , HA.style "height" (String.fromInt h ++ "px")
        ]
        []


getTextContent : Expression -> Maybe String
getTextContent expr =
    case expr of
        Text str _ ->
            Just str

        _ ->
            Nothing


renderBoldItalic : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderBoldItalic params acc args meta =
    Html.span
        [ HA.id meta.id
        , HA.style "font-weight" "bold"
        , HA.style "font-style" "italic"
        ]
        (renderList params acc args)


renderVar : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderVar params acc args meta =
    -- Variable styling (no special formatting in V2, just renders content)
    Html.span [ HA.id meta.id ] (renderList params acc args)


renderTitle : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderTitle params acc args meta =
    Html.span
        [ HA.id meta.id
        , HA.style "font-size" "32px"
        ]
        (renderList params acc args)


renderSubheading : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderSubheading params acc args meta =
    Html.div [ HA.id meta.id ]
        [ Html.p
            [ HA.style "font-size" "18px"
            , HA.style "margin-top" "8px"
            , HA.style "margin-bottom" "0"
            ]
            (renderList params acc args)
        ]


renderSmallSubheading : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderSmallSubheading params acc args meta =
    Html.div [ HA.id meta.id ]
        [ Html.p
            [ HA.style "font-size" "16px"
            , HA.style "font-style" "italic"
            , HA.style "margin-top" "8px"
            , HA.style "margin-bottom" "0"
            ]
            (renderList params acc args)
        ]


renderLarge : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderLarge params acc args meta =
    Html.span
        [ HA.id meta.id
        , HA.style "font-size" "18px"
        ]
        (renderList params acc args)


renderQed : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderQed _ _ _ meta =
    Html.span
        [ HA.id meta.id
        , HA.style "font-weight" "bold"
        ]
        [ Html.text "Q.E.D." ]


renderErrorHighlight : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderErrorHighlight params acc args meta =
    Html.span
        [ HA.id meta.id
        , HA.style "background-color" "#ffc8c8"
        , HA.style "padding" "2px 4px"
        ]
        (renderList params acc args)


renderChar : String -> CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderChar char _ _ _ meta =
    Html.span [ HA.id meta.id ] [ Html.text char ]


renderBrackets : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderBrackets params acc args meta =
    Html.span [ HA.id meta.id ]
        (Html.text "[" :: renderList params acc args ++ [ Html.text "]" ])


renderBox : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderBox _ _ _ meta =
    Html.span [ HA.id meta.id, HA.style "font-size" "20px" ] [ Html.text "☐" ]


renderCbox : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderCbox _ _ _ meta =
    Html.span [ HA.id meta.id, HA.style "font-size" "20px" ] [ Html.text "☑" ]


renderRbox : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderRbox _ _ _ meta =
    Html.span [ HA.id meta.id, HA.style "font-size" "20px", HA.style "color" "#b30000" ] [ Html.text "☐" ]


renderCrbox : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderCrbox _ _ _ meta =
    Html.span [ HA.id meta.id, HA.style "font-size" "20px", HA.style "color" "#b30000" ] [ Html.text "☑" ]


renderFbox : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderFbox _ _ _ meta =
    Html.span [ HA.id meta.id, HA.style "font-size" "24px" ] [ Html.text "■" ]


renderFrbox : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderFrbox _ _ _ meta =
    Html.span [ HA.id meta.id, HA.style "font-size" "24px", HA.style "color" "#b30000" ] [ Html.text "■" ]


renderHidden : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderHidden _ _ _ meta =
    Html.span [ HA.id meta.id, HA.style "display" "none" ] []


renderPar : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderPar _ _ _ meta =
    Html.div [ HA.id meta.id, HA.style "height" "5px" ] []


renderIndent : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderIndent _ _ _ meta =
    Html.span [ HA.id meta.id, HA.style "margin-left" "2em" ] []


renderQuote : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderQuote params acc args meta =
    Html.span [ HA.id meta.id ]
        (Html.text "\u{201C}" :: renderList params acc args ++ [ Html.text "\u{201D}" ])


renderAbstract : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderAbstract params acc args meta =
    Html.span [ HA.id meta.id ]
        (Html.span [ HA.style "font-size" "18px" ] [ Html.text "Abstract. " ]
            :: renderList params acc args
        )


renderAnchor : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderAnchor params acc args meta =
    Html.span
        [ HA.id meta.id
        , HA.style "text-decoration" "underline"
        ]
        (renderList params acc args)


renderFootnote : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderFootnote _ acc args meta =
    case args of
        [ Text _ textMeta ] ->
            case Dict.get textMeta.id acc.footnoteNumbers of
                Just k ->
                    Html.a
                        [ HA.id meta.id
                        , HA.href ("#" ++ textMeta.id ++ "_")
                        , HE.onClick (SelectId (textMeta.id ++ "_"))
                        , HA.style "font-weight" "bold"
                        , HA.style "color" "#0000b3"
                        ]
                        [ Html.sup [] [ Html.text (String.fromInt k) ] ]

                Nothing ->
                    Html.span [ HA.id meta.id ] []

        _ ->
            Html.span [ HA.id meta.id ] []


renderMarked : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderMarked params acc args meta =
    case args of
        [ first ] ->
            Html.span [ HA.id meta.id ] (renderList params acc [ first ])

        (Text str _) :: rest ->
            Html.span [ HA.id str ] (renderList params acc rest)

        _ ->
            Html.span [ HA.id meta.id ] []



-- TABLE RENDERING


renderTable : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderTable params acc rows meta =
    Html.table
        [ HA.id meta.id
        , HA.style "border-collapse" "collapse"
        , HA.style "margin" "8px 0"
        ]
        [ Html.tbody [] (List.map (renderTableRowExpr params acc) rows) ]


renderTableRowExpr : CompilerParameters -> Accumulator -> Expression -> Html Msg
renderTableRowExpr params acc expr =
    case expr of
        Fun "tableRow" items rowMeta ->
            Html.tr [ HA.id rowMeta.id ]
                (List.map (renderTableItemExpr params acc) items)

        _ ->
            Html.tr [] []


renderTableItemExpr : CompilerParameters -> Accumulator -> Expression -> Html Msg
renderTableItemExpr params acc expr =
    case expr of
        Fun "tableItem" exprList itemMeta ->
            Html.td
                [ HA.id itemMeta.id
                , HA.style "padding" "4px 8px"
                , HA.style "border" "1px solid #ddd"
                ]
                (renderList params acc exprList)

        _ ->
            Html.td [] []


renderTableRow : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderTableRow params acc items meta =
    Html.tr [ HA.id meta.id ]
        (List.map (renderTableItemExpr params acc) items)


renderTableItem : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderTableItem params acc exprList meta =
    Html.td
        [ HA.id meta.id
        , HA.style "padding" "4px 8px"
        , HA.style "border" "1px solid #ddd"
        ]
        (renderList params acc exprList)



-- IMAGES


renderInlineImage : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderInlineImage params _ args meta =
    case args of
        [ Text src _ ] ->
            Html.img
                [ HA.id meta.id
                , HA.src src
                , HA.style "display" "inline"
                , HA.style "vertical-align" "middle"
                , HA.style "max-height" "1.5em"
                ]
                []

        _ ->
            Html.span [ HA.id meta.id ] [ Html.text "[inlineimage: invalid args]" ]



-- BIBLIOGRAPHY


renderBibitem : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderBibitem _ _ args meta =
    let
        content =
            args
                |> List.filterMap getTextContent
                |> String.join " "
    in
    Html.span [ HA.id meta.id ] [ Html.text ("[" ++ content ++ "]") ]



-- SPECIALIZED LINKS


renderUlink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderUlink _ _ args meta =
    let
        argString =
            args |> List.filterMap getTextContent |> String.join " "

        words =
            String.words argString

        n =
            List.length words

        label =
            List.take (n - 1) words |> String.join " "

        target =
            List.drop (n - 1) words |> String.join ""
    in
    Html.a
        [ HA.id meta.id
        , HA.href ("#" ++ target)
        , HA.style "color" "#0066cc"
        , HA.style "cursor" "pointer"
        ]
        [ Html.text label ]


renderReflink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderReflink _ acc args meta =
    let
        argString =
            args |> List.filterMap getTextContent |> String.join " "

        words =
            String.words argString

        n =
            List.length words

        key =
            List.drop (n - 1) words |> String.join ""

        label =
            List.take (n - 1) words |> String.join " "

        targetId =
            Dict.get key acc.reference
                |> Maybe.map .id
                |> Maybe.withDefault ""
    in
    Html.a
        [ HA.id meta.id
        , HA.href ("#" ++ targetId)
        , HE.onClick (SelectId targetId)
        , HA.style "color" "#0066cc"
        , HA.style "font-weight" "600"
        ]
        [ Html.text label ]


renderCslink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderCslink _ _ args meta =
    let
        argString =
            args |> List.filterMap getTextContent |> String.join " "

        words =
            String.words argString

        n =
            List.length words

        label =
            List.take (n - 1) words |> String.join " "
    in
    Html.a
        [ HA.id meta.id
        , HA.style "color" "#0066cc"
        , HA.style "cursor" "pointer"
        ]
        [ Html.text label ]



-- SPECIAL/INTERACTIVE (simplified versions)


renderScheme : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderScheme _ _ args meta =
    let
        content =
            args |> List.filterMap getTextContent |> String.join " "
    in
    Html.code
        [ HA.id meta.id
        , HA.style "background-color" "#f5f5f5"
        , HA.style "padding" "2px 4px"
        , HA.style "font-family" "monospace"
        ]
        [ Html.text content ]


renderCompute : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderCompute _ _ args meta =
    let
        content =
            args |> List.filterMap getTextContent |> String.join " "
    in
    Html.span
        [ HA.id meta.id
        , HA.style "font-family" "monospace"
        , HA.style "color" "#666"
        ]
        [ Html.text ("[compute: " ++ content ++ "]") ]


renderData : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderData _ _ args meta =
    let
        content =
            args |> List.filterMap getTextContent |> String.join " "
    in
    Html.span
        [ HA.id meta.id
        , HA.style "font-family" "monospace"
        , HA.style "color" "#666"
        ]
        [ Html.text ("[data: " ++ content ++ "]") ]


renderButton : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderButton _ _ args meta =
    let
        content =
            args |> List.filterMap getTextContent |> String.join " "

        labelText =
            content
                |> String.split ","
                |> List.head
                |> Maybe.withDefault "Button"
                |> String.trim
    in
    Html.button
        [ HA.id meta.id
        , HA.style "padding" "4px 8px"
        , HA.style "font-size" "14px"
        , HA.style "cursor" "pointer"
        ]
        [ Html.text labelText ]


renderHrule : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderHrule params _ _ meta =
    Html.hr
        [ HA.id meta.id
        , HA.style "width" (String.fromInt params.width ++ "px")
        , HA.style "border" "none"
        , HA.style "border-top" "1px solid #bfbfbf"
        , HA.style "margin" "8px 0"
        ]
        []


renderMark : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderMark params acc args meta =
    case args of
        [ Text str _, Fun "anchor" list _ ] ->
            Html.span
                [ HA.id (String.trim str)
                , HA.style "text-decoration" "underline"
                ]
                (renderList params acc list)

        _ ->
            Html.span [ HA.id meta.id ] [ Html.text "Parse error in element mark?" ]
