# Future Optimizations

## 1. Debounce reparse

Delay `reparse` by 100-150ms after the last keystroke instead of running it on every `SourceChanged`. Trivial to implement — use a `Process.sleep` + message pattern. Big payoff for fast typists since intermediate keystrokes skip parsing entirely.

## 2. Per-tree Html.lazy (Step 6 from lazy plan)

Wrap individual top-level trees in `Html.lazy` inside `renderForest`. Editing paragraph 5 would skip re-rendering paragraphs 1-4. Requires the parser to produce referentially stable tree nodes for unchanged sections — a deeper architectural change.

## 3. Incremental parsing

Only re-parse blocks that changed, reuse the rest of the forest. Compare source lines to detect which blocks were modified, inserted, or deleted, then splice the new blocks into the existing forest. Most complex of the three but the largest potential gain for long documents.
