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
  {address: 'a', workspace: {id: 2}, wayland: {title: 'One'}},
  {address: 'b', workspace: {id: 2}, wayland: {title: 'Two'}},
  {address: 'dialog', workspace: {id: 2}, wayland: {parent: {}}},
  {address: 'other', workspace: {id: 3}, wayland: {}},
  {address: 'minimized', workspace: {id: -99}, wayland: {}}
]
assertDeepEqual(overview.windowsOnWorkspace(windows, 2).map(w => w.address), ['a', 'b'], 'overview selects top-level windows only on its workspace')
assertEqual(overview.selectionAfterChange(windows, 1, [windows[1]]), 0, 'selection follows window identity after a preceding window closes')
assertEqual(overview.selectionAfterChange(windows, 1, [windows[0]]), 0, 'closing the selected window selects a remaining window')
assertEqual(overview.selectionAfterChange(windows, 1, []), -1, 'empty overview has no selection')
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
binding = re.search(r"  readonly property var matchingWindows:[\s\S]*?\n  onMatchingWindowsChanged:[^\n]+", source)[0]
refresh = re.search(r"  function refresh\(\) \{[\s\S]*?\n  \}", source)[0]
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
  QtObject { id: workspaceTwo; property int number: 2 }
  QtObject { id: workspaceThree; property int number: 3 }
  QtObject { id: first; property string address: "a"; property var workspace: workspace2; property var wayland: ({}) }
  QtObject { id: second; property string address: "b"; property var workspace: workspace2; property var wayland: ({}) }
  property var workspace2: ({id: workspaceTwo.number})
  property var otherWorkspace: ({id: workspaceThree.number})

  QtObject {
    id: fixtures
    property var toplevels: model
    property var focusedMonitor: ({name: "one"})
    signal rawEvent(var event)
  }
  QtObject { id: model; property var values: [first, second] }
  function close() { requested = false; opened = false; windows = [] }
BINDING
REFRESH
  Connections {
    target: fixtures
EVENTS
  }
  TestCase {
    name: "OverviewRefresh"
    function init() {
      fixtures.focusedMonitor = {name: "one"}
      first.workspace = workspace2
      second.workspace = workspace2
      model.values = [first, second]
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
  }
}
"""
(tmp / "tst_overview_refresh.qml").write_text(qml.replace("BINDING", binding.replace("Hyprland", "fixtures")).replace("REFRESH", refresh).replace("EVENTS", events.replace("Hyprland", "fixtures")))
PY
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
    "$qml_runner" -input "$tmp/tst_overview_refresh.qml" -o -,txt
else
  skip "Qt6 qmltestrunner not found; skipping overview refresh test"
fi
