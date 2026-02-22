# Plan: LaTeX Export Error Diagnostic Tool

## Context

We already have a working pipeline (`tools/toLaTeXExport/`) that converts `.scripta` files to LaTeX and captures compilation errors as `FILE-errors.json`. Now we need a diagnostic tool that reads these error files, maps each error back to the Scripta source and the responsible exporter code, classifies the error, and produces an actionable report. This enables systematic, iterative improvement of the LaTeX exporter in `src/Render/Export/LaTeX.elm`.

## Current Error Landscape

From testing 9 documents, 5 have errors (virial: 1, manual: 5, graph-color: 12+, mltt: 40+, datasci: 69). Errors fall into these categories:

| Category | Example | Root Cause |
|----------|---------|------------|
| **Parse error passthrough** | `\errorHighlight{[code]?}` in output | Parser couldn't parse `[code ctrl-[ ]` (bracket inside code element); error marker passed to exporter which renders it literally |
| **Bare backticks** | `` ` a^2 ` `` instead of `\lstinline|...|` | `[bt ]` element not handled by exporter — missing from `macroDict` or `exportExpr` |
| **Missing math mode** | `a^` outside `$...$` | Consequence of backtick issue — `^` in text without math delimiters |
| **Bibliography structure** | `\bibitem` with undefined `\@listctr` | `exportBibliographyBegin` or list counter setup issue |
| **Missing character escaping** | `&`, `#`, `%` not escaped | `mapChars2` (line 1179) only escapes `_`, quotes, dashes |
| **Undefined control sequences** | Various `\errorHighlight` | Parser error markers leaking into LaTeX output |

## Tool Design

### What It Does

`tools/toLaTeXExport/diagnose.js` — a Node.js script that reads the error pair (`FILE-errors.json` + `FILE.scripta` + `FILE.tex`) and produces a structured diagnostic report.

### Input/Output

```
Usage: node diagnose.js <basename>
  e.g.: node diagnose.js manual
```

**Reads** from `tests/toLaTeXExportTestDocs/`:
- `FILE-errors.json` — error array from PDF server
- `FILE.scripta` — original source
- `FILE.tex` — generated LaTeX

**Writes** to `tests/toLaTeXExportTestDocs/`:
- `FILE-diagnosis.json` — structured diagnostic report

### Error JSON Input Format (from PDF server)

Each entry in `FILE-errors.json`:
```json
{
  "latex-begin": 301,
  "latex-end": 302,
  "latex-line": 302,
  "latex-text": "... the problematic LaTeX ...",
  "scripta-line": 51
}
```

### Diagnostic Output Format

```json
{
  "file": "manual",
  "totalErrors": 5,
  "categories": {
    "parse-error-passthrough": 4,
    "missing-handler": 1,
    "bibliography": 3
  },
  "errors": [
    {
      "id": 1,
      "scriptaLine": 51,
      "scriptaContext": "For code, you can use a [index code element] ...",
      "latexLine": 302,
      "latexContext": "... enclose code in backticks, e.g., ` a^2 ...",
      "category": "missing-handler",
      "pattern": "bare-backtick",
      "explanation": "Backtick element [bt ] not converted to \\lstinline",
      "fixLocation": "src/Render/Export/LaTeX.elm — exportExpr or macroDict",
      "fixHint": "Add 'bt' handling in exportExpr (around line 1668) or macroDict (line 1217)"
    }
  ],
  "summary": "5 errors across 3 categories. Top priority: parse-error-passthrough (4 errors)"
}
```

## Implementation Steps

### Step 1. Create `tools/toLaTeXExport/diagnose.js`

The script performs three phases:

**Phase A — Load files**: Read `FILE-errors.json`, `FILE.scripta`, `FILE.tex`. Split source and LaTeX into line arrays for context extraction.

**Phase B — Classify each error**: For each error entry, extract context lines from both source and LaTeX, then classify by pattern-matching on `latex-text`:

| Pattern to match | Category | Fix location |
|-----------------|----------|-------------|
| `\errorHighlight{` present | `parse-error-passthrough` | Parser or `exportExpr` (line 1663) |
| Bare backtick `` ` `` in text | `missing-handler` | `exportExpr` / `macroDict` (line 1217) |
| `\bibitem` | `bibliography` | `exportBibitem` (line 1271) / `exportBibliographyBegin` (line 1262) |
| `Missing $` in error text | `math-mode` | `mapChars2` (line 1179) or inline code handler |
| `Undefined control sequence` | `undefined-command` | `blockDict` (line 1284) or `macroDict` (line 1217) |
| Unescaped `&`, `#`, `%` | `escaping` | `mapChars2` (line 1179) |

**Phase C — Write report**: Aggregate by category, sort by frequency, write `FILE-diagnosis.json`.

### Step 2. Add `diagnose` and `diagnose-all` Makefile targets

```makefile
diagnose: build
	@for f in $(DOCS_DIR)/*-errors.json; do \
		base=$$(basename $$f -errors.json); \
		if [ -f $(DOCS_DIR)/$$base.scripta ]; then \
			echo "=== Diagnosing $$base ==="; \
			node diagnose.js $$base; \
		fi \
	done
```

Also add a single-file target: `make diagnose-FILE` (e.g., `make diagnose-manual`).

### Step 3. Add a summary mode

`node diagnose.js --summary` reads all `*-diagnosis.json` files and prints a consolidated table:

```
File            Errors  Top Category
manual          5       parse-error-passthrough (4)
datasci         69      missing-handler (23)
graph-color     12      escaping (8)
mltt            40      undefined-command (15)
virial          1       math-mode (1)
TOTAL           127
```

This gives an at-a-glance view of overall export quality across all test documents.

## Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `tools/toLaTeXExport/diagnose.js` | Create | Error classification and diagnostic report |
| `tools/toLaTeXExport/Makefile` | Modify | Add `diagnose` and `diagnose-all` targets |

## Key Exporter Code References

These are the locations the diagnostic tool will point developers to:

| Function | File:Line | Handles |
|----------|-----------|---------|
| `exportExpr` | `LaTeX.elm:1663` | Expression dispatch (Fun, Text, VFun) |
| `macroDict` | `LaTeX.elm:1217` | Maps function names -> LaTeX commands |
| `blockDict` | `LaTeX.elm:1284` | Maps block names -> export handlers |
| `mapChars2` | `LaTeX.elm:1179` | Text character escaping |
| `exportBibitem` | `LaTeX.elm:1271` | Bibliography items |
| `exportBibliographyBegin` | `LaTeX.elm:1262` | Bibliography environment |
| `inlineCode` | `LaTeX.elm:1362` | `[code ...]` -> `\lstinline` |
| `renderVerbatim` | `LaTeX.elm:1770` | Verbatim expressions (code, math, chem) |
| `annotateWithLineNumber` | `LaTeX.elm:315` | `%%% Line N` source mapping |

## Iterative Workflow

The intended developer workflow with this tool:

1. `make all` — export all .scripta files, get error JSONs
2. `make diagnose` — classify all errors, get diagnosis JSONs
3. Read `FILE-diagnosis.json` — see top error category and fix hints
4. Fix the exporter code in `src/Render/Export/LaTeX.elm`
5. `make all` again — re-export, check if error count decreased
6. Repeat until zero errors

## Verification

1. Start PDF server: `cd /Users/carlson/dev/elm-work/scripta/pdfServer2 && stack run`
2. `cd tools/toLaTeXExport && make all` — generate fresh error files
3. `node diagnose.js manual` — should produce `manual-diagnosis.json` with 5 classified errors
4. `node diagnose.js --summary` — should show table of all documents
