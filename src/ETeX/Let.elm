module ETeX.Let exposing (reduce)

import Parser.Advanced as PA
    exposing
        ( (|.)
        , (|=)
        , Step(..)
        , chompIf
        , chompUntilEndOr
        , chompWhile
        , getChompedString
        , succeed
        )


type alias Definition =
    { variable : Char
    , expr : String
    }


type alias LetBlock =
    { definitions : List Definition
    , body : String
    }


type alias Parser a =
    PA.Parser () String a



-- REDUCE --


reduce : String -> String
reduce input =
    case parseLetBlock input of
        Nothing ->
            input

        Just ( preamble, letBlock ) ->
            let
                resolvedDefs =
                    resolveDefinitions letBlock.definitions

                result =
                    applyDefinitions resolvedDefs letBlock.body
            in
            if String.isEmpty preamble then
                result

            else
                preamble ++ "\n" ++ result


{-| Process definitions sequentially: substitute earlier variables into later definitions.
-}
resolveDefinitions : List Definition -> List Definition
resolveDefinitions defs =
    let
        folder def resolved =
            let
                newExpr =
                    List.foldl
                        (\prev expr -> substituteVariable prev.variable prev.expr expr)
                        def.expr
                        resolved
            in
            resolved ++ [ { def | expr = newExpr } ]
    in
    List.foldl folder [] defs


{-| Substitute all definitions into the body.
-}
applyDefinitions : List Definition -> String -> String
applyDefinitions defs body =
    List.foldl
        (\def text -> substituteVariable def.variable def.expr text)
        body
        defs



-- PARSER --


{-| Parse a LET/IN block. Returns ( preamble, LetBlock ) on success.
-}
parseLetBlock : String -> Maybe ( String, LetBlock )
parseLetBlock input =
    case splitOnLET input of
        Nothing ->
            Nothing

        Just ( preamble, letPart ) ->
            case PA.run letBlockParser letPart of
                Ok block ->
                    Just ( preamble, block )

                Err _ ->
                    Nothing


{-| Split input on the first line that is exactly "LET".
Returns ( before, fromLETonward ).
-}
splitOnLET : String -> Maybe ( String, String )
splitOnLET input =
    let
        lines =
            String.lines input

        findLET idx remaining =
            case remaining of
                [] ->
                    Nothing

                line :: rest ->
                    if String.trim line == "LET" then
                        let
                            before =
                                List.take idx lines |> String.join "\n"

                            after =
                                remaining |> String.join "\n"
                        in
                        Just ( before, after )

                    else
                        findLET (idx + 1) rest
    in
    findLET 0 lines


letBlockParser : Parser LetBlock
letBlockParser =
    succeed LetBlock
        |. PA.keyword (PA.Token "LET" "expected LET")
        |. PA.spaces
        |= definitionsParser
        |. PA.keyword (PA.Token "IN" "expected IN")
        |. optionalNewline
        |= bodyParser


definitionsParser : Parser (List Definition)
definitionsParser =
    PA.loop [] definitionsHelper


definitionsHelper : List Definition -> Parser (Step (List Definition) (List Definition))
definitionsHelper revDefs =
    PA.oneOf
        [ PA.backtrackable definitionParser
            |> PA.map (\d -> Loop (d :: revDefs))
        , succeed ()
            |> PA.map (\_ -> Done (List.reverse revDefs))
        ]


definitionParser : Parser Definition
definitionParser =
    succeed Definition
        |. chompWhile (\c -> c == ' ')
        |= (chompIf Char.isUpper "expected uppercase letter"
                |> getChompedString
                |> PA.map (\s -> s |> String.toList |> List.head |> Maybe.withDefault 'X')
           )
        |. chompWhile (\c -> c == ' ')
        |. PA.symbol (PA.Token "=" "expected =")
        |. chompWhile (\c -> c == ' ')
        |= (chompUntilEndOr "\n" |> getChompedString |> PA.map String.trim)
        |. optionalNewline


bodyParser : Parser String
bodyParser =
    getChompedString (chompWhile (\_ -> True))
        |> PA.map String.trim


optionalNewline : Parser ()
optionalNewline =
    PA.oneOf
        [ PA.symbol (PA.Token "\n" "expected newline")
        , succeed ()
        ]



-- NEEDS PARENS --


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



-- SUBSTITUTE --


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
            if c == var && not (isLowerAlpha (lastCharOfAcc acc)) && not (isLowerAlpha (List.head rest)) then
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


isLowerAlpha : Maybe Char -> Bool
isLowerAlpha mc =
    case mc of
        Nothing ->
            False

        Just c ->
            Char.isAlpha c && Char.isLower c
