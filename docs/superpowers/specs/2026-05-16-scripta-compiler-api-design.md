# Recommendation: A Better Public API for the Scripta Compiler

**Date:** 2026-05-16
**Status:** Recommendation only — no implementation plan, no code changes
**Scope:** The public API surface of the Scripta compiler (`scripta-compiler-v3`),
keeping language coverage to Scripta markup. Markdown and LaTeX continue to be
dispatched separately by the consuming app.

## Why this document exists

The Scripta compiler today exposes an API shaped by its two current consumers
(`scripta-app-v4` and `kv-store`) and by its own internals. As the compiler
gains other users — other Elm apps, JS/web embedders, extension authors, and
CLI/batch tooling — that surface will not hold up. This document recommends a
clean-slate redesign of the public API, with migration notes for the two
existing apps. It is a recommendation; whether and when to implement it is a
separate decision.

## Current API, as it stands

The public surface is three functions in `V3.Compiler` plus a wide-open types
module.

```elm
-- V3/Compiler.elm
parse   : CompilerParameters -> List String -> ( Accumulator, List (Tree ExpressionBlock) )
compile : CompilerParameters -> List String -> CompilerOutput Msg
render  : CompilerParameters -> ( Accumulator, List (Tree ExpressionBlock) ) -> CompilerOutput Msg
```

```elm
-- V3/Types.elm
module V3.Types exposing (..)
```

### Problems

1. **The parse result is a bare tuple of internal types.**
   `parse` returns `( Accumulator, List (Tree ExpressionBlock) )`. To merely
   *hold* that value a consumer must import `RoseTree.Tree`, `Either`, and
   `V3.Types`. The editor (`scripta-app-v4/frontend/src/Editor.elm:44-57`)
   reaches directly into `block.meta.sourceText` and `block.meta.id`. The
   entire internal representation is therefore public API — any internal
   change is a breaking change.

2. **No public/private boundary in the types module.**
   `V3.Types.elm:1` is `module V3.Types exposing (..)`. `ExpressionCache`,
   `InListState`, `TermLoc`, `Macro`, and the 20-field `Accumulator` are all
   public. There is nothing the compiler can change freely.

3. **`CompilerParameters` conflates parse-time and render-time concerns.**
   `V3.Types.elm:220` defines an 8-field record. `parse` is handed the whole
   record but parsing depends only on a couple of fields; `theme`,
   `windowWidth`, `width`, `showTOC`, and `sizing` are render concerns.
   `editCount` is a cache-invalidation knob that is always `0` in both apps.

4. **The `Msg` type carries internal noise.**
   `V3.Types.elm:259` defines a 9-constructor `Msg`. Three constructors
   (`SendMeta`, `SendBlockMeta`, `NoOp`) are never meaningfully handled by a
   consumer. Both apps write an identical 7-branch `Html.map` translation —
   `scripta-app-v4/frontend/src/Render.elm:101-126` and `Render.elm:146-171`
   are copy-paste duplicates of each other.

5. **No headless output path.**
   Output always carries live `Html msg` with event handlers. CLI/SSG tooling
   and JS-via-ports embedders need a plain HTML string.

6. **`V3.` in module names** is an internal versioning artifact, awkward as a
   stable public package surface.

## Proposed API

### Module layout

Three public modules. Everything else (`Parser.*`, `Render.*`, `Generic.*`,
and today's `V3.Types`) becomes internal. The `elm.json` `exposed-modules`
list contains exactly these three:

| Module | Audience | Contents |
|---|---|---|
| `Scripta` | the 90% case | `compile`, `parse`, `render`, `compileToString`, `Options` + builders, `Event`, `Output`, `mapEvent` |
| `Scripta.Document` | editors / introspection | the opaque `Document` type and query functions |
| `Scripta.Markup` | extension authors | the minimal set of AST types needed to write custom renderers |

### Opaque `Document`

The leaked `( Accumulator, List (Tree ExpressionBlock) )` tuple is replaced by
an opaque `Document`. It is produced only by `parse`, consumed only by
`render`, and inspected only through `Scripta.Document` query functions.
Consumers hold a `Document` between edits but never depend on its internals.

### Opaque `Options` with builder functions

`CompilerParameters` is replaced by an opaque `Options` value built up with
`with*` functions:

```elm
defaultOptions  : Options
withTheme        : Theme -> Options -> Options
withWindowWidth  : Int -> Options -> Options
withContentWidth : Int -> Options -> Options
withTOC          : Bool -> Options -> Options
withMaxLevel     : Int -> Options -> Options
withSizing       : SizingConfig -> Options -> Options
withFilter       : Filter -> Options -> Options
-- reserved for later, non-breaking:
-- withCustomBlock : String -> BlockRenderer -> Options -> Options
```

This is the central forward-looking decision. In Elm, adding a field to a
public record is a breaking change for every caller that constructs the record
literally (both apps do this today). Adding a `with*` builder is not. Custom
blocks, new render options, and other future capabilities can land without
disturbing any existing caller.

A single `Options` value covers both parsing and rendering; the internal split
between parse-relevant and render-relevant fields is hidden. `editCount` is
removed from the public surface — if incremental parsing needs a generation
counter, the `Document` carries it internally.

### Functions

All entry points take a `String`, not `List String`. Both apps currently call
`String.lines` at the boundary; that belongs inside the compiler.

```elm
parse           : Options -> String -> Document
render          : Options -> Document -> Output Event
compile         : Options -> String -> Output Event
compileToString : Options -> String -> StringOutput
mapEvent        : (Event -> msg) -> Output Event -> Output msg
```

- `parse` / `render` — the two-phase path for editors doing incremental work.
- `compile` — `parse` followed by `render`, the one-shot path.
- `compileToString` — the headless path for CLI/batch tooling and JS
  embedders. It returns plain HTML strings with no event handlers and is
  deterministic.
- `mapEvent` — translates a whole `Output` from the compiler's `Event` type to
  the consumer's own message type, replacing the per-field `Html.map`
  boilerplate.

### Output and Event types

`Output` stays polymorphic in its message type so `mapEvent` can retarget it:

```elm
type alias Output msg =
    { title  : Html msg
    , body   : List (Html msg)
    , toc    : List (Html msg)
    , banner : Maybe (Html msg)
    }

type alias StringOutput =
    { title : String
    , body  : String
    , toc   : String
    }
```

`Event` is a trimmed, stable type. Every constructor corresponds to something a
consumer actually handles today; the internal `SendMeta`, `SendBlockMeta`, and
`NoOp` constructors are gone, and `ClickedLink` drops the `ExprMeta` payload
that both apps ignore.

```elm
type Event
    = ClickedId String
    | ClickedFootnote { targetId : String, returnId : String }
    | ClickedCitation { targetId : String, returnId : String }
    | ClickedImage String
    | ClickedLink String
    | HighlightedId String
```

Typical use collapses to one translation function plus `mapEvent`:

```elm
toRenderMsg : Scripta.Event -> RenderMsg
toRenderMsg event =
    case event of
        Scripta.ClickedId id_          -> ScrollTo id_
        Scripta.ClickedFootnote f      -> ScrollTo f.targetId
        Scripta.ClickedCitation c      -> ScrollToWithReturn c
        Scripta.ClickedImage url       -> ExpandImage url
        Scripta.ClickedLink slug       -> NavigateToDocument slug
        Scripta.HighlightedId id_      -> HighlightId id_

output : Output RenderMsg
output =
    Scripta.compile opts source |> Scripta.mapEvent toRenderMsg
```

### Document query API

`Scripta.Document` exposes query functions so editors stop walking the raw
forest and reaching into block metadata:

```elm
idsContainingSource : String -> Document -> List String
sourceOfId          : String -> Document -> Maybe String
title               : Document -> String
```

`idsContainingSource` replaces the hand-rolled `Editor.matchingIdsInAST`,
which currently flattens the forest and filters on `block.meta.sourceText`.

## How the design serves each future audience

- **Other Elm apps** — the opaque `Document` supports incremental parse/render
  without exposing internals; `mapEvent` removes the duplicated event-mapping
  boilerplate.
- **JS / web embedders** — `compileToString` produces plain HTML, suitable for
  passing across a port or wrapping in a web component.
- **Extension authors** — opaque `Options` with builders means `withCustomBlock`
  and similar can be added later without breaking callers; `Scripta.Markup`
  exposes only the AST types a custom renderer needs.
- **CLI / batch tooling** — `compileToString` is headless and deterministic,
  with no live `Html msg` and no event wiring.

## Migration notes for the two existing apps

These describe the shape of the change only. No implementation plan is included.

### `scripta-app-v4/frontend/src/Render.elm`

- `compilerParams isLight` becomes
  `defaultOptions |> withTheme (themeFor isLight) |> withWindowWidth 600 |> ...`.
- `V3.Compiler.parse params (String.lines source)` becomes
  `Scripta.parse opts source`; the result type changes from
  `( Accumulator, List (Tree ExpressionBlock) )` to `Document`.
- `V3.Compiler.render` / `V3.Compiler.compile` become `Scripta.render` /
  `Scripta.compile`.
- The two duplicated `mapMsg` blocks (`Render.elm:101-126`, `:146-171`)
  collapse to one `toRenderMsg : Event -> RenderMsg` plus `Scripta.mapEvent`.
- `renderScripta`'s `Maybe ( Accumulator, List (Tree ExpressionBlock) )`
  return becomes `Maybe Document`.

### `scripta-app-v4/frontend/src/Editor.elm`

- `matchingIdsInAST target forest` becomes
  `Scripta.Document.idsContainingSource target document`.
- The `import RoseTree.Tree` and `import V3.Types` lines are removed.
- `flattenTree` loses its only in-module caller; check for other uses before
  deleting it.

### `kv-store/frontend/src/View/Table.elm`

- `V3.Compiler.compile params (String.lines content)` becomes
  `Scripta.compile opts content`.
- The `SelectId` / `FootnoteClick` / `CitationClick` mapping moves into a
  `toScrollMsg : Event -> Msg` function applied through `Scripta.mapEvent`.

## Decisions and alternatives considered

1. **Opaque `Options` + builders vs. plain `ParseOptions` / `RenderOptions`
   records.** Plain records read more directly, but every field addition is a
   breaking change for callers that construct them literally. The opaque
   builder form was chosen because the explicit goal is to accommodate future
   users — extension authors in particular — without breaking the surface.

2. **`Html Event` + `mapEvent` vs. injecting handler functions so `render`
   returns `Html msg` directly.** Handler injection would let `render` produce
   the consumer's message type immediately, but it complicates the signatures
   and couples rendering to the consumer's update cycle. `Html.map` is the
   idiomatic Elm approach and keeps `render` pure; `mapEvent` is provided so
   the consumer still writes the translation only once.

3. **Scripta-only scope.** The compiler API stays focused on Scripta markup.
   Markdown (`elm-markdown`) and LaTeX (`MiniLatex`) remain separate libraries
   that the consuming app dispatches itself, as it does today.
