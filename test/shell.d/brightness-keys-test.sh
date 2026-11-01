#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/services/BrightnessModel.js')

// The in-shell brightness keys follow omarchy-brightness-display's steps.
const steps = [
  ['raise', 60, 65], ['lower', 60, 55],
  ['raise', 4, 5], ['raise', 5, 10], ['lower', 5, 4], ['lower', 6, 1],
  ['raise', 98, 100], ['raise', 100, 100], ['lower', 1, 1], ['lower', 2, 1],
]
for (const [action, current, target] of steps) {
  assertEqual(model.brightnessKeyTarget(action, current), target, `brightness ${action} from ${current}% lands on ${target}%`)
}
JS
