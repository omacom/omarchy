#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Execute the panel's actual cursor callbacks with command recording in place
# of compositor IPC. No Qt window or physical display is needed.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/panels/monitor/Panel.qml'), 'utf8')
const keySource = fs.readFileSync(path.join(root, 'shell/Ui/PanelKeyCatcher.qml'), 'utf8')
const selections = []
const panel = vm.createContext({
  cursorActive: true, focusSection: 'monitors', selectedIndex: 0,
  monitorPowerFocused: false, settingsBusy: false, settingsDirty: false,
  stateFresh: true, enabledDisplayCount: 2,
  visibleSections: ['identify', 'monitors', 'scale'], scaleValues: ['1', '2'],
  displays: [{name: 'DP-1', enabled: true}, {name: 'DP-2', enabled: false}],
  selectDisplay: name => selections.push(name),
  displayPowerProc: {running: false, command: []},
  Qt: Object.fromEntries(['Escape', 'Tab', 'Backtab', 'Down', 'Up', 'Right', 'Left', 'Return', 'Enter', 'Space', 'Delete'].map(key => ['Key_' + key, key])),
  blocked: false, reorderable: false, returnRequested() {}
})
panel.root = panel
for (const name of ['sectionCount', 'sectionIsSingleRow', 'sectionFirstIndex', 'moveCursor', 'moveCursorH', 'activateCursor', 'toggleDisplay']) {
  const match = source.match(new RegExp('^  function ' + name + '\\([^\\n]*\\) \\{[\\s\\S]*?^  \\}', 'm'))
  if (!match) fail('panel cursor callback is present: ' + name)
  vm.runInContext(match[0], panel)
}
const move = source.match(/onMoveRequested: function\(dx, dy\) \{([\s\S]*?)^      \}/m)
const activate = source.match(/onActivateRequested: ([^\n]+)/)
const key = keySource.match(/Keys.onPressed: function\(event\) \{([\s\S]*?)^  \}/m)
vm.runInContext('function moveRequested(dx, dy) {' + move[1] + '}\n'
  + 'function activateRequested() {' + activate[1] + '}\n'
  + 'function press(event) {' + key[1] + '}', panel)
function press(key, text = '') { panel.press({key, text, modifiers: 0, accepted: false}) }
function resetPower() { panel.displayPowerProc = {running: false, command: []} }

press('Enter')
assertDeepEqual(selections, ['DP-1'], 'Enter on a display selects it without changing power')
assertEqual(panel.displayPowerProc.running, false, 'selection leaves compositor power untouched')
press('Right')
assertEqual(panel.monitorPowerFocused, true, 'Right reaches the display power action')
press('Space')
assert(panel.displayPowerProc.command[2].includes('disabled = true'), 'Space on power disables the highlighted display')

resetPower()
press('Down')
assertEqual(panel.selectedIndex, 1, 'Down reaches a disabled display')
assertEqual(panel.monitorPowerFocused, false, 'changing rows returns to selection to avoid accidental power changes')
press('', 'l')
press('Return')
assert(panel.displayPowerProc.command[2].includes('output = "DP-2", disabled = false'), 'l then Enter enables a disabled display')
resetPower()
press('', 'h')
assertEqual(panel.monitorPowerFocused, false, 'h returns from power to selection')
press('Up')
press('Enter')
assertDeepEqual(selections, ['DP-1', 'DP-1'], 'Left/Up navigation preserves explicit display selection')

for (const [field, value, description] of [
  ['enabledDisplayCount', 1, 'last active display'],
  ['settingsBusy', true, 'in-flight settings operation'],
  ['settingsDirty', true, 'unsaved settings draft'],
  ['stateFresh', false, 'stale monitor state']
]) {
  const previous = panel[field]
  panel[field] = value
  resetPower()
  press('Right')
  press('Enter')
  assertEqual(panel.displayPowerProc.running, false, 'keyboard power respects guard: ' + description)
  panel[field] = previous
}
JS
