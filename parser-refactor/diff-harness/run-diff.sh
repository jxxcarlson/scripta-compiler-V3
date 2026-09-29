#!/usr/bin/env bash
# Differential test of the parser: compare output of BASE_REF (default HEAD)
# against the current working tree, over every .scripta file in the repo,
# the same files with trailing blank lines stripped, and synthetic cases
# listed in run.js.
#
# Usage: parser-refactor/diff-harness/run-diff.sh [BASE_REF]
set -euo pipefail

BASE_REF="${1:-HEAD}"
HARNESS="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$HARNESS" rev-parse --show-toplevel)"
WORK="$(mktemp -d)"
trap 'git -C "$REPO" worktree remove --force "$WORK/base" >/dev/null 2>&1 || true; rm -rf "$WORK"' EXIT

git -C "$REPO" worktree add -q --detach "$WORK/base" "$BASE_REF"

build () {  # $1 = name, $2 = src dir
  local dir="$WORK/build-$1"
  mkdir -p "$dir"
  sed "s#\"src\"#\"$2\", \"$HARNESS\"#" "$REPO/elm.json" > "$dir/elm.json"
  (cd "$dir" && elm make "$HARNESS/DiffMain.elm" --output="$dir/diff.js" >/dev/null)
}

echo "Building $BASE_REF and working tree..."
build base "$WORK/base/src"
build new "$REPO/src"

node "$HARNESS/run.js" "$WORK/build-base/diff.js" "$REPO" > "$WORK/base.out" 2>/dev/null
node "$HARNESS/run.js" "$WORK/build-new/diff.js" "$REPO" > "$WORK/new.out" 2>/dev/null

python3 "$HARNESS/compare.py" "$WORK/base.out" "$WORK/new.out"
