// Web search client for Pi's web_search tool.
// Uses Exa's hosted MCP search endpoint out of the box (no API key required),
// or routes automatically when SEARXNG_URL, TAVILY_API_KEY, BRAVE_API_KEY, or
// EXA_API_KEY is set. Imports nothing from Pi, so it runs under plain Node for
// tests.

export const DEFAULT_NUM_RESULTS = 8;
export const MAX_NUM_RESULTS = 20;
export const DEFAULT_TIMEOUT_SECONDS = 25;
export const MAX_TIMEOUT_SECONDS = 60;
export const MAX_RESPONSE_BYTES = 4 * 1024 * 1024;

export const EXA_MCP_URL = "https://mcp.exa.ai/mcp";
export const TAVILY_SEARCH_URL = "https://api.tavily.com/search";
export const BRAVE_SEARCH_URL = "https://api.search.brave.com/res/v1/web/search";
export const USER_AGENT = "pi-web-search";

export const BYOK_HINT =
  "Set EXA_API_KEY, TAVILY_API_KEY, BRAVE_API_KEY, or SEARXNG_URL in your environment to use your own search backend.";

export type BackendName = "searxng" | "tavily" | "brave" | "exa" | "exa-free";

export interface SearchOutcome {
  backend: BackendName;
  text: string;
  resultCount: number;
}

export interface SearchOptions {
  query: string;
  numResults?: number;
  signal: AbortSignal;
  env?: Record<string, string | undefined>;
  endpoints?: {
    exa?: string;
    tavily?: string;
    brave?: string;
  };
}

export function sanitizeError(message: string, secrets: Array<string | undefined>): string {
  let clean = message;
  for (const secret of secrets) {
    if (!secret) continue;
    clean = clean.replaceAll(secret, "[REDACTED]");
    clean = clean.replaceAll(encodeURIComponent(secret), "[REDACTED]");
  }
  return clean;
}

async function readTextCapped(response: Response, signal: AbortSignal): Promise<string> {
  const reader = response.body?.getReader();
  if (!reader) return "";
  const chunks: Uint8Array[] = [];
  let total = 0;
  while (true) {
    if (signal.aborted) throw signal.reason ?? new Error("aborted");
    const { done, value } = await reader.read();
    if (done) break;
    const remaining = MAX_RESPONSE_BYTES - total;
    if (value.byteLength >= remaining) {
      chunks.push(value.subarray(0, remaining));
      await reader.cancel().catch(() => {});
      break;
    }
    chunks.push(value);
    total += value.byteLength;
  }
  const merged = new Uint8Array(chunks.reduce((sum, chunk) => sum + chunk.byteLength, 0));
  let offset = 0;
  for (const chunk of chunks) {
    merged.set(chunk, offset);
    offset += chunk.byteLength;
  }
  return new TextDecoder("utf-8").decode(merged);
}

export function parseMcpResponse(raw: string, contentType: string): any {
  const trimmed = raw.trim();
  if (!trimmed) throw new Error("Exa search returned an empty response");

  if (contentType.includes("text/event-stream") || /^\s*(?:event:|data:)/m.test(trimmed)) {
    let lastPayload: any;
    let dataLines: string[] = [];

    const flush = () => {
      if (dataLines.length === 0) return;
      const joined = dataLines.join("\n").trim();
      dataLines = [];
      if (!joined || joined === "[DONE]") return;
      try {
        lastPayload = JSON.parse(joined);
      } catch {
        // Ignore non-JSON SSE control frames.
      }
    };

    for (const line of trimmed.split(/\r?\n/)) {
      if (line === "") {
        flush();
      } else if (line.startsWith("data:")) {
        dataLines.push(line.slice(5).trimStart());
      }
    }
    flush();

    if (lastPayload !== undefined) return lastPayload;
    throw new Error("Exa search returned an unreadable event stream");
  }

  try {
    return JSON.parse(trimmed);
  } catch {
    throw new Error(`Exa search returned invalid JSON: ${trimmed.slice(0, 200)}`);
  }
}

export function buildSearxngUrl(baseUrl: string, query: string): URL {
  let base: URL;
  try {
    base = new URL(baseUrl);
  } catch {
    throw new Error(`SEARXNG_URL is not a valid URL: ${baseUrl}`);
  }
  if (base.protocol !== "http:" && base.protocol !== "https:") {
    throw new Error(`SEARXNG_URL must use http or https, not ${base.protocol}`);
  }
  if (!base.pathname.endsWith("/")) base.pathname += "/";
  const url = new URL("search", base);
  url.searchParams.set("q", query);
  url.searchParams.set("format", "json");
  return url;
}

function formatEntries(
  items: Array<{ title?: string; url?: string; dateLabel?: string; date?: string; snippet?: string }>,
): string {
  if (items.length === 0) return "(no results)";
  return items
    .map((item, i) => {
      const lines = [`${i + 1}. ${item.title?.trim() || "(untitled)"}`, `URL: ${item.url ?? ""}`];
      if (item.date && item.dateLabel) lines.push(`${item.dateLabel}: ${item.date}`);
      if (item.snippet?.trim()) lines.push(`Snippet: ${item.snippet.trim()}`);
      return lines.join("\n");
    })
    .join("\n\n");
}

async function searchExa(
  endpoint: string,
  query: string,
  numResults: number,
  signal: AbortSignal,
  apiKey?: string,
): Promise<SearchOutcome> {
  const target = new URL(endpoint);
  if (apiKey) target.searchParams.set("exaApiKey", apiKey);

  const response = await fetch(target, {
    method: "POST",
    signal,
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json, text/event-stream",
      "User-Agent": USER_AGENT,
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "tools/call",
      params: {
        name: "web_search_exa",
        arguments: {
          query,
          objective: query,
          numResults,
        },
      },
    }),
  });

  const raw = await readTextCapped(response, signal);
  if (!response.ok) {
    const rateLimited = response.status === 429 || /rate limit/i.test(raw);
    const detail = sanitizeError(raw.trim().slice(0, 300) || response.statusText, [apiKey]);
    throw new Error(
      rateLimited && !apiKey
        ? `Exa free MCP rate limit hit (${response.status}): ${detail}\n${BYOK_HINT}`
        : `Exa search failed (${response.status}): ${detail}`,
    );
  }

  const contentType = (response.headers.get("content-type") ?? "").toLowerCase();
  const payload = parseMcpResponse(raw, contentType);

  if (payload?.error) {
    const msg = sanitizeError(payload.error.message ?? JSON.stringify(payload.error), [apiKey]);
    throw new Error(!apiKey && /rate limit/i.test(msg) ? `${msg}\n${BYOK_HINT}` : `Exa error: ${msg}`);
  }

  const parts: Array<{ type?: string; text?: string }> = payload?.result?.content ?? [];
  const text = parts
    .filter((p) => p.type === "text" && typeof p.text === "string")
    .map((p) => p.text!.trim())
    .filter(Boolean)
    .join("\n\n");

  if (payload?.result?.isError) {
    const msg = sanitizeError(text || "Exa search returned an error", [apiKey]);
    throw new Error(!apiKey && /rate limit/i.test(msg) ? `${msg}\n${BYOK_HINT}` : msg);
  }

  const resultCount = (text.match(/^Title:/gm) ?? []).length;
  return {
    backend: apiKey ? "exa" : "exa-free",
    text: text || "(no results)",
    resultCount,
  };
}

async function searchSearxng(
  baseUrl: string,
  query: string,
  numResults: number,
  signal: AbortSignal,
): Promise<SearchOutcome> {
  const url = buildSearxngUrl(baseUrl, query);
  const response = await fetch(url, {
    signal,
    headers: { Accept: "application/json", "User-Agent": USER_AGENT },
  });
  const raw = await readTextCapped(response, signal);
  if (!response.ok) {
    throw new Error(`SearXNG search failed (${response.status} ${response.statusText})`);
  }

  const data = JSON.parse(raw) as {
    results?: Array<{ title?: string; url?: string; content?: string; publishedDate?: string }>;
  };
  const items = (data.results ?? []).slice(0, numResults);
  const text = formatEntries(
    items.map((item) => ({
      title: item.title,
      url: item.url,
      dateLabel: "Published",
      date: item.publishedDate,
      snippet: item.content,
    })),
  );

  return { backend: "searxng", text, resultCount: items.length };
}

async function searchTavily(
  endpoint: string,
  apiKey: string,
  query: string,
  numResults: number,
  signal: AbortSignal,
): Promise<SearchOutcome> {
  const response = await fetch(endpoint, {
    method: "POST",
    signal,
    headers: { "Content-Type": "application/json", "User-Agent": USER_AGENT },
    body: JSON.stringify({
      api_key: apiKey,
      query,
      max_results: numResults,
      include_answer: false,
    }),
  });
  const raw = await readTextCapped(response, signal);
  if (!response.ok) {
    const detail = sanitizeError(raw.trim().slice(0, 300) || response.statusText, [apiKey]);
    throw new Error(`Tavily search failed (${response.status}): ${detail}`);
  }

  const data = JSON.parse(raw) as {
    results?: Array<{ title?: string; url?: string; content?: string; published_date?: string }>;
  };
  const items = (data.results ?? []).slice(0, numResults);
  const text = formatEntries(
    items.map((item) => ({
      title: item.title,
      url: item.url,
      dateLabel: "Published",
      date: item.published_date,
      snippet: item.content,
    })),
  );

  return { backend: "tavily", text, resultCount: items.length };
}

async function searchBrave(
  endpoint: string,
  apiKey: string,
  query: string,
  numResults: number,
  signal: AbortSignal,
): Promise<SearchOutcome> {
  const url = new URL(endpoint);
  url.searchParams.set("q", query);
  url.searchParams.set("count", String(numResults));

  const response = await fetch(url, {
    signal,
    headers: {
      Accept: "application/json",
      "X-Subscription-Token": apiKey,
      "User-Agent": USER_AGENT,
    },
  });
  const raw = await readTextCapped(response, signal);
  if (!response.ok) {
    const detail = sanitizeError(raw.trim().slice(0, 300) || response.statusText, [apiKey]);
    throw new Error(`Brave search failed (${response.status}): ${detail}`);
  }

  const data = JSON.parse(raw) as {
    web?: { results?: Array<{ title?: string; url?: string; description?: string; age?: string }> };
  };
  const items = (data.web?.results ?? []).slice(0, numResults);
  const text = formatEntries(
    items.map((item) => ({
      title: item.title,
      url: item.url,
      dateLabel: "Age",
      date: item.age,
      snippet: item.description,
    })),
  );

  return { backend: "brave", text, resultCount: items.length };
}

export async function runSearch(options: SearchOptions): Promise<SearchOutcome> {
  const env = options.env ?? process.env;
  const query = options.query.trim();
  if (!query) throw new Error("query must not be empty");

  const numResults = Math.min(Math.max(Math.round(options.numResults ?? DEFAULT_NUM_RESULTS), 1), MAX_NUM_RESULTS);

  const searxngUrl = env.SEARXNG_URL?.trim();
  const tavilyKey = env.TAVILY_API_KEY?.trim();
  const braveKey = env.BRAVE_API_KEY?.trim();
  const exaKey = env.EXA_API_KEY?.trim();
  const secrets = [tavilyKey, braveKey, exaKey];

  try {
    if (searxngUrl) return await searchSearxng(searxngUrl, query, numResults, options.signal);
    if (tavilyKey) {
      return await searchTavily(options.endpoints?.tavily ?? TAVILY_SEARCH_URL, tavilyKey, query, numResults, options.signal);
    }
    if (braveKey) {
      return await searchBrave(options.endpoints?.brave ?? BRAVE_SEARCH_URL, braveKey, query, numResults, options.signal);
    }
    return await searchExa(options.endpoints?.exa ?? EXA_MCP_URL, query, numResults, options.signal, exaKey);
  } catch (error) {
    if (error instanceof Error) {
      const cause = (error.cause as Error | undefined)?.message ?? error.message;
      throw new Error(sanitizeError(cause, secrets));
    }
    throw new Error(sanitizeError(String(error), secrets));
  }
}
