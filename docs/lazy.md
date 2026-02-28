# Html.lazy Optimization Analysis

## Current Situation

There are zero uses of `Html.lazy` in the codebase. The critical bottleneck is in `Demo/src/Main.elm:674`:

```elm
output =
    V3.Compiler.compile params (String.lines model.sourceText)
```

This runs the full compile pipeline (parse + accumulate + render to HTML) inside `view` on every render -- including renders triggered by clicking an element, pressing Escape, toggling sort mode, etc.

## The Core Coupling Problem

`selectedId` is passed through `CompilerParameters` all the way down to every block renderer via `Render.Utility.blockIdAndStyle` (~64 call sites across 4 render files). This means the entire HTML tree changes when `selectedId` changes, defeating any caching at the output level.

## Recommended Optimizations (Priority Order)

### 1. CSS-based selection highlighting (HIGHEST IMPACT, unlocks everything else)

**Problem**: Every click triggers a full re-render of all HTML just to change one block's `background-color`.

**Solution**: Instead of inline styles computed in Elm per-block, emit a constant CSS class on every block and inject a single dynamic `<style>` element:

```elm
Html.node "style" [] [ Html.text ("#" ++ selectedId ++ " { background-color: #d0e8ff; }") ]
```

This makes the entire rendered tree stable across click interactions.

**Files**: `src/Render/Utility.elm` (remove selectedId-dependent styling), all ~64 call sites in `Render/OrdinaryBlock.elm`, `Render/VerbatimBlock.elm`, `Render/Block.elm`, `Render/Expression.elm`.

### 2. Move compilation from `view` to `update` (HIGH IMPACT)

**Problem**: `V3.Compiler.compile` runs on every view call.

**Solution**: Store compiled output in the Model. Recompute only on `SourceChanged`, `SelectDocument`, `NewDocument`, `ConfirmDelete`.

Messages like `CompilerMsg SelectId`, `EscapePressed`, `ToggleTheme`, `SetSortMode`, `WindowResized` would skip recompilation entirely.

**Files**: `Demo/src/Main.elm` -- add compiled result to Model, recompute in `update` only when `sourceText` changes.

### 3. Html.lazy on viewHeader (TRIVIAL, free win)

`viewHeader` depends only on `model.theme`. Wrap it:

```elm
Html.lazy viewHeader_ model.theme
```

where `viewHeader_` takes just a `Theme`. Header re-renders drop from every keystroke to only on theme toggle.

### 4. Html.lazy on viewSidebar (MODERATE)

Depends on `model.documents`, `model.currentDocumentId`, `model.sortMode`, `model.theme`. Use `Html.lazy4` or a tuple wrapper. Sidebar skips re-render on click/highlight/escape interactions.

### 5. Html.lazy on viewPreview (HIGH, after #1 and #2)

Once compilation is cached and `selectedId` is decoupled, the preview becomes stable across non-edit interactions:

```elm
Html.lazy2 viewPreviewBody compiledOutput model.theme
```

This is the "big payoff" -- the entire rendered document tree is skipped by Elm's virtual DOM diffing when nothing relevant changed.

### 6. Per-tree lazy in renderForest (ADVANCED, large docs only)

Wrap individual top-level trees in `Html.lazy` so editing paragraph 5 doesn't re-render paragraphs 1-4. Requires stable tree references from the parser (deeper architectural change).

## Lamdera Compatibility Constraint

Lamdera automatically serializes `FrontendModel`, `BackendModel`, and all message types for wire transmission and backend persistence. Function types cannot be serialized.

### Impact on Optimization #2

`CompilerOutput Msg` contains `Html Msg`, which internally holds event handler closures. Storing `Html Msg` in `FrontendModel` would break Lamdera.

**Solution**: Cache the intermediate result instead.

The compile pipeline has two phases:

```
sourceText -> [parse + accumulate] -> (Accumulator, List (Tree ExpressionBlock)) -> [render] -> Html Msg
                  EXPENSIVE                    ALL PLAIN DATA                        CHEAPER
```

Both `Accumulator` and `List (Tree ExpressionBlock)` are 100% function-free -- they contain only `String`, `Int`, `Dict`, `List`, custom unions, and records. Safe for Lamdera serialization.

The Lamdera-compatible approach:
- Store `(Accumulator, List (Tree ExpressionBlock))` in the FrontendModel
- Recompute this only when `sourceText` changes
- Re-render to `Html Msg` in `view` from the cached forest (cheaper step)
- Apply `Html.lazy` on the render step

### Impact Summary

| Optimization | Lamdera impact |
|---|---|
| #1 CSS-based selection | None -- purely rendering |
| #2 Cache compilation | Must cache the parsed forest, not Html -- still effective |
| #3 lazy viewHeader | None -- purely rendering |
| #4 lazy viewSidebar | None -- purely rendering |
| #5 lazy viewPreview | None -- purely rendering |
| #6 Per-tree lazy | None -- purely rendering |

## What Triggers Re-renders

| Message | Fields Changed | Should Recompile? |
|---------|---------------|-------------------|
| `SourceChanged` | sourceText, documents, editCount | YES |
| `SelectDocument` | currentDocumentId, sourceText, editCount | YES |
| `NewDocument` | documents, currentDocumentId, sourceText, editCount | YES |
| `ConfirmDelete` | documents, currentDocumentId, sourceText, editCount, deleteConfirmation | YES |
| `CompilerMsg SelectId/SendMeta/...` | selectedId, previousId, debugClickCount | NO |
| `EscapePressed` | selectedId, previousId | NO |
| `ShiftEscapePressed` | selectedId, previousId | NO |
| `ToggleTheme` | theme | NO (re-render, no reparse) |
| `WindowResized` | windowWidth, windowHeight | NO (layout only) |
| `SetSortMode` | sortMode | NO (sidebar only) |
| `RequestDeleteDocument` | deleteConfirmation | NO (modal only) |
| `CancelDelete` | deleteConfirmation | NO (modal only) |

## Net Effect

Parsing + accumulation is the expensive part of the pipeline (tokenization, block parsing, forest construction, macro expansion, cross-reference resolution). Rendering from an already-parsed forest is comparatively fast. The main performance win -- skipping the full parse on clicks, escapes, theme toggles, etc. -- is fully achievable within Lamdera's serialization constraints.
