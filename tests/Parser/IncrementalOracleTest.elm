module Parser.IncrementalOracleTest exposing (suite)

{-| Oracle: an incremental reparse must give the same forest and accumulator as
a fresh parse of the edited text. Covers both the skip path (accumulator
reused) and the full path (expression cache reused).
-}

import Dict
import Expect
import Parser.Forest as PF
import Test exposing (..)
import TestData


doc : String
doc =
    String.join "\n"
        [ "Opening paragraph with the [b bold] word."
        , ""
        , "| section 1 label:intro"
        , "Introduction"
        , ""
        , "See [ref intro] and a footnote[footnote Note text]."
        , ""
        , "Plain paragraph with a footnote[footnote Only note]."
        , ""
        , "- one [i x]"
        , "- two"
        , ""
        , "| code"
        , "x = 1"
        , ""
        , "| table"
        , "a & [b b]"
        , "c & d"
        , ""
        , "| section 2"
        , "Second"
        , ""
        , "Closing paragraph."
        , ""
        ]


docWithContinuation : String
docWithContinuation =
    String.join "\n"
        [ "See [ref thm]."
        , ""
        , "| theorem"
        , "| label:thm"
        , "Body."
        , ""
        , "| image"
        , "| width:300"
        , "https://example.com/a.png"
        , ""
        , "End."
        , ""
        ]


{-| Replace the first occurrence of `target` with `replacement`.
-}
replaceFirst : String -> String -> String -> String
replaceFirst target replacement str =
    case String.indexes target str of
        i :: _ ->
            String.left i str ++ replacement ++ String.dropLeft (i + String.length target) str

        [] ->
            str


{-| Reparse `after` incrementally (as Scripta.reparse does) and compare with a fresh parse.
-}
expectSameAsFresh : Bool -> String -> String -> Expect.Expectation
expectSameAsFresh expectSkip before after =
    let
        params =
            TestData.defaultCompilerParameters

        ( cache, acc, forest ) =
            PF.parseIncrementally params Dict.empty (String.lines before)

        result =
            PF.parseIncrementallySkipAcc params cache ( acc, forest ) (String.lines after)

        ( _, freshAcc, freshForest ) =
            PF.parseIncrementally params Dict.empty (String.lines after)
    in
    Expect.all
        [ \_ -> Expect.equal expectSkip result.accWasSkipped
        , \_ -> Expect.equal freshForest result.forest
        , \_ -> Expect.equal freshAcc result.acc
        ]
        ()


suite : Test
suite =
    describe "incremental reparse equals fresh parse"
        [ test "no-op edit" <|
            \_ -> expectSameAsFresh True doc doc
        , test "character typed in the first paragraph (skip path, offsets shift)" <|
            \_ -> expectSameAsFresh True doc (replaceFirst "Opening" "Openingg" doc)
        , test "line added to the first paragraph (full path: ids below shift, so the old accumulator is stale)" <|
            \_ -> expectSameAsFresh False doc (replaceFirst "word." "word.\nAnother line." doc)
        , test "character typed in the last paragraph (skip path, nothing below)" <|
            \_ -> expectSameAsFresh True doc (replaceFirst "Closing" "Closingg" doc)
        , test "line added to the code block (full path: ids below shift)" <|
            \_ -> expectSameAsFresh False doc (replaceFirst "x = 1" "x = 1\ny = 2" doc)
        , test "paragraph inserted at the top (full path, cached blocks move)" <|
            \_ -> expectSameAsFresh False doc ("New first paragraph.\n\n" ++ doc)
        , test "section title changed (full path)" <|
            \_ -> expectSameAsFresh False doc (replaceFirst "Introduction" "Intro" doc)
        , test "header continuation line edited (label changed)" <|
            \_ -> expectSameAsFresh False docWithContinuation (replaceFirst "label:thm" "label:theo" docWithContinuation)
        , test "header continuation line edited (property value changed)" <|
            \_ -> expectSameAsFresh False docWithContinuation (replaceFirst "width:300" "width:400" docWithContinuation)
        , test "footnote removed from a paragraph (old block used the accumulator)" <|
            \_ -> expectSameAsFresh False doc (replaceFirst "[footnote Only note]" "" doc)
        , test "block deleted (full path, cached blocks move up)" <|
            \_ -> expectSameAsFresh False doc (replaceFirst "Opening paragraph with the [b bold] word.\n\n" "" doc)
        ]
