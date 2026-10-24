-- Bundle introductions are Markdown files named introduction.md. Float that
-- window in the center. Other Omawrite documents stay tiled.
o.window({
  class = "^omawrite$",
  title = "^\\*? ?introduction\\.md - Omawrite$",
}, {
  float = true,
  center = true,
  size = { 1100, 780 },
})
