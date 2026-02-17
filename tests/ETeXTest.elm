module ETeXTest exposing (..)

import Dict
import ETeX.Test as T
import ETeX.Transform exposing (makeMacroDict, transformETeX)
import Expect
import Test exposing (Test, describe, test)


macroDefinitions : String
macroDefinitions =
    """
nat:      mathbb N
reals:    mathbb R
space:    reals^(#1)
set:      \\{ #1 \\}
sett:     \\{\\ #1 \\ | \\ #2 \\ \\}
bracket:  \\{ [ #1 ] \\}
"""


macroDict =
    makeMacroDict macroDefinitions


suite : Test
suite =
    describe "ETeX.Transform"
        [ test "transforms a simple macro" <|
            \_ ->
                transformETeX macroDict "nat"
                    |> Expect.equal "\\nat"
        , test "transforms a macro with one argument" <|
            \_ ->
                transformETeX macroDict "set(x)"
                    |> Expect.equal "\\set{x}"
        , test "passes through plain LaTeX unchanged" <|
            \_ ->
                transformETeX Dict.empty "a^2 + b^2 = c^2"
                    |> Expect.equal "a^2 + b^2 = c^2"
        , test "Greek letters" <|
            \_ ->
                transformETeX Dict.empty "alpha^2 + beta^2 = gamma^2"
                    |> Expect.equal "\\alpha^2 + \\beta^2 = \\gamma^2"

        --, test "bad " <|
        --    \_ ->
        --        transformETeX Dict.empty "[math E = \\hbar q \\omega]"
        --            |> Expect.equal "[math E = hbar q omega]"
        ]
