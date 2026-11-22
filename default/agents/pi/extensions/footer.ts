// Pi's footer, trimmed to one line with tokens per second for each reply as
// OpenCode shows it. The folder and branch move into the editor's top border,
// and cost, the cache counters and the auto-compaction marker are dropped, so the
// footer keeps the same height from the first prompt on. The clock starts at
// the first streamed token, so the prompt processing before it doesn't count:
// the number is how fast the model writes. Replies that error, abort or arrive
// in one piece leave the last number standing.

import { CustomEditor, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatTokens(count: number): string {
  if (count < 1000) return `${count}`;
  if (count < 10_000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1_000_000) return `${Math.round(count / 1000)}k`;
  return `${(count / 1_000_000).toFixed(1)}M`;
}

export default function (pi: ExtensionAPI) {
  let firstToken: number | undefined;
  let tps: number | undefined;
  let branch: () => string | null | undefined = () => undefined;
  let requestRender = () => {};

  function place(ctx: ExtensionContext): string {
    let text = ctx.sessionManager.getCwd().replace(process.env.HOME ?? "\0", "~");
    const current = branch();
    if (current) text += ` (${current})`;
    const name = ctx.sessionManager.getSessionName();
    if (name) text += ` • ${name}`;
    return text;
  }

  function install(ctx: ExtensionContext) {
    // Pi draws its border, spinner and "↑ N more" in the width left of the
    // folder, and the folder goes on the right when there's room for both.
    class PlaceEditor extends CustomEditor {
      renderTopBorder(width: number, hiddenLineCount: number): string {
        const label = ` ${place(ctx)} `;
        const rest = width - visibleWidth(label) - 1;
        if (rest < 20) return super.renderTopBorder(width, hiddenLineCount);
        return super.renderTopBorder(rest, hiddenLineCount) + ctx.ui.theme.fg("dim", label) + this.borderColor("─");
      }
    }
    ctx.ui.setEditorComponent((tui, theme, keybindings) => new PlaceEditor(tui, theme, keybindings, { embedWorkingStatus: true }));

    ctx.ui.setFooter((tui, theme, footerData) => {
      requestRender = () => tui.requestRender();
      branch = () => footerData.getGitBranch();
      const unsubscribe = footerData.onBranchChange(requestRender);

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          const dim = (text: string) => theme.fg("dim", text);

          let input = 0;
          let output = 0;
          for (const entry of ctx.sessionManager.getEntries()) {
            const usage = entry.type === "message" ? entry.message.usage : entry.usage;
            if (!usage) continue;
            input += usage.input;
            output += usage.output;
          }

          const stats: string[] = [];
          if (input) stats.push(`↑${formatTokens(input)}`);
          if (output) stats.push(`↓${formatTokens(output)}`);
          const context = ctx.getContextUsage();
          const window = context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
          const percent = context?.percent;
          stats.push(`${percent == null ? "?" : percent.toFixed(1)}%/${formatTokens(window)}`);
          if (tps !== undefined) stats.push(`${Math.round(tps)} tok/s`);
          let left = dim(stats.join(" "));
          if ((percent ?? 0) > 90) left = theme.fg("error", stats.join(" "));
          else if ((percent ?? 0) > 70) left = theme.fg("warning", stats.join(" "));

          let model = ctx.model?.id ?? "no-model";
          if (ctx.model?.reasoning) {
            const level = pi.getThinkingLevel();
            model += level === "off" ? " • thinking off" : ` • ${level}`;
          }
          if (ctx.model && footerData.getAvailableProviderCount() > 1) {
            const withProvider = `(${ctx.model.provider}) ${model}`;
            if (visibleWidth(left) + 2 + visibleWidth(withProvider) <= width) model = withProvider;
          }
          const room = width - visibleWidth(left) - 2;
          const right = room > 0 ? truncateToWidth(model, room, "") : "";
          const gap = " ".repeat(Math.max(0, width - visibleWidth(left) - visibleWidth(right)));

          const lines = [truncateToWidth(left + dim(gap + right), width)];
          const statuses = [...footerData.getExtensionStatuses()].sort(([a], [b]) => a.localeCompare(b));
          if (statuses.length) lines.push(truncateToWidth(statuses.map(([, text]) => text).join(" "), width, dim("...")));
          return lines;
        },
      };
    });
  }

  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) install(ctx);
  });

  pi.on("message_start", async (event) => {
    if (event.message.role === "assistant") firstToken = undefined;
  });

  pi.on("message_update", async () => {
    firstToken ??= performance.now();
  });

  pi.on("message_end", async (event) => {
    const message = event.message;
    if (message.role !== "assistant" || firstToken === undefined) return;
    if (message.stopReason === "error" || message.stopReason === "aborted") return;

    const seconds = (performance.now() - firstToken) / 1000;
    const tokens = message.usage?.output ?? 0;
    if (seconds < 0.25 || tokens < 1) return;

    tps = tokens / seconds;
    requestRender();
  });
}
