#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/bar/widgets/Workspaces.qml'), 'utf8')

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
  /Hyprland\.monitors\.values/.test(qml),
  'the clicked screen is matched against Hyprland monitor names before dispatch'
)
JS
