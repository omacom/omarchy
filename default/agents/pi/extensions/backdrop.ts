// A large, faint Omarchy mark in braille dots, centered in the empty screen of
// a new session, as Codex draws its own. It sizes itself to the terminal and
// goes once the conversation has its first message.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// icon.txt on its 13 by 13 grid.
const MARK = [
  "#############",
  "#.....#.....#",
  "#.#####..##.#",
  "#.#.......#.#",
  "#.#.......#.#",
  "#.#.......#.#",
  "###.......#.#",
  "#.#.......#.#",
  "#.#.......#.#",
  "#.#.......#.#",
  "#.#########.#",
  "#.....#.....#",
  "#######.#####",
];

// The bit for each dot of a braille cell, two dots wide and four high.
const DOTS = [
  [0x01, 0x08],
  [0x02, 0x10],
  [0x04, 0x20],
  [0x40, 0x80],
];

// The editor and footer below the transcript.
const BELOW = 5;

function braille(unit: number): string[] {
  const size = MARK.length * unit;
  const on = (x: number, y: number) => x < size && y < size && MARK[Math.floor(y / unit)][Math.floor(x / unit)] === "#";
  const rows: string[] = [];
  for (let y = 0; y < size; y += 4) {
    let row = "";
    for (let x = 0; x < size; x += 2) {
      let bits = 0;
      for (let dy = 0; dy < 4; dy++) for (let dx = 0; dx < 2; dx++) if (on(x + dx, y + dy)) bits |= DOTS[dy][dx];
      row += bits ? String.fromCharCode(0x2800 + bits) : " ";
    }
    rows.push(row);
  }
  return rows;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    ctx.ui.setHeader((tui, theme) => ({
      invalidate() {},
      render(width: number): string[] {
        if (ctx.sessionManager.getEntries().some((entry) => entry.type === "message")) return [];

        const room = tui.terminal.rows - BELOW;
        // Half the free height at most, and no wider than the window.
        const unit = Math.min(6, Math.floor((room * 0.5 * 4) / MARK.length), Math.floor((width * 2) / MARK.length));
        if (unit < 2) return [];
        const mark = braille(unit);

        const top = Math.floor((room - mark.length) / 2);
        const left = " ".repeat(Math.floor((width - mark[0].length) / 2));
        return [...Array(top).fill(""), ...mark.map((row) => left + theme.fg("borderMuted", row))];
      },
    }));
  });
}
