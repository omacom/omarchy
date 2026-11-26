// web_search: search the web from pi with zero setup.
// Uses Exa's hosted MCP search endpoint out of the box (no API key required),
// or routes automatically to a configured backend when SEARXNG_URL,
// TAVILY_API_KEY, BRAVE_API_KEY, or EXA_API_KEY is set in the environment.

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
import {
  type BackendName,
  DEFAULT_NUM_RESULTS,
  DEFAULT_TIMEOUT_SECONDS,
  MAX_NUM_RESULTS,
  MAX_TIMEOUT_SECONDS,
  runSearch,
} from "../lib/web-search.ts";

const WebSearchParams = Type.Object({
  query: Type.String({
    description:
      "What to search for. Clear, descriptive queries work well (e.g. 'Omarchy Linux keybindings documentation').",
  }),
  num_results: Type.Optional(
    Type.Number({
      description: `Number of results to return (default ${DEFAULT_NUM_RESULTS}, max ${MAX_NUM_RESULTS})`,
    }),
  ),
  timeout: Type.Optional(
    Type.Number({
      description: `Seconds to wait (default ${DEFAULT_TIMEOUT_SECONDS}, max ${MAX_TIMEOUT_SECONDS})`,
    }),
  ),
});

interface WebSearchDetails {
  query: string;
  backend?: BackendName;
  resultCount?: number;
  bytes?: number;
  savedTo?: string;
  truncated?: boolean;
  error?: string;
}

function saveToTemp(data: string): string {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "pi-web-search-"));
  const file = path.join(dir, "results.md");
  fs.writeFileSync(file, data, { mode: 0o600 });
  return file;
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description: [
      "Search the web and return matching titles, URLs, and relevant text highlights.",
      "Use this when you need current information, documentation, facts, or URLs you don't already have.",
      "Follow up with web_fetch if a highlight isn't enough and you need the full content of a URL.",
      `Output is truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)};`,
      "the full text is then saved to a temp file whose path is given.",
    ].join(" "),
    promptSnippet: "Search the web for current information, documentation, and URLs",
    promptGuidelines: [
      "Use web_search to find current information, documentation, facts, and URLs when you don't already have a URL.",
      "Follow up with web_fetch when a search highlight is not enough and you need the full page.",
    ],
    parameters: WebSearchParams,

    async execute(_toolCallId, params, signal) {
      const query = params.query.trim();
      const fail = (error: string, details: Partial<WebSearchDetails> = {}) => ({
        content: [{ type: "text" as const, text: `Error: ${error}` }],
        details: { query, error, ...details } as WebSearchDetails,
        isError: true,
      });

      if (!query) return fail("query must not be empty");

      const seconds = Math.min(Math.max(params.timeout ?? DEFAULT_TIMEOUT_SECONDS, 1), MAX_TIMEOUT_SECONDS);
      const timeout = AbortSignal.timeout(seconds * 1000);
      const combined = signal ? AbortSignal.any([signal, timeout]) : timeout;

      let outcome;
      try {
        outcome = await runSearch({
          query,
          numResults: params.num_results,
          signal: combined,
        });
      } catch (error) {
        if (timeout.aborted && !signal?.aborted) return fail(`timed out after ${seconds}s searching for "${query}"`);
        const cause = error instanceof Error ? error.message : String(error);
        return fail(cause);
      }

      const bytes = Buffer.byteLength(outcome.text, "utf8");
      const details: WebSearchDetails = {
        query,
        backend: outcome.backend,
        resultCount: outcome.resultCount,
        bytes,
      };

      const truncation = truncateHead(outcome.text, { maxLines: DEFAULT_MAX_LINES, maxBytes: DEFAULT_MAX_BYTES });
      let output = truncation.content;
      if (truncation.truncated) {
        const savedTo = saveToTemp(outcome.text);
        details.savedTo = savedTo;
        details.truncated = true;
        output +=
          `\n\n[Output truncated: ${truncation.outputLines} of ${truncation.totalLines} lines` +
          ` (${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}). Full results saved to: ${savedTo}]`;
      }

      const header = `Query: ${query}\nBackend: ${outcome.backend}`;
      return {
        content: [{ type: "text" as const, text: `${header}\n\n${output}` }],
        details,
      };
    },

    renderCall(args, theme) {
      let text = theme.fg("toolTitle", theme.bold("web_search ")) + theme.fg("accent", args.query ?? "...");
      if (args.num_results !== undefined) text += theme.fg("dim", ` (${args.num_results})`);
      return new Text(text, 0, 0);
    },

    renderResult(result, { expanded }, theme) {
      const details = result.details as WebSearchDetails | undefined;
      if (!details) {
        const first = result.content[0];
        return new Text(first?.type === "text" ? first.text : "", 0, 0);
      }
      if (details.error) return new Text(theme.fg("error", `Error: ${details.error}`), 0, 0);

      const count = details.resultCount ?? 0;
      const label = count === 1 ? "1 result" : `${count} results`;
      let text = theme.fg("success", details.backend ?? "search");
      text += theme.fg("muted", ` · ${label} · ${formatSize(details.bytes ?? 0)}`);
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
