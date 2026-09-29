module Parser.Match exposing (getSegment, isReducible, match, splitAt, splitMatched)

import List.Extra
import Parser.Symbol exposing (Symbol(..), value)
import Tools.Loop exposing (Step(..), loop)


isReducible : List Symbol -> Bool
isReducible symbols_ =
    let
        symbols =
            List.filter (\sym -> sym /= WS) symbols_
    in
    case symbols of
        M :: rest ->
            List.head (List.reverse rest) == Just M

        C :: rest ->
            List.head (List.reverse rest) == Just C

        L :: ST :: rest ->
            case List.head (List.reverse rest) of
                Just R ->
                    hasReducibleArgs (dropLast rest)

                _ ->
                    False

        DL :: rest ->
            case lastTwo rest of
                Just ( R, R ) ->
                    isFlatBody (dropLast2 rest)

                _ ->
                    False

        _ ->
            False


hasReducibleArgs : List Symbol -> Bool
hasReducibleArgs symbols =
    case symbols of
        [] ->
            True

        L :: _ ->
            reducibleAux symbols

        DL :: _ ->
            reducibleAux symbols

        C :: _ ->
            reducibleAux symbols

        M :: _ ->
            let
                seg =
                    getSegment M symbols
            in
            if isReducible seg then
                hasReducibleArgs (List.drop (List.length seg) symbols)

            else
                False

        ST :: rest ->
            hasReducibleArgs rest

        _ ->
            False


{-| Split `items` just after the segment that `match` finds at the head of `symbols`.
`symbols` is the symbol view of `items`, so the two lists have the same length.
-}
splitMatched : List Symbol -> List a -> Maybe ( List a, List a )
splitMatched symbols items =
    match symbols |> Maybe.map (\k -> splitAt (k + 1) items)


reducibleAux : List Symbol -> Bool
reducibleAux symbols =
    case splitMatched symbols symbols of
        Nothing ->
            False

        Just ( a, b ) ->
            isReducible a && hasReducibleArgs b


dropLast : List a -> List a
dropLast list =
    let
        n =
            List.length list
    in
    List.take (n - 1) list


splitAt : Int -> List a -> ( List a, List a )
splitAt k list =
    ( List.take k list, List.drop k list )


type alias State =
    { symbols : List Symbol, index : Int, brackets : Int }


getSegment : Symbol -> List Symbol -> List Symbol
getSegment sym symbols =
    let
        seg_ =
            List.Extra.takeWhile (\sym_ -> sym_ /= sym) (List.drop 1 symbols)

        n =
            List.length seg_
    in
    case List.Extra.getAt (n + 1) symbols of
        Nothing ->
            sym :: seg_

        Just last ->
            sym :: seg_ ++ [ last ]


match : List Symbol -> Maybe Int
match symbols =
    case List.head symbols of
        Nothing ->
            Nothing

        Just symbol ->
            if List.member symbol [ C, M ] then
                Just (List.length (getSegment symbol symbols) - 1)

            else if value symbol < 0 then
                Nothing

            else
                loop { symbols = List.drop 1 symbols, index = 1, brackets = value symbol } nextStep


nextStep : State -> Step State (Maybe Int)
nextStep state =
    case List.head state.symbols of
        Nothing ->
            Done Nothing

        Just sym ->
            let
                brackets =
                    state.brackets + value sym
            in
            if brackets < 0 then
                Done Nothing

            else if brackets == 0 then
                Done (Just state.index)

            else
                Loop { symbols = List.drop 1 state.symbols, index = state.index + 1, brackets = brackets }



-- LIST HELPERS

lastTwo : List a -> Maybe ( a, a )
lastTwo list =
    case List.reverse list of
        b :: a :: _ ->
            Just ( a, b )

        _ ->
            Nothing


dropLast2 : List a -> List a
dropLast2 list =
    let
        n =
            List.length list
    in
    List.take (n - 2) list


isFlatBody : List Symbol -> Bool
isFlatBody symbols =
    List.all (\s -> s == ST) symbols

