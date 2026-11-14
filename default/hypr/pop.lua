-- Hyprland moves a floating window to another monitor at the same offset from its origin,
-- so a window can land off-center or off a smaller or rotated screen: one minimized from
-- the bottom of a portrait monitor comes back below the bottom of a landscape one, where
-- Alt + Tab and the dock focus it out of sight. A popped-out window (Super+O) is centered
-- again, and any other floating window is moved just far enough to be on screen.

local function tagged(window, wanted)
  for _, tag in ipairs(window.tags or {}) do
    if tag == wanted then
      return true
    end
  end

  return false
end

-- The part of the monitor a window can sit in: inside the bar and anything else that
-- reserves an edge.
local function usable_area(monitor)
  local width = math.floor(monitor.width / monitor.scale)
  local height = math.floor(monitor.height / monitor.scale)

  if (monitor.transform or 0) % 2 == 1 then
    width, height = height, width
  end

  local reserved = monitor.reserved or {}
  local left, top = reserved.left or 0, reserved.top or 0

  return {
    x = monitor.x + left,
    y = monitor.y + top,
    w = width - left - (reserved.right or 0),
    h = height - top - (reserved.bottom or 0),
  }
end

local function overlaps(window, area)
  return window.at.x < area.x + area.w and window.at.x + window.size.x > area.x
    and window.at.y < area.y + area.h and window.at.y + window.size.y > area.y
end

-- Where along one axis the window, with what is drawn before and after it, fits in the
-- room: as close to where it was as it can be, and against the start when it is larger
-- than the room, so its titlebar stays in reach.
local function within(position, length, before, after, start, room)
  return math.max(start + before, math.min(position, start + room - length - after))
end

-- Hyprland's position and size leave out the border all around, and the titlebar a
-- floating workspace draws above the window.
local function keep_on_screen(window, moved_monitor)
  if not (window.floating and (window.fullscreen or 0) == 0 and window.monitor and window.at and window.size) then
    return
  end

  local area = usable_area(window.monitor)
  -- A window coming back from the minimized windows' store stays on the same monitor
  -- when the store has moved there with it, out of sight all along.
  if not moved_monitor and overlaps(window, area) then
    return
  end

  local border = hl.get_config("general.border_size") or 0
  local bar = 0
  if tagged(window, "omarchy-floating-workspace") and hl.plugin.hyprbars then
    bar = hl.get_config("plugin.hyprbars.bar_height") or 0
  end

  local x = within(window.at.x, window.size.x, border, border, area.x, area.w)
  local y = within(window.at.y, window.size.y, border + bar, border, area.y, area.h)
  if x ~= window.at.x or y ~= window.at.y then
    hl.dispatch(hl.dsp.window.move({ x = x, y = y, relative = false, window = "address:" .. window.address }))
  end
end

-- A dispatcher move fires this before the window lands, while window.monitor is still
-- the one it is leaving, so the window is placed a loop later. A mouse drag has already
-- landed.
hl.on("window.move_to_workspace", function(window, workspace)
  if not (window and workspace and window.monitor and workspace.monitor) then return end

  local target = "address:" .. window.address
  local moved_monitor = window.monitor.id ~= workspace.monitor.id
  hl.timer(function()
    if moved_monitor and tagged(window, "pop") then
      hl.dispatch(hl.dsp.window.center({ window = target }))
      return
    end

    local landed = hl.get_window(target)
    if landed then
      keep_on_screen(landed, moved_monitor)
    end
  end, { timeout = 1, type = "oneshot" })
end)
