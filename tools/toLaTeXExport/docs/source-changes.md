# Source Changes to Test Documents

Changes made to `.scripta` files in `tests/toLaTeXExportTestDocs/` to fix
LaTeX export errors. Organized by file.

## Summary

Files with source corrections:

- **datasci.scripta** -- [term]->[index], inline image->block image, macro rename (\bx->\bfx)
- **mltt.scripta** -- [term]->[index], malformed \set macro, duplicate macros, \renewcommand for TeX primitives, ETeX-inside-\text fixes
- **virial.scripta** -- [term]->[index]

## datasci.scripta

### Commit 605a3f6

- **[term] -> [index]**: Changed `[term rise]`, `[term run]` to `[index rise]`, `[index run]`
- **Inline image -> block image**: Converted `[image URL CAPTION k:v]` to block `| image` syntax (22 images transformed via `tools/transform-images.sh`)
- **Trailing whitespace**: Removed trailing spaces on several lines

### Commit 1c0def8

- **Macro rename**: `\newcommand{\bx}{\mathbf x}` -> `\newcommand{\bfx}{\mathbf x}` to avoid ETeX collision (`bx` in `$ax^2 + bx + c$` was being resolved to `\bx`)
- **Image block cleanup**: Further inline `[image ...]` -> block `| image` conversions

## mltt.scripta

### Commit 27c01fb

- **[term] -> [index]**: Replaced all 29 occurrences of `[term ...]` with `[index ...]`
- **Malformed \newcommand**: Fixed `\newcommand{\set}[1]}` (extra `}`) -> `\newcommand{\set}[1]`
- **Duplicate macros**: Removed duplicate `\newcommand{\nat}` and `\newcommand{\rec}`

### Uncommitted (pending)

- **TeX primitive conflict**: `\newcommand{\and}` -> `\renewcommand{\and}`, `\newcommand{\or}` -> `\renewcommand{\or}` (both are TeX primitives)
- **ETeX inside \text{}**: `\text{true}` -> `\true` on line 90 (ETeX was converting `true` to `\true` inside `\text{}`)
- **ETeX inside \text{}**: `\text{ Empty type}` -> `\text{ Empty Type}` on line 794 (ETeX was converting `type` to `\type`)
- **ETeX inside \text{}**: `\text{ is propositionaly equal to }` -> `\quad n + 0 \equiv n` on line 960 (ETeX was converting `to` to `\to`)
- **ETeX inside \label{}**: `\label{boolean-computation}` -> `\label{bool-computation}` on line 464 (ETeX was converting `boolean` to `\boolean`)

## virial.scripta

### Commit 27c01fb

- **[term] -> [index]**: Changed `[term moment of inertia]` to `[index moment of inertia]`

## image.scripta

### Commit 1c0def8

- Minor formatting changes

## Files with no source changes needed

- `welcome.scripta` -- 1 error is a PDF server false positive (`\end{verbatim}` reported spuriously)
- `manual.scripta` -- 1 error is the same PDF server false positive
- `mathnotation-inline.scripta` -- 0 errors
- `bohr-debroglie.scripta` -- 0 errors
- `aligned-test1.scripta` -- 0 errors
- `aligned-test2.scripta` -- 0 errors
- `etex.scripta` -- 0 errors
- `index-test.scripta` -- 0 errors
- `graph-color.scripta` -- errors require exporter fixes, not source changes
