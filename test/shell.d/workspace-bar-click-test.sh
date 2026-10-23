#!/bin/bash

# A workspace click focuses that workspace. It uses the same per-monitor path
# as Super + number, and a second click on the one already showing does not
# cycle the layout. Super + L still does.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = name => fs.readFileSync(path.join(root, name), 'utf8')
const widget = read('shell/plugins/bar/widgets/Workspaces.qml')
const tiling = read('default/hypr/bindings/tiling.lua')
const navigation = read('manual/04-navigation.md')
const bar = read('manual/05-the-top-bar.md')

function body(source, signature) {
  const start = source.indexOf(signature)
  assert(start !== -1, `${signature} is present`)
  const open = source.indexOf('{', start)
  let depth = 0
  for (let i = open; i < source.length; i++) {
    if (source[i] === '{') depth++
    else if (source[i] === '}') {
      depth--
      if (depth === 0) return source.slice(open + 1, i)
    }
  }
  fail(`${signature} has a body`)
}

const focus = body(widget, 'function focusWorkspace(id)')
assert(
  focus.includes('if (root.blockOf(id) === root.block)') &&
    focus.includes('root.dispatch("o.workspaces.focus(" + root.slotOf(id) + ", \\"" + root.monitorName + "\\")")'),
  'a workspace of this monitor is focused by its slot, the same way Super + number does'
)
assert(
  focus.includes('root.dispatch("hl.dsp.focus({ workspace = \\"" + id + "\\" })")'),
  'a workspace visiting from another monitor is focused by its id'
)
assert(
  focus.indexOf('o.workspaces.focus') < focus.indexOf('hl.dsp.focus'),
  'the slot path is the one for this monitor, and the id path is the other'
)

const press = widget.match(/onPressed: function\(\) \{([^}]*)\}/)
assert(press, 'the workspace button has one press handler')
assertEqual(press[1].trim(), 'root.focusWorkspace(modelData)', 'a click focuses that workspace')
assert(!widget.includes('cycleLayout'), 'a click does not cycle the layout')
assert(
  widget.includes('text: shown ? root.modeGlyph(root.activeMode)'),
  'the workspace showing keeps its layout mark'
)
assert(
  widget.includes('if (target !== ids[index]) root.focusWorkspace(target)'),
  'scrolling the row focuses the workspace it lands on'
)

assert(
  tiling.includes('o.bind("SUPER + L", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-toggle")'),
  'Super + L still cycles the layout'
)
assert(
  tiling.includes('o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, o.workspaces.focus(workspace))'),
  'Super + number focuses a slot on the monitor you are on'
)

assert(
  navigation.includes('Clicking a workspace focuses it on that monitor.'),
  'the navigation manual says a click focuses the workspace on that monitor'
)
assert(
  !navigation.includes('Clicking that mark cycles'),
  'the navigation manual no longer says clicking the mark cycles the layout'
)
assert(
  bar.includes('| Workspaces | Focus that workspace on this monitor |'),
  'the top bar manual says a click focuses that workspace on this monitor'
)
JS
