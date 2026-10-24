-- Minimized windows wait on special:minimized, a store the dock brings them
-- back from onto the workspace in front of the user. The store is never meant
-- to be looked at. Anything else that focuses a minimized window, such as an
-- app asking to be brought forward when a link opens in it, has Hyprland show
-- the whole store over the screen instead: the window stays above everything,
-- cannot be minimized again, and a window that opens meanwhile lands in the
-- store without the floating mode or a titlebar.
--
-- So a minimized window that gets focus comes back the way the dock brings it.
-- Hyprland focuses a window in the store whenever it shows it, so the store
-- never stays on screen.

local STORE = "minimized"
local STORE_WORKSPACE = "special:" .. STORE

local M = {}

local function in_store(window)
  return window ~= nil and window.workspace ~= nil and window.workspace.name == STORE_WORKSPACE
end

local function showing_store(monitor)
  local special = monitor and monitor.active_special_workspace
  return special ~= nil and special.name == STORE_WORKSPACE
end

-- The dock's own steps: onto the workspace in front, without animating in,
-- focused and on top.
function M.bring_back(window)
  local monitor = hl.get_active_monitor()
  local workspace = monitor and monitor.active_workspace
  if not workspace or workspace.id < 1 then
    return
  end

  hl.dispatch(hl.dsp.window.set_prop({ prop = "no_anim", value = "1", window = window }))
  hl.dispatch(hl.dsp.window.move({ workspace = tostring(workspace.id), window = window }))

  -- Hyprland closes the store once its last window leaves; one still holding
  -- other minimized windows would stay over the screen.
  if showing_store(hl.get_active_monitor()) then
    hl.dispatch(hl.dsp.workspace.toggle_special(STORE))
  end

  hl.dispatch(hl.dsp.focus({ window = window }))
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = window }))

  hl.timer(function()
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_anim", value = "unset", window = window }))
  end, { type = "oneshot", timeout = 400 })
end

hl.on("window.active", function(window)
  if in_store(window) then
    M.bring_back(window)
  end
end)

return M
