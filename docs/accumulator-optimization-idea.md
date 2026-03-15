    # Accumulator-Independent Block Optimization
    
    ## What `updateAccumulator` does for a `Paragraph`
    
    From `Acc.elm:1266-1281`, every paragraph updates:
    - `inListState` — trivial, based on heading type
    - `footnotes` / `footnoteNumbers` — only if content contains `[footnote ...]`
    - `terms` — only if content contains `[term ...]` or `[index ...]`
    - `bibliography` — only if content contains `[cite ...]`
    
    And `updateReferenceWithBlock` is also called, but only inserts a reference if the block has a `tag` property.
    
    ## What `transformBlock` does for a `Paragraph`
    
    It falls through to the default case, which checks if the block name is in `numberedBlockNames`. A paragraph has no name, so it just calls `expand acc.textMacroDict` — which is a no-op unless the paragraph uses text macros.
    
    ## The classification
    
    A paragraph is **accumulator-independent** if its expressions contain none of these function names: `footnote`, `term`, `index`, `cite`, `ref`, `eqref`, `label`, and no text macro calls. That covers the vast majority of paragraphs — the typical case is just text with `[strong ...]`, `[italic ...]`, `[link ...]`, inline math `$...$`, etc.
    
    The check is cheap — a single recursive walk over the expression tree looking for a handful of function names. For a typical paragraph that's maybe 5-20 expression nodes.
    
    ## The optimization
    
    When the edited block is accumulator-independent:
    
    1. **Skip `transformAccumulate` entirely** — reuse the previous `(Accumulator, Forest)`
    2. **Splice the new block content** into the existing forest at the right position
    3. Cost: O(expression nodes in edited block) for the check, vs O(all blocks in document) for the full accumulator pass
    
    ## One structural requirement
    
    You need to verify the **forest structure hasn't changed** — same number of trees, same headings. If the user adds a blank line and splits a paragraph into two, or deletes a blank line and merges two blocks, that's a structural change and you'd need the full pass. This check is also cheap: compare the list of `(heading, indent)` pairs between old and new forests.
    
    ## Summary
    
    For the most common editing case — typing in a text paragraph — this skips the accumulator entirely. The check is O(small) and the savings are O(n) where n is the total number of blocks. For a large document like MLTT VX, this could be significant.
