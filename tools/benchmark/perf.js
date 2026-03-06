/**
 * Browser render benchmark for Scripta Demo app.
 *
 * Load this script in the Demo's index.html:
 *   <script src="tools/benchmark/perf.js"></script>
 *
 * Or paste into browser console. Displays a floating overlay with live metrics.
 */

(function () {
  "use strict";

  // --- Configuration ---
  const KEYSTROKE_SAMPLES = 50;
  const CLICK_SAMPLES = 20;

  // --- State ---
  const metrics = {
    keystroke: [],
    click: [],
    idle: [],
  };

  // --- Overlay UI ---
  function createOverlay() {
    const overlay = document.createElement("div");
    overlay.id = "perf-overlay";
    overlay.style.cssText = [
      "position: fixed",
      "top: 10px",
      "right: 10px",
      "z-index: 99999",
      "background: rgba(0,0,0,0.85)",
      "color: #0f0",
      "font-family: monospace",
      "font-size: 12px",
      "padding: 12px",
      "border-radius: 6px",
      "max-width: 350px",
      "pointer-events: auto",
      "cursor: move",
    ].join(";");
    overlay.innerHTML = `
      <div style="font-weight:bold;margin-bottom:6px;color:#ff0">Scripta Perf</div>
      <div id="perf-keystroke">Keystroke: waiting...</div>
      <div id="perf-click">Click: waiting...</div>
      <div id="perf-idle">Idle: waiting...</div>
      <div style="margin-top:8px;font-size:10px;color:#888">
        <button id="perf-run-click" style="font-size:10px;cursor:pointer">Run click test</button>
        <button id="perf-run-idle" style="font-size:10px;cursor:pointer">Run idle test</button>
        <button id="perf-dump" style="font-size:10px;cursor:pointer">Dump to console</button>
      </div>
    `;
    document.body.appendChild(overlay);
    return overlay;
  }

  function stats(arr) {
    if (arr.length === 0) return null;
    const sorted = [...arr].sort((a, b) => a - b);
    const sum = sorted.reduce((a, b) => a + b, 0);
    return {
      mean: sum / sorted.length,
      median: sorted[Math.floor(sorted.length / 2)],
      p95: sorted[Math.floor(sorted.length * 0.95)],
      min: sorted[0],
      max: sorted[sorted.length - 1],
      count: sorted.length,
    };
  }

  function formatStats(s) {
    if (!s) return "no data";
    return `mean=${s.mean.toFixed(1)}ms med=${s.median.toFixed(1)}ms p95=${s.p95.toFixed(1)}ms (n=${s.count})`;
  }

  function updateDisplay() {
    const ks = document.getElementById("perf-keystroke");
    const cl = document.getElementById("perf-click");
    const id = document.getElementById("perf-idle");
    if (ks) ks.textContent = "Keystroke: " + formatStats(stats(metrics.keystroke));
    if (cl) cl.textContent = "Click: " + formatStats(stats(metrics.click));
    if (id) id.textContent = "Idle: " + formatStats(stats(metrics.idle));
  }

  // --- Measurement: Keystroke-to-render latency ---
  function hookKeystroke() {
    // Find the editor textarea/contenteditable
    const editor = document.querySelector("textarea, [contenteditable=true], .CodeMirror");
    if (!editor) {
      console.warn("[perf] No editor element found. Keystroke measurement disabled.");
      return;
    }

    let pending = null;

    // Listen for input events on the editor
    const target = editor.closest(".CodeMirror") ? editor.closest(".CodeMirror") : editor;
    target.addEventListener(
      "input",
      function () {
        pending = performance.now();
        requestAnimationFrame(function () {
          if (pending !== null) {
            const delta = performance.now() - pending;
            metrics.keystroke.push(delta);
            // Keep only the most recent samples
            if (metrics.keystroke.length > KEYSTROKE_SAMPLES * 2) {
              metrics.keystroke = metrics.keystroke.slice(-KEYSTROKE_SAMPLES);
            }
            pending = null;
            updateDisplay();
          }
        });
      },
      { passive: true }
    );

    // Also listen on the preview pane for MutationObserver-based measurement
    const preview = document.querySelector(".rendered-text, .preview, [id*=preview]");
    if (preview) {
      const observer = new MutationObserver(function () {
        // DOM updated - the rAF callback above will capture the timing
      });
      observer.observe(preview, { childList: true, subtree: true, characterData: true });
    }

    console.log("[perf] Keystroke measurement hooked on:", target.tagName || target.className);
  }

  // --- Measurement: Click-to-render latency ---
  function runClickTest() {
    const blocks = document.querySelectorAll(".expression-block, .rendered-block, [id^='block-']");
    if (blocks.length === 0) {
      console.warn("[perf] No rendered blocks found for click test.");
      return;
    }

    let index = 0;

    function clickNext() {
      if (index >= Math.min(blocks.length, CLICK_SAMPLES)) {
        console.log("[perf] Click test complete:", formatStats(stats(metrics.click)));
        updateDisplay();
        return;
      }

      const block = blocks[index % blocks.length];
      const start = performance.now();

      block.click();

      requestAnimationFrame(function () {
        const delta = performance.now() - start;
        metrics.click.push(delta);
        updateDisplay();
        index++;
        // Small delay between clicks to let things settle
        setTimeout(clickNext, 100);
      });
    }

    clickNext();
  }

  // --- Measurement: Idle re-render cost ---
  function runIdleTest(iterations) {
    iterations = iterations || 20;
    let count = 0;

    function measure() {
      if (count >= iterations) {
        console.log("[perf] Idle test complete:", formatStats(stats(metrics.idle)));
        updateDisplay();
        return;
      }

      const start = performance.now();
      requestAnimationFrame(function () {
        const delta = performance.now() - start;
        metrics.idle.push(delta);
        updateDisplay();
        count++;
        // Next tick
        setTimeout(measure, 50);
      });
    }

    measure();
  }

  // --- Initialize ---
  function init() {
    console.log("[perf] Scripta Performance Monitor loaded");

    createOverlay();
    hookKeystroke();

    // Wire up buttons
    const clickBtn = document.getElementById("perf-run-click");
    const idleBtn = document.getElementById("perf-run-idle");
    const dumpBtn = document.getElementById("perf-dump");

    if (clickBtn) clickBtn.addEventListener("click", runClickTest);
    if (idleBtn) idleBtn.addEventListener("click", function () { runIdleTest(20); });
    if (dumpBtn) {
      dumpBtn.addEventListener("click", function () {
        console.log("[perf] Full metrics dump:");
        console.log(JSON.stringify({
          keystroke: stats(metrics.keystroke),
          click: stats(metrics.click),
          idle: stats(metrics.idle),
          raw: metrics,
        }, null, 2));
      });
    }
  }

  // Wait for DOM
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
