#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const DOCS_DIR = path.join(__dirname, "..", "..", "tests", "toLaTeXExportTestDocs");

// ---------------------------------------------------------------------------
// Known commands — sourced from src/ETeX/KaTeX.elm (513 commands)
// plus standard LaTeX text-mode commands used by the exporter
// ---------------------------------------------------------------------------

// From ETeX.KaTeX: greekLetters, binaryOperators, relationSymbols, arrows,
// delimiters, bigOperators, mathFunctions, accents, fonts, spacing,
// logicAndSetTheory, miscSymbols, fractions, binomials, roots, textOperators
const KATEX_COMMANDS = [
  // Greek letters (lowercase)
  "alpha","beta","gamma","delta","epsilon","varepsilon","zeta","eta","theta",
  "vartheta","iota","kappa","varkappa","lambda","mu","nu","xi","pi","varpi",
  "rho","varrho","sigma","varsigma","tau","upsilon","phi","varphi","chi","psi","omega",
  // Greek letters (uppercase)
  "Gamma","Delta","Theta","Lambda","Xi","Pi","Sigma","Upsilon","Phi","Psi","Omega",
  "digamma","varGamma","varDelta","varTheta","varLambda","varXi","varPi",
  "varSigma","varUpsilon","varPhi","varPsi","varOmega",
  // Binary operators
  "pm","mp","times","div","cdot","ast","star","circ","bullet","oplus","ominus",
  "otimes","oslash","odot","dagger","ddagger","vee","lor","wedge","land","cap",
  "cup","setminus","smallsetminus","triangleleft","triangleright","bigtriangleup",
  "bigtriangledown","lhd","rhd","unlhd","unrhd","amalg","uplus","sqcap","sqcup",
  "boxplus","boxminus","boxtimes","boxdot","leftthreetimes","rightthreetimes",
  "curlyvee","curlywedge","dotplus","divideontimes","doublebarwedge",
  // Relation symbols
  "leq","le","geq","ge","neq","ne","sim","simeq","approx","cong","equiv","prec",
  "succ","preceq","succeq","ll","gg","subset","supset","subseteq","supseteq",
  "nsubseteq","nsupseteq","sqsubset","sqsupset","sqsubseteq","sqsupseteq","in",
  "ni","notin","notni","propto","varpropto","perp","parallel","nparallel","smile",
  "frown","doteq","vdash","vDash","Vdash","models",
  // Arrows
  "leftarrow","gets","rightarrow","to","leftrightarrow","Leftarrow","Rightarrow",
  "Leftrightarrow","iff","uparrow","downarrow","updownarrow","Uparrow","Downarrow",
  "Updownarrow","mapsto","hookleftarrow","hookrightarrow","leftharpoonup",
  "rightharpoonup","leftharpoondown","rightharpoondown","rightleftharpoons",
  "longleftarrow","longrightarrow","longleftrightarrow","Longleftarrow","impliedby",
  "Longrightarrow","implies","Longleftrightarrow","longmapsto","nearrow","searrow",
  "swarrow","nwarrow","xrightarrow","xleftarrow",
  // Delimiters
  "lbrace","rbrace","lbrack","rbrack","langle","rangle","vert","Vert","lvert",
  "rvert","lVert","rVert","lfloor","rfloor","lceil","rceil",
  // Big operators
  "sum","prod","coprod","bigcup","bigcap","bigvee","bigwedge","bigoplus",
  "bigotimes","bigodot","biguplus","bigsqcup","int","oint","iint","iiint",
  // Math functions
  "sin","cos","tan","cot","sec","csc","sinh","cosh","tanh","coth","sech","csch",
  "arcsin","arccos","arctan","ln","log","lg","exp","deg","det","dim","hom","ker",
  "lim","liminf","limsup","max","min","sup","inf","Pr","gcd","lcm","arg","mod",
  "bmod","pmod",
  // Accents
  "hat","widehat","check","widecheck","tilde","widetilde","acute","grave","dot",
  "ddot","breve","bar","vec","mathring","overline","underline",
  // Fonts
  "mathrm","mathit","mathbf","boldsymbol","pmb","mathbb","Bbb","mathcal","cal",
  "mathscr","scr","mathfrak","frak","mathsf","sf","mathtt","tt","mathnormal",
  "text","textbf","textit","textrm","textsf","texttt","textnormal","operatorname",
  // Spacing
  "quad","qquad","space","thinspace","medspace","thickspace","enspace",
  "phantom","hphantom","vphantom","kern","hskip","hspace","mkern","mskip",
  // Logic and set theory
  "forall","exists","nexists","complement","mid","nmid","emptyset","varnothing",
  "neg","lnot",
  // Misc symbols
  "infty","aleph","partial","nabla","Box","square","triangle","angle","prime",
  "degree","top","bot","clubsuit","diamondsuit","heartsuit","spadesuit","ldots",
  "cdots","ddots","vdots",
  // Fractions, binomials, roots
  "frac","dfrac","tfrac","cfrac","over","binom","dbinom","tbinom","sqrt",
  // Text operators
  "not","cancel","bcancel","xcancel","sout","overset","underset","stackrel","substack",
  // Environments (appear after \begin/\end)
  "pmatrix","bmatrix","vmatrix","Vmatrix","cases",
];

// Standard LaTeX text-mode commands used by the exporter
const LATEX_TEXT_COMMANDS = [
  "textbf","textit","emph","lstinline","item","bibitem","index","label","ref",
  "eqref","section","subsection","subsubsection","chapter","begin","end","href",
  "url","cite","includegraphics","centering","caption","footnote","par","newline",
  "clearpage","newpage","tableofcontents","maketitle","makeindex","printindex",
  "textcolor","scalebox","usepackage","documentclass","title","author","date",
  "textwidth","linewidth","columnwidth","paperwidth",
  "vspace","hfill","noindent","bigskip","medskip","smallskip",
  "errorHighlight", // parser error marker — handled by parse-error-passthrough rule
  "markwith","anchor","ilink","strong","italic","strike","hide",
  "hang","compactItem","code","ellie","imagecenter","imagefloat",
  "red","blue","violet","green","gray","magenta","cyan","orange","pink","black",
  "u","st",
];

const KNOWN_COMMANDS = new Set(
  [...KATEX_COMMANDS, ...LATEX_TEXT_COMMANDS].map((c) => "\\" + c)
);

// Extract user-defined macro names from a .scripta file's mathmacros block
function extractUserMacros(scriptaPath) {
  const fs = require("fs");
  if (!fs.existsSync(scriptaPath)) return new Set();
  const src = fs.readFileSync(scriptaPath, "utf-8");
  const macros = new Set();
  const re = /\\newcommand\{\\([a-zA-Z]+)\}/g;
  let m;
  while ((m = re.exec(src)) !== null) {
    macros.add("\\" + m[1]);
  }
  return macros;
}

// ---------------------------------------------------------------------------
// Error classification rules
// ---------------------------------------------------------------------------

const RULES = [
  {
    category: "parse-error-passthrough",
    pattern: "bare-errorHighlight",
    test: (latexText) => latexText.includes("\\errorHighlight{"),
    explanation: "Parser error marker \\errorHighlight leaked into LaTeX output",
    fixLocation: "src/Render/Export/LaTeX.elm — exportExpr (line 1663)",
    fixHint:
      "The parser produced an error expression that the exporter rendered literally. " +
      "Either fix the parser to handle this input, or add a fallback in exportExpr " +
      "that strips/replaces \\errorHighlight markers.",
  },
  {
    category: "missing-handler",
    pattern: "bare-backtick",
    test: (latexText) => /(?:^|[^\\])` /.test(latexText) || / `(?:$|[^\\])/.test(latexText),
    explanation: "Backtick element [bt ] not converted to \\lstinline",
    fixLocation: "src/Render/Export/LaTeX.elm — exportExpr / macroDict (line 1217)",
    fixHint:
      "Add 'bt' handling in exportExpr (around line 1668) or add an entry " +
      "to macroDict (line 1217) that converts [bt ] to \\lstinline|...|.",
  },
  {
    category: "bibliography",
    pattern: "bibitem-structure",
    test: (latexText) => latexText.includes("\\bibitem{"),
    explanation: "Bibliography item \\bibitem causing undefined \\@listctr error",
    fixLocation:
      "src/Render/Export/LaTeX.elm — exportBibitem (line 1271) / exportBibliographyBegin (line 1262)",
    fixHint:
      "Check that \\begin{thebibliography}{N} is emitted before \\bibitem entries " +
      "and that the list counter is properly initialised.",
  },
  {
    category: "math-mode",
    pattern: "missing-dollar",
    test: (latexText) => /[_^]/.test(latexText)
      && !latexText.includes("\\lstinline")
      && !latexText.includes("$")
      && !latexText.includes("\\(")
      && !latexText.includes("\\begin{equation}")
      && !latexText.includes("\\begin{align}")
      && !latexText.includes("\\begin{pmatrix}")
      && !latexText.includes("\\begin{bmatrix}"),
    explanation: "Math characters (^ or _) appear outside math mode",
    fixLocation: "src/Render/Export/LaTeX.elm — mapChars2 (line 1179) or inline code handler",
    fixHint:
      "Either the source text contains math characters that should be in " +
      "a [code] or [math] element, or mapChars2 needs to escape them.",
  },
  {
    category: "escaping",
    pattern: "unescaped-special",
    test: (latexText) => {
      // Look for unescaped &, #, % outside of known-safe commands
      const stripped = latexText
        .replace(/\\lstinline\|[^|]*\|/g, "")
        .replace(/\\[a-zA-Z]+\{[^}]*\}/g, "")
        .replace(/\\[&#%]/g, "");
      return /[&#%]/.test(stripped);
    },
    explanation: "Special LaTeX characters (&, #, or %) not escaped",
    fixLocation: "src/Render/Export/LaTeX.elm — mapChars2 (line 1179)",
    fixHint:
      "Add escaping rules to mapChars2: & → \\&, # → \\#, % → \\%.",
  },
  {
    category: "undefined-command",
    pattern: "undefined-control-sequence",
    // This rule receives userMacros as a third argument via classify()
    test: (latexText, _scriptaText, userMacros) => {
      const unknowns = latexText.match(/\\[a-zA-Z]+/g) || [];
      const found = [...new Set(unknowns.filter((cmd) =>
        !KNOWN_COMMANDS.has(cmd) && !(userMacros && userMacros.has(cmd))
      ))];
      return found.length > 0 ? found : false;
    },
    explanation: "LaTeX output contains a control sequence not in the standard set",
    fixLocation:
      "src/Render/Export/LaTeX.elm — blockDict (line 1284) or macroDict (line 1217)",
    fixHint:
      "Check whether the command is intentional. If so, ensure the preamble " +
      "defines it. If not, fix the export function that generated it.",
  },
];

// ---------------------------------------------------------------------------
// Classification
// ---------------------------------------------------------------------------

function classify(errorEntry, scriptaLines, latexLines, userMacros) {
  const latexText = errorEntry["latex-text"] || "";
  const scriptaLine = errorEntry["scripta-line"];
  const latexLine = errorEntry["latex-line"];

  // Extract context (3 lines around the error, 0-indexed)
  const scriptaContext = extractContext(scriptaLines, scriptaLine - 1, 1);
  const latexContext = extractContext(latexLines, latexLine - 1, 1);

  // Try each rule in order; first match wins
  // A rule's test() returns truthy on match. For undefined-command it returns
  // the array of unknown commands; for others it returns true/false.
  for (const rule of RULES) {
    const result = rule.test(latexText, null, userMacros);
    if (result) {
      const entry = {
        scriptaLine,
        scriptaContext,
        latexLine,
        latexContext,
        category: rule.category,
        pattern: rule.pattern,
        explanation: rule.explanation,
        fixLocation: rule.fixLocation,
        fixHint: rule.fixHint,
      };
      // If the rule returned detail (e.g. list of unknown commands), include it
      if (Array.isArray(result)) {
        entry.unknownCommands = result;
        entry.explanation =
          "Undefined control sequence(s): " + result.join(", ");
      }
      return entry;
    }
  }

  // Fallback: unclassified
  return {
    scriptaLine,
    scriptaContext,
    latexLine,
    latexContext,
    category: "unclassified",
    pattern: "unknown",
    explanation: "Error did not match any known pattern",
    fixLocation: "src/Render/Export/LaTeX.elm",
    fixHint: "Inspect the latex-text field manually to determine the root cause.",
  };
}

function extractContext(lines, index, radius) {
  if (!lines || index < 0 || index >= lines.length) return "";
  const start = Math.max(0, index - radius);
  const end = Math.min(lines.length - 1, index + radius);
  return lines.slice(start, end + 1).join("\n");
}

// ---------------------------------------------------------------------------
// Summary mode
// ---------------------------------------------------------------------------

function runSummary() {
  const files = fs.readdirSync(DOCS_DIR).filter((f) => f.endsWith("-diagnosis.json"));
  if (files.length === 0) {
    console.log("No diagnosis files found. Run 'node diagnose.js <basename>' first.");
    process.exit(0);
  }

  const rows = [];
  let total = 0;

  for (const file of files.sort()) {
    const data = JSON.parse(fs.readFileSync(path.join(DOCS_DIR, file), "utf-8"));
    const topCat = Object.entries(data.categories || {}).sort((a, b) => b[1] - a[1])[0];
    const topStr = topCat ? `${topCat[0]} (${topCat[1]})` : "none";
    rows.push({ file: data.file, errors: data.totalErrors, topCategory: topStr });
    total += data.totalErrors;
  }

  // Print table
  const colFile = Math.max(4, ...rows.map((r) => r.file.length)) + 2;
  const colErr = 8;
  const header =
    "File".padEnd(colFile) + "Errors".padEnd(colErr) + "Top Category";
  console.log(header);
  console.log("-".repeat(header.length + 20));
  for (const r of rows) {
    console.log(
      r.file.padEnd(colFile) +
        String(r.errors).padEnd(colErr) +
        r.topCategory
    );
  }
  console.log("-".repeat(header.length + 20));
  console.log("TOTAL".padEnd(colFile) + String(total));
}

// ---------------------------------------------------------------------------
// Single-file diagnosis
// ---------------------------------------------------------------------------

function runDiagnosis(basename) {
  const errorsPath = path.join(DOCS_DIR, basename + "-errors.json");
  const scriptaPath = path.join(DOCS_DIR, basename + ".scripta");
  const texPath = path.join(DOCS_DIR, basename + "-2.tex");
  const outputPath = path.join(DOCS_DIR, basename + "-diagnosis.json");

  // Check required files exist
  if (!fs.existsSync(errorsPath)) {
    console.error("Error file not found:", errorsPath);
    process.exit(1);
  }
  if (!fs.existsSync(scriptaPath)) {
    console.error("Scripta source not found:", scriptaPath);
    process.exit(1);
  }

  // Load files
  const errorsRaw = JSON.parse(fs.readFileSync(errorsPath, "utf-8"));

  // Handle the {hasErrors: false} case
  if (!Array.isArray(errorsRaw)) {
    if (errorsRaw.hasErrors === false) {
      const report = {
        file: basename,
        totalErrors: 0,
        categories: {},
        errors: [],
        summary: "No errors.",
      };
      fs.writeFileSync(outputPath, JSON.stringify(report, null, 2));
      console.log(basename + ": No errors. Wrote:", outputPath);
      return;
    }
    console.error("Unexpected format in", errorsPath);
    process.exit(1);
  }

  const scriptaLines = fs.readFileSync(scriptaPath, "utf-8").split("\n");
  const latexLines = fs.existsSync(texPath)
    ? fs.readFileSync(texPath, "utf-8").split("\n")
    : [];

  // Extract user-defined macros from the .scripta file to avoid false positives
  const userMacros = extractUserMacros(scriptaPath);

  // Classify each error
  const diagnosed = errorsRaw.map((entry, i) => ({
    id: i + 1,
    ...classify(entry, scriptaLines, latexLines, userMacros),
  }));

  // Aggregate categories
  const categories = {};
  for (const d of diagnosed) {
    categories[d.category] = (categories[d.category] || 0) + 1;
  }

  // Build summary string
  const sorted = Object.entries(categories).sort((a, b) => b[1] - a[1]);
  const topStr = sorted.map(([cat, n]) => `${cat} (${n})`).join(", ");
  const summary = `${diagnosed.length} errors across ${sorted.length} categories. Breakdown: ${topStr}`;

  const report = {
    file: basename,
    totalErrors: diagnosed.length,
    categories,
    errors: diagnosed,
    summary,
  };

  fs.writeFileSync(outputPath, JSON.stringify(report, null, 2));
  console.log(`${basename}: ${diagnosed.length} errors diagnosed. Wrote: ${outputPath}`);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function usage() {
  console.error("Usage:");
  console.error("  node diagnose.js <basename>     Diagnose a single file");
  console.error("  node diagnose.js --summary      Print summary of all diagnoses");
  console.error("  node diagnose.js --all           Diagnose all error files");
  process.exit(1);
}

const args = process.argv.slice(2);
if (args.length < 1) usage();

if (args[0] === "--summary") {
  runSummary();
} else if (args[0] === "--all") {
  const errorFiles = fs
    .readdirSync(DOCS_DIR)
    .filter((f) => f.endsWith("-errors.json"));
  for (const f of errorFiles.sort()) {
    const base = f.replace(/-errors\.json$/, "");
    if (fs.existsSync(path.join(DOCS_DIR, base + ".scripta"))) {
      runDiagnosis(base);
    }
  }
} else {
  runDiagnosis(args[0]);
}
