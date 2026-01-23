# Code Review: Markup Renderer Implementation

**Commits Reviewed:** 73373fd → b53d437 (5 commits)
**Date:** 2026-01-23
**Reviewer:** Claude Opus 4.5

## Overview

These 5 commits add **557 lines** to `src/Render/Expression.elm`, implementing ~70 markup renderers ported from V2 to V3. The work systematically covers text styling, colors, special characters, structure elements, tables, links, and interactive features.

---

## Code Quality & Style

### Strengths

- **Consistent type signatures**: All renderers follow the pattern `CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg`
- **Good organization**: Functions are grouped by category with clear section comments
- **Proper ID attributes**: All rendered elements include `HA.id meta.id` for selection/sync
- **Matches V2 behavior**: Color values, font sizes, and styling faithfully reproduce V2

### Minor Issues

1. **Unused parameters** - Many functions have unused `params` or `acc` parameters:
   ```elm
   renderBox _ _ _ meta =  -- params, acc, args all unused
   ```
   Consider using `_` prefix consistently: `_params`, `_acc`, `_args`

2. **Duplicated helper logic** - The pattern for parsing "label + target" from args appears in multiple places:
   ```elm
   -- In renderUlink, renderReflink, renderCslink:
   let
       argString = args |> List.filterMap getTextContent |> String.join " "
       words = String.words argString
       n = List.length words
       label = List.take (n - 1) words |> String.join " "
       target = List.drop (n - 1) words |> String.join ""
   ```
   **Suggestion**: Extract to a helper function `parseLabelAndTarget : List Expression -> (String, String)`

3. **Hardcoded colors** - Color hex values are scattered throughout:
   ```elm
   , ( "pink", renderColor "#ff6464" )
   , ( "magenta", renderColor "#ff33c0" )
   ```
   **Suggestion**: Consider a `textColorDict` similar to `highlightColorDict`

---

## Specific Suggestions

### 1. renderInlineImage - Missing width parameter support
```elm
renderInlineImage params _ args meta =
    case args of
        [ Text src _ ] ->
            Html.img
                [ ...
                , HA.style "max-height" "1.5em"  -- Fixed height
                ]
```
V2 supports width parameters. Consider parsing additional args.

### 2. renderButton - No click handler
```elm
renderButton _ _ args meta =
    Html.button
        [ HA.id meta.id
        , HA.style "padding" "4px 8px"
        -- Missing: HE.onClick handler
        ]
```
The button renders but does nothing when clicked. This is noted as "simplified" but may confuse users.

### 3. renderCompute/renderData - Placeholder output
```elm
[ Html.text ("[compute: " ++ content ++ "]") ]
```
These show placeholder text rather than actual computation. Consider adding a comment explaining this is intentional for V3 Phase 1.

### 4. Table cell width
```elm
renderTableItem ... =
    Html.td
        [ ...
        , HA.style "padding" "4px 8px"
        , HA.style "border" "1px solid #ddd"
        -- V2 has: Element.width (Element.px 100)
        ]
```
V2 sets fixed 100px width; V3 uses auto-width. This is probably fine but worth noting.

---

## Potential Issues

| Issue | Severity | Description |
|-------|----------|-------------|
| Empty fallbacks | Low | Several functions return empty spans on parse errors - could be confusing for debugging |
| No `alt` attribute | Low | `renderInlineImage` missing accessibility `alt` attribute |
| Unicode in source | Low | Checkbox symbols (☐☑■) embedded directly - works but could use escapes for clarity |

---

## Test Coverage

**No tests added** for any of these 70+ new functions. Consider adding tests for:
- `renderFootnote` (depends on accumulator lookup)
- `renderReflink` (depends on accumulator lookup)
- `renderTable` (complex nested structure)
- `renderHighlight` with color option parsing

---

## Security Considerations

No security issues identified:
- No raw HTML injection
- Links use proper `HA.href`
- User content is escaped via `Html.text`

---

## Summary

**Overall**: Good systematic port of V2 functionality. The code is clean, consistent, and compiles correctly.

### Recommendations

1. Extract duplicated label/target parsing logic into a helper function
2. Add tests for complex functions (footnote, reflink, table)
3. Consider consolidating color definitions into a dictionary
4. Add comments explaining simplified/placeholder implementations

---

## Commits Included

1. **73373fd** - Add text styling and alias markup functions
2. **035b52e** - Add colors, special chars, checkboxes, structure, and footnote markup
3. **60dec0d** - Add tables, images, bibliography, links, and interactive markup
4. **a3c8d13** - Add hrule and mark markup functions
5. **b53d437** - Add missing verbatim function handlers
