#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const src = fs.readFileSync(root + '/shell/plugins/bar/widgets/Workspaces.qml', 'utf8')

// The real guard helper, extracted from the component.
const helperBody = src.match(/function activeWorkspaceId\(\) \{([\s\S]*?)\n  \}/)[1]
const activeWorkspaceId = new Function('root', helperBody)

// The per-button `shown` binding, extracted from the source so the test
// exercises exactly the line that shipped.
const shownExpr = src.match(/readonly property bool shown: (.*)/)[1]
const shown = new Function('root', 'modelData', 'return (' + shownExpr + ')')

function shownFor(monitor, modelData) {
  const widget = { monitor }
  widget.activeWorkspaceId = () => activeWorkspaceId(widget)
  return shown(widget, modelData)
}

// The issue's crash window: the monitor object still exists after an output
// drop, but Quickshell hands back an undefined activeWorkspace.
let crashed = null
let undefinedResult
try {
  undefinedResult = shownFor({ activeWorkspace: undefined }, 2)
} catch (e) {
  crashed = e.message
}
assert(crashed === null, 'shown does not throw when activeWorkspace is undefined', crashed || '')
assertEqual(undefinedResult, false, 'an undefined activeWorkspace marks no workspace shown')

assertEqual(shownFor({ activeWorkspace: { id: 3 } }, 3), true, "the monitor's active workspace is shown")
assertEqual(shownFor({ activeWorkspace: { id: 3 } }, 4), false, 'other workspaces are not shown')
assertEqual(shownFor({ activeWorkspace: null }, 2), false, 'a null activeWorkspace marks no workspace shown')
assertEqual(shownFor(null, 2), false, 'no monitor marks no workspace shown')
JS
