# Elm-Review NoUnused Rules by Priority

1. **`NoUnused.Variables.rule`** (Highest)
   - Detects unused top-level declarations, let bindings, and imported values
   - Most impactful: unused functions/values are dead code that adds confusion
   - Easy to fix, high value

2. **`NoUnused.Parameters.rule`**
   - Detects function parameters that are never used
   - Indicates potential bugs or over-generalized function signatures
   - May require renaming to `_param` if intentionally ignored

3. **`NoUnused.CustomTypeConstructors.rule []`**
   - Detects custom type variants that are never constructed
   - Signals dead code paths or incomplete refactors
   - Can be noisy if types are exposed for external use (hence the `[]` config)

4. **`NoUnused.Patterns.rule`**
   - Detects unused patterns in case expressions and function args
   - Less critical but helps clean up pattern matching
   - Example: `( x, _ )` where `x` is unused

5. **`NoUnused.CustomTypeConstructorArgs.rule`** (Lowest)
   - Detects constructor arguments that are never extracted
   - Most granular/noisy, catches things like `Error msg` where `msg` is never read
   - Often intentional (data stored for debugging/logging)

## Recommended Activation Order

Start with rules 1-2, add 3-4 after stabilizing, consider 5 only for mature codebases.
