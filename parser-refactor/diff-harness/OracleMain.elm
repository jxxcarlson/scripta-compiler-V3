port module OracleMain exposing (main)

{-| Oracle check: for each (before, after) pair, an incremental reparse
(Scripta.parse then Scripta.reparse, via Parser.Forest) must equal a fresh parse
of `after`: same forest and same accumulator. Reports one line per mismatch.
-}

import Dict
import Parser.Forest
import TestData


port out : List String -> Cmd msg


main : Program (List ( String, String, String )) () ()
main =
    Platform.worker
        { init = \cases -> ( (), out (List.filterMap check cases) )
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


check : ( String, String, String ) -> Maybe String
check ( label, before, after ) =
    let
        params =
            TestData.defaultCompilerParameters

        ( cache, acc, forest ) =
            Parser.Forest.parseIncrementally params Dict.empty (String.lines before)

        result =
            Parser.Forest.parseIncrementallySkipAcc params cache ( acc, forest ) (String.lines after)

        ( _, freshAcc, freshForest ) =
            Parser.Forest.parseIncrementally params Dict.empty (String.lines after)

        skipped =
            if result.accWasSkipped then
                "skip"

            else
                "full"
    in
    if result.forest /= freshForest then
        Just ("FOREST MISMATCH (" ++ skipped ++ ") " ++ label)

    else if result.acc /= freshAcc then
        Just ("ACC MISMATCH (" ++ skipped ++ ") " ++ label)

    else
        Just ("ok " ++ skipped)
