#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command node

node --input-type=module - "$ROOT" <<'EOF'
import assert from "node:assert/strict";
import * as fs from "node:fs";
import * as http from "node:http";
import { registerHooks } from "node:module";
import * as path from "node:path";
import { pathToFileURL } from "node:url";

const root = process.argv[2];
const piDir = path.join(root, "default/agents/pi");
const mod = await import(pathToFileURL(path.join(piDir, "lib/web-search.ts")).href);
const { BYOK_HINT, buildSearxngUrl, parseMcpResponse, runSearch, sanitizeError } = mod;

// 1. SSE and JSON MCP parsing
const sse = [
  "event: message",
  'data: {"jsonrpc":"2.0","id":1,"result":{"content":[{"type":"text","text":"Title: A\\nURL: https://a.example"}]}}',
  "",
].join("\n");
assert.equal(parseMcpResponse(sse, "text/event-stream").result.content[0].text, "Title: A\nURL: https://a.example");
assert.equal(parseMcpResponse('{"ok":true}', "application/json").ok, true);
assert.throws(() => parseMcpResponse("", "application/json"), /empty response/i);
console.log("ok - parseMcpResponse handles SSE, JSON, and empty responses");

// 2. SearXNG URL validation and subpath preservation
const searxUrl = buildSearxngUrl("https://search.example/searxng", "omarchy linux");
assert.equal(searxUrl.href, "https://search.example/searxng/search?q=omarchy+linux&format=json");
assert.throws(() => buildSearxngUrl("file:///etc/passwd", "x"), /http or https/i);
assert.throws(() => buildSearxngUrl("not a url", "x"), /not a valid URL/i);
console.log("ok - buildSearxngUrl preserves subpaths and rejects non-http(s) URLs");

// 3. Secret redaction
const secret = "exa_secret+key/123";
assert.equal(
  sanitizeError(`failed for ${secret} and ${encodeURIComponent(secret)}`, [secret]),
  "failed for [REDACTED] and [REDACTED]",
);
console.log("ok - sanitizeError redacts raw and URL-encoded API keys");

// 4. Live HTTP tests against a local mock server for every backend and the Pi extension
let lastRequest = null;
const server = http.createServer((req, res) => {
  const chunks = [];
  req.on("data", (c) => chunks.push(c));
  req.on("end", () => {
    const body = Buffer.concat(chunks).toString("utf8");
    lastRequest = { method: req.method, url: req.url, headers: req.headers, body };

    if (req.url.startsWith("/exa-sse")) {
      res.writeHead(200, { "Content-Type": "text/event-stream" });
      const payload = {
        jsonrpc: "2.0",
        id: 1,
        result: {
          content: [
            {
              type: "text",
              text: "Title: One\nURL: https://one.example\n\nTitle: Two\nURL: https://two.example",
            },
          ],
        },
      };
      res.end(`event: message\ndata: ${JSON.stringify(payload)}\n\n`);
      return;
    }

    if (req.url.startsWith("/exa-ratelimit")) {
      res.writeHead(429, { "Content-Type": "text/plain" });
      res.end("You've hit Exa's free MCP rate limit.");
      return;
    }

    if (req.url.startsWith("/exa-key-error")) {
      res.writeHead(500, { "Content-Type": "text/plain" });
      res.end(`backend error for ${req.url}`);
      return;
    }

    if (req.url.startsWith("/sub/search?")) {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(
        JSON.stringify({
          results: [
            { title: "First", url: "https://first.example", content: "Hello", publishedDate: "2026-11-26" },
            { title: "Second", url: "https://second.example", content: "World" },
          ],
        }),
      );
      return;
    }

    if (req.url.startsWith("/huge/search?")) {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(
        JSON.stringify({
          results: Array.from({ length: 10 }, (_, i) => ({
            title: `Entry ${i + 1}`,
            url: `https://example.test/${i + 1}`,
            content: `line ${i + 1}\n`.repeat(5),
          })),
        }),
      );
      return;
    }

    if (req.url === "/tavily") {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(
        JSON.stringify({
          results: [{ title: "Tavily Hit", url: "https://tavily.example", content: "Snippet" }],
        }),
      );
      return;
    }

    if (req.url.startsWith("/brave?")) {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(
        JSON.stringify({
          web: { results: [{ title: "Brave Hit", url: "https://brave.example", description: "Desc", age: "2 days ago" }] },
        }),
      );
      return;
    }

    res.writeHead(404);
    res.end("not found");
  });
});

await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
const { port } = server.address();
const base = `http://127.0.0.1:${port}`;

const savedDirs = [];
try {
  // Default keyless Exa MCP over SSE
  const exaFree = await runSearch({
    query: "omarchy linux",
    numResults: 5,
    signal: AbortSignal.timeout(5000),
    env: {},
    endpoints: { exa: `${base}/exa-sse` },
  });
  assert.equal(exaFree.backend, "exa-free");
  assert.equal(exaFree.resultCount, 2);
  const rpc = JSON.parse(lastRequest.body);
  assert.equal(rpc.params.name, "web_search_exa");
  assert.equal(rpc.params.arguments.query, "omarchy linux");
  assert.equal(rpc.params.arguments.objective, "omarchy linux");
  assert.equal(rpc.params.arguments.numResults, 5);
  console.log("ok - default backend queries Exa MCP keyless and parses SSE results");

  // Exa free rate limit includes BYOK hint
  await assert.rejects(
    () =>
      runSearch({
        query: "omarchy",
        signal: AbortSignal.timeout(5000),
        env: {},
        endpoints: { exa: `${base}/exa-ratelimit` },
      }),
    (err) => err.message.includes("rate limit") && err.message.includes(BYOK_HINT),
  );
  console.log("ok - keyless Exa rate limit surfaces BYOK hint");

  // Exa with EXA_API_KEY passes exaApiKey and redacts it on errors
  const exaKey = "super-secret-exa-key";
  const exaPaid = await runSearch({
    query: "omarchy",
    signal: AbortSignal.timeout(5000),
    env: { EXA_API_KEY: exaKey },
    endpoints: { exa: `${base}/exa-sse` },
  });
  assert.equal(exaPaid.backend, "exa");
  assert.ok(lastRequest.url.includes(`exaApiKey=${exaKey}`));
  await assert.rejects(
    () =>
      runSearch({
        query: "omarchy",
        signal: AbortSignal.timeout(5000),
        env: { EXA_API_KEY: exaKey },
        endpoints: { exa: `${base}/exa-key-error` },
      }),
    (err) => !err.message.includes(exaKey) && err.message.includes("[REDACTED]"),
  );
  console.log("ok - EXA_API_KEY authenticates Exa MCP and is redacted from errors");

  // SearXNG takes top priority and preserves subpaths
  const searx = await runSearch({
    query: "arch",
    numResults: 1,
    signal: AbortSignal.timeout(5000),
    env: { SEARXNG_URL: `${base}/sub`, TAVILY_API_KEY: "t", BRAVE_API_KEY: "b", EXA_API_KEY: "e" },
  });
  assert.equal(searx.backend, "searxng");
  assert.equal(searx.resultCount, 1);
  assert.match(searx.text, /1\. First\nURL: https:\/\/first\.example/);
  console.log("ok - SEARXNG_URL takes priority, preserves subpaths, and respects numResults");

  // Tavily backend
  const tavily = await runSearch({
    query: "arch",
    signal: AbortSignal.timeout(5000),
    env: { TAVILY_API_KEY: "tvly-key", BRAVE_API_KEY: "b", EXA_API_KEY: "e" },
    endpoints: { tavily: `${base}/tavily` },
  });
  assert.equal(tavily.backend, "tavily");
  assert.equal(tavily.resultCount, 1);
  assert.equal(JSON.parse(lastRequest.body).api_key, "tvly-key");
  console.log("ok - TAVILY_API_KEY routes to Tavily Search");

  // Brave backend
  const brave = await runSearch({
    query: "arch",
    signal: AbortSignal.timeout(5000),
    env: { BRAVE_API_KEY: "brave-key", EXA_API_KEY: "e" },
    endpoints: { brave: `${base}/brave` },
  });
  assert.equal(brave.backend, "brave");
  assert.equal(brave.resultCount, 1);
  assert.equal(lastRequest.headers["x-subscription-token"], "brave-key");
  console.log("ok - BRAVE_API_KEY routes to Brave Search");

  // Empty query rejected
  await assert.rejects(
    () => runSearch({ query: "   ", signal: AbortSignal.timeout(5000), env: {} }),
    /must not be empty/i,
  );
  console.log("ok - empty queries are rejected");

  // 5. Load and execute the extension entry declared in package.json with Pi module stubs
  const virtualModules = {
    "@earendil-works/pi-coding-agent": `
      export const DEFAULT_MAX_LINES = 5;
      export const DEFAULT_MAX_BYTES = 200;
      export const formatSize = (n) => n + " B";
      export function truncateHead(text, { maxLines, maxBytes }) {
        const lines = text.split("\\n");
        const sliced = lines.slice(0, maxLines).join("\\n").slice(0, maxBytes);
        const truncated = sliced.length < text.length;
        return {
          content: sliced,
          truncated,
          outputLines: sliced.split("\\n").length,
          totalLines: lines.length,
          outputBytes: Buffer.byteLength(sliced, "utf8"),
          totalBytes: Buffer.byteLength(text, "utf8"),
        };
      }
    `,
    "@earendil-works/pi-tui": `
      export class Text {
        constructor(text) { this.text = text; }
      }
    `,
    typebox: `
      export const Type = {
        Object: (props) => ({ type: "object", properties: props }),
        String: (opts) => ({ type: "string", ...opts }),
        Number: (opts) => ({ type: "number", ...opts }),
        Optional: (inner) => ({ optional: true, ...inner }),
      };
    `,
  };
  registerHooks({
    resolve(specifier, context, nextResolve) {
      if (Object.hasOwn(virtualModules, specifier)) {
        return { url: `pi-stub:${specifier}`, shortCircuit: true };
      }
      return nextResolve(specifier, context);
    },
    load(url, context, nextLoad) {
      if (url.startsWith("pi-stub:")) {
        return { format: "module", source: virtualModules[url.slice("pi-stub:".length)], shortCircuit: true };
      }
      return nextLoad(url, context);
    },
  });

  const pkg = JSON.parse(fs.readFileSync(path.join(piDir, "package.json"), "utf8"));
  const tools = new Map();
  const fakePi = {
    registerTool(def) {
      tools.set(def.name, def);
    },
  };
  for (const rel of pkg.pi.extensions) {
    if (!rel.endsWith("web-search.ts")) continue;
    const ext = await import(pathToFileURL(path.resolve(piDir, rel)).href);
    ext.default(fakePi);
  }
  const tool = tools.get("web_search");
  assert.ok(tool, "package.json extensions register the web_search tool");

  const theme = { fg: (_c, s) => s, bold: (s) => s };
  assert.match(tool.renderCall({ query: "omarchy", num_results: 3 }, theme).text, /web_search omarchy \(3\)/);

  const prevSearx = process.env.SEARXNG_URL;
  try {
    process.env.SEARXNG_URL = `${base}/sub`;
    const okResult = await tool.execute("id-1", { query: "omarchy", num_results: 2 });
    assert.ok(!okResult.isError);
    assert.equal(okResult.details.backend, "searxng");
    assert.equal(okResult.details.resultCount, 2);
    assert.match(okResult.content[0].text, /Query: omarchy\nBackend: searxng/);
    assert.match(tool.renderResult(okResult, { expanded: false }, theme).text, /searxng · 2 results/);

    const emptyResult = await tool.execute("id-2", { query: "   " });
    assert.equal(emptyResult.isError, true);
    assert.match(tool.renderResult(emptyResult, { expanded: false }, theme).text, /Error:/);

    process.env.SEARXNG_URL = `${base}/huge`;
    const truncResult = await tool.execute("id-3", { query: "huge", num_results: 10 });
    assert.equal(truncResult.details.truncated, true);
    assert.ok(truncResult.details.savedTo && fs.existsSync(truncResult.details.savedTo));
    savedDirs.push(path.dirname(truncResult.details.savedTo));
    assert.equal(fs.statSync(truncResult.details.savedTo).mode & 0o777, 0o600);
    assert.match(truncResult.content[0].text, /Full results saved to:/);
  } finally {
    if (prevSearx === undefined) delete process.env.SEARXNG_URL;
    else process.env.SEARXNG_URL = prevSearx;
  }
  console.log("ok - web-search extension loads via package.json, executes searches, truncates overflow, and renders output");
} finally {
  server.close();
  for (const dir of savedDirs) fs.rmSync(dir, { recursive: true, force: true });
}
EOF
