-- Windows-style recent order for Super+Tab (workspaces) and Alt+Tab (windows).
-- Copied into ~/.local/state/omarchy/toggles/hypr by `omarchy toggle windows mru`.
-- Toggles load after personal bindings, so this replaces a Super+Tab or Alt+Tab
-- rebind in ~/.config/hypr/bindings.lua while it is on.
--
-- A quick tap flips between the two most recent items. Holding Super or Alt and
-- tapping Tab walks further back through that list; Shift+Tab reverses. Releasing
-- the modifier leaves the item you landed on at the front. Switches made while
-- the modifier is held do not update the list, so walking through it does not
-- reshuffle the items still ahead.

local ws_mru = {}
local ws_cycling = false
local ws_cycle_mon = nil
local ws_cycle_list = {}
local ws_cycle_index = 1
local ws_cycle_target = nil

local function record_ws(mon_name, ws_id)
  if not mon_name or not ws_id or ws_id <= 0 then
    return
  end
  local list = ws_mru[mon_name] or {}
  for i = #list, 1, -1 do
    if list[i] == ws_id then
      table.remove(list, i)
    end
  end
  table.insert(list, 1, ws_id)
  ws_mru[mon_name] = list
end

local function seed_ws_mru()
  for _, mon in ipairs(hl.get_monitors()) do
    local last = hl.get_last_workspace(mon.name)
    if last and not last.special and last.id > 0 then
      record_ws(mon.name, last.id)
    end
    local active = mon.active_workspace
    if active and not active.special and active.id > 0 then
      record_ws(mon.name, active.id)
    end
  end
end

seed_ws_mru()

hl.on("workspace.active", function(ws)
  if ws_cycling or not ws or ws.special or ws.id <= 0 then
    return
  end
  local mon = ws.monitor or hl.get_active_monitor()
  if mon and mon.name then
    record_ws(mon.name, ws.id)
  end
end)

local function build_ws_cycle_list(mon)
  local active = mon.active_workspace
  local active_id = active and not active.special and active.id or nil
  local existing = {}
  local existing_ids = {}

  for _, ws in ipairs(hl.get_workspaces()) do
    if not ws.special and ws.id > 0 and ws.monitor and ws.monitor.name == mon.name then
      existing[ws.id] = true
      table.insert(existing_ids, ws.id)
    end
  end
  table.sort(existing_ids)

  local list = {}
  local seen = {}
  local function add(id)
    if id and id > 0 and not seen[id] then
      seen[id] = true
      table.insert(list, id)
    end
  end

  if active_id then
    add(active_id)
  end

  for _, id in ipairs(ws_mru[mon.name] or {}) do
    if existing[id] then
      add(id)
    end
  end

  for _, id in ipairs(existing_ids) do
    add(id)
  end

  -- One real workspace still needs a partner to flip to: the last visit, even
  -- if that workspace was empty and removed, or the other of the first two slots.
  if #list < 2 then
    for _, id in ipairs(ws_mru[mon.name] or {}) do
      add(id)
      if #list >= 2 then
        break
      end
    end
  end
  if #list < 2 then
    local last = hl.get_last_workspace(mon.name)
    if last and not last.special and last.id > 0 then
      add(last.id)
    end
  end
  if #list < 2 and o.workspaces and o.workspaces.workspace_id then
    local slot1 = o.workspaces.workspace_id(mon, 1)
    local slot2 = o.workspaces.workspace_id(mon, 2)
    add(active_id == slot1 and slot2 or slot1)
  end

  return list
end

local function step_workspace(step)
  local mon = hl.get_active_monitor()
  if not mon then
    return
  end

  if not ws_cycling or ws_cycle_mon ~= mon.name or #ws_cycle_list < 2 then
    ws_cycle_list = build_ws_cycle_list(mon)
    ws_cycle_mon = mon.name
    ws_cycle_index = 1
    ws_cycling = true
  end

  if #ws_cycle_list < 2 then
    return
  end

  ws_cycle_index = ((ws_cycle_index - 1 + step) % #ws_cycle_list) + 1
  local target_id = ws_cycle_list[ws_cycle_index]
  ws_cycle_target = target_id
  hl.dispatch(hl.dsp.focus({ workspace = tostring(target_id) }))
end

local function finish_ws_cycle()
  if not ws_cycling then
    return
  end
  ws_cycling = false
  local mon = ws_cycle_mon and hl.get_monitor(ws_cycle_mon) or hl.get_active_monitor()
  local ws = mon and mon.active_workspace
  local final_id = (ws and not ws.special and ws.id > 0 and ws.id) or ws_cycle_target
  if mon and final_id then
    record_ws(mon.name, final_id)
  end
  ws_cycle_target = nil
end

-- A plain release bind is skipped once Tab is released while Super is held.
-- Transparent and ignore_mods are what let this release still run. It is
-- non-consuming so Super keeps working for every other chord.
for _, key in ipairs({ "Super_L", "Super_R" }) do
  hl.bind(key, finish_ws_cycle, {
    release = true,
    transparent = true,
    ignore_mods = true,
    non_consuming = true,
  })
end

o.rebind("SUPER + TAB", "Next recent workspace", function()
  step_workspace(1)
end)
o.rebind("SUPER + SHIFT + TAB", "Previous recent workspace", function()
  step_workspace(-1)
end)

local win_mru = {}
local win_cycling = false
local win_cycle_ws = nil
local win_cycle_list = {}
local win_cycle_index = 1
local win_cycle_target = nil

local function record_win(addr)
  if not addr or addr == "" then
    return
  end
  for i = #win_mru, 1, -1 do
    if win_mru[i] == addr then
      table.remove(win_mru, i)
    end
  end
  table.insert(win_mru, 1, addr)
end

local function seed_win_mru()
  local wins = hl.get_windows({ mapped = true })
  table.sort(wins, function(a, b)
    return (a.focus_history_id or 9999) < (b.focus_history_id or 9999)
  end)
  for i = #wins, 1, -1 do
    if wins[i].address then
      record_win(wins[i].address)
    end
  end
end

seed_win_mru()

hl.on("window.active", function(win)
  if win_cycling or not win or not win.address then
    return
  end
  record_win(win.address)
end)

hl.on("window.destroy", function(win)
  if not win or not win.address then
    return
  end
  for i = #win_mru, 1, -1 do
    if win_mru[i] == win.address then
      table.remove(win_mru, i)
    end
  end
end)

local function build_win_cycle_list(ws_id)
  local wins = hl.get_windows({ workspace = ws_id, mapped = true })
  local by_addr = {}
  for _, w in ipairs(wins) do
    if w.address then
      by_addr[w.address] = w
    end
  end

  table.sort(wins, function(a, b)
    return (a.focus_history_id or 9999) < (b.focus_history_id or 9999)
  end)

  local list = {}
  local seen = {}
  local function add(addr)
    if addr and by_addr[addr] and not seen[addr] then
      seen[addr] = true
      table.insert(list, addr)
    end
  end

  local active = hl.get_active_window()
  if active and active.address then
    add(active.address)
  end

  for _, addr in ipairs(win_mru) do
    add(addr)
  end

  for _, w in ipairs(wins) do
    add(w.address)
  end

  return list
end

local function step_window(step)
  local ws = hl.get_active_workspace()
  if not ws then
    return
  end

  if not win_cycling or win_cycle_ws ~= ws.id or #win_cycle_list < 2 then
    win_cycle_list = build_win_cycle_list(ws.id)
    win_cycle_ws = ws.id
    win_cycle_index = 1
    win_cycling = true
  end

  if #win_cycle_list < 2 then
    return
  end

  win_cycle_index = ((win_cycle_index - 1 + step) % #win_cycle_list) + 1
  local target_addr = win_cycle_list[win_cycle_index]
  win_cycle_target = target_addr
  hl.dispatch(hl.dsp.focus({ window = "address:" .. target_addr }))
  hl.dispatch(hl.dsp.window.bring_to_top())
end

local function finish_win_cycle()
  if not win_cycling then
    return
  end
  win_cycling = false
  local win = hl.get_active_window()
  local final_addr = (win and win.address) or win_cycle_target
  if final_addr then
    record_win(final_addr)
  end
  win_cycle_target = nil
end

for _, key in ipairs({ "Alt_L", "Alt_R" }) do
  hl.bind(key, finish_win_cycle, {
    release = true,
    transparent = true,
    ignore_mods = true,
    non_consuming = true,
  })
end

o.rebind("ALT + TAB", "Focus on next recent window", function()
  step_window(1)
end)
o.rebind("ALT + SHIFT + TAB", "Focus on previous recent window", function()
  step_window(-1)
end)
