module EditMapTest exposing (suite)

import Edit.Map as EM
import Expect
import Test exposing (Test, describe, test)


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
        ]
