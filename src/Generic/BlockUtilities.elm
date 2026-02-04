module Generic.BlockUtilities exposing (getExpressionBlockName)

{-| Block utilities for working with expression blocks.
-}

import V3.Types exposing (ExpressionBlock, Heading(..))


{-| Get the name of an expression block from its heading.
-}
getExpressionBlockName : ExpressionBlock -> Maybe String
getExpressionBlockName block =
    case block.heading of
        Paragraph ->
            Nothing

        Ordinary name ->
            Just name

        Verbatim name ->
            Just name
