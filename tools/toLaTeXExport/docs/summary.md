# LaTeX Export Diagnostic Tool — Summary

## What It Does

`diagnose.js` reads the error output from the LaTeX export pipeline (`FILE-errors.json`) alongside the original Scripta source (`FILE.scripta`) and generated LaTeX (`FILE.tex`), classifies each error, and writes a structured diagnostic report (`FILE-diagnosis.json`).

## Makefile Targets

```bash
cd tools/toLaTeXExport

make diagnose          # Diagnose all error files
make diagnose-manual   # Diagnose a single file (replace 'manual' with any basename)
make summary           # Print overview table of all diagnoses
```

## Current Error Landscape (262 total errors across 9 documents)

```
File            Errors  Top Category
--------------------------------------------------------
aligned-test1   0       none
aligned-test2   0       none
bohr-debroglie  0       none
datasci         84      undefined-command (58)
graph-color     8       undefined-command (4)
manual          5       bibliography (3)
mltt            164     undefined-command (87)
virial          1       undefined-command (1)
welcome         0       none
--------------------------------------------------------
TOTAL           262
```

4 documents compile clean. The remaining 5 have errors in these categories:

| Category | Count | Description |
|----------|-------|-------------|
| `undefined-command` | 150 | Non-standard control sequences in LaTeX output |
| `bibliography` | 3 | `\bibitem` with undefined `\@listctr` |
| `parse-error-passthrough` | 1 | `\errorHighlight` markers leaked into output |
| `missing-handler` | 1 | `[bt ]` backtick element not converted to `\lstinline` |

## Iterative Fix Workflow

1. `make all` — export all .scripta files, get error JSONs
2. `make diagnose` — classify all errors, get diagnosis JSONs
3. Read `FILE-diagnosis.json` — see error categories and fix hints
4. Fix the exporter code in `src/Render/Export/LaTeX.elm`
5. `make all` again — re-export, check if error count decreased
6. Repeat until zero errors

## Files

| File | Purpose |
|------|---------|
| `diagnose.js` | Error classification and diagnostic report tool |
| `run.js` | Export pipeline: .scripta → LaTeX → PDF server → errors.json |
| `Worker.elm` | Elm Platform.worker: parses Scripta and exports LaTeX |
| `Makefile` | Build, export, diagnose, and summary targets |
| `docs/latex-export-diagnostic-tool-plan.md` | Design plan for the diagnostic tool |

## Key Exporter Code References

Each diagnosis entry includes `fixLocation` and `fixHint` pointing to these functions in `src/Render/Export/LaTeX.elm`:

| Function | Line | Handles |
|----------|------|---------|
| `exportExpr` | 1663 | Expression dispatch (Fun, Text, VFun) |
| `macroDict` | 1217 | Maps function names to LaTeX commands |
| `blockDict` | 1284 | Maps block names to export handlers |
| `mapChars2` | 1179 | Text character escaping |
| `exportBibitem` | 1271 | Bibliography items |
| `exportBibliographyBegin` | 1262 | Bibliography environment |
| `inlineCode` | 1362 | `[code ...]` to `\lstinline` |
| `renderVerbatim` | 1770 | Verbatim expressions (code, math, chem) |
