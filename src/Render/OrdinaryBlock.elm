module Render.OrdinaryBlock exposing (render)

{-| Render ordinary (named) blocks to HTML.
-}

import Dict exposing (Dict)
import Either exposing (Either(..))
import Html exposing (Html)
import Html.Attributes as HA
import Render.Expression
import Render.Utility exposing (idAttr, selectedStyle)
import Types exposing (Accumulator, CompilerParameters, Expr(..), Expression, ExpressionBlock, Msg(..), Theme(..))


{-| Render an ordinary block by name.
-}
render : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
render params acc name block children =
    case Dict.get name blockDict of
        Just renderer ->
            renderer params acc name block children

        Nothing ->
            renderDefault params acc name block children


{-| Dictionary of block renderers.
-}
blockDict : Dict String (CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg))
blockDict =
    Dict.fromList
        [ ( "section", renderSection )
        , ( "subsection", renderSubsection )
        , ( "subsubsection", renderSubsubsection )
        , ( "item", renderItem )
        , ( "numbered", renderNumbered )
        , ( "theorem", renderTheorem )
        , ( "lemma", renderTheorem )
        , ( "proposition", renderTheorem )
        , ( "corollary", renderTheorem )
        , ( "definition", renderTheorem )
        , ( "example", renderTheorem )
        , ( "remark", renderTheorem )
        , ( "note", renderTheorem )
        , ( "exercise", renderTheorem )
        , ( "problem", renderTheorem )
        , ( "question", renderTheorem )
        , ( "axiom", renderTheorem )
        , ( "proof", renderProof )
        , ( "indent", renderIndent )
        , ( "quotation", renderQuotation )
        , ( "quote", renderQuotation )
        , ( "center", renderCenter )
        , ( "abstract", renderAbstract )
        , ( "title", renderTitle )
        , ( "subtitle", renderSubtitle )
        , ( "author", renderAuthor )
        , ( "date", renderDate )
        , ( "contents", renderContents )
        , ( "index", renderIndexBlock )
        , ( "box", renderBox )
        , ( "comment", renderComment )
        , ( "hide", renderComment )
        , ( "document", renderDocument )
        , ( "collection", renderCollection )
          -- Tables and lists
        , ( "table", renderTable )
        , ( "desc", renderDesc )
          -- Footnotes
        , ( "endnotes", renderEndnotes )
        ]


{-| Default rendering for unknown block names.
-}
renderDefault : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDefault params acc name block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (String.fromInt params.paragraphSpacing ++ "px")
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.span [ HA.style "font-weight" "bold", HA.style "color" "blue" ]
            [ Html.text ("[" ++ name ++ "]") ]
            :: renderBody params acc block
            ++ children
        )
    ]


{-| Render block body content.
-}
renderBody : CompilerParameters -> Accumulator -> ExpressionBlock -> List (Html Msg)
renderBody params acc block =
    case block.body of
        Left _ ->
            []

        Right expressions ->
            Render.Expression.renderList params acc expressions



-- SECTION HEADINGS


renderSection : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSection params acc _ block children =
    let
        level =
            Dict.get "level" block.properties |> Maybe.andThen String.toInt |> Maybe.withDefault 1

        tag =
            case level of
                1 ->
                    Html.h2

                2 ->
                    Html.h3

                3 ->
                    Html.h4

                _ ->
                    Html.h5

        sectionNumber =
            Dict.get "section-number" block.properties |> Maybe.withDefault ""

        prefix =
            if sectionNumber /= "" then
                sectionNumber ++ " "

            else
                ""
    in
    tag
        ([ idAttr block.meta.id
         , HA.style "margin-top" "1.5em"
         , HA.style "margin-bottom" "0.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.text prefix :: renderBody params acc block)
        :: children


renderSubsection : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubsection params acc _ block children =
    Html.h3
        (idAttr block.meta.id :: selectedStyle params.selectedId block.meta.id params.theme)
        (renderBody params acc block)
        :: children


renderSubsubsection : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubsubsection params acc _ block children =
    Html.h4
        (idAttr block.meta.id :: selectedStyle params.selectedId block.meta.id params.theme)
        (renderBody params acc block)
        :: children



-- LIST ITEMS


renderItem : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderItem params acc _ block children =
    [ Html.li
        ([ idAttr block.meta.id
         , HA.style "margin-left" (String.fromInt (block.indent * 20) ++ "px")
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


renderNumbered : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderNumbered params acc _ block children =
    let
        index =
            case Dict.get block.meta.id acc.numberedItemDict of
                Just info ->
                    String.fromInt info.index ++ ". "

                Nothing ->
                    ""
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-left" (String.fromInt (block.indent * 20) ++ "px")
         , HA.style "margin-bottom" "0.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.span [ HA.style "margin-right" "0.5em" ] [ Html.text index ]
            :: renderBody params acc block
            ++ children
        )
    ]



-- THEOREM-LIKE ENVIRONMENTS


renderTheorem : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTheorem params acc name block children =
    let
        theoremTitle =
            String.toUpper (String.left 1 name) ++ String.dropLeft 1 name

        counter =
            Dict.get name acc.counter |> Maybe.withDefault 0

        numberString =
            if counter > 0 then
                " " ++ String.fromInt counter

            else
                ""

        label =
            List.head block.args |> Maybe.withDefault ""

        labelDisplay =
            if label /= "" then
                " (" ++ label ++ ")"

            else
                ""
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-top" "1em"
         , HA.style "margin-bottom" "1em"
         , HA.style "padding" "12px"
         , HA.style "border-left" "3px solid #ccc"
         , HA.style "background-color"
            (case params.theme of
                Light ->
                    "#f9f9f9"

                Dark ->
                    "#2a2a2a"
            )
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.span
            [ HA.style "font-weight" "bold"
            , HA.style "margin-right" "0.5em"
            ]
            [ Html.text (theoremTitle ++ numberString ++ labelDisplay ++ ".") ]
            :: renderBody params acc block
            ++ children
        )
    ]


renderProof : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderProof params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-top" "0.5em"
         , HA.style "margin-bottom" "1em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.span [ HA.style "font-style" "italic", HA.style "margin-right" "0.5em" ]
            [ Html.text "Proof." ]
            :: renderBody params acc block
            ++ children
            ++ [ Html.span [ HA.style "float" "right" ] [ Html.text "∎" ] ]
        )
    ]



-- FORMATTING BLOCKS


renderIndent : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIndent params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-left" "2em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


renderQuotation : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderQuotation params acc _ block children =
    [ Html.blockquote
        ([ idAttr block.meta.id
         , HA.style "border-left" "3px solid #ccc"
         , HA.style "padding-left" "1em"
         , HA.style "margin-left" "1em"
         , HA.style "font-style" "italic"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


renderCenter : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCenter params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


renderAbstract : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderAbstract params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 2em"
         , HA.style "font-size" "0.9em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.div [ HA.style "font-weight" "bold", HA.style "margin-bottom" "0.5em" ]
            [ Html.text "Abstract" ]
            :: renderBody params acc block
            ++ children
        )
    ]



-- DOCUMENT METADATA


renderTitle : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTitle params acc _ block _ =
    [ Html.h1
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin-bottom" "0.25em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block)
    ]


renderSubtitle : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubtitle params acc _ block _ =
    [ Html.h2
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "font-weight" "normal"
         , HA.style "margin-top" "0"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block)
    ]


renderAuthor : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderAuthor params acc _ block _ =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin-top" "0.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block)
    ]


renderDate : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDate params acc _ block _ =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin-top" "0.25em"
         , HA.style "font-size" "0.9em"
         , HA.style "color" "#666"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block)
    ]



-- SPECIAL BLOCKS


renderContents : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderContents _ _ _ block _ =
    -- Table of contents placeholder - actual TOC is built by Render.TOC
    [ Html.div
        [ idAttr block.meta.id
        , HA.id "toc-placeholder"
        ]
        []
    ]


renderIndexBlock : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIndexBlock _ _ _ block _ =
    -- Index block - invisible in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


renderBox : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderBox params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "border" "1px solid #ccc"
         , HA.style "padding" "1em"
         , HA.style "margin" "1em 0"
         , HA.style "border-radius" "4px"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


renderComment : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderComment _ _ _ block _ =
    -- Comments are hidden
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


renderDocument : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDocument _ _ _ block _ =
    -- Document blocks are metadata, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


renderCollection : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCollection _ _ _ block _ =
    -- Collection blocks are metadata, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]



-- TABLES


renderTable : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTable params acc _ block _ =
    case block.body of
        Right [ Fun "table" rows _ ] ->
            let
                formatList =
                    Dict.get "format" block.properties
                        |> Maybe.withDefault ""
                        |> String.trim
                        |> String.split " "
                        |> List.map String.trim

                columnWidths =
                    Dict.get "columnWidths" block.properties
                        |> Maybe.withDefault ""
                        |> String.replace "[" ""
                        |> String.replace "]" ""
                        |> String.split ","
                        |> List.map String.trim
                        |> List.filterMap String.toInt
            in
            [ Html.div
                ([ idAttr block.meta.id
                 , HA.style "margin" "1em 0"
                 , HA.style "padding-left" "24px"
                 ]
                    ++ selectedStyle params.selectedId block.meta.id params.theme
                )
                [ Html.table [ HA.style "border-collapse" "collapse" ]
                    [ Html.tbody [] (List.map (renderTableRow params acc formatList columnWidths) rows) ]
                ]
            ]

        Right _ ->
            [ Html.div [ idAttr block.meta.id ] [] ]

        Left data ->
            [ Html.div [ idAttr block.meta.id ] [ Html.text data ] ]


renderTableRow : CompilerParameters -> Accumulator -> List String -> List Int -> Expression -> Html Msg
renderTableRow params acc formats widths row =
    case row of
        Fun "row" cells _ ->
            Html.tr [ HA.style "height" "20px" ]
                (List.indexedMap (renderTableCell params acc formats widths) cells)

        _ ->
            Html.tr [] []


renderTableCell : CompilerParameters -> Accumulator -> List String -> List Int -> Int -> Expression -> Html Msg
renderTableCell params acc formats widths index cell =
    case cell of
        Fun "cell" exprs _ ->
            let
                width =
                    List.drop index widths
                        |> List.head
                        |> Maybe.withDefault 100

                alignment =
                    List.drop index formats
                        |> List.head
                        |> Maybe.withDefault "l"
                        |> formatToTextAlign
            in
            Html.td
                [ HA.style "width" (String.fromInt (width + 10) ++ "px")
                , HA.style "text-align" alignment
                , HA.style "padding" "4px 8px"
                ]
                (Render.Expression.renderList params acc exprs)

        _ ->
            Html.td [] []


formatToTextAlign : String -> String
formatToTextAlign fmt =
    case fmt of
        "l" ->
            "left"

        "r" ->
            "right"

        "c" ->
            "center"

        _ ->
            "left"



-- DESCRIPTION LISTS


renderDesc : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDesc params acc _ block children =
    let
        label =
            String.join " " block.args
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "display" "flex"
         , HA.style "margin-bottom" "0.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.dt
            [ HA.style "font-weight" "bold"
            , HA.style "width" "100px"
            , HA.style "flex-shrink" "0"
            ]
            [ Html.text label ]
        , Html.dd
            [ HA.style "margin-left" "1em"
            , HA.style "flex" "1"
            ]
            (renderBody params acc block ++ children)
        ]
    ]



-- FOOTNOTES/ENDNOTES


renderEndnotes : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderEndnotes params acc _ block _ =
    let
        endnoteList =
            acc.footnotes
                |> Dict.toList
                |> List.map
                    (\( content, meta ) ->
                        { label = Dict.get meta.id acc.footnoteNumbers |> Maybe.withDefault 0
                        , content = content
                        , id = meta.id ++ "_"
                        }
                    )
                |> List.sortBy .label
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-top" "2em"
         , HA.style "padding-top" "1em"
         , HA.style "border-top" "1px solid #ccc"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.div
            [ HA.style "font-weight" "bold"
            , HA.style "font-size" "18px"
            , HA.style "margin-bottom" "0.5em"
            ]
            [ Html.text "Endnotes" ]
            :: List.map renderFootnoteItem endnoteList
        )
    ]


renderFootnoteItem : { label : Int, content : String, id : String } -> Html Msg
renderFootnoteItem { label, content, id } =
    Html.div
        [ HA.id id
        , HA.style "margin-bottom" "0.5em"
        ]
        [ Html.span
            [ HA.style "width" "24px"
            , HA.style "display" "inline-block"
            ]
            [ Html.text (String.fromInt label ++ ".") ]
        , Html.text content
        ]
