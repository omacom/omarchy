-- A fullscreen game the user switches away from stays behind, the way Windows
-- keeps it there. Wine never lets go of the game's Win32 foreground when focus
-- goes to a window outside it, so every time the game touches its own window it
-- asks the window manager to activate it again. Omarchy honours such requests
-- (misc.focus_on_activate), and the game takes the keyboard back while the
-- window the user picked stays drawn in front of it.
--
-- So a fullscreen XWayland window that loses focus to another app only turns
-- urgent when it asks, until the user brings it back. X11 asks with no proof the
-- user was involved, where a Wayland app needs an activation token from the app
-- the user was using, so a browser opening a link still comes forward.

local M = {}

local locked = {}
local last_active = nil

local function set_focus_on_activate(window, value)
  hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = value, window = window }))
end

local function holds_screen(window)
  return window.mapped and window.xwayland and (window.fullscreen or 0) >= 2
end

hl.on("window.active", function(window)
  if not window then
    return
  end

  -- Only the user brings a locked window back, as it can no longer ask.
  if locked[window.address] then
    locked[window.address] = nil
    set_focus_on_activate(window, "unset")
  end

  local previous = last_active and hl.get_window("address:" .. last_active)
  last_active = window.address

  if previous and previous.address ~= window.address and previous.pid ~= window.pid and holds_screen(previous) then
    locked[previous.address] = true
    set_focus_on_activate(previous, "0")
  end
end)

hl.on("window.close", function(window)
  if window then
    locked[window.address] = nil
  end
end)

return M
