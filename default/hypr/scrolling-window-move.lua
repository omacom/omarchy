-- Reorder scrolling columns locally, then hand the window to the next monitor.
-- Dwindle uses the same handoff at a tiled workspace edge.
local function has_neighbor(window, other, direction, layout)
  local horizontal = direction == "l" or direction == "r"
  local axis = horizontal and "x" or "y"
  local cross = horizontal and "y" or "x"
  local sign = (direction == "l" or direction == "u") and -1 or 1
  if layout == "scrolling" then
    local column = window.layout and window.layout.column
    local other_column = other.layout and other.layout.column
    if not column or not other_column then return nil end
    return column.index ~= other_column.index and (other.at.x - window.at.x) * sign > 1
  end
  local center = window.at[axis] + window.size[axis] / 2
  local other_center = other.at[axis] + other.size[axis] / 2
  local overlap = math.min(window.at[cross] + window.size[cross], other.at[cross] + other.size[cross])
    - math.max(window.at[cross], other.at[cross])
  return (other_center - center) * sign > 1 and overlap > 1
end

return function(direction)
  local window = hl.get_active_window()
  if not window then return end
  local workspace = window.workspace
  local layout = workspace and workspace.tiled_layout
  local horizontal = direction == "l" or direction == "r"
  local monitors = 0
  for _, monitor in ipairs(hl.get_monitors()) do
    if not monitor.is_mirror then monitors = monitors + 1 end
  end
  if monitors < 2 or window.floating or window.group or (window.fullscreen or 0) ~= 0
      or not workspace or workspace.special or workspace.has_fullscreen
      or (layout ~= "scrolling" and layout ~= "dwindle") or (layout == "scrolling" and not horizontal) then
    hl.dispatch(hl.dsp.window.swap({ direction = direction }))
    return
  end

  for _, other in ipairs(hl.get_windows({ workspace = tostring(workspace.id), floating = false, mapped = true })) do
    if other.address ~= window.address and not other.hidden then
      local neighbor = has_neighbor(window, other, direction, layout)
      if neighbor == nil or neighbor then
        hl.dispatch(hl.dsp.window.swap({ direction = direction, window = window }))
        return
      end
    end
  end

  local fallback = hl.get_config("binds.window_direction_monitor_fallback")
  if fallback == false or fallback == 0 then return end
  local monitor = hl.get_monitor(direction)
  if monitor and not monitor.is_mirror then
    hl.dispatch(hl.dsp.window.move({ monitor = monitor.name, follow = true, window = window }))
  end
end
