# Data Flow: `make somedoc.scripta`

Run from `tools/toLaTeXExport/`.

## 1. Makefile (`Makefile:15-16`)

```makefile
%.scripta: build
	node run.js $(DOCS_DIR)/$@
```

First compiles `Worker.elm → worker.js`, then runs `node run.js ../../tests/toLaTeXExportTestDocs/somedoc.scripta`.

## 2. run.js (`run.js`)

- Reads `somedoc.scripta` from disk (line 45)
- Boots the Elm worker: `require('./worker.js')` → `Elm.Worker.init()` (lines 55-56)
- Sends source text to Elm: `app.ports.receiveSourceText.send(sourceText)` (line 106)

## 3. Worker.elm (`Worker.elm`)

- Receives source text via port
- Parses: `Parser.Forest.parseToForestWithAccumulator params (String.lines sourceText)` → forest of `ExpressionBlock`s
- Resolves metadata: `Render.Export.LaTeX.getPublicationData` → title, author, kind
- Exports: `Render.Export.LaTeX.export pubData settings forest` → full LaTeX string with preamble
- Sends LaTeX back via port: `sendLaTeX`

## 4. Back in run.js (`run.js:58` — `sendLaTeX.subscribe` callback)

- Writes `somedoc.tex` to `tests/toLaTeXExportTestDocs/` (line 63)
- POSTs JSON to `http://localhost:3000/pdf` (lines 67-81):
  ```json
  {"id": "somedoc.tex", "content": "<latex>", "urlList": [], "packageList": []}
  ```
- PDF server compiles the LaTeX and returns `{hasErrors, errorJson, pdf, ...}`

## 5. Error handling (`run.js:88-95`)

- If `result.hasErrors`: writes `result.errorJson` → `somedoc-errors.json`
- If no errors: writes `{"hasErrors": false}` → `somedoc-errors.json`

## Output files

Written to `tests/toLaTeXExportTestDocs/`:

| File | Contents |
|------|----------|
| `somedoc.tex` | Generated LaTeX (for debugging) |
| `somedoc-errors.json` | Error report from PDF server |

---

# Data Flow: `make diagnose`

Run from `tools/toLaTeXExport/`. Assumes export has already been run (`make all` or `make somedoc.scripta`) so that `*-errors.json` files exist.

## 1. Makefile (`Makefile:17-18`)

```makefile
diagnose:
	node diagnose.js --all
```

Runs `diagnose.js` in `--all` mode, which iterates over every `*-errors.json` file in the docs directory.

## 2. diagnose.js — file discovery (`diagnose.js`, `--all` branch)

- Scans `tests/toLaTeXExportTestDocs/` for files matching `*-errors.json`
- For each, strips the `-errors.json` suffix to get the basename (e.g., `manual`)
- Skips any that lack a matching `.scripta` file
- Calls `runDiagnosis(basename)` for each

## 3. diagnose.js — load phase (`runDiagnosis`)

For a given basename (e.g., `manual`), reads three files from `tests/toLaTeXExportTestDocs/`:

| File | Purpose |
|------|---------|
| `manual-errors.json` | Error array from PDF server |
| `manual.scripta` | Original Scripta source |
| `manual.tex` | Generated LaTeX (optional, for context) |

If the error file contains `{"hasErrors": false}`, writes a zero-error diagnosis and returns early.

## 4. diagnose.js — classify phase

For each entry in the error array, the classifier:

1. Extracts the `latex-text`, `scripta-line`, and `latex-line` fields
2. Pulls context lines from the `.scripta` and `.tex` files (1 line of surrounding context)
3. Tests `latex-text` against classification rules in priority order:

| Priority | Rule | Matches on |
|----------|------|-----------|
| 1 | `parse-error-passthrough` | `\errorHighlight{` in latex-text |
| 2 | `missing-handler` | Bare backtick `` ` `` in text |
| 3 | `bibliography` | `\bibitem{` in text |
| 4 | `math-mode` | `^` or `_` outside `$...$` and `\lstinline` |
| 5 | `escaping` | Unescaped `&`, `#`, or `%` |
| 6 | `undefined-command` | Control sequences not in the known-commands set |
| 7 | (fallback) | `unclassified` |

First matching rule wins. The `undefined-command` rule also extracts and lists the specific unknown control sequences.

Each classified error gets:
- `category`, `pattern` — what kind of error
- `scriptaContext`, `latexContext` — surrounding source lines
- `fixLocation`, `fixHint` — where and how to fix in `src/Render/Export/LaTeX.elm`
- `unknownCommands` (if applicable) — the specific undefined control sequences

## 5. diagnose.js — report phase

- Aggregates errors by category with counts
- Builds a summary string (e.g., `"5 errors across 3 categories. Breakdown: bibliography (3), ..."`)
- Writes the full report to `manual-diagnosis.json`

## Output files

Written to `tests/toLaTeXExportTestDocs/`:

| File | Contents |
|------|----------|
| `somedoc-diagnosis.json` | Classified error report with fix hints |

## Single-file variant: `make diagnose-somedoc`

```makefile
diagnose-%:
	node diagnose.js $*
```

Runs `diagnose.js manual` directly, diagnosing only that one file.

## Summary variant: `make summary`

```makefile
summary:
	node diagnose.js --summary
```

Reads all existing `*-diagnosis.json` files and prints a consolidated table to stdout:

```
File            Errors  Top Category
--------------------------------------------------------
manual          5       bibliography (3)
datasci         84      undefined-command (58)
...
TOTAL           262
```
