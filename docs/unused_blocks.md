# Block Comparison: V2 vs V3

This document compares the block handlers between ScriptaV2 and ScriptaV3.

## V3 Ordinary Blocks (55 entries)

```
section, subsection, subsubsection, item, itemList, numbered, numberedList,
theorem, lemma, proposition, corollary, definition, example, remark, note,
exercise, problem, question, axiom, proof, indent, quotation, quote, center,
abstract, title, subtitle, author, date, contents, index, box, comment, hide,
document, collection, table, desc, endnotes, subheading, sh, compact, identity,
red, red2, blue, q, a, reveal, book, chapter, section*, visibleBanner, banner,
runninghead_, tags, type, setcounter, shiftandsetcounter, bibitem, env
```

## V3 Verbatim Blocks (22 entries)

```
math, equation, aligned, code, verse, mathmacros, textmacros, datatable,
chart, svg, quiver, tikz, image, iframe, load, chem, array, textarray,
table, csvtable, verbatim, settings, load-data, hide, texComment, docinfo,
load-files, include, setup
```

## Blocks Added from V2

The following blocks were added to V3 to match V2 functionality:

| Block | Purpose | Renderer |
|-------|---------|----------|
| `subheading`, `sh` | Subheading text | `renderSubheading` |
| `compact` | Compact line spacing | `renderCompact` |
| `identity` | Pass-through (no styling) | `renderIdentity` |
| `red`, `red2`, `blue` | Colored block text | `renderColorBlock` |
| `q` | Interactive question | `renderQuestion` |
| `a` | Interactive answer | `renderAnswer` |
| `reveal` | Collapsible content | `renderReveal` |
| `book` | Document structure (no-op) | `renderNothing` |
| `chapter` | Chapter heading | `renderChapter` |
| `section*` | Unnumbered section | `renderUnnumberedSection` |
| `visibleBanner` | Visible banner image | `renderVisibleBanner` |
| `banner` | Banner (no-op) | `renderNothing` |
| `runninghead_` | Running header (no-op) | `renderNothing` |
| `tags` | Metadata tags (no-op) | `renderNothing` |
| `type` | Document type (no-op) | `renderNothing` |
| `setcounter` | Counter control (no-op) | `renderNothing` |
| `shiftandsetcounter` | Counter control (no-op) | `renderNothing` |
| `bibitem` | Bibliography entry | `renderBibitem` |
| `env` | Generic environment | `renderEnv` |

## No-Op Blocks

These blocks are recognized but render as nothing (metadata or document-level settings):

- `book` - Document structure marker
- `banner` - Hidden banner
- `runninghead_` - Running header definition
- `tags` - Document tags
- `type` - Document type
- `setcounter` - Counter manipulation
- `shiftandsetcounter` - Counter manipulation

## Notes

- Most critical missing blocks were `subheading`/`sh`, `bibitem`, and the interactive `q`/`a`/`reveal` blocks.
- The `reveal` block uses HTML `<details>`/`<summary>` for basic collapsible functionality.
- Colored blocks (`red`, `red2`, `blue`) apply CSS color to block content.
- The `env` block is a generic environment wrapper that uses its first argument as the environment name.
