module Render.OrdinaryBlock exposing (render)

{-| Render ordinary (named) blocks to HTML.
-}

import Dict exposing (Dict)
import Either exposing (Either(..))
import Html exposing (Html)
import Html.Attributes as HA
import Render.Expression
import Render.Utility exposing (idAttr, selectedStyle)
import Types exposing (Accumulator, CompilerParameters, ExpressionBlock, Msg(..), RenderSettings, Theme(..))


{-| Render an ordinary block by name.
-}
render : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
render params settings acc name block children =
    case Dict.get name blockDict of
        Just renderer ->
            renderer params settings acc name block children

        Nothing ->
            renderDefault params settings acc name block children


{-| Dictionary of block renderers.
-}
blockDict : Dict String (CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg))
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
        ]


{-| Default rendering for unknown block names.
-}
renderDefault : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDefault params settings acc name block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (String.fromInt settings.paragraphSpacing ++ "px")
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (Html.span [ HA.style "font-weight" "bold", HA.style "color" "blue" ]
            [ Html.text ("[" ++ name ++ "]") ]
            :: renderBody params settings acc block
            ++ children
        )
    ]


{-| Render block body content.
-}
renderBody : CompilerParameters -> RenderSettings -> Accumulator -> ExpressionBlock -> List (Html Msg)
renderBody params settings acc block =
    case block.body of
        Left _ ->
            []

        Right expressions ->
            Render.Expression.renderList params settings acc expressions



-- SECTION HEADINGS


renderSection : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSection params settings acc _ block children =
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
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (Html.text prefix :: renderBody params settings acc block)
        :: children


renderSubsection : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubsection params settings acc _ block children =
    Html.h3
        (idAttr block.meta.id :: selectedStyle settings.selectedId block.meta.id settings.theme)
        (renderBody params settings acc block)
        :: children


renderSubsubsection : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubsubsection params settings acc _ block children =
    Html.h4
        (idAttr block.meta.id :: selectedStyle settings.selectedId block.meta.id settings.theme)
        (renderBody params settings acc block)
        :: children



-- LIST ITEMS


renderItem : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderItem params settings acc _ block children =
    [ Html.li
        ([ idAttr block.meta.id
         , HA.style "margin-left" (String.fromInt (block.indent * 20) ++ "px")
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block ++ children)
    ]


renderNumbered : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderNumbered params settings acc _ block children =
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
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (Html.span [ HA.style "margin-right" "0.5em" ] [ Html.text index ]
            :: renderBody params settings acc block
            ++ children
        )
    ]



-- THEOREM-LIKE ENVIRONMENTS


renderTheorem : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTheorem params settings acc name block children =
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
            (case settings.theme of
                Light ->
                    "#f9f9f9"

                Dark ->
                    "#2a2a2a"
            )
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (Html.span
            [ HA.style "font-weight" "bold"
            , HA.style "margin-right" "0.5em"
            ]
            [ Html.text (theoremTitle ++ numberString ++ labelDisplay ++ ".") ]
            :: renderBody params settings acc block
            ++ children
        )
    ]


renderProof : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderProof params settings acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-top" "0.5em"
         , HA.style "margin-bottom" "1em"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (Html.span [ HA.style "font-style" "italic", HA.style "margin-right" "0.5em" ]
            [ Html.text "Proof." ]
            :: renderBody params settings acc block
            ++ children
            ++ [ Html.span [ HA.style "float" "right" ] [ Html.text "∎" ] ]
        )
    ]



-- FORMATTING BLOCKS


renderIndent : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIndent params settings acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-left" "2em"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block ++ children)
    ]


renderQuotation : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderQuotation params settings acc _ block children =
    [ Html.blockquote
        ([ idAttr block.meta.id
         , HA.style "border-left" "3px solid #ccc"
         , HA.style "padding-left" "1em"
         , HA.style "margin-left" "1em"
         , HA.style "font-style" "italic"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block ++ children)
    ]


renderCenter : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCenter params settings acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block ++ children)
    ]


renderAbstract : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderAbstract params settings acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin" "1em 2em"
         , HA.style "font-size" "0.9em"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (Html.div [ HA.style "font-weight" "bold", HA.style "margin-bottom" "0.5em" ]
            [ Html.text "Abstract" ]
            :: renderBody params settings acc block
            ++ children
        )
    ]



-- DOCUMENT METADATA


renderTitle : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTitle params settings acc _ block _ =
    [ Html.h1
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin-bottom" "0.25em"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block)
    ]


renderSubtitle : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubtitle params settings acc _ block _ =
    [ Html.h2
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "font-weight" "normal"
         , HA.style "margin-top" "0"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block)
    ]


renderAuthor : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderAuthor params settings acc _ block _ =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin-top" "0.5em"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block)
    ]


renderDate : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDate params settings acc _ block _ =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "text-align" "center"
         , HA.style "margin-top" "0.25em"
         , HA.style "font-size" "0.9em"
         , HA.style "color" "#666"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block)
    ]



-- SPECIAL BLOCKS


renderContents : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderContents _ settings _ _ block _ =
    -- Table of contents placeholder - actual TOC is built by Render.TOC
    [ Html.div
        [ idAttr block.meta.id
        , HA.id "toc-placeholder"
        ]
        []
    ]


renderIndexBlock : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIndexBlock _ _ _ _ block _ =
    -- Index block - invisible in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


renderBox : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderBox params settings acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "border" "1px solid #ccc"
         , HA.style "padding" "1em"
         , HA.style "margin" "1em 0"
         , HA.style "border-radius" "4px"
         ]
            ++ selectedStyle settings.selectedId block.meta.id settings.theme
        )
        (renderBody params settings acc block ++ children)
    ]


renderComment : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderComment _ _ _ _ block _ =
    -- Comments are hidden
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


renderDocument : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDocument _ _ _ _ block _ =
    -- Document blocks are metadata, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


renderCollection : CompilerParameters -> RenderSettings -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCollection _ _ _ _ block _ =
    -- Collection blocks are metadata, hidden in output
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]
