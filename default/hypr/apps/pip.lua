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

-- Google Meet PiP uses the meeting title instead of "Picture-in-Picture".
o.window({ tag = "chromium-based-browser", title = "^Meet - .+" }, {
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  move = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})

-- Discord pop-outs (a user tile or a screenshare) map as "Discord Popout" and
-- are renamed to the user or stream right after, so match the initial title.
-- Hyprland matches these regexes in full, hence the trailing wildcard. The main
-- window's initial title is its URL, so it stays tiled.
o.window({ class = "^chrome-discord\\.com.*$", initial_title = "^Discord Popout.*$" }, { tag = "+pip" })
