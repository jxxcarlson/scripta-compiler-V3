# Diff-Update-Map Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fast, pure metadata-shift (`applyEdit` / `applyEdits`) that keeps the RL-sync `data-begin`/`data-end`/`data-lines`/`id` metadata valid between debounced reparses, without reparsing content.

**Architecture:** A new pure module `src/Edit/Map.elm` shifts position metadata over the parsed forest (`List (Tree ExpressionBlock)`): blocks above the edit are untouched, the containing block grows, blocks below shift their offsets/line numbers/ids. `Scripta.elm` exposes `applyEdit`/`applyEdits` by unwrapping the opaque `Document`, shifting its forest, and rewrapping. Content reparsing remains the job of the existing debounced `Scripta.reparse`.

**Tech Stack:** Elm 0.19.1, `elm-explorations/test` 2.2.0 (run with `npx elm-test`), `maca/elm-rose-tree` (`RoseTree.Tree.mapValues`), `toastal/either` (`Either.map`).

## Global Constraints

- Elm 0.19.1; **no new dependencies** (use only `V3.Types`, `RoseTree.Tree`, `Either`, `String`).
- Follow existing test conventions: each test module exposes `suite : Test` and lives in `tests/` (see `tests/ScriptaTest.elm`).
- `applyEdit` is **total** — it returns a `Document`/forest and never errors or crashes.
- Shift-only: never reparse, never re-render, never modify block `sourceText`, `body` content text, `messages`, or `error`.
- The reference field meanings (verbatim from the spec): block `begin`/`end` are **absolute character offsets** into the whole source, `end = begin + length(sourceText)`; `numberOfLines` is a line count; `lineNumber` is the 0-based start line; expression `begin`/`end` are offsets **within their line**; block `id = "L-I"` (`lineNumber-blockIndex`); expression `id = "e-L.T"` (`e-lineNumber.tokenIndex`).

---

## File Structure

- **Create** `src/Edit/Map.elm` — the pure shift logic and the `Edit` type. Depends only on `V3.Types`, `RoseTree.Tree`, `Either`, `String`. Responsibility: given one `Edit`, transform a forest's metadata.
- **Modify** `src/Scripta.elm` — re-export `Edit` and add `applyEdit` / `applyEdits` over the opaque `Document`.
- **Create** `tests/EditMapTest.elm` — unit tests for helpers + forest-level shift tests.
- **Create** `tests/EditOracleTest.elm` — the acceptance oracle: `applyEdit (parse base)` block metadata equals `parse edited` for structure-preserving edits.

Tests read the forest out of an opaque `Document` by destructuring `Scripta.Internal.Document data` (the `Document(..)` constructor and `DocumentData` are exposed from `src/Scripta/Internal.elm`), exactly as `tests/ScriptaTest.elm` already imports `Scripta.Internal`.

---

### Task 1: `Edit` type and delta helpers

**Files:**
- Create: `src/Edit/Map.elm`
- Test: `tests/EditMapTest.elm`

**Interfaces:**
- Produces:
  - `type alias Edit = { offset : Int, removed : String, inserted : String }`
  - `charDelta : Edit -> Int`
  - `lineDelta : Edit -> Int`

- [ ] **Step 1: Write the failing test**

Create `tests/EditMapTest.elm`:

```elm
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: FAIL — module `Edit.Map` does not exist / `EM.charDelta` not found.

- [ ] **Step 3: Write minimal implementation**

Create `src/Edit/Map.elm`:

```elm
module Edit.Map exposing
    ( Edit
    , charDelta, lineDelta
    )

{-| Fast, pure metadata shift for RL-sync. See mydocs/diff-update-map-strategy.md.

@docs Edit
@docs charDelta, lineDelta

-}


{-| A single edit against the pre-edit document (CodeMirror-style change).
-}
type alias Edit =
    { offset : Int
    , removed : String
    , inserted : String
    }


{-| Net change in character count produced by the edit.
-}
charDelta : Edit -> Int
charDelta edit =
    String.length edit.inserted - String.length edit.removed


{-| Net change in newline count produced by the edit.
-}
lineDelta : Edit -> Int
lineDelta edit =
    countNewlines edit.inserted - countNewlines edit.removed


countNewlines : String -> Int
countNewlines s =
    List.length (String.indexes "\n" s)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add src/Edit/Map.elm tests/EditMapTest.elm
git commit -m "feat(edit): Edit type and char/line delta helpers"
```

---

### Task 2: ID shift helpers

**Files:**
- Modify: `src/Edit/Map.elm`
- Test: `tests/EditMapTest.elm`

**Interfaces:**
- Produces:
  - `shiftBlockId : Int -> String -> String` — bump the leading line-number component of a `"L-I"` block id by `dL`.
  - `shiftExprId : Int -> String -> String` — bump the line-number component of an `"e-L.T"` expression id by `dL`.

- [ ] **Step 1: Write the failing test**

Add this `describe` block to the `suite` list in `tests/EditMapTest.elm` (insert after the `"deltas"` block, before the closing `]`):

```elm
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: FAIL — `EM.shiftBlockId` / `EM.shiftExprId` not found.

- [ ] **Step 3: Write minimal implementation**

In `src/Edit/Map.elm`, add `shiftBlockId` and `shiftExprId` to the `exposing` list:

```elm
module Edit.Map exposing
    ( Edit
    , charDelta, lineDelta
    , shiftBlockId, shiftExprId
    )
```

and append these functions:

```elm
{-| Bump the leading line-number component of a block id ("L-I") by dL.
Leaves the id unchanged if it is not of the expected form.
-}
shiftBlockId : Int -> String -> String
shiftBlockId dL id =
    case String.split "-" id of
        lineStr :: rest ->
            case String.toInt lineStr of
                Just l ->
                    String.join "-" (String.fromInt (l + dL) :: rest)

                Nothing ->
                    id

        _ ->
            id


{-| Bump the line-number component of an expression id ("e-L.T") by dL.
Leaves the id unchanged if it is not of the expected form.
-}
shiftExprId : Int -> String -> String
shiftExprId dL id =
    if String.startsWith "e-" id then
        case String.split "." (String.dropLeft 2 id) of
            lineStr :: rest ->
                case String.toInt lineStr of
                    Just l ->
                        "e-" ++ String.fromInt (l + dL) ++ "." ++ String.join "." rest

                    Nothing ->
                        id

            _ ->
                id

    else
        id
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: PASS (10 tests total).

- [ ] **Step 5: Commit**

```bash
git add src/Edit/Map.elm tests/EditMapTest.elm
git commit -m "feat(edit): block/expression id shift helpers"
```

---

### Task 3: Expression-meta mapping

**Files:**
- Modify: `src/Edit/Map.elm`
- Test: `tests/EditMapTest.elm`

**Interfaces:**
- Produces:
  - `mapExprMeta : (V3.Types.ExprMeta -> V3.Types.ExprMeta) -> V3.Types.Expression -> V3.Types.Expression` — apply `f` to every `ExprMeta` in an expression tree (recursing into `Fun` and `ExprList` children).

- [ ] **Step 1: Write the failing test**

Add imports at the top of `tests/EditMapTest.elm` (below the existing imports):

```elm
import V3.Types exposing (Expr(..))
```

Add this `describe` block to the `suite` list (before the closing `]`):

```elm
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: FAIL — `EM.mapExprMeta` not found.

- [ ] **Step 3: Write minimal implementation**

In `src/Edit/Map.elm`, add the import and expose `mapExprMeta`:

```elm
module Edit.Map exposing
    ( Edit
    , charDelta, lineDelta
    , shiftBlockId, shiftExprId
    , mapExprMeta
    )

import V3.Types exposing (Expr(..), ExprMeta, Expression)
```

(Place the `import` line after the module declaration / docstring, matching the file's existing layout.) Append:

```elm
{-| Apply f to every ExprMeta in an expression tree.
-}
mapExprMeta : (ExprMeta -> ExprMeta) -> Expression -> Expression
mapExprMeta f expr =
    case expr of
        Text s m ->
            Text s (f m)

        Fun name args m ->
            Fun name (List.map (mapExprMeta f) args) (f m)

        VFun name s m ->
            VFun name s (f m)

        ExprList indent args m ->
            ExprList indent (List.map (mapExprMeta f) args) (f m)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: PASS (12 tests total).

- [ ] **Step 5: Commit**

```bash
git add src/Edit/Map.elm tests/EditMapTest.elm
git commit -m "feat(edit): mapExprMeta tree walk"
```

---

### Task 4: Block shift + forest application

**Files:**
- Modify: `src/Edit/Map.elm`
- Test: `tests/EditMapTest.elm`

**Interfaces:**
- Consumes: `Edit`, `charDelta`, `lineDelta`, `shiftBlockId`, `shiftExprId`, `mapExprMeta` (Tasks 1-3).
- Produces:
  - `applyEditToForest : Edit -> List (Tree V3.Types.ExpressionBlock) -> List (Tree V3.Types.ExpressionBlock)` — shift all metadata in the forest for one edit.

**Per-block rule** (with `P = edit.offset`, `dC = charDelta edit`, `dL = lineDelta edit`):

| Case | Condition | Action |
|------|-----------|--------|
| Above | `meta.end < P` | unchanged |
| Containing | `meta.begin <= P && P <= meta.end` | `end += dC`, `contentEnd += dC`, `numberOfLines += dL` |
| Below | `meta.begin > P` | shift `position/begin/end/contentBegin/contentEnd += dC`, `lineNumber/bodyLineNumber += dL`, bump ids (only when `dL /= 0`), bump expression ids in `body` (only when `dL /= 0`) |

(Boundary comparisons are strict — an edit exactly at a block's `begin`/`end` is Containing, matching reparse. The original `<=`/`>=` draft was corrected during implementation; the Task 6 oracle pins both boundaries.)

- [ ] **Step 1: Write the failing test**

Add imports to `tests/EditMapTest.elm`:

```elm
import Either
import RoseTree.Tree as Tree exposing (Tree)
import Scripta
import Scripta.Internal as Internal
import V3.Types exposing (ExpressionBlock)
```

Add these helpers and `describe` block. The helpers go above `suite`; the `describe` goes in the `suite` list:

```elm
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
```

```elm
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
```

Note: the literal offsets (`10`, `13`) assume the parser assigns `begin = 0` to the first block. If Step 2 shows different absolute values, update the two expected tuples to `(before.begin, before.end)` and `(before.begin + 1, before.end + 1)` read from the actual `beforeGhi` — the invariant under test is the **+1 shift**, not the absolute numbers.

- [ ] **Step 2: Run test to verify it fails**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: FAIL — `EM.applyEditToForest` not found.

- [ ] **Step 3: Write minimal implementation**

In `src/Edit/Map.elm`, expose `applyEditToForest` and add imports:

```elm
module Edit.Map exposing
    ( Edit
    , charDelta, lineDelta
    , shiftBlockId, shiftExprId
    , mapExprMeta
    , applyEditToForest
    )

import Either
import RoseTree.Tree as Tree exposing (Tree)
import V3.Types exposing (Expr(..), ExprMeta, Expression, ExpressionBlock)
```

(Merge the `V3.Types` import with the one added in Task 3 — a single import line exposing `Expr(..), ExprMeta, Expression, ExpressionBlock`.) Append:

```elm
{-| Apply one edit's metadata shift across the whole forest.
-}
applyEditToForest : Edit -> List (Tree ExpressionBlock) -> List (Tree ExpressionBlock)
applyEditToForest edit forest =
    let
        p =
            edit.offset

        dC =
            charDelta edit

        dL =
            lineDelta edit
    in
    if p < 0 || (dC == 0 && dL == 0) then
        forest

    else
        List.map (Tree.mapValues (shiftBlock p dC dL)) forest


shiftBlock : Int -> Int -> Int -> ExpressionBlock -> ExpressionBlock
shiftBlock p dC dL block =
    let
        m =
            block.meta
    in
    if m.end < p then
        -- entirely above the edit
        block

    else if m.begin > p then
        -- entirely below the edit: shift offsets, line numbers, ids
        { block
            | meta =
                { m
                    | position = m.position + dC
                    , begin = m.begin + dC
                    , end = m.end + dC
                    , contentBegin = m.contentBegin + dC
                    , contentEnd = m.contentEnd + dC
                    , lineNumber = m.lineNumber + dL
                    , bodyLineNumber = m.bodyLineNumber + dL
                    , id =
                        if dL == 0 then
                            m.id

                        else
                            shiftBlockId dL m.id
                }
            , body =
                if dL == 0 then
                    block.body

                else
                    shiftBodyIds dL block.body
        }

    else
        -- the edit lands inside this block: grow it, do not reparse content
        { block
            | meta =
                { m
                    | end = m.end + dC
                    , contentEnd = m.contentEnd + dC
                    , numberOfLines = m.numberOfLines + dL
                }
        }


shiftBodyIds : Int -> Either.Either String (List Expression) -> Either.Either String (List Expression)
shiftBodyIds dL body =
    Either.map
        (List.map (mapExprMeta (\meta -> { meta | id = shiftExprId dL meta.id })))
        body
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: PASS. If the first test fails only on the absolute tuple values, correct them per the note in Step 1 and re-run.

- [ ] **Step 5: Commit**

```bash
git add src/Edit/Map.elm tests/EditMapTest.elm
git commit -m "feat(edit): shiftBlock and applyEditToForest"
```

---

### Task 5: Public API in `Scripta`

**Files:**
- Modify: `src/Scripta.elm`
- Test: `tests/EditMapTest.elm`

**Interfaces:**
- Consumes: `Edit.Map.Edit`, `Edit.Map.applyEditToForest`; `Scripta.Internal.Document(..)`.
- Produces:
  - `Scripta.Edit` (re-exported type alias)
  - `Scripta.applyEdit : Edit -> Document -> Document`
  - `Scripta.applyEdits : List Edit -> Document -> Document` (left fold of `applyEdit`)

- [ ] **Step 1: Write the failing test**

Add this `describe` block to the `suite` list in `tests/EditMapTest.elm`:

```elm
        , describe "Scripta.applyEdit"
            [ test "applyEdit shifts the document forest like applyEditToForest" <|
                \_ ->
                    let
                        edit =
                            { offset = 6, removed = "", inserted = "X" }

                        viaDoc =
                            Scripta.applyEdit edit (Scripta.parse Scripta.defaultOptions threePara)
                                |> forestOf
                                |> blocksOf
                                |> List.map (\b -> ( b.meta.begin, b.meta.end ))

                        viaForest =
                            EM.applyEditToForest edit (parseForest threePara)
                                |> blocksOf
                                |> List.map (\b -> ( b.meta.begin, b.meta.end ))
                    in
                    Expect.equal viaDoc viaForest
            , test "applyEdits folds two edits in order" <|
                \_ ->
                    let
                        e1 =
                            { offset = 6, removed = "", inserted = "X" }

                        e2 =
                            { offset = 7, removed = "", inserted = "Y" }

                        viaList =
                            Scripta.applyEdits [ e1, e2 ] (Scripta.parse Scripta.defaultOptions threePara)
                                |> forestOf
                                |> blocksOf
                                |> List.map (\b -> ( b.meta.begin, b.meta.end ))

                        viaFold =
                            Scripta.applyEdit e2 (Scripta.applyEdit e1 (Scripta.parse Scripta.defaultOptions threePara))
                                |> forestOf
                                |> blocksOf
                                |> List.map (\b -> ( b.meta.begin, b.meta.end ))
                    in
                    Expect.equal viaList viaFold
            ]
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: FAIL — `Scripta.applyEdit` / `Scripta.applyEdits` not found.

- [ ] **Step 3: Write minimal implementation**

In `src/Scripta.elm`, add to the `exposing` list (in the "Documents and rendering" group): `Edit, applyEdit, applyEdits`. The exposing block becomes:

```elm
    , Document
    , Edit
    , Event(..), Output
    , parse, reparse, render, compile, mapEvent
    , applyEdit, applyEdits
```

Add the corresponding `@docs` lines in the module docstring under `# Documents and rendering`:

```
@docs Document, Edit
@docs Event, Output
@docs parse, reparse, render, compile, mapEvent
@docs applyEdit, applyEdits
```

Add the import:

```elm
import Edit.Map
```

Add the type re-export (near the `Document` alias):

```elm
{-| A single source edit: a character range `removed` replaced by `inserted`,
starting at character `offset` in the pre-edit document.
-}
type alias Edit =
    Edit.Map.Edit
```

Add the functions (after `reparse`):

```elm
{-| Apply one edit's fast metadata shift to a Document, keeping the RL-sync
map (data-begin/data-end/data-lines/id) valid without reparsing content.

This is the high-frequency path (run per keystroke). It does NOT refresh
block content or rendering — use `reparse` on a longer debounce for that.
-}
applyEdit : Edit -> Document -> Document
applyEdit edit (Document data) =
    Document { data | forest = Edit.Map.applyEditToForest edit data.forest }


{-| Apply a queue of edits in order (each in the coordinate space of the
document produced by the previous edit).
-}
applyEdits : List Edit -> Document -> Document
applyEdits edits doc =
    List.foldl applyEdit doc edits
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npx elm-test tests/EditMapTest.elm`
Expected: PASS.

Also confirm the whole suite and a production build still compile:

Run: `npx elm-test && elm make src/Main.elm --output=/dev/null`
Expected: all tests pass; `elm make` succeeds.

- [ ] **Step 5: Commit**

```bash
git add src/Scripta.elm tests/EditMapTest.elm
git commit -m "feat(scripta): expose applyEdit/applyEdits public API"
```

---

### Task 6: Oracle — shift equals reparse for structure-preserving edits

**Files:**
- Create: `tests/EditOracleTest.elm`

**Interfaces:**
- Consumes: `Scripta.applyEdit`, `Scripta.applyEdits`, `Scripta.parse`, `Scripta.Internal.Document(..)`.

This is the acceptance test. For a structure-preserving edit transforming `base` into `edited`, the block-level metadata of `applyEdit edit (parse base)` must equal that of `parse edited`, block for block.

- [ ] **Step 1: Write the failing test**

Create `tests/EditOracleTest.elm`:

```elm
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
(position, begin, end, contentBegin, contentEnd, lineNumber, bodyLineNumber,
numberOfLines, id)
-}
metaTuples : Internal.Document -> List ( ( Int, Int, Int ), ( Int, Int, Int, Int ), ( Int, String ) )
metaTuples doc =
    forestOf doc
        |> List.concatMap flattenTree
        |> List.map
            (\b ->
                ( ( b.meta.position, b.meta.begin, b.meta.end )
                , ( b.meta.contentBegin, b.meta.contentEnd, b.meta.lineNumber, b.meta.bodyLineNumber )
                , ( b.meta.numberOfLines, b.meta.id )
                )
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
```

- [ ] **Step 2: Run test to verify it fails or passes**

Run: `npx elm-test tests/EditOracleTest.elm`
Expected: the module compiles and runs. If any case fails, the failure diff shows exactly which block-level field diverged between shift and reparse — debug `shiftBlock` against the per-block rule before changing the test. (Do not weaken an assertion to make it pass; a real divergence is a bug in the shift.)

- [ ] **Step 3: Fix any divergence found**

If a case fails, the likely culprits are: (a) the containing-vs-below boundary (`>=` vs `>`), (b) a field omitted from the below-block shift (e.g. `position` or `bodyLineNumber`), or (c) `contentBegin/contentEnd` handling. Adjust `shiftBlock` in `src/Edit/Map.elm` to satisfy the per-block rule in Task 4, then re-run.

- [ ] **Step 4: Run the full test suite**

Run: `npx elm-test`
Expected: all suites pass (`EditMapTest`, `EditOracleTest`, and the pre-existing `ScriptaTest`, `ScriptaDocumentTest`, `ETeXTest`, …).

- [ ] **Step 5: Commit**

```bash
git add tests/EditOracleTest.elm
git commit -m "test(edit): oracle — shift metadata equals reparse"
```

---

### Task 7: Expression-id oracle for below-blocks

**Files:**
- Modify: `tests/EditOracleTest.elm`

**Interfaces:**
- Consumes: same as Task 6.

When a line is added above a block (`dL /= 0`), that block's expression ids must be bumped to match what reparse produces. This task pins that, since Task 6 only checks block-level metadata.

- [ ] **Step 1: Write the failing/confirming test**

Add this helper above `suite` in `tests/EditOracleTest.elm`:

```elm
import Either


exprIdsOf : Internal.Document -> List String
exprIdsOf doc =
    forestOf doc
        |> List.concatMap flattenTree
        |> List.concatMap
            (\b ->
                case b.body of
                    Either.Right exprs ->
                        List.concatMap collectIds exprs

                    Either.Left _ ->
                        []
            )


collectIds : V3.Types.Expr V3.Types.ExprMeta -> List String
collectIds expr =
    case expr of
        V3.Types.Text _ m ->
            [ m.id ]

        V3.Types.Fun _ args m ->
            m.id :: List.concatMap collectIds args

        V3.Types.VFun _ _ m ->
            [ m.id ]

        V3.Types.ExprList _ args m ->
            m.id :: List.concatMap collectIds args
```

Add this test to the `suite` list. The base has a bold expression in the second paragraph; inserting a line in the first paragraph shifts the second paragraph's line number, so its expression ids must bump:

```elm
        , test "expression ids in a below-block bump to match reparse when a line is added (dL = 1)" <|
            \_ ->
                let
                    base =
                        "intro\n\nsome [b bold] text"

                    -- insert "\nmore" at offset 5 (end of "intro"):
                    -- "intro\nmore\n\nsome [b bold] text"
                    edit =
                        { offset = 5, removed = "", inserted = "\nmore" }

                    edited =
                        "intro\nmore\n\nsome [b bold] text"

                    shifted =
                        Scripta.applyEdit edit (Scripta.parse Scripta.defaultOptions base)

                    reparsed =
                        Scripta.parse Scripta.defaultOptions edited
                in
                Expect.equal (exprIdsOf shifted) (exprIdsOf reparsed)
```

- [ ] **Step 2: Run the test**

Run: `npx elm-test tests/EditOracleTest.elm`
Expected: PASS. If it fails, inspect whether `[b bold]` parses to the expected `Fun`/`Text` ids; if the bold syntax differs, replace `[b bold]` with a known-good inline element from `tests/ScriptaTest.elm` and recompute `edited`. The invariant — shifted expression ids equal reparsed expression ids — must hold.

- [ ] **Step 3: Run the full suite**

Run: `npx elm-test && elm make src/Main.elm --output=/dev/null`
Expected: all pass; build succeeds.

- [ ] **Step 4: Commit**

```bash
git add tests/EditOracleTest.elm
git commit -m "test(edit): expression-id oracle for below-blocks"
```

---

## Self-Review

**Spec coverage:**
- §1 Scope & contract → Tasks 4 (shiftBlock partition), 6 (block-level shift==reparse), 7 (expression-id shift==reparse). `applyEdit` totality (never errors) → Task 4 negative-offset + no-op tests, return type `Document`.
- §2 Data types (`Edit`, derived deltas) → Task 1.
- §3 Algorithm tiers (dL==0 cheap path, dL≠0 id/expr path, no-op) → Task 4 (`dL == 0` branches in `shiftBlock`/`applyEditToForest`) + Task 1/4 no-op tests. (Skip-prefix binary search is intentionally omitted as a deferred micro-optimization — the full `mapValues` walk is O(N) integer comparisons; noted in strategy §Out-of-scope. The savings come from not reparsing, not from skipping the walk.)
- §4 Module placement / public API → Tasks 1-5.
- §5 Error handling (total, negative-offset guard, no source validation, contentBegin-of-header approximation) → Task 4 (guard + branches). The contentBegin approximation is honored by leaving the containing block's `contentBegin`/`position`/`begin`/`lineNumber` untouched.
- §6 Testing (oracle, units, multi-edit fold) → Tasks 6, 7 (oracle + fold), Tasks 1-5 (units). The "naive per-edit fold as second oracle" is realized by `applyEdits` being literally `List.foldl applyEdit`, cross-checked in Task 5's fold test and Task 6's two-edit case.

**Placeholder scan:** No TBD/TODO; every code step contains complete code; every run step has an exact command and expected result.

**Type consistency:** `Edit` fields `offset/removed/inserted` used identically in Tasks 1, 4, 5, 6, 7. `applyEditToForest : Edit -> List (Tree ExpressionBlock) -> List (Tree ExpressionBlock)` defined in Task 4, consumed unchanged in Task 5. `shiftBlockId`/`shiftExprId`/`mapExprMeta` signatures defined in Tasks 2-3 and used unchanged in Task 4. `forestOf`/`flattenTree`/`blocksOf`/`metaTuples` helper names consistent within each test module.

## Known approximations (carried from the spec, by design — not bugs)

- The **edited (containing) block's interior expression metadata is left stale** until the next `reparse`. The oracle tests therefore assert block-level metadata for all blocks, and expression-level metadata only for **below**-blocks (Task 7), never for the edited block.
- **Structure-changing edits** (blank line splitting a block, a heading marker created/removed) are out of scope for exactness; offsets stay numerically shifted and `reparse` is the authority. No task tests structural exactness because the contract does not promise it.
