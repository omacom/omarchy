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
assert(op1 && plan.luaDispatch.includes(`change_id({ workspace = "1", id = ${op1.tempId} })`) && plan.luaDispatch.includes(`change_id({ workspace = "${op1.tempId}", id = 2 })`), 'luaDispatch stages through temp workspace IDs before final placement')
assertEqual(overview.reorderWorkspacePlan(wsEntries, 3, 3, [], wsWins, {}), null, 'reorderWorkspacePlan returns null for no-op reorder')
assertEqual(overview.reorderWorkspacePlan(wsEntries, 6, 1, [], wsWins, {}), null, 'reorderWorkspacePlan ignores non-draggable slots such as +6')

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

qml_runner=/usr/lib/qt6/bin/qmltestrunner
[[ -x $qml_runner ]] || qml_runner=/usr/lib/qt6/qmltestrunner
if [[ -x $qml_runner ]]; then
  cp "$ROOT/shell/plugins/window-overview/OverviewModel.js" "$tmp/"
  python - "$ROOT" "$tmp" <<'PY'
from pathlib import Path
import re, sys

root, tmp = map(Path, sys.argv[1:])
source = (root / "shell/plugins/window-overview/Overview.qml").read_text()
ws_entries = re.search(r"  readonly property var workspaceEntries:[\s\S]*?\n    : \[\]", source)[0]
display_entries = re.search(r"  readonly property var displayWorkspaceEntries:[\s\S]*?\n    : workspaceEntries", source)[0]
active_prop = re.search(r"  readonly property int hyprlandActiveWorkspaceId:[\s\S]*?\n  \}", source)[0]
active_effective = re.search(r"  readonly property int activeHyprlandWorkspaceId:[\s\S]*?\n    : hyprlandActiveWorkspaceId", source)[0]
binding = re.search(r"  readonly property var matchingWindows:[\s\S]*?\n  onMatchingWindowsChanged:[^\n]+", source)[0]
ws_lookup = re.search(r"  function workspaceEntryById\(id\) \{[\s\S]*?\n  \}", source)[0]
refresh = re.search(r"  function refresh\(\) \{[\s\S]*?\n  \}", source)[0]
select_ws = re.search(r"  function selectWorkspace\(targetId\) \{[\s\S]*?\n  \}", source)[0]
switch_ws = re.search(r"  function switchToWorkspace\(targetId\) \{[\s\S]*?\n  \}", source)[0]
move_win = re.search(r"  function moveWindowToWorkspace\(window, targetWorkspaceId\) \{[\s\S]*?\n  \}", source)[0]
reorder_ws = re.search(r"  function reorderWorkspace\(sourceWorkspaceId, targetWorkspaceId\) \{[\s\S]*?\n  \}", source)[0]
reconcile = re.search(r"  function reconcilePendingMoves\(\) \{[\s\S]*?\n  \}", source)[0]
events = re.search(r"    function onFocusedMonitorChanged\(\) \{[\s\S]*?\n    function onRawEvent\(event\) \{[\s\S]*?\n    \}", source)[0]

qml = """import QtQuick
import QtTest
import "OverviewModel.js" as OverviewModel

Item {
  id: root
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
  property bool wsDragActive: false
  property var frozenWorkspaceEntries: null
  property int optimisticActiveWorkspaceId: -1
  property double optimisticActiveAt: 0
  property double ignoreWorkspaceEventsUntil: 0
  property bool pendingRefresh: false
  property var dispatches: []

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
MOVE_WIN
REORDER_WS
RECONCILE
  Connections {
    target: fixtures
EVENTS
  }
  TestCase {
    name: "OverviewRefresh"
    function init() {
      fixtures.focusedMonitor = {name: "one"}
      monitorModel.values = [{name: "one", activeWorkspace: workspace2}]
      first.workspace = workspace2
      second.workspace = workspace2
      third.workspace = otherWorkspace
      model.values = [first, second]
      root.workspaceId = 2
      root.viewedWorkspaceId = 2
      root.pendingMoves = ({})
      root.dragActive = false
      root.wsDragActive = false
      root.frozenWorkspaceEntries = null
      root.optimisticActiveWorkspaceId = -1
      root.optimisticActiveAt = 0
      root.ignoreWorkspaceEventsUntil = 0
      root.pendingRefresh = false
      root.dispatches = []
      windowRefresh.count = 0
      moveSettleTimer.count = 0
      root.requested = true
      root.opened = true
      root.refresh()
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
      verify(root.dispatches[0].indexOf('change_id') > 0)
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
    ("MOVE_WIN", move_win),
    ("REORDER_WS", reorder_ws),
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
