# Code Review TODO

Issues identified from review of commits 478bf68, f7e09c1, 310a0ee.

| Priority | Issue |
|----------|-------|
| High | Fix hardcoded `lineNumber = 0` in `reduceRestOfTokens` (Expression.elm:272) |
| Medium | Add missing type annotations (Tokenizer.elm:365-374) |
| Medium | Deduplicate `getAt` helper (Expression.elm:430, Match.elm:656) |
| Low | Add tests for error cases and nested expressions |
| Low | Clean up trailing space in error message (Expression.elm:352) |