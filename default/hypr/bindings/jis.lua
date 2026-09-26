-- Defaults for Japanese (JIS) keyboards, which only apply when the installed
-- layout is jp. See default/hypr/keyboard.lua.

local keyboard = require("default.hypr.keyboard")

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

-- Ctrl + Space is the tmux and Herdr prefix. With Japanese input on, the key
-- that follows it lands in Mozc's composition instead of reaching the
-- multiplexer, so drop back to direct input first. Non-consuming, so the prefix
-- itself still goes through. `omarchy setup japanese` moves the input method
-- toggle to Henkan/Muhenkan on JIS keyboards, leaving Ctrl + Space free.
o.bind("CTRL + SPACE", "Direct input for the terminal prefix (JIS)", function()
  if active_window_is_terminal() then
    hl.exec_cmd("fcitx5-remote -c")
  end
end, { non_consuming = true })

-- On JIS, + is Shift + ;, so apps see Ctrl + Shift + semicolon and never zoom
-- in. Hand them the keypad plus instead, which Chromium, Electron apps, VS Code,
-- Firefox, and the terminals all read as zoom in. Obsidian only listens for
-- Ctrl + ^, which JIS types without Shift.
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
