#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/bar/widgets/Workspaces.qml'), 'utf8')

const handler = qml.match(/onPressed: function\(button\) \{([^}]+)\}/)
assert(handler, 'workspace buttons receive the pressed mouse button')
const calls = []
const widget = {
  focusWorkspaceOnClickedMonitor: id => calls.push(['pull', id]),
  focusWorkspace: id => calls.push(['focus', id]),
  cycleLayout: () => calls.push(['cycle']),
}
const press = new Function('button', 'focused', 'root', 'Qt', 'modelData', handler[1])
press(4, true, widget, {MiddleButton: 4}, 3)
press(1, true, widget, {MiddleButton: 4}, 3)
press(1, false, widget, {MiddleButton: 4}, 3)
assert(JSON.stringify(calls) === JSON.stringify([['pull', 3], ['cycle'], ['focus', 3]]),
  'middle-click pulls even a focused workspace; left-click cycles the focused layout or focuses another workspace')

const pullFunction = qml.match(/function focusWorkspaceOnClickedMonitor\(id\) \{([\s\S]*?)\n  \}/)
assert(pullFunction, 'the production pull function is available to exercise')
const commands = []
const bar = {run: command => commands.push(command)}
const pullWidget = {bar, clickedMonitorName: () => 'DP-2'}
const pull = new Function('id', 'root', 'Util', pullFunction[1])
const util = {shellQuote: value => "'" + value.replace(/'/g, "'\\''") + "'"}
pull(3, pullWidget, util)
assert(commands.length === 1 && commands[0] ===
  `hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-2" })' && hyprctl dispatch 'hl.dsp.focus({ workspace = "3", on_current_monitor = true })'`,
  'pull focuses the clicked monitor before dispatching the workspace, conditional on success')
commands.length = 0
pullWidget.clickedMonitorName = () => ''
pull(3, pullWidget, util)
assert(commands.length === 1 && commands[0] ===
  `hyprctl dispatch 'hl.dsp.focus({ workspace = "3", on_current_monitor = true })'`,
  'without a resolved monitor the pull dispatch targets the current monitor directly')
commands.length = 0
pullWidget.bar = null
pull(3, pullWidget, util)
assert(commands.length === 0, 'a detached widget does not dispatch a pull')

assert(
  /function focusWorkspaceOnClickedMonitor/.test(qml),
  'workspace buttons expose a pull-to-clicked-monitor action'
)
assert(
  /button === Qt\.MiddleButton/.test(qml) &&
    /root\.focusWorkspaceOnClickedMonitor\(modelData\)/.test(qml),
  'middle-click pulls the tag onto the clicked monitor'
)
assert(
  /else root\.focusWorkspace\(modelData\)/.test(qml),
  'left-click keeps Hyprland default workspace focus'
)
assert(
  /on_current_monitor = true/.test(qml),
  'the pull dispatch asks Hyprland to show the tag on the current monitor'
)
assert(
  /Hyprland\.monitorFor/.test(qml),
  'the clicked screen is mapped to a Hyprland monitor before dispatch'
)
JS
