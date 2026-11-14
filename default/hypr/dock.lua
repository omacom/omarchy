-- Dock actions run against current compositor state, not a cached UI model.
-- Keeping a move and its focus together also avoids clicks racing subprocesses.
o.dock = {}
local generation = 0
local restoring = {}
local restore_workspaces = {}
local RESTORE_TAG = "omarchy-dock-restore"

-- Place a cross-monitor restore while it is still hidden. Removing this
-- temporary rule before revealing it preserves Hyprland's normal fade and
-- the user's animation and opacity preferences.
hl.window_rule({ name = RESTORE_TAG, match = { tag = RESTORE_TAG }, no_anim = true })

function o.dock.activate(address, workspace, action)
  local window = hl.get_window("address:" .. address)
  if not window or not window.mapped or workspace < 1 then return end
  generation = generation + 1
  local request = generation
  local stable_id = window.stable_id
  local current = window.workspace
  local minimized = current and (current.name == "special:minimized"
    or current.name:match("^special:minimized%-output%-"))
  local target = "address:" .. address

  local function raise()
    if request ~= generation then return end
    local live = hl.get_window(target)
    if not live or not live.mapped or live.hidden then return end
    hl.dispatch(hl.dsp.focus({ window = target }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = target }))
  end

  local destination = minimized and hl.get_workspace(tostring(workspace))
  local monitor = destination and destination.monitor
  if minimized and monitor and (restoring[address] or not window.monitor or window.monitor.id ~= monitor.id) then
    local staging = "special:minimized-output-" .. monitor.id
    if not restore_workspaces[monitor.id] then
      hl.workspace_rule({ workspace = staging, monitor = monitor.name })
      restore_workspaces[monitor.id] = true
    end
    restoring[address] = request
    hl.dispatch(hl.dsp.window.tag({ window = target, tag = "+" .. RESTORE_TAG }))
    hl.dispatch(hl.dsp.window.move({ window = target, workspace = staging, follow = false }))
    hl.timer(function()
      if restoring[address] ~= request then return end
      restoring[address] = nil
      local live = hl.get_window(target)
      if not live or not live.mapped or live.stable_id ~= stable_id then return end
      hl.dispatch(hl.dsp.window.tag({ window = target, tag = "-" .. RESTORE_TAG }))
      -- A manual move during staging takes precedence over the dock click.
      if not live.workspace or live.workspace.name ~= staging then return end
      hl.dispatch(hl.dsp.window.move({ window = target, workspace = tostring(workspace), follow = false }))
      hl.timer(raise, { type = "oneshot", timeout = 20 })
    end, { type = "oneshot", timeout = 80 })
  elseif minimized or action == "move" then
    hl.dispatch(hl.dsp.window.move({ window = target, workspace = tostring(workspace), follow = false }))
    -- The workspace mode applies floating geometry on the next event-loop tick.
    hl.timer(raise, { type = "oneshot", timeout = 20 })
  elseif current and current.id ~= workspace then
    hl.dispatch(hl.dsp.focus({ workspace = tostring(current.id) }))
    raise()
  else
    raise()
  end
end
