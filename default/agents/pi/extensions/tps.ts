// Tokens per second for each reply, shown in the footer as OpenCode does.
// The clock starts at the first streamed token, so the prompt processing
// before it doesn't count: the number is how fast the model writes. Replies
// that error, abort or arrive in one piece leave the last number standing.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let firstToken: number | undefined;

  pi.on("message_start", async (event) => {
    if (event.message.role === "assistant") firstToken = undefined;
  });

  pi.on("message_update", async () => {
    firstToken ??= performance.now();
  });

  pi.on("message_end", async (event, ctx) => {
    const message = event.message;
    if (message.role !== "assistant" || firstToken === undefined || !ctx.hasUI) return;
    if (message.stopReason === "error" || message.stopReason === "aborted") return;

    const seconds = (performance.now() - firstToken) / 1000;
    const tokens = message.usage?.output ?? 0;
    if (seconds < 0.25 || tokens < 1) return;

    ctx.ui.setStatus("tps", ctx.ui.theme.fg("dim", `${Math.round(tokens / seconds)} tok/s`));
  });
}
