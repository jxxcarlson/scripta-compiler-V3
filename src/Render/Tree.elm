module Render.Tree exposing (renderForest)

{-| Render a forest of ExpressionBlocks to HTML.
-}

import Html exposing (Html)
import Html.Attributes as HA
import Render.Block
import RoseTree.Tree as Tree exposing (Tree)
import Types exposing (Accumulator, CompilerParameters, ExpressionBlock, Msg(..), RenderSettings)


{-| Render a forest (list of trees) to HTML.
-}
renderForest : CompilerParameters -> RenderSettings -> Accumulator -> List (Tree ExpressionBlock) -> List (Html Msg)
renderForest params settings acc forest =
    List.concatMap (renderTree params settings acc) forest


{-| Render a single tree to HTML.

Recursively renders children first, then passes them to the block renderer.
This allows block renderers to wrap or incorporate child content as needed.

-}
renderTree : CompilerParameters -> RenderSettings -> Accumulator -> Tree ExpressionBlock -> List (Html Msg)
renderTree params settings acc tree =
    let
        block =
            Tree.value tree

        children =
            Tree.children tree

        renderedChildren =
            if List.isEmpty children then
                []

            else
                [ Html.div
                    [ HA.style "margin-left" "0px" ]
                    (List.concatMap (renderTree params settings acc) children)
                ]
    in
    Render.Block.renderBody params settings acc block renderedChildren
