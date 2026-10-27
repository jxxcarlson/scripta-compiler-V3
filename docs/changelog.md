# Changelog

## Unreleased

- **ETeX now comes from the package `jxxcarlson/etex` (≥ 1.1.0)** instead of a copy in
  `src/ETeX/`, which is deleted. The two had drifted apart; their code was merged into etex 1.1.0
  first. Export output is byte-identical on all 193 cases of scripta-app-v4's export harness.
  The ETeX tests moved to the etex repo (compiler tests: 215, passing). `Demo/elm.json` lists
  the etex dependency, since the Demo compiles `../src`.
- **Fix: `$\ $` (a control space) rendered as "[ETeX error]".** The ETeX step trimmed math
  before parsing, so a trailing `\ ` became a lone `\`, which cannot parse. A new `trimMath`
  keeps a space that follows an unescaped backslash (an odd number of backslashes); after `\\`
  (a line break) the space is still trimmed. Affects on-screen rendering (`evalStr`) and LaTeX
  export (`transformETeX`). Tests: 4 in `tests/ETeX/TransformTest.elm`, 2 end-to-end in
  `tests/ControlSpaceTest.elm` (checked to fail without the fix); 296 in all, passing.

## 1.0.0 — 2026-10-27

First release as the Elm package `jxxcarlson/scripta-compiler-v3` (MIT).

- **Public API:** two modules, `Scripta` (options, parsing and incremental re-parsing,
  rendering, export) and `Scripta.Document` (title, sections, id ↔ source mapping). Everything
  else is internal.
- **New in `Scripta`:** `exportLaTeX` (a complete LaTeX document, given a title and authors),
  `exportRawLaTeX` (body only) and `prettyPrint`. Tests pin each to the internal call it wraps,
  so apps that switched to them saw byte-identical output.
- **Package setup:** dependencies as version ranges; `elm/html` ≥ 1.0.0 and `elm/json` ≥ 1.1.3
  (checked by compiling against those versions); `elm/browser` and `zwilias/elm-rosetree`
  dropped as unused. README rewritten for the package site, including the `<math-text>`
  element the host page must define.
- **`Demo/`** is an application with its own `elm.json` that compiles `../src`.
- `Render.Sizing` tests moved here from scripta-app-v4. Tests: 290, all passing.

Developed on branch `redesign-API`, merged into `main` before publishing. scripta-app-v4
switched from its vendored copy to this package the same day.
