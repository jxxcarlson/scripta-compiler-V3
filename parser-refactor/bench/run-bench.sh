#!/usr/bin/env bash
# Benchmark Parser.Expression.parse for BASE_REF (default HEAD) and the working tree.
# Usage: parser-refactor/bench/run-bench.sh [BASE_REF] [SIZES]   e.g. run-bench.sh HEAD 250,500,1000
set -euo pipefail
BASE_REF="${1:-HEAD}"
SIZES="${2:-250,500,1000,2000}"
BENCH="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$BENCH" rev-parse --show-toplevel)"
WORK="$(mktemp -d)"
trap 'git -C "$REPO" worktree remove --force "$WORK/base" >/dev/null 2>&1 || true; rm -rf "$WORK"' EXIT
git -C "$REPO" worktree add -q --detach "$WORK/base" "$BASE_REF"
build () {
  local dir="$WORK/build-$1"; mkdir -p "$dir"
  sed "s#\"src\"#\"$2\", \"$BENCH\"#" "$REPO/elm.json" > "$dir/elm.json"
  (cd "$dir" && elm make "$BENCH/BenchMain.elm" --optimize --output="$dir/bench.js" >/dev/null)
}
build base "$WORK/base/src"
build new "$REPO/src"
echo "== $BASE_REF";        node "$BENCH/run.js" "$WORK/build-base/bench.js" "$SIZES"
echo "== working tree";     node "$BENCH/run.js" "$WORK/build-new/bench.js" "$SIZES"
