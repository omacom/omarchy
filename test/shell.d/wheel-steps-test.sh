#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const utilQml = fs.readFileSync(path.join(root, 'shell/Commons/Util.qml'), 'utf8')
const wheelStepsSource = utilQml.match(/  function wheelSteps\(accumulator, delta\) \{[\s\S]*?\n  \}\n/)
assert(wheelStepsSource, 'Util.qml defines wheelSteps')

const util = {}
vm.createContext(util)
vm.runInContext(wheelStepsSource[0], util)

// Feed a stream of angleDelta.y values through wheelSteps the way the
// handlers do, returning the steps each event produced.
function scroll(deltas) {
  let accumulator = 0
  return deltas.map(delta => {
    const result = util.wheelSteps(accumulator, delta)
    accumulator = result.remainder
    return result.steps
  })
}

function total(steps) {
  return steps.reduce((sum, step) => sum + step, 0)
}

assertDeepEqual(scroll([120]), [1], 'one classic wheel notch is one step')
assertDeepEqual(scroll([-120, -120]), [-1, -1], 'each classic wheel notch is one step')
assertDeepEqual(scroll([600]), [1], 'an oversized notch is still one step')

// High-resolution wheels (e.g. Logitech MX Master) split one notch into
// several smaller events that add up to 120.
assertDeepEqual(scroll([24, 24, 24, 24, 24]), [0, 0, 0, 0, 1], 'a high-resolution notch is one step, not one per event')
assertEqual(total(scroll(Array(12).fill(-20))), -2, 'two high-resolution notches are two steps')

assertEqual(total(scroll(Array(30).fill(8))), 2, 'touchpad deltas accumulate into whole steps')
assertDeepEqual(scroll([60, -24, -24, -24, -24, -24]), [0, 0, 0, 0, 0, -1], 'reversing direction discards the partial notch')

// Every wheel handler that steps a discrete value must go through wheelSteps;
// stepping on the sign of each event fires once per high-resolution event.
const handlers = [
  'shell/Ui/PanelSlider.qml',
  'shell/plugins/bar/widgets/Microphone.qml',
  'shell/plugins/panels/audio/Panel.qml',
  'shell/plugins/panels/clock/Panel.qml',
  'shell/plugins/panels/monitor/Panel.qml',
  'shell/plugins/services/media/BarWidget.qml'
]

for (const file of handlers) {
  const source = fs.readFileSync(path.join(root, file), 'utf8').replace(/^\s*\/\/.*$/gm, '')
  assert(/Util\.wheelSteps\(root\.wheelAccumulator, /.test(source), `${file} steps the wheel through wheelSteps`)
  assert(/var (\w+) = Util\.wheelSteps\(root\.wheelAccumulator, .*\n\s*root\.wheelAccumulator = \1\.remainder\n/.test(source), `${file} carries the wheel remainder to the next event`)
  assert(!/angleDelta\.y [<>] 0/.test(source), `${file} does not step on the sign of each wheel event`)
}
JS
