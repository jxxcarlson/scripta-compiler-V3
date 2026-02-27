# Elements with No Working Default in LaTeX Export

Items from `missing-latex-export.md` that will cause LaTeX compilation errors
because neither the preamble nor standard LaTeX defines the generated command
or environment.

Items NOT listed here have working defaults: e.g., `\strong` is in the preamble,
theorem-like blocks use `\newtheorem`, `\emph`/`\ref`/`\footnote`/`\underline`/
`\href` are standard LaTeX, `quotation`/`center`/`proof` are standard environments.

## Expression-level (inline functions)

| Name | Default output | Problem |
|------|---------------|---------|
| `sup` | `\sup{content}` | `\sup` is a math operator, not superscript |
| `sub` | `\sub{content}` | Not defined |
| `bi` | `\bi{content}` | Not defined |
| `var` | `\var{content}` | Not defined |
| `break`, `//` | `\break{content}`, `\//{content}` | Not valid |
| `mdash` | `\mdash{}` | Not defined |
| `ndash` | `\ndash{}` | Not defined |
| `ds` | `\ds{}` | Not defined (alias for `dollarSign` which IS defined) |
| `indent` | `\indent{content}` | `\indent` takes no argument |
| `quote` | `\quote{content}` | Not a command (it's an environment) |
| `abstract` | `\abstract{content}` | Not a command (it's an environment) |
| `marked` | `\marked{content}` | Not defined |
| `ulink` | `\ulink{content}` | Not defined |
| `reflink` | `\reflink{content}` | Not defined |
| `cslink` | `\cslink{content}` | Not defined |
| `hrule` | `\hrule{content}` | TeX primitive, doesn't take braced arg |
| `tableRow` | `\tableRow{content}` | Not defined |
| `tableItem` | `\tableItem{content}` | Not defined |
| `inlineimage` | `\inlineimage{content}` | Not defined |
| `scheme` | `\scheme{content}` | Not defined (interactive/app-specific) |
| `compute` | `\compute{content}` | Not defined (interactive/app-specific) |
| `data` | `\data{content}` | Not defined (interactive/app-specific) |
| `button` | `\button{content}` | Not defined (interactive/app-specific) |
| `newPost` | `\newPost{content}` | Not defined (interactive/app-specific) |

## Block-level (Ordinary)

| Name | Default output | Problem |
|------|---------------|---------|
| `note` | `\begin{note}...\end{note}` | No `\newtheorem{note}` in preamble |
| `question` | `\begin{question}...\end{question}` | No `\newtheorem{question}` in preamble |
| `compact` | `\begin{compact}...\end{compact}` | Not defined |
| `identity` | `\begin{identity}...\end{identity}` | Not defined |
| `red`, `red2`, `blue` | `\begin{red}...\end{red}` | Not defined as environments |
| `q`, `a` | `\begin{q}...\end{q}` | Not defined |
| `reveal` | `\begin{reveal}...\end{reveal}` | Not defined |
| `visibleBanner` | `\begin{visibleBanner}...\end{visibleBanner}` | Not defined |
| `sh` | `\begin{sh}...\end{sh}` | Not defined (alias for subheading) |
| `env` | `\begin{env}...\end{env}` | Not defined |
| `runninghead_` | `\begin{runninghead_}...\end{runninghead_}` | Not defined |
| `type` | `\begin{type}...\end{type}` | Not defined |
| `shiftandsetcounter` | `\begin{shiftandsetcounter}...\end{shiftandsetcounter}` | Not defined |

## Verbatim blocks

Unhandled verbatim blocks fall through to a catch-all that may produce empty
output (silent failure) rather than a LaTeX error. These are listed for
completeness — they won't cause compilation errors but content will be missing.

`datatable`, `chart`, `svg`, `array`, `textarray`, `load`, `load-data`,
`include`, `setup`, `settings`, `book`, `article`, `iframe`
