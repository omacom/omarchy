// web_fetch: read a web page as Markdown, the way OpenCode's webfetch and
// Omp's fetch tool do, so the model doesn't curl raw HTML into its context.
// Text and JSON come back as they are, images as images, PDFs as their text
// (with pdftotext), and anything else is saved to a temp file for the other
// tools to open. A page that comes back all but empty says why.

import { execFile } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import {
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  type ExtensionAPI,
  formatSize,
  truncateHead,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { htmlToMarkdown, titleOf } from "../lib/html-to-markdown.ts";

const MAX_RESPONSE_BYTES = 10 * 1024 * 1024;
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const DEFAULT_TIMEOUT_SECONDS = 30;
const MAX_TIMEOUT_SECONDS = 120;
const IMAGE_TYPES = new Set(["image/png", "image/jpeg", "image/gif", "image/webp"]);
// Some sites turn away anything that doesn't look like a browser.
const USER_AGENT =
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0 Safari/537.36";
const HONEST_USER_AGENT = "pi-web-fetch";

function challenged(response: Response): boolean {
  return response.status === 403 && response.headers.get("cf-mitigated") === "challenge";
}

const WebFetchParams = Type.Object({
  url: Type.String({ description: "The http(s) URL to fetch" }),
  raw: Type.Optional(Type.Boolean({ description: "Return HTML as-is instead of converting it to Markdown" })),
  timeout: Type.Optional(
    Type.Number({ description: `Seconds to wait (default ${DEFAULT_TIMEOUT_SECONDS}, max ${MAX_TIMEOUT_SECONDS})` }),
  ),
});

interface WebFetchDetails {
  url: string;
  status?: number;
  contentType?: string;
  bytes?: number;
  title?: string;
  savedTo?: string;
  truncated?: boolean;
  error?: string;
}

// A file view on GitHub is an HTML page around the file; the raw file is what's wanted.
export function rawGitHubUrl(url: URL): URL {
  const match = /^\/([^/]+)\/([^/]+)\/blob\/(.+)$/.exec(url.pathname);
  if (url.hostname !== "github.com" || !match) return url;
  return new URL(`https://raw.githubusercontent.com/${match[1]}/${match[2]}/${match[3]}`);
}

async function readCapped(response: Response, signal: AbortSignal): Promise<{ bytes: Buffer; complete: boolean }> {
  const reader = response.body?.getReader();
  if (!reader) return { bytes: Buffer.alloc(0), complete: true };
  const chunks: Buffer[] = [];
  let total = 0;
  while (true) {
    if (signal.aborted) throw signal.reason ?? new Error("aborted");
    const { done, value } = await reader.read();
    if (done) return { bytes: Buffer.concat(chunks), complete: true };
    chunks.push(Buffer.from(value));
    total += value.byteLength;
    if (total > MAX_RESPONSE_BYTES) {
      await reader.cancel().catch(() => {});
      return { bytes: Buffer.concat(chunks).subarray(0, MAX_RESPONSE_BYTES), complete: false };
    }
  }
}

function saveToTemp(name: string, data: Buffer | string): string {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "pi-web-fetch-"));
  const file = path.join(dir, name);
  fs.writeFileSync(file, data, { mode: 0o600 });
  return file;
}

// A name for a saved download, kept well under the 255-byte filename limit
// however long the URL's last segment is.
function fileNameFor(url: URL, contentType: string): string {
  const base = path.basename(url.pathname).replace(/[^\w.-]+/g, "_");
  const known = base.includes(".") ? path.extname(base).slice(1, 17) : "";
  const extension = known || contentType.split("/")[1]?.split(/[+;]/)[0]?.slice(0, 16) || "bin";
  const stem = (known ? base.slice(0, -known.length - 1) : base).slice(0, 100) || "download";
  return `${stem}.${extension}`;
}

// The PDF's text, or undefined when pdftotext isn't installed or can't read it.
function pdfText(file: string, signal: AbortSignal): Promise<string | undefined> {
  return new Promise((resolve) => {
    execFile("pdftotext", ["-enc", "UTF-8", file, "-"], { signal, maxBuffer: 64 * 1024 * 1024 }, (error, stdout) => {
      resolve(error || !stdout.trim() ? undefined : stdout);
    });
  });
}

function decode(bytes: Buffer, contentType: string): string {
  const charset = /charset=["']?([\w-]+)/i.exec(contentType)?.[1] ?? "utf-8";
  try {
    return new TextDecoder(charset).decode(bytes);
  } catch {
    return new TextDecoder("utf-8").decode(bytes);
  }
}

function isText(contentType: string): boolean {
  return (
    contentType === "" ||
    contentType.startsWith("text/") ||
    /[/+](json|xml|javascript|ecmascript|yaml|toml|x-sh|csv)\b/.test(contentType)
  );
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description: [
      "Fetch a URL and return its content. HTML pages are converted to Markdown (main content only;",
      "pass raw: true for the HTML). Text, JSON and other text formats come back as-is, images as images,",
      "PDFs as their text, and other files are saved to a temp file whose path is returned.",
      "It fetches a URL you already have; it does not search the web.",
      `Output is truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)};`,
      "the full text is then saved to a temp file whose path is given.",
    ].join(" "),
    promptSnippet: "Fetch a web page or file over http(s) and read it as Markdown",
    promptGuidelines: [
      "Use web_fetch instead of curl or wget in bash to read web pages, documentation and other URLs.",
      "For GitHub issues, pull requests and API data, prefer the gh CLI in bash over web_fetch when gh is available.",
    ],
    parameters: WebFetchParams,

    async execute(_toolCallId, params, signal) {
      const fail = (error: string, details: Partial<WebFetchDetails> = {}) => ({
        content: [{ type: "text" as const, text: `Error: ${error}` }],
        details: { url: params.url, error, ...details } as WebFetchDetails,
        isError: true,
      });

      let url: URL;
      try {
        url = new URL(params.url);
      } catch {
        return fail(`not a valid URL: ${params.url}`);
      }
      if (url.protocol !== "http:" && url.protocol !== "https:") {
        return fail(`only http and https URLs can be fetched, not ${url.protocol}`);
      }
      url = rawGitHubUrl(url);

      const seconds = Math.min(Math.max(params.timeout ?? DEFAULT_TIMEOUT_SECONDS, 1), MAX_TIMEOUT_SECONDS);
      const timeout = AbortSignal.timeout(seconds * 1000);
      const combined = signal ? AbortSignal.any([signal, timeout]) : timeout;

      const request = (userAgent: string) =>
        fetch(url, {
          redirect: "follow",
          signal: combined,
          headers: {
            "User-Agent": userAgent,
            // Sites that serve Markdown to agents send it instead of HTML.
            Accept: "text/markdown, text/html;q=0.9, application/xhtml+xml;q=0.9, */*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
          },
        });

      let response: Response;
      let body: { bytes: Buffer; complete: boolean };
      try {
        response = await request(USER_AGENT);
        // Cloudflare challenges a browser that can't run its check, yet often
        // lets through a client that says plainly what it is.
        if (challenged(response)) {
          await response.body?.cancel().catch(() => {});
          response = await request(HONEST_USER_AGENT);
        }
        body = await readCapped(response, combined);
      } catch (error) {
        if (timeout.aborted && !signal?.aborted) return fail(`timed out after ${seconds}s fetching ${url.href}`);
        const cause = error instanceof Error ? ((error.cause as Error | undefined)?.message ?? error.message) : String(error);
        return fail(`could not fetch ${url.href}: ${cause}`);
      }

      const finalUrl = response.url || url.href;
      const contentType = (response.headers.get("content-type") ?? "").toLowerCase();
      const mimeType = contentType.split(";")[0].trim();
      const details: WebFetchDetails = {
        url: finalUrl,
        status: response.status,
        contentType: mimeType,
        bytes: body.bytes.length,
      };
      const header = [`URL: ${finalUrl}`, `Status: ${response.status} ${response.statusText}`.trim()];

      if (IMAGE_TYPES.has(mimeType) && body.complete && body.bytes.length <= MAX_IMAGE_BYTES && response.ok) {
        return {
          content: [
            { type: "text" as const, text: header.join("\n") },
            { type: "image" as const, data: body.bytes.toString("base64"), mimeType },
          ],
          details,
        };
      }

      let text: string | undefined;
      if (!isText(mimeType) && !mimeType.includes("html")) {
        const savedTo = saveToTemp(fileNameFor(new URL(finalUrl), mimeType), body.bytes);
        details.savedTo = savedTo;
        // Pi's read tool can't open a PDF, so its text comes back when pdftotext is installed.
        if (mimeType === "application/pdf" && body.complete && response.ok) text = await pdfText(savedTo, combined);
        if (text === undefined) {
          const note = body.complete ? "" : ` (cut off at ${formatSize(MAX_RESPONSE_BYTES)})`;
          return {
            content: [
              {
                type: "text" as const,
                text: [...header, `Content-Type: ${mimeType}`, `Saved ${formatSize(body.bytes.length)}${note} to: ${savedTo}`].join("\n"),
              },
            ],
            details,
            isError: !response.ok,
          };
        }
        header.push(`PDF saved to: ${savedTo}`);
      }

      text ??= decode(body.bytes, contentType);
      if (mimeType.includes("html") && !params.raw) {
        const html = text;
        details.title = titleOf(html);
        text = htmlToMarkdown(html, finalUrl);
        if (details.title) header.push(`Title: ${details.title}`);
        if (challenged(response)) {
          header.push("Note: blocked by a Cloudflare bot check. Look for the same content elsewhere.");
        } else if (text.length < 200 && html.length > 5000) {
          header.push(
            "Note: the page has almost no readable text. It probably renders with JavaScript; look for the same content elsewhere, such as a raw file, an API or the project's repository.",
          );
        }
      }
      if (!body.complete) text += `\n\n[Response cut off at ${formatSize(MAX_RESPONSE_BYTES)}]`;

      const truncation = truncateHead(text, { maxLines: DEFAULT_MAX_LINES, maxBytes: DEFAULT_MAX_BYTES });
      let output = truncation.content;
      if (truncation.truncated) {
        const savedTo = saveToTemp(mimeType.includes("html") && !params.raw ? "page.md" : fileNameFor(new URL(finalUrl), mimeType), text);
        details.savedTo = savedTo;
        details.truncated = true;
        output +=
          `\n\n[Output truncated: ${truncation.outputLines} of ${truncation.totalLines} lines` +
          ` (${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}). Full text saved to: ${savedTo}]`;
      }

      return {
        content: [{ type: "text" as const, text: `${header.join("\n")}\n\n${output || "(empty response)"}` }],
        details,
        isError: !response.ok,
      };
    },

    renderCall(args, theme) {
      let text = theme.fg("toolTitle", theme.bold("web_fetch ")) + theme.fg("accent", args.url ?? "...");
      if (args.raw) text += theme.fg("dim", " (raw)");
      return new Text(text, 0, 0);
    },

    renderResult(result, { expanded }, theme) {
      const details = result.details as WebFetchDetails | undefined;
      if (!details) {
        const first = result.content[0];
        return new Text(first?.type === "text" ? first.text : "", 0, 0);
      }
      if (details.error) return new Text(theme.fg("error", `Error: ${details.error}`), 0, 0);

      const ok = details.status !== undefined && details.status < 400;
      let text = theme.fg(ok ? "success" : "error", `${details.status}`);
      text += theme.fg("muted", ` ${details.contentType || "unknown"} · ${formatSize(details.bytes ?? 0)}`);
      if (details.title) text += ` ${theme.fg("text", details.title)}`;
      if (details.truncated) text += theme.fg("warning", " (truncated)");
      if (details.savedTo) text += `\n${theme.fg("dim", `saved to ${details.savedTo}`)}`;
      if (expanded) {
        const body = result.content.find((part) => part.type === "text");
        if (body?.type === "text") text += `\n\n${theme.fg("toolOutput", body.text)}`;
      }
      return new Text(text, 0, 0);
    },
  });
}
