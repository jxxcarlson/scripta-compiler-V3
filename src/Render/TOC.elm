module Render.TOC exposing (build, buildTocItem, extractSections)

{-| Build table of contents from expression blocks.
-}

import Dict
import Either exposing (Either(..))
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import RoseTree.Tree as Tree exposing (Tree)
import Types exposing (Accumulator, CompilerParameters, Expr(..), ExpressionBlock, Heading(..), Msg(..), RenderSettings, Theme(..))


{-| Section data for TOC entry.
-}
type alias TocEntry =
    { id : String
    , level : Int
    , title : String
    , sectionNumber : String
    }


{-| Build table of contents HTML from a forest.
-}
build : CompilerParameters -> RenderSettings -> Accumulator -> List (Tree ExpressionBlock) -> List (Html Msg)
build _ settings _ forest =
    let
        sections =
            extractSections forest
    in
    if List.isEmpty sections then
        []

    else
        [ Html.div
            [ HA.style "margin-bottom" "2em"
            , HA.style "padding" "1em"
            , HA.style "border" "1px solid #ccc"
            , HA.style "border-radius" "4px"
            , HA.style "background-color"
                (case settings.theme of
                    Light ->
                        "#f9f9f9"

                    Dark ->
                        "#1a1a1a"
                )
            ]
            ([ Html.div
                [ HA.style "font-weight" "bold"
                , HA.style "margin-bottom" "0.5em"
                ]
                [ Html.text "Contents" ]
             ]
                ++ List.map (buildTocItem settings) sections
            )
        ]


{-| Extract section entries from forest.
-}
extractSections : List (Tree ExpressionBlock) -> List TocEntry
extractSections forest =
    List.concatMap extractSectionsFromTree forest


{-| Extract sections from a tree.
-}
extractSectionsFromTree : Tree ExpressionBlock -> List TocEntry
extractSectionsFromTree tree =
    let
        block =
            Tree.value tree

        thisEntry =
            case block.heading of
                Ordinary "section" ->
                    [ blockToTocEntry block ]

                _ ->
                    []

        childEntries =
            List.concatMap extractSectionsFromTree (Tree.children tree)
    in
    thisEntry ++ childEntries


{-| Convert a section block to a TOC entry.
-}
blockToTocEntry : ExpressionBlock -> TocEntry
blockToTocEntry block =
    { id = block.meta.id
    , level = Dict.get "level" block.properties |> Maybe.andThen String.toInt |> Maybe.withDefault 1
    , title = extractTitle block
    , sectionNumber = Dict.get "section-number" block.properties |> Maybe.withDefault ""
    }


{-| Extract title text from block content.
-}
extractTitle : ExpressionBlock -> String
extractTitle block =
    case block.body of
        Left str ->
            str

        Right expressions ->
            expressions
                |> List.map extractTextFromExpr
                |> String.join ""


{-| Extract text from an expression.
-}
extractTextFromExpr : Types.Expression -> String
extractTextFromExpr expr =
    case expr of
        Text str _ ->
            str

        Fun _ args _ ->
            List.map extractTextFromExpr args |> String.join ""

        VFun _ content _ ->
            content

        ExprList _ exprs _ ->
            List.map extractTextFromExpr exprs |> String.join ""


{-| Build a single TOC item HTML.
-}
buildTocItem : RenderSettings -> TocEntry -> Html Msg
buildTocItem settings entry =
    let
        indent =
            (entry.level - 1) * 20

        prefix =
            if entry.sectionNumber /= "" then
                entry.sectionNumber ++ " "

            else
                ""
    in
    Html.div
        [ HA.style "margin-left" (String.fromInt indent ++ "px")
        , HA.style "margin-bottom" "0.25em"
        ]
        [ Html.a
            [ HA.href ("#" ++ entry.id)
            , HE.onClick (SelectId entry.id)
            , HA.style "color"
                (case settings.theme of
                    Light ->
                        "#0066cc"

                    Dark ->
                        "#66b3ff"
                )
            , HA.style "text-decoration" "none"
            ]
            [ Html.text (prefix ++ entry.title) ]
        ]
