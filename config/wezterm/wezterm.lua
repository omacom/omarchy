local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- Dynamic theme colors. omarchy-theme-set-templates renders
-- default/themed/wezterm.lua.tpl into the current theme on every theme change.
-- Guard the load: the file is absent on a theme that predates the template, and
-- a half-written one during a theme swap must not take the whole config down.
local home_dir = wezterm.home_dir or os.getenv("HOME")
if home_dir and home_dir ~= "" then
  local theme_chunk = loadfile(home_dir .. "/.local/state/omarchy/current/theme/wezterm.lua")
  if theme_chunk then
    local ok, colors = pcall(theme_chunk)
    if ok and type(colors) == "table" then
      -- A malformed palette must not discard font, window and key settings.
      pcall(function() config.colors = colors end)
    end
  end
end

config.term = "xterm-256color"

-- Fontconfig carries the user's selected monospace family.
config.font = wezterm.font("monospace", { weight = "Regular" })
config.font_size = 9

-- Window
config.window_decorations = "NONE"
config.enable_tab_bar = false
config.window_padding = { left = 14, right = 14, top = 14, bottom = 14 }
config.window_close_confirmation = "NeverPrompt"

-- Cursor
config.default_cursor_style = "SteadyBlock"

-- Keybindings
config.keys = {
  -- Leave Omarchy's tmux split and resize chords to the application.
  { key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },
  { key = "LeftArrow", mods = "CTRL|ALT|SHIFT", action = act.DisableDefaultAssignment },
  { key = "RightArrow", mods = "CTRL|ALT|SHIFT", action = act.DisableDefaultAssignment },
  { key = "UpArrow", mods = "CTRL|ALT|SHIFT", action = act.DisableDefaultAssignment },
  { key = "DownArrow", mods = "CTRL|ALT|SHIFT", action = act.DisableDefaultAssignment },
  { key = "Insert", mods = "CTRL", action = act.CopyTo("Clipboard") },
  { key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") },
  -- Send Shift+Enter as CSI-u so TUIs can distinguish it from Enter.
  { key = "Enter", mods = "SHIFT", action = act.SendString("\27[13;2u") },
  -- Legacy encoding sends Alt+Shift+Enter the same as Alt+Enter; send CSI-u so tmux can match M-S-Enter.
  { key = "Enter", mods = "ALT|SHIFT", action = act.SendString("\27[13;4u") },
}

return config
