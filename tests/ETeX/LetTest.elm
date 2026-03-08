module ETeX.LetTest exposing (..)

import ETeX.Let exposing (needsParens, reduce, substituteVariable)
import Expect
import Test exposing (Test, describe, test)


needsParensSuite : Test
needsParensSuite =
    describe "needsParens"
        [ test "single letter" <|
            \_ -> Expect.equal False (needsParens "x")
        , test "single number" <|
            \_ -> Expect.equal False (needsParens "3")
        , test "power expression (no +/-)" <|
            \_ -> Expect.equal False (needsParens "x^2")
        , test "frac (no +/-)" <|
            \_ -> Expect.equal False (needsParens "\\frac{1}{2}")
        , test "sum needs parens" <|
            \_ -> Expect.equal True (needsParens "a + b")
        , test "difference needs parens" <|
            \_ -> Expect.equal True (needsParens "a - b")
        , test "plus inside braces does not need parens" <|
            \_ -> Expect.equal False (needsParens "\\frac{a + b}{2}")
        , test "plus inside parens does not need parens" <|
            \_ -> Expect.equal False (needsParens "(a + b)")
        , test "already parenthesized" <|
            \_ -> Expect.equal False (needsParens "(a + b)")
        , test "negative sign at start (unary minus)" <|
            \_ -> Expect.equal True (needsParens "-x")
        ]


substituteSuite : Test
substituteSuite =
    describe "substituteVariable"
        [ test "simple replacement" <|
            \_ -> Expect.equal "x^2 + 1" (substituteVariable 'A' "x^2" "A + 1")
        , test "no replacement when part of longer identifier" <|
            \_ -> Expect.equal "AB + 1" (substituteVariable 'A' "x^2" "AB + 1")
        , test "multiple occurrences" <|
            \_ -> Expect.equal "x^2 + x^2" (substituteVariable 'A' "x^2" "A + A")
        , test "adds parens when expr has plus" <|
            \_ -> Expect.equal "(a + b) + 1" (substituteVariable 'A' "a + b" "A + 1")
        , test "no parens when expr is simple" <|
            \_ -> Expect.equal "x^2 + 1" (substituteVariable 'A' "x^2" "A + 1")
        , test "variable at start of string" <|
            \_ -> Expect.equal "x^2 + 1" (substituteVariable 'A' "x^2" "A + 1")
        , test "variable at end of string" <|
            \_ -> Expect.equal "1 + x^2" (substituteVariable 'A' "x^2" "1 + A")
        , test "variable alone" <|
            \_ -> Expect.equal "x^2" (substituteVariable 'A' "x^2" "A")
        , test "no match" <|
            \_ -> Expect.equal "b + 1" (substituteVariable 'A' "x^2" "b + 1")
        , test "adjacent to operator" <|
            \_ -> Expect.equal "x^2+x^2" (substituteVariable 'A' "x^2" "A+A")
        , test "adjacent to brace" <|
            \_ -> Expect.equal "{x^2}" (substituteVariable 'A' "x^2" "{A}")
        ]


reduceSuite : Test
reduceSuite =
    describe "reduce"
        [ test "no LET block passes through" <|
            \_ -> Expect.equal "x^2 + 1" (reduce "x^2 + 1")
        , test "simple single variable" <|
            \_ ->
                reduce "LET\n  A = x^2\nIN\n  A + 1"
                    |> Expect.equal "x^2 + 1"
        , test "two independent variables" <|
            \_ ->
                reduce "LET\n  A = x^2\n  B = y^2\nIN\n  A + B"
                    |> Expect.equal "x^2 + y^2"
        , test "sequential definitions" <|
            \_ ->
                reduce "LET\n  A = e1\n  B = e2\n  P = A + B\nIN\n  P"
                    |> Expect.equal "(e1 + e2)"
        , test "full example from design doc" <|
            \_ ->
                reduce "LET\n  A = e1\n  B = e2\n  P = A + B\n  Q = A - B\nIN\n  PQ"
                    |> Expect.equal "(e1 + e2)(e1 - e2)"
        , test "content before LET is preserved" <|
            \_ ->
                reduce "preamble\nLET\n  A = x\nIN\n  A + 1"
                    |> Expect.equal "preamble\nx + 1"
        , test "no parens for simple expressions" <|
            \_ ->
                reduce "LET\n  A = x^2\n  B = y^2\nIN\n  AB"
                    |> Expect.equal "AB"
        , test "variables not replaced inside identifiers" <|
            \_ ->
                reduce "LET\n  A = x\nIN\n  AB + A"
                    |> Expect.equal "AB + x"
        ]
