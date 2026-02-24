#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const DOCS_DIR = path.join(__dirname, "..", "..", "tests", "toLaTeXExportTestDocs");

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
    test: (latexText) => /[_^]/.test(latexText) && !latexText.includes("\\lstinline") && !latexText.includes("$"),
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
    test: (latexText) => {
      // Catch unknown commands that aren't standard LaTeX
      const unknowns = latexText.match(/\\[a-zA-Z]+/g) || [];
      const known = new Set([
        "\\textbf", "\\textit", "\\emph", "\\lstinline", "\\item",
        "\\bibitem", "\\index", "\\label", "\\ref", "\\eqref",
        "\\section", "\\subsection", "\\subsubsection", "\\chapter",
        "\\begin", "\\end", "\\href", "\\url", "\\cite",
        "\\includegraphics", "\\centering", "\\caption",
        "\\footnote", "\\par", "\\newline", "\\\\",
        "\\errorHighlight", // handled by parse-error-passthrough rule
      ]);
      const found = [...new Set(unknowns.filter((cmd) => !known.has(cmd)))];
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

function classify(errorEntry, scriptaLines, latexLines) {
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
    const result = rule.test(latexText);
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
  const texPath = path.join(DOCS_DIR, basename + ".tex");
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

  // Classify each error
  const diagnosed = errorsRaw.map((entry, i) => ({
    id: i + 1,
    ...classify(entry, scriptaLines, latexLines),
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
