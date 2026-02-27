# Missing HTML → LaTeX Export Mappings

Elements and blocks that have HTML renderers (in `src/Render/Expression.elm`,
`src/Render/OrdinaryBlock.elm`, `src/Render/VerbatimBlock.elm`) but are not
handled in the LaTeX exporter (`src/Render/Export/LaTeX.elm`).

When these appear in a document, they fall through to default handling:
- Inline functions: exported as `\name{content}` (may be undefined in LaTeX)
- Ordinary blocks: exported as `\begin{name}...\end{name}` (may be undefined)
- Verbatim blocks: may produce empty output or errors

## Expression-level (inline functions)

- `strong`, `emph` — formatting (partially covered by `b`/`i` aliases)
- `highlight` — text highlighting
- `href`, `ref` — hyperlinks and references
- `sup`, `sub` — superscript/subscript
- `bi`, `boldItalic` — combined bold+italic (`bolditalic` IS in macroDict)
- `var` — variable formatting
- `break`, `//` — line breaks
- `mdash`, `ndash` — em-dash, en-dash
- `dollarSign`, `ds` — literal dollar sign
- `backTick`, `bt` — backtick (`bt` IS in macroDict)
- `indent` — indentation
- `quote`, `abstract` — quotation/abstract
- `anchor` — anchor links
- `footnote` — footnotes
- `marked` — marked text
- `ulink`, `reflink`, `cslink` — various link types
- `hrule` — horizontal rule
- `underline` — underline
- `tableRow`, `tableItem` — table elements
- `inlineimage` — inline images (`image` IS in macroDict)
- `scheme`, `compute`, `data`, `button`, `newPost` — interactive/app-specific

## Block-level (Ordinary)

- `theorem`, `lemma`, `proposition`, `corollary`, `definition`, `example`,
  `remark`, `note`, `exercise`, `problem`, `question`, `axiom` — theorem-like environments
- `proof` — proof environment
- `quotation`, `center` — text layout
- `compact`, `identity` — formatting
- `red`, `red2`, `blue` — color blocks
- `q`, `a` — Q&A blocks
- `reveal` — expandable content
- `section*` — unnumbered section
- `visibleBanner` — visible banner (`banner` IS in blockDict)
- `sh` — alias for subheading (`subheading` IS in blockDict)
- `env` — generic environment
- `runninghead_`, `type`, `shiftandsetcounter` — document metadata

## Verbatim blocks

- `datatable`, `chart`, `svg` — data visualization
- `array`, `textarray` — array/table formats
- `load`, `load-data`, `include`, `setup`, `settings` — document configuration
- `book`, `article` — document type declarations
- `iframe` — embedded content
