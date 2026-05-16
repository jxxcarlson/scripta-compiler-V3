# API Design & RL-Sync Discussion

**Date:** 2026-05-16
**Status:** Discussion notes + decisions. Companion to
`docs/superpowers/specs/2026-05-16-scripta-compiler-api-design.md`.
**Scope:** How the proposed public API interacts with editor sync (LR / RL),
rendered-text marking, and the rendering performance constraints that follow.

This document records a design conversation prompted by one question:
*"Would the new API handle things like LR and RL sync?"* It captures the
analysis, the options considered, and the decisions reached at the end.

---

## 1. Background: the proposed API

The recommendation in `2026-05-16-scripta-compiler-api-design.md` replaces the
leaky `( Accumulator, List (Tree ExpressionBlock) )` tuple with three public
modules — `Scripta`, `Scripta.Document`, `Scripta.Markup` — an opaque
`Document`, opaque `Options` with `with*` builders, `String`-based entry
points, a trimmed `Event` type, `mapEvent`, and a headless `compileToString`.

The question below is whether that surface supports the editor's two-way sync
between the source pane (CodeMirror) and the rendered pane.

---

## 2. Sync has two halves, covered very unevenly

### 2.1 LR sync (editor → rendered): covered

`matchingIdsInAST` (`scripta-app-v4/frontend/src/Editor.elm:44-57`) filters AST
blocks whose `meta.sourceText` contains the selected text and returns their
ids. The spec explicitly replaces this with:

```elm
Scripta.Document.idsContainingSource : String -> Document -> List String
```

A clean, direct fit. `sourceOfId : String -> Document -> Maybe String` covers
the reverse lookup. ✅

### 2.2 RL sync (rendered → editor): not addressed by the API design

RL sync **does not go through Elm today.** It is implemented entirely in JS —
`setupRLSync` in `scripta-app-v4/frontend/codemirror-element.js:26954-27137`.
It reads DOM attributes off the rendered elements:

- the element `id`, decoded by `parseLineNumber`
  (`codemirror-element.js:26966`) — expressions use `e-N.T`, blocks use `N-I`,
  where `N` is a 0-indexed line number;
- `data-begin`, `data-end` — column offsets within the line
  (`codemirror-element.js:27071-27072`);
- `data-lines` — block line span (`codemirror-element.js:27073`).

So RL sync depends on a **DOM-attribute contract**: the rendered HTML must keep
emitting `id` / `data-begin` / `data-end` / `data-lines` with exactly those
encodings. The proposed API never mentions this.

That matters because the spec's central thesis is *"the entire internal
representation is currently public API — make it opaque."* This attribute
scheme is precisely such an implicit public contract, and right now it is
invisible — neither documented nor protected.

Two decisions the spec needs:

1. **Is the rendered-HTML attribute scheme a committed public contract?**
   `render` / `compile` produce `Output Event` (live `Html`), so as long as the
   renderer keeps emitting those attributes, RL sync keeps working — but
   nothing in the API *says so*.
2. **Does `compileToString` retain `id` / `data-*` attributes?** The spec calls
   its output "plain HTML strings." RL sync needs those attributes. Decide
   whether the headless path is sync-capable or explicitly sync-free.

### 2.3 Current state of the renderer's sync hooks

Important detail discovered while investigating: **RL sync today is 100% JS.**
The Elm click handlers in `Render/Utility.elm` — `rlSync` (`:15-37`) and
`rlBlockSync` (`:40-62`) — are **commented out** ("JXXC Temporary Edit"). The
renderer only emits the *DOM attributes*; all detection, id-parsing, and
highlighting happen in JS. `renderText` (`Render/Expression.elm:46-50`) emits
**one** `<span>` per text run with **one** `begin`/`end` pair.

---

## 3. A possible improvement: route RL sync through `Document`

RL sync currently re-derives line numbers by string-parsing element ids in JS
(`parseLineNumber`). It could instead route through the `Document` — e.g. a
typed query:

```elm
Scripta.Document.positionOfId : String -> Document -> Maybe { line : Int, begin : Int, end : Int }
```

so the `e-N.T` / `N-I` id encoding stops being a cross-language contract. That
would make RL sync as first-class as LR sync: the renderer attaches an Elm
`onClick` to each syncable element, the app receives a clean `Event`, looks the
position up in the `Document`, and sends a port message to CodeMirror — which
shrinks to just the highlight call.

**This is the agreed direction** (see §6, Decisions) — but deferred. See §6.

---

## 4. Word-level and selection-level precision via richer marking

The current JS sync has **word-level precision** — it uses `caretRangeFromPoint`
(`codemirror-element.js:27094`) to detect which word inside an expression was
clicked — plus drag-**selection** sync via `getSelection()`. A pure-Elm
`onClick` only knows which *element* was clicked, not the pixel position inside
it. So at first glance, going "first-class Elm" looks like it would cost
precision.

It need not. Richer marking trades a runtime DOM/pixel problem for a
compile-time arithmetic problem — the kind of work that belongs in Elm.

### 4.1 The current limitation

`renderText` emits one `<span>` per text run with one `begin`/`end` pair.
Because the span covers the whole run, JS *must* use `caretRangeFromPoint` to
recover sub-span position. That is the only reason pixel hit-testing exists.

### 4.2 Word-level: fully solvable by marking

Split `renderText` so each word is its own span with its own range:

```elm
-- word k occupies [meta.begin + offsetK, meta.begin + offsetK + len - 1]
Html.span [] (wordsWithOffsets str |> List.map renderWordSpan)
```

The offsets are pure arithmetic — `ExprMeta` carries `begin`, and the string is
in hand. Each word span gets `id` + `data-begin` / `data-end`. Then an Elm
`onClick` on a word span *is* word-level precision: the element clicked already
carries its exact source range. Zero JS, no `caretRangeFromPoint`.

### 4.3 Selection-level: solvable too, two variants

A selection only needs its two **endpoints** — the first and last marked
element it touches. With per-word marking you don't need character offsets from
the browser; the endpoint word-spans already carry them, and the `Document`
computes the union range.

- **Pure Elm:** `onMouseDown` / `onMouseUp` on word spans → start id / end id →
  `Document` computes the span. No `getSelection()` at all. It snaps to word
  boundaries (which is the granularity anyway). Caveats: keyboard selection
  (shift+arrows) fires no mouse events, and a mouseup landing on
  whitespace/margin needs a nearest-word fallback.
- **~5-line JS shim:** for exact intra-word character offsets or keyboard
  selection, keep a tiny `selectionchange` handler that reads `getSelection()`,
  walks `anchorNode` / `focusNode` up to the nearest marked element, and emits
  **two ids** to a port. All position logic still lives in Elm/`Document` — the
  JS becomes a dumb id-harvester, not the ~80-line `setupRLSync` of today.

### 4.4 Cost and mitigations

Math and verbatim stay expression-level — you cannot meaningfully word-split
rendered KaTeX (`renderVFun`, `Render/Expression.elm:68-96`), and intra-formula
sync is not useful anyway.

The real cost is DOM node count — one span per word. Mitigations:

- Make word-splitting **opt-in via `Options`** (e.g. `withSyncMarking True`) —
  read-only viewers pay nothing. Fits the opaque-`Options` / builder direction.
- Word-split only blocks **in / near the viewport or near the cursor**. Distant
  blocks stay expression-level; RL sync from them snaps to expression
  granularity, which is fine since fine-grained sync only matters where you are
  editing. This caps total word-spans at *viewport size* regardless of document
  length.

---

## 5. Performance of one-span-per-word

There are two distinct costs, and they behave very differently.

### 5.1 Static cost (initial render, layout, memory) — scales with total words

A `<span>` per word is ~2 DOM nodes. Plain spans with only `id` + `data-*`
attributes and no per-word inline styles are cheap. Rough thresholds:

| Total words | Effect |
|---|---|
| ~2,000 | imperceptible |
| ~10,000 | initial render adds tens of ms; scrolling smooth |
| ~30,000+ | initial render and memory (tens of MB of nodes) become noticeable — consider viewport windowing |

Lighthouse flags DOM trees around ~1,500 nodes, but that is a soft SEO
heuristic; modern browsers paint 50k-node documents without trouble.

### 5.2 Per-keystroke cost (vdom diff) — this is what causes *lag*

If the whole document re-rendered on every keystroke, the diff would scale with
total word-spans and lag would appear around ~3,000–5,000 word-spans.

**But the renderer already prevents that.** `renderTreeLazy`
(`Render/Tree.elm:22-24`) wraps every tree node in `Html.Lazy.lazy3`, and
`Render/Tree.elm:33` uses `Html.Keyed`. With lazy + keyed, a keystroke
re-renders and re-diffs only the block whose content changed. The relevant
number becomes **words per block** (50–200 → 100–400 nodes → well under 1ms).
There is effectively no document-size limit on typing performance — *provided
laziness actually fires* (see §6 below).

### 5.3 Summary: how many words is "too many"?

| Scenario | Threshold for lag |
|---|---|
| Typing, with working `lazy` / `keyed` | bounded by one block (~200 words) — never a problem |
| Typing, if laziness is broken (full re-render) | ~3,000–5,000 word-spans total |
| Initial page render / memory | comfortable to ~10k words; heavy past ~30k |

The honest risk is not the steady state — it is accidentally breaking
laziness, which is the subject of the next section.

---

## 6. Referential stability — how `Html.Lazy` actually behaves

`Render/Tree.elm:22-24` calls `Html.Lazy.lazy3 renderTreeWrapped params acc tree`.
For laziness to fire, the function **and all three arguments** must be
referentially stable between renders.

### 6.1 How Elm's `lazy` equality works

`Html.Lazy.lazyN` stores `[func, arg1, …, argN]` and on the next render
compares each slot with JS `===`:

- **The function is compared too.** A lambda or partially-applied closure built
  inside `view` is a fresh allocation each render → `lazy` never fires. It must
  be a **top-level named function**. `renderTreeWrapped` qualifies.
- **Primitives** (`Int`, `Float`, `Bool`, `Char`, `String`) compare equal by
  *value* — JS `===` on primitives is value equality. Always stable.
- **Everything else** — records, custom types, tuples, lists, `Dict`, `Tree`,
  `Html` — compares equal **only by reference identity**: the literally-same
  allocation as last render. There is **no deep/structural equality**.

So `params` (record), `acc` (record), and `tree` (`Tree`) must each be the same
object the previous render saw, or that subtree re-renders.

### 6.2 What you must do — in priority order

1. **Stop threading `Accumulator` through the lazy boundary.** `acc` is passed
   to every node (`renderForest`, `Render/Tree.elm:19`). `parse` produces a
   fresh `Accumulator` on every edit, so a fresh `acc` differs for *every*
   block — laziness is currently defeated globally, regardless of tree
   stability. Fix: after parsing, **bake the accumulator-derived data the
   renderer needs (numbers, resolved cross-references, macros) into each
   `ExpressionBlock`**, and render from the self-contained block. Then `acc`
   leaves the `lazy` signature entirely.
2. **Build `Options` / `params` once and store it in the model.** Constructing
   it freshly in `view` (`defaultOptions |> withTheme …`) reallocates it every
   frame. Build it in `update` when inputs change; keep it in the model.
3. **The incremental parser must preserve reference identity of unchanged
   blocks/trees.** Elm does no automatic structural sharing — reuse means
   *physically returning the previous Elm value*. When block N is edited, the
   parser must return a forest in which blocks ≠ N are the exact previous
   values, not freshly-constructed equal ones.
4. **Keep the render function top-level** (already satisfied) and do not later
   wrap it in an adapter lambda.

### 6.3 The extent — hard limits you cannot engineer past

1. **Reference identity only.** No value-based laziness for compound data; a
   block must be physically reused, not reconstructed-equal.
2. **Any cross-cutting argument is a global kill-switch.** While `acc` (or
   anything document-wide) is in the `lazy` signature, one edit invalidates
   everything. The fix is removing it from the signature, not stabilizing it.
3. **Edits that shift line numbers re-render everything downstream —
   unavoidably.** `block.meta` carries absolute `lineNumber` / `begin` / `end`,
   and RL sync *needs* those in the output. Inserting a line at the top
   legitimately changes every subsequent block's meta. The guaranteed cost
   profile is therefore:
   - in-place typing inside a block → O(one block);
   - inserting/deleting lines → O(blocks after the insertion point);
   - an edit that renumbers cross-references → re-renders the blocks whose
     numbers shifted.
   All three are correct and minimal; only the first is "cheap."
4. **`parse` always allocates a new `Document`.** Sharing inside it is
   deliberate parser work; the type system will not enforce it.

Achievable guarantee: laziness fires for exactly those blocks whose
self-contained value (parsed content + baked accumulator data + position
metadata) is reference-preserved from the previous render — i.e. every block
the edit did not semantically touch. Ordinary typing becomes O(block)
regardless of document size. Line-shifting edits remain O(downstream); that is
the hard floor.

### 6.4 Safeguard

Broken laziness is **silent** — output stays correct, only slow. Add a
temporary render counter or `Debug.log` inside `renderTreeWrapped` and confirm
that typing in block N logs only block N. Without that check, a future change
that reintroduces a fresh `acc` or rebuilds `params` will quietly kill
performance with no visible symptom until documents grow large.

---

## 7. Decisions

1. **LR sync** — adopt `Scripta.Document.idsContainingSource` as the
   replacement for `matchingIdsInAST`. (Already in the API spec.)

2. **RL sync — keep as-is (JS) for now.** Do **not** rework RL sync during the
   new-API implementation. The current `setupRLSync` JS and the
   `id` / `data-begin` / `data-end` / `data-lines` DOM-attribute contract stay.
   The renderer must therefore continue emitting those attributes unchanged
   while the new API is built.

3. **Route RL sync through `Document` — agreed direction, deferred.** The
   `positionOfId` design in §3 is the intended end state: RL sync should
   eventually route through a typed `Document` query instead of string-parsing
   ids in JS. To be **reconsidered and implemented after the new API has been
   implemented and tested.**

4. **Word-level / selection-level marking (one span per word, §4) — deferred.**
   Also to be reconsidered after the new API is implemented and tested, as part
   of the same RL-sync follow-up phase.

5. **Referential stability (§6) is in scope for the new API now.** Because the
   new API introduces the opaque `Document` and the `parse` / `render` split,
   the §6.2 requirements — drop `Accumulator` from the `lazy` signature, store
   `Options` in the model, preserve block identity in incremental parsing —
   must be honored as the API is designed. Getting `Document` right depends on
   it.

---

## 8. Comments and recommendations

These are notes for the deferred RL-sync follow-up and the immediate API work.

- **Preserve the RL-sync attribute contract explicitly.** Even though RL sync
  stays in JS, the API spec should *name* `id` / `data-begin` / `data-end` /
  `data-lines` as a contract the renderer currently honors, so a future "make
  the rendering internal" change does not silently break sync. An undocumented
  contract is the exact problem the new API is meant to eliminate — keeping RL
  sync in JS does not exempt it; it just defers the cleanup.

- **`compileToString` and sync attributes.** Decide and document whether the
  headless string output keeps the `id` / `data-*` attributes. Recommendation:
  keep them — they are inert in a non-editor context and harmless, and dropping
  them would make the headless path silently sync-incapable.

- **Sequencing of the follow-up.** The deferred phase (Decisions 3 + 4) is
  naturally one project: §3 (`positionOfId` + Elm `onClick` handlers) and §4
  (per-word marking) are complementary. Word marking without Document routing
  still leaves id-parsing in JS; Document routing without word marking still
  caps precision at expression level. Do them together.

- **`withSyncMarking` as an `Options` builder.** When the follow-up happens,
  per-word marking should be an opt-in `Options` builder (§4.4) — this is
  exactly the kind of capability the opaque-`Options` design was chosen to
  accommodate without breaking callers. Worth reserving the name now alongside
  the commented-out `withCustomBlock`.

- **Re-enable, don't delete, `rlSync` / `rlBlockSync`.** The commented-out Elm
  handlers in `Render/Utility.elm:15-62` are the natural attachment point for
  the future Elm `onClick` path. Leave the scaffolding; the follow-up will
  revive it (emitting a clean `Event`, not the old `SendMeta` / `SendBlockMeta`).

- **Verify laziness as part of API acceptance.** The §6.4 render-counter check
  should be a checklist item when the new `Document` lands — broken laziness is
  invisible until documents are large, and the API redesign is precisely the
  change most likely to introduce a fresh-`acc`-per-edit regression.

- **Line-shifting cost is inherent — set expectations.** Per §6.3(3), no API
  shape makes a top-of-document line insertion cheap while absolute positions
  appear in the output. If that ever becomes a felt problem, the only real
  lever is viewport windowing (render only visible blocks), not a cleverer
  `lazy` arrangement.
