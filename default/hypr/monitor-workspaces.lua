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
-- The monitor comes back showing that same workspace, not the empty one
-- Hyprland starts a new output on. Hyprland's FALLBACK placeholder is not a
-- monitor and never takes a block.

local paths = require("default.hypr.paths")

local SLOTS = 10
local STATE_DIR = paths.state_home .. "/omarchy/monitors"
local STATE_FILE = STATE_DIR .. "/workspaces"
local MERGED_FILE = STATE_DIR .. "/workspaces-merged"
local SHOWN_FILE = STATE_DIR .. "/workspaces-shown"

local M = { slots = SLOTS }

-- Identity -> block, kept across sessions.
local blocks = {}
local written = nil

-- Connector -> identity for the monitors plugged in now.
local current = {}

-- Identity -> the connector it was last seen on, including while unplugged.
-- Two monitors with one description stay Twin and Twin #2 by this, whichever
-- of them is plugged back first. The state file's connector column stays empty
-- while a monitor is unplugged, so the bar does not keep that block on the port.
local last_connector = {}

local function load_blocks()
  local file = io.open(STATE_FILE, "r")
  if not file then
    return
  end

  for line in file:lines() do
    local block, connector, identity, remembered = line:match("^(%d+)\t([^\t]*)\t([^\t]+)\t([^\t]*)$")
    if not block then
      block, connector, identity = line:match("^(%d+)\t([^\t]*)\t(.+)$")
    end
    -- A block saved for FALLBACK is the placeholder, not a monitor.
    if block and identity ~= "FALLBACK" then
      blocks[identity] = tonumber(block)
      if connector ~= "" then
        current[connector] = identity
        last_connector[identity] = connector
      end
      if remembered and remembered ~= "" then
        last_connector[identity] = remembered
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

-- Identity -> { id, away }. The workspace that monitor was showing. `away` holds
-- the id while it is unplugged, so the empty workspace Hyprland starts a
-- returning monitor on doesn't replace it. Kept in a file to outlive a reload
-- between the unplug and the return.
local shown = {}

-- Connector -> number of times it has been added. A monitor.removed timer
-- captured the previous number; a later add makes that timer stale.
local removal_generation = {}
-- Connector -> generation captured when its removal timer was scheduled.
-- Equal to removal_generation until that timer runs or a replug advances it.
local removal_scheduled = {}

-- Identity -> guest workspace id currently being viewed on this monitor.
-- Cleared once it shows one of its own workspaces again, so when that guest
-- returns to its owner, this monitor restores its remembered view instead of
-- staying on whatever workspace (own or another guest) Hyprland plugged in.
local showing_guest = {}
local reconciling = false
local awaiting_reload = true
-- Identity -> own workspace ids seen via workspace.active while online, mapped
-- to the order they arrived, before the 1ms confirmation timer ran. A
-- disconnect keeps the latest occupied id, not the highest number. The
-- connector a monitor departed from is separate. If a native workspace switch
-- races an unplug before the timer fires and Hyprland restores that exact
-- workspace on the same connector, own_views keeps it instead of reverting to
-- the pre-switch record.
local pending_active = {}
local pending_evacuated = {}
-- Identity -> true when a native switch left a visitor but the 1ms timer has
-- not confirmed it. The visitor record stays so a reconnect gap plug is not
-- saved as the user's workspace. An unfocused teardown can still promote the
-- pending switch.
local pending_guest_leave = {}
local away_connector = {}

local shown_written = nil
local note_shown

local function load_shown()
  local file = io.open(SHOWN_FILE, "r")
  if not file then
    return
  end

  local content = {}
  for line in file:lines() do
    local id, away, identity, guest, connector, pending_csv =
      line:match("^(%d+)\t([01])\t([^\t]+)\t([^\t]*)\t([^\t]*)\t([^\t]*)$")
    if not id then
      id, away, identity = line:match("^(%d+)\t([01])\t(.+)$")
    end
    if id then
      shown[identity] = { id = tonumber(id), away = away == "1" }
      if guest and guest ~= "" then
        showing_guest[identity] = tonumber(guest)
      end
      if connector and connector ~= "" then
        away_connector[identity] = connector
      end
      if pending_csv and pending_csv ~= "" then
        local pending = {}
        local seq = 0
        for pending_id in pending_csv:gmatch("%d+") do
          seq = seq + 1
          pending[tonumber(pending_id)] = seq
        end
        if next(pending) ~= nil then
          pending_active[identity] = pending
        end
      end
      content[#content + 1] = line .. "\n"
    end
  end

  file:close()
  shown_written = table.concat(content)
end

load_shown()

-- Replace the file only after a complete write. open("w") truncates first, so a
-- failed write or close would leave an empty file and, if the cache were
-- updated anyway, the next save would not try again.
local function write_atomic(path, content)
  local temporary = path .. ".tmp"
  local file = io.open(temporary, "w")
  if not file then
    os.execute("mkdir -p " .. o.shell_quote(STATE_DIR))
    file = io.open(temporary, "w")
  end
  if not file then
    return false
  end

  local written = file:write(content)
  if not written then
    file:close()
    os.remove(temporary)
    return false
  end

  local closed = file:close()
  if not closed then
    os.remove(temporary)
    return false
  end

  if not os.rename(temporary, path) then
    os.remove(temporary)
    return false
  end

  return true
end

local function save_shown()
  local identities = {}
  for identity in pairs(shown) do
    identities[#identities + 1] = identity
  end
  table.sort(identities)

  local lines = {}
  for _, identity in ipairs(identities) do
    local record = shown[identity]
    local guest = showing_guest[identity]
    local connector = away_connector[identity]
    local pending = pending_active[identity]
    local pending_ids = {}
    if pending then
      for pending_id in pairs(pending) do
        pending_ids[#pending_ids + 1] = pending_id
      end
      table.sort(pending_ids, function(left, right)
        local left_seq = pending[left]
        local right_seq = pending[right]
        if left_seq == right_seq then
          return left < right
        end
        return left_seq < right_seq
      end)
    end
    local line = record.id .. "\t" .. (record.away and "1" or "0") .. "\t" .. identity
    if guest or connector or #pending_ids > 0 then
      line = line .. "\t" .. (guest or "") .. "\t" .. (connector or "") .. "\t" .. table.concat(pending_ids, ",")
    end
    lines[#lines + 1] = line .. "\n"
  end
  local content = table.concat(lines)
  if content == shown_written then
    return
  end

  if write_atomic(SHOWN_FILE, content) then
    shown_written = content
  end
end

-- One line per monitor ever seen: its block, its connector while it is plugged
-- in, and its identity. The bar maps its own connector to a block from this.
-- While it is unplugged the connector column stays empty, and a fourth field
-- remembers the port so two identical monitors can be told apart on the way back.
local function save(monitors, identities)
  local connector = {}
  for _, monitor in ipairs(monitors) do
    local identity = identities[monitor.name]
    connector[identity] = monitor.name
    last_connector[identity] = monitor.name
  end

  local rows = {}
  for identity, block in pairs(blocks) do
    local live = connector[identity] or ""
    local line = block .. "\t" .. live .. "\t" .. identity
    local remembered = last_connector[identity]
    if remembered and remembered ~= live then
      line = line .. "\t" .. remembered
    end
    rows[#rows + 1] = { block = block, line = line }
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
-- still lists while it reports the monitor's removal. FALLBACK is the
-- placeholder Hyprland leaves when nothing is plugged in: it shows nothing of
-- its own, and a block for it would sit in the state file forever.
local function connected(gone)
  local monitors = {}

  for _, monitor in ipairs(hl.get_monitors()) do
    if not monitor.is_mirror and monitor.name ~= gone and monitor.name ~= "FALLBACK" then
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
-- the pair doesn't hand its block to the other. The connector each was last
-- seen on breaks the tie when they come back in a different order. A monitor
-- that comes back alone on a new port still takes the one identity that matches.
local function identities_of(monitors)
  local identities = {}
  local taken = {}

  local function described(monitor)
    local description = monitor.description or ""
    return description ~= "" and description or monitor.name
  end

  local function same(identity, monitor)
    return identity:gsub(" #%d+$", "") == described(monitor)
  end

  local function claim(monitor, identity)
    identities[monitor.name] = identity
    taken[identity] = true
    last_connector[identity] = monitor.name
  end

  for _, monitor in ipairs(monitors) do
    local identity = current[monitor.name]
    if identity and not taken[identity] and same(identity, monitor) then
      claim(monitor, identity)
    end
  end

  for _, monitor in ipairs(monitors) do
    if not identities[monitor.name] then
      local match = nil
      for identity, connector in pairs(last_connector) do
        if connector == monitor.name and not taken[identity] and same(identity, monitor) then
          match = identity
          break
        end
      end
      if match then
        claim(monitor, match)
      end
    end
  end

  local ordered = {}
  for _, monitor in ipairs(monitors) do
    ordered[#ordered + 1] = monitor
  end
  table.sort(ordered, function(left, right) return left.name < right.name end)

  for _, monitor in ipairs(ordered) do
    if not identities[monitor.name] then
      local base = described(monitor)
      local saved = {}
      for identity in pairs(blocks) do
        if not taken[identity] and identity:gsub(" #%d+$", "") == base then
          saved[#saved + 1] = identity
        end
      end
      table.sort(saved)

      -- One monitor, moved to a port we have not seen: it is that monitor.
      if #saved == 1 then
        claim(monitor, saved[1])
      else
        local identity = base
        local count = 1
        while taken[identity] do
          count = count + 1
          identity = base .. " #" .. count
        end
        claim(monitor, identity)
      end
    end
  end

  current = identities

  return identities
end

-- Each connected monitor's identity, keyed by connector, for settings that
-- belong to the physical monitor rather than the port (see monitor-settings).
function M.identities()
  return identities_of(connected())
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
local function renumber(workspace, id, host_identity)
  local old = workspace.id
  hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(old), id = id }))

  if host_identity and showing_guest[host_identity] == old then
    showing_guest[host_identity] = id
  end

  -- Carry this workspace's origin onto its new id. A record only under the new
  -- id belonged to a workspace that has gone. Assigning `merged[old]` when that
  -- is nil would delete an origin the restore loop has not visited yet.
  if merged[old] then
    merged[id] = merged[old]
    merged[old] = nil
    save_merged()
  elseif merged[id] then
    merged[id] = nil
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

-- An empty persistent workspace is one the user kept. Treat it as occupied
-- wherever a placeholder with no windows would otherwise be ignored.
local function occupied_or_persistent(workspace)
  return ((workspace.windows or 0) > 0) or (workspace.is_persistent == true)
end

-- A workspace that joined this monitor's block while its own monitor was
-- unplugged, or sits here as a guest outside this monitor's own block. It is
-- on screen here, but it is not the workspace this monitor was showing.
local function visiting(id, identity)
  if not id then
    return false
  end
  local origin = merged[id]
  if origin and origin.identity ~= identity then
    return true
  end
  local block = blocks[identity]
  return block ~= nil and block_of_id(id) ~= block
end

-- The workspace id of a slot on a monitor.
function M.workspace_id(monitor, slot)
  local by_connector = assign(connected())
  return (by_connector[monitor.name] or 0) * SLOTS + slot
end

-- The workspace a monitor falls back to when what it shows isn't its own. The
-- one it was showing before it left comes first, once that workspace is back
-- on it. A monitor that just came back would otherwise sit on the empty
-- workspace Hyprland starts an output on, so one of its own that has windows
-- beats that. Otherwise the lowest of its own already on it, or its first.
local function home(monitor, block, arriving, identity)
  identity = identity or current[monitor.name]
  local record = identity and shown[identity]

  if record and block_of_id(record.id) == block then
    local workspace = hl.get_workspace(record.id)
    if regular(workspace) and workspace.monitor and workspace.monitor.name == monitor.name
      and not visiting(workspace.id, identity) then
      -- An empty non-persistent workspace under the saved number, on a monitor
      -- that is away, is the one Hyprland just started it on. The workspace it
      -- left is gone. A persistent empty workspace is the one the user kept.
      if (workspace.windows or 0) > 0 or workspace.is_persistent or not (arriving and record.away) then
        return record.id
      end
    end
  end

  local best = nil
  local occupied = nil

  for _, workspace in ipairs(hl.get_workspaces()) do
    if regular(workspace) and block_of_id(workspace.id) == block and workspace.monitor
      and workspace.monitor.name == monitor.name and not visiting(workspace.id, identity) then
      if not best or workspace.id < best then
        best = workspace.id
      end
      if (workspace.windows or 0) > 0 and (not occupied or workspace.id < occupied) then
        occupied = workspace.id
      end
    end
  end

  if arriving and occupied then
    return occupied
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
  if not workspace or (workspace.monitor and workspace.monitor.name == monitor.name) then
    return
  end

  local away = workspace.monitor
  hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = monitor.name }))

  if away then
    local monitors = connected()
    settle(away, monitors, assign(monitors))
  end
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
      return id
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

local function target_monitor(name)
  if name then
    return hl.get_monitor(name)
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
    note_shown(hl.get_monitor(monitor.name))
  end, "o.workspaces.focus(" .. slot .. (monitor_name and ", " .. literal(monitor_name) or "") .. ")")
end

-- Step to another workspace on the focused monitor (m+1, m-1,
-- previous_per_monitor) and record the new view immediately so a fast unplug
-- cannot race the workspace.active timer.
function M.step(spec)
  return action(function()
    hl.dispatch(hl.dsp.focus({ workspace = spec }))
    note_shown(hl.get_active_monitor())
  end, "o.workspaces.step(" .. literal(spec) .. ")")
end

-- Move the active window to a relative workspace (r-1, r+1) and follow it,
-- recording the new view immediately so a fast unplug cannot race the
-- workspace.active timer.
function M.step_window(spec)
  return action(function()
    hl.dispatch(hl.dsp.window.move({ workspace = spec }))
    note_shown(hl.get_active_monitor())
  end, "o.workspaces.step_window(" .. literal(spec) .. ")")
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
    if follow ~= false then
      note_shown(hl.get_monitor(monitor.name))
    end
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
    note_shown(hl.get_monitor(moved.monitor.name))
    if from then
      note_shown(hl.get_monitor(from.name))
    end
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
local function reconcile_body(added, gone)
  local monitors = connected(gone)
  if #monitors == 0 then
    -- Nothing is plugged in, so there is nowhere to merge into. Remember which
    -- monitor each workspace came from and leave its number until that monitor
    -- returns. Merging into FALLBACK would only renumber them.
    local remembered = false
    for _, workspace in ipairs(hl.get_workspaces()) do
      if regular(workspace) and occupied_or_persistent(workspace) and not merged[workspace.id] then
        local identity = identity_of_block(block_of_id(workspace.id))
        if identity then
          merged[workspace.id] = { id = workspace.id, identity = identity }
          remembered = true
        end
      end
    end
    if remembered then
      save_merged()
    end
    -- No monitor is left to assign, but the online connector column still has
    -- to be cleared. The last connector stays, so each monitor gets its block
    -- back, and the workspace it was showing stays recorded. Drop the
    -- in-memory connector map too: the ports are offline, and a gap plug on
    -- the way back must not look like a switch on a monitor that is still
    -- assigned. last_connector and away_connector keep the port history.
    current = {}
    save({}, {})
    save_shown()
    return
  end

  local by_connector, identities = assign(monitors)
  local focused_window = hl.get_active_window()
  local focused_monitor = hl.get_active_monitor()
  local focused_name = focused_monitor and focused_monitor.name
  local changed = false
  local returned_home = {}
  local arrived_pending = {}
  for _, monitor in ipairs(monitors) do
    local identity = identities[monitor.name]
    local record = identity and shown[identity]
    local pending = identity and pending_active[identity]
    local active = monitor.active_workspace
    if record and record.away and pending and regular(active) and occupied_or_persistent(active)
      and away_connector[identity] == monitor.name then
      local origin = merged[active.id]
      local original_id = (origin and origin.identity == identity) and origin.id or active.id
      if block_of_id(original_id) == by_connector[monitor.name] and pending[original_id] then
        arrived_pending[identity] = active.id
      end
    end
  end

  local function own_views()
    for _, monitor in ipairs(monitors) do
      local block = by_connector[monitor.name]
      local active = monitor.active_workspace
      local identity = identities[monitor.name]
      local record = identity and shown[identity]
      local arriving = monitor.name == added or (record and record.away)
      local own = regular(active) and block_of_id(active.id) == block

      -- A workspace whose monitor is unplugged stays in view where it was put,
      -- unless this monitor has only just arrived on it. An empty non-persistent
      -- one is only the number Hyprland starts a monitor on.
      local guest = regular(active) and not owner(active.id, monitors, by_connector) and monitor.name ~= added
        and occupied_or_persistent(active)

      -- The empty workspace a returning monitor is started on sits in its own
      -- block when that block is the first, so it looks like one of its own.
      -- A persistent workspace the user saved is not that placeholder.
      local saved_persistent = regular(active) and active.is_persistent and record and record.id == active.id
      -- A persistent empty workspace Hyprland restored from a native switch is
      -- arrived_pending, not the placeholder a returning monitor is started on.
      if own and arriving and (active.windows or 0) == 0 and not saved_persistent
        and arrived_pending[identity] ~= active.id
        and home(monitor, block, true, identity) ~= active.id then
        own = false
      end

      -- The workspace left in view while this monitor was unplugged can already
      -- be active on the way back. The one it was showing still wins when that
      -- one came back with windows, unless Hyprland itself restored a native
      -- switch whose 1ms confirmation timer raced the disconnect.
      if own and record and record.away and arrived_pending[identity] ~= active.id then
        local wanted = home(monitor, block, true, identity)
        if wanted ~= active.id then
          local workspace = hl.get_workspace(wanted)
          if workspace and occupied_or_persistent(workspace) then
            own = false
          end
        end
      end

      -- When this monitor was showing a specific visiting guest that has now
      -- left (moved by Hyprland on plug or by restore()/place()), Hyprland
      -- fills the gap with another workspace (own or another offline guest).
      -- Restore this monitor's remembered view, while leaving the same guest
      -- in view when an unrelated monitor changes.
      local viewed_guest = showing_guest[identity]
      local viewed_guest_ws = viewed_guest and hl.get_workspace(viewed_guest)
      local viewed_guest_still_here = viewed_guest_ws and regular(viewed_guest_ws)
        and viewed_guest_ws.monitor and viewed_guest_ws.monitor.name == monitor.name
      if viewed_guest and (not regular(active) or active.id ~= viewed_guest)
        and not viewed_guest_still_here
        and record and block_of_id(record.id) == block then
        local wanted = home(monitor, block, false, identity)
        if not regular(active) or wanted ~= active.id then
          own = false
          guest = false
        end
      end

      -- When this monitor's remembered workspace was temporarily pulled onto
      -- another monitor (e.g. Hyprland connector memory when another output
      -- reconnects) and restore()/place() just returned it here, bring it back
      -- into view instead of accepting Hyprland's fallback workspace, unless
      -- this monitor is actively viewing a still-present guest workspace or
      -- the user already switched this online monitor natively before the 1ms
      -- workspace.active timer settled.
      local keeping_guest = viewed_guest and regular(active) and active.id == viewed_guest
      -- A pending id recorded while a visitor was still on this monitor is
      -- Hyprland's gap plug when that visitor has since left. It is not a
      -- confirmed user switch, so it must not keep the fallback in view.
      local switched_online = pending_active[identity] and regular(active) and pending_active[identity][active.id]
        and not (viewed_guest and not viewed_guest_still_here)
      if returned_home[identity] and record and block_of_id(record.id) == block
        and not keeping_guest and not switched_online and (not regular(active) or active.id ~= record.id) then
        if home(monitor, block, false, identity) == record.id then
          own = false
          guest = false
        end
      end

      if not own and not guest then
        show(monitor, home(monitor, block, arriving, identity))
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
      if regular(workspace) and workspace.monitor and occupied_or_persistent(workspace) then
        local home_monitor = owner(workspace.id, monitors, by_connector)
        if home_monitor and home_monitor.name ~= workspace.monitor.name then
          local here = by_connector[workspace.monitor.name]
          if added or not here or not adopt(workspace, here) then
            local host = workspace.monitor
            local host_active = host and host.active_workspace
            if host and host_active and host_active.id == workspace.id and identities[host.name] then
              showing_guest[identities[host.name]] = workspace.id
            end
            local home_identity = identities[home_monitor.name]
            if home_identity and shown[home_identity] and not shown[home_identity].away
              and shown[home_identity].id == workspace.id then
              returned_home[home_identity] = true
            end
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
      if origin then
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
              local host = workspace.monitor
              local host_active = host and host.active_workspace
              if host and host_active and host_active.id == workspace.id and identities[host.name] then
                showing_guest[identities[host.name]] = workspace.id
              end
              local home_identity = identities[monitor.name]
              if home_identity and shown[home_identity] and not shown[home_identity].away
                and (shown[home_identity].id == origin.id or shown[home_identity].id == workspace.id) then
                returned_home[home_identity] = true
              end
              hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = monitor.name }))
            end

            -- The number it had is free, or held only by the empty workspace
            -- Hyprland started this monitor on. That one gives the number back.
            local final_id = workspace.id
            if block_of_id(origin.id) == by_connector[monitor.name] then
              local occupant = hl.get_workspace(origin.id)
              if occupant and occupant.id ~= workspace.id and not occupied_or_persistent(occupant) and not merged[origin.id] then
                -- A free number that is still a merged key belongs to a workspace
                -- this loop has not restored. Parking here would rename that
                -- record away, or delete it.
                local park = 1
                while hl.get_workspace(park) or merged[park] do
                  park = park + 1
                end
                renumber(occupant, park)
                occupant = nil
              end
              if not occupant or occupant.id == workspace.id then
                if workspace.id ~= origin.id then
                  renumber(workspace, origin.id)
                  final_id = origin.id
                end
              elseif block_of_id(workspace.id) ~= by_connector[monitor.name] then
                final_id = adopt(workspace, by_connector[monitor.name]) or final_id
              end
            elseif block_of_id(workspace.id) ~= by_connector[monitor.name] then
              final_id = adopt(workspace, by_connector[monitor.name]) or final_id
            end
            if final_id ~= origin.id and block_of_id(final_id) == by_connector[monitor.name] then
              if shown[origin.identity] and shown[origin.identity].away and shown[origin.identity].id == origin.id then
                shown[origin.identity].id = final_id
                save_shown()
              end
              if arrived_pending[origin.identity] == origin.id then
                arrived_pending[origin.identity] = nil
              end
            end
            if arrived_pending[origin.identity] == id then
              arrived_pending[origin.identity] = final_id
            end
            changed = true
          end
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
        renumber(workspace, id, identities[workspace.monitor.name])
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
    local window = focused_window and hl.get_window("address:" .. focused_window.address)
    local workspace_id = window and window.workspace and (window.workspace.id or window.workspace)
    local workspace = workspace_id and hl.get_workspace(workspace_id)
    local showing = workspace and workspace.monitor and workspace.monitor.active_workspace
    -- Focusing the window Hyprland had active switches to its workspace. On a
    -- monitor that just came back, that workspace is the one left in view while
    -- it was gone, not the one it was showing.
    if window and showing and showing.id == workspace_id then
      hl.dispatch(hl.dsp.focus({ window = "address:" .. focused_window.address }))
    elseif focused_name and focused_name ~= gone and hl.get_monitor(focused_name) then
      hl.dispatch(hl.dsp.focus({ monitor = focused_name }))
    end
  end

  -- The monitor is plugged in again, so the workspace it was showing before it
  -- left is no longer a reason to pull it back. Leaving `away` set made a later
  -- switch to an empty workspace jump back there on reload.
  for _, monitor in ipairs(monitors) do
    local identity = identities[monitor.name]
    if identity then
      pending_active[identity] = nil
      pending_evacuated[identity] = nil
      pending_guest_leave[identity] = nil
      away_connector[identity] = nil
      local active = monitor.active_workspace
      -- A workspace merged from another monitor is only visiting. Recording it
      -- would forget the workspace this monitor was showing when it too unplugs.
      if regular(active) and not visiting(active.id, identity) then
        showing_guest[identity] = nil
        shown[identity] = { id = active.id, away = false }
      else
        if regular(active) and visiting(active.id, identity) then
          showing_guest[identity] = active.id
        end
        if shown[identity] then
          shown[identity].away = false
        end
      end
    end
  end
  save_shown()
end

function M.reconcile(added, gone)
  reconciling = true
  local ok, err = pcall(reconcile_body, added, gone)
  reconciling = false
  if not ok then
    error(err, 0)
  end
end

local function has_unassigned_monitor()
  for _, mon in ipairs(connected()) do
    if not current[mon.name] then
      return true
    end
  end
  return false
end

-- The connector that owns this workspace, and whether its removal timer has
-- not run yet. Hyprland 0.56.2 gap-plugs the survivor before inserting the
-- returning monitor into the monitor list (MonitorState adds it on
-- monitor.added), so hl.get_monitors() does not show it during workspace.active.
local function owner_removal_pending(id)
  if not id then
    return false
  end
  local origin = merged[id]
  local owner_identity = origin and origin.identity or identity_of_block(block_of_id(id))
  if not owner_identity then
    return false
  end
  local connector = last_connector[owner_identity]
  for name, identity in pairs(current) do
    if identity == owner_identity then
      connector = name
    end
  end
  if not connector or removal_scheduled[connector] == nil then
    return false
  end
  return removal_scheduled[connector] == (removal_generation[connector] or 0)
end

-- Record id as the latest native target for this monitor. False when it
-- already is the latest, so a repeated event does not rewrite the state file.
local function touch_pending(identity, id)
  local pending = pending_active[identity]
  if not pending then
    pending = {}
    pending_active[identity] = pending
  end
  local best = 0
  for _, seq in pairs(pending) do
    if type(seq) == "number" and seq > best then
      best = seq
    end
  end
  if pending[id] == best and best > 0 then
    return false
  end
  pending[id] = best + 1
  return true
end

-- The most recently arrived pending workspace that still has windows.
-- allow_guest keeps a visiting id; the sole-monitor scan rejects those.
local function latest_pending(identity, allow_guest)
  local pending = pending_active[identity]
  if not pending then
    return nil
  end
  local candidate, best = nil, 0
  for pid, seq in pairs(pending) do
    local order = type(seq) == "number" and seq or 0
    local pws = hl.get_workspace(pid)
    if order > best and regular(pws) and occupied_or_persistent(pws)
      and (allow_guest or not visiting(pid, identity)) then
      candidate, best = pid, order
    end
  end
  return candidate
end

local function guest_departed(prev_id, host_name)
  if not prev_id then
    return false
  end
  local prev_ws = hl.get_workspace(prev_id)
  if not regular(prev_ws) or not prev_ws.monitor or prev_ws.monitor.name ~= host_name then
    return true
  end
  -- The visitor's monitor pointer can still name this host when Hyprland
  -- emits workspace.active for the fallback. The returning monitor is not in
  -- hl.get_monitors() until monitor.added. has_unassigned_monitor() is false
  -- then. owner_removal_pending covers that reconnect; guest_left uses it.
  -- This check stays the pointer move only, so a switch onto another guest
  -- during the same window is still recorded.
  return has_unassigned_monitor()
end

local function guest_left(prev_id, host_name)
  return guest_departed(prev_id, host_name) or owner_removal_pending(prev_id)
end

local function mark_away(monitor)
  if not monitor or not monitor.name or monitor.name == "FALLBACK" then
    return
  end

  local identity = current[monitor.name]
  if not identity then
    return
  end

  local active = monitor.active_workspace
  local active_id = regular(active) and active.id
  if visiting(active_id, identity) then
    active_id = nil
  end
  -- Hyprland v0.56.2 clears the departing monitor's active_workspace before
  -- emitting monitor.removed, after moving its active workspace onto a
  -- surviving backup monitor and activating it there when the departing
  -- monitor had focus (WorkspacePlacementController.cpp:328-342). If a native
  -- switch raced the unplug before the 1ms confirmation timer, promote that
  -- evacuated workspace into `shown` now so it survives host switches and
  -- config reloads while this monitor is offline.
  local promoted = false
  local kept_guest = false
  local others = connected(monitor.name)
  local viewed_guest = showing_guest[identity]
  if #others > 0 and viewed_guest then
    for _, other in ipairs(others) do
      local other_active = other.active_workspace
      if regular(other_active) and other_active.id == viewed_guest then
        kept_guest = true
        break
      end
    end
  end
  if not active_id and #others > 0 and not kept_guest then
    local shown_id = shown[identity] and shown[identity].id
    for _, other in ipairs(others) do
      local other_active = other.active_workspace
      if regular(other_active) and not visiting(other_active.id, identity)
        and ((pending_active[identity] and pending_active[identity][other_active.id])
          or (shown_id and other_active.id == shown_id)) then
        active_id = other_active.id
        promoted = true
        break
      end
    end
  end
  if not active_id and #others > 0 and not kept_guest and pending_evacuated[identity] then
    local evacuated = hl.get_workspace(pending_evacuated[identity])
    if regular(evacuated) and occupied_or_persistent(evacuated) and not visiting(evacuated.id, identity) then
      active_id = evacuated.id
      promoted = true
    end
  end
  -- The last monitor does not move its workspaces onto a backup before
  -- monitor.removed, so the search above never sees a native switch that is
  -- still waiting on the 1ms timer. Hyprland remembered that occupied
  -- workspace. An empty placeholder is not one, and neither is a gap-filler
  -- already promoted into pending_evacuated while the saved workspace was
  -- being moved away. Several switches in the same tick keep the latest, not
  -- the highest id.
  if not active_id and #others == 0 and not pending_evacuated[identity] then
    local candidate = latest_pending(identity, false)
    if candidate then
      active_id = candidate
      promoted = true
    end
  end
  local id = active_id or (shown[identity] and shown[identity].id)
  if not id or visiting(id, identity) then
    return
  end

  showing_guest[identity] = nil
  pending_evacuated[identity] = nil
  pending_guest_leave[identity] = nil
  if promoted or kept_guest or #others == 0 then
    pending_active[identity] = nil
  end
  away_connector[identity] = monitor.name

  shown[identity] = { id = id, away = true }
  save_shown()
end

note_shown = function(monitor)
  if not monitor or monitor.name == "FALLBACK" then
    return
  end

  local identity = current[monitor.name]
  if not identity then
    return
  end

  -- While it is away, the workspace Hyprland activates on the way back is the
  -- empty one it starts a monitor on, not the one the monitor was showing.
  if shown[identity] and shown[identity].away then
    return
  end

  local active = monitor.active_workspace
  if not regular(active) then
    return
  end

  if visiting(active.id, identity) then
    showing_guest[identity] = active.id
    save_shown()
    return
  end

  showing_guest[identity] = nil
  pending_active[identity] = nil
  pending_evacuated[identity] = nil
  pending_guest_leave[identity] = nil
  shown[identity] = { id = active.id, away = false }
  save_shown()
end

hl.on("hyprland.start", function()
  awaiting_reload = false
  -- Windows don't outlive a session, so neither do the workspaces that held them
  -- nor which one a monitor was showing.
  merged = {}
  save_merged()
  shown = {}
  showing_guest = {}
  pending_active = {}
  pending_evacuated = {}
  pending_guest_leave = {}
  away_connector = {}
  save_shown()
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
  awaiting_reload = false
  M.reconcile()
end)

hl.on("workspace.active", function(workspace)
  -- The workspace names its own monitor. Reading the focused one records the
  -- switch against whichever monitor happens to have focus.
  --
  -- Hyprland 0.56.2 activates another workspace on a departing monitor inside
  -- moveWorkspaceToMonitor before moving the active workspace away and emitting
  -- monitor.removed. Recording after a short tick drops that migration when the
  -- monitor disappears before the timer runs, while M.focus and M.move_window
  -- record Omarchy's own switches immediately.
  local monitor = workspace and workspace.monitor or hl.get_active_monitor()
  if not monitor or monitor.name == "FALLBACK" then
    return
  end

  local name = monitor.name
  local id = workspace and workspace.id
  local identity = current[name]
  if identity and regular(workspace) and not (shown[identity] and shown[identity].away) then
    local active_monitor = hl.get_active_monitor()
    local focused_here = active_monitor ~= nil and active_monitor.name == name
    local function promote_pending_evacuated()
      local candidate = latest_pending(identity, true)
      if candidate then
        pending_evacuated[identity] = candidate
      end
    end
    local prev = showing_guest[identity]
    if visiting(id, identity) then
      if not focused_here and not reconciling and not awaiting_reload and not has_unassigned_monitor()
        and pending_active[identity] then
        promote_pending_evacuated()
      elseif not prev or prev == id or (
        -- A focused switch onto another out-of-block guest is the user: the
        -- block was full, so neither workspace was merged, and the record has
        -- to land before the 1ms timer or the previous guest's monitor can
        -- return and pull this one back. A guest merged into this block is
        -- different. Hyprland 0.56.2 gap-plugs that next guest (noFocus)
        -- before the returning monitor is listed and before the reclaimed
        -- guest's monitor pointer moves, both while the removal timer is
        -- still pending and after it has run. Committing here leaves the
        -- host on the gap guest when monitor.added reconciles.
        -- owner_removal_pending covers the timer window. After the timer the
        -- same event waits for the 1ms confirmation (note_shown), so a
        -- deliberate switch with no reconnect still sticks and a gap-plug
        -- right before monitor.added does not.
        not reconciling and not awaiting_reload and not guest_departed(prev, name)
        and focused_here and not owner_removal_pending(prev) and not has_unassigned_monitor()
        and not (merged[id] or merged[prev])
      ) then
        pending_guest_leave[identity] = nil
        showing_guest[identity] = id
        save_shown()
      end
    elseif not reconciling then
      local leaving_guest = prev ~= nil and not awaiting_reload and not guest_left(prev, name)
      if not prev or (leaving_guest and focused_here) or pending_guest_leave[identity] then
        if not has_unassigned_monitor() then
          local shown_record = shown[identity]
          local shown_ws = shown_record and hl.get_workspace(shown_record.id)
          local shown_evacuated = shown_record ~= nil and regular(shown_ws)
            and (not shown_ws.monitor or shown_ws.monitor.name ~= name)
          -- An empty non-persistent workspace is a disconnect placeholder when
          -- this monitor is not leaving a guest and has no saved view yet, or
          -- that view has already left. A focused switch onto an empty
          -- workspace that is still beside the saved one is the user, and a
          -- later plug must not pull them back.
          local empty_placeholder = not occupied_or_persistent(workspace) and not leaving_guest
            and (not shown_record or shown_evacuated)
          -- A fast replug reclaims the visitor before monitor.added. Hyprland
          -- 0.56.2 activates this monitor's own fallback first, while the
          -- visitor still names this monitor and before the returning monitor
          -- is listed. That is not a user switch. After the removal timer the
          -- same event is ambiguous with a real switch, so the visitor record
          -- stays until the 1ms confirmation (note_shown) when nothing
          -- reconnects.
          local reclaiming = prev ~= nil and owner_removal_pending(prev)
          local is_teardown_fallback = not focused_here
            or (not leaving_guest and shown_record and shown_record.id == id)
            or empty_placeholder
            or (not leaving_guest and shown_evacuated)
            or reclaiming
          if not is_teardown_fallback then
            local changed = false
            pending_evacuated[identity] = nil
            if leaving_guest then
              pending_guest_leave[identity] = true
            end
            if touch_pending(identity, id) then
              changed = true
            end
            if changed then
              save_shown()
            end
          else
            promote_pending_evacuated()
          end
        end
      end
    end
  end
  hl.timer(function()
    local live = hl.get_monitor(name)
    if not live then
      return
    end
    local active = live.active_workspace
    if id and (not regular(active) or active.id ~= id) then
      return
    end
    note_shown(live)
  end, { type = "oneshot", timeout = 1 })
end)

hl.on("monitor.added", function(monitor)
  local name = monitor and monitor.name
  if name then
    removal_generation[name] = (removal_generation[name] or 0) + 1
  end
  M.reconcile(name)
end)

-- Hyprland reports the removal from inside the monitor's teardown, where moving
-- workspaces or focus onto a monitor that was mirroring it crashes Hyprland, so
-- reconcile once the teardown has returned. The workspace it was showing is
-- noted first: the teardown drops the monitor before reconcile runs. An add
-- that lands first has already reconciled this connector, and the timer from
-- the removal must not mark it offline afterwards.
-- Hyprland can show a departing monitor's workspace on a survivor without a
-- workspace.active that records a visitor. Note it before the removal
-- debounce, so a fast replug that drops the survivor onto another of its own
-- workspaces restores the view it had instead of saving that fallback.
local function note_departed_visitor(departed_name, departed_guest)
  local departed = departed_name and current[departed_name]
  if not departed then
    return
  end

  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.name ~= departed_name and monitor.name ~= "FALLBACK" then
      local identity = current[monitor.name]
      local active = monitor.active_workspace
      if identity and regular(active) and visiting(active.id, identity)
        and not (shown[identity] and shown[identity].away) then
        local origin = merged[active.id]
        local from_departed = (origin and origin.identity == departed)
          or identity_of_block(block_of_id(active.id)) == departed
          or (departed_guest ~= nil and active.id == departed_guest)
        if from_departed and showing_guest[identity] ~= active.id then
          showing_guest[identity] = active.id
          save_shown()
        end
      end
    end
  end
end

hl.on("monitor.removed", function(monitor)
  local name = monitor and monitor.name
  local departed = name and current[name]
  local departed_guest = departed and showing_guest[departed]
  mark_away(monitor)
  note_departed_visitor(name, departed_guest)
  local generation = name and removal_generation[name] or 0
  if name then
    removal_scheduled[name] = generation
  end
  hl.timer(function()
    if name and (removal_generation[name] or 0) ~= generation then
      return
    end
    if name then
      removal_scheduled[name] = nil
    end
    M.reconcile(nil, name)
  end, { type = "oneshot", timeout = 1 })
end)

o.workspaces = M

return M
