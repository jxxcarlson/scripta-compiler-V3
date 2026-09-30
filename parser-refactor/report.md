# Parser refactor (branch `refactor-parser`)

Simplification of the `Parser.*` modules. Steps 1–3 removed dead code,
collapsed duplicate branches, and fixed latent bugs (319 insertions, 549 deletions;
`src/Parser` went from ~1,975 to 1,700 lines of code). Step 4 made the
expression parser linear-time and stack-safe. Step 5 replaced the three tree walks
of incremental reparse with one. Step 6 made incremental reparse agree
exactly with a fresh parse. Step 7 did the smaller cleanups (lists, `TokenType`,
tables). Step 8 fixed `end` offsets of indented blocks. All 281 tests pass
(250 original + 31 new).
The remaining work is tracked in `parser-refactor/todo.md`.

Tests must be run with `npx elm-test@0.19.2-0`. The global `elm-test` is
0.19.1-revision7, which rejects `elm.json`'s `elm-version: 0.19.2`.

## Verification

Besides the unit tests, a differential check compared the forest output
(`Parser.Forest.parse`, `parseToForestWithAccumulator`, and per-line
`Parser.Expression.parse`) of HEAD against the branch over:

- all 21 `.scripta` files in the repo,
- the same files with trailing blank lines stripped,
- 17 synthetic edge cases (26 since step 4, which added mid-line error-recovery cases),
- since step 5, 68 incremental reparses: `parseIncrementallySkipAcc` after a no-op,
  a plain word change, an added `[ref …]`, and a paragraph inserted at the top.

The harness is `parser-refactor/diff-harness/run-diff.sh [REF]`; see
`parser-refactor/scripta-files-for-diff-testing.md`.

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

## Step 4: linear-time expression parser (to-do item #1)

The expression parser now runs in linear time and no longer crashes on long
lines, and its output hasn't changed.

Before and after (median ms to parse one line of the given shape, n = 2000;
from `parser-refactor/bench/run-bench.sh`):

| shape | before | after |
|---|---:|---:|
| `a [b x] ` × n | 130 | 25 |
| `[b ` + `a [i x] ` × n + `]` | 3048 | 25 |
| `[b ` + `x [i y] ` × n (unclosed) | 2880 | 26 |
| `$x$ ` × n | 88 | 13 |
| `[b ` + `$x$ ` × n + `]` | 1526 | 13 |

Time now roughly doubles when the input doubles, tested up to 128 KB lines.
Timings for real documents change much less, since most paragraphs are
short; full documents were not benchmarked.

The fixes, all in `Parser/Expression.elm` and `Parser/Match.elm`:

- **Tokens are popped from the front of the list.** Previously each step looked
  up `getAt tokenIndex`, walking from the start every time. Error recovery now
  resumes by dropping tokens from the full list, and only on errors.
- **The expensive reducibility check is skipped when it can't succeed.** The
  parser tracks bracket depth, and only calls `isReducible` when depth is 0 and
  the top token is `]`, `$` or a backtick. The comment on `tokensAreReducible`
  explains why that precheck can't change the result.
- **Segment matching converts tokens only as far as it needs to.** The new
  `Match.matchBy` / `splitMatchedBy` convert tokens to symbols while walking the
  segment, instead of converting the whole remainder for every argument.

Stack overflows fixed: HEAD crashed with `RangeError: Maximum call stack size
exceeded` on lines of about 32 KB. `fixup` became `List.map trimFirstArg`,
`reduceRestOfTokens` became an accumulator loop, and `hasReducibleArgs` absorbed
`reducibleAux` so it calls itself directly in tail position.

Verification:

- The output comparison (`run-diff.sh`) reports `IDENTICAL` to HEAD, including
  9 new cases with errors mid-line, added because the resume logic changed.
- 257 tests pass. Two new long-line tests in
  `tests/Parser/ExpressionParserTest.elm` fail on the old parser with the stack
  overflow.

## Step 5: one tree walk for incremental reparse (to-do item #2)

`parseIncrementallySkipAcc` decides whether it can reuse the previous
accumulator. Before, it walked the old and new forests three times, with six
functions: `forestStructureMatches`, `allChangedBlocksAreAccIndependent`,
`spliceForest` and a per-tree helper for each. Now one function,
`spliceIfAccIndependent`, does it in a single walk:

- It returns `Just` the spliced forest exactly when the old check passed, and
  otherwise `Nothing`, stopping at the first mismatch.
- It loops over sibling blocks with an accumulator, so stack use grows with
  nesting depth, not document length.
- `parseToForestWithAccumulator`, `parseIncrementally` and the fallback path
  share an `accumulate` helper (filter, then the accumulator pass).

Verification:

- The diff harness gained 68 incremental reparses: 28 take the skip path and 40
  don't, identical to HEAD.
- 8 new tests in `tests/Parser/ForestTest.elm` pin down when the accumulator pass
  is skipped: plain text change, change in a code block, unchanged source (skip),
  and added reference, section title change, inserted block, block kind change
  (no skip). They pass on both the old and the new code.

### Bugs found during step 5 (not fixed there, see to-do #6)

Both were in HEAD; step 5 kept the behavior exactly. Probe tests confirmed each one.

- **The skip path keeps stale positions.** An unchanged block is reused as the
  *old* block, with its old `lineNumber`, `id`, `begin`/`end` and expression ids.
  Reparsing `"alpha\n\nbeta"` into `"alpha\nmore\n\nbeta"` leaves the second
  block with line 2, id `"2-1"` and begin 7; a fresh parse gives line 3, `"3-1"`
  and 12. Any edit that changes a paragraph's length does this to every block
  below it. Calling `Scripta.applyEdit` before `reparse` hides it, but
  `mydocs/diff-update-map-strategy.md` treats `reparse` as the step that
  corrects `applyEdit`'s approximations, and on this path it corrects nothing.
- **The expression cache reuses old expression ids when a block moves**, even when
  the accumulator pass runs. The cache is keyed by source text, so after inserting
  a section at the top, the moved blocks keep `e-0.0`, `e-2.0`, `e-2.2` instead
  of `e-3.0`, `e-5.0`, `e-5.2`.

## Step 6: incremental reparse equals a fresh parse (to-do item #6)

The two bugs found during step 5, plus two more found by the new corpus oracle,
are fixed. An incremental reparse (`Scripta.reparse`) now gives exactly the
forest and accumulator that a fresh parse of the same text gives.

- **Expression cache:** it now records each body's line number; on a hit,
  expression ids are shifted to the block's new line.
- **Skip path:** the previous accumulator is reused only if every block keeps its
  id, because the accumulator stores block and expression ids. Unchanged blocks
  take fresh offsets from the new parse.
- **Removed accumulator content:** a changed block's old version must also be
  accumulator-independent (deleting a footnote or `[index …]` used to leave
  stale entries).
- **Header continuation lines** (`| width:300`, `| label:foo`) are now part of
  `meta.sourceText`. Before, edits to them went undetected, and those blocks had
  wrong `end` / `contentBegin` / `contentEnd`.

Cost: Enter inside a plain paragraph now runs the full accumulator pass
(~5.4 ms instead of ~2.6 ms on the 2,850-line `mlttv1.scripta`; a cold parse
is ~46 ms).

Verification: 11 oracle unit tests (`IncrementalOracleTest.elm`), 2 new
`PrimitiveBlockTest` cases, and `run-oracle.sh`, which checks 2,604 generated
edits over all repo documents with 0 mismatches. Details are in
`parser-refactor/todo.md`, item 6.

## Step 7: smaller cleanups (to-do items #3, #4, #5)

- **#3, lists in one place:** new `Parser/ListItem.elm` holds the list syntax
  (`kind`, `stripPrefix`), used by `PrimitiveBlock` and `Pipeline`. List blocks
  keep raw lines, and only `Pipeline.groupListItems` merges continuation lines.
  This also fixed list `sourceText`/`end`, which were computed from merged lines.
- **#4, `TokenType` removed instead of `Symbol`:** after step 4, `Symbol` costs
  little and gives `Match` a small alphabet for its tests. The redundant copy was
  `Tokenizer.TokenType` / `type_`, now replaced by pattern matches.
- **#5, tables are ordinary blocks:** `table` moved from `verbatimNames` to
  `ordinaryNames`, which removes `Pipeline.transformBlockHeading`.

Verification: all 279 tests pass. `run-diff.sh` against the previous commit
differs only in the two synthetic list inputs with continuation lines (their
`sourceText`/`end`). `run-oracle.sh` finds 0 mismatches in 2,604 edits.

### Bug found during step 7 (to-do #7)

Indented multi-line blocks have `end`/`contentEnd` computed from dedented
`sourceText`, so they fall short by the indentation width per line. A span check
over the corpus found 43 such blocks.

## Step 8: block offsets for indented blocks (to-do item #7)

For an indented multi-line block, `end` and `contentEnd` were computed from
`sourceText`, whose body lines have the indentation removed, so they fell short by
the indentation width for every line after the first. `PrimitiveBlock` now tracks
`end` from the raw line positions as lines are added. `sourceText` is unchanged
(still dedented).

A new check, `parser-refactor/diff-harness/run-span-check.sh`, verifies for every
block in every repo document that `begin`/`end` cut exactly the block's source
lines: 0 mismatches in 2,214 blocks, against 43 before the fix. All 281 tests pass
(2 new), and the reparse oracle still reports 0 mismatches.

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

- ~~**One walk in `Forest.elm`**~~: done, see Step 5.
- ~~**Quadratic expression parser**~~: done, see Step 4.
- ~~**Stale position metadata after incremental reparse**~~: done, see Step 6.
- ~~**List logic in one place**~~: done, see Step 7.
- ~~**Drop `Parser.Symbol`**~~: dropped `TokenType` instead, see Step 7.
- ~~**Tables**~~: done, see Step 7.
- ~~**Indented blocks' `end` offsets**~~: done, see Step 8.
