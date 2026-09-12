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
  /originX = barPos === "left" \? Math\.min\(missingW, barW\)/.test(panelQml) && /originY = barPos === "top" \? Math\.min\(missingH, barH\)/.test(panelQml) && !/root\.x/.test(panelQml) && !/root\.y/.test(panelQml),
  'panel cards are positioned in the inset overlay via the window origin derived from the mapped surface, not phantom root.x/root.y'
)
JS
