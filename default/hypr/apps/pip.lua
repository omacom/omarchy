-- Picture-in-picture overlays.
o.window({ title = "(Picture.?in.?[Pp]icture)" }, { tag = "+pip" })
o.window({ tag = "pip" }, {
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  move = { "(monitor_w-window_w-40)", "(monitor_h*0.04)" },
})

-- Google Meet PiP titles omit the browser suffix used by regular Meet tabs, and take
-- their dash from the meeting page, so it can be a hyphen, an en dash or an em dash.
o.window({
  tag = "chromium-based-browser",
  title = "^Meet (-|–|—) .+",
  initial_title = "negative:.* - (Chromium|Google Chrome|Brave|Microsoft Edge|Vivaldi|Helium)$",
}, {
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  move = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})
