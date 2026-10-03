#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Run the widget's actual functions with monitor/workspace fixtures, without
# requiring a compositor or duplicating the filtering implementation.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const source = fs.readFileSync(path.join(root, 'shell/plugins/bar/widgets/Workspaces.qml'), 'utf8')
const base = fs.readFileSync(path.join(root, 'shell/Ui/BarWidget.qml'), 'utf8')
const context = vm.createContext({
  settings: {},
  QsWindow: { window: { screen: { name: 'DP-9' } } },
  Hyprland: { workspaces: { values: [] } }
})
context.root = context

function loadFunction(qml, name) {
  const fn = qml.match(new RegExp(`  function ${name}\\([^]*?\\n  }`))
  if (!fn) fail(`QML provides ${name}`)
  vm.runInContext(fn[0], context)
}

loadFunction(base, 'setting')
for (const name of ['barScreenName', 'monitorWorkspaceIds', 'workspaceIds']) loadFunction(source, name)

function check(expected, description) {
  assertDeepEqual(context.workspaceIds(), expected, description)
}

check([1, 2, 3, 4, 5], 'an unset monitorOnly setting keeps workspace buttons 1–5 with no reported workspaces')

const left = { name: 'DP-9' }
const right = { name: 'DP-10' }
const workspaces = [
  { id: 10, monitor: left },
  { id: 7, monitor: right },
  { id: -99, monitor: left },
  { id: 2, monitor: right },
  { id: 6, monitor: left },
  { id: 11, monitor: left },
  { id: 0, monitor: right },
  { id: 1, monitor: left },
  { id: 3, monitor: null }
]
context.Hyprland.workspaces.values = workspaces
check([1, 2, 3, 4, 5, 6, 7, 10], 'the default includes workspaces on both monitors in numeric order without duplicate buttons')

context.settings = { monitorOnly: false }
check([1, 2, 3, 4, 5, 6, 7, 10], 'explicitly disabling monitorOnly preserves the default list')

context.settings = { monitorOnly: true }
check([1, 6, 10], 'monitorOnly filters the left bar to its monitor and workspace IDs 1–10')

context.QsWindow.window.screen.name = 'DP-10'
check([2, 7], 'monitorOnly filters the right bar and omits workspaces without a monitor')

workspaces.find(ws => ws.id === 6).monitor = right
check([2, 6, 7], 'a workspace reassigned to this monitor appears in its list')
context.QsWindow.window.screen.name = 'DP-9'
check([1, 10], 'a workspace reassigned away from this monitor leaves its list')

context.QsWindow.window.screen.name = 'HDMI-A-1'
check([], 'a monitor with no matching workspaces has no workspace buttons')

for (const [description, window] of [
  ['no attached window', undefined],
  ['no window surface', {}],
  ['no screen', { window: {} }],
  ['an unnamed screen', { window: { screen: { name: '' } } }]
]) {
  context.QsWindow = window
  check([1, 2, 3, 6, 7, 10], `${description} falls back to all reported workspace IDs 1–10`)
}

context.Hyprland.workspaces.values = []
context.QsWindow = { window: { screen: { name: 'DP-9' } } }
check([], 'monitorOnly does not invent buttons when Hyprland reports no workspaces')

context.settings = {}
check([1, 2, 3, 4, 5], 'removing monitorOnly restores the default workspace buttons')
JS
