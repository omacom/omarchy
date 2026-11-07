-- The clipboard helper needs a Wayland surface to synchronize selections, but
-- its transparent one-pixel window must not occupy a tile. Keep focus behavior
-- unchanged: clipboard updates still need an input serial.
o.window(
  { class = "^$", title = "^Parallels Shared Clipboard$", xwayland = false },
  {
    float = true,
    size = { 1, 1 },
    opacity = 0,
    border_size = 0,
    no_shadow = true,
    no_blur = true,
  }
)
