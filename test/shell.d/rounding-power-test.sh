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
assert(/function refresh\(\)\s*\{[\s\S]*?roundingPowerProc.running = true/.test(style),
  'rounding power follows the existing shell refresh lifecycle')
assert(style.includes('["hyprctl", "-j", "getoption", "decoration:rounding_power"]'),
  'rounding power reads the Hyprland float option')
const surface = fs.readFileSync(path.join(root, 'shell/Ui/BorderSurface.qml'), 'utf8')
assert(surface.includes('roundingPower: root.roundingPower') && surface.includes('radius: root.effectiveRadius'), 'border and fill use the same effective radius and rounding power')
const corner = fs.readFileSync(path.join(root, 'shell/Ui/CornerRectangle.qml'), 'utf8')
assert(corner.includes('Geometry.effectiveRadius(radius, roundingPower)')
  && corner.includes('Geometry.surfacePath(root.width, root.height, root.effectiveRadius, root.roundingPower)'),
  'custom corners scale the configured radius once')
assert(corner.includes('active: root.border.width > 0'), 'borderless custom corners do not construct an unused overlay')
for (const [file, marker] of [
  ['shell/plugins/panels/elsewhen/CityRow.qml', 'CornerRectangle {'],
  ['shell/plugins/panels/elsewhen/Globe.qml', '// Results overlay the globe so it never resizes under the pointer mid-search.\n  CornerRectangle {'],
]) {
  assert(fs.readFileSync(path.join(root, file), 'utf8').includes(marker), `${file} follows theme-shaped corners`)
}
for (const file of ['shell/Ui/ToggleSwitch.qml', 'shell/Ui/PanelSlider.qml', 'shell/plugins/panels/tailscale/TailscaleIcon.qml']) {
  assert(fs.readFileSync(path.join(root, file), 'utf8').includes('roundingPower: 2'), `${file} preserves intentional circular geometry`)
}
JS
