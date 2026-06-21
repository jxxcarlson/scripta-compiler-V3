module EditMapTest exposing (suite)

import Edit.Map as EM
import Either
import Expect
import RoseTree.Tree as Tree exposing (Tree)
import Scripta
import Scripta.Internal as Internal
import Test exposing (Test, describe, test)
import V3.Types exposing (Expr(..), ExpressionBlock)


forestOf : Internal.Document -> List (Tree ExpressionBlock)
forestOf doc =
    case doc of
        Internal.Document data ->
            data.forest


blocksOf : List (Tree ExpressionBlock) -> List ExpressionBlock
blocksOf forest =
    List.concatMap flattenTree forest


flattenTree : Tree ExpressionBlock -> List ExpressionBlock
flattenTree tree =
    Tree.value tree :: List.concatMap flattenTree (Tree.children tree)


parseForest : String -> List (Tree ExpressionBlock)
parseForest source =
    forestOf (Scripta.parse Scripta.defaultOptions source)


-- "abc" / "def" / "ghi" as three paragraph blocks
threePara : String
threePara =
    "abc\n\ndef\n\nghi"


suite : Test
suite =
    describe "Edit.Map"
        [ describe "deltas"
            [ test "charDelta = inserted length - removed length" <|
                \_ ->
                    EM.charDelta { offset = 3, removed = "ab", inserted = "xyz" }
                        |> Expect.equal 1
            , test "charDelta is negative for a net deletion" <|
                \_ ->
                    EM.charDelta { offset = 0, removed = "abcd", inserted = "" }
                        |> Expect.equal -4
            , test "lineDelta counts newlines inserted minus removed" <|
                \_ ->
                    EM.lineDelta { offset = 0, removed = "", inserted = "a\nb\n" }
                        |> Expect.equal 2
            , test "lineDelta is negative when newlines are removed" <|
                \_ ->
                    EM.lineDelta { offset = 0, removed = "x\ny", inserted = "z" }
                        |> Expect.equal -1
            , test "lineDelta is 0 for an intra-line edit" <|
                \_ ->
                    EM.lineDelta { offset = 5, removed = "a", inserted = "bc" }
                        |> Expect.equal 0
            ]
        , describe "id surgery"
            [ test "shiftBlockId bumps the line-number component" <|
                \_ ->
                    EM.shiftBlockId 3 "5-2"
                        |> Expect.equal "8-2"
            , test "shiftBlockId handles negative delta" <|
                \_ ->
                    EM.shiftBlockId -2 "5-2"
                        |> Expect.equal "3-2"
            , test "shiftBlockId leaves an empty id unchanged" <|
                \_ ->
                    EM.shiftBlockId 3 ""
                        |> Expect.equal ""
            , test "shiftExprId bumps the line-number component" <|
                \_ ->
                    EM.shiftExprId 4 "e-5.3"
                        |> Expect.equal "e-9.3"
            , test "shiftExprId leaves a non-e- id unchanged" <|
                \_ ->
                    EM.shiftExprId 4 "weird"
                        |> Expect.equal "weird"
            ]
        , describe "mapExprMeta"
            [ test "applies f to a leaf Text meta" <|
                \_ ->
                    EM.mapExprMeta (\m -> { m | id = EM.shiftExprId 2 m.id })
                        (Text "hi" { begin = 0, end = 1, index = 0, id = "e-3.0" })
                        |> Expect.equal
                            (Text "hi" { begin = 0, end = 1, index = 0, id = "e-5.0" })
            , test "recurses into Fun children" <|
                \_ ->
                    let
                        child =
                            Text "x" { begin = 0, end = 0, index = 1, id = "e-3.1" }

                        fun =
                            Fun "bold" [ child ] { begin = 0, end = 5, index = 0, id = "e-3.0" }

                        bump m =
                            { m | id = EM.shiftExprId 1 m.id }
                    in
                    EM.mapExprMeta bump fun
                        |> Expect.equal
                            (Fun "bold"
                                [ Text "x" { begin = 0, end = 0, index = 1, id = "e-4.1" } ]
                                { begin = 0, end = 5, index = 0, id = "e-4.0" }
                            )
            ]
        , describe "applyEditToForest"
            [ test "an intra-line insert shifts begin/end of the block below" <|
                \_ ->
                    let
                        edit =
                            { offset = 6, removed = "", inserted = "X" }

                        -- block "ghi" begins at offset 10 in threePara
                        beforeGhi =
                            parseForest threePara
                                |> blocksOf
                                |> List.filter (\b -> b.meta.sourceText == "ghi")
                                |> List.head
                                |> Maybe.map (\b -> ( b.meta.begin, b.meta.end ))

                        afterGhi =
                            EM.applyEditToForest edit (parseForest threePara)
                                |> blocksOf
                                |> List.filter (\b -> b.meta.sourceText == "ghi")
                                |> List.head
                                |> Maybe.map (\b -> ( b.meta.begin, b.meta.end ))
                    in
                    Expect.equal ( beforeGhi, afterGhi )
                        ( Just ( 10, 13 ), Just ( 11, 14 ) )
            , test "a no-op edit (charDelta 0, lineDelta 0) leaves the forest unchanged" <|
                \_ ->
                    let
                        edit =
                            { offset = 6, removed = "e", inserted = "E" }
                    in
                    EM.applyEditToForest edit (parseForest threePara)
                        |> blocksOf
                        |> List.map (\b -> ( b.meta.begin, b.meta.end ))
                        |> Expect.equal
                            (parseForest threePara
                                |> blocksOf
                                |> List.map (\b -> ( b.meta.begin, b.meta.end ))
                            )
            , test "a negative offset is a no-op" <|
                \_ ->
                    let
                        edit =
                            { offset = -1, removed = "", inserted = "X" }
                    in
                    EM.applyEditToForest edit (parseForest threePara)
                        |> blocksOf
                        |> List.map (\b -> ( b.meta.begin, b.meta.end ))
                        |> Expect.equal
                            (parseForest threePara
                                |> blocksOf
                                |> List.map (\b -> ( b.meta.begin, b.meta.end ))
                            )
            ]
        ]
