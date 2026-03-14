#!/bin/bash
#
# Cross-branch benchmark comparison.
#
# Creates worktrees for `main` and `optimize`, builds the appropriate
# Worker variant in each, runs benchmarks, and compares results.
#
# Usage:
#   ./compare.sh
#   ./compare.sh --iterations 50

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ITERATIONS="${1:---iterations}"
ITER_COUNT="${2:-100}"

BENCH_MAIN="/tmp/bench-main"
BENCH_OPT="/tmp/bench-optimize"

cleanup() {
  echo "Cleaning up worktrees..."
  cd "$REPO_ROOT"
  git worktree remove "$BENCH_MAIN" --force 2>/dev/null || true
  git worktree remove "$BENCH_OPT" --force 2>/dev/null || true
}

trap cleanup EXIT

echo "=== Scripta Benchmark: main vs optimize ==="
echo "Repo: $REPO_ROOT"
echo ""

# 1. Create worktrees
echo "Creating worktrees..."
cd "$REPO_ROOT"
git worktree remove "$BENCH_MAIN" --force 2>/dev/null || true
git worktree remove "$BENCH_OPT" --force 2>/dev/null || true
git worktree add "$BENCH_MAIN" main
git worktree add "$BENCH_OPT" optimize

# 2. Copy benchmark tool into each worktree
echo "Copying benchmark tools..."
mkdir -p "$BENCH_MAIN/tools/benchmark"
mkdir -p "$BENCH_OPT/tools/benchmark"

for dir in "$BENCH_MAIN/tools/benchmark" "$BENCH_OPT/tools/benchmark"; do
  cp "$SCRIPT_DIR/elm.json" "$dir/"
  cp "$SCRIPT_DIR/run.js" "$dir/"
  cp "$SCRIPT_DIR/Makefile" "$dir/"
done

# 3. Copy branch-specific workers
echo "Setting up branch-specific workers..."
cp "$SCRIPT_DIR/WorkerMain.elm" "$BENCH_MAIN/tools/benchmark/Worker.elm"
cp "$SCRIPT_DIR/WorkerOptimize.elm" "$BENCH_OPT/tools/benchmark/Worker.elm"

# Also rename the module declaration to "Worker" for each
sed -i.bak 's/^port module WorkerMain/port module Worker/' "$BENCH_MAIN/tools/benchmark/Worker.elm"
sed -i.bak 's/^port module WorkerOptimize/port module Worker/' "$BENCH_OPT/tools/benchmark/Worker.elm"
rm -f "$BENCH_MAIN/tools/benchmark/Worker.elm.bak"
rm -f "$BENCH_OPT/tools/benchmark/Worker.elm.bak"

# Update run.js to look for Elm.Worker instead of WorkerMain/WorkerOptimize
for dir in "$BENCH_MAIN/tools/benchmark" "$BENCH_OPT/tools/benchmark"; do
  sed -i.bak 's/Elm\.WorkerMain || Elm\.WorkerOptimize/Elm.Worker/' "$dir/run.js"
  sed -i.bak 's/!!Elm\.WorkerOptimize/!!Elm.Worker.init.toString().includes("seedCache")/' "$dir/run.js"
  rm -f "$dir/run.js.bak"
done

# 4. Build and run on main branch
echo ""
echo "=== Building main branch ==="
cd "$BENCH_MAIN/tools/benchmark"
make build

echo ""
echo "=== Running benchmarks on main ==="
node run.js --iterations "$ITER_COUNT"

# 5. Build and run on optimize branch
echo ""
echo "=== Building optimize branch ==="
cd "$BENCH_OPT/tools/benchmark"
make build

echo ""
echo "=== Running benchmarks on optimize ==="
node run.js --iterations "$ITER_COUNT"

# 6. Compare results
echo ""
echo "=== Comparison ==="
cd "$SCRIPT_DIR"
node compare.js \
  "$BENCH_MAIN/tools/benchmark/results-main.json" \
  "$BENCH_OPT/tools/benchmark/results-optimize.json"

echo ""
echo "Done. Results saved in worktrees at:"
echo "  Main:     $BENCH_MAIN/tools/benchmark/results-main.json"
echo "  Optimize: $BENCH_OPT/tools/benchmark/results-optimize.json"
