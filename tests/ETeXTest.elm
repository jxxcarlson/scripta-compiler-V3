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


macroDefinitionsWithZero : String
macroDefinitionsWithZero =
    """
nat:      mathbb N
zero:     mathop{\\tt{zero}}
"""


macroDict =
    makeMacroDict macroDefinitions


macroDictWithZero =
    makeMacroDict macroDefinitionsWithZero


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
        , test "unknown macro passes through silently" <|
            -- C2: documents silent failure — unknown backslash-commands pass through unchanged
            \_ ->
                transformETeX Dict.empty "\\badmacro"
                    |> Expect.equal "\\badmacro"
        , test "multi-arg macro: space(3)" <|
            \_ ->
                transformETeX macroDict "space(3)"
                    |> Expect.equal "\\space{3}"
        , test "two-argument macro: sett(A,B)" <|
            \_ ->
                transformETeX macroDict "sett(A,B)"
                    |> Expect.equal "\\sett{A}{B}"
        , test "makeMacroDict with invalid line returns empty dict" <|
            -- C2: bad input handling — lines without colon or \\newcommand are skipped
            \_ ->
                makeMacroDict "not a definition"
                    |> Expect.equal Dict.empty
        , test "parse failure produces visible error marker" <|
            -- FIXED C2: parse failures now show [ETeX error] instead of silently returning input
            \_ ->
                transformETeX Dict.empty "\\foo{"
                    |> String.startsWith "[ETeX error]"
                    |> Expect.equal True
        , test "textsf preserves bare words that match user macros" <|
            \_ ->
                transformETeX macroDictWithZero "\\textsf{zero-intro}"
                    |> Expect.equal "\\textsf{zero-intro}"
        , test "text command preserves content as-is" <|
            \_ ->
                transformETeX macroDictWithZero "\\text{hello world}"
                    |> Expect.equal "\\text{hello world}"
        , test "text command with nested braces" <|
            \_ ->
                transformETeX macroDictWithZero "\\text{\\textbf{bold} normal}"
                    |> Expect.equal "\\text{\\textbf{bold} normal}"
        ]
