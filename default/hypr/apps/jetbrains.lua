-- Disable mouse focus (see https://github.com/omacom/omarchy/pull/5183#issuecomment-4189299971).
o.window("^(jetbrains-.*)$", { no_follow_mouse = true })

local function monitor_size(monitor)
  local width, height = monitor.width / monitor.scale, monitor.height / monitor.scale
  if monitor.transform % 2 == 1 then
    width, height = height, width
  end
  return width, height
end

-- Toolbox can reopen entirely outside the monitor layout after initial window rules run.
local function schedule_toolbox_recovery(window)
  if window.class ~= "jetbrains-toolbox" or not window.xwayland or not window.floating then
    return
  end

  local selector, stable_id = "address:" .. window.address, window.stable_id
  local function recover_if_offscreen()
    local w = hl.get_window(selector)
    if not w or w.stable_id ~= stable_id or not w.mapped or w.hidden or not w.floating then
      return
    end

    local at, size = w.at, w.size
    for _, monitor in ipairs(hl.get_monitors()) do
      local width, height = monitor_size(monitor)
      if at.x < monitor.x + width and at.x + size.x > monitor.x
        and at.y < monitor.y + height and at.y + size.y > monitor.y then
        return
      end
    end

    local workspace = hl.get_active_workspace()
    if not workspace or not workspace.monitor then
      return
    end

    hl.dispatch(hl.dsp.window.move({ window = w, workspace = workspace, follow = false }))
    hl.dispatch(hl.dsp.window.center({ window = w }))
    hl.dispatch(hl.dsp.window.alter_zorder({ window = w, mode = "top" }))
  end

  -- Recheck late placement without polling indefinitely or reopening a closed window.
  for _, delay in ipairs({ 150, 750 }) do
    hl.timer(recover_if_offscreen, { timeout = delay, type = "oneshot" })
  end
end

hl.on("window.open", schedule_toolbox_recovery)

-- Also handle a Toolbox window already off screen when the configuration is reloaded.
-- Raw iteration avoids the keybinding scanner's endlessly indexable mock window list.
local windows = hl.get_windows()
if type(windows) == "table" then
  for _, window in next, windows do
    schedule_toolbox_recovery(window)
  end
end
