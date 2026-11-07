-- Preserve visible tiled order when Hyprland rebuilds a workspace's layout.
local M = {}
local PREFIX = "omarchy-layout-order-"

function M.clear(window)
  local tags = window.tags or {}
  for index = #tags, 1, -1 do
    local tag = tags[index]
    if tag:sub(1, #PREFIX) == PREFIX then
      hl.dispatch(hl.dsp.window.tag({ tag = "-" .. tag, window = window }))
    end
  end
end

local function rank(window, workspace)
  local prefix = PREFIX .. workspace .. "-"
  local members = window.group and window.group.members or { window }
  for _, member in ipairs(members) do
    for _, tag in ipairs(member.tags or {}) do
      if tag:sub(1, #prefix) == prefix then
        return tonumber(tag:sub(#prefix + 1))
      end
    end
  end
end

function M.capture(windows, workspace, claimed, restore)
  local order = {}
  for _, window in ipairs(windows) do
    local at = window.at
    local current = window.group and window.group.current or window
    if current.address == window.address and at and window.mapped ~= false and not window.hidden and not window.pinned
        and (window.fullscreen or 0) == 0
        and (not window.floating or claimed[window.address]) then
      table.insert(order, { window = window, address = window.address, x = at.x, y = at.y,
        rank = restore and rank(window, workspace) or nil })
    end
  end
  table.sort(order, function(a, b)
    if a.rank ~= b.rank and (a.rank or b.rank) then
      return (a.rank or math.huge) < (b.rank or math.huge)
    end
    if a.x ~= b.x then return a.x < b.x end
    if a.y ~= b.y then return a.y < b.y end
    return a.address < b.address
  end)
  return order
end

function M.remember(order, workspace)
  -- Window tags survive the first floating workspace's titlebar reload.
  for index, entry in ipairs(order) do
    local members = entry.window.group and entry.window.group.members or { entry.window }
    for _, member in ipairs(members) do
      M.clear(member)
      hl.dispatch(hl.dsp.window.tag({ tag = "+" .. PREFIX .. workspace .. "-" .. index, window = member }))
    end
  end
end

function M.restore(order)
  if #order < 2 then return end
  hl.exec_scheduled_prop_refresh_immediately()
  local actual = {}
  for _, entry in ipairs(order) do
    local window = entry.window
    if window.mapped ~= false and not window.floating and not window.hidden then
      local at = window.at
      table.insert(actual, { window = window, address = window.address, x = at.x, y = at.y })
    end
  end
  if #actual ~= #order then return end
  table.sort(actual, function(a, b)
    if a.x ~= b.x then return a.x < b.x end
    if a.y ~= b.y then return a.y < b.y end
    return a.address < b.address
  end)
  local focused = hl.get_active_window()
  local swapped = false
  for index, desired in ipairs(order) do
    if actual[index].address ~= desired.address then
      for other = index + 1, #actual do
        if actual[other].address == desired.address then
          hl.dispatch(hl.dsp.window.swap({ window = actual[index].window, target = "address:" .. desired.address }))
          actual[index], actual[other] = actual[other], actual[index]
          swapped = true
          break
        end
      end
    end
  end
  if swapped and focused and focused.mapped ~= false then
    hl.dispatch(hl.dsp.focus({ window = focused }))
  end
end

return M
