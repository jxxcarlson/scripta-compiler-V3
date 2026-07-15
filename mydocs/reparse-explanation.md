# What `reparse` Does

A walkthrough of `Scripta.reparse` and the incremental parser it drives, with
module/line references. Companion to `mydocs/diff-update-map-strategy.md` (the
`applyEdit` metadata-shift feature exists to fill the gap this document
describes).

## The entry point — `Scripta.reparse` (`src/Scripta.elm:251-267`)

```elm
reparse : Options -> Document -> String -> Document
```

It takes the **previous** `Document` (which carries `cache`, `accumulator`,
`forest`) and the **new** full source string, and produces a fresh `Document`.
It's the function an editor host calls on a (debounced) keystroke. All it really
does is unwrap the previous document and delegate to
`Parser.Forest.parseIncrementallySkipAcc`, passing the previous `cache` and
`(accumulator, forest)` as reuse material (`src/Scripta.elm:257-262`).

## The real work — `parseIncrementallySkipAcc` (`src/Parser/Forest.elm:140-180`)

### Step 1 — always re-parse the whole source into a forest (`Forest.elm:148-153`)

```
String.lines source
  |> Parser.PrimitiveBlock.parse              -- re-lex every line into primitive blocks
  |> Generic.ForestTransform.forestFromBlocks -- rebuild tree structure from indentation
  |> mapForest (toExpressionBlockCached cache)-- parse each block's inline expressions
  |> filterForest params.filter
```

This part runs every time. Note the consequence: **the entire document is
re-lexed and every block/expression gets its `begin`/`end`/`lineNumber`/`id`
regenerated from scratch.** That is the cost `applyEdit` was built to avoid
between reparses.

The one saving here is the **expression cache**
(`toExpressionBlockCached`, `Forest.elm:109/152`): it's a `Dict` keyed by each
block's `sourceText` (`ExpressionCache` in `V3.Types.elm:24-25`). If a block's
raw text is unchanged, its already-parsed inline expression tree is reused
instead of being re-tokenized and re-parsed.

### Step 2 — decide whether to skip the accumulator pass (`Forest.elm:155`)

The "accumulator" (`V3.Types.elm:155-177`) is the document-wide pass that
computes section numbers, cross-references, footnotes, theorem counters, the
bibliography, etc. (`Generic.Acc.transformAccumulate`). It's the expensive
global pass. `reparse` skips it when **both** conditions hold:

- `forestStructureMatches` (`Forest.elm:185-207`) — the new forest has the same
  shape: same `heading` type and `indent` at every position, same children
  counts. (i.e. you didn't add/remove/split a block or change a heading.)
- `allChangedBlocksAreAccIndependent` (`Forest.elm:212-256`) — every block whose
  `sourceText` actually changed is "accumulator-independent": a plain paragraph
  or a `code` block that contains none of
  `footnote/term/index/cite/ref/eqref/label` (`accDependentNames`,
  `Forest.elm:261-263`). Editing such a block can't shift any numbering or
  references elsewhere.

**Fast path** (`Forest.elm:156-163`): `spliceForest` (`Forest.elm:289-309`)
walks old and new in lockstep — for each block, keep the **old** version (with
its accumulator-derived numbering intact) if `sourceText` is unchanged,
otherwise take the **freshly parsed** one (safe, because it's acc-independent).
The previous `accumulator` is reused verbatim, `accWasSkipped = True`.

**Slow path** (`Forest.elm:165-180`): structure changed or an edited block
affects numbering/references → run the full `Generic.Acc.transformAccumulate`
over the whole forest, rebuilding all numbers/refs, `accWasSkipped = False`.

Either way it rebuilds the expression cache (`buildExpressionCache`) and returns
the new `cache`, `acc`, and `forest`.

## How it relates to `parse` and to `applyEdit`

- `parse` (`src/Scripta.elm:231-244`) is the cold path — `parseIncrementally`
  with an empty cache and no forest to reuse. Used for initial load / document
  switch.
- `reparse` is the warm path — same lexing work, but reuses the expression cache
  and (when safe) the accumulator.
- **`applyEdit`** does none of that lexing/parsing — it just shifts existing
  metadata offsets. That's the division of labor: `applyEdit` keeps the sync map
  numerically correct per keystroke for pennies; `reparse` on a longer debounce
  re-derives authoritative content, structure, numbering, and IDs.

The key thing to internalize: even the "incremental" `reparse` always re-lexes
the full source and regenerates all positional metadata and IDs — its savings
are in skipping inline-expression re-parsing (cache) and the global numbering
pass (accumulator skip), **not** in avoiding the whole-document walk. That is
exactly the gap `applyEdit` fills.

## Is the expression parse applied only to changed or new blocks?

Yes — for the **inline-expression** parse specifically.
`toExpressionBlockCached` (`src/Parser/Pipeline.elm:50-57`):

```elm
case Dict.get block.meta.sourceText cache of
    Just cachedBody -> toExpressionBlockWithBody cachedBody block   -- reuse parsed expressions
    Nothing         -> toExpressionBlock block                       -- actually parse
```

The cache is keyed by `block.meta.sourceText` (`buildExpressionCache`,
`src/Parser/Forest.elm:318-323`). So the inline-expression parse runs only on a
**cache miss** — a block whose exact raw text isn't in the previous document's
cache, i.e. **changed or new blocks**. Unchanged blocks reuse their
already-parsed expression tree.

Two precisions so the conclusion isn't over-read:

1. **It's the *expression* parse only.** The whole document is still re-lexed
   into primitive blocks and re-assembled into the forest every reparse
   (`PrimitiveBlock.parse` → `forestFromBlocks`, `Forest.elm:150-151`), which
   regenerates every block's `begin`/`end`/`lineNumber`/`id`. The cache
   short-circuits the *inner* tokenize-and-parse of a block's content, not the
   outer lexing/structuring.

2. **The cache key is exact `sourceText`, not position.** So a block whose text
   is unchanged but which *moved* (e.g. a line inserted above it) is still a
   **hit** — its expressions aren't re-parsed even though its block-level offsets
   shift. Conversely, a one-character edit makes that block's `sourceText` a new
   key → miss → re-parse. Because the key is exact text, two blocks with
   identical text share one entry, and reverting a block to its
   immediately-previous text re-hits.

So: **inline-expression parsing is confined to changed/new blocks; everything
else (lexing, forest structure, all positional metadata) is still recomputed
wholesale** — which is the part `applyEdit` sidesteps.
