# Wikilinks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the `[[ID]]` / `[[ID label...]]` wikilink construct to the Scripta compiler, rendering as `[ilink label... ID]`. Malformed wikilinks render in red.

**Architecture:** Parser-level. New `DLB` token for `[[` (no new token for `]]`). New `DL` symbol with value +2, matched by two `R` symbols. Reducer produces `Fun "wikilink"` for well-formed, `Fun "red" [Text source]` for malformed. Both renderers register a `"wikilink"` entry.

**Tech Stack:** Elm 0.19.1, elm-test, elm/parser.

**Spec:** `docs/wikilinks-design.md`.

---

## Files touched

- `src/Parser/Tokenizer.elm` — new `DLB` constructor, `TDLB` type, `doubleLeftBracketParser`, helper cases
- `src/Parser/Symbol.elm` — new `DL` symbol
- `src/Parser/Match.elm` — `isReducible` and `hasReducibleArgs` cases for `DL`
- `src/Parser/Expression.elm` — push/reduce/recover cases for `DLB`, wikilink helpers
- `src/Render/Expression.elm` — `renderWikilink`, markupDict entry
- `src/Render/Export/LaTeX.elm` — `wikilink` export function, markup dict entry
- `tests/Parser/SymbolTest.elm` — tests for `DL` (new file if missing)
- `tests/Parser/MatchTest.elm` — `DL` reducibility cases
- `tests/Parser/ExpressionParserTest.elm` — end-to-end wikilink cases

---

## Task 1: Tokenizer — add `DLB` token

**Files:**
- Modify: `src/Parser/Tokenizer.elm`
- Test: manual via elm REPL + covered indirectly by Task 4+

Background: `[` is tokenized one char at a time by `leftBracketParser` (line 437). We add a two-char parser `doubleLeftBracketParser` that tries `[[` first; single `[` still falls through to the existing parser.

- [ ] **Step 1: Add `DLB meta` to the `Token_` type**

File `src/Parser/Tokenizer.elm` at line 16-23, change:

```elm
type Token_ meta
    = LB meta
    | RB meta
    | S String meta
    | W String meta
    | MathToken meta
    | CodeToken meta
    | TokenError (List (DeadEnd Context Problem)) meta
```

to:

```elm
type Token_ meta
    = LB meta
    | DLB meta
    | RB meta
    | S String meta
    | W String meta
    | MathToken meta
    | CodeToken meta
    | TokenError (List (DeadEnd Context Problem)) meta
```

- [ ] **Step 2: Add `TDLB` to `TokenType` and extend `type_`**

At line 51-58, change:

```elm
type TokenType
    = TLB
    | TRB
    | TS
    | TW
    | TMath
    | TCode
    | TTokenError
```

to add `TDLB`:

```elm
type TokenType
    = TLB
    | TDLB
    | TRB
    | TS
    | TW
    | TMath
    | TCode
    | TTokenError
```

Extend `type_` (line 61-83) to add `DLB _ -> TDLB` case between LB and RB:

```elm
type_ : Token -> TokenType
type_ token =
    case token of
        LB _ ->
            TLB

        DLB _ ->
            TDLB

        RB _ ->
            TRB

        -- unchanged below
        ...
```

- [ ] **Step 3: Extend `indexOf`, `setIndex`, `getMeta`, `stringValue`**

Line 86-183: add `DLB meta` / `DLB m` cases mirroring `LB`. For `stringValue`, return `"[["`:

```elm
indexOf token =
    case token of
        LB meta -> meta.index
        DLB meta -> meta.index
        RB meta -> meta.index
        -- etc
```

```elm
setIndex k token =
    case token of
        LB meta -> LB { meta | index = k }
        DLB meta -> DLB { meta | index = k }
        RB meta -> RB { meta | index = k }
        -- etc
```

```elm
getMeta token =
    case token of
        LB m -> m
        DLB m -> m
        RB m -> m
        -- etc
```

```elm
stringValue token =
    case token of
        LB _ -> "["
        DLB _ -> "[["
        RB _ -> "]"
        -- etc
```

- [ ] **Step 4: Add `doubleLeftBracketParser` and register it**

Insert between `parenMathCloseParser` (line 400) and `backslashTextParser`:

```elm
doubleLeftBracketParser : Int -> Int -> TokenParser
doubleLeftBracketParser start index =
    Parser.symbol (Parser.Token "[[" (ExpectingSymbol "[["))
        |> Parser.map (\_ -> DLB { begin = start, end = start + 1, index = index })
```

Then in `tokenParser_` (line 376-388), insert `doubleLeftBracketParser start index` **before** `leftBracketParser start index`:

```elm
tokenParser_ start index =
    Parser.oneOf
        [ whiteSpaceParser start index
        , textParser start index
        , parenMathOpenParser start index
        , parenMathCloseParser start index
        , backslashTextParser start index
        , doubleLeftBracketParser start index
        , leftBracketParser start index
        , rightBracketParser start index
        , mathParser start index
        , codeParser start index
        ]
```

Order matters: `doubleLeftBracketParser` must come first so `[[` wins over `[`.

- [ ] **Step 5: Note on compile status**

Do NOT run `elm make` yet. Elm requires exhaustive case matching, and adding `DLB` breaks every case expression on `Token_` until Tasks 2-4 add matching arms. The compile chain (tokenizer → symbol → match → expression) will only be green again after Task 4 Step 5. Proceed to Task 2.

- [ ] **Step 6: Commit**

```bash
git add src/Parser/Tokenizer.elm
git commit -m "$(cat <<'EOF'
Add DLB token for [[ in wikilinks

Tokenizer now emits DLB for the two-char literal [[, tried before single [
via Parser.symbol. Single [ still tokenizes as LB. ]] stays as two RB.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

(Intermediate commits during Tasks 1-3 may not compile on their own; the chain is green again after Task 4 Step 6. This is a natural consequence of Elm's exhaustive pattern matching combined with incremental TDD.)

---

## Task 2: Symbol — add `DL`

**Files:**
- Modify: `src/Parser/Symbol.elm`
- Test: `tests/Parser/SymbolTest.elm`

- [ ] **Step 1: Write the failing tests**

Check if `tests/Parser/SymbolTest.elm` exists. If it does, add cases. If not, create:

File `tests/Parser/SymbolTest.elm`:

```elm
module Parser.SymbolTest exposing (..)

import Expect
import Parser.Symbol as Symbol exposing (Symbol(..))
import Parser.Tokenizer as Tokenizer exposing (Token_(..))
import Test exposing (Test, describe, test)


dummyMeta : Tokenizer.Meta
dummyMeta =
    { begin = 0, end = 0, index = 0 }


suite : Test
suite =
    describe "Parser.Symbol"
        [ describe "toSymbol"
            [ test "DLB token maps to DL symbol" <|
                \_ ->
                    Symbol.toSymbols [ DLB dummyMeta ]
                        |> Expect.equal [ DL ]
            , test "LB token maps to L symbol" <|
                \_ ->
                    Symbol.toSymbols [ LB dummyMeta ]
                        |> Expect.equal [ L ]
            ]
        , describe "value"
            [ test "DL has value 2" <|
                \_ ->
                    Symbol.value DL
                        |> Expect.equal 2
            , test "L has value 1" <|
                \_ ->
                    Symbol.value L
                        |> Expect.equal 1
            , test "R has value -1" <|
                \_ ->
                    Symbol.value R
                        |> Expect.equal -1
            ]
        ]
```

If the file already exists, insert the four `DL`/`DLB` test cases above into the existing `describe` blocks in the same style.

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
elm-test tests/Parser/SymbolTest.elm
```

Expected: compile errors referencing `DL` (which doesn't exist yet) and `Symbol.toSymbols` possibly failing to match `DLB`.

- [ ] **Step 3: Add `DL` to `Symbol` type**

File `src/Parser/Symbol.elm`, line 6-13, change:

```elm
type Symbol
    = L -- LB, [
    | R -- RB, ]
    | ST -- S String (string)
    | M -- $
    | C -- `
    | WS -- W String (whitespace)
    | E -- Token error
```

to:

```elm
type Symbol
    = L -- LB, [
    | DL -- DLB, [[
    | R -- RB, ]
    | ST -- S String (string)
    | M -- $
    | C -- `
    | WS -- W String (whitespace)
    | E -- Token error
```

- [ ] **Step 4: Extend `value` and `toSymbol`**

Line 16-39, extend `value` with `DL -> 2`:

```elm
value symbol =
    case symbol of
        L ->
            1

        DL ->
            2

        R ->
            -1

        ST ->
            0

        WS ->
            0

        M ->
            0

        C ->
            0

        E ->
            0
```

Line 46-68, extend `toSymbol` with `DLB _ -> DL`:

```elm
toSymbol token =
    case token of
        LB _ ->
            L

        DLB _ ->
            DL

        RB _ ->
            R

        -- unchanged below
        ...
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
elm-test tests/Parser/SymbolTest.elm
```

Expected: all 4 (or 4 new) tests PASS.

- [ ] **Step 6: Commit**

```bash
git add src/Parser/Symbol.elm tests/Parser/SymbolTest.elm
git commit -m "$(cat <<'EOF'
Add DL symbol for wikilink opener

DL maps DLB to a symbol with bracket-weight 2, closed by two R symbols.
Symbol/Match layer can now count wikilink nesting depth correctly.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Match — extend `isReducible` and `hasReducibleArgs` for `DL`

**Files:**
- Modify: `src/Parser/Match.elm`
- Test: `tests/Parser/MatchTest.elm`

- [ ] **Step 1: Write the failing tests**

Open `tests/Parser/MatchTest.elm` and add the following inside the `"isReducible"` describe block, alongside existing cases:

```elm
, test "[DL, ST, R, R] is True (simple [[ID]])" <|
    \_ ->
        Match.isReducible [ DL, ST, R, R ]
            |> Expect.equal True
, test "[DL, ST, WS, ST, R, R] is True ([[ID label]])" <|
    \_ ->
        Match.isReducible [ DL, ST, WS, ST, R, R ]
            |> Expect.equal True
, test "[DL, R, R] is True (empty body passes structural check)" <|
    \_ ->
        Match.isReducible [ DL, R, R ]
            |> Expect.equal True
, test "[DL, WS, R, R] is True (WS filtered equals empty body)" <|
    \_ ->
        Match.isReducible [ DL, WS, R, R ]
            |> Expect.equal True
, test "[DL, ST, L, ST, R, R, R] is False (nested [ in body)" <|
    \_ ->
        Match.isReducible [ DL, ST, L, ST, R, R, R ]
            |> Expect.equal False
, test "[DL, ST, DL, ST, R, R, R, R] is False (nested [[ in body)" <|
    \_ ->
        Match.isReducible [ DL, ST, DL, ST, R, R, R, R ]
            |> Expect.equal False
, test "[L, ST, DL, ST, R, R, R] is True (wikilink as child of [])" <|
    \_ ->
        Match.isReducible [ L, ST, DL, ST, R, R, R ]
            |> Expect.equal True
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
elm-test tests/Parser/MatchTest.elm
```

Expected: all 7 new tests FAIL (or compile error if `DL` is not yet exposed).

- [ ] **Step 3: Extend `isReducible` for `DL`**

File `src/Parser/Match.elm`, line 8-30. Current body:

```elm
isReducible : List Symbol -> Bool
isReducible symbols_ =
    let
        symbols =
            List.filter (\sym -> sym /= WS) symbols_
    in
    case symbols of
        M :: rest ->
            List.head (List.reverse rest) == Just M

        C :: rest ->
            List.head (List.reverse rest) == Just C

        L :: ST :: rest ->
            case List.head (List.reverse rest) of
                Just R ->
                    hasReducibleArgs (dropLast rest)

                _ ->
                    False

        _ ->
            False
```

Insert a `DL :: rest` case **before** the `_ -> False` fallback:

```elm
isReducible : List Symbol -> Bool
isReducible symbols_ =
    let
        symbols =
            List.filter (\sym -> sym /= WS) symbols_
    in
    case symbols of
        M :: rest ->
            List.head (List.reverse rest) == Just M

        C :: rest ->
            List.head (List.reverse rest) == Just C

        L :: ST :: rest ->
            case List.head (List.reverse rest) of
                Just R ->
                    hasReducibleArgs (dropLast rest)

                _ ->
                    False

        DL :: rest ->
            case lastTwo rest of
                Just ( R, R ) ->
                    isFlatBody (dropLast2 rest)

                _ ->
                    False

        _ ->
            False
```

At the bottom of `Parser.Match`, add the helpers:

```elm
lastTwo : List a -> Maybe ( a, a )
lastTwo list =
    case List.reverse list of
        b :: a :: _ ->
            Just ( a, b )

        _ ->
            Nothing


dropLast2 : List a -> List a
dropLast2 list =
    let
        n =
            List.length list
    in
    List.take (n - 2) list


isFlatBody : List Symbol -> Bool
isFlatBody symbols =
    List.all (\s -> s == ST) symbols
```

- [ ] **Step 4: Extend `hasReducibleArgs` for `DL`**

File `src/Parser/Match.elm` line 33-60. Current:

```elm
hasReducibleArgs : List Symbol -> Bool
hasReducibleArgs symbols =
    case symbols of
        [] ->
            True

        L :: _ ->
            reducibleAux symbols

        C :: _ ->
            reducibleAux symbols

        M :: _ ->
            let
                seg =
                    getSegment M symbols
            in
            if isReducible seg then
                hasReducibleArgs (List.drop (List.length seg) symbols)

            else
                False

        ST :: rest ->
            hasReducibleArgs rest

        _ ->
            False
```

Insert a `DL :: _` case that delegates to `reducibleAux` like the `L` case. `reducibleAux` calls `split`, which calls `match`, which uses bracket-count — `DL`'s value of 2 makes this work without extra match code:

```elm
hasReducibleArgs : List Symbol -> Bool
hasReducibleArgs symbols =
    case symbols of
        [] ->
            True

        L :: _ ->
            reducibleAux symbols

        DL :: _ ->
            reducibleAux symbols

        C :: _ ->
            reducibleAux symbols

        M :: _ ->
            let
                seg =
                    getSegment M symbols
            in
            if isReducible seg then
                hasReducibleArgs (List.drop (List.length seg) symbols)

            else
                False

        ST :: rest ->
            hasReducibleArgs rest

        _ ->
            False
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
elm-test tests/Parser/MatchTest.elm
```

Expected: all tests PASS (7 new + all existing).

- [ ] **Step 6: Commit**

```bash
git add src/Parser/Match.elm tests/Parser/MatchTest.elm
git commit -m "$(cat <<'EOF'
Recognize DL :: body :: R :: R as reducible wikilink

isReducible accepts DL when body is flat (only ST after WS filter).
hasReducibleArgs delegates DL to reducibleAux so wikilinks can appear as
args of [name ...] expressions. Match.match already handles DL's
bracket-weight 2 via the generic bracket-count loop.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: Expression — push `DLB` and reduce well-formed wikilinks

**Files:**
- Modify: `src/Parser/Expression.elm`
- Test: `tests/Parser/ExpressionParserTest.elm`

This task handles the happy path: `[[foo]]` and `[[foo bar]]` produce `Fun "wikilink"`. Malformed cases are addressed in Tasks 5-7.

- [ ] **Step 1: Write the failing tests**

Append to `tests/Parser/ExpressionParserTest.elm` inside the main `describe "parse"` block:

```elm
, test "parses [[foo]] as Fun wikilink with single Text arg" <|
    \_ ->
        let
            result =
                pe "[[foo]]"
        in
        case result of
            [ Fun "wikilink" [ Text "foo" _ ] _ ] ->
                Expect.pass

            _ ->
                Expect.fail ("Expected Fun \"wikilink\" [Text \"foo\"], got: " ++ Debug.toString result)
, test "parses [[foo bar baz]] with first Text arg = ID" <|
    \_ ->
        let
            result =
                pe "[[foo bar baz]]"
        in
        case result of
            [ Fun "wikilink" args _ ] ->
                case args of
                    (Text "foo" _) :: _ ->
                        Expect.pass

                    _ ->
                        Expect.fail ("Expected first arg Text \"foo\" (the ID), got: " ++ Debug.toString args)

            _ ->
                Expect.fail ("Expected [Fun \"wikilink\" args _], got: " ++ Debug.toString result)
, test "parses [[jxxcarlson-202611141744 Plato]] (zku id)" <|
    \_ ->
        let
            result =
                pe "[[jxxcarlson-202611141744 Plato]]"
        in
        case result of
            [ Fun "wikilink" args _ ] ->
                case args of
                    (Text "jxxcarlson-202611141744" _) :: _ ->
                        Expect.pass

                    _ ->
                        Expect.fail ("Expected first arg = zku ID, got: " ++ Debug.toString args)

            _ ->
                Expect.fail ("Expected [Fun \"wikilink\" …], got: " ++ Debug.toString result)
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
elm-test tests/Parser/ExpressionParserTest.elm
```

Expected: three new tests FAIL (likely with "Expected Fun \"wikilink\"…" because DLB hasn't been hooked into reduction yet).

- [ ] **Step 3: Push `DLB` onto the stack in `pushOrCommit`**

File `src/Parser/Expression.elm` line 135-157. Add a `DLB _` case that pushes:

```elm
pushOrCommit : Token -> State -> State
pushOrCommit token state =
    case token of
        S _ _ ->
            pushOrCommit_ token state

        W _ _ ->
            pushOrCommit_ token state

        MathToken _ ->
            pushOnStack_ token state

        CodeToken _ ->
            pushOnStack_ token state

        LB _ ->
            pushOnStack_ token state

        DLB _ ->
            pushOnStack_ token state

        RB _ ->
            pushOnStack_ token state

        TokenError _ _ ->
            pushOnStack_ token state
```

- [ ] **Step 4: Handle DLB in `reduceTokens`**

File `src/Parser/Expression.elm` line 221-284. Current `reduceTokens` begins with `if isExpr tokens then …`. We add a wikilink branch **before** that.

Replace the opening of `reduceTokens` with:

```elm
reduceTokens : Int -> List Token -> List Expression
reduceTokens lineNumber tokens =
    case tokens of
        (DLB dlbMeta) :: rest ->
            reduceWikilink lineNumber dlbMeta rest

        _ ->
            reduceTokensNonWikilink lineNumber tokens
```

Rename the existing body (everything from `if isExpr tokens then …` through the final `_ -> [ errorMessage "[????]" ]`) into `reduceTokensNonWikilink`:

```elm
reduceTokensNonWikilink : Int -> List Token -> List Expression
reduceTokensNonWikilink lineNumber tokens =
    if isExpr tokens then
        let
            args =
                unbracket tokens
        in
        case args of
            (S name meta) :: rest ->
                -- unchanged body from previous `reduceTokens`
                ...

            _ ->
                [ errorMessage "[????]" ]

    else
        case tokens of
            (MathToken meta) :: (S str _) :: (MathToken closeMeta) :: rest ->
                ...

            -- remainder unchanged
            ...

            _ ->
                [ errorMessage "[????]" ]
```

Add the wikilink reducer below (near the other helpers, e.g., after `reduceRestOfTokens`):

```elm
reduceWikilink : Int -> Tokenizer.Meta -> List Token -> List Expression
reduceWikilink lineNumber dlbMeta rest =
    case splitOffWikilinkBody rest of
        Just ( body, closeMeta ) ->
            if List.any isSToken body then
                let
                    spanMeta =
                        boostMeta lineNumber dlbMeta.index { dlbMeta | end = closeMeta.end }
                in
                [ Fun "wikilink" (wikilinkArgs lineNumber body) spanMeta ]

            else
                -- empty / whitespace-only body — handled in Task 5
                [ redLiteral lineNumber dlbMeta closeMeta (DLB dlbMeta :: rest) ]

        Nothing ->
            -- malformed body — handled in Task 6
            [ redLiteral lineNumber dlbMeta (lastMeta rest) (DLB dlbMeta :: rest) ]


splitOffWikilinkBody : List Token -> Maybe ( List Token, Tokenizer.Meta )
splitOffWikilinkBody tokens =
    case List.reverse tokens of
        (RB m2) :: (RB _) :: revBody ->
            let
                body =
                    List.reverse revBody
            in
            if List.all isFlatBodyToken body then
                Just ( body, m2 )

            else
                Nothing

        _ ->
            Nothing


isFlatBodyToken : Token -> Bool
isFlatBodyToken token =
    case token of
        S _ _ ->
            True

        W _ _ ->
            True

        _ ->
            False


isSToken : Token -> Bool
isSToken token =
    case token of
        S _ _ ->
            True

        _ ->
            False


wikilinkArgs : Int -> List Token -> List Expression
wikilinkArgs lineNumber tokens =
    List.filterMap (stringTokenToExpr lineNumber) tokens


lastMeta : List Token -> Tokenizer.Meta
lastMeta tokens =
    case List.reverse tokens of
        t :: _ ->
            Tokenizer.getMeta t

        [] ->
            { begin = 0, end = 0, index = 0 }


redLiteral : Int -> Tokenizer.Meta -> Tokenizer.Meta -> List Token -> Expression
redLiteral lineNumber dlbMeta closeMeta spanTokens =
    let
        source =
            Tokenizer.toString spanTokens

        spanMeta =
            boostMeta lineNumber dlbMeta.index
                { begin = dlbMeta.begin, end = closeMeta.end, index = dlbMeta.index }
    in
    Fun "red" [ Text source spanMeta ] spanMeta
```

You will need to expose `getMeta` and `toString` from `Parser.Tokenizer`. Open `src/Parser/Tokenizer.elm` line 1-9 and extend the module exposing list:

```elm
module Parser.Tokenizer exposing
    ( Meta
    , Token
    , TokenType(..)
    , Token_(..)
    , getMeta
    , indexOf
    , run
    , toString
    , type_
    )
```

In `src/Parser/Expression.elm`, add `Parser.Tokenizer as Tokenizer` alias if not present. Existing line 22:

```elm
import Parser.Tokenizer as Token exposing (Token, TokenType(..), Token_(..))
```

Change to expose `Meta`:

```elm
import Parser.Tokenizer as Token exposing (Meta, Token, TokenType(..), Token_(..))
```

And in `reduceWikilink` and helpers above, replace `Tokenizer.Meta` references with `Meta`, and `Tokenizer.getMeta` / `Tokenizer.toString` with `Token.getMeta` / `Token.toString` to match the existing alias. Final helpers:

```elm
reduceWikilink : Int -> Meta -> List Token -> List Expression
reduceWikilink lineNumber dlbMeta rest =
    case splitOffWikilinkBody rest of
        Just ( body, closeMeta ) ->
            if List.any isSToken body then
                let
                    spanMeta =
                        boostMeta lineNumber dlbMeta.index { dlbMeta | end = closeMeta.end }
                in
                [ Fun "wikilink" (wikilinkArgs lineNumber body) spanMeta ]

            else
                [ redLiteral lineNumber dlbMeta closeMeta (DLB dlbMeta :: rest) ]

        Nothing ->
            [ redLiteral lineNumber dlbMeta (lastMeta rest) (DLB dlbMeta :: rest) ]


splitOffWikilinkBody : List Token -> Maybe ( List Token, Meta )
splitOffWikilinkBody tokens =
    case List.reverse tokens of
        (RB m2) :: (RB _) :: revBody ->
            let
                body =
                    List.reverse revBody
            in
            if List.all isFlatBodyToken body then
                Just ( body, m2 )

            else
                Nothing

        _ ->
            Nothing


isFlatBodyToken : Token -> Bool
isFlatBodyToken token =
    case token of
        S _ _ ->
            True

        W _ _ ->
            True

        _ ->
            False


isSToken : Token -> Bool
isSToken token =
    case token of
        S _ _ ->
            True

        _ ->
            False


wikilinkArgs : Int -> List Token -> List Expression
wikilinkArgs lineNumber tokens =
    List.filterMap (stringTokenToExpr lineNumber) tokens


lastMeta : List Token -> Meta
lastMeta tokens =
    case List.reverse tokens of
        t :: _ ->
            Token.getMeta t

        [] ->
            { begin = 0, end = 0, index = 0 }


redLiteral : Int -> Meta -> Meta -> List Token -> Expression
redLiteral lineNumber dlbMeta closeMeta spanTokens =
    let
        source =
            Token.toString spanTokens

        spanMeta =
            boostMeta lineNumber dlbMeta.index
                { begin = dlbMeta.begin, end = closeMeta.end, index = dlbMeta.index }
    in
    Fun "red" [ Text source spanMeta ] spanMeta
```

- [ ] **Step 5: Handle DLB in `reduceRestOfTokens`**

File `src/Parser/Expression.elm` line 287-324. Add a case for `DLB` that mirrors the existing `LB` case at line 290-296:

```elm
reduceRestOfTokens : Int -> List Token -> List Expression
reduceRestOfTokens lineNumber tokens =
    case tokens of
        (LB _) :: _ ->
            case splitTokens tokens of
                Nothing ->
                    [ Text "error on match" dummyLocWithId ]

                Just ( a, b ) ->
                    reduceTokens lineNumber a ++ reduceRestOfTokens lineNumber b

        (DLB _) :: _ ->
            case splitTokens tokens of
                Nothing ->
                    [ Text "error on match" dummyLocWithId ]

                Just ( a, b ) ->
                    reduceTokens lineNumber a ++ reduceRestOfTokens lineNumber b

        (MathToken _) :: _ ->
            -- unchanged
            ...
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
elm-test tests/Parser/ExpressionParserTest.elm
```

Expected: three new wikilink tests PASS. All existing tests continue to pass.

If existing tests fail, re-check that `reduceTokensNonWikilink` contains the exact original body of `reduceTokens` (no lines dropped during refactoring).

- [ ] **Step 7: Commit**

```bash
git add src/Parser/Tokenizer.elm src/Parser/Expression.elm tests/Parser/ExpressionParserTest.elm
git commit -m "$(cat <<'EOF'
Reduce well-formed wikilinks to Fun \"wikilink\"

DLB :: body :: RB :: RB with flat, non-empty body becomes Fun \"wikilink\"
with the body tokens (Text + whitespace) as args in source order. First
arg is the ID. Label args follow. Renderer will reshuffle for ilink.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Empty and whitespace-only wikilinks → red literal

**Files:**
- Modify: nothing (logic already stubbed in Task 4; only tests added here)
- Test: `tests/Parser/ExpressionParserTest.elm`

Task 4 already routes empty / whitespace-only bodies to `redLiteral`. This task verifies via tests.

- [ ] **Step 1: Write tests**

Append to `tests/Parser/ExpressionParserTest.elm`:

```elm
, test "parses [[]] as Fun red with literal [[]]" <|
    \_ ->
        let
            result =
                pe "[[]]"
        in
        case result of
            [ Fun "red" [ Text "[[]]" _ ] _ ] ->
                Expect.pass

            _ ->
                Expect.fail ("Expected [Fun \"red\" [Text \"[[]]\"]], got: " ++ Debug.toString result)
, test "parses [[   ]] as Fun red with literal [[   ]]" <|
    \_ ->
        let
            result =
                pe "[[   ]]"
        in
        case result of
            [ Fun "red" [ Text "[[   ]]" _ ] _ ] ->
                Expect.pass

            _ ->
                Expect.fail ("Expected [Fun \"red\" [Text \"[[   ]]\"]], got: " ++ Debug.toString result)
```

- [ ] **Step 2: Run tests**

```bash
elm-test tests/Parser/ExpressionParserTest.elm
```

Expected: both tests PASS (the Task 4 implementation already handles this).

If a test fails with mismatched source text (e.g. `[[ ]]` instead of `[[   ]]`), check that `Token.stringValue` for `W str _` returns `str` verbatim. Fix `stringValue` if needed.

- [ ] **Step 3: Commit**

```bash
git add tests/Parser/ExpressionParserTest.elm
git commit -m "$(cat <<'EOF'
Test: [[]] and [[   ]] render as red literal

Verifies the empty/whitespace-only branch of reduceWikilink emits
Fun \"red\" [Text source].

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: Malformed body (nested brackets) → red literal

**Files:**
- Test: `tests/Parser/ExpressionParserTest.elm`

Task 4 already routes malformed bodies through the `Nothing` branch of `splitOffWikilinkBody` to `redLiteral`. This task verifies with tests, including the nested-wikilink case.

- [ ] **Step 1: Write tests**

Append to `tests/Parser/ExpressionParserTest.elm`:

```elm
, test "parses [[a [b] c]] as Fun red" <|
    \_ ->
        let
            result =
                pe "[[a [b] c]]"
        in
        case result of
            [ Fun "red" [ Text src _ ] _ ] ->
                src
                    |> Expect.equal "[[a [b] c]]"

            _ ->
                Expect.fail ("Expected [Fun \"red\" [Text ...]], got: " ++ Debug.toString result)
, test "parses [[a [[b]] c]] as Fun red (nested wikilink malformed)" <|
    \_ ->
        let
            result =
                pe "[[a [[b]] c]]"
        in
        case result of
            [ Fun "red" [ Text src _ ] _ ] ->
                src
                    |> Expect.equal "[[a [[b]] c]]"

            _ ->
                Expect.fail ("Expected [Fun \"red\" [Text \"[[a [[b]] c]]\"]], got: " ++ Debug.toString result)
```

- [ ] **Step 2: Run tests to verify they pass or fail**

```bash
elm-test tests/Parser/ExpressionParserTest.elm
```

Expected: both tests PASS. If the nested-wikilink case (`[[a [[b]] c]]`) fails with the inner `[[b]]` reducing first, that means top-down splitting is not happening as expected. Investigate `splitTokens` → `Match.match` behavior for symbol sequence `DL ST WS DL ST R R WS ST R R`. The running bracket count is:
start 2, ST=2, WS=2, DL=4, ST=4, R=3, R=2, WS=2, ST=2, R=1, R=0 — matches the FINAL R (whole span). So `splitTokens` returns the whole span as `a`, and `reduceTokens` sees the whole span as one wikilink — which `splitOffWikilinkBody` then rejects due to nested DLB in body. `redLiteral` emits the source text including inner `[[b]]` unchanged. Test should pass.

If the test fails, add a `let _ = Debug.log "tokens" tokens in` at the entry of `reduceWikilink` and verify the token list matches expectations.

- [ ] **Step 3: Commit**

```bash
git add tests/Parser/ExpressionParserTest.elm
git commit -m "$(cat <<'EOF'
Test: malformed wikilink bodies render as red literal

[[a [b] c]] and [[a [[b]] c]] both have non-flat bodies and fall through
to redLiteral, emitting Fun \"red\" [Text <original-source>].

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 7: Unclosed `[[` — recover as red literal

**Files:**
- Modify: `src/Parser/Expression.elm`
- Test: `tests/Parser/ExpressionParserTest.elm`

An unclosed `[[unclosed` leaves `DLB` on the stack at end-of-input. `recoverFromError` (line 327-401) handles this path. We extend it to emit a red literal for leading `DLB` instead of the fallback `" ?!? "`.

- [ ] **Step 1: Write the failing test**

Append to `tests/Parser/ExpressionParserTest.elm`:

```elm
, test "parses [[unclosed as Fun red" <|
    \_ ->
        let
            result =
                pe "[[unclosed"
        in
        case result of
            [ Fun "red" [ Text src _ ] _ ] ->
                src
                    |> Expect.equal "[[unclosed"

            _ ->
                Expect.fail ("Expected [Fun \"red\" [Text \"[[unclosed\"]], got: " ++ Debug.toString result)
```

- [ ] **Step 2: Run test to verify it fails**

```bash
elm-test tests/Parser/ExpressionParserTest.elm
```

Expected: FAIL with current output likely being `Fun "errorHighlight" [Text " ?!? "]` or similar.

- [ ] **Step 3: Extend `recoverFromError`**

File `src/Parser/Expression.elm` line 327-401. Add a `(DLB dlbMeta) :: rest` case **before** `(LB _) :: (RB meta) :: _`:

```elm
recoverFromError : State -> Step State State
recoverFromError state =
    case List.reverse state.stack of
        (DLB dlbMeta) :: rest ->
            let
                spanTokens =
                    List.reverse state.stack

                closeMeta =
                    case List.head state.stack of
                        Just t ->
                            Token.getMeta t

                        Nothing ->
                            dlbMeta
            in
            Done
                { state
                    | committed =
                        redLiteral state.lineNumber dlbMeta closeMeta spanTokens
                            :: state.committed
                    , stack = []
                    , tokenIndex = 0
                    , numberOfTokens = 0
                    , messages = prependMessage state.lineNumber "Unclosed [[" state.messages
                }

        (LB _) :: (RB meta) :: _ ->
            -- unchanged below
            ...
```

- [ ] **Step 4: Run test to verify it passes**

```bash
elm-test tests/Parser/ExpressionParserTest.elm
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/Parser/Expression.elm tests/Parser/ExpressionParserTest.elm
git commit -m "$(cat <<'EOF'
Recover unclosed [[ as red literal

recoverFromError emits Fun \"red\" [Text <source>] when an unclosed DLB
is on the stack at end-of-input, covering cases like \"[[unclosed\".

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 8: Wikilink as child of bracket expression + regressions

**Files:**
- Test: `tests/Parser/ExpressionParserTest.elm`

Two verifications: (a) `[foo [[bar]] baz]` reduces with a `wikilink` child inside a `foo` Fun, (b) the existing `[outer [inner]]` shape is unchanged.

- [ ] **Step 1: Write the tests**

Append to `tests/Parser/ExpressionParserTest.elm`:

```elm
, test "parses [foo [[bar]] baz] with wikilink child" <|
    \_ ->
        let
            result =
                pe "[foo [[bar]] baz]"
        in
        case result of
            [ Fun "foo" children _ ] ->
                let
                    hasWikilinkChild =
                        List.any
                            (\child ->
                                case child of
                                    Fun "wikilink" [ Text "bar" _ ] _ ->
                                        True

                                    _ ->
                                        False
                            )
                            children
                in
                if hasWikilinkChild then
                    Expect.pass

                else
                    Expect.fail ("Expected a wikilink child, got: " ++ Debug.toString children)

            _ ->
                Expect.fail ("Expected [Fun \"foo\" children _], got: " ++ Debug.toString result)
, test "regression: [italic how is this [bold possible?]] unchanged" <|
    \_ ->
        let
            result =
                pe "[italic how is this [bold possible?]]"
        in
        case result of
            [ Fun "italic" _ _ ] ->
                Expect.pass

            _ ->
                Expect.fail ("Expected [Fun \"italic\" ...], got: " ++ Debug.toString result)
, test "parses two wikilinks on one line" <|
    \_ ->
        let
            result =
                pe "prefix [[a]] middle [[b]] suffix"

            wikilinkCount =
                List.length
                    (List.filter
                        (\expr ->
                            case expr of
                                Fun "wikilink" _ _ ->
                                    True

                                _ ->
                                    False
                        )
                        result
                    )
        in
        wikilinkCount
            |> Expect.equal 2
```

- [ ] **Step 2: Run tests**

```bash
elm-test tests/Parser/ExpressionParserTest.elm
```

Expected: all three tests PASS. Existing tests continue to pass.

If `[foo [[bar]] baz]` fails with an error shape, check `hasReducibleArgs` (Task 3) — the `DL :: _` case is what enables this.

- [ ] **Step 3: Commit**

```bash
git add tests/Parser/ExpressionParserTest.elm
git commit -m "$(cat <<'EOF'
Test: wikilink as child of bracket expr + regressions

[foo [[bar]] baz] reduces with a Fun \"wikilink\" child. The existing
[outer [inner]] shape is unchanged. Multiple wikilinks on one line parse
independently.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 9: Web renderer — `renderWikilink`

**Files:**
- Modify: `src/Render/Expression.elm`
- Test: manual (no render-test harness identified)

- [ ] **Step 1: Register `"wikilink"` in `markupDict`**

File `src/Render/Expression.elm` line 151 (near `ilink` entry). Add:

```elm
, ( "ilink", renderIlink )
, ( "wikilink", renderWikilink )
```

- [ ] **Step 2: Add `renderWikilink`**

At an appropriate location (e.g., immediately after `renderIlink` at line 489ff), add:

```elm
{-| Render a wikilink. Args arrive with ID first, then label words.
Reshuffle so ID is last (to match ilink's trailing-ID convention), then
delegate to renderIlink.
-}
renderWikilink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderWikilink params acc args meta =
    renderIlink params acc (moveFirstTextToEnd args) meta


moveFirstTextToEnd : List Expression -> List Expression
moveFirstTextToEnd args =
    case args of
        (Text first firstMeta) :: rest ->
            dropLeadingWhitespace rest ++ [ Text first firstMeta ]

        _ ->
            args


dropLeadingWhitespace : List Expression -> List Expression
dropLeadingWhitespace args =
    case args of
        (Text s m) :: rest ->
            if String.trim s == "" then
                dropLeadingWhitespace rest

            else
                Text s m :: rest

        _ ->
            args
```

`moveFirstTextToEnd` takes `[Text ID, W, Text w1, W, Text w2]` and produces `[Text w1, W, Text w2, Text ID]`, which `renderIlink`'s word-extraction (line 493-497) turns into `"w1 w2 ID"`, last word = `ID`. ✓

- [ ] **Step 3: Compile-check**

```bash
elm make src/Main.elm --output=/dev/null
```

Expected: PASS.

- [ ] **Step 4: Manual sanity check**

If an elm-watch dev server is available:

```bash
elm-watch hot
```

Create a small Scripta test file containing `[[example-id]]` and `[[example-id My Label]]`, open it in the browser, and verify the wikilinks render as clickable blue links with text `example-id` and `My Label` respectively.

If elm-watch is not set up, skip to commit — the next task's LaTeX export provides a verifiable artifact, and the full chain is covered by parser tests.

- [ ] **Step 5: Commit**

```bash
git add src/Render/Expression.elm
git commit -m "$(cat <<'EOF'
Render wikilink as ilink with reshuffled args

renderWikilink moves the ID (first arg) to the end, then delegates to
renderIlink. Leading whitespace after the ID is stripped so the label
\"label words\" is contiguous.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 10: LaTeX export — `wikilink`

**Files:**
- Modify: `src/Render/Export/LaTeX.elm`
- Test: manual via `tests/toLaTeXExport/`

- [ ] **Step 1: Register `"wikilink"` in the markup dict**

File `src/Render/Export/LaTeX.elm` line 1233 (near `ilink`). Find:

```elm
, ( "ilink", \_ -> ilink )
```

Add directly below:

```elm
, ( "ilink", \_ -> ilink )
, ( "wikilink", \_ -> wikilink )
```

- [ ] **Step 2: Add the `wikilink` function**

Near `ilink` (line 1487), add:

```elm
wikilink : List Expression -> String
wikilink exprs =
    ilink (moveFirstTextToEnd exprs)


moveFirstTextToEnd : List Expression -> List Expression
moveFirstTextToEnd exprs =
    case exprs of
        (Text first firstMeta) :: rest ->
            dropLeadingWhitespace rest ++ [ Text first firstMeta ]

        _ ->
            exprs


dropLeadingWhitespace : List Expression -> List Expression
dropLeadingWhitespace exprs =
    case exprs of
        (Text s m) :: rest ->
            if String.trim s == "" then
                dropLeadingWhitespace rest

            else
                Text s m :: rest

        _ ->
            exprs
```

`ilink` then processes `[Text w1, W, Text w2, Text ID]` via `getTwoArgs`, producing `first = "w1 w2"`, `second = "ID"`, and renders `\href{https://scripta.io/s/ID}{w1 w2}`. ✓

- [ ] **Step 3: Compile-check**

```bash
elm make src/Main.elm --output=/dev/null
```

Expected: PASS.

- [ ] **Step 4: Manual end-to-end test via toLaTeXExport**

Create `tests/toLaTeXExportTestDocs/wikilinks.scripta` with:

```
| title
Wikilinks test

Single: [[abc123]]

With label: [[abc123 Example Label]]

Zku: [[jxxcarlson-202611141744]]

Zku with label: [[jxxcarlson-202611141744 Plato]]

Empty: [[]]

Whitespace: [[   ]]

Malformed: [[a [b] c]]
```

From repo root:

```bash
cd tests/toLaTeXExport
make wikilinks.scripta
```

Expected: produces a `.tex` file containing `\href{https://scripta.io/s/abc123}{abc123}` for the single case and `\href{https://scripta.io/s/abc123}{Example Label}` for the label case. Malformed cases appear wrapped in `\textcolor{red}{...}`.

If `make` or the PDF server is unavailable, skip the PDF step but inspect the `.tex` output.

- [ ] **Step 5: Commit**

```bash
git add src/Render/Export/LaTeX.elm tests/toLaTeXExportTestDocs/wikilinks.scripta
git commit -m "$(cat <<'EOF'
Export wikilinks to LaTeX \\ilink

wikilink reshuffles the args (ID first → ID last) and delegates to ilink,
producing \\href{https://scripta.io/s/ID}{label}. Malformed wikilinks
travel as Fun \"red\" [Text src] and emit \\textcolor{red}{...} via the
existing \"red\" handler.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 11: Full-suite regression check

- [ ] **Step 1: Run all tests**

```bash
elm-test
```

Expected: all existing + all new tests PASS. Zero failures.

- [ ] **Step 2: Full compile check**

```bash
elm make src/Main.elm --output=/dev/null --optimize
```

Expected: PASS.

- [ ] **Step 3: If any test fails**

Investigate one at a time. Common failure modes:

- *Compile errors about missing cases for `DLB` in a file not covered above*: find the file, add the `DLB` arm mirroring the `LB` arm. Re-run.
- *Regression in existing `[name …]` parsing*: suggests `reduceTokensNonWikilink` was not exactly the original `reduceTokens` body. Diff against git history to restore.
- *Source-text mismatch in a red-literal test (`Expected "[[foo]]" got "[foo]"`)*: `stringValue DLB _` must return `"[["` not `"["`.

- [ ] **Step 4: Final commit (no-op if clean)**

Only commit if additional fixes were applied in Step 3:

```bash
git add -A
git commit -m "$(cat <<'EOF'
Fix regressions discovered during wikilinks full-suite check

<describe specific fixes>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Self-review checklist

Done during plan writing:

- **Spec coverage**: examples table (well-formed single, well-formed multi, zku, empty, whitespace, nested-bracket, nested-wikilink, regressions, unclosed) each have at least one test task. ✓
- **Placeholder scan**: no "TBD", "TODO", or "similar to…" directives. Every code block is complete. ✓
- **Type consistency**: `DLB` used consistently in Tokenizer, Symbol (`DL`), Match (`DL`), Expression (reduceWikilink, splitOffWikilinkBody). Helper names `moveFirstTextToEnd` and `dropLeadingWhitespace` are the same in both renderers. ✓
