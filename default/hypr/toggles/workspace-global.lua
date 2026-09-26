-- Global workspace mode — active when this file is loaded by toggles.lua.
-- When present in ~/.local/state/omarchy/toggles/hypr/, global mode is ON.
--
-- STABLE-BASE SCHEME (replaces monitorId * 10):
--   Each monitor is assigned a permanent workspace base on first connection.
--   The base is stored in ~/.local/state/omarchy/monitor-bases.json keyed by
--   monitor *name* (e.g. "eDP-1", "HDMI-1") — not by Hyprland's transient id.
--
--   Hyprland does not reuse monitor ids after hotplug (hyprwm/Hyprland#2601).
--   Unplugging and replugging an external monitor gives it a new id each time,
--   which broke the old monitorId * 10 scheme by orphaning occupied workspaces.
--   Using name as the key means the same physical monitor always owns the same
--   workspace range regardless of what numeric id Hyprland assigns to it.
--
--   Example persistent mapping (monitor-bases.json):
--     { "eDP-1": 0, "HDMI-1": 10, "DP-2": 20 }
--
--   Workspace ID for slot N on monitor named M = bases[M] + N
--
-- This file:
--   1. Reads monitor-bases.json and allocates bases for any new monitors using
--      hl.get_monitors() — no subprocess, no IPC round-trip during config eval.
--   2. Persists any new allocations by backgrounding omarchy-monitor-base sync.
--   3. Stores the resulting map in _G.omarchy_monitor_bases (name → base).
--   4. Stores the sorted monitor list in _G.omarchy_global_ws_monitors.
--   5. Registers monitor.added / monitor.removed handlers so hotplug is picked
--      up without a full hyprctl reload.
--
-- STUB-SAFETY NOTES:
--   omarchy-menu-keybindings evaluates this file under a stub Lua environment
--   to extract keybinding metadata without running a real Hyprland session.
--   Two hazards to avoid:
--
--   1. ipairs() on a stub object hangs (omacom/omarchy#7025): the stub's
--      __index returns a truthy sentinel for every key, so ipairs() never
--      sees nil and loops forever. Fixed: use numeric for i = 1, #tbl.
--
--   2. io.popen() / hl.get_monitors() under the stub: io.popen actually
--      executes the shell command, causing omarchy-monitor-base to call
--      hyprctl which blocks waiting for a Hyprland socket that doesn't
--      exist in the menu context. Fixed: gate both calls behind a
--      HYPRLAND_INSTANCE_SIGNATURE check — that env var is only set inside
--      a live Hyprland session.

-- Only run the Hyprland-dependent setup when inside a real session.
if not os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then
  _G.omarchy_monitor_bases = {}
  _G.omarchy_global_ws_monitors = {}
  return
end

-- ── Base map helpers ──────────────────────────────────────────────────────────

local BASES_FILE = (os.getenv("HOME") or "") ..
                   "/.local/state/omarchy/monitor-bases.json"
local STRIDE = 10  -- workspace slots per monitor

-- Read the persisted name→base map from disk. Returns {} on any error.
local function load_bases()
  local f = io.open(BASES_FILE, "r")
  if not f then return {} end
  local raw = f:read("*a")
  f:close()
  -- Minimal JSON object parser: extract "key": number pairs.
  local result = {}
  for key, val in raw:gmatch('"([^"]+)"%s*:%s*(%d+)') do
    result[key] = tonumber(val)
  end
  return result
end

-- Find the lowest non-negative multiple of STRIDE not already in bases.
local function next_free_base(bases)
  local used = {}
  for _, b in pairs(bases) do used[b] = true end
  local candidate = 0
  while used[candidate] do candidate = candidate + STRIDE end
  return candidate
end

-- Merge hl.get_monitors() names into bases, allocating new entries in
-- Hyprland's reported order (sorted by current id ascending — same policy
-- as the Python omarchy-monitor-base script). Returns bases, changed.
local function sync_bases_in_lua(monitors)
  local bases = load_bases()
  local changed = false

  -- Sort by current Hyprland id for deterministic allocation order.
  local sorted = {}
  for i = 1, #monitors do sorted[i] = monitors[i] end
  table.sort(sorted, function(a, b) return a.id < b.id end)

  for i = 1, #sorted do
    local name = sorted[i].name
    if name and name ~= "" and bases[name] == nil then
      bases[name] = next_free_base(bases)
      changed = true
    end
  end

  return bases, changed
end

-- Write bases back to disk as JSON. Called only when changed=true.
-- Uses a temp-file + rename for atomicity (same as the Python script).
local function save_bases(bases)
  local dir = BASES_FILE:match("^(.*)/[^/]+$")
  os.execute("mkdir -p '" .. dir .. "'")
  local tmp = BASES_FILE .. ".tmp"
  local f = io.open(tmp, "w")
  if not f then return end
  -- Emit sorted-key JSON so the file is stable across writes.
  local keys = {}
  for k in pairs(bases) do keys[#keys + 1] = k end
  table.sort(keys)
  f:write("{\n")
  for i = 1, #keys do
    local k = keys[i]
    f:write(string.format('  "%s": %d', k, bases[k]))
    if i < #keys then f:write(",") end
    f:write("\n")
  end
  f:write("}\n")
  f:close()
  os.rename(tmp, BASES_FILE)
end

-- ── Monitor list builder ──────────────────────────────────────────────────────
-- Builds/refreshes _G.omarchy_monitor_bases and _G.omarchy_global_ws_monitors
-- from a live hl.get_monitors() snapshot. Call at startup and on hotplug.

local function rebuild_monitor_list()
  local monitors = hl.get_monitors()
  local bases, changed = sync_bases_in_lua(monitors)

  if changed then
    -- Write synchronously (pure Lua, no subprocess).
    save_bases(bases)
    -- Also background the Python script so it can do any additional bookkeeping
    -- (it is a no-op when the JSON is already up to date).
    pcall(function() os.execute("omarchy-monitor-base sync &>/dev/null &") end)
  end

  _G.omarchy_monitor_bases = bases

  -- Sort by stable base (ascending) for consistent dispatch ordering.
  table.sort(monitors, function(a, b)
    local base_a = bases[a.name] or (a.id * 10)
    local base_b = bases[b.name] or (b.id * 10)
    return base_a < base_b
  end)

  _G.omarchy_global_ws_monitors = {}
  -- Numeric for avoids the ipairs/stub hang (see note above).
  for i = 1, #monitors do
    local mon = monitors[i]
    _G.omarchy_global_ws_monitors[i] = {
      id   = mon.id,
      name = mon.name,
      base = bases[mon.name] or (mon.id * 10),
    }
  end
end

-- Run initial setup: build base map and monitor list without any subprocess.
rebuild_monitor_list()

-- ── Materialize persistent workspaces ────────────────────────────────────────
-- set_workspace() silently no-ops on workspaces that don't exist yet. Register
-- hl.workspace_rule() with persistent=true for every slot on every monitor so
-- switching to an empty slot works immediately (no silent failures).
local function ensure_persistent_workspaces()
  if not hl.workspace_rule then
    return  -- Hyprland version too old or not available
  end
  for i = 1, #_G.omarchy_global_ws_monitors do
    local mon = _G.omarchy_global_ws_monitors[i]
    local base = mon.base
    for slot = 1, 10 do
      local ws_id = base + slot
      pcall(function()
        hl.workspace_rule({
          workspace  = tostring(ws_id),
          monitor    = mon.name,
          persistent = true,
        })
      end)
    end
  end
end

-- Ensure all workspace slots exist before any focus dispatch.
ensure_persistent_workspaces()

-- hl.workspace_rule() doesn't materialize synchronously; background a retry
-- script that re-verifies after a short delay.
pcall(function() os.execute("omarchy-ensure-workspaces &>/dev/null &") end)

-- ── Hotplug handlers ──────────────────────────────────────────────────────────
-- The monitor list is built once at config-eval time. Without these handlers a
-- newly connected monitor is invisible to the workspace sync logic until the
-- next full hyprctl reload. monitor.added / monitor.removed are Hyprland 0.56+
-- events (confirmed in wiki.hypr.land/configuring/core/advanced-configuration/events/).

if hl.on then
  hl.on("monitor.added", function(_mon)
    -- Rebuild the global monitor list and allocate a base for the new monitor.
    rebuild_monitor_list()
    -- Materialise workspace slots for the newly connected monitor.
    ensure_persistent_workspaces()
    -- Retry-with-delay in case workspace_rule() needs a moment to settle.
    pcall(function() os.execute("omarchy-ensure-workspaces &>/dev/null &") end)
  end)

  hl.on("monitor.removed", function(_mon)
    -- Prune the disconnected monitor from the live list so the workspace.active
    -- handler doesn't try to dispatch to a monitor that no longer exists.
    rebuild_monitor_list()
  end)
end

-- ── Workspace sync event hook ─────────────────────────────────────────────────
-- Catches ALL workspace switches regardless of source (keybindings, bar clicks,
-- menus, raw hyprctl, other tools) and syncs every monitor to the same slot.
-- Re-entrancy is safe: only dispatches to monitors showing the wrong workspace,
-- so each pass strictly reduces mismatches and converges in one round.

if hl.on then
  local function slot_of(ws_id)
    -- Extract slot 1-10 from any workspace ID within the global range.
    -- Returns nil for special/named/out-of-range IDs.
    -- Reads _G.omarchy_monitor_bases dynamically so hotplugged monitors with
    -- high bases (e.g. base=90 after monitor.added) are included without a
    -- full config reload. The stale local ws_id_upper_bound variable is gone.
    if ws_id <= 0 then return nil end
    local bases = _G.omarchy_monitor_bases
    if not bases then return nil end
    for _, base in pairs(bases) do
      if ws_id >= base + 1 and ws_id <= base + 10 then
        local slot = ws_id % 10
        if slot == 0 then slot = 10 end
        return slot
      end
    end
    return nil
  end

  local function switch_to_slot(slot)
    local monitors = hl.get_monitors()
    if not monitors then return end

    -- Record the focused monitor name BEFORE any dispatches so we can
    -- unconditionally refocus it afterwards. hl.dsp.focus({ workspace = N })
    -- warps keyboard focus and the pointer to whichever monitor owns workspace N,
    -- so every dispatch to another monitor steals focus. We must restore it
    -- explicitly after all non-focused-monitor dispatches — including the case
    -- where the originating monitor was already on the target slot (e.g.
    -- SUPER+TAB/scroll) and therefore isn't in the "needs syncing" set.
    local focused_monitor_name = nil
    local active_ws = {}
    for i = 1, #monitors do
      local m = monitors[i]
      if m.active_workspace then
        active_ws[m.id] = m.active_workspace.id
      end
      if m.focused then
        focused_monitor_name = m.name
      end
    end

    -- Dispatch all monitors that need syncing, non-focused first.
    -- The focused monitor is handled last (if it needs a change) or via an
    -- explicit refocus call below (if it was already on the right slot).
    local others = {}
    local focused_entry = nil
    for i = 1, #_G.omarchy_global_ws_monitors do
      local mon = _G.omarchy_global_ws_monitors[i]
      local target_ws = mon.base + slot
      if active_ws[mon.id] ~= target_ws then
        if mon.name == focused_monitor_name then
          focused_entry = { mon = mon, target_ws = target_ws }
        else
          others[#others + 1] = { mon = mon, target_ws = target_ws }
        end
      end
    end

    for i = 1, #others do
      pcall(function()
        hl.dispatch(hl.dsp.focus({ workspace = tostring(others[i].target_ws) }))
      end)
    end
    if focused_entry then
      pcall(function()
        hl.dispatch(hl.dsp.focus({ workspace = tostring(focused_entry.target_ws) }))
      end)
    end

    -- Always refocus the originating monitor after all dispatches so that
    -- focus and the pointer return to where the user is, even when that monitor
    -- was already on the target slot and no dispatch was needed for it.
    if focused_monitor_name then
      pcall(function()
        hl.dispatch(hl.dsp.focus({ monitor = focused_monitor_name }))
      end)
    end
  end

  hl.on("workspace.active", function(workspace)
    local slot = slot_of(workspace.id)
    if not slot then return end
    switch_to_slot(slot)
  end)
end
