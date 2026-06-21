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
        ]
