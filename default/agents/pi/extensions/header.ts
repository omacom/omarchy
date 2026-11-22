// Pi's startup header with the Omarchy mark in the theme's accent in place of
// Pi's logo, beside Pi's version and its compact key hints. The listing of
// loaded context, skills and extensions is left out by quietStartup: "header",
// which omarchy-agent-pi-defaults sets.

import { type ExtensionAPI, keyHint, keyText, rawKeyHint, VERSION } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

// icon.txt, one cell per square of its 13 by 13 grid.
const MARK = [
  "█▀▀▀▀▀█▀▀▀▀▀█",
  "█ █▀▀▀▀  ▀█ █",
  "█ █       █ █",
  "█▀█       █ █",
  "█ █       █ █",
  "█ ▀▀▀▀█▀▀▀▀ █",
  "▀▀▀▀▀▀▀ ▀▀▀▀▀",
];

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    ctx.ui.setHeader((_tui, theme) => ({
      invalidate() {},
      render(width: number): string[] {
        const hints = [
          keyHint("app.interrupt", "interrupt"),
          rawKeyHint(`${keyText("app.clear")}/${keyText("app.exit")}`, "clear/exit"),
          rawKeyHint("/", "commands"),
          rawKeyHint("!", "bash"),
        ].join(theme.fg("muted", " · "));
        const beside = ["", "", theme.fg("dim", `Pi v${VERSION}`), hints];

        return MARK.map((row, i) => truncateToWidth(` ${theme.fg("accent", row)}   ${beside[i] ?? ""}`, width));
      },
    }));
  });
}
