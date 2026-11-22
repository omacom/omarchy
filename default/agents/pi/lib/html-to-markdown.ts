// Turns a fetched HTML page into readable Markdown for the model: the page's
// main content with headings, links, lists, code and tables kept, and the
// scripts, styles, navigation and other chrome dropped. It imports nothing, so
// it also runs under plain Node for its test.

const DROP = new Set([
  "script", "style", "noscript", "template", "svg", "canvas", "iframe", "object",
  "nav", "footer", "aside", "form", "button", "select", "dialog", "head",
]);
const VOID = new Set([
  "area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta",
  "param", "source", "track", "wbr",
]);
const BLOCK = new Set([
  "address", "article", "blockquote", "dd", "details", "div", "dl", "dt",
  "figcaption", "figure", "h1", "h2", "h3", "h4", "h5", "h6", "header", "hr",
  "li", "main", "ol", "p", "pre", "section", "summary", "table", "tr", "ul",
]);

const ENTITIES: Record<string, string> = {
  amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " ", ndash: "–",
  mdash: "—", hellip: "…", lsquo: "‘", rsquo: "’", ldquo: "“", rdquo: "”",
  laquo: "«", raquo: "»", copy: "©", reg: "®", trade: "™", middot: "·",
  bull: "•", times: "×", deg: "°", euro: "€", pound: "£", larr: "←",
  rarr: "→", uarr: "↑", darr: "↓", shy: "", zwj: "", zwnj: "",
};

export function decodeEntities(text: string): string {
  return text.replace(/&(#x[0-9a-f]+|#\d+|[a-z][a-z0-9]*);/gi, (match, name: string) => {
    if (name[0] === "#") {
      const code = name[1] === "x" || name[1] === "X" ? parseInt(name.slice(2), 16) : parseInt(name.slice(1), 10);
      return Number.isFinite(code) && code > 0 && code <= 0x10ffff ? String.fromCodePoint(code) : match;
    }
    return ENTITIES[name.toLowerCase()] ?? match;
  });
}

interface Tag {
  name: string;
  closing: boolean;
  attrs: Record<string, string>;
}

function parseTag(raw: string): Tag | null {
  const match = /^<\s*(\/)?\s*([a-zA-Z][a-zA-Z0-9-]*)([\s\S]*?)\/?\s*>$/.exec(raw);
  if (!match) return null;
  const attrs: Record<string, string> = {};
  const attrPattern = /([^\s=/>]+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+)))?/g;
  let attr: RegExpExecArray | null;
  while ((attr = attrPattern.exec(match[3]))) {
    attrs[attr[1].toLowerCase()] = decodeEntities(attr[2] ?? attr[3] ?? attr[4] ?? "");
  }
  return { name: match[2].toLowerCase(), closing: Boolean(match[1]), attrs };
}

function resolveUrl(href: string, base: string | undefined): string {
  if (!base) return href;
  try {
    return new URL(href, base).href;
  } catch {
    return href;
  }
}

// The part of the page worth reading: the first <main>, else the first
// <article>, else the <body>, else the whole document.
function contentOf(html: string): string {
  for (const tag of ["main", "article", "body"]) {
    const open = new RegExp(`<${tag}(\\s[^>]*)?>`, "i").exec(html);
    if (!open) continue;
    const close = html.toLowerCase().lastIndexOf(`</${tag}>`);
    if (close > open.index) return html.slice(open.index + open[0].length, close);
  }
  return html;
}

export function titleOf(html: string): string | undefined {
  const match = /<title[^>]*>([\s\S]*?)<\/title>/i.exec(html);
  const title = match ? decodeEntities(match[1]).replace(/\s+/g, " ").trim() : "";
  return title || undefined;
}

export function htmlToMarkdown(html: string, baseUrl?: string): string {
  const source = contentOf(html.replace(/<!--[\s\S]*?-->/g, "").replace(/<!\[CDATA\[[\s\S]*?\]\]>/g, ""));
  const tokens = source.match(/<[^>]*>|[^<]+|</g) ?? [];

  let out = "";
  let dropDepth = 0;
  let dropTag = "";
  let preDepth = 0;
  const lists: Array<{ ordered: boolean; index: number }> = [];
  const links: Array<{ href: string; start: number }> = [];
  let cellsInRow = 0;
  let rowsInTable = 0;
  let inCell = false;

  // A table cell or a link's text has to stay on one line, so blocks inside
  // one (a heading in a cell, a paragraph in a link) run on with a space.
  const flat = () => inCell || links.length > 0;
  const ensureBreak = (count: number) => {
    if (out === "") return;
    if (flat()) {
      if (!/\s$/.test(out)) out += " ";
      return;
    }
    const trailing = /\n*$/.exec(out)![0].length;
    if (trailing < count) out = out.replace(/[ \t]+$/, "") + "\n".repeat(count - trailing);
  };
  // Inline markers wrap their text, and one left with nothing inside (an icon
  // font's <i></i>) is taken back out. Trailing space moves outside the
  // closing marker, where Markdown needs it.
  const marks: number[] = [];
  const inline = (closing: boolean, marker: string) => {
    if (!closing) {
      marks.push(out.length);
      out += marker;
      return;
    }
    const start = marks.pop();
    if (start === undefined) return;
    const inner = out.slice(start + marker.length);
    if (inner.trim() === "") {
      out = out.slice(0, start) + inner;
    } else {
      const trailing = /\s*$/.exec(inner)![0];
      out = out.slice(0, out.length - trailing.length) + marker + trailing;
    }
  };
  const appendText = (text: string) => {
    if (preDepth > 0) {
      out += text;
      return;
    }
    let collapsed = text.replace(/\s+/g, " ");
    const open = marks[marks.length - 1];
    if (collapsed.startsWith(" ") && open !== undefined && /^(\*\*|\*|`)$/.test(out.slice(open))) {
      // Leading space goes before an opening marker, not inside it.
      const marker = out.slice(open);
      out = out.slice(0, open) + (/(^|\s)$/.test(out.slice(0, open)) ? "" : " ") + marker;
      marks[marks.length - 1] = out.length - marker.length;
      collapsed = collapsed.slice(1);
    }
    if (/(^|\n|[ (])$/.test(out) || out === "") collapsed = collapsed.replace(/^ /, "");
    if (/\n$/.test(out) && collapsed.startsWith(" ")) collapsed = collapsed.trimStart();
    out += collapsed;
  };

  for (const token of tokens) {
    if (token[0] !== "<" || token === "<") {
      if (dropDepth > 0) continue;
      appendText(decodeEntities(token));
      continue;
    }
    if (token.startsWith("<!") || token.startsWith("<?")) continue;
    const tag = parseTag(token);
    if (!tag) continue;

    if (dropDepth > 0) {
      if (tag.name === dropTag) dropDepth += tag.closing ? -1 : VOID.has(tag.name) || token.endsWith("/>") ? 0 : 1;
      continue;
    }
    if (DROP.has(tag.name) && !tag.closing) {
      if (!VOID.has(tag.name) && !token.endsWith("/>")) {
        dropDepth = 1;
        dropTag = tag.name;
      }
      continue;
    }
    if (tag.attrs.hidden !== undefined || tag.attrs["aria-hidden"] === "true") {
      if (!tag.closing && !VOID.has(tag.name) && !token.endsWith("/>")) {
        dropDepth = 1;
        dropTag = tag.name;
      }
      continue;
    }

    const name = tag.name;
    if (/^h[1-6]$/.test(name)) {
      ensureBreak(2);
      if (!tag.closing && !flat()) out += `${"#".repeat(Number(name[1]))} `;
      continue;
    }

    switch (name) {
      case "br":
        if (flat()) ensureBreak(1);
        else out = out.replace(/[ \t]+$/, "") + "\n";
        continue;
      case "hr":
        ensureBreak(2);
        out += "---";
        ensureBreak(2);
        continue;
      case "pre":
        if (tag.closing) {
          if (preDepth > 0) preDepth--;
          if (preDepth === 0) {
            out = out.replace(/\n*$/, "") + "\n```";
            ensureBreak(2);
          }
        } else {
          if (preDepth === 0) {
            ensureBreak(2);
            const language = /(?:language|lang)-([\w+-]+)/.exec(tag.attrs.class ?? "")?.[1] ?? "";
            out += "```" + language + "\n";
          }
          preDepth++;
        }
        continue;
      case "code":
        if (preDepth === 0) {
          inline(tag.closing, "`");
        } else if (!tag.closing && out.endsWith("```\n")) {
          // Highlighters put the language on the <code> inside the <pre>.
          const language = /(?:language|lang)-([\w+-]+)/.exec(tag.attrs.class ?? "")?.[1];
          if (language) out = out.slice(0, -1) + language + "\n";
        }
        continue;
      case "strong":
      case "b":
        inline(tag.closing, "**");
        continue;
      case "em":
      case "i":
        inline(tag.closing, "*");
        continue;
      case "a":
        if (tag.closing) {
          const link = links.pop();
          if (!link) continue;
          const text = out.slice(link.start).trim();
          out = out.slice(0, link.start);
          if (!text) continue;
          if (!link.href || text === link.href) {
            out += text;
          } else {
            out += `[${text}](${link.href})`;
          }
        } else {
          // A link within the page or to script leads nowhere the model can fetch.
          const href = (tag.attrs.href ?? "").trim();
          const followable = href !== "" && !href.startsWith("#") && !/^javascript:/i.test(href);
          links.push({ href: followable ? resolveUrl(href, baseUrl) : "", start: out.length });
        }
        continue;
      case "img": {
        const alt = (tag.attrs.alt ?? "").trim();
        if (alt && tag.attrs.src && !tag.attrs.src.startsWith("data:")) {
          out += `![${alt}](${resolveUrl(tag.attrs.src, baseUrl)})`;
        }
        continue;
      }
      case "ul":
      case "ol":
        if (tag.closing) lists.pop();
        else lists.push({ ordered: name === "ol", index: Number(tag.attrs.start ?? 1) - 1 });
        ensureBreak(lists.length > 0 ? 1 : 2);
        continue;
      case "li":
        ensureBreak(1);
        if (!tag.closing) {
          const list = lists[lists.length - 1];
          const indent = "  ".repeat(Math.max(0, lists.length - 1));
          if (list?.ordered) out += `${indent}${++list.index}. `;
          else out += `${indent}- `;
        }
        continue;
      case "blockquote":
        ensureBreak(2);
        if (!tag.closing) out += "> ";
        continue;
      case "table":
        ensureBreak(2);
        rowsInTable = 0;
        continue;
      case "tr":
        inCell = false;
        if (tag.closing) {
          if (cellsInRow === 0) continue;
          out = out.replace(/[ \t]+$/, "") + " |";
          rowsInTable++;
          // Markdown takes a table's first row as its header, whatever its cells are.
          if (rowsInTable === 1) out += `\n|${" --- |".repeat(cellsInRow)}`;
          out += "\n";
        } else {
          ensureBreak(1);
          cellsInRow = 0;
        }
        continue;
      case "th":
      case "td":
        if (tag.closing) {
          inCell = false;
        } else {
          out = out.replace(/[ \t]+$/, "") + (cellsInRow === 0 ? "| " : " | ");
          cellsInRow++;
          inCell = true;
        }
        continue;
    }

    if (BLOCK.has(name)) ensureBreak(name === "div" || name === "dt" || name === "dd" ? 1 : 2);
  }

  return out
    .split("\n")
    .map((line) => line.replace(/[ \t]+$/, ""))
    .join("\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}
