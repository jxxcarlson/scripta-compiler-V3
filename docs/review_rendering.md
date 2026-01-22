# Review: Compiler.compile with Html msg Rendering Layer

**Commit:** 97c88ee
**Date:** 2026-01-22

## Summary

This commit adds a complete HTML rendering layer for the Scripta compiler, implementing `Compiler.compile` which takes source lines and produces `CompilerOutput Msg` containing rendered HTML.

## Files Changed

12 files, +1834 lines

| File | Lines | Purpose |
|------|-------|---------|
| `src/Compiler.elm` | 185 | Main compile/render functions |
| `src/Types.elm` | +87 | CompilerOutput, Msg, RenderSettings, Theme types |
| `src/Render/OrdinaryBlock.elm` | 454 | Named blocks (section, theorem, item, etc.) |
| `src/Render/VerbatimBlock.elm` | 426 | Verbatim blocks (code, math, equation) |
| `src/Render/Expression.elm` | 277 | Expression rendering with markupDict |
| `src/Render/TOC.elm` | 167 | Table of contents generation |
| `src/Render/Block.elm` | 65 | Dispatch on Heading type |
| `src/Render/Utility.elm` | 50 | Helper functions |
| `src/Render/Math.elm` | 48 | math-text custom element for KaTeX |
| `src/Render/Tree.elm` | 45 | Tree/forest traversal rendering |
| `src/Render/Settings.elm` | 32 | CompilerParameters to RenderSettings conversion |
| `elm.json` | +1 | elm/json as direct dependency |

## Architecture

- Clean module hierarchy under `src/Render/`
- Good separation of concerns: Tree traversal → Block dispatch → Expression rendering
- Dictionary-based dispatch pattern for extensible block/expression handling
- `markupDict` in Expression.elm for inline markup functions
- `blockDict` in OrdinaryBlock.elm and VerbatimBlock.elm for block types

## Issues Noted

### 1. Breaking Change to CompilerParameters

`Types.elm:164-175` - `CompilerParameters` now requires 5 fields instead of 1:

```elm
type alias CompilerParameters =
    { filter : Filter
    , windowWidth : Int
    , selectedId : String
    , theme : Theme
    , editCount : Int
    }
```

Existing code using the old single-field version will break. This appears intentional for the V3 rewrite.

### 2. SVG Rendering Placeholder

`Render/VerbatimBlock.elm` - SVG rendering is a placeholder showing `[SVG content - requires JS integration]`. Raw innerHTML injection is not supported in Elm, so this requires JavaScript interop via ports or custom elements.

### 3. Limited VFun Handling

`Render/Expression.elm:53-54` - The `VFun` case only handles:
- `$` (inline math)
- `code`

Other verbatim functions fall through to default rendering showing the content as-is.

### 4. Unused Import

`Compiler.elm` imports `Dict` but does not use it. Minor cleanup opportunity.

## Verification

- `elm make src/Compiler.elm` succeeds
- `elm-test` passes (18 tests)

## Assessment

The commit is solid with a well-structured rendering layer and good extensibility through dictionary-based dispatch. The main consideration is the intentional breaking change to `CompilerParameters` which is appropriate for a major version rewrite.
