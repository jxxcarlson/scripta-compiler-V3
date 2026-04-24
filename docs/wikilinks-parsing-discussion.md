# Wikilinks parsing — discussion of approach

Continues from `docs/wikilinks-dialogue.md`. Captures the preprocessor-vs-parser
debate and the decision to modify the parser.

## User's objection to a preprocessor

> I have a question about adding a preprocessor step. This is something that
> I have avoided so far because it means processing the entire file on each
> full parse. (( There is also the problem that parses may be either full or
> incremental. )). Another strategy would be to adapt the parser pipeline
> beginning with tokenizer. We would have to recognize as tokens the strings
> "[[" and "]]". The first is easy because no such string can exist in the
> current Scripta language. If such a string is recognized and assigned a new
> token, there comes the problem of finding the matching "]]" if there is
> one. Because this string may appear as part of a wikilink
> "[[202611141744 Plato]]" or as "[italic how is this [bold possible?]]". The
> meaning of "]]" in the first case is not the same as the meaning of it in
> the last case. I would prefer to modify the parser rather than install a
> preprocessor.

## Response

### First, a clarification on the preprocessor cost

The preprocessor as proposed runs inside `Parser.Expression.parse`
(`src/Parser/Expression.elm:39`), which is called **per expression-block**,
not per file — see the five call sites in `Parser/Pipeline.elm:84,93,126,187`
and `Parser/Table.elm:22`. So the regex pass is O(paragraph), not O(file),
and it slots into incremental parsing exactly the same way the tokenizer
does — they run on the same unit. That said, the parser-level solution is
cleaner, and the concern about paying extra per-paragraph work for a feature
that only matches a small fraction of inputs is legitimate.

### The `]]` ambiguity dissolves if we only tokenize `[[`

Key insight: we don't need `]]` to be a token. **Only `[[` gets a new token.**
`]` always tokenizes as a single `RB`, exactly as today. Matching of `[[…]]`
happens at the *symbol / match* layer, not at tokenization.

**Wikilink** `[[202611141744 Plato]]`:
Tokens: `DLB, S "202611141744", W, S "Plato", RB, RB`
Symbols (with `DL` counting as +2, `R` as -1): `DL ST W ST R R`
Running bracket count: `2, 2, 2, 2, 1, 0` → closes at end.

**Nested** `[italic how is this [bold possible?]]`:
Tokens: `LB, S "italic", W, …, LB, S "bold", W, S "possible?", RB, RB`
Symbols: `L ST W … L ST W ST R R`
No `DL` anywhere. Standard nested matching applies.

No ambiguity because the distinction happens at tokenization: the tokenizer's
`doubleLeftBracketParser` tries `[[` first, so `[[` produces `DLB`, but a
lone `[` still produces `LB`. There is no way for `]]` inside
`[… [… ]]` to be mistaken for a wikilink closer, because no `DLB` was opened
at the matching depth.

### Content rule: wikilinks are flat (text + whitespace only)

To keep match/reduce logic simple, wikilink bodies are restricted to `ST`
and `W` symbols — no nested `[`, no math, no code. Rationale:

- Zettelkasten wikilinks carry IDs and labels, not markup.
- Flat bodies let the matcher count RBs to depth 0 without worrying about
  contents.
- Inputs like `[[200 [foo]]]` become *malformed* wikilinks, which render
  literally.

### Touch points for the parser modification

1. `src/Parser/Tokenizer.elm` — add `doubleLeftBracketParser` before
   `leftBracketParser` in the alternatives list (line 384). Add `DLB ExprMeta`
   constructor to the `Token_` type.
2. `src/Parser/Symbol.elm` — add a `DL` symbol with value +2 (closed by two
   `R` symbols). Update `toSymbols` and `value`.
3. `src/Parser/Match.elm` — add a case in `isReducible` for `DL :: rest`
   requiring the rest to be `ST/W only :: R :: R`, and a case in
   `hasReducibleArgs` that handles a nested `DL` in args.
4. `src/Parser/Expression.elm` — add a reduction case for
   `DLB :: body :: RB :: RB` emitting `Fun "wl" body …`, plus handling for
   malformed bodies (emit literal `Text`).
5. `src/Render/Expression.elm` and `src/Render/Export/LaTeX.elm` — register
   `"wl"` renderer that reshuffles args to ilink's label-then-ID order.

### Trade-off summary

| | Preprocessor | Parser-level (DLB) |
|---|---|---|
| Files touched | 3 | 5 |
| Extra work per paragraph | one regex pass | single-char tokenizer extension |
| Source offset fidelity | lost across rewrite boundary | preserved |
| Interaction with incremental parse | same granularity as parser | native |
| Risk of regression in existing `[…]` | none | moderate — Symbol/Match is central |

The parser-level approach costs more in surface area but is philosophically
better — especially given the recent `BlockMeta contentBegin/contentEnd`
work which depends on accurate offsets.

## Resolved questions

1. **Malformed wikilinks with bracket-containing bodies** (`[[200 [foo]]]`):
   **render literally** (same as `[[]]` and `[[   ]]`).
2. **Nested wikilinks** (`[[a [[b]] c]]`): **render literally** (any DLB
   whose body isn't pure text-plus-whitespace is treated as literal source
   text).

Uniform rule: **any DLB whose body isn't pure text-plus-whitespace renders
as its original source text.**
