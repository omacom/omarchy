-- Defaults for Japanese (JIS) keyboards, which only apply when the installed
-- layout is jp. See default/hypr/keyboard.lua.

local keyboard = require("default.hypr.keyboard")
local paths = require("default.hypr.paths")

if not keyboard.jis() then
  return
end

-- Same down/up split as the universal clipboard shortcuts in clipboard.lua.
local function send_shortcut_once(mods, key)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

local function active_window_class()
  local window = hl.get_active_window()
  return ((window and window.class) or ""):lower()
end

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

-- fcitx5 toggles the input method on Ctrl + Space until its trigger keys are
-- changed, which `omarchy setup japanese` does on JIS keyboards. Without a
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

-- Ctrl + Space is the tmux and Herdr prefix. With Japanese input on, the key
-- that follows it lands in Mozc's composition instead of reaching the
-- multiplexer, so also drop back to direct input. Non-consuming, so the prefix
-- itself still goes through. Mozc keeps the prefix while composing, though. While Ctrl + Space still toggles fcitx5, this
-- would undo that toggle, so it only runs once the toggle has moved elsewhere.
o.bind("CTRL + SPACE", "Direct input for the terminal prefix (JIS)", function()
  if active_window_is_terminal() and not fcitx5_toggles_on_ctrl_space() then
    hl.exec_cmd("fcitx5-remote -c")
  end
end, { non_consuming = true })

-- On JIS, + is Shift + ;, so apps see Ctrl + Shift + semicolon and never zoom
-- in. Hand them Ctrl + keypad plus instead, which Chromium, Electron apps,
-- VS Code, and Firefox read as zoom in. Obsidian only listens for Ctrl + ^,
-- which JIS types without Shift.
local zoom_in_overrides = {
  obsidian = { "CTRL", "asciicircum" },
}

o.bind("CTRL + SHIFT + semicolon", "Zoom in (JIS + key)", function()
  local class = active_window_class()

  for pattern, chord in pairs(zoom_in_overrides) do
    if class:find(pattern, 1, true) then
      send_shortcut_once(chord[1], chord[2])
      return
    end
  end

  send_shortcut_once("CTRL", "KP_Add")
end)
