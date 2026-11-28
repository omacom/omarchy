-- Directional focus (SUPER + arrows) that also reaches floating windows.
--
-- Hyprland's own directional focus only moves between windows of the same kind,
-- tiled to tiled or floating to floating, so it skips a floating or popped-out
-- (SUPER + O) window sitting over the tiles, and can't leave one either. This
-- picks the nearest visible window in that direction by centre, tiled or
-- floating. When it is of the other kind, focus goes straight to it; otherwise
-- Hyprland's own move is kept, falling back to the nearest window, then to a
-- window of the other kind under the focused one, when that finds nothing.

local M = {}

local function center(window)
  return window.at.x + window.size.x / 2, window.at.y + window.size.y / 2
end

local function contains(window, x, y)
  return x >= window.at.x and x <= window.at.x + window.size.x
    and y >= window.at.y and y <= window.at.y + window.size.y
end

-- Windows visible on the focused window's monitor, itself excluded.
local function candidates(from)
  local monitor = from.monitor and from.monitor.id
  local workspace = hl.get_active_workspace()
  local workspace_id = workspace and workspace.id
  local visible = {}

  for _, window in ipairs(hl.get_windows()) do
    local on_screen = window.pinned or (window.workspace and window.workspace.id == workspace_id)

    if window.address ~= from.address and window.mapped and not window.hidden
        and window.monitor and window.monitor.id == monitor and on_screen then
      visible[#visible + 1] = window
    end
  end

  return visible
end

local function nearest(from, windows, direction)
  local cx, cy = center(from)
  local best, best_score

  for _, window in ipairs(windows) do
    local wx, wy = center(window)
    local dx, dy = wx - cx, wy - cy
    local along, across

    if direction == "l" then
      along, across = -dx, dy
    elseif direction == "r" then
      along, across = dx, dy
    elseif direction == "u" then
      along, across = -dy, dx
    else
      along, across = dy, dx
    end

    if along > 0 then
      local score = along + 2 * math.abs(across)
      if not best_score or score < best_score then
        best, best_score = window, score
      end
    end
  end

  return best
end

-- A window of the other kind stacked over or under the focused one, such as the
-- lone tile under a popped-out window centred on it: no direction separates them.
local function overlapping(from, windows)
  local cx, cy = center(from)

  for _, window in ipairs(windows) do
    if window.floating ~= from.floating and contains(window, cx, cy) then
      return window
    end
  end
end

local function focus_window(window)
  local target = "address:" .. window.address
  hl.dispatch(hl.dsp.focus({ window = target }))
  if window.floating then
    hl.dispatch(hl.dsp.window.alter_zorder({ window = target, mode = "top" }))
  end
end

local function focus(direction)
  local before = hl.get_active_window()
  if not before then
    hl.dispatch(hl.dsp.focus({ direction = direction }))
    return
  end

  local windows = candidates(before)
  local best = nearest(before, windows, direction)

  if best and best.floating ~= before.floating then
    focus_window(best)
    return
  end

  hl.dispatch(hl.dsp.focus({ direction = direction }))

  local after = hl.get_active_window()
  if after and after.address ~= before.address then return end

  local fallback = best or overlapping(before, windows)
  if fallback then focus_window(fallback) end
end

-- Bind actions return functions for hl.dispatch, so `hyprctl dispatch
-- 'o.window_focus.direction("l")'` runs the same thing as the key. The
-- keybindings menu replays a bind through that expression.
function M.direction(direction)
  local fn = function()
    focus(direction)
  end

  o.bind_expressions[fn] = string.format("o.window_focus.direction(%q)", direction)
  return fn
end

o.window_focus = M

return M
