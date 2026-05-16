# Scripta Public API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a clean public API for the Scripta compiler — modules `Scripta` and `Scripta.Document` with opaque `Document` and `Options` types — and convert the `/Demo` app to use it.

**Architecture:** A thin façade over the existing internal compiler. An internal module `Scripta.Internal` defines the opaque `Document` and `Options` types and their constructors. `Scripta` re-exposes them opaquely (via type aliases) and provides `defaultOptions` + `with*` builders, a trimmed `Event` type, an `Output` record, and `parse` / `reparse` / `render` / `compile` / `mapEvent`. `Scripta.Document` adds query functions. The existing `V3.*`, `Parser.*`, `Render.*`, `Generic.*` modules are unchanged except for trimming three dead constructors from `V3.Types.Msg`.

**Tech Stack:** Elm 0.19.1, `elm-test`, the existing Scripta compiler internals (`Parser.Forest`, `V3.Compiler`, `Render.*`).

---

## Scope

**In scope:**
- `Scripta.Internal` — opaque `Document` / `Options` definitions.
- `Scripta` — `Options` + builders, `Event`, `Output`, `parse`, `reparse`, `render`, `compile`, `mapEvent`.
- `Scripta.Document` — `idsContainingSource`, `sourceOfId`, `title`.
- Trim `V3.Types.Msg` to its six live constructors.
- Convert `Demo/src/Main.elm` to the new API.

**Deferred to follow-up plans (intentionally NOT in this plan):**
- `compileToString` / `StringOutput` — the headless path needs a separate HTML-string renderer subsystem; Elm cannot serialize `Html`. No current consumer.
- `Scripta.Markup` — exposing AST custom types (`Expr(..)`, `Heading(..)`) requires relocating their definitions out of `V3.Types`, because Elm cannot re-export a custom type's constructors. No current consumer.
- Dropping `Accumulator` from the `Html.Lazy` signature in `Render/Tree.elm` (see `docs/api-and-rl-sync-discussion.md` §6) — tracked in memory `referential-stability-followup`.
- Routing RL sync through `Document` + per-word marking — tracked in memory `rl-sync-followup`.

**Design decisions:**
- The spec's `parse : Options -> String -> Document` is kept as the cold/full path. A second function `reparse : Options -> Document -> String -> Document` is added for the incremental warm path (the Demo uses incremental parsing). This extends the spec by one function rather than changing the `parse` signature.
- `Theme` and `Filter` are redefined as fresh types in `Scripta` (not re-exported from `V3.Types`) because Elm cannot re-export custom-type constructors. `SizingConfig` is a record alias and IS re-exported.

---

## File Structure

| File | Status | Responsibility |
|---|---|---|
| `src/Scripta/Internal.elm` | Create | Opaque `Document` and `Options` definitions (constructors exposed to sibling modules only); `optionsToParams`. |
| `src/Scripta.elm` | Create | Public façade: `Options` + builders, `Theme`/`Filter`/`SizingConfig`, `Event`, `Output`, `parse`/`reparse`/`render`/`compile`/`mapEvent`. |
| `src/Scripta/Document.elm` | Create | Public query functions over a `Document`. |
| `src/V3/Types.elm` | Modify | Remove dead `Msg` constructors `SendMeta`, `SendBlockMeta`, `NoOp`. |
| `Demo/src/Main.elm` | Modify | Convert from `V3.Compiler`/`V3.Types`/`Parser.Forest` to `Scripta`/`Scripta.Document`. |
| `tests/ScriptaTest.elm` | Create | Tests for `Options` builders and the `parse`→`render` pipeline. |
| `tests/ScriptaDocumentTest.elm` | Create | Tests for `Scripta.Document` query functions. |

`Scripta.Internal` is internal: consumers (the Demo, future apps) import only `Scripta` and `Scripta.Document`. Test modules MAY import `Scripta.Internal` to inspect opaque values.

No `elm.json` changes are needed: the root `elm.json` has `source-directories: ["src"]`, and `Demo/elm.json` has `["src", "../src"]`, so all new `src/Scripta*` modules are visible to both `elm-test` and the Demo.

---

## Task 1: Trim `V3.Types.Msg`

`SendMeta`, `SendBlockMeta`, and `NoOp` are dead: `SendMeta`/`SendBlockMeta` appear only in commented-out code in `src/Render/Utility.elm`, and `NoOp` appears only in its own definition. Removing them lets `Scripta.msgToEvent` be a clean total function.

**Files:**
- Modify: `src/V3/Types.elm:259-268`

- [ ] **Step 1: Verify the three constructors are dead**

Run:
```bash
grep -rn "SendMeta\|SendBlockMeta\|NoOp" src/ tests/ | grep -v "src/V3/Types.elm" | grep -v "^[^:]*:[0-9]*: *--"
```
Expected: no output (only comment lines or the definition site, both filtered out). If any live (non-comment) reference appears outside `src/V3/Types.elm`, STOP and keep that constructor — the rest of the plan still works, but `msgToEvent` in Task 4 must then map it.

- [ ] **Step 2: Edit `src/V3/Types.elm`**

Replace the `Msg` type (currently lines 259-268):

```elm
{-| Messages for interactive rendering.
-}
type Msg
    = SelectId String
    | HighlightId String
    | ExpandImage String
    | FootnoteClick { targetId : String, returnId : String }
    | CitationClick { targetId : String, returnId : String }
    | GoToDocument String ExprMeta
```

- [ ] **Step 3: Verify compilation and tests**

Run:
```bash
elm make src/V3/Compiler.elm --output=/dev/null && elm-test
```
Expected: compiles cleanly; `TEST RUN PASSED`, 188 tests. (Note: this is a library-style project — there is no `src/Main.elm`. `src/V3/Compiler.elm` is the top of the compiler; `elm-test` additionally compiles everything reachable from the test modules.)

- [ ] **Step 4: Commit**

```bash
git add src/V3/Types.elm
git commit -m "Remove dead Msg constructors SendMeta, SendBlockMeta, NoOp

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Create `Scripta.Internal`

Defines the opaque `Document` and `Options` types. The `Options` record mirrors `V3.Types.CompilerParameters` minus `editCount`. `optionsToParams` converts an `Options` to the internal `CompilerParameters` (filling `editCount = 0`). `Theme` and `Filter` here are `Scripta`'s own types — Task 3 defines them; this module references them, so Task 3's `Scripta` module and this module must agree. To avoid a circular import (`Scripta` imports `Internal`, `Internal` cannot import `Scripta`), **`Theme` and `Filter` are defined in `Scripta.Internal`** and re-exposed by `Scripta`.

**Files:**
- Create: `src/Scripta/Internal.elm`

- [ ] **Step 1: Write `src/Scripta/Internal.elm`**

```elm
module Scripta.Internal exposing
    ( Document(..)
    , DocumentData
    , Filter(..)
    , Options(..)
    , OptionsData
    , SizingConfig
    , Theme(..)
    , optionsToParams
    )

{-| Internal definitions for the Scripta public API.

This module is NOT part of the public API. Consumers import `Scripta` and
`Scripta.Document`. The opaque `Document` and `Options` types are defined here
so that both `Scripta` and `Scripta.Document` can construct and inspect them.

-}

import RoseTree.Tree exposing (Tree)
import V3.Types exposing (Accumulator, ExpressionBlock, ExpressionCache)


{-| Sizing configuration. Re-exported from V3.Types (a record alias, so this
re-export is legal in Elm).
-}
type alias SizingConfig =
    V3.Types.SizingConfig


{-| Light or dark theme. Defined here (not re-exported from V3.Types) because
Elm cannot re-export a custom type's constructors.
-}
type Theme
    = Light
    | Dark


{-| Forest filter.
-}
type Filter
    = NoFilter
    | SuppressDocumentBlocks


{-| The data carried by an opaque Options value.
-}
type alias OptionsData =
    { filter : Filter
    , windowWidth : Int
    , theme : Theme
    , contentWidth : Int
    , showTOC : Bool
    , sizing : SizingConfig
    , maxLevel : Int
    }


{-| Opaque options value. Built with `Scripta.defaultOptions` and `with*`.
-}
type Options
    = Options OptionsData


{-| The data carried by an opaque Document value.
-}
type alias DocumentData =
    { accumulator : Accumulator
    , forest : List (Tree ExpressionBlock)
    , cache : ExpressionCache
    }


{-| Opaque parsed document. Produced by `Scripta.parse` / `Scripta.reparse`,
consumed by `Scripta.render` and `Scripta.Document` queries.
-}
type Document
    = Document DocumentData


{-| Convert public Options to the internal CompilerParameters.
-}
optionsToParams : Options -> V3.Types.CompilerParameters
optionsToParams (Options data) =
    { filter =
        case data.filter of
            NoFilter ->
                V3.Types.NoFilter

            SuppressDocumentBlocks ->
                V3.Types.SuppressDocumentBlocks
    , windowWidth = data.windowWidth
    , theme =
        case data.theme of
            Light ->
                V3.Types.Light

            Dark ->
                V3.Types.Dark
    , editCount = 0
    , width = data.contentWidth
    , showTOC = data.showTOC
    , sizing = data.sizing
    , maxLevel = data.maxLevel
    }
```

- [ ] **Step 2: Verify compilation**

Run:
```bash
elm make src/Scripta/Internal.elm --output=/dev/null
```
Expected: compiles cleanly (no output, exit 0).

- [ ] **Step 3: Commit**

```bash
git add src/Scripta/Internal.elm
git commit -m "Add Scripta.Internal: opaque Document and Options types

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: `Scripta` — Options and builders

First half of the `Scripta` module: the opaque `Options`, `defaultOptions`, the `with*` builders, and the re-exported `Theme` / `Filter` / `SizingConfig`.

**Files:**
- Create: `src/Scripta.elm`
- Test: `tests/ScriptaTest.elm`

- [ ] **Step 1: Write the failing test `tests/ScriptaTest.elm`**

```elm
module ScriptaTest exposing (suite)

import Expect
import Scripta
import Scripta.Internal as Internal
import Test exposing (Test, describe, test)
import V3.Types


suite : Test
suite =
    describe "Scripta"
        [ describe "Options builders"
            [ test "defaultOptions has NoFilter" <|
                \_ ->
                    Internal.optionsToParams Scripta.defaultOptions
                        |> .filter
                        |> Expect.equal V3.Types.NoFilter
            , test "withTheme Dark sets the theme" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withTheme Scripta.Dark
                        |> Internal.optionsToParams
                        |> .theme
                        |> Expect.equal V3.Types.Dark
            , test "withWindowWidth sets windowWidth" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withWindowWidth 750
                        |> Internal.optionsToParams
                        |> .windowWidth
                        |> Expect.equal 750
            , test "withContentWidth sets width" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withContentWidth 640
                        |> Internal.optionsToParams
                        |> .width
                        |> Expect.equal 640
            , test "withTOC sets showTOC" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withTOC True
                        |> Internal.optionsToParams
                        |> .showTOC
                        |> Expect.equal True
            , test "withMaxLevel sets maxLevel" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withMaxLevel 3
                        |> Internal.optionsToParams
                        |> .maxLevel
                        |> Expect.equal 3
            , test "builders compose without clobbering" <|
                \_ ->
                    let
                        params =
                            Scripta.defaultOptions
                                |> Scripta.withTheme Scripta.Dark
                                |> Scripta.withWindowWidth 800
                                |> Internal.optionsToParams
                    in
                    Expect.equal ( params.theme, params.windowWidth )
                        ( V3.Types.Dark, 800 )
            ]
        ]
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `elm-test tests/ScriptaTest.elm`
Expected: FAIL — `Scripta` module does not exist / `defaultOptions` not found.

- [ ] **Step 3: Write `src/Scripta.elm` (Options portion)**

**Re-export pitfall:** Elm cannot re-export a custom type's constructors. A
`type alias Theme = Internal.Theme` would expose the *name* `Theme` but not its
constructors `Light` / `Dark`, which consumers need. So `Theme` and `Filter`
are *re-declared* in `Scripta` and mapped to their `Internal` counterparts by
`themeToInternal` / `filterToInternal`. (`Options` and `SizingConfig` are fine
to alias — `Options` is opaque, `SizingConfig` is a record.)

Create the file with exactly this content (Task 4 appends to it):

```elm
module Scripta exposing
    ( Options, defaultOptions
    , withTheme, withWindowWidth, withContentWidth, withTOC, withMaxLevel, withSizing, withFilter
    , Theme(..), Filter(..), SizingConfig, defaultSizing
    )

{-| Public API for the Scripta compiler.


# Options

@docs Options, defaultOptions
@docs withTheme, withWindowWidth, withContentWidth, withTOC, withMaxLevel, withSizing, withFilter
@docs Theme, Filter, SizingConfig, defaultSizing

-}

import Scripta.Internal as Internal exposing (Options(..))
import V3.Types


{-| Opaque compiler options. Build with `defaultOptions` and the `with*`
functions.
-}
type alias Options =
    Internal.Options


{-| Light or dark theme.
-}
type Theme
    = Light
    | Dark


{-| Forest filter. `NoFilter` renders everything; `SuppressDocumentBlocks`
hides `document` and `title` blocks.
-}
type Filter
    = NoFilter
    | SuppressDocumentBlocks


{-| Sizing/spacing configuration (a record).
-}
type alias SizingConfig =
    Internal.SizingConfig


{-| Default sizing configuration.
-}
defaultSizing : SizingConfig
defaultSizing =
    V3.Types.defaultSizingConfig


themeToInternal : Theme -> Internal.Theme
themeToInternal theme =
    case theme of
        Light ->
            Internal.Light

        Dark ->
            Internal.Dark


filterToInternal : Filter -> Internal.Filter
filterToInternal filter =
    case filter of
        NoFilter ->
            Internal.NoFilter

        SuppressDocumentBlocks ->
            Internal.SuppressDocumentBlocks


{-| Default options: no filter, 800px window and content width, light theme,
no table of contents, default sizing, unlimited heading level.
-}
defaultOptions : Options
defaultOptions =
    Internal.Options
        { filter = Internal.NoFilter
        , windowWidth = 800
        , theme = Internal.Light
        , contentWidth = 800
        , showTOC = False
        , sizing = V3.Types.defaultSizingConfig
        , maxLevel = 0
        }


{-| Set the theme.
-}
withTheme : Theme -> Options -> Options
withTheme theme (Internal.Options data) =
    Internal.Options { data | theme = themeToInternal theme }


{-| Set the window width in pixels.
-}
withWindowWidth : Int -> Options -> Options
withWindowWidth w (Internal.Options data) =
    Internal.Options { data | windowWidth = w }


{-| Set the content (text column) width in pixels.
-}
withContentWidth : Int -> Options -> Options
withContentWidth w (Internal.Options data) =
    Internal.Options { data | contentWidth = w }


{-| Show or hide the table of contents.
-}
withTOC : Bool -> Options -> Options
withTOC show (Internal.Options data) =
    Internal.Options { data | showTOC = show }


{-| Set the maximum heading level to render.
-}
withMaxLevel : Int -> Options -> Options
withMaxLevel level (Internal.Options data) =
    Internal.Options { data | maxLevel = level }


{-| Set the sizing configuration.
-}
withSizing : SizingConfig -> Options -> Options
withSizing sizing (Internal.Options data) =
    Internal.Options { data | sizing = sizing }


{-| Set the forest filter.
-}
withFilter : Filter -> Options -> Options
withFilter filter (Internal.Options data) =
    Internal.Options { data | filter = filterToInternal filter }
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `elm-test tests/ScriptaTest.elm`
Expected: PASS — 7 tests in the "Options builders" group.

- [ ] **Step 5: Commit**

```bash
git add src/Scripta.elm tests/ScriptaTest.elm
git commit -m "Add Scripta module: opaque Options and builder functions

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: `Scripta` — Event, Output, parse/reparse/render/compile/mapEvent

Append the rendering API to `src/Scripta.elm`. `Event` is the trimmed event type; `msgToEvent` maps the internal `V3.Types.Msg` (six constructors after Task 1) to `Event`. `Output` is the polymorphic output record. `parse` is the cold path, `reparse` the incremental warm path.

**Files:**
- Modify: `src/Scripta.elm` (extend `exposing` list; append definitions)
- Test: `tests/ScriptaTest.elm` (add a "pipeline" group)

- [ ] **Step 1: Add the failing test group to `tests/ScriptaTest.elm`**

Add this `describe` block to the `suite` list (after the "Options builders" group):

```elm
        , describe "pipeline"
            [ test "compile produces a non-empty body" <|
                \_ ->
                    Scripta.compile Scripta.defaultOptions "Hello [strong world]."
                        |> .body
                        |> List.isEmpty
                        |> Expect.equal False
            , test "parse then render produces a non-empty body" <|
                \_ ->
                    let
                        doc =
                            Scripta.parse Scripta.defaultOptions "Hello world."
                    in
                    Scripta.render Scripta.defaultOptions doc
                        |> .body
                        |> List.isEmpty
                        |> Expect.equal False
            , test "reparse of an edited document produces a non-empty body" <|
                \_ ->
                    let
                        doc0 =
                            Scripta.parse Scripta.defaultOptions "First paragraph.\n\nSecond paragraph."

                        doc1 =
                            Scripta.reparse Scripta.defaultOptions doc0 "First paragraph edited.\n\nSecond paragraph."
                    in
                    Scripta.render Scripta.defaultOptions doc1
                        |> .body
                        |> List.isEmpty
                        |> Expect.equal False
            ]
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `elm-test tests/ScriptaTest.elm`
Expected: FAIL — `Scripta.compile` / `parse` / `reparse` / `render` not found.

- [ ] **Step 3: Extend the `exposing` list of `src/Scripta.elm`**

Replace the module declaration's `exposing (...)` with:

```elm
module Scripta exposing
    ( Options, defaultOptions
    , withTheme, withWindowWidth, withContentWidth, withTOC, withMaxLevel, withSizing, withFilter
    , Theme(..), Filter(..), SizingConfig, defaultSizing
    , Document
    , Event(..), Output
    , parse, reparse, render, compile, mapEvent
    )
```

And add to the doc comment, after the Options `@docs` lines:

```elm

# Documents and rendering

@docs Document
@docs Event, Output
@docs parse, reparse, render, compile, mapEvent

```

- [ ] **Step 4: Add imports to `src/Scripta.elm`**

Add these imports below the existing `import Scripta.Internal ...` / `import V3.Types` lines:

```elm
import Dict
import Html exposing (Html)
import Parser.Forest
import Scripta.Internal exposing (Document(..))
import V3.Compiler
```

(Merge with the existing `import Scripta.Internal as Internal exposing (Options(..))` — Elm allows only one import per module, so the single line becomes:
`import Scripta.Internal as Internal exposing (Document(..), Options(..))`.)

- [ ] **Step 5: Append the rendering API to `src/Scripta.elm`**

```elm
{-| An opaque parsed document. Produced by `parse` / `reparse`, consumed by
`render` and the `Scripta.Document` query functions.
-}
type alias Document =
    Internal.Document


{-| An interaction event emitted by rendered output.

  - `ClickedId` — the user clicked an element with the given id.
  - `ClickedFootnote` / `ClickedCitation` — jump to a target, remembering a return id.
  - `ClickedImage` — the user clicked an image (url).
  - `ClickedLink` — the user clicked an internal document link (slug).
  - `HighlightedId` — request to highlight the element with the given id.

-}
type Event
    = ClickedId String
    | ClickedFootnote { targetId : String, returnId : String }
    | ClickedCitation { targetId : String, returnId : String }
    | ClickedImage String
    | ClickedLink String
    | HighlightedId String


{-| Rendered output, polymorphic in the message type so `mapEvent` can retarget it.
-}
type alias Output msg =
    { title : Html msg
    , body : List (Html msg)
    , toc : List (Html msg)
    , banner : Maybe (Html msg)
    }


{-| Translate the internal compiler Msg to the public Event type.
-}
msgToEvent : V3.Types.Msg -> Event
msgToEvent msg =
    case msg of
        V3.Types.SelectId id ->
            ClickedId id

        V3.Types.HighlightId id ->
            HighlightedId id

        V3.Types.ExpandImage url ->
            ClickedImage url

        V3.Types.FootnoteClick record ->
            ClickedFootnote record

        V3.Types.CitationClick record ->
            ClickedCitation record

        V3.Types.GoToDocument slug _ ->
            ClickedLink slug


{-| Parse source text into a Document (cold path: full parse).
-}
parse : Options -> String -> Document
parse options source =
    let
        params =
            Internal.optionsToParams options

        ( cache, accumulator, forest ) =
            Parser.Forest.parseIncrementally params Dict.empty (String.lines source)
    in
    Internal.Document
        { accumulator = accumulator
        , forest = forest
        , cache = cache
        }


{-| Re-parse source text incrementally, reusing the previous Document's cache
and accumulator where it is safe to do so. Use this for editor keystroke
updates; use `parse` for initial load and document switches.
-}
reparse : Options -> Document -> String -> Document
reparse options (Internal.Document prev) source =
    let
        params =
            Internal.optionsToParams options

        result =
            Parser.Forest.parseIncrementallySkipAcc params
                prev.cache
                ( prev.accumulator, prev.forest )
                (String.lines source)
    in
    Internal.Document
        { accumulator = result.acc
        , forest = result.forest
        , cache = result.cache
        }


{-| Render a parsed Document to HTML output carrying `Event`s.
-}
render : Options -> Document -> Output Event
render options (Internal.Document data) =
    V3.Compiler.render (Internal.optionsToParams options)
        ( data.accumulator, data.forest )
        |> toEventOutput


{-| Parse and render in one step (cold path).
-}
compile : Options -> String -> Output Event
compile options source =
    render options (parse options source)


{-| Retarget a whole Output from `Event` to the consumer's own message type.
-}
mapEvent : (Event -> msg) -> Output Event -> Output msg
mapEvent f output =
    { title = Html.map f output.title
    , body = List.map (Html.map f) output.body
    , toc = List.map (Html.map f) output.toc
    , banner = Maybe.map (Html.map f) output.banner
    }


{-| Convert the internal CompilerOutput Msg to an Output Event.
-}
toEventOutput : V3.Types.CompilerOutput V3.Types.Msg -> Output Event
toEventOutput output =
    { title = Html.map msgToEvent output.title
    , body = List.map (Html.map msgToEvent) output.body
    , toc = List.map (Html.map msgToEvent) output.toc
    , banner = Maybe.map (Html.map msgToEvent) output.banner
    }
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `elm-test tests/ScriptaTest.elm`
Expected: PASS — all "Options builders" and "pipeline" tests pass.

- [ ] **Step 7: Commit**

```bash
git add src/Scripta.elm tests/ScriptaTest.elm
git commit -m "Add Scripta parse/reparse/render/compile, Event, Output, mapEvent

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Create `Scripta.Document`

Query functions over an opaque `Document`: `idsContainingSource` (replaces the Demo's hand-rolled forest walk), `sourceOfId`, and `title`.

**Files:**
- Create: `src/Scripta/Document.elm`
- Test: `tests/ScriptaDocumentTest.elm`

- [ ] **Step 1: Write the failing test `tests/ScriptaDocumentTest.elm`**

```elm
module ScriptaDocumentTest exposing (suite)

import Expect
import Scripta
import Scripta.Document
import Test exposing (Test, describe, test)


sampleSource : String
sampleSource =
    "| title\nMy Document\n\nThis paragraph mentions primes.\n\n| theorem\nThere are infinitely many primes.\n"


suite : Test
suite =
    describe "Scripta.Document"
        [ test "title returns the title block text" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.title
                    |> Expect.equal "My Document"
        , test "title returns empty string when there is no title block" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions "Just a paragraph."
                    |> Scripta.Document.title
                    |> Expect.equal ""
        , test "idsContainingSource finds blocks containing the target text" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.idsContainingSource "infinitely many primes"
                    |> List.isEmpty
                    |> Expect.equal False
        , test "idsContainingSource returns [] for empty target" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.idsContainingSource "   "
                    |> Expect.equal []
        , test "idsContainingSource returns [] when no block matches" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.idsContainingSource "nonexistent zzz text"
                    |> Expect.equal []
        , test "sourceOfId round-trips with idsContainingSource" <|
            \_ ->
                let
                    doc =
                        Scripta.parse Scripta.defaultOptions sampleSource

                    target =
                        "infinitely many primes"
                in
                case Scripta.Document.idsContainingSource target doc of
                    firstId :: _ ->
                        Scripta.Document.sourceOfId firstId doc
                            |> Maybe.map (String.contains target)
                            |> Expect.equal (Just True)

                    [] ->
                        Expect.fail "expected at least one matching id"
        , test "sourceOfId returns Nothing for an unknown id" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.sourceOfId "no-such-id"
                    |> Expect.equal Nothing
        ]
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `elm-test tests/ScriptaDocumentTest.elm`
Expected: FAIL — `Scripta.Document` module does not exist.

- [ ] **Step 3: Write `src/Scripta/Document.elm`**

```elm
module Scripta.Document exposing
    ( Document
    , idsContainingSource, sourceOfId, title
    )

{-| Query functions over a parsed Scripta `Document`.

@docs Document
@docs idsContainingSource, sourceOfId, title

-}

import Either exposing (Either(..))
import RoseTree.Tree as Tree exposing (Tree)
import Scripta.Internal as Internal
import V3.Types exposing (Expr(..), ExpressionBlock, Heading(..))


{-| Re-export of the opaque `Document` type.
-}
type alias Document =
    Internal.Document


{-| Flatten a forest into a flat list of blocks (pre-order).
-}
flattenForest : List (Tree ExpressionBlock) -> List ExpressionBlock
flattenForest forest =
    List.concatMap flattenTree forest


flattenTree : Tree ExpressionBlock -> List ExpressionBlock
flattenTree tree =
    Tree.value tree :: List.concatMap flattenTree (Tree.children tree)


{-| Return the ids of all blocks whose source text contains `target`.

Replaces hand-rolled forest walks like `Editor.matchingIdsInAST`. Used for
left-to-right sync: editor selection -> matching rendered element ids.
An empty or whitespace-only target yields `[]`.

-}
idsContainingSource : String -> Document -> List String
idsContainingSource target (Internal.Document data) =
    let
        trimmed =
            String.trim target
    in
    if String.isEmpty trimmed then
        []

    else
        data.forest
            |> flattenForest
            |> List.filter (\block -> String.contains trimmed block.meta.sourceText)
            |> List.map (\block -> block.meta.id)


{-| Return the source text of the block with the given id, if any.
-}
sourceOfId : String -> Document -> Maybe String
sourceOfId id (Internal.Document data) =
    data.forest
        |> flattenForest
        |> List.filter (\block -> block.meta.id == id)
        |> List.head
        |> Maybe.map (\block -> block.meta.sourceText)


{-| Return the document title (the text of its `title` block), or `""` if
there is no title block.
-}
title : Document -> String
title (Internal.Document data) =
    data.forest
        |> List.filterMap (findBlockByName "title")
        |> List.head
        |> Maybe.map blockText
        |> Maybe.withDefault ""


{-| Find the first block named `name` in a tree.
-}
findBlockByName : String -> Tree ExpressionBlock -> Maybe ExpressionBlock
findBlockByName name tree =
    let
        block =
            Tree.value tree

        here =
            case block.heading of
                Ordinary blockName ->
                    if blockName == name then
                        Just block

                    else
                        Nothing

                _ ->
                    Nothing
    in
    case here of
        Just b ->
            Just b

        Nothing ->
            Tree.children tree
                |> List.filterMap (findBlockByName name)
                |> List.head


{-| Extract the plain text content of a block.
-}
blockText : ExpressionBlock -> String
blockText block =
    case block.body of
        Left str ->
            str

        Right expressions ->
            expressions
                |> List.map exprText
                |> String.concat


exprText : V3.Types.Expression -> String
exprText expr =
    case expr of
        Text str _ ->
            str

        Fun _ args _ ->
            List.map exprText args |> String.concat

        VFun _ content _ ->
            content

        ExprList _ exprs _ ->
            List.map exprText exprs |> String.concat
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `elm-test tests/ScriptaDocumentTest.elm`
Expected: PASS — all 7 `Scripta.Document` tests pass.

- [ ] **Step 5: Run the full test suite**

Run: `elm-test`
Expected: `TEST RUN PASSED` — 188 original + new `Scripta` + `Scripta.Document` tests.

- [ ] **Step 6: Commit**

```bash
git add src/Scripta/Document.elm tests/ScriptaDocumentTest.elm
git commit -m "Add Scripta.Document query module

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Convert `Demo/src/Main.elm` to the new API

Replace direct use of `V3.Compiler`, `V3.Types`, `Parser.Forest`, and `RoseTree.Tree` with `Scripta` and `Scripta.Document`. The Demo keeps incremental parsing (`Scripta.reparse`) and its parse-time readout, but loses the three-way `FullParse`/`Incremental`/`Inc+SkipAcc` toggle (the new API commits to one incremental strategy) and the `accWasSkipped` indicator.

This task is a sequence of edits to one file. After all edits, `elm make Demo/src/Main.elm` must succeed.

**Files:**
- Modify: `Demo/src/Main.elm`

- [ ] **Step 1: Replace the imports block**

Replace lines 25-32 (`import Parser.Forest` through `import V3.Types exposing (...)`):

```elm
import Process
import Scripta
import Scripta.Document
import Task
import Time
```

(Delete the `Parser.Forest`, `RoseTree.Tree`, `V3.Compiler`, `Dict`, and `V3.Types` imports. Keep `Process`, `Task`, `Time`, and the `Browser*`/`Html*`/`Json*` imports already present above line 25. The `Theme` type is now `Scripta.Theme`; see Step 3.)

- [ ] **Step 2: Delete the `ParseMode` type**

Delete lines 115-119 (the `type ParseMode = FullParse | Incremental | IncrementalSkipAcc` declaration).

- [ ] **Step 3: Replace the `Model` type alias**

Replace the `Model` record (lines 121-139) with:

```elm
type alias Model =
    { documents : List Document
    , currentDocumentId : String
    , sourceText : String
    , windowWidth : Int
    , windowHeight : Int
    , theme : Scripta.Theme
    , editCount : Int
    , selectedId : String
    , previousId : String
    , debugClickCount : Int
    , deleteConfirmation : Maybe String
    , sortMode : SortMode
    , document : Scripta.Document
    , options : Scripta.Options
    , lastParseTimeMs : Float
    }
```

- [ ] **Step 4: Add an `makeOptions` helper and replace `initParams`**

Replace `initParams` (lines 221-233) with:

```elm
{-| Build compiler Options from theme and window width.
Stored in the model and rebuilt only on theme/resize, so that the
preview's Html.lazy boundary stays referentially stable across renders.
-}
makeOptions : Scripta.Theme -> Int -> Scripta.Options
makeOptions theme windowWidth =
    let
        contentWidth =
            (windowWidth - sidebarWidth - 50) // 2
    in
    Scripta.defaultOptions
        |> Scripta.withTheme theme
        |> Scripta.withWindowWidth contentWidth
        |> Scripta.withContentWidth contentWidth
        |> Scripta.withSizing
            { baseFontSize = 14.0
            , paragraphSpacing = 18.0
            , marginLeft = 0.0
            , marginRight = 120.0
            , indentation = 20.0
            , indentUnit = 2
            , scale = 1.0
            }
```

- [ ] **Step 5: Rewrite `init`**

Replace the body of `init` (lines 172-218) with:

```elm
init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        refreshTitle : Document -> Document
        refreshTitle doc =
            { doc | title = extractTitle doc.content }

        documents =
            case Decode.decodeValue documentsDecoder flags.documents of
                Ok docs ->
                    if List.isEmpty docs then
                        [ defaultDocument ]

                    else
                        List.map refreshTitle docs

                Err _ ->
                    [ defaultDocument ]

        currentDoc =
            List.head documents |> Maybe.withDefault defaultDocument

        options =
            makeOptions Scripta.Light 1200
    in
    ( { documents = documents
      , currentDocumentId = currentDoc.id
      , sourceText = currentDoc.content
      , windowWidth = 1200
      , windowHeight = 800
      , theme = Scripta.Light
      , editCount = 1
      , selectedId = ""
      , previousId = ""
      , debugClickCount = 0
      , deleteConfirmation = Nothing
      , sortMode = ByDate
      , document = Scripta.parse options currentDoc.content
      , options = options
      , lastParseTimeMs = 0
      }
    , Task.perform GotViewport Browser.Dom.getViewport
    )
```

- [ ] **Step 6: Update the `Msg` type**

In the `Msg` type (lines 335-355), delete the `CycleParseMode` constructor and change the last constructor:

```elm
    | GotParseStartTime Int Time.Posix
    | GotParseEndTime Int Time.Posix Time.Posix
    | CompilerEvent Scripta.Event
```

(Renamed `CompilerMsg V3.Types.Msg` to `CompilerEvent Scripta.Event`.)

- [ ] **Step 7: Rewrite the parsing-related `update` branches**

Replace the `GotParseStartTime` branch (lines 401-450) with:

```elm
        GotParseStartTime n startTime ->
            if n == model.editCount then
                ( { model
                    | document =
                        Scripta.reparse model.options model.document model.sourceText
                  }
                , Task.perform (GotParseEndTime n startTime) Time.now
                )

            else
                ( model, Cmd.none )
```

Delete the `CycleParseMode` branch (lines 463-476) entirely.

- [ ] **Step 8: Update document-switching `update` branches**

In `SelectDocument` (lines 478-504), replace the `case selectedDoc of Just doc ->` body:

```elm
                Just doc ->
                    ( { model
                        | currentDocumentId = docId
                        , sourceText = doc.content
                        , editCount = model.editCount + 1
                        , document = Scripta.parse model.options doc.content
                      }
                    , Cmd.none
                    )
```

In `NewDocument` (lines 506-534), replace the `let ... in` and result:

```elm
        NewDocument ->
            let
                newId =
                    "doc-" ++ String.fromInt (model.editCount + 1)

                newDoc =
                    { id = newId
                    , title = "Untitled"
                    , content = "| title\nUntitled\n\nStart writing here...\n"
                    }

                updatedDocuments =
                    model.documents ++ [ newDoc ]
            in
            ( { model
                | documents = updatedDocuments
                , currentDocumentId = newId
                , sourceText = newDoc.content
                , editCount = model.editCount + 1
                , document = Scripta.parse model.options newDoc.content
              }
            , saveDocuments (encodeDocuments updatedDocuments)
            )
```

In `ConfirmDelete` (lines 545-602), replace the `( newParsedForest, newCache ) = ...` binding and the final record. Change the `let` binding:

```elm
                        newDocument =
                            if deletedCurrent then
                                Scripta.parse model.options newSourceText

                            else
                                model.document
```

and the final record's parsed fields:

```elm
                    ( { model
                        | documents = finalDocuments
                        , currentDocumentId = newCurrentId
                        , sourceText = newSourceText
                        , editCount = model.editCount + 1
                        , deleteConfirmation = Nothing
                        , document = newDocument
                      }
                    , saveDocuments (encodeDocuments finalDocuments)
                    )
```

- [ ] **Step 9: Update `GotViewport`, `WindowResized`, `ToggleTheme` to rebuild `options`**

Replace these three branches (lines 604-631):

```elm
        GotViewport viewport ->
            let
                w =
                    round viewport.viewport.width
            in
            ( { model
                | windowWidth = w
                , windowHeight = round viewport.viewport.height
                , options = makeOptions model.theme w
              }
            , Cmd.none
            )

        WindowResized width height ->
            ( { model
                | windowWidth = width
                , windowHeight = height
                , options = makeOptions model.theme width
              }
            , Cmd.none
            )

        ToggleTheme ->
            let
                newTheme =
                    case model.theme of
                        Scripta.Light ->
                            Scripta.Dark

                        Scripta.Dark ->
                            Scripta.Light
            in
            ( { model
                | theme = newTheme
                , options = makeOptions newTheme model.windowWidth
              }
            , Cmd.none
            )
```

- [ ] **Step 10: Rewrite the `CompilerMsg` branch as `CompilerEvent`**

Replace the `CompilerMsg compilerMsg ->` branch (lines 704-745) with:

```elm
        CompilerEvent event ->
            let
                newClickCount =
                    model.debugClickCount + 1
            in
            case event of
                Scripta.ClickedId id ->
                    ( { model
                        | selectedId = id
                        , previousId = model.selectedId
                        , debugClickCount = newClickCount
                      }
                    , scrollToElement id
                    )

                Scripta.HighlightedId id ->
                    ( { model | selectedId = id, debugClickCount = newClickCount }, Cmd.none )

                Scripta.ClickedImage _ ->
                    ( { model | debugClickCount = newClickCount }, Cmd.none )

                Scripta.ClickedFootnote { targetId } ->
                    ( { model | selectedId = targetId, debugClickCount = newClickCount }
                    , scrollToElement targetId
                    )

                Scripta.ClickedCitation { targetId } ->
                    ( { model | selectedId = targetId, debugClickCount = newClickCount }
                    , scrollToElement targetId
                    )

                Scripta.ClickedLink _ ->
                    ( { model | debugClickCount = newClickCount }, Cmd.none )
```

- [ ] **Step 11: Remove the parse-mode UI from `viewEditor`**

In `viewEditor`, delete the parse-mode toggle `Html.span` (lines 1127-1158, the element with `HE.onClick CycleParseMode`). In the timing `Html.span` (lines 1111-1126), replace its text expression with just the elapsed time (drop `accWasSkipped`):

```elm
                [ Html.text (String.fromFloat model.lastParseTimeMs ++ "ms") ]
```

- [ ] **Step 12: Rewrite `viewPreview` / `viewPreviewBody` and delete `viewParams`**

Replace `viewPreviewBody` (lines 1226-1235) with:

```elm
{-| Render the preview body. Wrapped in Html.lazy2 so it only re-renders
when the document or options change.
-}
viewPreviewBody : Scripta.Document -> Scripta.Options -> Html Msg
viewPreviewBody document options =
    let
        output =
            Scripta.render options document
                |> Scripta.mapEvent CompilerEvent
    in
    Html.div [] output.body
```

In `viewPreview`, change the `Html.Lazy.lazy2` call (line 1222) to:

```elm
            [ Html.Lazy.lazy2 viewPreviewBody model.document model.options ]
```

Delete `viewParams` entirely (lines 1346-1366). Keep `panelWidth` (lines 1340-1343) only if still referenced; if `grep -n "panelWidth" Demo/src/Main.elm` shows no remaining callers after these edits, delete `panelWidth` too.

- [ ] **Step 13: Compile the Demo**

Run:
```bash
elm make Demo/src/Main.elm --output=/dev/null
```
Expected: compiles cleanly. If errors remain, fix them — common ones: a missed `V3.Types.`/`CompilerMsg` reference, or a leftover `model.parsedForest` / `model.expressionCache` / `model.parseMode` / `model.accWasSkipped` access. Run `grep -n "parsedForest\|expressionCache\|parseMode\|accWasSkipped\|V3\.\|CompilerMsg\|Parser\.Forest" Demo/src/Main.elm` and resolve every hit.

- [ ] **Step 14: Build the Demo bundle and commit**

```bash
elm make Demo/src/Main.elm --output=Demo/build/main.js
git add Demo/src/Main.elm Demo/build/main.js
git commit -m "Convert Demo app to the new Scripta public API

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Final verification

- [ ] **Step 1: Compile the compiler library**

Run: `elm make src/V3/Compiler.elm --output=/dev/null`
Expected: compiles cleanly. (There is no `src/Main.elm`; this is a library-style project.)

- [ ] **Step 2: Run the full test suite**

Run: `elm-test`
Expected: `TEST RUN PASSED` — 188 original tests plus the new `Scripta` (10) and `Scripta.Document` (7) tests.

- [ ] **Step 3: Compile the Demo**

Run: `elm make Demo/src/Main.elm --output=/dev/null`
Expected: compiles cleanly.

- [ ] **Step 4: Manual smoke test of the Demo**

Open `Demo/index.html` (or run `Demo/run.sh`). Verify: the document renders in the preview pane; typing in the editor updates the preview; switching documents works; the timing readout shows a number of ms; toggling the theme re-renders. Report the result.

- [ ] **Step 5: Final commit (if Step 4 required fixes)**

```bash
git add -A
git commit -m "Fix issues found in Demo smoke test

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review Notes

- **Spec coverage:** `Scripta`/`Scripta.Document` modules, opaque `Document`, opaque `Options` + builders, `String`-based entry points, trimmed `Event`, `Output`, `mapEvent`, `idsContainingSource`/`sourceOfId`/`title` — all covered. `compileToString`/`StringOutput` and `Scripta.Markup` are explicitly deferred (see Scope) with the reasons stated.
- **`parse` signature:** the plan deliberately adds `reparse` rather than altering `parse`, per the confirmed decision to keep incremental parsing.
- **Type consistency:** `Document` and `Options` are defined once in `Scripta.Internal` and aliased in `Scripta` / `Scripta.Document`. `Event` constructors (`ClickedId`, `ClickedFootnote`, `ClickedCitation`, `ClickedImage`, `ClickedLink`, `HighlightedId`) are used identically in `msgToEvent` (Task 4) and the Demo's `CompilerEvent` branch (Task 6). `makeOptions` / `viewPreviewBody` signatures match their call sites.
- **Re-export pitfall:** Task 3 Step 3 explicitly flags that Elm cannot re-export custom-type constructors, and gives the correct form (re-declare `Theme`/`Filter` in `Scripta`, map to `Internal`).
- **Deferred work** is recorded in memory files `referential-stability-followup` and `rl-sync-followup`.
