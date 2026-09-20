-- Keep the occupied workspaces numbered consecutively: 1, 2, 3 ... with no gaps.
--
-- When a workspace empties, the workspaces above it slide down to fill the
-- hole, windows and all, so their order is preserved. The workspace you are on
-- always counts as open, even when empty; if it is numbered past the next free
-- slot (Super + 7 with only 1-2 in use), you land on the next free number.

-- Give close/move events a moment to settle before looking at the windows.
local settle_ms = 120

local busy = false

local function active_id()
  local workspace = hl.get_active_workspace()
  if workspace == nil or workspace.id == nil or workspace.id <= 0 then
    return nil -- special workspaces (scratchpad) are left alone
  end
  return workspace.id
end

-- { [workspace id] = { window address, ... } } for mapped windows on real workspaces.
local function windows_by_workspace()
  local by_workspace = {}
  local windows = hl.get_windows()
  if type(windows) ~= "table" then
    return by_workspace
  end

  for _, window in ipairs(windows) do
    local id = window.workspace and window.workspace.id
    if window.mapped and id ~= nil and id > 0 then
      by_workspace[id] = by_workspace[id] or {}
      table.insert(by_workspace[id], window.address)
    end
  end
  return by_workspace
end

local function compact()
  if busy then
    return
  end
  busy = true

  local by_workspace = windows_by_workspace()
  local active = active_id()

  local open = {}
  for id in pairs(by_workspace) do
    table.insert(open, id)
  end
  if active ~= nil and by_workspace[active] == nil then
    table.insert(open, active)
  end
  table.sort(open)

  local refocus = nil
  for slot, id in ipairs(open) do
    if id ~= slot then
      -- Every id below this one is already packed, so the slot is free.
      for _, address in ipairs(by_workspace[id] or {}) do
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(slot), follow = false, window = "address:" .. address }))
      end
      if id == active then
        refocus = slot
      end
    end
  end

  if refocus ~= nil then
    hl.dispatch(hl.dsp.focus({ workspace = tostring(refocus) }))
  end

  busy = false
end

local function compact_soon()
  hl.timer(compact, { timeout = settle_ms, type = "oneshot" })
end

hl.on("workspace.active", compact_soon)
hl.on("window.open", compact_soon)
hl.on("window.close", compact_soon)
hl.on("window.move_to_workspace", compact_soon)

-- Tidy up whatever is already open when the config (re)loads.
compact_soon()
