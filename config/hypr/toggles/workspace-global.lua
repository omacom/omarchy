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
--   1. Calls omarchy-monitor-base sync to update/persist the base map for the
--      currently connected monitors.
--   2. Stores the resulting map in _G.omarchy_monitor_bases (name → base).
--   3. Also stores the sorted monitor list in _G.omarchy_global_ws_monitors
--      for use by other config modules (tiling.lua, etc.).
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

local function parse_bases()
  -- Run omarchy-monitor-base sync: allocates any missing bases for currently
  -- connected monitors, persists, then prints "name base\n" lines.
  local handle = io.popen("omarchy-monitor-base sync 2>/dev/null")
  local result = {}
  if handle then
    for line in handle:lines() do
      local name, base = line:match("^(%S+)%s+(%d+)$")
      if name and base then
        result[name] = tonumber(base)
      end
    end
    handle:close()
  end
  return result
end

-- Build and export the stable name→base map.
_G.omarchy_monitor_bases = parse_bases()

-- Also export the sorted monitor list (ordered by base, ascending) so other
-- config modules can use a stable, base-ordered view of monitors without
-- re-querying.
local monitors = hl.get_monitors()

-- Sort by name-keyed base (stable), falling back to current Hyprland id
-- for any monitor not yet in the map (shouldn't happen after sync above).
table.sort(monitors, function(a, b)
  local base_a = _G.omarchy_monitor_bases[a.name] or (a.id * 10)
  local base_b = _G.omarchy_monitor_bases[b.name] or (b.id * 10)
  return base_a < base_b
end)

_G.omarchy_global_ws_monitors = {}
-- Numeric for avoids the ipairs/stub hang (see note above).
for i = 1, #monitors do
  local mon = monitors[i]
  _G.omarchy_global_ws_monitors[i] = {
    id   = mon.id,
    name = mon.name,
    base = _G.omarchy_monitor_bases[mon.name] or (mon.id * 10),
  }
end

-- ── Materialize persistent workspaces (Issue #5) ─────────────────────────
-- set_workspace() silently no-ops on workspaces that don't exist yet. We need
-- all workspace slots pre-created with persistent=true so that switching to
-- an empty slot works immediately (no silent failures).
--
-- This function registers hl.workspace_rule() for every slot (1-10) on every
-- monitor to ensure they exist even if empty. Persistent workspaces remain
-- alive even with no windows.
local function ensure_persistent_workspaces()
  if not hl.workspace_rule then
    return  -- Hyprland version too old or not available
  end
  
  for i = 1, #_G.omarchy_global_ws_monitors do
    local mon = _G.omarchy_global_ws_monitors[i]
    local base = mon.base
    
    -- Register persistent workspace for each slot 1-10 on this monitor
    for slot = 1, 10 do
      local ws_id = base + slot
      local rule_ok = pcall(function()
        hl.workspace_rule({
          workspace = tostring(ws_id),
          monitor = mon.name,
          persistent = true,
          -- layout defaults to current; no need to override here
        })
      end)
      -- Silently ignore errors; rule registration is best-effort
    end
  end
end

-- Ensure all workspace slots exist before any focus dispatch
ensure_persistent_workspaces()

-- ── Delayed verification (Issue #6) ────────────────────────────────────
-- hl.workspace_rule() doesn't materialize synchronously. Schedule a retry
-- script to verify all workspaces exist after a short delay. This catches the
-- race where a fresh monitor's workspaces aren't created yet.
local ok = pcall(function()
  os.execute("omarchy-ensure-workspaces &")
end)
-- Silently ignore if the script isn't found yet
