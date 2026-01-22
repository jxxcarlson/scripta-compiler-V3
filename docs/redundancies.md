# Render.* Module Redundancies

Analysis of redundant or unnecessary code in the Render modules.

## 1. Render.Settings.elm

**Lines 24-32: `makeSettings` function**
- Never used anywhere in the codebase
- `fromParams` is what's actually used
- Can be removed

## 2. Render.Utility.elm

**Lines 20-22: `makeId` function**
- Never used in Render modules
- Parser/Expression.elm has its own local `makeId` (lines 405-406)
- Can be removed from Render.Utility

**Lines 43-50: `highlightStyle` function**
- Never used anywhere in the codebase
- Can be removed

**Lines 13-15: `idAttr` function**
- Used throughout Render modules
- However, it's a trivial wrapper that just calls `HA.id id`
- Could be inlined at call sites, but low priority

## 3. Render.Tree.elm

**Line 41: No-op style**
```elm
HA.style "margin-left" "0px"
```
- Setting margin-left to 0px has no effect (it's the default)
- Can be removed

## 4. Render.VerbatimBlock.elm

**Lines 184-188: `applyMathMacros` misleading name and unused parameter**
```elm
applyMathMacros : Dict String String -> String -> String
applyMathMacros _ content =
    ETeX.Transform.evalStr Dict.empty content
```
- Function name suggests it applies math macros, but it actually runs ETeX transform
- The `mathMacroDict` parameter (first argument) is completely ignored
- Should be renamed to `applyETeXTransform` and parameter removed, or the dict should actually be used

## 5. Render.Expression.elm

**Lines 91-93: Duplicate `applyETeXTransform`**
```elm
applyETeXTransform : String -> String
applyETeXTransform content =
    ETeX.Transform.evalStr Dict.empty content
```
- Same logic exists in VerbatimBlock.elm (named `applyMathMacros`)
- Should be consolidated into a shared helper, possibly in Render.Math or a new Render.ETeX module

## 6. Render.OrdinaryBlock.elm

**Lines 146-161: Redundant `renderSubsection` and `renderSubsubsection`**
- These functions duplicate logic already handled by `renderSection` via the `level` property
- `renderSection` already supports levels 1-4 with appropriate heading tags (h2-h5)
- Could be removed and have "subsection"/"subsubsection" map to `renderSection` in `blockDict`

**Lines 439-454: Duplicate hidden block renderers**
- `renderComment`, `renderDocument`, `renderCollection`, `renderIndexBlock` all produce identical output:
```elm
[ Html.div [ idAttr block.meta.id, HA.style "display" "none" ] [] ]
```
- Could share a single `renderHidden` helper function

## 7. Unused Parameters (Low Priority)

Many renderer functions receive `params`, `settings`, `acc` but don't use all of them. This is acceptable for consistency of function signatures in the dictionary-based dispatch pattern, but worth noting:

- `renderText` in Expression.elm doesn't use params, settings, or acc
- `renderIndex` in Expression.elm doesn't use params, settings, or acc
- Various OrdinaryBlock renderers only use subset of parameters

## Summary of Recommended Removals

| File | Item | Action |
|------|------|--------|
| Render/Settings.elm | `makeSettings` | Remove |
| Render/Utility.elm | `makeId` | Remove |
| Render/Utility.elm | `highlightStyle` | Remove |
| Render/Tree.elm | `margin-left: 0px` | Remove |
| Render/VerbatimBlock.elm | `applyMathMacros` | Rename and fix |
| Render/Expression.elm | `applyETeXTransform` | Consolidate with VerbatimBlock |
| Render/OrdinaryBlock.elm | `renderSubsection` | Consider consolidating |
| Render/OrdinaryBlock.elm | `renderSubsubsection` | Consider consolidating |
| Render/OrdinaryBlock.elm | Hidden renderers | Extract shared helper |
