-- Picture-in-picture overlays.
o.window({ title = "(Picture.?in.?[Pp]icture)" }, { tag = "+pip" })
o.window({ tag = "pip" }, {
  tag = "-default-opacity",
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  opacity = "1 1",
  move = { "(monitor_w-window_w-40)", "(monitor_h*0.04)" },
})

-- Google Meet PiP uses the meeting title instead of "Picture-in-Picture", and
-- separates it with an en dash. The browser's own window uses an ASCII hyphen
-- ("Meet - <meeting> - Google Chrome"), so matching the dash is what keeps this
-- rule off the main window.
o.window({ tag = "chromium-based-browser", title = "^Meet [–—] .+" }, {
  tag = "-default-opacity",
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  opacity = "1 1",
  move = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})
