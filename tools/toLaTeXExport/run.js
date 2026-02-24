#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const http = require("http");

const PDF_SERVER = "http://localhost:3000";
const OUTPUT_DIR = path.join(__dirname, "..", "..", "tests", "toLaTeXExportTestDocs");

function usage() {
  console.error("Usage: node run.js <path-to-scripta-file>");
  process.exit(1);
}

function httpRequest(url, options, body) {
  return new Promise((resolve, reject) => {
    const parsedUrl = new URL(url);
    const reqOptions = {
      hostname: parsedUrl.hostname,
      port: parsedUrl.port,
      path: parsedUrl.pathname,
      ...options,
    };
    const req = http.request(reqOptions, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => resolve({ status: res.statusCode, body: data }));
    });
    req.on("error", reject);
    if (body) req.write(body);
    req.end();
  });
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length < 1) usage();

  const scriptaPath = args[0];
  if (!fs.existsSync(scriptaPath)) {
    console.error("File not found:", scriptaPath);
    process.exit(1);
  }

  const sourceText = fs.readFileSync(scriptaPath, "utf-8");
  const basename = path.basename(scriptaPath, path.extname(scriptaPath));
  const texFilename = basename + ".tex";

  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  // Boot the Elm worker
  const { Elm } = require("./worker.js");
  const app = Elm.Worker.init();

  app.ports.sendLaTeX.subscribe(async (latex) => {
    console.log("Got LaTeX output (" + latex.length + " chars)");

    // Write the LaTeX file for debugging
    const texPath = path.join(OUTPUT_DIR, texFilename);
    fs.writeFileSync(texPath, latex);
    console.log("Wrote:", texPath);

    // POST to the PDF server
    const payload = JSON.stringify({
      id: texFilename,
      content: latex,
      urlList: [],
      packageList: [],
    });

    try {
      const res = await httpRequest(PDF_SERVER + "/tex", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(payload),
        },
      }, payload);

      console.log("PDF server responded:", res.status);
      const result = JSON.parse(res.body);

      // Write the server's final LaTeX (after PDF pipeline) as FILE-2.tex
      if (result.tex) {
        const tex2Path = path.join(OUTPUT_DIR, basename + "-2.tex");
        fs.writeFileSync(tex2Path, result.tex);
        console.log("Wrote pipeline LaTeX:", tex2Path);
      }

      const errorsPath = path.join(OUTPUT_DIR, basename + "-errors.json");

      if (result.hasErrors) {
        // Error data is in the response itself under errorJson
        fs.writeFileSync(errorsPath, JSON.stringify(result.errorJson, null, 2));
        console.log("Errors (" + result.errorJson.length + ") written to:", errorsPath);
      } else {
        fs.writeFileSync(errorsPath, JSON.stringify({ hasErrors: false }, null, 2));
        console.log("No errors. Wrote:", errorsPath);
      }
    } catch (err) {
      console.error("Error communicating with PDF server:", err.message);
      console.error("Is the PDF server running at " + PDF_SERVER + "?");
      process.exit(1);
    }

    process.exit(0);
  });

  // Send source text to Elm
  app.ports.receiveSourceText.send(sourceText);
}

main();
