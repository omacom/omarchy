#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
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

const qml = fs.readFileSync(path.join(root, 'shell/services/BrightnessKeys.qml'), 'utf8')
assert(
  qml.includes('if (!/^(eDP|LVDS|DSI)-/.test(name) || !device) return false'),
  'brightness keys act in the shell only on the internal panel and defer external and Apple displays to the script'
)
assert(
  /if \(setProc\.running\) return true/.test(qml),
  'brightness keys drop a press that overlaps one still being applied, as the script does'
)
assert(
  /file\.reload\(\)\s*file\.waitForJob\(\)/.test(qml),
  'brightness keys read the current level fresh, so a level changed elsewhere steps from the right place'
)
assert(
  qml.includes('var current = Math.round(100 * readNumber(brightnessFile) / max)') &&
    qml.includes('var percent = Math.round(100 * readNumber(brightnessFile) / max)'),
  'brightness keys compute percentages as brightnessctl reports them'
)

const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
assert(
  /if \(!shell\.brightnessKeys\.handle\(entry\.target\)\)\s*Util\.execArgv\(\["omarchy-brightness-display", entry\.target === "raise" \? "\+5%" : "5%-"\]\)/.test(shellQml),
  'a brightness key the shell declines runs omarchy-brightness-display'
)
JS
