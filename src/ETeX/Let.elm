module ETeX.Let exposing (needsParens, reduce, substituteVariable)


type alias Definition =
    { variable : Char
    , expr : String
    }


type alias LetBlock =
    { definitions : List Definition
    , body : String
    }


reduce : String -> String
reduce input =
    input


needsParens : String -> Bool
needsParens expr =
    let
        trimmed =
            String.trim expr
    in
    if isFullyWrapped trimmed then
        False

    else
        hasTopLevelPlusOrMinus trimmed


{-| Check if the expression is fully wrapped in parens: "(...)".
-}
isFullyWrapped : String -> Bool
isFullyWrapped str =
    if String.startsWith "(" str && String.endsWith ")" str then
        let
            inner =
                str |> String.dropLeft 1 |> String.dropRight 1
        in
        not (hasUnmatchedParens inner)

    else
        False


{-| Check if a string has unmatched close-parens (meaning the outer parens don't match each other).
-}
hasUnmatchedParens : String -> Bool
hasUnmatchedParens str =
    let
        folder c depth =
            if depth < 0 then
                depth

            else if c == '(' then
                depth + 1

            else if c == ')' then
                depth - 1

            else
                depth
    in
    String.foldl folder 0 str < 0


{-| Check if + or - appears at brace/paren depth 0.
-}
hasTopLevelPlusOrMinus : String -> Bool
hasTopLevelPlusOrMinus str =
    let
        folder c ( depth, found ) =
            if found then
                ( depth, True )

            else if c == '{' || c == '(' then
                ( depth + 1, False )

            else if c == '}' || c == ')' then
                ( depth - 1, False )

            else if depth == 0 && (c == '+' || c == '-') then
                ( depth, True )

            else
                ( depth, False )
    in
    String.foldl folder ( 0, False ) str |> Tuple.second


substituteVariable : Char -> String -> String -> String
substituteVariable var expr target =
    let
        replacement =
            if needsParens expr then
                "(" ++ expr ++ ")"

            else
                expr
    in
    substituteHelper var replacement (String.toList target) []
        |> List.reverse
        |> String.concat


substituteHelper : Char -> String -> List Char -> List String -> List String
substituteHelper var replacement remaining acc =
    case remaining of
        [] ->
            acc

        c :: rest ->
            if c == var && not (isAlphaNum (lastCharOfAcc acc)) && not (isAlphaNum (List.head rest)) then
                substituteHelper var replacement rest (replacement :: acc)

            else
                substituteHelper var replacement rest (String.fromChar c :: acc)


lastCharOfAcc : List String -> Maybe Char
lastCharOfAcc acc =
    case acc of
        [] ->
            Nothing

        s :: _ ->
            s |> String.right 1 |> String.toList |> List.head


isAlphaNum : Maybe Char -> Bool
isAlphaNum mc =
    case mc of
        Nothing ->
            False

        Just c ->
            Char.isAlphaNum c
