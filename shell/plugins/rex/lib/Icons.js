.pragma library

// Nerd Font glyphs for Rex's pages, kept in one place so QML files carry
// names rather than raw private-use characters.
var ICONS = {
  workbench: "󰑑",
  compare: "󰗑",
  debug: "󰃤",
  bench: "󰓅",
  tests: "󰙨",
  code: "󰅩",
  reference: "󱓷",
  lessons: "󰑴",
  library: "󰸕",
}

if (typeof module !== "undefined") module.exports = { ICONS: ICONS }
