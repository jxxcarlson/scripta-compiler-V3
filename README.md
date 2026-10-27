# Scripta compiler

Compile [Scripta](https://x-scripta.app) markup to Html, and export it to LaTeX.

The package exposes two modules:

- **`Scripta`** — options, parsing (including incremental re-parsing after edits),
  rendering, and export to Html and LaTeX.
- **`Scripta.Document`** — questions about a parsed document: its title, whether it has
  sections, and the mapping between rendered ids and source text.

## Rendering

```elm
import Scripta

-- One shot: parse and render.
view source =
    let
        output =
            Scripta.compile Scripta.defaultOptions source
    in
    Html.div [] (output.title :: output.body)
```

`render` and `compile` return an `Output Event`: the rendered `title`, `body`, `toc` and an
optional `banner`. `Event` describes clicks on paragraphs, footnotes, citations, images and
links; use `Scripta.mapEvent` to turn it into your own message type.

For an editor, parse once and keep the `Document` in your model. `reparse`, `applyEdit` and
`applyEdits` bring it up to date after an edit, reusing the unchanged parts.

Options are built from `defaultOptions` with `withTheme`, `withWindowWidth`,
`withContentWidth`, `withTOC`, `withMaxLevel`, `withSizing` and `withFilter`.

## Export

- `Scripta.exportHtml options document` — a standalone Html page.
- `Scripta.exportLaTeX { title, authors } document` — a complete LaTeX document, ready for
  `xelatex`.
- `Scripta.exportRawLaTeX document` — the LaTeX body only, without the preamble.
- `Scripta.prettyPrint source` — Scripta source rewritten with standard indentation and
  spacing.

## Math

Math is emitted as `<math-text>` custom elements with two properties: `content` (the TeX
source) and `display` (`True` for display math). The host page must define `math-text`;
without it, math is not typeset. [`Demo/index.html`](Demo/index.html) defines it with KaTeX.

## Demo

[`Demo/`](Demo) is a live-preview editor built on the package. It is an application with its
own `elm.json` that compiles the package from `../src`, so it always shows the current source:

```bash
cd Demo
elm make src/Main.elm --output=main.js
open index.html
```

## Development

```bash
elm make --docs=docs.json   # build and check the documentation
elm-test                    # run the tests (elm-test 0.19.2-0 for elm 0.19.2)
```
