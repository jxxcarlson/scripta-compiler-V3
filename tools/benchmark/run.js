#!/usr/bin/env node

/**
 * Benchmark driver for Scripta parse pipeline.
 *
 * Sends commands to the Elm worker via ports and measures round-trip time.
 * Outputs JSON results and a human-readable table.
 *
 * Usage:
 *   node run.js                   # run all test documents
 *   node run.js --iterations 50   # custom iteration count
 */

const fs = require("fs");
const path = require("path");
const { performance } = require("perf_hooks");

const DOCS_DIR = path.join(__dirname, "..", "..", "tests", "toLaTeXExportTestDocs");
const ITERATIONS = parseInt(process.argv.find((_, i, a) => a[i - 1] === "--iterations") || "100", 10);

const TEST_DOCS = [
  { label: "small",  file: "index-test.scripta" },
  { label: "medium", file: "welcome.scripta" },
  { label: "large",  file: "mltt.scripta" },
  { label: "xlarge", file: "mlttv1.scripta" },
];

function loadDocument(filename) {
  const filepath = path.join(DOCS_DIR, filename);
  if (!fs.existsSync(filepath)) {
    console.error("Document not found:", filepath);
    return null;
  }
  return fs.readFileSync(filepath, "utf-8");
}

function stats(times) {
  const sorted = [...times].sort((a, b) => a - b);
  const sum = sorted.reduce((a, b) => a + b, 0);
  return {
    mean: sum / sorted.length,
    median: sorted[Math.floor(sorted.length / 2)],
    min: sorted[0],
    max: sorted[sorted.length - 1],
    p95: sorted[Math.floor(sorted.length * 0.95)],
    count: sorted.length,
  };
}

function sendCommand(app, command, sourceText) {
  return new Promise((resolve) => {
    const handler = (result) => {
      app.ports.sendResult.unsubscribe(handler);
      resolve(result);
    };
    app.ports.sendResult.subscribe(handler);
    app.ports.receiveCommand.send({ command, sourceText });
  });
}

async function benchmarkOperation(app, command, sourceText, iterations) {
  const times = [];
  for (let i = 0; i < iterations; i++) {
    const start = performance.now();
    await sendCommand(app, command, sourceText);
    const end = performance.now();
    times.push(end - start);
  }
  return stats(times);
}

function editDocument(sourceText, lineNumber) {
  const lines = sourceText.split("\n");
  if (lineNumber < lines.length) {
    lines[lineNumber] = lines[lineNumber] + " [edited]";
  }
  return lines.join("\n");
}

function formatMs(ms) {
  return ms.toFixed(2).padStart(8);
}

function printTable(results) {
  const header = [
    "Document".padEnd(10),
    "Lines".padStart(6),
    "Operation".padEnd(20),
    "Mean(ms)".padStart(10),
    "Median".padStart(10),
    "Min".padStart(10),
    "Max".padStart(10),
    "P95".padStart(10),
  ].join(" | ");

  const sep = "-".repeat(header.length);

  console.log("\n" + sep);
  console.log(header);
  console.log(sep);

  for (const r of results) {
    const row = [
      r.label.padEnd(10),
      String(r.lines).padStart(6),
      r.operation.padEnd(20),
      formatMs(r.stats.mean),
      formatMs(r.stats.median),
      formatMs(r.stats.min),
      formatMs(r.stats.max),
      formatMs(r.stats.p95),
    ].join(" | ");
    console.log(row);
  }

  console.log(sep);
}

async function main() {
  // Load the compiled Elm worker
  const workerPath = path.join(__dirname, "worker.js");
  if (!fs.existsSync(workerPath)) {
    console.error("worker.js not found. Run `make build` first.");
    process.exit(1);
  }

  const { Elm } = require(workerPath);

  // Detect which worker we have based on the module name
  const workerModule = Elm.WorkerMain || Elm.WorkerOptimize;
  if (!workerModule) {
    console.error("Could not find WorkerMain or WorkerOptimize module in worker.js");
    process.exit(1);
  }

  const isOptimize = !!Elm.WorkerOptimize;
  const branchName = isOptimize ? "optimize" : "main";

  console.log(`Benchmark: branch=${branchName}, iterations=${ITERATIONS}`);
  console.log(`Documents dir: ${DOCS_DIR}`);

  const app = workerModule.init();
  const results = [];

  for (const doc of TEST_DOCS) {
    const sourceText = loadDocument(doc.file);
    if (!sourceText) {
      console.warn(`Skipping ${doc.file}: not found`);
      continue;
    }

    const lines = sourceText.split("\n").length;
    console.log(`\nBenchmarking ${doc.label} (${doc.file}, ${lines} lines)...`);

    // 1. Full parse
    console.log(`  fullParse x ${ITERATIONS}...`);
    const fullStats = await benchmarkOperation(app, "fullParse", sourceText, ITERATIONS);
    results.push({ label: doc.label, file: doc.file, lines, operation: "fullParse", stats: fullStats });

    // 2. Incremental parse (optimize branch only)
    if (isOptimize) {
      // Seed the cache first
      console.log("  seedCache...");
      await sendCommand(app, "seedCache", sourceText);

      // Incremental parse with warm cache (same document)
      console.log(`  incrementalParse x ${ITERATIONS}...`);
      const incrStats = await benchmarkOperation(app, "incrementalParse", sourceText, ITERATIONS);
      results.push({ label: doc.label, file: doc.file, lines, operation: "incrementalParse", stats: incrStats });

      // 3. Cached forest: return stored forest without re-parsing
      // Measures the "skip parse on click/non-edit interaction" optimization
      console.log(`  cachedForest x ${ITERATIONS}...`);
      const cachedStats = await benchmarkOperation(app, "cachedForest", sourceText, ITERATIONS);
      results.push({ label: doc.label, file: doc.file, lines, operation: "cachedForest", stats: cachedStats });

      // 4. Edit simulation: modify line 10, seed, then incremental parse
      const edited = editDocument(sourceText, 10);
      console.log("  seedCache (edited)...");
      await sendCommand(app, "seedCache", sourceText); // seed with original
      console.log(`  incrementalParse (edited) x ${ITERATIONS}...`);
      const editStats = await benchmarkOperation(app, "incrementalParse", edited, ITERATIONS);
      results.push({ label: doc.label, file: doc.file, lines, operation: "incrParse-edited", stats: editStats });
    }
  }

  // Print human-readable table
  printTable(results);

  // Output JSON
  const output = {
    branch: branchName,
    iterations: ITERATIONS,
    timestamp: new Date().toISOString(),
    results,
  };

  const jsonPath = path.join(__dirname, `results-${branchName}.json`);
  fs.writeFileSync(jsonPath, JSON.stringify(output, null, 2));
  console.log(`\nJSON results written to: ${jsonPath}`);

  // Also write to stdout-friendly format
  console.log("\n--- JSON ---");
  console.log(JSON.stringify(output));

  process.exit(0);
}

main().catch((err) => {
  console.error("Benchmark failed:", err);
  process.exit(1);
});
