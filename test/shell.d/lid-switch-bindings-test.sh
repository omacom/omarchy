#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const utilities = fs.readFileSync(path.join(root, 'default/hypr/bindings/utilities.lua'), 'utf8')

// Hyprland compares a switch bind against the device name byte for byte and
// offers no wildcard, so a lid reporting any other name never fires at all.
// These assert whole literal lines rather than a pattern on purpose: a
// near-miss in this string is indistinguishable from having no bind.
const edges = [
  ['on', 'omarchy-system-lid-close'],
  ['off', 'omarchy-hyprland-monitor-clamshell'],
]

// "Lid Switch" is what a typical ACPI laptop reports; Apple Silicon exposes the
// same SW_LID switch as "Apple SMC power/lid events" and never as the former.
const devices = ['Lid Switch', 'Apple SMC power/lid events']

for (const device of devices) {
  for (const [edge, handler] of edges) {
    // locked = true is part of the contract, not decoration: without it the
    // bind is skipped exactly when the lid closes on an already-locked session.
    const bind = `o.bind("switch:${edge}:${device}", nil, "${handler}", { locked = true })`

    assert(
      utilities.includes(bind),
      `${device} binds ${edge} to ${handler} and fires while locked`,
      `missing line: ${bind}`
    )
  }
}
JS
