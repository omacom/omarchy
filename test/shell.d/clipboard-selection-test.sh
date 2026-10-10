#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const selection = requireFromRoot('shell/plugins/clipboard/ClipboardSelection.js')
const history = requireFromRoot('shell/plugins/clipboard/ClipboardHistory.js')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/clipboard/Clipboard.qml'), 'utf8')
const first = { type: 'text', text: 'First paragraph' }
const second = { type: 'text', text: 'Second paragraph' }

let marked = selection.toggle(selection.toggle([], second), first)
assertEqual(selection.join(selection.retain(marked, [first, second])), 'Second paragraph\nFirst paragraph', 'clipboard combines texts in marking order after history reordering')
assertEqual(selection.position(marked, first), 1, 'clipboard numbers marks in selection order')
const unmarked = selection.toggle(marked, { ...second })
assertDeepEqual(unmarked, [first], 'clipboard toggles duplicate text off')
assertDeepEqual(marked, [second, first], 'clipboard toggling does not mutate the previous selection')
assertDeepEqual(selection.toggle(unmarked, second), [first, second], 'clipboard appends a reselected entry to the end')
assertDeepEqual(selection.remove(marked, second), [first], 'clipboard removes deleted text from the selection')
assertDeepEqual(selection.retain(marked, [second]), [second], 'clipboard drops entries no longer in history')
for (const invalid of [{ type: 'image', path: '/tmp/image.png' }, { type: 'text', text: ' \n\t' }, null]) {
  assertDeepEqual(selection.toggle([first], invalid), [first], 'clipboard ignores non-text and empty marks')
}
const literal = [
  { type: 'text', text: '  áéíóú 🐺\nsecond line\n' },
  { type: 'text', text: '`whoami` $(id) "quotes" \\ path' }
]
assertEqual(selection.join(literal), '  áéíóú 🐺\nsecond line\n\n`whoami` $(id) "quotes" \\ path', 'clipboard preserves whitespace, Unicode and shell syntax literally')
const large = [{ type: 'text', text: 'x'.repeat(200000) }, second]
assertEqual(selection.preview(large, 8192).length, 8192, 'clipboard bounds the combined preview')
assertEqual(selection.join(large).length, 200000 + 1 + second.text.length, 'clipboard retains the complete large paste')
assertEqual(selection.preview([first, second], first.text.length + 3), first.text + '\nSe', 'clipboard preview includes the separator within its bound')

// Run the production handlers with a model and process fixture. No desktop,
// user history or external clipboard commands are touched.
const model = {
  rows: [],
  get count() { return this.rows.length },
  get(index) { return this.rows[index] },
  clear() { this.rows = [] },
  append(row) { this.rows.push(row) }
}
const copy = { running: false, stdinEnabled: false }
const timer = { running: false, restart() { this.running = true } }
const calls = []
const Qt = {
  ControlModifier: 1, ShiftModifier: 2, AltModifier: 4,
  Key_Escape: 10, Key_Space: 11, Key_Delete: 12, Key_Up: 13, Key_Down: 14,
  Key_PageUp: 15, Key_PageDown: 16, Key_Home: 17, Key_End: 18, Key_Return: 19, Key_Enter: 20,
  callLater(callback) { callback() }
}
const picker = {
  history: [first, second], selectedEntries: [], selectedIndex: 0, cursorActive: true,
  filterText: '', clearConfirmOpen: false, historyLimit: 2, opened: false,
  pendingCombinedText: '', pendingCopyOnly: false, omarchyPath: '/fixture',
  disarmPointer() {}, saveHistory() {}, close() { this.opened = false }
}
const context = vm.createContext({
  root: picker, ClipboardHistory: history, ClipboardSelection: selection,
  displayModel: model, combinedCopy: copy, combinedPasteTimer: timer, Qt,
  Util: { fileUrl(value) { return value }, editsFilter() { return false } },
  ListView: { Contain: 0 }, resultList: { positionViewAtIndex() {} },
  keyCatcher: { forceActiveFocus() {} }, clearConfirm: { selectedIndex: 1 },
  Quickshell: { execDetached(command) { calls.push(command) } }, row: { index: 0 }
})
for (const name of Object.keys(picker).filter(name => typeof picker[name] !== 'function')) {
  Object.defineProperty(context, name, {
    get() { return picker[name] },
    set(value) { picker[name] = value }
  })
}
for (const name of [
  'open', 'loadHistory', 'addClipboardEntry', 'confirmClearHistory', 'removeDisplayIndex',
  'rebuildDisplay', 'select', 'selectAbsolute', 'setFilter', 'toggleIndex',
  'activateIndex', 'copyIndex', 'applyCombined', 'applySelected', 'copySelected', 'openIndex', 'openSelected'
]) {
  const match = qml.match(new RegExp(`  function ${name}\\([^]*?\\n  }`))
  if (!match) fail('clipboard handler exists: ' + name)
  vm.runInContext(match[0], context)
  picker[name] = context[name]
}
const keyHandler = qml.match(/Keys.onPressed: function\(event\) \{([^]*?)\n        }/)
if (!keyHandler) fail('clipboard key handler exists')
picker.key = vm.runInContext('(function(event) {' + keyHandler[1] + '\n})', context)
const mouseHandler = qml.match(/onClicked: function\(mouse\) \{([^]*?)\n                    }/)
if (!mouseHandler) fail('clipboard row click handler exists')
picker.click = vm.runInContext('(function(mouse) {' + mouseHandler[1] + '\n})', context)

picker.open('{}')
picker.key({ key: Qt.Key_Space, modifiers: Qt.ControlModifier, text: ' ' })
context.row.index = 1
picker.click({ modifiers: Qt.ControlModifier })
assertEqual(selection.join(picker.selectedEntries), 'First paragraph\nSecond paragraph', 'clipboard Ctrl+Space and Ctrl+click mark without submitting')
assert(picker.opened && !copy.running, 'clipboard marking keeps the picker open')
picker.loadHistory(JSON.stringify([second, first]))
picker.setFilter('no matching entry')
assertEqual(model.count, 0, 'clipboard supports a filter with no matches')
assertEqual(selection.join(picker.selectedEntries), 'First paragraph\nSecond paragraph', 'clipboard filtering and history reordering preserve marks')
picker.key({ key: Qt.Key_Return, modifiers: Qt.ShiftModifier, text: '' })
assert(copy.running && copy.stdinEnabled && picker.pendingCopyOnly && !picker.opened, 'clipboard Shift+Enter copies the group even with no matching rows')
assertEqual(picker.pendingCombinedText, 'First paragraph\nSecond paragraph', 'clipboard submits the selected texts with newline separators')
picker.open('{}')
assert(!picker.opened, 'clipboard does not reopen while a combined copy is pending')
copy.running = false
picker.open('{}')
assertEqual(picker.selectedEntries.length, 0, 'clipboard clears marks on opening')

picker.toggleIndex(0)
picker.addClipboardEntry({ type: 'text', text: 'New entry' })
picker.addClipboardEntry({ type: 'text', text: 'Another entry' })
assertEqual(picker.selectedEntries.length, 0, 'clipboard prunes a marked entry evicted by the history limit')
picker.toggleIndex(0)
picker.removeDisplayIndex(0)
assertEqual(picker.selectedEntries.length, 0, 'clipboard deleting a row removes its mark')
picker.toggleIndex(0)
picker.confirmClearHistory()
assertEqual(picker.selectedEntries.length, 0, 'clipboard clearing history clears marks')

picker.history = [first, { type: 'image', path: '/tmp/synthetic.png', mime: 'image/png' }, { type: 'text', text: 'file:///tmp/synthetic.txt' }]
picker.rebuildDisplay()
picker.toggleIndex(0)
for (const index of [1, 2]) {
  picker.toggleIndex(index)
  picker.activateIndex(index)
  picker.copyIndex(index)
}
assertEqual(picker.selectedEntries.length, 1, 'clipboard images and file URI rows cannot be marked')
assertDeepEqual(calls, [
  ['/fixture/bin/omarchy-clipboard-paste-file', 'image/png', '/tmp/synthetic.png'],
  ['/fixture/bin/omarchy-clipboard-paste-file', '--copy-only', 'image/png', '/tmp/synthetic.png'],
  ['/fixture/bin/omarchy-clipboard-paste-text', '--shift-insert', '--history-index', '2'],
  ['/fixture/bin/omarchy-clipboard-paste-text', '--copy-only', '--history-index', '2']
], 'clipboard image and file activation preserves native helper dispatch with texts marked')
picker.openIndex(0)
assertDeepEqual(calls.pop(), ['/fixture/bin/omarchy-clipboard-open', '--history-index', '0'], 'clipboard open action still opens the individual row')
picker.selectedEntries = []
picker.activateIndex(0)
assertDeepEqual(calls.pop(), ['/fixture/bin/omarchy-clipboard-paste-text', '--shift-insert', '--history-index', '0'], 'clipboard ordinary single-text activation keeps the native paste helper')

const processBlock = qml.match(/Process \{\n    id: combinedCopy([^]*?)\n  }/)
if (!processBlock) fail('clipboard combined copy process exists')
const command = processBlock[1].match(/command: (\[[^\n]*\])/)
assertDeepEqual(JSON.parse(command[1]), ['wl-copy', '--type', 'text/plain;charset=utf-8'], 'clipboard sends text through stdin without command-line interpolation')
let written = ''
context.write = text => { written += text }
context.stdinEnabled = true
const started = processBlock[1].match(/onStarted: \{([^]*?)\n    }/)
picker.selectedEntries = large
picker.applyCombined(false)
vm.runInContext(started[1], context)
assertEqual(written, selection.join(large), 'clipboard writes the full payload to the copy process')
assertEqual(context.stdinEnabled, false, 'clipboard closes stdin after writing so the copy can finish')
const exited = processBlock[1].match(/onExited: function\(exitCode, exitStatus\) \{([^]*?)\n    }/)
const onExited = vm.runInContext('(function(exitCode, exitStatus) {' + exited[1] + '\n})', context)
onExited(1, 0)
assert(picker.opened && picker.selectedEntries.length === 2 && !timer.running, 'clipboard copy failure keeps marks available for retry and does not paste')
picker.pendingCopyOnly = true
onExited(0, 0)
assert(!timer.running && picker.selectedEntries.length === 0, 'clipboard copy-only success clears marks without a paste keystroke')
picker.pendingCopyOnly = false
onExited(0, 0)
assert(timer.running, 'clipboard paste waits until the copy command succeeds')
const paste = qml.match(/id: combinedPasteTimer[^]*?onTriggered: ([^\n]+)/)
vm.runInContext(paste[1], context)
assertDeepEqual(calls.pop(), ['wtype', '-M', 'shift', '-k', 'Insert', '-m', 'shift'], 'clipboard combined paste uses the native Shift+Insert gesture')
JS
