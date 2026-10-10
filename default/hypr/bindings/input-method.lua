local paths = require("default.hypr.paths")

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

-- Read on demand so adding an engine in a live desktop needs no reload.
local function has_input_method()
  local file = io.open(paths.config_home .. "/fcitx5/profile", "r")
  if not file then return false end
  local in_item, found = false, false
  for line in file:lines() do
    if line:match("^%[") then
      in_item = line:match("^%[Groups/%d+/Items/%d+%]$") ~= nil
    elseif in_item then
      local name = line:match("^Name=(.+)$")
      if name and not name:match("^keyboard%-") then found = true end
    end
  end
  file:close()
  return found
end

-- Keep the desktop shortcut independent of Fcitx's custom switching keys.
-- Read the live Fcitx group so setup works without a compositor reload.
o.bind("SUPER + I", "Switch input language", "omarchy-input-method cycle")
o.bind("SUPER + SHIFT + I", "Switch input language back", "omarchy-input-method cycle back")

-- Preserve custom Ctrl + Space triggers. Without a
-- [Hotkey/TriggerKeys] list in the config, fcitx5 uses its default, which has
-- Ctrl + Space.
local function fcitx5_toggles_on_ctrl_space()
  local file = io.open(paths.config_home .. "/fcitx5/config", "r")
  if not file then
    return true
  end

  local in_triggers, has_triggers, toggles = false, false, false
  for line in file:lines() do
    if line:match("^%[") then
      in_triggers = line == "[Hotkey/TriggerKeys]"
      has_triggers = has_triggers or in_triggers
    elseif in_triggers and line:match("^%d+=Control%+space$") then
      toggles = true
    end
  end

  file:close()
  return toggles or not has_triggers
end

-- Pass the tmux/Herdr prefix through and return to direct input, so the next
-- key reaches the multiplexer instead of the engine's composition.
o.bind("CTRL + SPACE", "Direct input for the terminal prefix", function()
  if active_window_is_terminal() and has_input_method() and not fcitx5_toggles_on_ctrl_space() then
    -- Wait for the local controller reply before dispatching the next key.
    o.shell_succeeds("timeout 0.3 fcitx5-remote --check -c")
  end
end, { non_consuming = true })
