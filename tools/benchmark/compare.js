#!/usr/bin/env node

/**
 * Compare benchmark results from two branches.
 *
 * Usage:
 *   node compare.js results-main.json results-optimize.json
 */

const fs = require("fs");
const path = require("path");

function usage() {
  console.error("Usage: node compare.js <results-main.json> <results-optimize.json>");
  process.exit(1);
}

function loadResults(filepath) {
  if (!fs.existsSync(filepath)) {
    console.error("File not found:", filepath);
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(filepath, "utf-8"));
}

function formatMs(ms) {
  if (ms === null || ms === undefined) return "       —";
  return ms.toFixed(2).padStart(8);
}

function formatSpeedup(mainMs, optMs) {
  if (mainMs === null || optMs === null) return "       —";
  if (optMs === 0) return "     inf";
  const ratio = mainMs / optMs;
  return (ratio.toFixed(2) + "x").padStart(8);
}

function main() {
  const args = process.argv.slice(2);
  if (args.length < 2) usage();

  const mainData = loadResults(args[0]);
  const optData = loadResults(args[1]);

  console.log(`\nComparison: ${mainData.branch} vs ${optData.branch}`);
  console.log(`Main: ${mainData.iterations} iterations, ${mainData.timestamp}`);
  console.log(`Optimize: ${optData.iterations} iterations, ${optData.timestamp}`);

  // Build lookup maps: label -> operation -> stats
  function buildMap(data) {
    const map = {};
    for (const r of data.results) {
      if (!map[r.label]) map[r.label] = {};
      map[r.label][r.operation] = r;
    }
    return map;
  }

  const mainMap = buildMap(mainData);
  const optMap = buildMap(optData);

  // Collect all document labels and operations
  const labels = [...new Set([...mainData.results, ...optData.results].map((r) => r.label))];
  const operations = [...new Set([...mainData.results, ...optData.results].map((r) => r.operation))];

  // Print comparison table
  const header = [
    "Document".padEnd(10),
    "Operation".padEnd(20),
    "main(ms)".padStart(10),
    "opt(ms)".padStart(10),
    "Speedup".padStart(10),
    "Notes".padEnd(30),
  ].join(" | ");

  const sep = "=".repeat(header.length);

  console.log("\n" + sep);
  console.log(header);
  console.log(sep);

  for (const label of labels) {
    for (const op of operations) {
      const mainR = mainMap[label] && mainMap[label][op];
      const optR = optMap[label] && optMap[label][op];

      if (!mainR && !optR) continue;

      const mainMean = mainR ? mainR.stats.mean : null;
      const optMean = optR ? optR.stats.mean : null;

      let notes = "";
      if (op === "incrementalParse" || op === "incrParse-edited") {
        // Compare incremental vs full parse on optimize branch
        const optFull = optMap[label] && optMap[label]["fullParse"];
        if (optFull && optMean !== null) {
          const vsFullRatio = optFull.stats.mean / optMean;
          notes = `${vsFullRatio.toFixed(2)}x vs opt fullParse`;
        }
        if (!mainR) {
          notes += (notes ? "; " : "") + "optimize-only";
        }
      }

      const row = [
        label.padEnd(10),
        op.padEnd(20),
        formatMs(mainMean),
        formatMs(optMean),
        mainMean !== null && optMean !== null ? formatSpeedup(mainMean, optMean) : "       —",
        notes.padEnd(30),
      ].join(" | ");

      console.log(row);
    }
    console.log("-".repeat(sep.length));
  }

  console.log(sep);

  // Summary
  console.log("\nSummary:");
  for (const label of labels) {
    const mainFull = mainMap[label] && mainMap[label]["fullParse"];
    const optFull = optMap[label] && optMap[label]["fullParse"];
    const optIncr = optMap[label] && optMap[label]["incrementalParse"];

    if (mainFull && optFull) {
      const fullSpeedup = mainFull.stats.mean / optFull.stats.mean;
      console.log(`  ${label}: fullParse ${fullSpeedup.toFixed(2)}x (main ${mainFull.stats.mean.toFixed(1)}ms -> opt ${optFull.stats.mean.toFixed(1)}ms)`);
    }
    if (optFull && optIncr) {
      const incrSpeedup = optFull.stats.mean / optIncr.stats.mean;
      console.log(`  ${label}: incrementalParse ${incrSpeedup.toFixed(2)}x faster than fullParse on optimize`);
    }
  }
}

main();
