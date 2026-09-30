# Parser refactor: to-do

Remaining structural work on branch `refactor-parser`, in the agreed order.
Line numbers are as of commit `a8cd639`.

## 1. ~~Fix the quadratic expression parser~~ (done)

Three sources of quadratic time in `Parser/Expression.elm` and `Parser/Match.elm`:

- `getToken` used `List.Extra.getAt tokenIndex` on every step. Now the state
  keeps the remaining tokens and pops the head; error recovery resumes with
  `List.drop (meta.index + 1) allTokens`.
- `tokensAreReducible` converted and reversed the whole stack after every push.
  Now the state tracks bracket depth, and `isReducible` runs only when the stack
  could be reducible (depth 0 and a closing `]`, `$` or backtick on top). When
  that precheck fails, `isReducible` would have returned False anyway.
- `splitTokens` converted the whole remainder to symbols for every function
  argument. `Match.matchBy` / `splitMatchedBy` now convert tokens only as far as
  the segment extends.

Stack overflows on long lines were also fixed. `fixup` (now `List.map trimFirstArg`),
`reduceRestOfTokens` (accumulator loop) and `hasReducibleArgs` (merged with
`reducibleAux`) are now self tail-recursive or stack-safe. Before this, a line of
about 32 KB crashed with `RangeError: Maximum call stack size exceeded`.

Verified with `run-diff.sh` (IDENTICAL, including 9 new mid-line error-recovery
cases) and 257 unit tests, including 2 new long-line tests that overflow on the
old parser. Benchmark (`parser-refactor/bench/run-bench.sh`), median ms for
`Parser.Expression.parse` of one line:

| shape (n = 2000) | before | after |
|---|---:|---:|
| `"a [b x] " * n` | 130 | 25 |
| `"[b " + "a [i x] " * n + "]"` | 3048 | 25 |
| `"[b " + "x [i y] " * n` (unclosed) | 2880 | 26 |
| `"$x$ " * n` | 88 | 13 |
| `"[b " + "$x$ " * n + "]"` | 1526 | 13 |

Time now roughly doubles when the input doubles, up to n = 16000 (128 KB lines).

## 2. ~~Walk the old and new trees once in `Parser/Forest.elm`~~ (done)

`forestStructureMatches`, `allChangedBlocksAreAccIndependent` and `spliceForest`
(six functions, three walks) are replaced by one `spliceIfAccIndependent`. It
returns `Just` the spliced forest exactly when the old check passed, and stops at
the first mismatch. It loops over siblings with an accumulator, so stack use grows
with nesting depth, not document length. `parseToForestWithAccumulator`,
`parseIncrementally` and the fallback path share an `accumulate` helper.

Verified:

- `run-diff.sh` now also compares 68 incremental reparses (no-op, plain word change,
  `[ref …]` added, paragraph inserted at top) and reports how many took the skip
  path: 28 skipped, 40 did not, identical to HEAD.
- 8 new tests in `tests/Parser/ForestTest.elm` pin down when the accumulator pass
  is skipped. They pass on both the old and new code.

## 3. ~~Keep list handling in one place~~ (done)

- New module `Parser/ListItem.elm` holds the only copy of the list syntax:
  `kind` (`"- "` → item/itemList, `". "` → numbered/numberedList) and `stripPrefix`.
  `PrimitiveBlock.getHeadingData`, `PrimitiveBlock.addBodyLine` and
  `Pipeline.groupListItems` all use it.
- `PrimitiveBlock` no longer merges a list item's continuation lines
  (`appendToLastListItem` is gone). List blocks keep their lines raw, and
  `Pipeline.groupListItems` does all the grouping. Parsed expressions are unchanged.
- Bug fixed along the way: merging in `PrimitiveBlock` meant `sourceText` was not
  the source (`"- b\n  more"` became `"- b more"`), so a list's `end` fell short.
  New test in `PrimitiveBlockTest` ("list continuation lines").

## 4. ~~Drop `Parser.Symbol`~~: dropped `TokenType` instead (done)

After #1, `Symbol` is converted lazily and only when a reduction is possible, so
the performance reason for removing it is gone. It gives `Match` a tiny alphabet,
which its 20 tests use (`[L, ST, R]`). The redundant copy was the `TokenType`
enum (`TLB`, `TRB`, …) and `Tokenizer.type_`, used in only three places.
Those are now direct pattern matches on `Token` (`Expression.isExpr`,
`Tokenizer.isTextToken`, `Tokenizer.lastIsOpenBracket`). Output identical.

## 5. ~~Stop treating tables as verbatim and then relabelling them~~ (done)

`table` moved from `verbatimNames` to `ordinaryNames`, so it parses as
`Ordinary "table"` directly. `Pipeline.transformBlockHeading` is gone, and
`Pipeline.parseBody` has an `Ordinary "table"` case. The only parsing difference
between verbatim and ordinary blocks is the rule for `| word` lines directly under
the header, and no table in the corpus has a row starting with `|`. Forest output
identical.

## 6. ~~Incremental reparse returns stale position metadata~~ (done)

Goal, checked by an oracle: an incremental reparse must give exactly the forest
and accumulator that a fresh parse of the same text gives. Four problems, all in
HEAD, were fixed:

1. **Expression cache reused old expression ids after a block moved.** The cache
   now records the line each body was parsed at (`ExpressionCache` values are
   `{ lineNumber, body }`). On a hit, `Pipeline.toExpressionBlockCached` shifts
   the `e-L.T` ids by the block's line change with `Edit.Map.shiftExprId`.
2. **The skip path kept stale positions and ids.** The accumulator stores block ids
   and expression ids (references, footnotes, terms, numbered items, Q&A), and both
   embed the line number. So the previous accumulator can be reused only if every
   block keeps its id. If a changed block gains or loses lines, the reparse now takes
   the full path. When skipping, unchanged blocks keep their accumulator-derived
   properties but take `meta` (offsets) from the new parse.
3. **Removing accumulator-dependent content went unnoticed.** Only the new version of
   a changed block was checked, so deleting a footnote, `[index …]` etc. reused a
   stale accumulator. Now the old and new versions must both be
   accumulator-independent.
4. **Header continuation lines were missing from `sourceText`.** Lines like
   `| width:300` or `| label:foo` were merged into args/properties but not into
   `meta.sourceText`. As a result, edits to them were invisible to change detection
   (skip path and cache), and `end`, `contentBegin` and `contentEnd` were wrong for
   such blocks: `end` stopped short and `contentBegin` pointed into the header.
   `mergeContinuationLine` now adds the line to `sourceText` and moves
   `contentBegin` past it.

Cost: pressing Enter in a plain paragraph now takes the full path. On
`mlttv1.scripta` (2,850 lines) that reparse takes ~5.4 ms instead of ~2.6 ms,
against ~46 ms for a cold parse. Typing within a line still takes the skip path
(~1.5 ms).

Verified:

- `tests/Parser/IncrementalOracleTest.elm`: 11 cases (skip and full path,
  continuation-line edits, footnote removal). Each compares the reparse with a fresh parse.
- `parser-refactor/diff-harness/run-oracle.sh`: 2,604 generated edits over all
  repo documents (insert char, add line, delete line, append `[ref …]` at ~40
  lines per document). 0 mismatches: 217 skip path, 2,387 full path. Before the
  fix, the first version of this check found 9 mismatches, which led to fixes 3 and 4.
- 2 new tests in `PrimitiveBlockTest` for continuation-line `sourceText` and offsets.
- `run-diff.sh` against HEAD: first-parse output differs only for the 5 inputs with
  header continuation lines (offsets and `sourceText`), as intended.
- All 278 tests pass, including `EditOracleTest` (shift == reparse).

## 7. ~~Indented multi-line blocks have wrong `end` / `contentEnd`~~ (done)

`PrimitiveBlock` now tracks `meta.end` line by line: each function that adds a
line to a block (`addLineToBlock`, `addRawLineToBlock`, `mergeContinuationLine`)
sets it to that line's `lineEnd` (`position + length` as written). `finalize` no
longer computes `end` from `sourceText`, and `contentEnd` is the tracked `end`.
`sourceText` of an indented block stays dedented after the first line (it is the
cache key and is used for text search); a test records this.

Verified:

- New `parser-refactor/diff-harness/run-span-check.sh`: for every block in every
  repo document, `String.slice begin end source` equals the block's lines as
  written. 0 mismatches in 2,214 blocks (HEAD before the fix: 43).
- 2 new `PrimitiveBlockTest` cases ("indented blocks"). All 281 tests pass,
  including `EditOracleTest`.
- `run-diff.sh`: only documents with indented blocks change, and every differing
  fragment shown differs only in `end`/`contentEnd`. `run-oracle.sh`: 0 mismatches.

## Known issues (out of scope for now)

- Cells in the same table row share expression ids (e.g. `e-3.0` twice),
  because token numbering restarts in each cell.
- Arguments that start with a space produce a leading `Text ""`.

## For each step

- Run `parser-refactor/diff-harness/run-diff.sh`. It should report `IDENTICAL`
  for the pure refactors (1, 2, 4 and probably 3).
- Run the unit tests with `npx elm-test@0.19.2-0`.
