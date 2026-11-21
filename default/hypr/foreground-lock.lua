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

-- A locked window carries this tag. It lives on the window, so it dies with it
-- and survives a config reload, which starts this file over.
local LOCKED_TAG = "omarchy-foreground-locked"

local last_active = nil
-- Whether the window last active held the screen at any point while it was.
local last_active_held = false

local function set_locked(window, on)
  hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = on and "0" or "unset", window = window }))
  hl.dispatch(hl.dsp.window.tag({ tag = (on and "+" or "-") .. LOCKED_TAG, window = window }))
end

local function is_locked(window)
  for _, tag in ipairs(window.tags or {}) do
    if tag == LOCKED_TAG then
      return true
    end
  end
  return false
end

local function holds_screen(window)
  return window.mapped and window.xwayland and (window.fullscreen or 0) >= 2
end

-- Omarchy hands the screen to a window focused under a fullscreen one
-- (misc.on_focus_under_fullscreen = 1), so a game left for a window on its own
-- workspace may no longer be fullscreen by the time focus is reported. If it
-- held the screen while it was active, the window now fullscreen on that
-- workspace took the screen from it. A windowed app that starts a fullscreen
-- game, such as Steam, never held it.
local function lost_screen_to(previous, window)
  return last_active_held and previous.mapped and previous.xwayland and (window.fullscreen or 0) >= 2
    and previous.workspace and window.workspace and previous.workspace.id == window.workspace.id
end

-- A config reload starts this file over while a window already has focus, and
-- that window is the one the next switch leaves.
local active = hl.get_active_window()
if active then
  last_active = active.address
  last_active_held = holds_screen(active)
end

hl.on("window.active", function(window)
  if not window then
    return
  end

  -- Only the user brings a locked window back, as it can no longer ask.
  if is_locked(window) then
    set_locked(window, false)
  end

  local previous = last_active and hl.get_window("address:" .. last_active)
  if previous and previous.address ~= window.address and previous.pid ~= window.pid and (holds_screen(previous) or lost_screen_to(previous, window)) then
    set_locked(previous, true)
  end

  if window.address ~= last_active then
    last_active = window.address
    last_active_held = false
  end
  last_active_held = last_active_held or holds_screen(window)
end)

hl.on("window.fullscreen", function(window)
  if window and window.address == last_active and holds_screen(window) then
    last_active_held = true
  end
end)

return M
