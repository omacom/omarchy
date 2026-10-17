-- Each monitor keeps its own workspaces 1–10, like macOS Spaces with
-- "Displays have separate Spaces". Hyprland workspace ids are global, so
-- monitor N (0-based, stable for a display's description) owns ids
-- N*10+1 through N*10+10. The internal panel is slot 0, which leaves a
-- single screen on the familiar 1–10 ids.

local M = {}

M.count = 10
M.state_name = "monitor-workspaces.json"
M.park_base = 900000

function M.global_id(index, local_n)
  return index * M.count + local_n
end

function M.local_number(index, id)
  if type(index) ~= "number" or type(id) ~= "number" then
    return nil
  end

  local local_n = id - index * M.count
  if local_n < 1 or local_n > M.count then
    return nil
  end

  return local_n
end

local function json_escape(value)
  return (tostring(value):gsub("\\", "\\\\"):gsub('"', '\\"'))
end

function M.state_path()
  local home = os.getenv("HOME") or ""
  local state_home = os.getenv("XDG_STATE_HOME")
  if state_home == nil or state_home == "" then
    state_home = home .. "/.local/state"
  end

  return state_home .. "/omarchy/" .. M.state_name
end

function M.read_state(path)
  local slots = {}
  local file = io.open(path or M.state_path(), "r")
  if not file then
    return { enabled = false, slots = slots }
  end

  local raw = file:read("*a") or ""
  file:close()

  local enabled = raw:find('"enabled"%s*:%s*true') ~= nil
  local monitors = raw:match('"monitors"%s*:%s*{(.-)}') or ""
  for description, index in monitors:gmatch('"([^"\\]*)"%s*:%s*(%d+)') do
    slots[description] = tonumber(index)
  end

  return { enabled = enabled, slots = slots }
end

function M.write_state(slots, enabled, path)
  path = path or M.state_path()
  local directory = path:match("^(.*)/")
  if directory then
    os.execute("mkdir -p " .. "'" .. directory:gsub("'", "'\\''") .. "'")
  end

  local descriptions = {}
  for description in pairs(slots) do
    descriptions[#descriptions + 1] = description
  end
  table.sort(descriptions)

  local lines = {}
  for _, description in ipairs(descriptions) do
    lines[#lines + 1] = string.format('    "%s": %d', json_escape(description), slots[description])
  end

  local body = "{\n"
  body = body .. '  "enabled": ' .. (enabled and "true" or "false") .. ",\n"
  body = body .. '  "count": ' .. tostring(M.count) .. ",\n"
  body = body .. '  "monitors": {\n'
  body = body .. table.concat(lines, ",\n")
  if #lines > 0 then
    body = body .. "\n"
  end
  body = body .. "  }\n}\n"

  local temporary = path .. ".tmp"
  local file = io.open(temporary, "w")
  if not file then
    return false
  end

  file:write(body)
  file:close()
  os.rename(temporary, path)
  return true
end

local function next_index(slots)
  local highest = -1
  for _, index in pairs(slots) do
    if index > highest then
      highest = index
    end
  end

  return highest + 1
end

local function internal_monitor(monitor)
  local name = monitor.name or ""
  return name:find("^eDP") ~= nil or name:find("^LVDS") ~= nil or name:find("^DSI") ~= nil
end

local function sort_monitors(monitors)
  table.sort(monitors, function(left, right)
    local left_internal = internal_monitor(left)
    local right_internal = internal_monitor(right)
    if left_internal ~= right_internal then
      return left_internal
    end

    local left_x = (left.position and left.position.x) or 0
    local right_x = (right.position and right.position.x) or 0
    if left_x ~= right_x then
      return left_x < right_x
    end

    local left_y = (left.position and left.position.y) or 0
    local right_y = (right.position and right.position.y) or 0
    if left_y ~= right_y then
      return left_y < right_y
    end

    return (left.name or "") < (right.name or "")
  end)
end

-- Assign a stable slot to each connected display. Existing descriptions keep
-- their slot so unplugging and replugging does not renumber workspaces.
function M.assign_slots(monitors, slots)
  slots = slots or {}
  local fresh = {}
  for _, monitor in ipairs(monitors) do
    local description = monitor.description or ""
    if description ~= "" and slots[description] == nil then
      fresh[#fresh + 1] = monitor
    end
  end

  sort_monitors(fresh)
  for _, monitor in ipairs(fresh) do
    slots[monitor.description] = next_index(slots)
  end

  return slots
end

-- Workspaces outside a monitor's id block move into it. local number is
-- preserved when the target id is free (workspace 6 on the second monitor
-- becomes 16, which that monitor still shows as 6). Swaps park on a
-- temporary id first so two monitors can exchange numbers safely.
function M.plan_moves(workspaces, slots)
  local used = {}
  for _, workspace in ipairs(workspaces) do
    if workspace.id and workspace.id > 0 then
      used[workspace.id] = true
    end
  end

  local movers = {}
  for _, workspace in ipairs(workspaces) do
    local id = workspace.id
    local index = workspace.description and slots[workspace.description] or nil
    if not workspace.special and id and id > 0 and index ~= nil and not M.local_number(index, id) then
      used[id] = nil
      movers[#movers + 1] = {
        from = id,
        to = M.global_id(index, ((id - 1) % M.count) + 1),
        index = index,
      }
    end
  end

  local claimed = {}
  for id in pairs(used) do
    claimed[id] = true
  end

  for _, move in ipairs(movers) do
    local target = move.to
    if claimed[target] then
      target = nil
      for local_n = 1, M.count do
        local candidate = M.global_id(move.index, local_n)
        if not claimed[candidate] then
          target = candidate
          break
        end
      end
    end

    move.to = target
    if target then
      claimed[target] = true
    end
  end

  local origins = {}
  local needs_park = false
  for _, move in ipairs(movers) do
    origins[move.from] = true
  end
  for _, move in ipairs(movers) do
    if move.to and origins[move.to] then
      needs_park = true
      break
    end
  end

  local steps = {}
  if not needs_park then
    for _, move in ipairs(movers) do
      if move.to and move.to ~= move.from then
        steps[#steps + 1] = { from = move.from, to = move.to }
      end
    end
    return steps
  end

  for index, move in ipairs(movers) do
    if move.to and move.to ~= move.from then
      local park = M.park_base + index
      steps[#steps + 1] = { from = move.from, to = park }
      move.park = park
    end
  end
  for _, move in ipairs(movers) do
    if move.park and move.to then
      steps[#steps + 1] = { from = move.park, to = move.to }
    end
  end

  return steps
end

local function notify(text)
  if hl and hl.notification and hl.notification.create then
    hl.notification.create({ text = text, timeout = 8000 })
  end
end

local function connected_monitors()
  local monitors = hl.get_monitors() or {}
  local listed = {}
  for _, monitor in ipairs(monitors) do
    listed[#listed + 1] = monitor
  end
  return listed
end

local function workspace_snapshot(slots)
  local listed = {}
  for _, workspace in ipairs(hl.get_workspaces() or {}) do
    local monitor = workspace.monitor
    local description = monitor and monitor.description or nil
    listed[#listed + 1] = {
      id = workspace.id,
      special = workspace.special == true,
      description = description,
    }
  end
  return listed
end

function M.apply()
  local state = M.read_state()
  local slots = M.assign_slots(connected_monitors(), state.slots)
  local steps = M.plan_moves(workspace_snapshot(slots), slots)

  for _, step in ipairs(steps) do
    local ok, err = pcall(function()
      hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(step.from), id = step.to }))
    end)
    if not ok then
      -- Leave the rules unpinned. A pin for an id that still lives on the
      -- other monitor would pull that workspace across.
      notify("Separate workspaces could not renumber workspace " .. tostring(step.from) .. ": " .. tostring(err))
      return
    end
  end

  -- An id still occupied on another monitor is left unpinned. Pinning it
  -- would move that workspace onto this screen.
  local occupied = {}
  for _, workspace in ipairs(workspace_snapshot()) do
    if not workspace.special and workspace.id and workspace.id > 0 and workspace.description then
      occupied[workspace.id] = workspace.description
    end
  end

  for _, monitor in ipairs(connected_monitors()) do
    local description = monitor.description or ""
    local index = slots[description]
    if index ~= nil and description ~= "" then
      for local_n = 1, M.count do
        local id = M.global_id(index, local_n)
        local holder = occupied[id]
        if holder == nil or holder == description then
          hl.workspace_rule({
            workspace = tostring(id),
            monitor = "desc:" .. description,
          })
        end
      end
    end
  end

  M.write_state(slots, true)
end

local function monitor_index(monitor, slots)
  if not monitor or not monitor.description then
    return nil
  end

  return slots[monitor.description]
end

function M.focus_local(local_n)
  local monitor = hl.get_active_monitor()
  local slots = M.read_state().slots
  local index = monitor_index(monitor, slots)
  if index == nil then
    hl.dispatch(hl.dsp.focus({ workspace = tostring(local_n) }))
    return
  end

  hl.dispatch(hl.dsp.focus({ workspace = tostring(M.global_id(index, local_n)) }))
end

function M.move_local(local_n, follow)
  local monitor = hl.get_active_monitor()
  local slots = M.read_state().slots
  local index = monitor_index(monitor, slots)
  local id = local_n
  if index ~= nil then
    id = M.global_id(index, local_n)
  end

  if follow then
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(id) }))
  else
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(id), follow = false }))
  end
end

function M.focus_existing_relative(delta)
  hl.dispatch(hl.dsp.focus({ workspace = delta < 0 and "m-1" or "m+1" }))
end

local function unbind(keys)
  if hl and hl.unbind then
    pcall(hl.unbind, keys)
  end
end

function M.install_binds()
  for local_n = 1, M.count do
    -- Bind callbacks must close over this iteration's number. Lua 5.1 reuses
    -- one loop variable, and every key would otherwise land on workspace 10.
    local n = local_n
    local key = "code:" .. tostring(n + 9)
    unbind("SUPER + " .. key)
    unbind("SUPER + SHIFT + " .. key)
    unbind("SUPER + SHIFT + ALT + " .. key)

    o.bind("SUPER + " .. key, "Switch to workspace " .. n .. " on this monitor", function()
      M.focus_local(n)
    end)
    o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. n .. " on this monitor", function()
      M.move_local(n, true)
    end)
    o.bind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. n .. " on this monitor", function()
      M.move_local(n, false)
    end)
  end

  unbind("SUPER + TAB")
  unbind("SUPER + SHIFT + TAB")
  o.bind("SUPER + TAB", "Next workspace on this monitor", function()
    M.focus_existing_relative(1)
  end)
  o.bind("SUPER + SHIFT + TAB", "Previous workspace on this monitor", function()
    M.focus_existing_relative(-1)
  end)

  unbind("SUPER + mouse_down")
  unbind("SUPER + mouse_up")
  o.bind("SUPER + mouse_down", "Scroll active workspace forward on this monitor", function()
    M.focus_existing_relative(1)
  end)
  o.bind("SUPER + mouse_up", "Scroll active workspace backward on this monitor", function()
    M.focus_existing_relative(-1)
  end)
end

function M.install()
  M.install_binds()
  local ok, err = pcall(M.apply)
  if not ok then
    notify("Separate workspaces failed: " .. tostring(err))
  end
end

return M
