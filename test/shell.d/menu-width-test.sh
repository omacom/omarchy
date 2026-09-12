#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')
const context = vm.createContext({})
context.root = context
for (const name of ['scheduleWidthUpdate', 'measureRowWidth', 'rowListWidth', 'setFilter', 'setActiveMenu', 'openExistingMenu', 'openDmenu']) {
  const match = qml.match(new RegExp(`  function ${name}\\([^)]*\\) \\{[\\s\\S]*?\\n  \\}`))
  assert(match, `menu exposes ${name}`)
  vm.runInContext(match[0], context)
}

// Execute the production handlers with a controlled clock and model. Count
// font probes as well as width changes: delaying only the latter still does
// the expensive measurement work on each keystroke or partial model rebuild.
let now = 0, deadline = null, probes = 0
let rows = ['Short']
const timer = qml.match(/Timer \{\s*id: widthTimer([\s\S]*?)\n  \}/)[1]
const interval = Number(timer.match(/interval: (\d+)/)[1])
assertEqual(interval, 1000, 'menu waits one second after the last edit')
const trigger = timer.match(/onTriggered: (.*)/)[1]
const layoutHandler = qml.match(/onLayoutSerialChanged: (.*)/)[1]
const closedHandler = qml.match(/onOpenedChanged: (.*)/)[1]
const noop = () => {}
Object.assign(context, {
  opened: true, dmenuActive: false, mode: 'menu', filterText: '',
  activeMenu: 'root', navStack: [], requestSerial: 0, widestLabelWidth: 0,
  widthTimer: {
    get running() { return deadline !== null },
    restart() { deadline = now + interval },
    stop() { deadline = null }
  },
  displayModel: { get count() { return rows.length }, get: i => ({ label: rows[i] }) },
  labelMetrics: { advanceWidth(label) { probes++; return label.length * 10 } },
  panel: { freezeCardTop: noop }, Qt: { callLater: noop },
  disarmPointer: noop, loadProvidersForSearch: noop, loadProviderForMenu: noop,
  invalidateVolatileProvider: noop, evaluateGuards: noop, item: () => ({}),
  rebuildDisplay() { vm.runInContext(layoutHandler, context) },
  Style: { space: n => n }, Border: { left: spec => spec.left, right: spec => spec.right },
  contentMargin: 12, borderSpec: { left: 9, right: 11 },
  rowReservedBorderLeft: 2, rowReservedBorderRight: 3
})
function advance(ms) {
  now += ms
  if (deadline !== null && now >= deadline) {
    deadline = null
    vm.runInContext(trigger, context)
  }
}
context.rebuildDisplay()
assertEqual(context.widestLabelWidth, 50, 'opening measures the completed menu immediately')
const initialProbes = probes
rows = ['A much longer result']
context.setFilter('a')
advance(600)
context.setFilter('ab')
advance(600)
assertEqual(probes, initialProbes, 'typing across a second does not measure while edits continue')
assertEqual(context.widestLabelWidth, 50, 'width stays stable while typing')
rows = ['Newest provider result is longer']
context.rebuildDisplay()
advance(999)
assertEqual(probes, initialProbes, 'provider refreshes during search also defer measurements')
advance(1)
assertEqual(context.widestLabelWidth, rows[0].length * 10, 'one idle update measures the latest rows even with the same result count')
assertEqual(probes, initialProbes + 1, 'only one measurement follows the typing burst')

rows = ['Short']
context.setFilter('')
advance(999)
assert(context.widestLabelWidth > 50, 'deleting the final character also holds the width')
advance(1)
assertEqual(context.widestLabelWidth, 50, 'clearing search shrinks after the idle interval')
rows = []
context.setFilter('no matches')
advance(1000)
assertEqual(context.rowListWidth(context.widestLabelWidth), 0, 'empty results fall back to the minimum card width')

rows = ['Navigated menu']
context.setFilter('pending')
context.setActiveMenu('setup', true, false)
assertEqual(context.widestLabelWidth, rows[0].length * 10, 'navigation measures immediately despite a pending search resize')
assertEqual(deadline, null, 'navigation cancels the old search timer')
context.setFilter('pending again')
context.opened = false
vm.runInContext(closedHandler, context)
assertEqual(deadline, null, 'closing cancels the pending resize')
rows = ['Reopened']
context.openExistingMenu('root')
assertEqual(context.widestLabelWidth, 80, 'reopening measures the fresh menu immediately')
context.setFilter('pending dmenu')
context.dmenuActive = true
const beforeDmenu = probes
context.openDmenu({ options: ['Choice'], width: 420 })
advance(1000)
assertEqual(probes, beforeDmenu, 'dmenu never measures dynamic label widths')
assertEqual(deadline, null, 'opening dmenu cancels pending menu measurements')

assertEqual(context.rowListWidth(50.5), 50 + 1 + 24 + 20 + 2 + 8 + 36 + 6 + 6 + 14 + 3 + 8, 'width includes asymmetric card borders and row gutters')
const binding = qml.match(/property int cardWidth: (.*)/)[1]
assert(!/displayModel|layoutSerial|filterText/.test(binding), 'card width does not remeasure a partially rebuilt result model')
for (const [dmenuActive, activeMenu, panelWidth, widestLabelWidth, expected] of [
  [false, 'root', 1200, 0, 300],
  [false, 'root', 500, 1000, 480],
  [true, 'root', 1200, 1000, 420],
  [false, 'style.font', 1200, 1000, 520],
  [false, 'trigger.capture.screenrecord', 1200, 1000, 520]
]) {
  Object.assign(context, { dmenuActive, activeMenu, widestLabelWidth })
  context.panel.width = panelWidth
  context.Style.gapsOut = 10
  assertEqual(vm.runInContext(binding, context), expected, `card width preserves the bounds for ${activeMenu}, dmenu=${dmenuActive}, screen=${panelWidth}`)
}
JS
