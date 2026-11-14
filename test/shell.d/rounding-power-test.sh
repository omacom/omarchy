#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const style = fs.readFileSync(path.join(root, 'shell/Commons/Style.qml'), 'utf8')
const body = style.match(/  function applyRoundingPowerJson\(raw\) \{([\s\S]*?)\n  \}/)[1]
const context = { cornerRoundingPower: 2 }
vm.createContext(context)
vm.runInContext(`function apply(raw) {${body}\n}`, context)
for (const power of [1, 1.5, 2, 4, 10]) {
  context.apply(JSON.stringify({ float: power }))
  assertEqual(context.cornerRoundingPower, power, `Style accepts rounding power ${power}`)
}
for (const [raw, expected] of [['{"float":0}', 1], ['{"float":0.5}', 1], ['{"float":11}', 10]]) {
  context.apply(raw)
  assertEqual(context.cornerRoundingPower, expected, `Style clamps out-of-range power ${raw}`)
}
for (const raw of ['', 'bad json', '{}', 'null', '{"float":null}', '{"float":"1"}', '{"int":1}']) {
  context.apply(raw)
  assertEqual(context.cornerRoundingPower, 10, `Style preserves previous power for ${JSON.stringify(raw)}`)
}
JS
