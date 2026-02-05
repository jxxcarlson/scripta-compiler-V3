module Render.OrdinaryBlock exposing (render)

{-| Render ordinary (named) blocks to HTML.
-}

import Char
import Dict exposing (Dict)
import Either exposing (Either(..))
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as Decode
import Render.Expression
import Render.Sizing
import Render.Utility exposing (idAttr, selectedStyle)
import V3.Types exposing (Accumulator, CompilerParameters, Expr(..), Expression, ExpressionBlock, Msg(..), TermLoc, Theme(..))


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
        , ( "itemList", renderItemList )
        , ( "numbered", renderNumbered )
        , ( "numberedList", renderNumberedList )
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

        -- Additional blocks from V2
        , ( "subheading", renderSubheading )
        , ( "sh", renderSubheading )
        , ( "compact", renderCompact )
        , ( "identity", renderIdentity )
        , ( "red", renderColorBlock "red" )
        , ( "red2", renderColorBlock "#c00" )
        , ( "blue", renderColorBlock "blue" )
        , ( "q", renderQuestion )
        , ( "a", renderAnswer )
        , ( "reveal", renderReveal )
        , ( "book", renderNothing )
        , ( "chapter", renderChapter )
        , ( "section*", renderUnnumberedSection )
        , ( "visibleBanner", renderVisibleBanner )
        , ( "banner", renderNothing )
        , ( "runninghead_", renderNothing )
        , ( "tags", renderNothing )
        , ( "type", renderNothing )
        , ( "setcounter", renderNothing )
        , ( "shiftandsetcounter", renderNothing )
        , ( "bibitem", renderBibitem )
        , ( "env", renderEnv )
        ]


{-| Default rendering for unknown block names.
-}
renderDefault : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDefault params acc name block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (Render.Sizing.paragraphSpacingPx params.sizing)
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


{-| Render a numbered section heading.

    | section
    Introduction

    | section 2
    Background

The argument specifies heading level (1-3, default 1).

-}
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

        -- Get number-to-level from accumulator's keyValueDict (set by title block)
        numberToLevel =
            Dict.get "number-to-level" acc.keyValueDict
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 0

        -- Get the section label (set by transformBlock in Acc.elm)
        sectionLabel =
            Dict.get "label" block.properties |> Maybe.withDefault ""

        -- Only show section number if level <= numberToLevel
        prefix =
            if level <= numberToLevel && sectionLabel /= "" then
                sectionLabel ++ ". "

            else
                ""

        -- Generate slug from heading text
        slug =
            getBlockText block |> toSlug
    in
    [ Html.div
        [ HA.id slug ]
        (tag
            ([ idAttr block.meta.id
             , HA.style "font-weight" "normal"
             , HA.style "margin-top" "1.5em"
             , HA.style "margin-bottom" "0.5em"
             ]
                ++ selectedStyle params.selectedId block.meta.id params.theme
            )
            (Html.text prefix :: renderBody params acc block)
            :: children
        )
    ]


{-| Render a subsection heading (level 2).

    | subsection
    Methods

-}
renderSubsection : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubsection params acc _ block children =
    let
        slug =
            getBlockText block |> toSlug
    in
    [ Html.div
        [ HA.id slug ]
        (Html.h3
            (idAttr block.meta.id :: selectedStyle params.selectedId block.meta.id params.theme)
            (renderBody params acc block)
            :: children
        )
    ]


{-| Render a subsubsection heading (level 3).

    | subsubsection
    Details

-}
renderSubsubsection : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubsubsection params acc _ block children =
    let
        slug =
            getBlockText block |> toSlug
    in
    [ Html.div
        [ HA.id slug ]
        (Html.h4
            (idAttr block.meta.id :: selectedStyle params.selectedId block.meta.id params.theme)
            (renderBody params acc block)
            :: children
        )
    ]



-- LIST ITEMS


{-| Render a single bullet list item.

    - First item
    - Second item

-}
renderItem : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderItem params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-left" (String.fromInt (block.indent * 20) ++ "px")
         , HA.style "margin-bottom" (Render.Sizing.itemSpacingPx params.sizing)
         , HA.style "padding-left" "1.5em"
         , HA.style "text-indent" "-1.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.span [ HA.style "margin-right" "0.5em" ] [ Html.text "•" ]
            :: renderBody params acc block
            ++ children
        )
    ]


{-| Render a single numbered list item.

    . First item
    . Second item

-}
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
         , HA.style "margin-bottom" (Render.Sizing.itemSpacingPx params.sizing)
         , HA.style "padding-left" "1.5em"
         , HA.style "text-indent" "-1.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.span [ HA.style "margin-right" "0.5em" ] [ Html.text index ]
            :: renderBody params acc block
            ++ children
        )
    ]


{-| Render a bullet list (coalesced from consecutive "- " items).

    - First item
    - Second item
    - Third item

-}
renderItemList : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderItemList params acc _ block children =
    [ Html.ul
        ([ idAttr block.meta.id
         , HA.style "margin-left" (String.fromInt (18 + block.indent * 20) ++ "px")
         , HA.style "margin-bottom" (Render.Sizing.paragraphSpacingPx params.sizing)
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderListItems params acc block ++ children)
    ]


{-| Render a numbered list (coalesced from consecutive ". " items).

    . First item
    . Second item
    . Third item

-}
renderNumberedList : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderNumberedList params acc _ block children =
    [ Html.ol
        ([ idAttr block.meta.id
         , HA.style "margin-left" (String.fromInt (18 + block.indent * 20) ++ "px")
         , HA.style "margin-bottom" (Render.Sizing.paragraphSpacingPx params.sizing)
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderListItems params acc block ++ children)
    ]


{-| Render each ExprList in the body as a list item.
-}
renderListItems : CompilerParameters -> Accumulator -> ExpressionBlock -> List (Html Msg)
renderListItems params acc block =
    case block.body of
        Right expressions ->
            List.map (renderListItemExpr params acc) expressions

        Left _ ->
            []


{-| Render a single ExprList as a <li> element.
-}
renderListItemExpr : CompilerParameters -> Accumulator -> Expression -> Html Msg
renderListItemExpr params acc expr =
    case expr of
        ExprList _ innerExprs meta ->
            Html.li [ HA.id meta.id ]
                (Render.Expression.renderList params acc innerExprs)

        _ ->
            Html.li [] (Render.Expression.renderList params acc [ expr ])



-- THEOREM-LIKE ENVIRONMENTS


{-| Render theorem-like environments with automatic numbering.

    | theorem
    Every even number greater than 2 is the sum of two primes.

    | theorem Goldbach's Conjecture
    Every even number greater than 2 is the sum of two primes.

Supported environments: theorem, lemma, proposition, corollary, definition,
example, remark, note, exercise, problem, question, axiom.

Arguments:

  - Optional label (e.g., "Goldbach's Conjecture")

-}
renderTheorem : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTheorem params acc name block children =
    let
        theoremTitle =
            String.toUpper (String.left 1 name) ++ String.dropLeft 1 name

        -- Get the number from block.properties["label"] (set by Acc.transformBlock)
        numberString =
            case Dict.get "label" block.properties of
                Just label_ ->
                    if label_ /= "" then
                        " " ++ label_

                    else
                        ""

                Nothing ->
                    ""

        -- User-provided label (e.g., "Goldbach's Conjecture")
        userLabel =
            List.head block.args |> Maybe.withDefault ""

        labelDisplay =
            if userLabel /= "" then
                " (" ++ userLabel ++ ")"

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
        [ Html.span
            [ HA.style "font-weight" "bold"
            , HA.style "margin-right" "0.5em"
            ]
            [ Html.text (theoremTitle ++ numberString ++ labelDisplay ++ ".") ]
        , Html.span
            [ HA.style "font-style" "italic" ]
            (renderBody params acc block ++ children)
        ]
    ]


{-| Render a proof block with "Proof." prefix and QED marker.

    | proof
    By contradiction, assume...

-}
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


{-| Render indented content.

    | indent
    This paragraph is indented.

-}
renderIndent : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIndent params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-left" "2em"
         , HA.style "margin-bottom" "1em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


{-| Render a block quotation with left border.

    | quotation
    To be or not to be, that is the question.

Also available as `| quote`.

-}
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


{-| Render centered content.

    | center
    Centered text here.

-}
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


{-| Render an abstract with "Abstract" heading.

    | abstract
    This paper presents a new method for...

-}
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


{-| Render the document title (centered h1).

    | title
    My Document Title

-}
renderTitle : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderTitle _ _ _ _ _ =
    []


{-| Render the document subtitle (centered, lighter h2).

    | subtitle
    A Comprehensive Guide

-}
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


{-| Render the document author (centered).

    | author
    John Doe

-}
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


{-| Render the document date (centered, smaller).

    | date
    January 2024

-}
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


{-| Render a table of contents placeholder.

    | contents

The actual TOC is built by Render.TOC.

-}
renderContents : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderContents _ _ _ block _ =
    [ Html.div
        [ idAttr block.meta.id
        , HA.id "toc-placeholder"
        ]
        []
    ]


{-| Render an index of all terms collected from [term ...] elements.

    | index

Displays an alphabetically sorted list of terms with links to their locations.

-}
renderIndexBlock : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIndexBlock _ acc _ block _ =
    let
        -- Helper to get display text for sorting/grouping
        getDisplayText ( term, loc ) =
            loc.displayAs |> Maybe.withDefault term

        -- Get all terms sorted alphabetically by display text (case-insensitive)
        sortedTerms =
            acc.terms
                |> Dict.toList
                |> List.sortBy (\entry -> String.toLower (getDisplayText entry))

        -- Group terms by first letter of display text
        groupedTerms =
            groupByFirstLetterWithDisplay sortedTerms

        -- Render each group
        renderGroup ( letter, terms ) =
            Html.div
                [ HA.style "margin-bottom" "1em" ]
                [ Html.div
                    [ HA.style "font-weight" "bold"
                    , HA.style "font-size" "1.2em"
                    , HA.style "border-bottom" "1px solid #ccc"
                    , HA.style "margin-bottom" "0.5em"
                    ]
                    [ Html.text (String.toUpper letter) ]
                , Html.div [] (List.map renderIndexEntry terms)
                ]

        -- Render a single index entry as a clickable link
        -- Uses displayAs if present, otherwise uses the term itself
        renderIndexEntry ( term, loc ) =
            let
                displayText =
                    loc.displayAs |> Maybe.withDefault term
            in
            Html.div
                [ HA.style "margin-left" "1em"
                , HA.style "margin-bottom" "0.25em"
                ]
                [ Html.a
                    [ HA.href ("#" ++ loc.id)
                    , HE.preventDefaultOn "click" (Decode.succeed ( SelectId loc.id, True ))
                    , HA.style "color" "#0066cc"
                    , HA.style "text-decoration" "none"
                    , HA.style "cursor" "pointer"
                    ]
                    [ Html.text displayText ]
                ]
    in
    [ Html.div
        [ idAttr block.meta.id ]
        [ Html.h2
            [ HA.style "font-weight" "normal"
            , HA.style "margin-bottom" "1em"
            ]
            [ Html.text "Index" ]
        , Html.div
            [ HA.style "column-count" "2"
            , HA.style "column-gap" "2em"
            ]
            (if List.isEmpty sortedTerms then
                [ Html.text "(No index entries)" ]

             else
                List.map renderGroup groupedTerms
            )
        ]
    ]


{-| Group terms by their first letter, using displayAs when present.
-}
groupByFirstLetterWithDisplay : List ( String, TermLoc ) -> List ( String, List ( String, TermLoc ) )
groupByFirstLetterWithDisplay terms =
    let
        getDisplayText ( term, loc ) =
            loc.displayAs |> Maybe.withDefault term

        getFirstLetter entry =
            String.left 1 (getDisplayText entry) |> String.toLower

        addToGroup entry groups =
            let
                letter =
                    getFirstLetter entry
            in
            case groups of
                [] ->
                    [ ( letter, [ entry ] ) ]

                ( currentLetter, currentTerms ) :: rest ->
                    if currentLetter == letter then
                        ( currentLetter, entry :: currentTerms ) :: rest

                    else
                        ( letter, [ entry ] ) :: groups
    in
    terms
        |> List.foldl addToGroup []
        |> List.map (\( letter, ts ) -> ( letter, List.reverse ts ))
        |> List.reverse


{-| Render content in a bordered box.

    | box
    Important notice here.

-}
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


{-| Render nothing (comments are hidden).

    | comment
    This won't appear in output.

Also available as `| hide`.

-}
renderComment : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderComment _ _ _ block _ =
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


{-| Render document metadata block (hidden).

    | document
    type:article

-}
renderDocument : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderDocument _ _ _ block _ =
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]


{-| Render collection metadata block (hidden).

    | collection
    docs/chapter1.md
    docs/chapter2.md

-}
renderCollection : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCollection _ _ _ block _ =
    [ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]



-- TABLES


{-| Render a table with rows and cells.

    | table format:l c r columnWidths:[100,80,80]
    [table [row [cell A][cell B][cell C]] [row [cell 1][cell 2][cell 3]]]

Properties:

  - format: Column alignment (l=left, c=center, r=right)
  - columnWidths: Pixel widths for each column

-}
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


{-| Render a description list item.

    | desc Term
    Definition of the term.

Arguments:

  - Term label

-}
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


{-| Render collected endnotes at the end of a document.

    | endnotes

Displays all footnotes collected from [footnote ...] expressions.

-}
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
            , HA.style "font-size" (Render.Sizing.toPx params.sizing 18.0)
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



-- ADDITIONAL BLOCKS FROM V2


{-| Render nothing (for configuration/metadata blocks).

Used for: book, banner, runninghead\_, tags, type, setcounter, shiftandsetcounter.

-}
renderNothing : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderNothing _ _ _ block _ =
    [ Html.span [ HA.id block.meta.id, HA.style "display" "none" ] [] ]


{-| Render a subheading (smaller than section).

    | subheading
    Minor Heading

Also available as `| sh`.

-}
renderSubheading : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderSubheading params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "font-size" "1.1em"
         , HA.style "font-weight" "normal"
         , HA.style "margin-top" "1em"
         , HA.style "margin-bottom" "0.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


{-| Render content with reduced line spacing.

    | compact
    Dense content with tighter line spacing.

-}
renderCompact : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderCompact params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "line-height" "1.2"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


{-| Render content with no special styling (identity transform).

    | identity
    This content is rendered as-is.

-}
renderIdentity : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderIdentity params acc _ block children =
    [ Html.div
        (idAttr block.meta.id
            :: selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


{-| Render content in a specified color.

    | red
    This text is red.

    | blue
    This text is blue.

Available colors: red, red2, blue.

-}
renderColorBlock : String -> CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderColorBlock color params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "color" color
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


{-| Render a question block with "Q:" prefix.

    | q
    What is the meaning of life?

-}
renderQuestion : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderQuestion params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (Render.Sizing.paragraphSpacingPx params.sizing)
         , HA.style "padding" "0.5em"
         , HA.style "background-color" "#f0f8ff"
         , HA.style "border-left" "3px solid #4a90d9"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.span [ HA.style "font-weight" "bold", HA.style "color" "#4a90d9" ] [ Html.text "Q: " ]
            :: renderBody params acc block
            ++ children
        )
    ]


{-| Render an answer block with "A:" prefix.

    | a
    42.

-}
renderAnswer : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderAnswer params acc _ block children =
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (Render.Sizing.paragraphSpacingPx params.sizing)
         , HA.style "padding" "0.5em"
         , HA.style "background-color" "#f0fff0"
         , HA.style "border-left" "3px solid #4a9"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.span [ HA.style "font-weight" "bold", HA.style "color" "#4a9" ] [ Html.text "A: " ]
            :: renderBody params acc block
            ++ children
        )
    ]


{-| Render collapsible/expandable content.

    | reveal Click to see answer
    The hidden answer is here.

Arguments:

  - Summary text (default: "Click to reveal")

-}
renderReveal : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderReveal params acc _ block children =
    [ Html.details
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (Render.Sizing.paragraphSpacingPx params.sizing)
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        [ Html.summary [ HA.style "cursor" "pointer", HA.style "font-weight" "bold" ]
            [ Html.text
                (String.join " " block.args
                    |> (\s ->
                            if String.isEmpty s then
                                "Click to reveal"

                            else
                                s
                       )
                )
            ]
        , Html.div [ HA.style "padding" "0.5em" ]
            (renderBody params acc block ++ children)
        ]
    ]


{-| Render a chapter heading (large h1).

    | chapter
    Introduction to Mathematics

-}
renderChapter : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderChapter params acc _ block children =
    let
        chapterNumber =
            Dict.get "chapter-number" block.properties
                |> Maybe.withDefault ""

        chapterLabel =
            if chapterNumber /= "" then
                "Chapter " ++ chapterNumber ++ ". "

            else
                ""
    in
    [ Html.h1
        ([ idAttr block.meta.id
         , HA.style "font-size" "2em"
         , HA.style "font-weight" "normal"
         , HA.style "margin-top" "1.5em"
         , HA.style "margin-bottom" "0.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.text chapterLabel :: renderBody params acc block ++ children)
    ]


{-| Render an unnumbered section heading.

    | section*
    Appendix

    | section* 2
    Sub-appendix

Arguments:

  - Level (1-3, default 1)

-}
renderUnnumberedSection : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderUnnumberedSection params acc _ block children =
    let
        level =
            block.args
                |> List.head
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 1

        fontSize =
            case level of
                1 ->
                    "1.5em"

                2 ->
                    "1.3em"

                _ ->
                    "1.1em"
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "font-size" fontSize
         , HA.style "font-weight" "bold"
         , HA.style "margin-top" "1em"
         , HA.style "margin-bottom" "0.5em"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (renderBody params acc block ++ children)
    ]


{-| Render a visible banner image.

    | visibleBanner
    /images/banner.jpg

-}
renderVisibleBanner : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderVisibleBanner _ _ _ block _ =
    let
        src =
            block.firstLine
    in
    [ Html.img
        [ HA.id block.meta.id
        , HA.src src
        , HA.style "max-width" "100%"
        , HA.style "margin-bottom" "1em"
        ]
        []
    ]


{-| Render a bibliography item.

    | bibitem einstein1905
    Einstein, A. (1905). On the Electrodynamics of Moving Bodies.

Arguments:

  - Citation key (e.g., "einstein1905")

Renders as: [N] <body content>
Wrapped in div with id "key:N" for citation linking.

-}
renderBibitem : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderBibitem params acc _ block children =
    let
        key =
            block.args
                |> List.head
                |> Maybe.withDefault ""

        -- Get the bibitem number from the bibliography dictionary
        number =
            Dict.get key acc.bibliography
                |> Maybe.andThen identity
                |> Maybe.withDefault 0

        -- Create id as "key:number" for citation linking
        bibitemId =
            key ++ ":" ++ String.fromInt number
    in
    [ Html.div
        [ HA.id bibitemId
        , HA.style "display" "flex"
        , HA.style "margin-bottom" "0.5em"
        ]
        [ Html.span
            [ HA.style "font-weight" "bold"
            , HA.style "min-width" "40px"
            ]
            [ Html.text ("[" ++ String.fromInt number ++ "]") ]
        , Html.div [ HA.style "flex" "1" ]
            (renderBody params acc block ++ children)
        ]
    ]


{-| Render a generic named environment.

    | env Algorithm
    Step 1: Initialize
    Step 2: Process
    Step 3: Output

Arguments:

  - Environment name (displayed as title)

-}
renderEnv : CompilerParameters -> Accumulator -> String -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderEnv params acc _ block children =
    let
        envName =
            block.args
                |> List.head
                |> Maybe.withDefault "environment"
    in
    [ Html.div
        ([ idAttr block.meta.id
         , HA.style "margin-bottom" (Render.Sizing.paragraphSpacingPx params.sizing)
         , HA.style "padding" "0.5em"
         , HA.style "border" "1px solid #ddd"
         ]
            ++ selectedStyle params.selectedId block.meta.id params.theme
        )
        (Html.div [ HA.style "font-weight" "bold", HA.style "margin-bottom" "0.5em" ]
            [ Html.text (capitalize envName) ]
            :: renderBody params acc block
            ++ children
        )
    ]


capitalize : String -> String
capitalize str =
    case String.uncons str of
        Just ( first, rest ) ->
            String.cons (Char.toUpper first) rest

        Nothing ->
            str


{-| Convert text to a URL-friendly slug.
Removes non-alphanumeric characters, compresses spaces, converts to lowercase, and replaces spaces with dashes.

    toSlug "Jon's Stuff!" == "jons-stuff"
    toSlug "Hello   World" == "hello-world"

-}
toSlug : String -> String
toSlug text =
    text
        |> String.toLower
        |> String.toList
        |> List.map
            (\c ->
                if Char.isAlphaNum c then
                    c

                else
                    ' '
            )
        |> String.fromList
        |> String.words
        |> String.join "-"


{-| Extract plain text from a block's body for use in slug generation.
Falls back to firstLine if body is empty.
-}
getBlockText : ExpressionBlock -> String
getBlockText block =
    case block.body of
        Left str ->
            if String.isEmpty str then
                block.firstLine

            else
                str

        Right expressions ->
            let
                bodyText =
                    expressions
                        |> List.map extractTextFromExpr
                        |> String.concat
            in
            if String.isEmpty bodyText then
                block.firstLine

            else
                bodyText


{-| Recursively extract text from an expression.
-}
extractTextFromExpr : Expression -> String
extractTextFromExpr expr =
    case expr of
        Text str _ ->
            str

        Fun _ args _ ->
            List.map extractTextFromExpr args |> String.concat

        VFun _ content _ ->
            content

        ExprList _ exprs _ ->
            List.map extractTextFromExpr exprs |> String.concat
