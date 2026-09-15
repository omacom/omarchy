// Keep the upstream MCP tools and parsing, but emit offline HTML artifacts.
import fs from "node:fs/promises";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath, pathToFileURL } from "node:url";
import { randomUUID } from "node:crypto";
import { markmapDocument } from "./markmap-document.mjs";

const configPath = fileURLToPath(import.meta.url).replace(/\.mjs$/, ".json");
const { backend } = JSON.parse(await fs.readFile(configPath, "utf8"));
const require = createRequire(backend);
// The backend imports the ESM SDK. require.resolve selects its separate CJS
// build, whose Server prototype and schema identities cannot intercept it.
const packageRoot = path.dirname(path.dirname(backend));
const sdkRoot = path.join(packageRoot, "node_modules/@modelcontextprotocol/sdk/dist/esm");
const { Server } = await import(pathToFileURL(path.join(sdkRoot, "server/index.js")));
const types = await import(pathToFileURL(path.join(sdkRoot, "types.js")));
const { JSDOM } = require("jsdom");
const { MarkmapHandler } = await import(pathToFileURL(path.join(path.dirname(backend), "lib/markmap-handler.js")));
const d3 = await fs.readFile(path.join(packageRoot, "node_modules/d3/dist/d3.min.js"), "utf8");
const markmap = await fs.readFile(path.join(packageRoot, "node_modules/markmap-view/dist/browser/index.js"), "utf8");

// Network-sourced labels must not turn into active HTML or remote resources.
const allowedTags = new Set(["STRONG", "EM", "CODE", "B", "I", "BR", "SPAN"]);
function cleanLabels(node) {
  const fragment = JSDOM.fragment(node.content || "");
  for (const element of [...fragment.querySelectorAll("*")].reverse()) {
    if (!allowedTags.has(element.tagName)) {
      element.replaceWith(...element.childNodes);
    } else {
      for (const attribute of [...element.attributes]) element.removeAttribute(attribute.name);
    }
  }
  const container = fragment.ownerDocument.createElement("div");
  container.append(fragment);
  node.content = container.innerHTML;
  for (const child of node.children || []) cleanLabels(child);
  return node;
}

MarkmapHandler.prototype.renderToSVG = async function(content, options) {
  const { root } = this.parseMarkdown(content);
  return markmapDocument(cleanLabels(root), options, d3, markmap);
};

const renderingTools = new Set(["markmap_generate", "markmap_from_outline", "markmap_render_file", "markmap_customize"]);
const originalSetHandler = Server.prototype.setRequestHandler;
Server.prototype.setRequestHandler = function(schema, handler) {
  if (schema === types.ListToolsRequestSchema) {
    const upstream = handler;
    handler = async (...args) => {
      const result = await upstream(...args);
      for (const tool of result.tools) {
        if (!renderingTools.has(tool.name)) continue;
        tool.description = tool.description.replaceAll("SVG", "HTML") + " Returns an offline HTML artifact path; open it in a browser. No HTML blob is returned to the model.";
        tool.inputSchema.properties.output_path = { type: "string", description: "Optional .html output path within the workspace" };
      }
      return result;
    };
  } else if (schema === types.CallToolRequestSchema) {
    const upstream = handler;
    handler = async (request, extra) => {
      const { name, arguments: args = {} } = request.params;
      if (!renderingTools.has(name)) return upstream(request, extra);
      const destination = path.resolve(args.output_path || path.join("showcase", `markmap-${randomUUID()}.html`));
      const relative = path.relative(process.cwd(), destination);
      if (relative.startsWith("..") || path.isAbsolute(relative) || !destination.endsWith(".html")) {
        return { isError: true, content: [{ type: "text", text: "Use an .html output path inside the current workspace." }] };
      }
      // Save here after rendering, so every tool follows the same path policy.
      const forwarded = { ...request, params: { ...request.params, arguments: { ...args, save_output: false } } };
      const result = await upstream(forwarded, extra);
      const output = result.structuredContent;
      if (!result.isError && output?.svg_content?.startsWith("<!doctype html>")) {
        await fs.mkdir(path.dirname(destination), { recursive: true });
        // Reject directory symlinks that lead outside the workspace.
        const actualParent = await fs.realpath(path.dirname(destination));
        const actualRoot = await fs.realpath(process.cwd());
        const actualRelative = path.relative(actualRoot, actualParent);
        if (actualRelative.startsWith("..") || path.isAbsolute(actualRelative)) throw new Error("Output directory must remain inside the workspace");
        await fs.writeFile(destination, output.svg_content, { mode: 0o600, flag: "wx" });
        delete output.svg_content;
        output.saved_path = destination;
        output.mime_type = "text/html";
        result.content = [{ type: "text", text: `Generated interactive mind map: ${destination}. Open this HTML file in your browser.` }];
      }
      return result;
    };
  }
  return originalSetHandler.call(this, schema, handler);
};

await import(pathToFileURL(backend));
