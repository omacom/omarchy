-- Dock actions run against current compositor state, not a cached UI model.
-- Keeping a move and its focus together also avoids clicks racing subprocesses.
o.dock = {}
local generation = 0

function o.dock.activate(address, workspace, action)
  local window = hl.get_window("address:" .. address)
  if not window or not window.mapped or workspace < 1 then return end
  generation = generation + 1
  local request = generation
  local current = window.workspace
  local minimized = current and current.name == "special:minimized"
  local target = "address:" .. address

  local function raise()
    if request ~= generation then return end
    local live = hl.get_window(target)
    if not live or not live.mapped or live.hidden then return end
    hl.dispatch(hl.dsp.focus({ window = target }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = target }))
  end

  if minimized or action == "move" then
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
