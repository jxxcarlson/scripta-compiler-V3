
  cd tools/benchmark
  make build-optimize && make run          # benchmark current branch
  make build-main && make run              # benchmark with main worker
  make compare                             # full cross-branch comparison via worktrees



- Both WorkerMain.elm and WorkerOptimize.elm compile successfully
  - run.js produces correct JSON and table output
  - compare.js generates the comparison table with speedup ratios

  Early Results (5 iterations, optimize branch)

  The incremental parse cache shows 6-8x speedups across all document sizes:

  ┌──────────┬───────┬───────────┬──────────────────┬─────────┐
  │ Document │ Lines │ fullParse │ incrementalParse │ Speedup │
  ├──────────┼───────┼───────────┼──────────────────┼─────────┤
  │ small    │ 51    │ 3.6ms     │ 0.4ms            │ 8.2x    │
  ├──────────┼───────┼───────────┼──────────────────┼─────────┤
  │ medium   │ 403   │ 10.2ms    │ 1.5ms            │ 6.9x    │
  ├──────────┼───────┼───────────┼──────────────────┼─────────┤
  │ large    │ 1,364 │ 33.2ms    │ 4.1ms            │ 8.2x    │
  ├──────────┼───────┼───────────┼──────────────────┼─────────┤
  │ xlarge   │ 2,851 │ 49.9ms    │ 8.1ms            │ 6.1x    │
  └──────────┴───────┴───────────┴──────────────────┴─────────┘






⏺ The cachedForest command works perfectly. The results show the three tiers clearly:

  ┌──────────────────┬────────────────────────┬───────────────────────────────────────┐
  │    Operation     │  xlarge (2851 lines)   │           What it measures            │
  ├──────────────────┼────────────────────────┼───────────────────────────────────────┤
  │ fullParse        │ 48.0ms                 │ Cold parse from scratch               │
  ├──────────────────┼────────────────────────┼───────────────────────────────────────┤
  │ incrementalParse │ 7.6ms (6.3x faster)    │ Warm cache, reuse expressions         │
  ├──────────────────┼────────────────────────┼───────────────────────────────────────┤
  │ cachedForest     │ 0.01ms (~5000x faster) │ Return stored forest, no parse at all │
  └──────────────────┴────────────────────────┴───────────────────────────────────────┘

  The cachedForest at ~0.01ms confirms the "skip parse on click" optimization is essentially free — the model just returns the already-stored forest without
  touching the parser.

