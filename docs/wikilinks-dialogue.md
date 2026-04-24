# Wikilinks proposal — analysis dialogue

Parked for later. This file captures the original proposal and the analysis
dialogue so the work can be picked up again without re-deriving the context.

## Original questions

I am considering adding a new parseable element to the compiler. The idea is
to permit source text of the form

    [[2027061366]] and  [[2027061366 Philosophy Notes]].

The first would render in the same way as `[ilink 2027061366 2027061366]`.
The second as `[ilink Philosophy Notes 2027061366]`.

The rationale is to make the source file text compatible with zettelkasten
systems. I would like you to analyze this proposal with respect to the
integrity and proper functioning of the compiler, since
`[element-name element-body]` is fundamental to the current version, and both
`[[]]` and `[[some text ...]]` show up as `?!?` with a coloration indicating a
parser error in the rendered text for any consumer which implements rendering
of scripta documents. Thus:

- Would this change interfere with the normal use of `[]` and
  `[element-name element-body]`?
- If not, how can we prevent `[[]]` and `[[some text ...]]` rendering as
  errors?

## Analysis

Read the tokenizer, the expression reducer, `Match.isReducible`, and the
error-recovery path to understand current behavior.

### How `[...]` is parsed today

- **Tokens**: `[` → `LB`, `]` → `RB`, one character each
  (`Parser/Tokenizer.elm:437-446`). `[[` is already two `LB` tokens in
  sequence.
- **Reducibility** (`Parser/Match.elm:21-30`): the only accepted expression
  shape is `L :: ST :: rest :: R` — i.e. left-bracket, a **string identifier
  as the head**, args, right-bracket. A stack starting `L :: L :: …` falls
  through to `_ -> False`. So `[[ anything ]]` is structurally **unreducible**
  by design.
- **Error recovery** (`Parser/Expression.elm:327-401`): explicit cases exist
  for `[]`, `[name` (no close), `[ ` (space after `[`), etc. No case matches
  `LB :: LB :: …`, so `[[…]]` hits the catch-all `_ ->` branch at line
  396-401 that emits `errorMessage " ?!? "`. That is exactly the rendering
  the user reports.

### 1. Would adding `[[ID]]` / `[[label… ID]]` interfere with `[]` and `[element-name element-body]`?

**No, with one caveat.** The new syntax lives entirely on ground that today
is already guaranteed to be a parse error:

- `[[` currently produces an unreducible stack (Match rejects `L :: L :: …`).
- No legitimate current source text uses `[[` or `]]` successfully — the
  claim "if you see `[[` today, it's already broken" is load-bearing here
  and is backed by `isReducible`.
- The caveat: `]]` can arise innocently as the *boundary* between two
  adjacent bracket expressions, e.g. `[foo [bar]]` — if nested bracket
  expressions are supported. Looking at `Match.hasReducibleArgs`, it does
  recurse into `L :: …` args (line 39-40), so nested `[...]` inside args is
  in principle reducible. A greedy `]] → DoubleRB` tokenizer would
  mistokenize that. Worth confirming whether nested bracket expressions are
  used anywhere in real source, but this is the one real collision to watch.

### 2. How to avoid the `?!?` rendering for `[[…]]`

Three implementation layers, in increasing invasiveness:

- **A. Pre-tokenization rewrite.** Before the tokenizer runs on a line,
  string-rewrite `[[ID]]` → `[ilink ID ID]` and `[[label… ID]]` →
  `[ilink label… ID]` (last whitespace-separated word is the ID). Zero
  parser changes; existing `ilink` machinery handles rendering (web at
  `Render/Expression.elm:151,488`, LaTeX at
  `Render/Export/LaTeX.elm:1233,1487`). Malformed cases (`[[]]`, `[[  ]]`)
  fall through unrewritten and keep today's `?!?` behavior — which is
  probably what you want.
  - *Cost*: text transform shifts source offsets, so the recent
    `BlockMeta contentBegin/contentEnd` / inverse-transform work won't get
    accurate positions for the rewritten span unless you track the edit.
- **B. Tokenizer-level `DLB`/`DRB` tokens + a new reducer rule** that folds
  `DLB args DRB` into `Fun "ilink" …`. Requires updates in
  `Parser/Tokenizer.elm`, `Parser/Symbol.elm`, `Parser/Match.elm`, and the
  reducer in `Parser/Expression.elm`. Type-safe, preserves offsets, but
  more surface area and more edge cases (nesting, adjacency with regular
  `]]`).
- **C. Add a recovery rule** for `LB :: LB :: … :: RB :: RB` in
  `recoverFromError`. Wrong layer — recovery is for repairing errors, not
  accepting a legitimate grammar addition. Ruled out.

**Recommendation: approach A for the first pass.** It's the smallest change
with the most easily defensible "no interference" argument (pure
`String → String`, unit-testable exhaustively, no parser state touched).
Promote to B later if source-offset fidelity for `[[…]]` spans becomes
important for sync or inverse transforms.

## Open questions before writing a spec — answered

1. **ID form**: not restricted for now. Any token is acceptable as the ID.
2. **Empty/whitespace-only forms**: `[[]]` and `[[   ]]` should render
   **verbatim** — literally as `[[]]` and `[[   ]]` — to signal to the
   author that these are incomplete constructions. (Not an error, not
   silently suppressed.)
3. **Scope**: recognized inside any block that currently runs the
   expression parser.
4. **Nested brackets**: `[outer [inner]]` constructs are **common**, e.g.
   `[bold stuff [italic more stuff]]`. This means the boundary `]]` of
   nested bracket expressions must not be mistokenized as a wikilink
   closer. **Approach B (greedy tokenizer-level `]] → DRB`) is therefore
   ruled out.** Approach A (pre-tokenization rewrite) remains viable
   because a rewrite regex of the form `\[\[([^\]]*)\]\]` only matches
   when `[[` and `]]` bracket a region containing no `]`, which excludes
   the `[bold [italic x]]` case (that starts with a single `[`, not `[[`).

## Additional design context: `zku` identifiers

The author intends to add a parallel `zku` identifier to the document type
and the document table. Shape:

    USERNAME-YYYYMMDDmmss

This form is distinguishable from current Scripta identifiers by its
structure (username prefix, hyphen, timestamp), so the linking mechanism
can accept either a legacy Scripta ID or a `zku` ID interchangeably.

Rendering contract for wikilinks with a zku:

    [[USERNAME-YYYYMMDDmmss Document title ...]]

renders identically to

    [ilink Document title ... IDENTIFIER]

where `USERNAME-YYYYMMDDmmss` and `IDENTIFIER` resolve to the same
document. Resolution from `zku` to the document the `ilink` renderer
expects happens at lookup time, not at parse time — the wikilink rewrite
can stay purely syntactic.

### Implication for the rewrite rule

Earlier I described the rewrite as

    [[ID]]           → [ilink ID ID]
    [[label... ID]]  → [ilink label... ID]

with the convention that the **last** whitespace-separated token is the
ID. With zku IDs of the form `USERNAME-YYYYMMDDmmss`, the user-facing
form becomes

    [[USERNAME-YYYYMMDDmmss Document title ...]]

where the ID is now the **first** token, not the last. Two options to
reconcile:

- **(i)** Detect ID position by form: if the first token matches the zku
  shape (regex `\w+-\d{12}` or similar), treat it as the ID and the rest
  as the label. Otherwise, fall back to last-token-is-ID for legacy
  Scripta IDs.
- **(ii)** Require the ID to always be in the same position (either
  always first or always last) regardless of ID flavor. Simpler; breaks
  the zettelkasten convention of "ID first".

Decision deferred until this work is picked up again.
