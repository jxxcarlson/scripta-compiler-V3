#!/usr/bin/env bash
# Check that every block's begin/end cut exactly its own source lines out of the
# document, for every .scripta file in the repo (working tree).
# Usage: parser-refactor/diff-harness/run-span-check.sh
set -euo pipefail
HARNESS="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$HARNESS" rev-parse --show-toplevel)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
sed "s#\"src\"#\"$REPO/src\", \"$HARNESS\"#" "$REPO/elm.json" > "$WORK/elm.json"
(cd "$WORK" && elm make "$HARNESS/SpanCheck.elm" --optimize --output="$WORK/span.js" >/dev/null)
node "$HARNESS/span.js" "$WORK/span.js" "$REPO"
