-- Picture-in-picture overlays.
-- Inline 600x338 in move the same way webcam-overlay.lua inlines its size
-- expressions. Hyprland evaluates window_w / window_h from the client's
-- original size, then applies size, so a small Chromium PiP would otherwise
-- hang off the right edge.
o.window({ title = "(Picture.?in.?[Pp]icture)" }, { tag = "+pip" })
o.window({ tag = "pip" }, {
  tag = "-default-opacity",
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  opacity = "1 1",
  move = { "(monitor_w-600-40)", "(monitor_h*0.04)" },
})

-- Google Meet PiP uses the meeting title instead of "Picture-in-Picture".
o.window({ tag = "chromium-based-browser", title = "^Meet - .+" }, {
  tag = "-default-opacity",
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  opacity = "1 1",
  move = { "(monitor_w-600-40)", "(monitor_h-338-40)" },
})
