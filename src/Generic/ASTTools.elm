module Generic.ASTTools exposing (filterExpressionsOnName_, getText)

{-| AST utilities for working with expressions.
-}

import V3.Types exposing (Expr(..), Expression)


{-| Extract text content from an expression.
-}
getText : Expression -> Maybe String
getText expression =
    case expression of
        Text str _ ->
            Just str

        VFun _ str _ ->
            Just (String.replace "`" "" str)

        Fun _ expressions _ ->
            List.filterMap getText expressions
                |> String.join " "
                |> Just

        ExprList _ _ _ ->
            Nothing


{-| Filter expressions that match a function name.
-}
filterExpressionsOnName_ : String -> List Expression -> List Expression
filterExpressionsOnName_ name exprs =
    List.filter (matchExprOnName_ name) exprs


matchExprOnName_ : String -> Expression -> Bool
matchExprOnName_ name expr =
    getFunctionName expr == Just name


getFunctionName : Expression -> Maybe String
getFunctionName expression =
    case expression of
        Fun name _ _ ->
            Just name

        VFun _ _ _ ->
            Nothing

        Text _ _ ->
            Nothing

        ExprList _ _ _ ->
            Nothing
