-- Unplugging a monitor, or the lid disabling the laptop panel, keeps you on the
-- workspace you were on. Hyprland first warps focus to whichever monitor it
-- lists first and only then moves the removed monitor's workspaces over, so the
-- one you were on lands hidden behind that monitor's own. Measured on Hyprland
-- 0.56.2 (CMonitor::onDisconnect).
--
-- monitor.focused fires before Hyprland records the new focus, so the monitor
-- still reported as active is the one being left. The workspace it showed is
-- kept until the event loop next turns, which the removal that caused the warp
-- finishes well before: a monitor.removed inside that window brings it back.

local left_behind = nil
local generation = 0
local moves = 0
local restoring = false

local function selector(ws)
  if not ws or type(ws.id) ~= "number" then
    return nil
  end

  -- Named workspaces have negative ids, which a selector reads as relative.
  if ws.id > 0 then
    return tostring(ws.id)
  end
  return "name:" .. ws.name
end

local function later(fn)
  hl.timer(fn, { timeout = 1, type = "oneshot" })
end

hl.on("monitor.focused", function(monitor)
  if restoring then
    return
  end

  generation = generation + 1
  moves = moves + 1
  left_behind = nil

  local leaving = hl.get_active_monitor()
  if not leaving or not monitor or leaving.name == monitor.name then
    return
  end

  -- An open scratchpad already comes along to the front of the next monitor.
  if hl.get_active_special_workspace(leaving) then
    return
  end

  left_behind = selector(hl.get_active_workspace(leaving))
  local seen = generation
  later(function()
    if generation == seen then
      left_behind = nil
    end
  end)
end)

-- Only counts towards giving way to the user once the removal is over: the
-- workspaces it moves between monitors fire this too, before monitor.removed.
hl.on("workspace.active", function()
  if not restoring then
    moves = moves + 1
  end
end)

hl.on("monitor.removed", function()
  local workspace = left_behind
  left_behind = nil
  if not workspace then
    return
  end

  -- Let the removal finish first, and give way to any focus or workspace change
  -- since.
  local seen = moves
  later(function()
    if moves ~= seen or selector(hl.get_active_workspace()) == workspace or not hl.get_workspace(workspace) then
      return
    end

    restoring = true
    pcall(hl.dispatch, hl.dsp.focus({ workspace = workspace }))
    restoring = false
  end)
end)
