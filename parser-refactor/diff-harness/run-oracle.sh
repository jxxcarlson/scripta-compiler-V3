#!/usr/bin/env bash
# Check that incremental reparse equals a fresh parse, for the working tree,
# over generated edits to every .scripta file in the repo.
# Usage: parser-refactor/diff-harness/run-oracle.sh
set -euo pipefail
HARNESS="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$HARNESS" rev-parse --show-toplevel)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
sed "s#\"src\"#\"$REPO/src\", \"$HARNESS\"#" "$REPO/elm.json" > "$WORK/elm.json"
(cd "$WORK" && elm make "$HARNESS/OracleMain.elm" --optimize --output="$WORK/oracle.js" >/dev/null)
node "$HARNESS/oracle.js" "$WORK/oracle.js" "$REPO"
