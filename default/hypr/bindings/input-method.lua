-- Same terminal tag test as clipboard.lua.
local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

-- Read the shortcut the user chose for switching the input language under
-- Setup > Typing > Keyboard Shortcuts. The file is rewritten by
-- omarchy-menu-keyboard-shortcuts and re-read on every Hyprland reload, so the
-- new binding takes effect immediately. A missing, empty or blank file means
-- the default.
local function read_input_language_shortcut()
  local default = "SUPER + I"
  local paths = require("default.hypr.paths")
  local file = io.open(paths.config_home .. "/omarchy/keyboard-shortcut", "r")
  if not file then
    return default
  end

  local line = file:read("*l")
  file:close()
  if not line then
    return default
  end

  line = line:gsub("^%s+", ""):gsub("%s+$", "")
  if line == "" then
    return default
  end

  -- "LEFT ALT + RIGHT ALT" was renamed to "LEFT ALT"; keep old files working.
  if line == "LEFT ALT + RIGHT ALT" then
    return "LEFT ALT"
  end

  return line
end

local shortcut = read_input_language_shortcut()

-- Keep the desktop shortcut independent of Fcitx's custom switching keys.
-- Read the live Fcitx group so setup works without a compositor reload.
-- Any value that isn't listed here falls back to SUPER + I, which is also the
-- row the menu ticks for it.
if shortcut == "ALT + SHIFT" then
  o.bind("ALT + SHIFT", "Switch input language", "omarchy-input-method cycle")
elseif shortcut == "LEFT ALT" then
  -- Left Alt on its own: fire when the key is released, so Alt still works as
  -- a modifier for every other shortcut. This is a release binding, which
  -- o.bind doesn't expose, so it goes straight to Hyprland.
  hl.bind("ALT + Alt_L", hl.dsp.exec_cmd("omarchy-input-method cycle"), {
    release = true,
    description = "Switch input language",
  })
else
  o.bind("SUPER + I", "Switch input language", "omarchy-input-method cycle")
end

-- "Back" stays complementary: if the primary is a modifier toggle, Super +
-- Shift + I still steps the other direction; it is unaffected by the
-- choice and never conflicts.
o.bind("SUPER + SHIFT + I", "Switch input language back", "omarchy-input-method cycle back")
