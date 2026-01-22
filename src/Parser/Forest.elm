module Parser.Forest exposing (parse)

{-| Parse source lines into a forest of ExpressionBlocks.

    import Parser.Forest

    lines
        |> Parser.Forest.parse
        --> Forest ExpressionBlock

-}

import Generic.ForestTransform
import Parser.Pipeline
import Parser.PrimitiveBlock
import RoseTree.Tree as Tree exposing (Tree)
import Types exposing (ExpressionBlock, PrimitiveBlock)


{-| Parse source lines into a forest of expression blocks.

Pipeline:
1. Parse lines into PrimitiveBlocks
2. Build forest structure based on indentation
3. Convert each PrimitiveBlock to ExpressionBlock

-}
parse : List String -> List (Tree ExpressionBlock)
parse lines =
    lines
        |> Parser.PrimitiveBlock.parse
        |> Generic.ForestTransform.forestFromBlocks .indent
        |> mapForest Parser.Pipeline.toExpressionBlock


{-| Map a function over all values in a forest.
-}
mapForest : (a -> b) -> List (Tree a) -> List (Tree b)
mapForest f forest =
    List.map (Tree.mapValues f) forest
