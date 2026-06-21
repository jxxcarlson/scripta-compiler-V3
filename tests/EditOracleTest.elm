module EditOracleTest exposing (suite)

import Edit.Map exposing (Edit)
import Expect
import RoseTree.Tree as Tree exposing (Tree)
import Scripta
import Scripta.Internal as Internal
import Test exposing (Test, describe, test)
import V3.Types exposing (ExpressionBlock)


forestOf : Internal.Document -> List (Tree ExpressionBlock)
forestOf doc =
    case doc of
        Internal.Document data ->
            data.forest


flattenTree : Tree ExpressionBlock -> List ExpressionBlock
flattenTree tree =
    Tree.value tree :: List.concatMap flattenTree (Tree.children tree)


{-| The block-level metadata that a pure shift must keep identical to reparse.
Fields: position, begin, end, contentBegin, contentEnd, lineNumber,
bodyLineNumber, numberOfLines, id.
-}
type alias BlockMetaSnapshot =
    { position : Int
    , begin : Int
    , end : Int
    , contentBegin : Int
    , contentEnd : Int
    , lineNumber : Int
    , bodyLineNumber : Int
    , numberOfLines : Int
    , id : String
    }


metaTuples : Internal.Document -> List BlockMetaSnapshot
metaTuples doc =
    forestOf doc
        |> List.concatMap flattenTree
        |> List.map
            (\b ->
                { position = b.meta.position
                , begin = b.meta.begin
                , end = b.meta.end
                , contentBegin = b.meta.contentBegin
                , contentEnd = b.meta.contentEnd
                , lineNumber = b.meta.lineNumber
                , bodyLineNumber = b.meta.bodyLineNumber
                , numberOfLines = b.meta.numberOfLines
                , id = b.meta.id
                }
            )


{-| Assert: applying `edit` to parse(base) gives the same block metadata as
parse(edited).
-}
expectShiftEqualsReparse : String -> Edit -> String -> Expect.Expectation
expectShiftEqualsReparse base edit edited =
    let
        shifted =
            Scripta.applyEdit edit (Scripta.parse Scripta.defaultOptions base)

        reparsed =
            Scripta.parse Scripta.defaultOptions edited
    in
    Expect.equal (metaTuples shifted) (metaTuples reparsed)


threePara : String
threePara =
    "abc\n\ndef\n\nghi"


suite : Test
suite =
    describe "Edit oracle: shift == reparse (structure-preserving)"
        [ test "intra-line insert in the middle block (dL = 0)" <|
            \_ ->
                -- insert "X" at offset 6 -> "abc\n\ndXef\n\nghi"
                expectShiftEqualsReparse threePara
                    { offset = 6, removed = "", inserted = "X" }
                    "abc\n\ndXef\n\nghi"
        , test "intra-line delete in the middle block (dL = 0)" <|
            \_ ->
                -- delete "e" at offset 6 -> "abc\n\ndf\n\nghi"
                expectShiftEqualsReparse threePara
                    { offset = 6, removed = "e", inserted = "" }
                    "abc\n\ndf\n\nghi"
        , test "line added inside the middle block (dL = 1)" <|
            \_ ->
                -- insert "\nX" at offset 8 -> "abc\n\ndef\nX\n\nghi"
                expectShiftEqualsReparse threePara
                    { offset = 8, removed = "", inserted = "\nX" }
                    "abc\n\ndef\nX\n\nghi"
        , test "edit in the last block shifts nothing below (dL = 0)" <|
            \_ ->
                -- insert "Z" at offset 12 -> "abc\n\ndef\n\ngZhi"
                expectShiftEqualsReparse threePara
                    { offset = 12, removed = "", inserted = "Z" }
                    "abc\n\ndef\n\ngZhi"
        , test "insert at block.begin joins the front of the block (Containing, not Below)" <|
            \_ ->
                expectShiftEqualsReparse threePara
                    { offset = 10, removed = "", inserted = "X" }
                    "abc\n\ndef\n\nXghi"
        , test "two sequential edits fold to the same metadata as reparse" <|
            \_ ->
                -- e1: insert "X" at 6 -> "abc\n\ndXef\n\nghi"
                -- e2: insert "Y" at 7 (after the X) -> "abc\n\ndXYef\n\nghi"
                let
                    shifted =
                        Scripta.applyEdits
                            [ { offset = 6, removed = "", inserted = "X" }
                            , { offset = 7, removed = "", inserted = "Y" }
                            ]
                            (Scripta.parse Scripta.defaultOptions threePara)

                    reparsed =
                        Scripta.parse Scripta.defaultOptions "abc\n\ndXYef\n\nghi"
                in
                Expect.equal (metaTuples shifted) (metaTuples reparsed)
        ]
