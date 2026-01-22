# Generic.Acc and ForestTransform Setup

Here's a summary of what was created/modified:

## New modules created

| Module | Purpose |
|--------|---------|
| `Tools.String` | `makeSlug` for URL-friendly strings |
| `Tools.Utility` | `compressWhitespace` |
| `Generic.Settings` | `numberedBlockNames`, `indentationQuantum` |
| `Generic.ASTTools` | `getText`, `filterExpressionsOnName_` |
| `Generic.BlockUtilities` | `getExpressionBlockName` |
| `Generic.TextMacro` | `Macro` type, `expand`, `buildDictionary` (stubs) |
| `Library.Tree` | Rose tree utilities |
| `Library.Forest` | Forest construction from blocks |

## Packages installed

- `maca/elm-rose-tree` (for `RoseTree.Tree`)
- `zwilias/elm-rosetree` (for `Tree`)
- `elm-community/maybe-extra`

## Files modified

- `Generic.Acc` - Updated imports to use V3 `Types`, removed V2-specific dependencies
- `Generic.ForestTransform` - Now compiles with rose tree packages
