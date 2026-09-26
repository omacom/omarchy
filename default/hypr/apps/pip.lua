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

-- Google Meet PiP uses the meeting title instead of "Picture-in-Picture".
o.window({ tag = "chromium-based-browser", title = "^Meet - .+" }, {
  tag = "-default-opacity",
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  opacity = "1 1",
  move = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})

-- The pattern above also matches the real meeting window, whose title keeps
-- the trailing browser name ("Meet - abc-defg-hij - Chromium"). Only the PiP
-- overlay drops it, so tile anything carrying that suffix back: the overlay
-- keeps floating while the meeting window tiles and can fullscreen again.
o.window({
  tag = "chromium-based-browser",
  title = "^Meet - .+ - (Chromium|Google Chrome|Brave|Microsoft.Edge|Vivaldi|Helium)$",
}, {
  tile = true,
})
