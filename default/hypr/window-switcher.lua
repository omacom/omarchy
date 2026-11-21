-- Alt + Tab switches windows the way Windows does. The shell's switcher
-- (shell/plugins/switcher/) keeps the order windows were last used in, shows
-- them while Alt is held, and when Alt is let go calls activate below with the
-- window it landed on. Every window is in the list, whatever workspace or
-- monitor it is on, so activate goes wherever the window is.

local MINIMIZED_WORKSPACE = "special:minimized"

local M = {}

local function window_at(address)
  if type(address) ~= "string" or address == "" then
    return nil
  end

  local window = hl.get_window("address:" .. address)
  if window and window.mapped then
    return window
  end

  return nil
end

-- A minimized window comes back onto the workspace in front of the user, the
-- way the dock brings it back. Like the dock, it stays put when that workspace
-- is a named one, and the switch goes no further: focusing it where it is
-- would only open the minimized windows' special workspace.
local function bring_back_minimized(window)
  local monitor = hl.get_active_monitor()
  local workspace = monitor and monitor.active_workspace
  if not workspace or workspace.id < 1 then
    return false
  end

  hl.dispatch(hl.dsp.window.set_prop({ prop = "no_anim", value = "1", window = window }))
  hl.dispatch(hl.dsp.window.move({ workspace = tostring(workspace.id), window = window }))
  hl.timer(function()
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_anim", value = "unset", window = window }))
  end, { type = "oneshot", timeout = 400 })
  return true
end

-- Focus each window given in turn and put it on top of the others, so the last
-- ends up focused in front. A window on a workspace out of view brings its
-- workspace into view, and one on a hidden special workspace, such as the
-- scratchpad, shows it. A dialog comes after the windows it belongs to, the
-- topmost owner first, so it stays on top of them.
function M.activate(...)
  local addresses = { ... }
  return function()
    for _, address in ipairs(addresses) do
      local target = window_at(address)
      if target then
        if target.workspace and target.workspace.name == MINIMIZED_WORKSPACE and not bring_back_minimized(target) then
          return
        end
        hl.dispatch(hl.dsp.focus({ window = target }))
        hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = target }))
      end
    end
  end
end

o.window_switcher = M

return M
