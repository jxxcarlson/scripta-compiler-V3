# ScriptaV3 Compilation Pipeline

The ScriptaV3 compilation pipeline transforms source text into rendered HTML in these stages:

## Pipeline Diagram

```
Source Text (List String)
         │
         ▼
┌─────────────────────────────────────┐
│  1. Parser.PrimitiveBlock.parse     │
│     Lines → List PrimitiveBlock     │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  2. Generic.ForestTransform         │
│     List PrimitiveBlock → Forest    │
│     (builds tree by indentation)    │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  3. Parser.Pipeline.toExpressionBlock│
│     PrimitiveBlock → ExpressionBlock │
│     (parses inline expressions)      │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  4. Generic.Acc.transformAccumulate │
│     Adds numbering, references,     │
│     counters, macros to Accumulator │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  5. Render.Tree.renderForest        │
│     Forest → List (Html Msg)        │
│     Dispatches by Heading type      │
└─────────────────────────────────────┘
         │
         ▼
    CompilerOutput Msg
    { body, banner, toc, title }
```

## Key Modules

| Stage | Module | Input → Output |
|-------|--------|----------------|
| 1 | `Parser.PrimitiveBlock` | `List String → List PrimitiveBlock` |
| 2 | `Generic.ForestTransform` | `List PrimitiveBlock → List (Tree PrimitiveBlock)` |
| 3 | `Parser.Pipeline` | `PrimitiveBlock → ExpressionBlock` |
| 3a | `Parser.Expression` | `String → List Expression` |
| 4 | `Generic.Acc` | Accumulator pass (numbering, refs) |
| 5 | `Render.Tree` | Tree traversal |
| 5a | `Render.Block` | Dispatch on `Heading` type |
| 5b | `Render.Expression` | Render `Text`, `Fun`, `VFun`, `ExprList` |

## Entry Point

```elm
-- Compiler.elm:45-47
compile : CompilerParameters -> List String -> CompilerOutput Msg
compile params lines =
    render params (Parser.Forest.parseToForestWithAccumulator params lines)
```
