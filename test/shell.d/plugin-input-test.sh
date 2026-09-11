#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const scope = vm.createContext({})
vm.runInContext(fs.readFileSync(path.join(root, 'shell/services/PluginInput.js'), 'utf8'), scope)
const full = [{x: 0, y: 0, width: 800, height: 500}]
const contains = (rects, x, y) => rects.some(r => x >= r.x && y >= r.y && x < r.x + r.width && y < r.y + r.height)
const surface = fs.readFileSync(path.join(root, 'shell/services/native/SandboxedOutputSurface.qml'), 'utf8')
assert(surface.includes('PluginInput.outputPolicy(owner.opened, ownsPanel,'), 'host uses the tested output policy')
assert(surface.includes('policy.pointer') && surface.includes('policy.keyboard') && surface.includes('hostInputRegions:'), 'render, pointer and keyboard permissions are enforced separately')
for (const ownsPanel of [false, true]) {
  for (const outputs of ['owner', 'all']) {
    assertDeepEqual(JSON.parse(JSON.stringify(scope.outputPolicy(false, ownsPanel, true, 'none', outputs))),
      {render: false, pointer: false, keyboard: false}, 'closed policy denies content before and after first ownership, even with all outputs selected')
  }
}
assertDeepEqual(JSON.parse(JSON.stringify(scope.outputPolicy(true, true, true, 'none', 'owner'))),
  {render: true, pointer: true, keyboard: true}, 'an authorized own panel permits content input and keyboard focus')
assertDeepEqual(JSON.parse(JSON.stringify(scope.outputPolicy(true, false, false, 'none', 'all'))),
  {render: false, pointer: false, keyboard: false}, 'another output cannot reuse the active panel authority')
for (const mode of ['visual', 'pointer']) {
  for (const ownsOverlay of [false, true]) {
    for (const outputs of ['owner', 'all']) {
      const allowed = ownsOverlay || outputs === 'all'
      assertDeepEqual(JSON.parse(JSON.stringify(scope.outputPolicy(false, true, ownsOverlay, mode, outputs))),
        {render: allowed, pointer: allowed && mode === 'pointer', keyboard: false}, 'roaming policy independently bounds pixels and pointer input, never keyboard focus')
    }
  }
}
const sessionSource = fs.readFileSync(path.join(root, 'shell/services/native/SandboxedPluginSession.qml'), 'utf8')
const opened = sessionSource.match(/readonly property bool opened: (.*)/)[1]
const sessionScope = vm.createContext({panelAuthorized: false, error: '', panelCommand: null, session: {panelOpen: true}})
vm.runInContext('reportedOpen = ' + sessionSource.match(/readonly property bool reportedOpen: (.*)/)[1], sessionScope)
assertEqual(vm.runInContext(opened, sessionScope), false, 'unsolicited worker panel-open state grants no authority')
sessionScope.panelAuthorized = true
assertEqual(vm.runInContext(opened, sessionScope), true, 'host activation admits worker panel state')
sessionScope.panelAuthorized = false
assertEqual(vm.runInContext(opened, sessionScope), false, 'old worker-open state cannot revive a dismissed panel')
sessionScope.panelAuthorized = true
sessionScope.reportedOpen = false
vm.runInContext(sessionSource.match(/onReportedOpenChanged: \{ (.*) \}/)[1], sessionScope)
assertEqual(sessionScope.panelAuthorized, false, 'worker closure withdraws authorization without mutating the opened binding')
const claimScope = vm.createContext({
  PluginInput: scope, screenRows: [{id: 1, screen: {width: 800, height: 500}}],
  placements: [{id: 1, output: 1, bar: {position: 'top', visible: true, size: 26, x: 100, y: 0, width: 40, height: 26}}],
  activeOutputId: 1, activeViewId: 1, panelAuthorized: false, opened: false,
  panelGestureTimer: {restart() {}}
})
vm.runInContext(sessionSource.match(/  function claimOutput\(outputId, point\) \{[\s\S]*?\n  \}/)[0], claimScope)
assertEqual(claimScope.claimOutput(1, {x: 400, y: 250}), false, 'roaming presses cannot fall back to an old bar placement')
assertEqual(claimScope.panelAuthorized, false, 'roaming pointer input cannot authorize a keyboard panel')
assertEqual(claimScope.claimOutput(1, {x: 120, y: 13}), true, 'a real own-slot press can authorize its panel')
assertEqual(claimScope.panelAuthorized, true, 'slot gesture authorizes its own panel')
for (const position of ['top', 'bottom', 'left', 'right']) {
  const vertical = position === 'left' || position === 'right'
  const bar = {position, visible: true, size: 26, x: vertical ? 0 : 100, y: vertical ? 100 : 0,
    width: vertical ? 26 : 40, height: vertical ? 40 : 26}
  const edge = position === 'bottom' ? 487 : position === 'right' ? 787 : 13
  const point = along => vertical ? [edge, along] : [along, edge]
  const mask = scope.barMasks(full, [bar], 800, 500, true)
  assert(contains(mask, ...point(120)), position + ' preserves the own slot')
  assert(!contains(mask, ...point(80)) && !contains(mask, ...point(160)), position + ' leaves neighbors click-through')
  assert(contains(mask, 400, 250), position + ' preserves panel and dismissal input')
  assertEqual(scope.barMasks([], [bar], 800, 500, true).length, 0, position + ' never invents input')
  const partial = [{x: 400, y: 240, width: 20, height: 20}]
  assertDeepEqual(JSON.parse(JSON.stringify(scope.barMasks(partial, [bar], 800, 500, true))), partial, position + ' preserves sparse masks')
  assertDeepEqual(JSON.parse(JSON.stringify(scope.barMasks(full, [{...bar, visible: false}], 800, 500, true))), full, position + ' releases a hidden bar strip')
  const closed = scope.barMasks(full, [bar], 800, 500, scope.outputPolicy(false, true, true, 'none', 'owner').pointer)
  assert(contains(closed, ...point(120)) && !contains(closed, 400, 250), position + ' closed-after-open retains only its slot')
}
pass('host bar input isolation on all four edges')
const bars = [
  {position: 'top', visible: true, size: 26, x: 100, y: 0, width: 40, height: 26},
  {position: 'top', visible: true, size: 26, x: 200, y: 0, width: 40, height: 26},
  {position: 'right', visible: true, size: 26, x: 0, y: 100, width: 26, height: 40},
  {position: 'bottom', visible: false, size: 26, x: 300, y: 0, width: 40, height: 26}
]
for (const allowed of [true, false]) {
  const masks = scope.barMasks(full, bars, 800, 500, allowed)
  assert(contains(masks, 120, 13) && contains(masks, 220, 13) && contains(masks, 787, 120), 'multiple own placements form a union')
  assert(!contains(masks, 170, 13) && !contains(masks, 787, 170), 'all neighboring bar slots remain click-through')
  assertEqual(contains(masks, 400, 250), allowed, 'non-owner output suppresses panel input unless roaming is approved')
  assertEqual(scope.barMasks([], bars, 800, 500, allowed).length, 0, 'multiple slots cannot invent worker input')
}
assertEqual(scope.barMasks(full, [], 800, 500, false).length, 0, 'unplaced non-owner output has no input')
assertDeepEqual(JSON.parse(JSON.stringify(scope.barMasks(full, [], 800, 500, true))), full, 'unplaced approved output preserves worker input')
const outside = [{...bars[0], x: -10, width: 20}]
assertDeepEqual(JSON.parse(JSON.stringify(scope.barSlots(outside, 800, 500))), [{x: 0, y: 0, width: 10, height: 26}], 'slots clip to output bounds')
assertEqual(scope.barMasks(Array(513).fill(full[0]), [], 800, 500, true).length, 0, 'mask complexity fails closed')
JS
