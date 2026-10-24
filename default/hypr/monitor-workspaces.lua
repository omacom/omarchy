-- Per-monitor workspaces: every monitor has its own workspaces 1-10, the way
-- Niri gives every output its own.
--
-- Hyprland numbers workspaces globally, so each monitor owns a block of ten:
-- the laptop panel 1-10, the next monitor 11-20, and so on. Super + 3 goes to
-- the third workspace in the focused monitor's block, and the bar labels each
-- monitor's workspaces 1-10.
--
-- A block belongs to the physical monitor, named by its make, model and serial.
-- The connector and Hyprland's monitor id would both be wrong: a dock renames
-- its connectors between plugs, and Hyprland hands a free id to whichever
-- display turns up next. The assignment lives in a state file, so a monitor
-- gets the same block every time it comes back, and the bar reads the same
-- file to know which block is its own.
--
-- Hyprland already moves an unplugged monitor's workspaces onto another one and
-- returns them when it comes back, as Niri does, but it recognizes the monitor
-- by its connector, and it puts a new monitor on the next free workspace number
-- rather than in its own block. Reconciling on every monitor change keeps each
-- monitor on its own block. Workspaces whose monitor is unplugged join the
-- block of the one they landed on, after its own, as Niri appends them to
-- another output, and a second state file remembers where each came from so it
-- goes back, under its old number, when that monitor returns. With no room in
-- the block they stay guests, and the bar lists them after the monitor's own.

local paths = require("default.hypr.paths")

local SLOTS = 10
local STATE_DIR = paths.state_home .. "/omarchy"
local STATE_FILE = STATE_DIR .. "/monitor-workspaces"
local MERGED_FILE = STATE_DIR .. "/monitor-workspaces-merged"

local M = { slots = SLOTS }

-- Identity -> block, kept across sessions.
local blocks = {}
local written = nil

-- Connector -> identity for the monitors plugged in now.
local current = {}

local function load_blocks()
  local file = io.open(STATE_FILE, "r")
  if not file then
    return
  end

  for line in file:lines() do
    local block, connector, identity = line:match("^(%d+)\t([^\t]*)\t(.+)$")
    if block then
      blocks[identity] = tonumber(block)
      if connector ~= "" then
        current[connector] = identity
      end
    end
  end

  file:close()
end

load_blocks()

-- Workspace id -> where it came from, { id, identity }, for each workspace that
-- joined another monitor's block while its own monitor was unplugged. Kept in a
-- file to outlive config reloads, and cleared when Hyprland starts.
local merged = {}

local function load_merged()
  local file = io.open(MERGED_FILE, "r")
  if not file then
    return
  end

  for line in file:lines() do
    local id, original, identity = line:match("^(%d+)\t(%d+)\t(.+)$")
    if id then
      merged[tonumber(id)] = { id = tonumber(original), identity = identity }
    end
  end

  file:close()
end

load_merged()

local function save_merged()
  local ids = {}
  for id in pairs(merged) do
    ids[#ids + 1] = id
  end
  table.sort(ids)

  local lines = {}
  for _, id in ipairs(ids) do
    lines[#lines + 1] = id .. "\t" .. merged[id].id .. "\t" .. merged[id].identity .. "\n"
  end

  local file = io.open(MERGED_FILE, "w")
  if not file then
    os.execute("mkdir -p " .. o.shell_quote(STATE_DIR))
    file = io.open(MERGED_FILE, "w")
  end

  if file then
    file:write(table.concat(lines))
    file:close()
  end
end

-- One line per monitor ever seen: its block, its connector while it is plugged
-- in, and its identity. The bar maps its own connector to a block from this.
local function save(monitors, identities)
  local connector = {}
  for _, monitor in ipairs(monitors) do
    connector[identities[monitor.name]] = monitor.name
  end

  local rows = {}
  for identity, block in pairs(blocks) do
    rows[#rows + 1] = { block = block, line = block .. "\t" .. (connector[identity] or "") .. "\t" .. identity }
  end
  table.sort(rows, function(left, right) return left.block < right.block end)

  local lines = {}
  for _, row in ipairs(rows) do
    lines[#lines + 1] = row.line
  end
  local content = table.concat(lines, "\n") .. "\n"

  if content == written then
    return
  end

  local file = io.open(STATE_FILE, "w")
  if not file then
    os.execute("mkdir -p " .. o.shell_quote(STATE_DIR))
    file = io.open(STATE_FILE, "w")
  end

  if file then
    file:write(content)
    file:close()
    written = content
  end
end

local function internal(monitor)
  return monitor.name:match("^eDP") or monitor.name:match("^LVDS") or monitor.name:match("^DSI")
end

-- The monitors that show workspaces of their own. `gone` names one Hyprland
-- still lists while it reports the monitor's removal.
local function connected(gone)
  local monitors = {}

  for _, monitor in ipairs(hl.get_monitors()) do
    if not monitor.is_mirror and monitor.name ~= gone then
      monitors[#monitors + 1] = monitor
    end
  end

  -- The laptop panel claims the first block, so a laptop keeps 1-10 on its own
  -- screen whatever is plugged in.
  table.sort(monitors, function(left, right)
    if (internal(left) ~= nil) ~= (internal(right) ~= nil) then
      return internal(left) ~= nil
    end
    return left.id < right.id
  end)

  return monitors
end

-- Make, model and serial. Two monitors that report the same, such as a pair
-- without serials, are told apart by connector order when they first appear,
-- and each keeps that identity while it stays plugged in, so unplugging one of
-- the pair doesn't hand its block to the other.
local function identities_of(monitors)
  local identities = {}
  local taken = {}

  local function described(monitor)
    local description = monitor.description or ""
    return description ~= "" and description or monitor.name
  end

  for _, monitor in ipairs(monitors) do
    local identity = current[monitor.name]
    if identity and not taken[identity] and identity:gsub(" #%d+$", "") == described(monitor) then
      identities[monitor.name] = identity
      taken[identity] = true
    end
  end

  local ordered = {}
  for _, monitor in ipairs(monitors) do
    ordered[#ordered + 1] = monitor
  end
  table.sort(ordered, function(left, right) return left.name < right.name end)

  for _, monitor in ipairs(ordered) do
    if not identities[monitor.name] then
      local identity = described(monitor)
      local count = 1
      while taken[identity] do
        count = count + 1
        identity = described(monitor) .. " #" .. count
      end
      identities[monitor.name] = identity
      taken[identity] = true
    end
  end

  current = identities

  return identities
end

local function free_block()
  local taken = {}
  for _, block in pairs(blocks) do
    taken[block] = true
  end

  local block = 0
  while taken[block] do
    block = block + 1
  end

  return block
end

-- Each connected monitor's block, assigning one to a monitor seen for the first
-- time. Keyed by connector.
local function assign(monitors)
  local identities = identities_of(monitors)
  local by_connector = {}

  for _, monitor in ipairs(monitors) do
    local identity = identities[monitor.name]
    if not blocks[identity] then
      blocks[identity] = free_block()
    end
    by_connector[monitor.name] = blocks[identity]
  end

  save(monitors, identities)

  return by_connector, identities
end

local function block_of_id(id)
  return (id - 1) // SLOTS
end

local function identity_of_block(block)
  for identity, owned in pairs(blocks) do
    if owned == block then
      return identity
    end
  end

  return nil
end

-- Give a workspace another id, carrying where it came from with it.
local function renumber(workspace, id)
  local old = workspace.id
  hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(old), id = id }))

  -- A record left under the new id belonged to a workspace that has gone.
  if merged[old] or merged[id] then
    merged[id] = merged[old]
    merged[old] = nil
    save_merged()
  end
end

local function owner(id, monitors, by_connector)
  if id < 1 then
    return nil
  end

  for _, monitor in ipairs(monitors) do
    if by_connector[monitor.name] == block_of_id(id) then
      return monitor
    end
  end

  return nil
end

local function regular(workspace)
  return workspace and not workspace.special and workspace.id > 0
end

-- The workspace id of a slot on a monitor.
function M.workspace_id(monitor, slot)
  local by_connector = assign(connected())
  return (by_connector[monitor.name] or 0) * SLOTS + slot
end

-- The workspace a monitor falls back to when what it shows isn't its own: the
-- lowest of its own already on it, or its first.
local function home(monitor, block)
  local best = nil

  for _, workspace in ipairs(hl.get_workspaces()) do
    if regular(workspace) and block_of_id(workspace.id) == block and workspace.monitor
      and workspace.monitor.name == monitor.name and (not best or workspace.id < best) then
      best = workspace.id
    end
  end

  return best or block * SLOTS + 1
end

-- Show a workspace on a monitor, bringing it over from another or creating it
-- there. Bringing it over is a move rather than a focus on the current monitor,
-- which swaps the two monitors' workspaces when it is visible over there.
local function show(monitor, id)
  local workspace = hl.get_workspace(id)

  if workspace and workspace.monitor and workspace.monitor.name ~= monitor.name then
    hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = monitor.name }))
    workspace = hl.get_workspace(id)
  end

  if workspace then
    monitor:set_workspace({ workspace = workspace.name })
  else
    hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
    hl.dispatch(hl.dsp.focus({ workspace = tostring(id) }))
  end
end

-- Moving a monitor's visible workspace away leaves Hyprland to fill the gap
-- with any workspace it finds, or a fresh one with the lowest free number, so
-- put the monitor back on one of its own.
local function settle(monitor, monitors, by_connector)
  local block = by_connector[monitor.name]
  local active = monitor.active_workspace

  if block and regular(active) and block_of_id(active.id) ~= block and owner(active.id, monitors, by_connector) then
    show(monitor, home(monitor, block))
  end
end

-- Bring a workspace of this monitor's block back from wherever an unplug left
-- it. Moving it explicitly, rather than focusing it on the current monitor,
-- keeps Hyprland from swapping the two monitors' workspaces when it is visible
-- over there.
local function reclaim(monitor, id)
  local workspace = hl.get_workspace(id)
  if not workspace or not workspace.monitor or workspace.monitor.name == monitor.name then
    return
  end

  local away = workspace.monitor
  hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = monitor.name }))

  local monitors = connected()
  settle(away, monitors, assign(monitors))
end

-- Renumber a workspace into a block, keeping its slot when that one is free and
-- taking the first free one otherwise. False when all ten are taken.
local function adopt(workspace, block)
  local wanted = block * SLOTS + (workspace.id - 1) % SLOTS + 1
  local candidates = { wanted }
  for slot = 1, SLOTS do
    candidates[#candidates + 1] = block * SLOTS + slot
  end

  for _, id in ipairs(candidates) do
    if not hl.get_workspace(id) then
      renumber(workspace, id)
      return true
    end
  end

  return false
end

-- The first free id after the highest of a block in use, as Niri appends an
-- unplugged output's workspaces after another's, or any free one in the block
-- when the last is taken. Nil when all ten are.
local function append_slot(block)
  local highest = block * SLOTS
  for _, workspace in ipairs(hl.get_workspaces()) do
    if regular(workspace) and block_of_id(workspace.id) == block and workspace.id > highest then
      highest = workspace.id
    end
  end

  if highest < block * SLOTS + SLOTS then
    return highest + 1
  end

  for id = block * SLOTS + 1, block * SLOTS + SLOTS do
    if not hl.get_workspace(id) then
      return id
    end
  end

  return nil
end

-- The bar names its monitor. After a hotplug its window can still hold the
-- screen that went away, so the name reaches here as one Hyprland no longer
-- has, or as its FALLBACK stand-in, and a click on a slot would do nothing
-- (#16351). A name that finds no monitor falls back to the focused one.
local function target_monitor(name)
  if name then
    local monitor = hl.get_monitor(name)
    if monitor then
      return monitor
    end
  end

  return hl.get_active_monitor()
end

-- Bind actions return functions for hl.dispatch, so `hyprctl dispatch
-- 'o.workspaces.focus(3)'` runs the same thing as the key. The keybindings menu
-- replays a bind through that expression.
local function action(fn, expression)
  o.bind_expressions[fn] = expression
  return fn
end

local function literal(value)
  if value == nil then
    return "nil"
  end
  return string.format("%q", value)
end

-- Go to a slot on a monitor, the focused one unless named.
function M.focus(slot, monitor_name)
  return action(function()
    local monitor = target_monitor(monitor_name)
    if not monitor then
      return
    end

    if not monitor.focused then
      hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
    end

    local id = M.workspace_id(monitor, slot)
    reclaim(monitor, id)
    hl.dispatch(hl.dsp.focus({ workspace = tostring(id) }))
  end, "o.workspaces.focus(" .. slot .. (monitor_name and ", " .. literal(monitor_name) or "") .. ")")
end

-- Move the active window to a slot on the focused monitor, following it unless
-- `follow` is false.
function M.move_window(slot, follow)
  return action(function()
    local window = hl.get_active_window()
    local monitor = hl.get_active_monitor()
    if not window or not monitor then
      return
    end

    local id = M.workspace_id(monitor, slot)
    reclaim(monitor, id)
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(id), follow = follow ~= false, window = "address:" .. window.address }))
  end, "o.workspaces.move_window(" .. slot .. (follow == false and ", false" or "") .. ")")
end

-- Move the active workspace to the monitor in a direction, where it joins that
-- monitor's block, under the same number when it is free. With all ten taken it
-- keeps its number and stays a guest until its own monitor wants it back.
function M.move_to_monitor(direction)
  return action(function()
    local workspace = hl.get_active_workspace()
    if not regular(workspace) then
      return
    end

    -- Hyprland reports a move toward no monitor as an error on screen.
    local target = hl.get_monitor(direction)
    if not target then
      return
    end

    local id = workspace.id
    local from = hl.get_active_monitor()
    hl.dispatch(hl.dsp.workspace.move({ monitor = target.name }))

    local moved = hl.get_workspace(id)
    if not moved or not moved.monitor or (from and moved.monitor.name == from.name) then
      return
    end

    -- Moved by hand, it belongs where it was put, as in Niri.
    if merged[id] then
      merged[id] = nil
      save_merged()
    end

    local monitors = connected()
    local by_connector = assign(monitors)
    local block = by_connector[moved.monitor.name]
    if block and block_of_id(id) ~= block then
      adopt(moved, block)
    end
    if from then
      settle(from, monitors, by_connector)
    end

    -- Settling the monitor it left can take focus; it belongs with the
    -- workspace that moved.
    hl.dispatch(hl.dsp.focus({ workspace = tostring(moved.id) }))
  end, "o.workspaces.move_to_monitor(" .. literal(direction) .. ")")
end

-- Move the focused window onto the workspace the monitor in that direction
-- shows, and follow it there.
function M.move_window_to_monitor(direction)
  return action(function()
    local target = hl.get_monitor(direction)
    if target then
      hl.dispatch(hl.dsp.window.move({ monitor = target.name }))
    end
  end, "o.workspaces.move_window_to_monitor(" .. literal(direction) .. ")")
end

-- Put every workspace whose monitor is plugged in back on it, and every monitor
-- on a workspace of its own. `added` names a monitor that just arrived, which
-- leaves whatever Hyprland put it on; `gone` one being removed.
function M.reconcile(added, gone)
  local monitors = connected(gone)
  if #monitors == 0 then
    return
  end

  local by_connector, identities = assign(monitors)
  local focused_window = hl.get_active_window()
  local focused_monitor = hl.get_active_monitor()
  local focused_name = focused_monitor and focused_monitor.name
  local changed = false

  local function own_views()
    for _, monitor in ipairs(monitors) do
      local block = by_connector[monitor.name]
      local active = monitor.active_workspace
      local own = regular(active) and block_of_id(active.id) == block

      -- A workspace whose monitor is unplugged stays in view where it was put,
      -- unless this monitor has only just arrived on it. An empty one is only
      -- the number Hyprland starts a monitor on.
      local guest = regular(active) and not owner(active.id, monitors, by_connector) and monitor.name ~= added
        and (active.windows or 0) > 0

      if not own and not guest then
        show(monitor, home(monitor, block))
        changed = true
      end
    end
  end

  -- A workspace sitting on a monitor other than the plugged-in one that owns it
  -- goes home when a monitor arrives, since that is a monitor returning to the
  -- workspaces an unplug left elsewhere. Otherwise it is one that got there some
  -- other way, such as a session from before workspaces were per monitor or a
  -- window rule naming a number, and it joins the block of the monitor it is
  -- on, so its windows don't jump screens. An empty one is only the number
  -- Hyprland parked a monitor on, and goes away once the monitor shows its own.
  local function place()
    for _, workspace in ipairs(hl.get_workspaces()) do
      if regular(workspace) and workspace.monitor and (workspace.windows or 0) > 0 then
        local home_monitor = owner(workspace.id, monitors, by_connector)
        if home_monitor and home_monitor.name ~= workspace.monitor.name then
          local here = by_connector[workspace.monitor.name]
          if added or not here or not adopt(workspace, here) then
            hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(workspace.id), monitor = home_monitor.name }))
          end
          changed = true
        end
      end
    end
  end

  -- Workspaces that joined another monitor's block while theirs was unplugged
  -- go back to it, under their old numbers when those are free.
  local function restore()
    local ids = {}
    for id in pairs(merged) do
      ids[#ids + 1] = id
    end
    table.sort(ids)

    for _, id in ipairs(ids) do
      local origin = merged[id]
      local monitor = nil
      for _, candidate in ipairs(monitors) do
        if identities[candidate.name] == origin.identity then
          monitor = candidate
        end
      end

      if monitor then
        merged[id] = nil
        save_merged()

        local workspace = hl.get_workspace(id)
        if regular(workspace) then
          if not workspace.monitor or workspace.monitor.name ~= monitor.name then
            hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = monitor.name }))
          end

          if block_of_id(origin.id) == by_connector[monitor.name] and not hl.get_workspace(origin.id) then
            renumber(workspace, origin.id)
          elseif block_of_id(id) ~= by_connector[monitor.name] then
            adopt(workspace, by_connector[monitor.name])
          end
          changed = true
        end
      end
    end
  end

  -- A workspace whose monitor is unplugged joins the block of the monitor it
  -- waits on, after that monitor's own, and remembers where it came from. An
  -- empty one is left to go away, and one with no room stays a guest.
  local function merge()
    local guests = {}
    for _, workspace in ipairs(hl.get_workspaces()) do
      if regular(workspace) and workspace.monitor and (workspace.windows or 0) > 0
        and not owner(workspace.id, monitors, by_connector) and by_connector[workspace.monitor.name] then
        guests[#guests + 1] = workspace
      end
    end
    table.sort(guests, function(left, right) return left.id < right.id end)

    for _, workspace in ipairs(guests) do
      local old = workspace.id
      local id = append_slot(by_connector[workspace.monitor.name])
      if id then
        -- One merged before keeps the monitor it first came from.
        local origin = merged[old]
        local identity = identity_of_block(block_of_id(old))
        if not origin and identity then
          merged[old] = { id = old, identity = identity }
        end
        renumber(workspace, id)
        save_merged()
        changed = true
      end
    end
  end

  restore()

  -- Views first for a new monitor, so the number Hyprland gave it is left empty
  -- and goes away instead of being carried to the monitor that owns it.
  if added then
    own_views()
  end
  place()
  merge()

  -- Moving a visible workspace home leaves a gap Hyprland fills with anything.
  own_views()

  if changed then
    if focused_window and hl.get_window("address:" .. focused_window.address) then
      hl.dispatch(hl.dsp.focus({ window = "address:" .. focused_window.address }))
    elseif focused_name and focused_name ~= gone and hl.get_monitor(focused_name) then
      hl.dispatch(hl.dsp.focus({ monitor = focused_name }))
    end
  end
end

hl.on("hyprland.start", function()
  -- Windows don't outlive a session, so neither do the workspaces that held them.
  merged = {}
  save_merged()
  M.reconcile()
end)

-- A workspace created under a remembered number is a new one; the one that
-- came from elsewhere has gone.
hl.on("workspace.created", function(workspace)
  if workspace and merged[workspace.id] then
    merged[workspace.id] = nil
    save_merged()
  end
end)

hl.on("config.reloaded", function()
  M.reconcile()
end)

hl.on("monitor.added", function(monitor)
  M.reconcile(monitor and monitor.name)
end)

hl.on("monitor.removed", function(monitor)
  M.reconcile(nil, monitor and monitor.name)
end)

o.workspaces = M

return M
