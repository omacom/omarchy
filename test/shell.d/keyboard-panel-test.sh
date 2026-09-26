#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelQml = fs.readFileSync(path.join(root, 'shell/Ui/KeyboardPanel.qml'), 'utf8')

assert(
  /exclusionMode: ExclusionMode\.Auto/.test(panelQml),
  'bar panels respect the reserved area of an on-screen keyboard'
)
assert(
  !/exclusionMode: ExclusionMode\.Ignore/.test(panelQml),
  'bar panels do not cover exclusive zones (OSK taps would dismiss the popdown)'
)
assert(
  /WlrLayershell\.keyboardFocus: open/.test(panelQml) &&
    /focusPrimed \? WlrKeyboardFocus\.OnDemand : WlrKeyboardFocus\.Exclusive/.test(panelQml),
  'bar panels settle on OnDemand keyboard focus so pointer input can reach an OSK'
)
assert(
  /localX = x - root\.originX/.test(panelQml) && /localY = y - root\.originY/.test(panelQml),
  'panel cards are positioned in the inset overlay, not double-offset by the bar exclusive zone'
)
assert(
  !/root\.x/.test(panelQml) && !/root\.y/.test(panelQml),
  'panel positioning never reads PanelWindow x/y (undefined there, NaNs the card origin to top-left)'
)
assert(
  /insetOverlay: backingWindowVisible/.test(panelQml),
  'panel overlay measurements wait for the mapped surface instead of trusting pre-map geometry'
)
JS
