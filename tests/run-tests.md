# Running the LaTeX Export Test

## Prerequisites

1. The PDF server must be running:
   ```bash
   cd /Users/carlson/dev/elm-work/scripta/pdfServer2 && stack run
   ```

2. Node.js must be installed.

## Quick Start

```bash
cd tools/toLaTeXExport
make test
```

This builds `Worker.elm` into `worker.js`, then runs `welcome.scripta` through the pipeline.

## What It Does

1. Reads a `.scripta` source file
2. Parses it and exports to LaTeX using the V3 compiler
3. POSTs the LaTeX to the PDF server at `localhost:3000/pdf`
4. Captures any compilation errors as JSON

## Output

Results are written to `tests/toLaTeXExportTestDocs/`:
- `welcome.tex` — the generated LaTeX (for debugging)
- `welcome-errors.json` — error report from the PDF server, or `{"hasErrors": false}`

## Manual Usage

```bash
cd tools/toLaTeXExport
make build
node run.js <path-to-any-scripta-file>
```

## Makefile Targets

- `make build` — compile `Worker.elm` to `worker.js`
- `make test` — build + run with `welcome.scripta`
- `make clean` — remove `worker.js` and `elm-stuff`
