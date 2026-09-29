# Scripta files used for diff testing

The comparison of HEAD against `refactor-parser` used all 21 `.scripta` files in
the repo, about 8,200 lines in total:

| Lines | File |
|---:|---|
| 468 | `docs/elements_visual_test.scripta` |
| 426 | `docs/ordinary_block_visual_test.scripta` |
| 315 | `docs/verbatim_block_visual_test.scripta` |
| 3 | `tests/toLaTeXExportTestDocs/aligned-test1.scripta` |
| 3 | `tests/toLaTeXExportTestDocs/aligned-test2.scripta` |
| 108 | `tests/toLaTeXExportTestDocs/bohr-debroglie.scripta` |
| 19 | `tests/toLaTeXExportTestDocs/crazy-verbatim.scripta` |
| 1074 | `tests/toLaTeXExportTestDocs/datasci.scripta` |
| 8 | `tests/toLaTeXExportTestDocs/etex.scripta` |
| 223 | `tests/toLaTeXExportTestDocs/graph-color.scripta` |
| 6 | `tests/toLaTeXExportTestDocs/image.scripta` |
| 50 | `tests/toLaTeXExportTestDocs/index-test.scripta` |
| 614 | `tests/toLaTeXExportTestDocs/manual.scripta` |
| 6 | `tests/toLaTeXExportTestDocs/mathnotation-inline.scripta` |
| 1363 | `tests/toLaTeXExportTestDocs/mltt.scripta` |
| 41 | `tests/toLaTeXExportTestDocs/mlttv1-test.scripta` |
| 2850 | `tests/toLaTeXExportTestDocs/mlttv1.scripta` |
| 9 | `tests/toLaTeXExportTestDocs/theorem.scripta` |
| 208 | `tests/toLaTeXExportTestDocs/virial.scripta` |
| 402 | `tests/toLaTeXExportTestDocs/welcome.scripta` |
| 16 | `tests/toLaTeXExportTestDocs/wikilinks.scripta` |

Each file was also run a second time with its trailing blank lines removed,
which is what exercises the last-block id path. On top of that there were 17
hand-written snippets:

- unclosed or stray brackets
- code and math inside function arguments
- wikilinks
- `\alpha` and `\(…\)`
- list continuations
- markdown and `| section` headings
- header continuation lines
- a small table

Two of the real files triggered specific findings:

- **`mlttv1.scripta`** has the tab-indented line that caught an indentation
  mistake in step 2 (the `Line.classify` rewrite briefly counted tabs as
  indentation).
- **`virial.scripta`** is the file that ends without a trailing blank line, so
  its last block had the empty id.

## Rerunning the comparison

The harness is in `parser-refactor/diff-harness/`:

```bash
parser-refactor/diff-harness/run-diff.sh            # compare working tree vs HEAD
parser-refactor/diff-harness/run-diff.sh main       # ... vs any git ref
```

It checks out the base ref in a temporary git worktree, and builds `DiffMain.elm`
against both source trees. It then runs every input through `Parser.Forest.parse`,
`parseToForestWithAccumulator`, and per-line `Parser.Expression.parse`. It prints
`IDENTICAL` (exit 0) or the changed inputs with their first differing fragments
(exit 1). Input numbering: 0–20 are the files above in sorted order, 21–41 the
same files with trailing blank lines stripped, and 42–58 the synthetic cases in
`run.js`. A run takes about 15 seconds.

- `DiffMain.elm`: Elm worker that prints `Debug.toString` of the parse results
- `run.js`: collects inputs and runs the worker
- `compare.py`: summarizes differences
- `run-diff.sh`: builds both versions, runs, compares

## Incremental reparse oracle

`parser-refactor/diff-harness/run-oracle.sh` checks the working tree only.
For every `.scripta` file, at about 40 evenly spaced lines, it applies four
edits: insert a character, add a line, delete the line, append `[ref foo]`.
For each edit it checks that an incremental reparse (`parseIncrementally`, then
`parseIncrementallySkipAcc`) gives the same forest and accumulator as a fresh
parse. It prints each mismatch and a summary line with the skip/full counts
(2,604 edits; about 1 minute).

- `OracleMain.elm`: Elm worker that does the comparison
- `oracle.js`: generates the edits and prints the report
