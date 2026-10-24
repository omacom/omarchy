-- A standalone config keeps personal shell, mux, and key bindings out of the screensaver.
return {
  enable_wayland = true,
  font_size = 18.0,
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  window_background_opacity = 1.0,
  window_decorations = "NONE",
  enable_tab_bar = false,
  enable_scroll_bar = false,
  colors = {
    background = "#000000",
    cursor_bg = "#000000",
    cursor_border = "#000000",
  },
  default_cursor_style = "SteadyBlock",
  check_for_updates = false,
  window_close_confirmation = "NeverPrompt",
  exit_behavior = "Close",
  disable_default_key_bindings = true,
  disable_default_mouse_bindings = true,
}
