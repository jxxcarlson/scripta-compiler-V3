# Parser refactor (branch `refactor-parser`)

Simplification of the `Parser.*` modules, in three steps: remove dead code,
collapse duplicate branches, fix latent bugs. All 255 tests pass (250 existing + 5 new).
Diff: 319 insertions, 549 deletions; `src/Parser` went from ~1,975 to 1,700 lines of code.

Tests must be run with `npx elm-test@0.19.2-0`. The global `elm-test` is
0.19.1-revision7, which rejects `elm.json`'s `elm-version: 0.19.2`.

## Verification

Besides the unit tests, a differential check compared the forest output
(`Parser.Forest.parse`, `parseToForestWithAccumulator`, and per-line
`Parser.Expression.parse`) of HEAD against the branch over:

- all 21 `.scripta` files in the repo,
- the same files with trailing blank lines stripped,
- 17 synthetic edge cases.

After steps 1 and 2 the output was byte-identical to HEAD. (An early version of
the `Line.classify` rewrite counted tabs as indentation; the differential check caught this
and it was reverted to count spaces only.) After step 3 the only differences were
the intended fixes.

## Step 1: dead code removed

- `Parser/Expression.elm`: `State` fields `messages`, `step`, `numberOfTokens`
  (messages were built but never returned); `prependMessage`, `dummyTokenIndex`.
- `Parser/PrimitiveBlock.elm`: `State` fields `inBlock` (duplicated
  `currentBlock /= Nothing`), `indent`, `inVerbatim` (written, never read);
  `isVerbatimLine`; the unreachable "commit existing block" branch in `createBlock`.
- `Parser/Line.elm`: unused `prefix` field.
- `Parser/Tokenizer.elm`: unused `toString`, and `indexOf` (callers already had the meta).
- `Parser/Pipeline.elm`: ignored first argument of `parseListItems`.
- `Parser/Forest.elm`: three copies of the no-op
  `{ initialData_ | maxLevel = initialData_.maxLevel }`.

## Step 2: duplicate branches collapsed

- `Parser/Expression.elm`
  - `pushOrCommit`: 8 branches → 3.
  - `reduceRestOfTokens`: identical `LB`/`DLB` and `MathToken`/`CodeToken` branches
    share `reduceSplit`; redundant `S` case removed.
  - `recoverFromError`: branches use `resumeAfter` / `stopWith`.
  - `parseToState` / `parseTokenListToState` folded into `parse`.
- `Parser/Match.elm`: uses `List.Extra.takeWhile` instead of a local copy;
  `splitMatched` replaces both `Match.split` and the body of `Expression.splitTokens`.
- `Parser/Tokenizer.elm`: two identical `nextStep` branches merged (the extra
  `setIndex` was a no-op); `textParser` / `mathTextParser` / `codeTextParser`
  share `textParserStoppingAt`.
- `Parser/PrimitiveBlock.elm`
  - `nextStep` advances the line once; handlers no longer repeat that bookkeeping.
  - List coalescing is two rules in `addBodyLine` (with `inspectListKind`)
    instead of a six-arm `case`.
  - `markdownHeading` replaces three `#`/`##`/`###` branches.
  - `finalize`: duplicate `Paragraph` / `Ordinary "section"` branches merged.
  - Section level computed with a `Maybe` pipeline (preserving the original string).
- `Parser/Pipeline.elm`: `parseSingleItem` shared by `item` and `numbered`.
- `Parser/Forest.elm`: `parseWith` replaces the parse chain repeated three times.

## Step 3: bugs fixed (test written first, seen failing)

1. **Last block had no id.** If the input did not end with a blank line, the
   end-of-input path finalized the block without `setBlockId`, leaving `id = ""`.
   This affected one repo file and any editor text without a trailing newline.
   Block ids become HTML ids (`Render/Utility.elm`), which editor sync depends on.
   Fix: end of input goes through `commitBlock`. The old "assume input ends with a
   blank line" TODO is removed.
   Test: `tests/Parser/PrimitiveBlockTest.elm`, "block ids".

2. **Backtick code followed by `$…$` inside function arguments was mis-parsed.**
   `segLength` always searched for a `$` delimiter, even for code segments, so
   `` [b `x` $y$ z] `` produced a bogus `VFun "math" " z"`. Fix: math/code segments
   use `splitTokens`, since `Match.match` already picks the right delimiter.
   `splitTokensWithSegment` and `segLength` were deleted.
   Test: `tests/Parser/ExpressionParserTest.elm`, "code and math segments inside
   function arguments".

3. **Table cell expression ids always used line 0.** `Parser.Table.parseTable 0`
   gave every cell an id of the form `e-0.N`. `Edit/Map.elm` shifts the line part of
   `e-L.T` ids during edits, so table ids were wrong after an edit. Fix: row `k` uses
   `bodyLineNumber + k`, its actual source line.
   Test: `tests/Parser/PipelineTest.elm`, "table expression ids".

## Known issues left alone

- Cells in the same table row still share expression ids (e.g. `e-3.0` twice),
  because token numbering restarts per cell. Fixing this needs a change to the
  `e-L.T` id format that `Edit/Map.elm` parses.
- `[f …]` whose arguments start with a space yields a leading `Text ""`.
  The new tests expect this current behavior.
- `Expression.elm`, `Pipeline.elm`, `Match.elm` were not `elm-format` clean
  before this work; they were not reformatted, to keep the diff readable.
- `tools/toLaTeXExport/Worker.elm` fails with `AMBIGUOUS IMPORT` (duplicate
  `Render.*` modules in its source directories). This also fails on HEAD.
  `tools/benchmark` compiles.

## Possible next steps (structural)

- **One walk in `Forest.elm`:** `forestStructureMatches`,
  `allChangedBlocksAreAccIndependent`, and `spliceForest` walk the same pair of trees.
  Replace them with one walk that returns `Maybe` forest. Also make
  `parseToForestWithAccumulator` and `parseIncrementally` share one implementation.
- **Quadratic expression parser:** `getToken` uses `List.Extra.getAt tokenIndex`,
  and `isReducible` re-reverses the stack every step. Consume tokens from the head
  of the list instead. Error recovery (`tokenIndex = meta.index + 1`) becomes a drop.
- **List logic in one place:** continuation lines are merged both in
  `PrimitiveBlock.appendToLastListItem` and in `Pipeline.groupListItems`, and the
  `"- "` / `". "` prefix test exists three times.
- **Drop `Parser.Symbol`:** it is a third view of `Token`, used only for bracket
  depth in `Match`. Match on `Token` with a `bracketValue : Token -> Int`.
- **Tables:** stop routing `table` through `verbatimNames` and then relabelling it
  `Ordinary` in `Pipeline.transformBlockHeading`.
