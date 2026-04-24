# Wikilinks — design

**Status:** approved design, pending implementation plan.
**Related:** `docs/wikilinks-dialogue.md`, `docs/wikilinks-parsing-discussion.md`.

## Goal

Add a new source-level construct `[[...]]` that renders identically to
`[ilink ...]`, compatible with zettelkasten-style document linking. Preserve
all existing `[…]` and `[outer [inner]]` behavior. Render malformed
wikilinks literally so authors see what they typed.

### Examples

| Source | Renders as |
|---|---|
| `[[2027061366]]` | `[ilink 2027061366 2027061366]` |
| `[[2027061366 Philosophy Notes]]` | `[ilink Philosophy Notes 2027061366]` |
| `[[jxxcarlson-202611141744]]` | `[ilink jxxcarlson-202611141744 jxxcarlson-202611141744]` |
| `[[jxxcarlson-202611141744 Plato]]` | `[ilink Plato jxxcarlson-202611141744]` |
| `[[]]` | `[[]]` in red |
| `[[   ]]` | `[[   ]]` in red |
| `[[a [b] c]]` | `[[a [b] c]]` in red |
| `[[a [[b]] c]]` | whole outer in red (malformed due to inner `[[`) |
| `[italic how is this [bold possible?]]` | unchanged from today |
| `[bold stuff [italic more stuff]]` | unchanged from today |

## Architecture

Parser-level treatment. **Only `[[` gets a new token (`DLB`).** `]` remains a
single-character `RB` token. Matching of `[[…]]` happens at the symbol / match
layer by counting brackets (DLB = +2, RB = -1). Wikilink bodies are
restricted to text + whitespace only. Any malformed `[[…]]` span is emitted
as literal source text.

### Why only `[[`, not also `]]`

`]]` is ambiguous at the character level (wikilink closer vs. two nested
close brackets). Making it a token forces that ambiguity to be resolved in
the tokenizer, where no context is available. Instead, `]]` stays as two
`RB` tokens and the matcher decides their role based on whether a `DLB` is
currently open at that depth. See `docs/wikilinks-parsing-discussion.md`
for the full analysis.

## Components

### 1. Tokenizer — `src/Parser/Tokenizer.elm`

**Add** a new `Token_` constructor `DLB ExprMeta`.

**Add** `doubleLeftBracketParser : Int -> Int -> TokenParser` that matches
the two-character literal `[[`. Uses `Parser.symbol (Parser.Token "[[" …)`
similar to `parenMathOpenParser` at line 394.

**Order-sensitive**: insert `doubleLeftBracketParser` in the alternatives
list (line 384) **before** `leftBracketParser`. `elm/parser` tries
alternatives in order, so `[[` wins over `[`.

**Meta**: the `DLB` token spans two characters. Set
`end = start + 1` (mirroring `parenMathOpenParser`).

### 2. Symbol — `src/Parser/Symbol.elm`

**Add** a new `Symbol` constructor `DL`.

**Extend** `value`:

    DL -> 2

**Extend** `toSymbol`:

    DLB _ -> DL

This makes `DL` open with weight 2, closed by two `R` symbols. Count-based
matching in `Parser.Match.match` continues to work without further changes.

### 3. Match — `src/Parser/Match.elm`

**Extend** `isReducible` with a new case recognizing a reducible wikilink:

    DL :: rest ->
        case lastTwo rest of
            Just ( R, R ) ->
                isFlatBody (dropLast2 rest)
            _ ->
                False

Helper `isFlatBody : List Symbol -> Bool` returns `True` if every symbol is
`ST`. (Empty body returns `True` — the outer `isReducible` already filters
`WS` on line 12, so a whitespace-only body appears empty here. Empty/
whitespace-only bodies pass the structural check and are classified as
malformed at the reduction step.)

**Extend** `hasReducibleArgs` with a case for `DL :: _`:

    DL :: _ ->
        reducibleAux symbols

This lets a wikilink appear as a child inside a normal bracket expression
(e.g., `[foo [[bar]] baz]`). `split` uses `match`, and `match` uses the
bracket-count algorithm which already handles `DL`'s value-2 weight
correctly. No new matching code needed.

**Rule for malformed wikilinks**: when `DL :: … :: R :: R` appears but the
body is not flat (contains `L`, `DL`, `M`, `C`, or `E`), `isReducible`
returns `False`. The expression parser's recovery path then handles this
as a literal text emission (see §4).

### 4. Expression parser — `src/Parser/Expression.elm`

**Extend** `pushOrCommit` to push `DLB _` onto the stack, same as `LB _`
(line 150-151).

**Extend** `reduceTokens` to handle `DLB :: body :: RB :: RB`:

    (DLB dlbMeta) :: rest ->
        case extractWikilinkBody rest of
            Just (body, closeMeta) ->
                if hasNonWhitespace body then
                    [ Fun "wikilink"
                        (wikilinkArgs body)
                        (boostMeta lineNumber dlbMeta.index { dlbMeta | end = closeMeta.end })
                    ]
                else
                    -- empty or whitespace-only body: malformed, render red
                    [ redLiteral lineNumber dlbMeta closeMeta (originalText dlbMeta rest) ]
            Nothing ->
                -- body contains nested brackets / math / code: malformed
                [ redLiteral lineNumber dlbMeta (lastRBMeta rest) (originalText dlbMeta rest) ]

where:

- `extractWikilinkBody : List Token -> Maybe (List Token, ExprMeta)`
  returns `(body, closeMeta)` if the token list matches `body :: RB :: RB`
  and `body` is flat (only `S` and `W` tokens); otherwise `Nothing`.
  `closeMeta` is the meta of the final `RB`.
- `hasNonWhitespace : List Token -> Bool` — `True` iff body contains at
  least one `S` token.
- `wikilinkArgs : List Token -> List Expression` — converts flat body
  tokens to a list of `Text`/whitespace `Expression`s in source order
  (first = ID, rest = label words).
- `originalText : ExprMeta -> List Token -> String` reconstructs the
  original source span covering `[[ … ]]` by slicing the source string
  from `dlbMeta.begin` through the last `RB`'s `end`. The expression
  parser currently receives source as a `String` in `parse`; stash it
  on `State` so `reduceTokens` can read it. *(Alternative: reconstruct
  by joining token `S`/`W` contents with inferred whitespace; less
  reliable for recovery paths.)*
- `redLiteral : Int -> ExprMeta -> ExprMeta -> String -> Expression`
  constructs `Fun "red" [ Text source … ] …` with meta spanning the
  full `[[ … ]]` region.

**Extend** `reduceRestOfTokens` with a case for `DLB` that mirrors the
existing `LB` case at line 290-296: attempt `splitTokens`, reduce the
wikilink segment, recurse on the rest.

**Extend** `recoverFromError` with a case for an unreducible `DLB` at the
head of the reversed stack — emit a `redLiteral` expression for the span
from the `DLB` to the current read position, and advance. Covers cases
like `[[unclosed`.

**Update** `Token.type_` if there's a corresponding `TDLB` type constant
needed for `isExpr` / related helpers. (Line 413-418 — inspect during
implementation.)

### 5. Renderer (web) — `src/Render/Expression.elm`

**Register** `"wikilink"` in `markupDict` (insert near `ilink` at line 151).

**Add** `renderWikilink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg`:

    renderWikilink params acc args meta =
        case args of
            [ Text s _ ] ->
                -- single non-whitespace token: ID doubles as label
                renderIlinkFromParts params acc meta s s

            (Text first _) :: rest ->
                let
                    label = rest
                        |> List.map exprText
                        |> String.concat
                        |> String.trim
                in
                renderIlinkFromParts params acc meta first label

            _ ->
                -- defensive: parser guarantees wikilink args are flat non-empty text
                Html.text "[[?]]"

`renderIlinkFromParts` factors out the rendering logic from `renderIlink`
(line 488) so both entry points share it.

Malformed wikilinks do not reach `renderWikilink` — the parser emits them
as `Fun "red" [Text source]`, which the existing `red` renderer (line 138)
handles. No empty/whitespace case in this function.

### 6. Renderer (LaTeX export) — `src/Render/Export/LaTeX.elm`

**Register** `"wikilink"` in the markup dict (line 1233).

**Add** `wikilink : List Expression -> String`:

    wikilink args =
        case args of
            [ Text s _ ] ->
                "\\ilink{" ++ s ++ "}{" ++ s ++ "}"

            (Text first _) :: rest ->
                let
                    label =
                        rest |> List.map exprToLatex |> String.concat |> String.trim
                in
                "\\ilink{" ++ first ++ "}{" ++ label ++ "}"

            _ ->
                "[[?]]"

Malformed wikilinks reach LaTeX export as `Fun "red" [Text source]`,
which the existing `red` export handler renders with
`\textcolor{red}{...}`. No empty/whitespace case in this function.

## Data flow

    source text
        |
        v
    Parser.Tokenizer.run
        |  (produces Token list; [[ → DLB, [ → LB, ] → RB)
        v
    Parser.Expression.parse
        |  (reduces via Symbol + Match; well-formed wikilinks become
        |   Fun "wikilink" …; malformed [[…]] become Fun "red" [Text src])
        v
    List Expression
        |
        v (depending on output)
    Render.Expression.render       — web
    Render.Export.LaTeX.exportExpr — LaTeX

No preprocessor. No whole-file pass. Everything stays per-paragraph inside
the existing parser pipeline.

## Error handling

All malformed wikilinks emit `Fun "red" [ Text <original-source> … ] …`
so the reader sees the literal source text in **red**, signaling an
incomplete or malformed construction.

| Input shape | Handling |
|---|---|
| `[[ID]]` (single non-whitespace token) | `Fun "wikilink" [Text ID]`. Renderer emits ilink. |
| `[[ID label…]]` (flat, multiple tokens) | `Fun "wikilink" [Text ID, W, Text word…]`. Renderer emits ilink with reshuffled args. |
| `[[]]` | `isReducible` true; body empty. Reducer emits `Fun "red" [Text "[[]]"]`. |
| `[[   ]]` | `isReducible` true (WS filtered); body empty after filter. Reducer emits `Fun "red" [Text "[[   ]]"]`. |
| `[[a [b] c]]` | Body contains `L`, not flat. `isReducible` false. Recovery emits `Fun "red" [Text "[[a [b] c]]"]`. |
| `[[a [[b]] c]]` | Outer body contains nested `DL`. `isReducible` false for outer. Recovery emits `Fun "red" [Text "[[a [[b]] c]]"]`. Inner never reduces — top-down splitting checks outer first. |
| `[[unclosed` | `DLB` at end-of-input with no closer. Recovery emits `Fun "red" [Text "[[unclosed"]`. |
| `unclosed]]` | Two stray `RB` tokens, same as today (`" extra ]?"` error). Unchanged. |

### Implementation note: nested wikilinks reduce correctly by accident

`splitTokens` in `reduceRestOfTokens` (line 287-296) is top-down: it finds
a matching closing bracket for the leftmost opener and feeds the entire
span — inner tokens still raw — to `reduceTokens`. That means for
`[[a [[b]] c]]`, the outer reducer sees the raw symbol stream
`DL ST WS DL ST R R WS ST R R` and the flat-body check correctly rejects it
because of the inner `DL`. No special case needed. Verify during
implementation by unit-testing this input directly.

## Testing plan

Three test modules, mirroring existing structure in `tests/Parser/` and
`tests/`:

### `tests/Parser/WikilinkTokenTest.elm` (new)

Tokenization:

- `[[` produces `DLB`
- `[` still produces `LB`
- `[[[` produces `DLB, LB` (greedy double match first)
- `]]` produces `RB, RB`
- `[[a]]` produces `DLB, S, RB, RB`
- Verify meta offsets for `DLB` span both characters.

### `tests/Parser/MatchTest.elm` (extend)

Add cases:

- `[DL, ST, R, R]` → `True`
- `[DL, ST, WS, ST, R, R]` → `True`
- `[DL, R, R]` → `True` (empty body passes structural check; reducer classifies as malformed and emits red literal)
- `[DL, WS, R, R]` → `True` (whitespace-only body — WS filtered out, same as empty at this layer)
- `[DL, ST, L, ST, R, R, R]` → `False` (nested `[` in body — not flat)
- `[DL, ST, DL, ST, R, R, R, R]` → `False` (nested `[[` in body — not flat)
- `[L, ST, DL, ST, R, R, R]` → `True` (wikilink as child of normal bracket)

### `tests/Parser/ExpressionParserTest.elm` (extend)

End-to-end:

- `parse 0 "[[foo]]"` → `[Fun "wikilink" [Text "foo" …] …]`
- `parse 0 "[[foo bar baz]]"` → `Fun "wikilink"` with ID `foo` and label `bar baz` (exact child shape = Text/W/Text/W/Text; first Text is ID).
- `parse 0 "[[]]"` → `[Fun "red" [Text "[[]]" …] …]`
- `parse 0 "[[   ]]"` → `[Fun "red" [Text "[[   ]]" …] …]`
- `parse 0 "[[a [b] c]]"` → `[Fun "red" [Text "[[a [b] c]]" …] …]`
- `parse 0 "[[a [[b]] c]]"` → `[Fun "red" [Text "[[a [[b]] c]]" …] …]` (single outer, inner never reduced)
- `parse 0 "[italic how is this [bold possible?]]"` — unchanged shape from today.
- `parse 0 "[foo [[bar]] baz]"` → `[Fun "foo" [..., Fun "wikilink" [Text "bar" …] …, ...] …]`
- `parse 0 "prefix [[a]] middle [[b]] suffix"` — two wikilinks mid-line.
- `parse 0 "[[unclosed"` → `[Fun "red" [Text "[[unclosed" …] …]` via recovery.

### Render tests

Optional if snapshot harness exists. Otherwise spot-check manually via
`tests/toLaTeXExport/` for LaTeX path.

## Files changed summary

**New:**

- `tests/Parser/WikilinkTokenTest.elm`

**Edited:**

- `src/Parser/Tokenizer.elm` — `DLB` token, `doubleLeftBracketParser`
- `src/Parser/Symbol.elm` — `DL` symbol
- `src/Parser/Match.elm` — `isReducible` and `hasReducibleArgs` cases for `DL`
- `src/Parser/Expression.elm` — reduction, recovery, and helper functions for `wikilink`
- `src/Render/Expression.elm` — `renderWikilink`, dict entry
- `src/Render/Export/LaTeX.elm` — `wikilink` export function, dict entry
- `tests/Parser/MatchTest.elm` — new `DL` test cases
- `tests/Parser/ExpressionParserTest.elm` — wikilink end-to-end tests

## Out of scope

- `zku` identifier support at the document/database level. The parser
  treats any text token as an ID; validation of ID shape and resolution
  to a document row is a separate layer, not this work.
- Visual styling of malformed wikilinks (they render as plain text, not
  error-highlighted). Can be revisited if useful.
- Round-trip inverse transform (LaTeX → Scripta) for wikilinks. Only
  forward rendering is in scope.
