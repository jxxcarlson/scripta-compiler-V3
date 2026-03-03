# Parser Benchmarks

## Quick start

```bash
cd tools/benchmark

# Build the Elm worker and run benchmarks (default: WorkerOptimize)
make all
```

This compiles the Elm worker with `--optimize` and runs 100 iterations against 4 test documents of increasing size.

## Individual steps

```bash
# Build only
make build              # builds WorkerOptimize.elm → worker.js
make build-main         # builds WorkerMain.elm → worker.js
make build-optimize     # builds WorkerOptimize.elm → worker.js

# Run only (requires worker.js to already exist)
make run                # 100 iterations (default)
node run.js --iterations 50   # custom iteration count
```

## What it benchmarks

The runner (`run.js`) loads 4 `.scripta` test documents from `tests/toLaTeXExportTestDocs/` (small, medium, large, xlarge) and measures:

- **fullParse** — full parse pipeline (both workers)
- **incrementalParse** — parse with warm cache (optimize worker only)
- **cachedForest** — return stored forest without re-parsing (optimize worker only)
- **incrParse-edited** — incremental parse after a simulated edit (optimize worker only)

Output is a human-readable table plus a JSON file (`results-<branch>.json`).

## Cross-branch comparison

To compare `main` vs `optimize` branches side-by-side:

```bash
make compare
# or with custom iterations:
bash compare.sh --iterations 50
```

This creates temporary git worktrees in `/tmp/`, builds each branch's worker, runs benchmarks in both, and then runs `compare.js` to produce a comparison report. Worktrees are cleaned up automatically on exit.
