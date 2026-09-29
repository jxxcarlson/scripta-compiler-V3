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

## 2. Walk the old and new trees once in `Parser/Forest.elm`

- `forestStructureMatches` (line 168), `allChangedBlocksAreAccIndependent`
  (line 195) and `spliceForest` (line 272) each walk the same pair of trees.
- Replace them with one walk that returns `Maybe` forest.
- At the same time, `parseToForestWithAccumulator` (line 62) and
  `parseIncrementally` (line 93) could share one implementation.

## 3. Keep list handling in one place

- Continuation lines are merged in both `appendToLastListItem`
  (`Parser/PrimitiveBlock.elm:327`) and `groupListItems`
  (`Parser/Pipeline.elm:138`).
- The `"- "` / `". "` prefix test is written three times: `inspectListKind`
  (`PrimitiveBlock.elm:290`), `groupListItems`, and `stripListPrefix`
  (`Pipeline.elm:166`).

## 4. Drop `Parser.Symbol`

Let `Parser/Match.elm` work on `Token` directly, using a
`bracketValue : Token -> Int`, instead of converting with `toSymbols`
(`Parser/Symbol.elm:45`).

## 5. Stop treating tables as verbatim and then relabelling them

`table` is listed in `verbatimNames` (`PrimitiveBlock.elm:13`), then renamed
to `Ordinary "table"` by `transformBlockHeading` (`Pipeline.elm:60`).
A separate `parseBody` case would be cleaner. Check first that ordinary-block
continuation lines can't affect table rows.

## Known issues (out of scope for now)

- Cells in the same table row share expression ids (e.g. `e-3.0` twice),
  because token numbering restarts in each cell.
- Arguments that start with a space produce a leading `Text ""`.

## For each step

- Run `parser-refactor/diff-harness/run-diff.sh`. It should report `IDENTICAL`
  for the pure refactors (1, 2, 4 and probably 3).
- Run the unit tests with `npx elm-test@0.19.2-0`.
