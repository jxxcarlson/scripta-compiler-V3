module Parser.Pipeline exposing (toExpressionBlock)

{-| Convert PrimitiveBlock to ExpressionBlock by parsing inline expressions.

    import Parser.Pipeline exposing (toExpressionBlock)

    primitiveBlock
        |> toExpressionBlock
        --> ExpressionBlock with parsed expressions in body

-}

import Dict
import Either exposing (Either(..))
import Parser.Expression as Expression
import Types exposing (BlockMeta, ExprMeta, ExpressionBlock, Heading(..), PrimitiveBlock, Expression, Expr(..))


{-| Convert a PrimitiveBlock to an ExpressionBlock.

For Verbatim blocks, the body is preserved as raw text (Left String).
For all other blocks, the body is parsed into expressions (Right (List Expression)).

-}
toExpressionBlock : PrimitiveBlock -> ExpressionBlock
toExpressionBlock block =
    { heading = block.heading
    , indent = block.indent
    , args = block.args
    , properties = block.properties |> Dict.insert "id" block.meta.id
    , firstLine = block.firstLine
    , body = parseBody block
    , meta = block.meta
    , style = block.style
    }


{-| Parse the body based on block heading type.
-}
parseBody : PrimitiveBlock -> Either String (List Expression)
parseBody block =
    case block.heading of
        Paragraph ->
            Right (parseLines block.meta.lineNumber block.body)

        Ordinary "item" ->
            Right [ ExprList block.indent (Expression.parse block.meta.lineNumber block.firstLine) emptyExprMeta ]

        Ordinary "numbered" ->
            Right [ ExprList block.indent (Expression.parse block.meta.lineNumber block.firstLine) emptyExprMeta ]

        Ordinary _ ->
            Right (parseLines block.meta.lineNumber block.body)

        Verbatim _ ->
            Left (String.join "\n" block.body)


{-| Parse multiple lines into a list of expressions.
-}
parseLines : Int -> List String -> List Expression
parseLines lineNumber lines =
    String.join "\n" lines |> Expression.parse lineNumber


{-| Empty expression metadata for synthetic expressions.
-}
emptyExprMeta : ExprMeta
emptyExprMeta =
    { begin = 0, end = 0, index = 0, id = "list" }
