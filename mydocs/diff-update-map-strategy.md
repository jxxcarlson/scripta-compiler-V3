# Diff-Update-Map Strategy

**Branch:** `diff-update-map`
**Date:** 2026-06-21
**Status:** Design approved; ready for implementation plan

## Problem

The RL-sync map (render ↔ source location sync) is encoded as HTML attributes baked
into the rendered DOM:

- **Blocks** (`src/Render/Utility.elm:40-44`, `rlBlockSync`):
  `data-begin = blockMeta.begin`, `data-end = blockMeta.end`, `data-lines = blockMeta.numberOfLines`
- **In-block expressions** (`src/Render/Utility.elm:15-19`, `rlSync`):
  `id = meta.id`, `data-begin = meta.begin`, `data-end = meta.end`

When the user edits the source (character or line added/deleted), every block and
expression *at and below* the edit point has stale position metadata until the next
compile. A full reparse on every keystroke is wasteful and causes churn.

For an edit that does **not** change block structure, every block/expression below the
edit needs only an **offset shift** (by the character delta) and a **line shift** (by the
line delta) — no content reparsing.

## Relevant facts about the current model

- **Block `begin`/`end`** are absolute character offsets into the whole source;
  `end = begin + length(sourceText)`. `numberOfLines` is a line count; `lineNumber` is the
  0-based start line. (`src/V3/Types.elm:87-100`, computed in `src/Parser/PrimitiveBlock.elm`.)
- **Expression `begin`/`end`** are offsets *within their line* (not global).
- **IDs are position-derived and regenerated on every parse:** block `id = "L-I"`
  (`lineNumber-blockIndex`); expression `id = "e-L.T"` (`e-lineNumber.tokenIndex`).
- There is already an incremental path — `Scripta.reparse` /
  `Parser.Forest.parseIncrementallySkipAcc` — that reuses the expression cache + accumulator
  when block structure is unchanged, but it still re-renders the whole forest and re-derives
  all offsets/IDs.

## Decisions (from brainstorming)

1. **Update target:** patch the Elm model (`Document`/`Forest`). Pure
   `Document -> Document`; the next Elm render emits correct `data-*` attributes.
2. **Edited block:** shift-only. `applyEdit` shifts metadata for everything at/below the
   edit and does **not** reparse the edited block's content. The existing debounced
   `reparse` refreshes actual content/rendering.
3. **Edit shape:** `{ offset, removed, inserted }` against the pre-edit document
   (CodeMirror-style). The compiler derives `charDelta` and `lineDelta`.
4. **Cadence:** shift runs high-frequency (per keystroke) to keep the map live; the full
   `reparse` runs on a longer debounce and re-establishes the authoritative model + clears
   the edit queue.
5. **Algorithm:** Approach 1 — each edit applied as a single downward forest pass with a
   skip-prefix optimization; batches handled by folding `applyEdit`. (True multi-edit
   coalescing into one breakpoint map is a deferred optimization — see Out of scope.)

## 1. Scope & contract

`applyEdit`/`applyEdits` is a **pure metadata transform** on a parsed `Document`. It shifts
position metadata so the RL-sync map stays valid between debounced reparses. It never
reparses, never re-renders, never touches block content or `sourceText`.

**Guarantee (structure-preserving edits — no block split/merge, no heading marker
created/destroyed):**

- **Block-level metadata** (`begin`, `end`, `lineNumber`, `numberOfLines`, `id`,
  `contentBegin/End`): after the shift, identical to what a full `reparse` of the post-edit
  text would produce — for *every* block, including the edited one. (A block's `begin/end`
  depend only on the offsets of its boundaries, not its interior, so even the edited block's
  block-level numbers are exactly recoverable by shifting.)
- **Expression-level metadata** (`begin`, `end`, `id` within a block): identical to reparse
  for every block **except the directly-edited block(s)**, whose interior expressions stay
  stale until the next reparse fixes them.

For **structure-changing** edits, character offsets remain numerically shifted but the block
partition may be wrong; the longer-debounce `reparse` is the authority that corrects it.
`applyEdit` never errors — worst case it produces a transiently-approximate map.

## 2. Data types

```elm
type alias Edit =
    { offset : Int       -- char offset into the pre-edit document
    , removed : String   -- text deleted at offset
    , inserted : String  -- text inserted at offset
    }
```

Derived (not stored):

- `charDelta = String.length inserted - String.length removed`
- `lineDelta = newlines inserted - newlines removed`

`applyEdits : List Edit -> Document -> Document` folds `applyEdit` left-to-right; the
contract is that each edit's `offset` is in the coordinate space of the document produced by
the previous edit (the natural shape of a keystroke queue).

## 3. Algorithm (tiered, per the deltas)

Let `P = offset`, `dC = charDelta`, `dL = lineDelta`. Partition each block `B` by `P` vs
`B.begin`/`B.end`:

| Case       | Condition            | Action |
|------------|----------------------|--------|
| Above      | `B.end <= P`         | untouched |
| Containing | `B.begin < P < B.end`| `end += dC`, `contentEnd += dC`, `numberOfLines += dL` (begin/lineNumber unchanged) |
| Below      | `B.begin >= P`       | `begin/end/contentBegin/contentEnd += dC`, `lineNumber += dL`, recompute `id` |

**Tiering — the speed win:**

- `dL == 0` (typing a normal character — the dominant case): only integer `begin/end`
  shifts on below-blocks. **No `lineNumber`, no `id`, no expression touched at all**
  (expression offsets are line-relative, so they don't move; ids embed `lineNumber`, which
  didn't change).
- `dL /= 0` (newline added/removed): additionally shift `lineNumber` and recompute ids —
  block `id` (`"L-I"` → bump `L`) and every interior expression `id` (`"e-L.T"` → bump `L`)
  via the line-number component. Expression `begin/end` still untouched.
- `dC == 0 && dL == 0` (same-length overtype): effectively a no-op on metadata.

**Skip-prefix:** binary-search the forest (flattened, ordered by `begin`) to the first block
with `end > P`; only blocks from there down are visited. An edit near the bottom touches
almost nothing.

ID rewriting is pure string surgery on the leading line-number component, covered by
dedicated tests.

## 4. Module placement & public API

New module **`src/Edit/Map.elm`** (matches the `diff-update-map` branch) holding `Edit`,
`applyEdit`, `applyEdits`, and the internal shift/id helpers. Re-exported through
**`src/Scripta.elm`** as the public surface:

```elm
Scripta.Edit          -- the Edit type alias (re-exposed)
Scripta.applyEdit  : Edit -> Document -> Document
Scripta.applyEdits : List Edit -> Document -> Document
```

Forest traversal reuses the existing `mapForest`; a small `mapExprMeta` recurses expression
trees (only invoked when `dL /= 0`).

## 5. Error handling / robustness

- Returns `Document` (never `Result`) — the sync path must never break the editor.
- Defensive guards: negative `offset`, or `offset` past the last block's `end`, → return the
  document unchanged (nothing below to shift).
- We hold no source text, so `removed` is **not** validated against the document; it's
  retained in `Edit` purely for debugging/logging and future DOM-patch reuse.
- `contentBegin` of the containing block is left unshifted (edit assumed in the body, not the
  header line); if the edit lands in a header that's a structural edit anyway, corrected at
  reparse. Known approximation.

## 6. Testing strategy

- **Oracle property test (the core):** for a base document and a generated sequence of
  *structure-preserving* edits yielding text `T'`, compare
  `applyEdits edits (parse base)` against `parse T'`, matching blocks by forest position:
  - all block-level metadata equal for **every** block;
  - expression-level metadata equal for every block **except** the edited one(s).
- **Generators:** random insert/delete *within* existing lines (dL = 0) and random
  insert/delete of whole non-blank lines (dL ≠ 0); single- and multi-edit folds.
- **Unit tests:** each tier; edits at top / middle / bottom; at exact block boundaries;
  empty doc; single-block doc; multi-line verbatim/math blocks; `id` string-surgery in
  isolation; same-length overtype no-op.
- Built with `elm-test`; the naive per-edit fold (old "Approach 2") is included as a second
  oracle to cross-check the optimized path on the structure-preserving subset.

## Out of scope (noted for future work)

- **Document-absolute expression offsets.** Expression `begin/end` are line-relative today;
  the shift preserves that. Making them document-absolute would ease per-word DOM marking
  (the RL-sync follow-up) but is a larger change kept out of this feature.
- **Direct DOM attribute patching (JS/ports).** The shift map produced here could later drive
  an in-place DOM rewrite with no Elm re-render. `Edit.removed` is retained partly to enable
  that.
- **Coalescing sequential edits into one breakpoint map.** v1 folds `applyEdit` per edit
  (each O(skip-prefix + affected blocks)); a true single-pass coalescer is an optimization to
  add only if profiling demands it.
