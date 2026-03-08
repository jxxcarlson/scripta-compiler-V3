# ETeX Let-Expressions Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add LET/IN expressions to ETeX that allow naming sub-expressions and composing them via sequential substitution.

**Architecture:** A new `ETeX.Let` module performs text-level preprocessing before the existing ETeX transform pipeline. It parses LET/IN blocks using `Parser.Advanced`, resolves definitions sequentially, and substitutes into the body. The result is a plain LaTeX string that feeds into the existing `evalStr`/`transformETeX` functions unchanged.

**Tech Stack:** Elm 0.19.1, `Parser.Advanced`, `elm-test`

**Design doc:** `docs/plans/2026-03-08-etex-let-expressions-design.md`

---

### Task 1: Scaffold module and types

**Files:**
- Create: `src/ETeX/Let.elm`

**Step 1: Create the module with types and a stub `reduce` function**

```elm
module ETeX.Let exposing (reduce)


type alias Definition =
    { variable : Char
    , expr : String
    }


type alias LetBlock =
    { definitions : List Definition
    , body : String
    }


reduce : String -> String
reduce input =
    input
```

**Step 2: Verify it compiles**

Run: `elm make src/ETeX/Let.elm --output=/dev/null`
Expected: `Success!`

**Step 3: Commit**

```
git add src/ETeX/Let.elm
git commit -m "Add ETeX.Let module with types and stub reduce"
```

---

### Task 2: Write tests for `needsParens`

**Files:**
- Create: `tests/ETeX/LetTest.elm`
- Modify: `src/ETeX/Let.elm` (expose `needsParens` for testing)

**Step 1: Write the test file**

```elm
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
```

**Step 2: Run tests to verify they fail**

Run: `elm-test`
Expected: FAIL — `needsParens` not exposed / not defined

**Step 3: Commit test file**

```
git add tests/ETeX/LetTest.elm
git commit -m "Add tests for ETeX.Let.needsParens"
```

---

### Task 3: Implement `needsParens`

**Files:**
- Modify: `src/ETeX/Let.elm`

**Step 1: Update module exposing to include `needsParens`**

Change the module line to:
```elm
module ETeX.Let exposing (needsParens, reduce)
```

**Step 2: Implement `needsParens`**

Add after the type definitions:

```elm
needsParens : String -> Bool
needsParens expr =
    let
        trimmed =
            String.trim expr
    in
    if isFullyWrapped trimmed then
        False

    else
        hasTopLevelPlusOrMinus trimmed


{-| Check if the expression is fully wrapped in parens: "(...)".
-}
isFullyWrapped : String -> Bool
isFullyWrapped str =
    if String.startsWith "(" str && String.endsWith ")" str then
        -- Verify the opening paren matches the closing one
        let
            inner =
                str |> String.dropLeft 1 |> String.dropRight 1
        in
        not (hasUnmatchedParens inner)

    else
        False


{-| Check if a string has unmatched close-parens (meaning the outer parens don't match each other).
-}
hasUnmatchedParens : String -> Bool
hasUnmatchedParens str =
    let
        folder c depth =
            if depth < 0 then
                depth

            else if c == '(' then
                depth + 1

            else if c == ')' then
                depth - 1

            else
                depth
    in
    String.foldl folder 0 str < 0


{-| Check if + or - appears at brace/paren depth 0.
-}
hasTopLevelPlusOrMinus : String -> Bool
hasTopLevelPlusOrMinus str =
    let
        folder c ( depth, found ) =
            if found then
                ( depth, True )

            else if c == '{' || c == '(' then
                ( depth + 1, False )

            else if c == '}' || c == ')' then
                ( depth - 1, False )

            else if depth == 0 && (c == '+' || c == '-') then
                ( depth, True )

            else
                ( depth, False )
    in
    String.foldl folder ( 0, False ) str |> Tuple.second
```

**Step 3: Run tests**

Run: `elm-test`
Expected: All `needsParens` tests PASS

**Step 4: Commit**

```
git add src/ETeX/Let.elm
git commit -m "Implement needsParens for LET expression parenthesization"
```

---

### Task 4: Write tests for `substituteVariable`

**Files:**
- Modify: `tests/ETeX/LetTest.elm`
- Modify: `src/ETeX/Let.elm` (expose `substituteVariable`)

**Step 1: Add tests to `LetTest.elm`**

```elm
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
```

**Step 2: Run tests to verify they fail**

Run: `elm-test`
Expected: FAIL — `substituteVariable` not defined

**Step 3: Commit**

```
git add tests/ETeX/LetTest.elm
git commit -m "Add tests for ETeX.Let.substituteVariable"
```

---

### Task 5: Implement `substituteVariable`

**Files:**
- Modify: `src/ETeX/Let.elm`

**Step 1: Update module exposing**

```elm
module ETeX.Let exposing (needsParens, reduce, substituteVariable)
```

**Step 2: Implement `substituteVariable`**

```elm
substituteVariable : Char -> String -> String -> String
substituteVariable var expr target =
    let
        replacement =
            if needsParens expr then
                "(" ++ expr ++ ")"

            else
                expr

        varStr =
            String.fromChar var
    in
    substituteHelper var replacement (String.toList target) []
        |> List.reverse
        |> String.concat


substituteHelper : Char -> String -> List Char -> List String -> List String
substituteHelper var replacement remaining acc =
    case remaining of
        [] ->
            acc

        c :: rest ->
            if c == var && not (isAlphaNum (lastCharOfAcc acc)) && not (isAlphaNum (List.head rest)) then
                substituteHelper var replacement rest (replacement :: acc)

            else
                substituteHelper var replacement rest (String.fromChar c :: acc)


lastCharOfAcc : List String -> Maybe Char
lastCharOfAcc acc =
    case acc of
        [] ->
            Nothing

        s :: _ ->
            s |> String.right 1 |> String.toList |> List.head


isAlphaNum : Maybe Char -> Bool
isAlphaNum mc =
    case mc of
        Nothing ->
            False

        Just c ->
            Char.isAlphaNum c
```

**Step 3: Run tests**

Run: `elm-test`
Expected: All `substituteVariable` tests PASS

**Step 4: Commit**

```
git add src/ETeX/Let.elm
git commit -m "Implement substituteVariable with boundary detection and smart parens"
```

---

### Task 6: Write tests for `reduce`

**Files:**
- Modify: `tests/ETeX/LetTest.elm`

**Step 1: Add reduce tests**

```elm
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
```

**Step 2: Run tests to verify they fail**

Run: `elm-test`
Expected: FAIL — `reduce` is still a stub returning input unchanged

**Step 3: Commit**

```
git add tests/ETeX/LetTest.elm
git commit -m "Add tests for ETeX.Let.reduce"
```

---

### Task 7: Implement the LET/IN parser

**Files:**
- Modify: `src/ETeX/Let.elm`

**Step 1: Add Parser.Advanced import and parser types**

```elm
import Parser.Advanced as PA
    exposing
        ( (|.)
        , (|=)
        , Step(..)
        , chompIf
        , chompUntilEndOr
        , chompWhile
        , getChompedString
        , succeed
        )


type alias Parser a =
    PA.Parser () String a
```

**Step 2: Implement the parsers**

```elm
{-| Parse a LET/IN block. Returns ( preamble, LetBlock ) on success.
-}
parseLetBlock : String -> Maybe ( String, LetBlock )
parseLetBlock input =
    case splitOnLET input of
        Nothing ->
            Nothing

        Just ( preamble, letPart ) ->
            case PA.run letBlockParser letPart of
                Ok block ->
                    Just ( preamble, block )

                Err _ ->
                    Nothing


{-| Split input on the first line that is exactly "LET".
Returns ( before, fromLETonward ).
-}
splitOnLET : String -> Maybe ( String, String )
splitOnLET input =
    let
        lines =
            String.lines input

        findLET idx remaining =
            case remaining of
                [] ->
                    Nothing

                line :: rest ->
                    if String.trim line == "LET" then
                        let
                            before =
                                List.take idx lines |> String.join "\n"

                            after =
                                remaining |> String.join "\n"
                        in
                        Just ( before, after )

                    else
                        findLET (idx + 1) rest
    in
    findLET 0 lines


letBlockParser : Parser LetBlock
letBlockParser =
    succeed LetBlock
        |. PA.keyword (PA.Token "LET" "expected LET")
        |. PA.spaces
        |= definitionsParser
        |. PA.keyword (PA.Token "IN" "expected IN")
        |. optionalNewline
        |= bodyParser


definitionsParser : Parser (List Definition)
definitionsParser =
    PA.loop [] definitionsHelper


definitionsHelper : List Definition -> Parser (Step (List Definition) (List Definition))
definitionsHelper revDefs =
    PA.oneOf
        [ succeed (\d -> Loop (d :: revDefs))
            |= definitionParser
        , succeed ()
            |> PA.map (\_ -> Done (List.reverse revDefs))
        ]


definitionParser : Parser Definition
definitionParser =
    succeed Definition
        |. chompWhile (\c -> c == ' ')
        |= (chompIf Char.isUpper "expected uppercase letter"
                |> getChompedString
                |> PA.map (\s -> s |> String.toList |> List.head |> Maybe.withDefault 'X')
           )
        |. chompWhile (\c -> c == ' ')
        |. PA.symbol (PA.Token "=" "expected =")
        |. chompWhile (\c -> c == ' ')
        |= (chompUntilEndOr "\n" |> getChompedString |> PA.map String.trim)
        |. optionalNewline


bodyParser : Parser String
bodyParser =
    getChompedString (chompWhile (\_ -> True))
        |> PA.map String.trim


optionalNewline : Parser ()
optionalNewline =
    PA.oneOf
        [ PA.symbol (PA.Token "\n" "expected newline")
        , succeed ()
        ]
```

**Step 3: Verify it compiles**

Run: `elm make src/ETeX/Let.elm --output=/dev/null`
Expected: `Success!`

**Step 4: Commit**

```
git add src/ETeX/Let.elm
git commit -m "Implement LET/IN parser using Parser.Advanced"
```

---

### Task 8: Implement `reduce` using parser and substitution

**Files:**
- Modify: `src/ETeX/Let.elm`

**Step 1: Replace the stub `reduce` with the real implementation**

```elm
reduce : String -> String
reduce input =
    case parseLetBlock input of
        Nothing ->
            input

        Just ( preamble, letBlock ) ->
            let
                resolvedDefs =
                    resolveDefinitions letBlock.definitions

                result =
                    applyDefinitions resolvedDefs letBlock.body
            in
            if String.isEmpty preamble then
                result

            else
                preamble ++ "\n" ++ result


{-| Process definitions sequentially: substitute earlier variables into later definitions.
-}
resolveDefinitions : List Definition -> List Definition
resolveDefinitions defs =
    let
        folder def resolved =
            let
                newExpr =
                    List.foldl
                        (\prev expr -> substituteVariable prev.variable prev.expr expr)
                        def.expr
                        resolved
            in
            resolved ++ [ { def | expr = newExpr } ]
    in
    List.foldl folder [] defs


{-| Substitute all definitions into the body.
-}
applyDefinitions : List Definition -> String -> String
applyDefinitions defs body =
    List.foldl
        (\def text -> substituteVariable def.variable def.expr text)
        body
        defs
```

**Step 2: Run tests**

Run: `elm-test`
Expected: All `reduce` tests PASS

**Step 3: Commit**

```
git add src/ETeX/Let.elm
git commit -m "Implement reduce with sequential definition resolution"
```

---

### Task 9: Integrate into ETeX.Transform

**Files:**
- Modify: `src/ETeX/Transform.elm:176-190`

**Step 1: Add import**

Add after existing imports (around line 13):

```elm
import ETeX.Let
```

**Step 2: Modify `evalStr` (line 176-184)**

Change from:
```elm
evalStr : MathMacroDict -> String -> String
evalStr userDefinedMacroDict str =
    case evalStrResult userDefinedMacroDict str of
```

To:
```elm
evalStr : MathMacroDict -> String -> String
evalStr userDefinedMacroDict str =
    case evalStrResult userDefinedMacroDict (ETeX.Let.reduce str) of
```

**Step 3: Modify `transformETeX` (line 43-51)**

Change from:
```elm
transformETeX : MathMacroDict -> String -> String
transformETeX userdefinedMacroDict src =
    case transformETeXResult userdefinedMacroDict src of
```

To:
```elm
transformETeX : MathMacroDict -> String -> String
transformETeX userdefinedMacroDict src =
    case transformETeXResult userdefinedMacroDict (ETeX.Let.reduce src) of
```

**Step 4: Run all tests**

Run: `elm-test`
Expected: All 100+ tests PASS (existing tests unaffected since `reduce` is a no-op on non-LET input)

**Step 5: Commit**

```
git add src/ETeX/Transform.elm
git commit -m "Integrate ETeX.Let.reduce into evalStr and transformETeX"
```

---

### Task 10: Clean up exports and final verification

**Files:**
- Modify: `src/ETeX/Let.elm`

**Step 1: Remove test-only exports**

Change module line back to:
```elm
module ETeX.Let exposing (reduce)
```

Update `tests/ETeX/LetTest.elm` to only test via `reduce` (the public API). Remove direct imports of `needsParens` and `substituteVariable`. Keep only the `reduceSuite` tests, and add any `needsParens`/`substituteVariable` behaviors as `reduce` tests instead.

**Step 2: Run all tests**

Run: `elm-test`
Expected: All tests PASS

**Step 3: Compile the Demo app**

Run: `cd Demo && elm make src/Main.elm --output=main.js`
Expected: `Success!`

**Step 4: Commit**

```
git add src/ETeX/Let.elm tests/ETeX/LetTest.elm
git commit -m "Clean up ETeX.Let exports, finalize tests"
```