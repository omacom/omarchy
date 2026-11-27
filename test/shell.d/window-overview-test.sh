#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

ROOT="$ROOT" run_node_test <<'JS'
const overview = requireFromRoot('shell/plugins/window-overview/OverviewModel.js')
const qml = require('fs').readFileSync(process.env.ROOT + '/shell/plugins/window-overview/Overview.qml', 'utf8')
const keys = qml.match(/Keys.onPressed: function\(event\) \{([\s\S]*?)\n      \}/)[1]
const Qt = Object.fromEntries(['Key_Escape','Key_Return','Key_Enter','Key_Left','Key_Right','Key_Up','Key_Down','Key_Tab','Key_Backtab','ShiftModifier'].map((key, index) => [key, index + 1]))
const selection = {windows: [{}, {}], selectedIndex: 0}
const press = new Function('root', 'Qt', 'Util', 'layout', 'OverviewModel', 'event', keys)
press(selection, Qt, {readingKey: event => event.key}, {columns: 3}, overview, {key: Qt.Key_Backtab, modifiers: Qt.ShiftModifier})
assertEqual(selection.selectedIndex, 1, 'Qt Backtab moves backward and wraps to the last window')
press(selection, Qt, {readingKey: event => event.key}, {columns: 3}, overview, {key: Qt.Key_Tab, modifiers: 0})
assertEqual(selection.selectedIndex, 0, 'Tab moves forward after Backtab')
assertEqual(overview.moveSelection(0, -3, 2), 1, 'Up with more columns than windows keeps a valid selection')
assertEqual(overview.moveSelection(0, -11, 2), 1, 'large backward steps wrap without a negative remainder')
const windows = [
  {address: '0xA', workspace: {id: 2}, wayland: {title: 'One'}, lastIpcObject: {at: [100, 100], size: [800, 500], focusHistoryID: 1}},
  {address: 'b', workspace: {id: 2}, wayland: {title: 'Two'}, lastIpcObject: {at: [900, 200], size: [600, 400], focusHistoryID: 0}},
  {address: 'dialog', workspace: {id: 2}, wayland: {parent: {}}},
  {address: 'other', workspace: {id: 3}, wayland: {}},
  {address: 'minimized', workspace: {id: -99}, wayland: {}}
]
assertDeepEqual(overview.windowsOnWorkspace(windows, 2).map(w => w.address), ['0xA', 'b'], 'overview selects top-level windows only on its workspace')
assertDeepEqual(overview.windowsOnWorkspace(windows, 2, {'0xa': {targetWorkspaceId: 4}}).map(w => w.address), ['b'], 'pendingMoves immediately hides moved window from source workspace')
assertDeepEqual(overview.windowsOnWorkspace(windows, 4, {'0xa': {targetWorkspaceId: 4}}).map(w => w.address), ['0xA'], 'pendingMoves immediately shows moved window on target workspace')
assertEqual(overview.selectionAfterChange(windows, 1, [windows[1]]), 0, 'selection follows window identity after a preceding window closes')
assertEqual(overview.selectionAfterChange(windows, 1, [windows[0]]), 0, 'closing the selected window selects a remaining window')
assertEqual(overview.selectionAfterChange(windows, 1, []), -1, 'empty overview has no selection')

const blocks = overview.parseMonitorBlocks('0\teDP-1\tPanel\n1\tDP-2\tExternal\n')
assertEqual(blocks['eDP-1'], 0, 'parseMonitorBlocks maps first monitor to block 0')
assertEqual(blocks['DP-2'], 1, 'parseMonitorBlocks maps second monitor to block 1')
assertEqual(overview.monitorBlock('DP-2', blocks, 1), 1, 'monitorBlock prefers monitor block map')
assertEqual(overview.slotOf(13), 3, 'slotOf converts monitor block workspace id to 1-based slot')

const entries = overview.workspaceEntries([{id: 1}, {id: 3}, {id: 7}, {id: 14, monitor: {name: 'eDP-1'}}], windows, 'eDP-1', blocks, 2, {'0xa': {targetWorkspaceId: 4}})
assertDeepEqual(entries.map(e => e.id), [1, 2, 3, 4, 5, 7, 14], 'workspaceEntries keeps slots 1-5, occupied/existing slots, and visiting guests')
assertEqual(entries.find(e => e.id === 4).windowCount, 1, 'workspaceEntries counts pending moved windows on target workspace')
assertEqual(entries.find(e => e.id === 2).windowCount, 1, 'workspaceEntries deducts pending moved windows from source workspace')

const packed = [1, 2, 3, 4, 5].map(id => ({address: '0x' + id, workspace: {id}, wayland: {appId: 'app'}}))
const packedEntries = overview.workspaceEntries([], packed, 'eDP-1', blocks, 1, {})
assertDeepEqual(packedEntries.map(e => e.id), [1, 2, 3, 4, 5, 6], 'workspaceEntries appends next empty workspace slot when 1-5 are all occupied')
assertEqual(packedEntries[5].isNewSlot, true, 'appended empty workspace slot is marked isNewSlot')

assertDeepEqual([0, 1, 2, 3, 4].map(i => overview.reorderShiftSlots(i, 2, 0)), [1, 1, -2, 0, 0], 'reorderShiftSlots shifts cards right when dragging workspace 3 to slot 1')
assertDeepEqual([0, 1, 2, 3, 4].map(i => overview.reorderShiftSlots(i, 0, 2)), [2, -1, -1, 0, 0], 'reorderShiftSlots shifts cards left when dragging workspace 1 to slot 3')
assertEqual(overview.reorderShiftSlots(1, 2, 2), 0, 'reorderShiftSlots returns 0 when source equals target')

const wsWins = [
  {address: '0x1', workspace: {id: 1}, wayland: {title: 'W1'}},
  {address: '0x2', workspace: {id: 2}, wayland: {title: 'W2'}},
  {address: '0x3', workspace: {id: 3}, wayland: {title: 'W3'}}
]
const wsEntries = overview.workspaceEntries([{id: 1}, {id: 2}, {id: 3}], wsWins, 'eDP-1', blocks, 1, {})
const plan = overview.reorderWorkspacePlan(wsEntries, 3, 1, [{id: 1}, {id: 2}, {id: 3}], wsWins, {})
assertEqual(plan.idMap[3], 1, 'reorderWorkspacePlan maps workspace 3 to slot 1')
assertEqual(plan.idMap[1], 2, 'reorderWorkspacePlan shifts workspace 1 to slot 2')
assertEqual(plan.idMap[2], 3, 'reorderWorkspacePlan shifts workspace 2 to slot 3')
assertEqual(plan.idMap[4], 4, 'reorderWorkspacePlan leaves untouched slots alone')
assertEqual(new Set(plan.stageOps.map(op => op.tempId)).size, plan.stageOps.length, 'reorderWorkspacePlan assigns distinct unused temp workspace IDs')
assert(plan.stageOps.every(op => op.tempId >= 9900), 'temp workspace IDs stay safely outside regular monitor slots')
assertDeepEqual(plan.windowMoves.map(m => `${m.address}:${m.fromId}->${m.toId}`), ['0x1:1->2', '0x2:2->3', '0x3:3->1'], 'reorderWorkspacePlan records all affected window moves')
const op1 = plan.stageOps.find(op => op.fromId === 1)
assert(op1 && plan.luaDispatch.includes('o.workspaces.reorder(') && plan.luaDispatch.includes(`from = 1, temp = ${op1.tempId}, to = 2`), 'luaDispatch routes workspace reordering through o.workspaces.reorder with temp IDs')
assertEqual(overview.reorderWorkspacePlan(wsEntries, 3, 3, [], wsWins, {}), null, 'reorderWorkspacePlan returns null for no-op reorder')
assertEqual(overview.reorderWorkspacePlan(wsEntries, 6, 1, [], wsWins, {}), null, 'reorderWorkspacePlan ignores non-draggable slots such as +6')

const dropEntries = [
  {id: 1, guest: false, isNewSlot: false},
  {id: 2, guest: false, isNewSlot: false},
  {id: 3, guest: false, isNewSlot: false},
  {id: 4, guest: false, isNewSlot: false},
  {id: 5, guest: false, isNewSlot: false},
  {id: 11, guest: true, isNewSlot: false}
]
// 6 cards of width 100, spacing 10 => rowWidth = 650. In RTL, index 0 sits at [550, 650], index 4 at [110, 210], guest at [0, 100].
assertDeepEqual(overview.workspaceDropTarget(dropEntries, 50, 30, 650, 62, 100, 10, false), {index: 0, id: 1}, 'LTR drop target picks first slot on the left')
assertDeepEqual(overview.workspaceDropTarget(dropEntries, 490, 30, 650, 62, 100, 10, false), {index: 4, id: 5}, 'LTR drop target picks fifth regular slot')
assertDeepEqual(overview.workspaceDropTarget(dropEntries, 600, 30, 650, 62, 100, 10, false), {index: -1, id: -1}, 'LTR drop target rejects guest slots on the right')
assertDeepEqual(overview.workspaceDropTarget(dropEntries, 600, 30, 650, 62, 100, 10, true), {index: 0, id: 1}, 'RTL drop target picks first slot on the right')
assertDeepEqual(overview.workspaceDropTarget(dropEntries, 160, 30, 650, 62, 100, 10, true), {index: 4, id: 5}, 'RTL drop target picks fifth regular slot near left')
assertDeepEqual(overview.workspaceDropTarget(dropEntries, 50, 30, 650, 62, 100, 10, true), {index: -1, id: -1}, 'RTL drop target rejects guest slots on the far left')
assertDeepEqual(overview.workspaceDropTarget(dropEntries, 300, -100, 650, 62, 100, 10, true), {index: -1, id: -1}, 'drop target returns -1 outside vertical drop zone')

const gappedEntries = [
  {id: 1, guest: false, isNewSlot: false},
  {id: 2, guest: false, isNewSlot: false},
  {id: 3, guest: false, isNewSlot: false},
  {id: 4, guest: false, isNewSlot: false},
  {id: 5, guest: false, isNewSlot: false},
  {id: 6, guest: false, isNewSlot: true},
  {id: 7, guest: false, isNewSlot: false}
]
assertDeepEqual(overview.workspaceDropTarget(gappedEntries, 710, 30, 760, 62, 100, 10, false), {index: 6, id: 7}, 'drop target skips +newSlot cards and hits regular slot 7')

const rects = overview.miniWindowRects([windows[0], windows[1]], {x: 0, y: 0, width: 1600, height: 1000})
assertEqual(rects.length, 2, 'miniWindowRects returns one rect per window')
assertEqual(rects[0].address, '0xa', 'miniWindowRects sorts back-to-front by focusHistoryID')
assert(rects[0].x > 0 && rects[0].width >= 0.18 && rects[1].x > rects[0].x, 'miniWindowRects preserves relative monitor placement')
const fallbackRects = overview.miniWindowRects([{address: '0xc', wayland: {}}, {address: '0xd', wayland: {}}], {x: 0, y: 0, width: 1600, height: 1000})
assert(fallbackRects.length === 2 && fallbackRects[1].x > fallbackRects[0].x, 'miniWindowRects lays out windows without IPC geometry cleanly')
JS

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/home" "$tmp/bin"
export HOME="$tmp/home" OMARCHY_PATH="$ROOT" PATH="$tmp/bin:$ROOT/bin:$PATH"
export OVERVIEW_CALLS="$tmp/calls"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$OVERVIEW_CALLS"\n' >"$tmp/bin/hyprctl"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$OVERVIEW_CALLS"\n' >"$tmp/bin/omarchy-shell"
printf '#!/bin/bash\necho "${OVERVIEW_LAYOUT:-dwindle}"\n' >"$tmp/bin/omarchy-hyprland-workspace-layout-current"
chmod +x "$tmp/bin/"*

[[ $(omarchy-hyprland-window-overview middle-click) == "off" ]] || fail "overview middle-click is opt-in"
omarchy-hyprland-window-overview middle-click on
[[ $(omarchy-hyprland-window-overview middle-click) == "on" ]] || fail "overview middle-click preference persists"
omarchy-hyprland-window-overview middle-click toggle
[[ $(omarchy-hyprland-window-overview middle-click) == "off" ]] || fail "overview middle-click toggles off"
if omarchy-hyprland-window-overview middle-click invalid; then fail "overview rejects invalid toggle values"; fi
: >"$OVERVIEW_CALLS"
omarchy-hyprland-window-overview
[[ ! -s $OVERVIEW_CALLS ]] || fail "overview leaves tiled workspaces alone"
OVERVIEW_LAYOUT=floating omarchy-hyprland-window-overview
grep -qxF 'shell toggle omarchy.window-overview' "$OVERVIEW_CALLS" || fail "floating workspace invokes the overview lifecycle"
pass "middle-click is opt-in and overview preserves tiled workspace input"

mkdir -p "$HOME/.local/state/omarchy/toggles"
touch "$HOME/.local/state/omarchy/toggles/window-overview-middle-click"
ROOT="$ROOT" lua <<'LUA'
local floating, binds, enabled = false, 0, nil
local callback, up, fourUp, dispatched
local events, timers = {}, {}
local function flush()
  local queued = timers
  timers = {}
  for _, fn in ipairs(queued) do fn() end
end
package.preload["default.hypr.paths"] = function() return { home = os.getenv("HOME") } end
package.preload["default.hypr.workspace-modes"] = function()
  return { is_floating = function() return floating end, on_change = function(fn) callback = fn end }
end
hl = {
  get_active_workspace = function() return { id = 2 } end,
  on = function(event, fn) events[event] = fn end,
  timer = function(fn) table.insert(timers, fn) end,
  bind = function()
    binds = binds + 1
    return { set_enabled = function(_, value) enabled = value end, unbind = function() error("must not unbind user shortcuts") end }
  end,
  gesture = function(spec)
    if spec.fingers == 3 and spec.direction == "up" then up = spec end
    if spec.fingers == 4 and spec.direction == "up" then fourUp = spec end
  end,
  dispatch = function(value) dispatched = value end,
  dsp = { exec_cmd = function(command) return command end, workspace = { toggle_special = function(name) return name end } },
}
dofile(os.getenv("ROOT") .. "/default/hypr/window-overview.lua")
assert(binds == 1 and enabled == false, "tiled workspace keeps the overview binding disabled")
floating = true; callback(); callback(); flush()
assert(binds == 1, "floating workspace binds once")
floating = false; callback(); flush()
assert(enabled == false and binds == 1, "leaving floating disables only the overview handle")
-- Workspace and monitor events precede the new focused state.
events["workspace.active"](); events["monitor.focused"]()
assert(#timers == 1, "focus events coalesce into one deferred update")
floating = true; flush()
assert(binds == 1 and enabled == true, "entering floating reuses the existing handle")
events["monitor.focused"](); events["workspace.active"]()
floating = false; flush()
assert(enabled == false, "entering tiled disables using destination state")
dofile(os.getenv("ROOT") .. "/default/hypr/gestures.lua")
assert(up.action == "special" and up.workspace_name == "qconsole", "three-finger up preserves the console")
assert(fourUp and type(fourUp.action) == "function", "four-finger up is available without a toggle")
fourUp.action(); assert(dispatched == nil, "four-finger up leaves tiled workspaces alone")
floating = true; fourUp.action()
assert(dispatched == "omarchy-hyprland-window-overview", "four-finger up opens floating overview")
LUA
pass "middle-click releases on tiling, four-finger up opens floating overview, and three-finger up retains the console"

cat >"$tmp/reorder-test.lua" <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path

local state_home = os.getenv("XDG_STATE_HOME")
local layouts_dir = state_home .. "/omarchy/workspace-layouts"
os.execute("mkdir -p " .. string.format("%q", layouts_dir))

-- Seed floating layout on workspace 1 and default (dwindle) on workspace 2.
do
  local f = assert(io.open(layouts_dir .. "/1.lua", "w"))
  f:write('o.workspace_mode({ workspace = "1", mode = "floating" })\n')
  f:close()
end

local world = {
  monitors = {
    { name = "eDP-1", id = 0, description = "Panel", active = 1 },
    { name = "DP-1", id = 1, description = "LG", active = 11 },
  },
  workspaces = {
    { id = 1, monitor = "eDP-1" },
    { id = 2, monitor = "eDP-1" },
    { id = 3, monitor = "eDP-1" },
    { id = 4, monitor = "eDP-1" },
    { id = 5, monitor = "eDP-1" },
    { id = 11, monitor = "DP-1" },
  },
  focused = "eDP-1",
  handlers = {},
  timers = {},
  rules = {},
  ws_rules = {},
  execs = {},
  config = { ["input.follow_mouse"] = 1, ["decoration.shadow.enabled"] = true, ["general.layout"] = "dwindle" },
  middle_enabled = nil,
}

local function monitor_named(name)
  for _, m in ipairs(world.monitors) do if m.name == name then return m end end
end
local function ws_numbered(id)
  for _, ws in ipairs(world.workspaces) do if ws.id == id then return ws end end
end
local function wins_on(id)
  local list = {}
  for _, w in pairs(world.windows) do
    if w.workspace_id == id then list[#list + 1] = w end
  end
  return list
end
local function make_win(address, ws_id, floating, tags)
  local w = { address = address, workspace_id = ws_id, floating = floating or false, fullscreen = 0, pinned = false, tags = tags or {} }
  w.workspace = setmetatable({}, { __index = function(_, k) if k == "id" then return w.workspace_id end end })
  return w
end
world.windows = {
  ["0x1"] = make_win("0x1", 1, false, {}),
  ["0x2"] = make_win("0x2", 2, false, {}),
  ["0x3"] = make_win("0x3", 3, false, {}),
  ["0x4"] = make_win("0x4", 4, false, {}),
  ["0x5"] = make_win("0x5", 5, false, {}),
  ["0xext"] = make_win("0xext", 11, false, {}),
  ["0xmin"] = make_win("0xmin", -99, true, { "omarchy-minimized-from-1" }),
}
local function has_tag(w, t)
  for _, held in ipairs(w.tags) do if held == t then return true end end
  return false
end

local monitor_obj, ws_obj
function ws_obj(ws)
  if not ws then return nil end
  return setmetatable({}, { __index = function(_, k)
    if k == "id" then return ws.id end
    if k == "name" then return tostring(ws.id) end
    if k == "special" then return false end
    if k == "windows" then return #wins_on(ws.id) end
    if k == "monitor" then return monitor_obj(monitor_named(ws.monitor)) end
  end })
end
function monitor_obj(m)
  if not m then return nil end
  return setmetatable({
    set_workspace = function(_, spec)
      local ws = ws_numbered(tonumber(spec.workspace))
      if ws and ws.monitor == m.name then m.active = ws.id end
    end,
  }, { __index = function(_, k)
    if k == "focused" then return world.focused == m.name end
    if k == "active_workspace" then return ws_obj(ws_numbered(m.active)) end
    if k == "is_mirror" then return false end
    return m[k]
  end })
end

hl = {
  on = function(ev, fn)
    world.handlers[ev] = world.handlers[ev] or {}
    table.insert(world.handlers[ev], fn)
  end,
  timer = function(fn) table.insert(world.timers, fn) end,
  bind = function()
    return { set_enabled = function(_, val) world.middle_enabled = val end }
  end,
  exec_cmd = function(cmd) table.insert(world.execs, cmd) end,
  get_monitors = function()
    local out = {}
    for _, m in ipairs(world.monitors) do out[#out + 1] = monitor_obj(m) end
    return out
  end,
  get_monitor = function(name) return monitor_obj(monitor_named(name)) end,
  get_active_monitor = function() return monitor_obj(monitor_named(world.focused)) end,
  get_active_window = function() return nil end,
  get_active_workspace = function() return ws_obj(ws_numbered(monitor_named(world.focused).active)) end,
  get_workspace = function(id) return ws_obj(ws_numbered(tonumber(id))) end,
  get_workspaces = function()
    local out = {}
    for _, ws in ipairs(world.workspaces) do out[#out + 1] = ws_obj(ws) end
    return out
  end,
  get_workspace_windows = function(sel) return wins_on(tonumber(sel)) end,
  get_windows = function(filter)
    local out = {}
    for _, w in pairs(world.windows) do
      if not filter or (filter.tag and has_tag(w, filter.tag)) then out[#out + 1] = w end
    end
    return out
  end,
  get_window = function(sel)
    local addr = sel:match("^address:(.+)$")
    return world.windows[addr]
  end,
  get_config = function(k) return world.config[k] end,
  config = function(vals)
    for sec, opts in pairs(vals) do
      for k, v in pairs(opts) do world.config[sec .. "." .. k] = v end
    end
  end,
  workspace_rule = function(rule) world.ws_rules[tostring(rule.workspace)] = rule.layout end,
  window_rule = function(rule) table.insert(world.rules, rule) end,
  plugin = { load = function() end },
  dispatch = function(fn) if type(fn) == "function" then fn() end end,
  dsp = {
    exec_cmd = function(c) return c end,
    focus = function(spec)
      return function()
        if spec.monitor then world.focused = spec.monitor
        elseif spec.workspace then
          local id = tonumber(spec.workspace)
          local ws = ws_numbered(id)
          if not ws then ws = { id = id, monitor = world.focused }; table.insert(world.workspaces, ws) end
          monitor_named(ws.monitor).active = ws.id
        end
      end
    end,
    workspace = {
      move = function(spec)
        return function()
          local ws = ws_numbered(tonumber(spec.workspace))
          if ws then ws.monitor = spec.monitor end
        end
      end,
      change_id = function(spec)
        return function()
          local old = tonumber(spec.workspace)
          local ws = ws_numbered(old)
          assert(ws, "missing workspace " .. tostring(old))
          assert(not ws_numbered(spec.id), "target id already exists: " .. tostring(spec.id))
          ws.id = spec.id
          for _, m in ipairs(world.monitors) do if m.active == old then m.active = spec.id end end
          for _, w in pairs(world.windows) do if w.workspace_id == old then w.workspace_id = spec.id end end
          -- Simulate Hyprland firing workspace.created during ID transitions.
          for _, cb in ipairs(world.handlers["workspace.created"] or {}) do cb({ id = spec.id }) end
        end
      end,
    },
    window = {
      float = function(spec) return function() spec.window.floating = (spec.action == "on") end end,
      tag = function(spec)
        return function()
          local name = spec.tag:sub(2)
          if spec.tag:sub(1, 1) == "+" then
            if not has_tag(spec.window, name) then table.insert(spec.window.tags, name) end
          else
            for i, held in ipairs(spec.window.tags) do
              if held == name then table.remove(spec.window.tags, i); break end
            end
          end
        end
      end,
      resize = function() return function() end end,
      center = function() return function() end end,
      move = function() return function() end end,
    },
  },
}

local function flush_timers()
  local q = world.timers
  world.timers = {}
  for _, fn in ipairs(q) do fn() end
end

require("default.hypr.helpers")
local mw = require("default.hypr.monitor-workspaces")
mw.reconcile()
require("default.hypr.workspace-layouts")
local modes = require("default.hypr.workspace-modes")
require("default.hypr.window-overview")

assert(modes.is_floating(1) and not modes.is_floating(2), "initial saved modes load cleanly")
assert(world.middle_enabled == true, "middle-click starts enabled on floating workspace 1")
assert(world.windows["0x1"].floating == true and world.windows["0x2"].floating == false, "initial floating state matches layouts")

-- 1. Swap workspace 1 (floating) -> slot 2 (tiled) and verify layouts, modes, minimized tags, middle-click, and shell refresh.
o.workspaces.reorder({ { from = 1, temp = 9900, to = 2 }, { from = 2, temp = 9901, to = 1 } })
flush_timers()

assert(world.windows["0x1"].workspace_id == 2 and world.windows["0x2"].workspace_id == 1, "windows swapped workspaces")
assert(monitor_named("eDP-1").active == 2, "active workspace followed reordered workspace 1 -> 2")
assert(modes.is_floating(2) == true and modes.is_floating(1) == false, "workspace-modes updated alongside workspace IDs")
assert(world.middle_enabled == true, "middle-click stays enabled on moved floating workspace 2")
assert(io.open(layouts_dir .. "/1.lua", "r") == nil, "stale 1.lua removed when default-mode workspace moved to slot 1")
local f2 = assert(io.open(layouts_dir .. "/2.lua", "r"), "saved layout moved to 2.lua")
local f2_body = f2:read("*a"); f2:close()
assert(f2_body:match('workspace = "2"') and f2_body:match('mode = "floating"'), "2.lua rewritten for workspace 2: " .. f2_body)
assert(has_tag(world.windows["0xmin"], "omarchy-minimized-from-2") and not has_tag(world.windows["0xmin"], "omarchy-minimized-from-1"), "minimized window tag followed reordered workspace")
assert(#world.execs >= 1 and world.execs[#world.execs]:find("omarchy.dock refresh", 1, true), "reorder refreshes workspaces and dock caches")

-- Switching to slot 1 (now tiled) disables middle-click.
monitor_named("eDP-1").active = 1
for _, fn in ipairs(world.handlers["workspace.active"] or {}) do fn() end
flush_timers()
assert(world.middle_enabled == false, "middle-click disables on workspace 1 after floating workspace moved away")

-- Reloading config preserves floating on 2 and tiled on 1.
package.loaded["default.hypr.workspace-modes"] = nil
package.loaded["default.hypr.workspace-layouts"] = nil
require("default.hypr.workspace-layouts")
modes = require("default.hypr.workspace-modes")
assert(modes.is_floating(2) and not modes.is_floating(1), "reloaded workspace-layouts keeps floating on workspace 2")
assert(world.windows["0x1"].floating == true and world.windows["0x2"].floating == false, "reloading does not tile moved floating windows")

-- 2. Unplug DP-1 so workspace 11 merges into slot 6, then drag slot 6 -> slot 1, and reconnect DP-1.
world.monitors = { world.monitors[1] }
for _, ws in ipairs(world.workspaces) do if ws.monitor == "DP-1" then ws.monitor = "eDP-1" end end
for _, fn in ipairs(world.handlers["monitor.removed"] or {}) do fn({ name = "DP-1" }) end
flush_timers()
assert(world.windows["0xext"].workspace_id == 6, "unplugged monitor workspace merged into slot 6: " .. world.windows["0xext"].workspace_id)
do
  local mf_before = assert(io.open(state_home .. "/omarchy/monitors/workspaces-merged", "r"))
  local text_before = mf_before:read("*a"); mf_before:close()
  assert(text_before:match("^6\t11\tLG"), "merged record starts at slot 6: " .. text_before)
end

-- Drag slot 6 (merged) to slot 1: 6->1, 1->2, 2->3, 3->4, 4->5, 5->6.
o.workspaces.reorder({
  { from = 6, temp = 9900, to = 1 },
  { from = 1, temp = 9901, to = 2 },
  { from = 2, temp = 9902, to = 3 },
  { from = 3, temp = 9903, to = 4 },
  { from = 4, temp = 9904, to = 5 },
  { from = 5, temp = 9905, to = 6 },
})
flush_timers()
assert(world.windows["0xext"].workspace_id == 1, "merged external workspace moved to slot 1")
assert(world.windows["0x5"].workspace_id == 6, "local workspace 5 shifted to slot 6")
assert(modes.is_floating(3) == true and modes.is_floating(2) == false, "floating layout shifted from slot 2 to slot 3")

local mf = assert(io.open(state_home .. "/omarchy/monitors/workspaces-merged", "r"))
local merged_text = mf:read("*a"); mf:close()
assert(merged_text:match("^1\t11\tLG"), "merged record moved from slot 6 to slot 1: " .. merged_text)

-- Reconnect DP-1: slot 1 (0xext) must return to DP-1 as workspace 11, and slot 6 (0x5) must stay on eDP-1.
table.insert(world.monitors, { name = "DP-1", id = 1, description = "LG", active = 11 })
for _, fn in ipairs(world.handlers["monitor.added"] or {}) do fn({ name = "DP-1" }) end
flush_timers()
assert(world.windows["0xext"].workspace_id == 11 and ws_numbered(11).monitor == "DP-1", "reconnected monitor reclaimed moved external workspace back to 11")
assert(world.windows["0x5"].workspace_id == 6 and ws_numbered(6).monitor == "eDP-1", "local workspace in slot 6 stayed on eDP-1")

-- 3. With default = "floating" and an explicit tiled override on workspace 2, swapping 1 <-> 2 moves the override to 1.lua and removes 2.lua.
os.remove(layouts_dir .. "/3.lua")
do
  local df = assert(io.open(layouts_dir .. "/default.lua", "w"))
  df:write('o.workspace_mode({ default = "floating" })\n')
  df:close()
  local f2t = assert(io.open(layouts_dir .. "/2.lua", "w"))
  f2t:write('o.workspace_mode({ workspace = "2", mode = "dwindle" })\n')
  f2t:close()
end
package.loaded["default.hypr.workspace-modes"] = nil
package.loaded["default.hypr.workspace-layouts"] = nil
require("default.hypr.workspace-layouts")
modes = require("default.hypr.workspace-modes")
assert(modes.is_floating(1) and not modes.is_floating(2), "floating default with tiled override on 2 loads")
o.workspaces.reorder({ { from = 1, temp = 9900, to = 2 }, { from = 2, temp = 9901, to = 1 } })
flush_timers()
assert(modes.is_floating(2) and not modes.is_floating(1), "floating default follows workspace 1 into slot 2")
assert(io.open(layouts_dir .. "/2.lua", "r") == nil, "2.lua removed when default-following workspace moves to slot 2")
local f1d = assert(io.open(layouts_dir .. "/1.lua", "r"), "explicit dwindle override moved to 1.lua")
local f1d_body = f1d:read("*a"); f1d:close()
assert(f1d_body:match('workspace = "1"') and f1d_body:match('mode = "dwindle"'), "1.lua rewritten for workspace 1: " .. f1d_body)
assert(world.ws_rules["1"] == "dwindle", "tiled workspace_rule updated for moved override workspace")

-- 4. Generated luaDispatch string from OverviewModel.js executes cleanly through o.workspaces.reorder.
local lua_dispatch = assert(os.getenv("OVERVIEW_LUA_DISPATCH"), "OVERVIEW_LUA_DISPATCH missing")
local fn_chunk = assert(load("return " .. lua_dispatch))
fn_chunk()()
assert(modes.is_floating(1) and not modes.is_floating(2), "evaluated OverviewModel luaDispatch swaps modes cleanly")
LUA
OVERVIEW_LUA_DISPATCH=$(ROOT="$ROOT" node -e '
  const overview = require(process.env.ROOT + "/shell/plugins/window-overview/OverviewModel.js");
  const entries = [{id: 1, guest: false, isNewSlot: false}, {id: 2, guest: false, isNewSlot: false}];
  const plan = overview.reorderWorkspacePlan(entries, 1, 2, [{id: 1}, {id: 2}], [], {});
  process.stdout.write(plan.luaDispatch);
')
HOME="$tmp/home" XDG_STATE_HOME="$tmp/home/.local/state" ROOT="$ROOT" OVERVIEW_LUA_DISPATCH="$OVERVIEW_LUA_DISPATCH" lua "$tmp/reorder-test.lua"
pass "workspace reordering updates saved layouts, workspace-modes, middle-click state, minimized tags, and merged monitor records"

qml_runner=/usr/lib/qt6/bin/qmltestrunner
[[ -x $qml_runner ]] || qml_runner=/usr/lib/qt6/qmltestrunner
if [[ -x $qml_runner ]]; then
  cp "$ROOT/shell/plugins/window-overview/OverviewModel.js" "$tmp/"
  python - "$ROOT" "$tmp" <<'PY'
from pathlib import Path
import re, sys

root, tmp = map(Path, sys.argv[1:])
source = (root / "shell/plugins/window-overview/Overview.qml").read_text()
ws_entries = re.search(r"  readonly property var workspaceEntries:[\s\S]*?\n  onWorkspaceEntriesChanged:[^\n]+", source)[0]
display_entries = re.search(r"  property var displayWorkspaceEntries:[\s\S]*?\n  Component\.onCompleted:[^\n]+", source)[0]
active_prop = re.search(r"  readonly property int hyprlandActiveWorkspaceId:[\s\S]*?\n  \}", source)[0]
active_effective = re.search(r"  readonly property int activeHyprlandWorkspaceId:[\s\S]*?\n    : hyprlandActiveWorkspaceId", source)[0]
binding = re.search(r"  readonly property var matchingWindows:[\s\S]*?\n  onMatchingWindowsChanged:[^\n]+", source)[0]
ws_lookup = re.search(r"  function workspaceEntryById\(id\) \{[\s\S]*?\n  \}", source)[0]
refresh = re.search(r"  function refresh\(\) \{[\s\S]*?\n  \}", source)[0]
select_ws = re.search(r"  function selectWorkspace\(targetId\) \{[\s\S]*?\n  \}", source)[0]
switch_ws = re.search(r"  function switchToWorkspace\(targetId\) \{[\s\S]*?\n  \}", source)[0]
update_drop = re.search(r"  function updateDropTarget\(pointInCatcher\) \{[\s\S]*?\n  \}", source)[0]
scroll_to = re.search(r"  function scrollStripTo\(nextX\) \{[\s\S]*?\n  \}", source)[0]
scroll_by = re.search(r"  function scrollStripBy\(delta\) \{[\s\S]*?\n  \}", source)[0]
reveal_ws = re.search(r"  function revealWorkspaceCard\(targetId\) \{[\s\S]*?\n  \}", source)[0]
drag_autoscroll = re.search(r"  function dragStripAutoScrollDir\(pointInCatcher\) \{[\s\S]*?\n  \}", source)[0]
begin_ws_drag = re.search(r"  function beginWorkspaceDrag\([^)]*\) \{[\s\S]*?\n  \}", source)[0]
update_ws_drag = re.search(r"  function updateWorkspaceDrag\([^)]*\) \{[\s\S]*?\n  \}", source)[0]
cancel_ws_drag = re.search(r"  function cancelWorkspaceDrag\(\) \{[\s\S]*?\n  \}", source)[0]
finish_ws_drag = re.search(r"  function finishWorkspaceDrag\(\) \{[\s\S]*?\n  \}", source)[0]
move_win = re.search(r"  function moveWindowToWorkspace\(window, targetWorkspaceId\) \{[\s\S]*?\n  \}", source)[0]
reorder_ws = re.search(r"  function reorderWorkspace\(sourceWorkspaceId, targetWorkspaceId\) \{[\s\S]*?\n  \}", source)[0]
update_ws_drop = re.search(r"  function updateWorkspaceDropTarget\(pointInCatcher\) \{[\s\S]*?\n  \}", source)[0]
ws_translate_x = re.search(r"transform: Translate \{\n\s*x: ([^\n]+)", source)[1]
ws_mouse = re.search(r"([ ]+)MouseArea \{\n\1  id: wsMouse[\s\S]*?\n\1\}", source)[0]
strip_shell_props = re.search(r"          readonly property real maxWidth:[\s\S]*?\n          height: workspaceStripViewport\.height", source)[0]
viewport_props = re.search(r"            readonly property real vPad:[\s\S]*?\n            onMaxContentXChanged:[^\n]+", source)[0]
row_props = re.search(r"              spacing: layout\.snap\(Style\.space\(12\)\)[\s\S]*?\n              readonly property real totalWidth:[^\n]+", source)[0]
reconcile = re.search(r"  function reconcilePendingMoves\(\) \{[\s\S]*?\n  \}", source)[0]
events = re.search(r"    function onFocusedMonitorChanged\(\) \{[\s\S]*?\n    function onRawEvent\(event\) \{[\s\S]*?\n    \}", source)[0]

qml = """import QtQuick
import QtTest
import "OverviewModel.js" as OverviewModel

Item {
  id: root
  width: panel.width
  height: 160
  property var windows: []
  property int selectedIndex: -1
  property bool opened: true
  property bool requested: true
  property string monitorName: "one"
  property int workspaceId: 2
  property int viewedWorkspaceId: 2
  property var monitorBlocks: ({"one": 0})
  property var pendingMoves: ({})
  property bool dragActive: false
  property int hoveredDropWorkspaceId: -1
  property bool wsDragActive: false
  property var draggedWorkspaceEntry: null
  property int draggedWorkspaceId: -1
  property int wsDragFromIndex: -1
  property int wsDragTargetIndex: -1
  property int wsDragTargetId: -1
  property point wsDragPoint: Qt.point(0, 0)
  property int stripAutoScrollDir: 0
  property bool rtl: false
  property int optimisticActiveWorkspaceId: -1
  property double optimisticActiveAt: 0
  property double ignoreWorkspaceEventsUntil: 0
  property bool pendingRefresh: false
  property var dispatches: []
  property int displayModelChanges: 0
  onDisplayWorkspaceEntriesChanged: displayModelChanges++

  QtObject {
    id: styleStub
    property real scale: 1.0
    function space(n) { return Math.round(n * scale) }
  }
  QtObject {
    id: panel
    property real width: 1200
  }
  QtObject {
    id: layout
    function snap(v) { return Math.round(v) }
  }

  QtObject { id: workspaceOne; property int number: 1 }
  QtObject { id: workspaceTwo; property int number: 2 }
  QtObject { id: workspaceThree; property int number: 3 }
  QtObject { id: first; property string address: "0xa"; property var workspace: workspace2; property var wayland: ({}) }
  QtObject { id: second; property string address: "0xb"; property var workspace: workspace2; property var wayland: ({}) }
  QtObject { id: third; property string address: "0xc"; property var workspace: otherWorkspace; property var wayland: ({}) }
  property var workspace1: ({id: workspaceOne.number})
  property var workspace2: ({id: workspaceTwo.number})
  property var otherWorkspace: ({id: workspaceThree.number})

  QtObject {
    id: fixtures
    property var toplevels: model
    property var workspaces: wsModel
    property var monitors: monitorModel
    property var focusedMonitor: ({name: "one"})
    signal rawEvent(var event)
    function dispatch(expr) { root.dispatches = root.dispatches.concat([expr]) }
    function refreshMonitors() {}
    function refreshWorkspaces() {}
    function refreshToplevels() {}
  }
  QtObject { id: model; property var values: [first, second] }
  QtObject { id: wsModel; property var values: [{id: 1}, {id: 2}, {id: 3}] }
  QtObject { id: monitorModel; property var values: [{name: "one", activeWorkspace: workspace2}] }
  QtObject { id: windowRefresh; property int count: 0; function restart() { count++ } }
  QtObject { id: moveSettleTimer; property int count: 0; function restart() { count++ } }
  function close() {
    requested = false
    opened = false
    pendingMoves = ({})
    optimisticActiveWorkspaceId = -1
    ignoreWorkspaceEventsUntil = 0
    windows = []
  }
ACTIVE_PROP
ACTIVE_EFFECTIVE
WS_ENTRIES
DISPLAY_ENTRIES
BINDING
WS_LOOKUP
REFRESH
SELECT_WS
SWITCH_WS
SCROLL_TO
SCROLL_BY
REVEAL_WS
DRAG_AUTOSCROLL
UPDATE_DROP
BEGIN_WS_DRAG
UPDATE_WS_DRAG
CANCEL_WS_DRAG
FINISH_WS_DRAG
MOVE_WIN
REORDER_WS
UPDATE_WS_DROP
RECONCILE
  Item {
    id: keyCatcher
    width: panel.width
    height: 160
    LayoutMirroring.enabled: root.rtl
    LayoutMirroring.childrenInherit: true
    Item {
      id: workspaceStripShell
      anchors.horizontalCenter: parent.horizontalCenter
STRIP_SHELL_PROPS
      Flickable {
        id: workspaceStripViewport
VIEWPORT_PROPS
        Row {
          id: workspaceRow
          x: 0
          y: workspaceStripViewport.vPad
ROW_PROPS
          Repeater {
            id: workspaceRepeater
            model: root.displayWorkspaceEntries
            delegate: Item {
              id: wsCard
              required property var modelData
              required property int index
              readonly property int workspaceId: modelData.id
              readonly property bool isReorderSource: root.wsDragActive && workspaceId === root.draggedWorkspaceId
              readonly property int reorderShiftSlots: root.wsDragActive && !modelData.guest && !modelData.isNewSlot
                ? OverviewModel.reorderShiftSlots(index, root.wsDragFromIndex, root.wsDragTargetIndex >= 0 ? root.wsDragTargetIndex : root.wsDragFromIndex)
                : 0
              property point wsPressPoint
              property bool wsDragMoved: false
              width: workspaceRow.cardWidth
              height: workspaceRow.cardHeight
              transform: Translate {
                id: cardTranslate
                x: WS_TRANSLATE_X
              }
WS_MOUSE
            }
          }
        }
      }
    }
  }
  Connections {
    target: fixtures
EVENTS
  }
  TestCase {
    name: "OverviewRefresh"
    when: windowShown
    function init() {
      fixtures.focusedMonitor = {name: "one"}
      wsModel.values = [{id: 1}, {id: 2}, {id: 3}]
      monitorModel.values = [{name: "one", activeWorkspace: workspace2}]
      first.workspace = workspace2
      second.workspace = workspace2
      third.workspace = otherWorkspace
      model.values = [first, second]
      root.workspaceId = 2
      root.viewedWorkspaceId = 2
      root.pendingMoves = ({})
      root.dragActive = false
      root.hoveredDropWorkspaceId = -1
      root.wsDragActive = false
      root.draggedWorkspaceEntry = null
      root.draggedWorkspaceId = -1
      root.wsDragFromIndex = -1
      root.wsDragTargetIndex = -1
      root.wsDragTargetId = -1
      root.stripAutoScrollDir = 0
      root.rtl = false
      panel.width = 1200
      styleStub.scale = 1.0
      workspaceStripViewport.contentX = 0
      root.optimisticActiveWorkspaceId = -1
      root.optimisticActiveAt = 0
      root.ignoreWorkspaceEventsUntil = 0
      root.pendingRefresh = false
      root.dispatches = []
      root.displayModelChanges = 0
      windowRefresh.count = 0
      moveSettleTimer.count = 0
      root.requested = true
      root.opened = true
      root.refresh()
      workspaceRow.forceLayout()
    }
    function test_move_and_close() {
      compare(root.windows.length, 2)
      root.selectedIndex = 1
      first.workspace = otherWorkspace
      compare(root.windows.length, 1)
      compare(root.windows[0], second)
      compare(root.selectedIndex, 0)
      first.workspace = workspace2
      compare(root.windows.length, 2)
      compare(root.selectedIndex, 1)
      model.values = [first]
      compare(root.windows.length, 1)
      compare(root.windows[0], first)
      compare(root.selectedIndex, 0)
    }
    function test_focus_changes_close() {
      fixtures.rawEvent({name: "workspacev2"})
      verify(!root.opened && !root.requested)
      init()
      fixtures.focusedMonitor = {name: "two"}
      verify(!root.opened && !root.requested)
    }
    function test_drag_move_updates_immediately_and_settles() {
      compare(root.windows.length, 2)
      root.dragActive = true
      root.refresh()
      verify(root.pendingRefresh)
      root.dragActive = false
      root.moveWindowToWorkspace(first, 3)
      compare(root.windows.length, 1)
      compare(root.windows[0], second)
      compare(root.workspaceEntryById(3).windowCount, 1)
      compare(root.dispatches.length, 1)
      verify(root.dispatches[0].indexOf('hl.dsp.window.move') === 0)
      verify(root.dispatches[0].indexOf('follow = false') > 0)
      verify(windowRefresh.count >= 1 && moveSettleTimer.count >= 1)
      first.workspace = otherWorkspace
      root.reconcilePendingMoves()
      compare(Object.keys(root.pendingMoves).length, 0)
      compare(root.workspaceEntryById(3).windowCount, 1)
    }
    function test_select_and_switch_workspace() {
      root.moveWindowToWorkspace(first, 3)
      root.dispatches = []
      root.selectWorkspace(3)
      wait(20)
      verify(!root.opened)
      compare(root.dispatches.length, 1)
      compare(root.dispatches[0], 'o.workspaces.focus(3, "one")')
    }
    function test_reorder_workspaces_preserves_focus_and_moves_windows() {
      model.values = [first, second, third]
      root.refresh()
      root.wsDragActive = true
      root.refresh()
      verify(root.pendingRefresh)
      root.wsDragActive = false
      root.reorderWorkspace(2, 1)
      compare(root.workspaceId, 1)
      compare(root.viewedWorkspaceId, 1)
      compare(root.activeHyprlandWorkspaceId, 1)
      compare(root.windows.length, 2)
      compare(root.workspaceEntryById(1).windowCount, 2)
      compare(root.workspaceEntryById(3).windowCount, 1)
      compare(root.dispatches.length, 1)
      verify(root.dispatches[0].indexOf('o.workspaces.reorder') > 0)
      verify(root.dispatches[0].indexOf('9900') > 0)
      // Self-initiated workspacev2 during reorder should not close overview.
      fixtures.rawEvent({name: "workspacev2"})
      verify(root.opened)
      // Once Hyprland finishes moving, reconcilePendingMoves clears optimistic state.
      monitorModel.values = [{name: "one", activeWorkspace: workspace1}]
      first.workspace = workspace1
      second.workspace = workspace1
      root.reconcilePendingMoves()
      compare(Object.keys(root.pendingMoves).length, 0)
      compare(root.optimisticActiveWorkspaceId, -1)
    }
    function test_rtl_workspace_drag_drop_mirrors_slots_and_translate() {
      wsModel.values = [{id: 1}, {id: 2}, {id: 3}, {id: 11, monitor: {name: "one"}}]
      root.rtl = true
      wait(0)
      // Entries: [1, 2, 3, 4, 5, 11(guest)]. In RTL Row, index 0 (slot 1) is rightmost, guest 11 is leftmost.
      var card0 = workspaceRepeater.itemAt(0)
      var card2 = workspaceRepeater.itemAt(2)
      var card4 = workspaceRepeater.itemAt(4)
      var guestCard = workspaceRepeater.itemAt(5)
      verify(card0.x > card2.x && card2.x > card4.x && card4.x > guestCard.x, "RTL Row lays out slot 1 on the right and guest on the left")

      root.wsDragFromIndex = 2
      root.wsDragActive = true
      // Dragging card 2 onto card 0's center (on the right) must target slot 1 (index 0).
      var pt0 = card0.mapToItem(keyCatcher, card0.width / 2, card0.height / 2)
      root.updateWorkspaceDropTarget(pt0)
      compare(root.wsDragTargetIndex, 0)
      compare(root.wsDragTargetId, 1)
      // In RTL, card 0 shifts left (-1 slot) and card 2 shifts right (+2 slots).
      compare(card0.transform[0].x, -(workspaceRow.cardWidth + workspaceRow.spacing))
      compare(card2.transform[0].x, 2 * (workspaceRow.cardWidth + workspaceRow.spacing))

      // Dragging card 0 leftward onto card 2 shifts card 0 left (-2) and card 2 right (+1).
      root.wsDragFromIndex = 0
      var pt2 = card2.mapToItem(keyCatcher, card2.width / 2, card2.height / 2)
      root.updateWorkspaceDropTarget(pt2)
      compare(root.wsDragTargetIndex, 2)
      compare(root.wsDragTargetId, 3)
      compare(card0.transform[0].x, -2 * (workspaceRow.cardWidth + workspaceRow.spacing))
      compare(card2.transform[0].x, workspaceRow.cardWidth + workspaceRow.spacing)

      // Dragging over the leftmost guest card must not produce a reorder target.
      var ptGuest = guestCard.mapToItem(keyCatcher, guestCard.width / 2, guestCard.height / 2)
      root.updateWorkspaceDropTarget(ptGuest)
      compare(root.wsDragTargetIndex, -1)
      compare(root.wsDragTargetId, -1)
    }
    function test_workspace_drag_keeps_card_and_completes_reorder() {
      model.values = [first, second, third]
      root.refresh()
      workspaceRow.forceLayout()
      var card0 = workspaceRepeater.itemAt(0)
      var card1 = workspaceRepeater.itemAt(1)
      verify(card1.x > card0.x, "LTR Row positions workspace 2 to the right of workspace 1")
      var start = card1.mapToItem(keyCatcher, card1.width / 2, card1.height / 2)
      var target = card0.mapToItem(keyCatcher, card0.width / 2, card0.height / 2)
      var entriesBefore = root.displayWorkspaceEntries
      root.displayModelChanges = 0

      mousePress(keyCatcher, start.x, start.y, Qt.LeftButton)
      mouseMove(keyCatcher, start.x - 16, start.y)
      verify(root.wsDragActive, "dragging past threshold starts workspace reorder")
      compare(root.displayModelChanges, 0, "starting workspace drag does not replace displayWorkspaceEntries")
      verify(root.displayWorkspaceEntries === entriesBefore, "starting workspace drag keeps the same model array")
      compare(workspaceRepeater.itemAt(1), card1, "starting workspace drag preserves the pressed card delegate")

      // A background workspace update during the drag must not rebuild the cards either.
      wsModel.values = [{id: 1}, {id: 2}, {id: 3}, {id: 4}]
      wait(0)
      compare(root.displayModelChanges, 0, "background workspace changes do not replace displayWorkspaceEntries mid-drag")
      compare(workspaceRepeater.itemAt(1), card1, "background workspace changes do not replace cards mid-drag")

      mouseMove(keyCatcher, target.x, target.y)
      compare(root.wsDragTargetIndex, 0)
      compare(root.wsDragTargetId, 1)

      mouseRelease(keyCatcher, target.x, target.y, Qt.LeftButton)
      verify(!root.wsDragActive, "releasing the dragged card finishes workspace drag")
      compare(root.workspaceId, 1)
      compare(root.dispatches.length, 1)
      verify(root.dispatches[0].indexOf('o.workspaces.reorder') > 0)

      // Canceling a drag reconciles any background workspace entry changes that arrived mid-drag.
      init()
      var cancelCard = workspaceRepeater.itemAt(1)
      var cancelStart = cancelCard.mapToItem(keyCatcher, cancelCard.width / 2, cancelCard.height / 2)
      mousePress(keyCatcher, cancelStart.x, cancelStart.y, Qt.LeftButton)
      mouseMove(keyCatcher, cancelStart.x - 16, cancelStart.y)
      verify(root.wsDragActive)
      var countBefore = root.displayWorkspaceEntries.length
      wsModel.values = [{id: 1}, {id: 2}, {id: 3}, {id: 11, monitor: {name: "one"}}]
      wait(0)
      compare(root.displayWorkspaceEntries.length, countBefore)
      root.cancelWorkspaceDrag()
      mouseRelease(keyCatcher, cancelStart.x - 16, cancelStart.y, Qt.LeftButton)
      verify(!root.wsDragActive)
      compare(root.displayWorkspaceEntries.length, countBefore + 1)
      compare(root.dispatches.length, 0)
    }
    function test_overflowing_workspace_strip_stays_onscreen_and_scrolls() {
      panel.width = 960
      styleStub.scale = 16 / 12
      wsModel.values = [{id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}]
      root.refresh()
      workspaceRow.forceLayout()
      wait(0)
      verify(workspaceStripShell.overflows, "10 workspaces at text size 16 on a 960px display overflow the strip")
      verify(workspaceStripShell.width <= workspaceStripShell.maxWidth + 0.5, "strip container stays within maxWidth")
      verify(workspaceStripShell.x >= 0 && workspaceStripShell.x + workspaceStripShell.width <= panel.width + 0.5, "strip container never leaves the screen")
      verify(workspaceStripViewport.maxContentX > 0, "overflowing strip has positive scroll range")

      // Card 10 starts offscreen in LTR; pointing outside the viewport must not hit it.
      var card10 = workspaceRepeater.itemAt(9)
      verify(card10.x + card10.width > workspaceStripViewport.width, "card 10 starts beyond the right viewport edge")
      var clippedPt = card10.mapToItem(keyCatcher, card10.width / 2, card10.height / 2)
      root.dragActive = true
      root.updateDropTarget(clippedPt)
      compare(root.hoveredDropWorkspaceId, -1, "clipped offscreen cards cannot steal window drops")

      // Dragging near the right edge requests rightward auto-scroll.
      var rightEdge = workspaceStripViewport.mapToItem(keyCatcher, workspaceStripViewport.width - 10, workspaceStripViewport.height / 2)
      compare(root.dragStripAutoScrollDir(rightEdge), 1, "dragging near the right edge auto-scrolls right")

      // Revealing workspace 10 brings card 10 into the visible viewport so drops and clicks reach it.
      root.revealWorkspaceCard(10)
      verify(workspaceStripViewport.contentX > 0, "revealing workspace 10 scrolls the strip")
      verify(card10.x >= workspaceStripViewport.contentX - 0.5, "card 10 left edge is inside viewport")
      verify(card10.x + card10.width <= workspaceStripViewport.contentX + workspaceStripViewport.width + 0.5, "card 10 right edge is inside viewport")
      var visiblePt = card10.mapToItem(keyCatcher, card10.width / 2, card10.height / 2)
      root.updateDropTarget(visiblePt)
      compare(root.hoveredDropWorkspaceId, 10, "scrolled-in card 10 accepts window drops")

      // At the right scroll bound, right auto-scroll stops and left edge auto-scrolls left.
      compare(root.dragStripAutoScrollDir(rightEdge), 0, "auto-scroll stops at the right bound")
      var leftEdge = workspaceStripViewport.mapToItem(keyCatcher, 10, workspaceStripViewport.height / 2)
      compare(root.dragStripAutoScrollDir(leftEdge), -1, "dragging near the left edge auto-scrolls left")
      root.dragActive = false

      // In RTL, revealing workspace 1 shows the rightmost card and revealing workspace 10 scrolls left.
      root.rtl = true
      workspaceRow.forceLayout()
      wait(0)
      verify(workspaceRow.LayoutMirroring.enabled, "workspaceRow inherits RTL mirroring inside Flickable")
      root.revealWorkspaceCard(1)
      var rtlCard1 = workspaceRepeater.itemAt(0)
      verify(rtlCard1.x >= workspaceStripViewport.contentX - 0.5 && rtlCard1.x + rtlCard1.width <= workspaceStripViewport.contentX + workspaceStripViewport.width + 0.5, "RTL reveal keeps workspace 1 inside the viewport")
      root.revealWorkspaceCard(10)
      var rtlCard10 = workspaceRepeater.itemAt(9)
      verify(rtlCard10.x >= workspaceStripViewport.contentX - 0.5 && rtlCard10.x + rtlCard10.width <= workspaceStripViewport.contentX + workspaceStripViewport.width + 0.5, "RTL reveal scrolls workspace 10 into the viewport")
    }
  }
}
"""
for token, snippet in [
  ("ACTIVE_PROP", active_prop),
  ("ACTIVE_EFFECTIVE", active_effective),
  ("WS_ENTRIES", ws_entries),
  ("DISPLAY_ENTRIES", display_entries),
  ("BINDING", binding),
  ("WS_LOOKUP", ws_lookup),
  ("REFRESH", refresh),
  ("SELECT_WS", select_ws),
  ("SWITCH_WS", switch_ws),
  ("SCROLL_TO", scroll_to),
  ("SCROLL_BY", scroll_by),
  ("REVEAL_WS", reveal_ws),
  ("DRAG_AUTOSCROLL", re.sub(r"\bStyle\b", "styleStub", drag_autoscroll)),
  ("UPDATE_DROP", re.sub(r"\bStyle\b", "styleStub", update_drop)),
  ("BEGIN_WS_DRAG", begin_ws_drag),
  ("UPDATE_WS_DRAG", update_ws_drag),
  ("CANCEL_WS_DRAG", cancel_ws_drag),
  ("FINISH_WS_DRAG", finish_ws_drag),
  ("MOVE_WIN", move_win),
  ("REORDER_WS", reorder_ws),
  ("UPDATE_WS_DROP", re.sub(r"\bStyle\b", "styleStub", update_ws_drop)),
  ("STRIP_SHELL_PROPS", re.sub(r"\bStyle\b", "styleStub", strip_shell_props)),
  ("VIEWPORT_PROPS", re.sub(r"\bStyle\b", "styleStub", viewport_props)),
  ("ROW_PROPS", re.sub(r"\bStyle\b", "styleStub", row_props)),
  ("WS_TRANSLATE_X", ws_translate_x),
  ("WS_MOUSE", re.sub(r"\bStyle\b", "styleStub", ws_mouse)),
  ("RECONCILE", reconcile),
  ("EVENTS", events),
]:
  qml = qml.replace(token, re.sub(r"\bHyprland\b", "fixtures", snippet))
(tmp / "tst_overview_refresh.qml").write_text(qml)
PY
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
    "$qml_runner" -input "$tmp/tst_overview_refresh.qml" -o -,txt
else
  skip "Qt6 qmltestrunner not found; skipping overview refresh test"
fi
