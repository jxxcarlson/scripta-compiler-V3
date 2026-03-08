module ETeX.LetTest exposing (..)

import ETeX.Let exposing (needsParens, reduce)
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
