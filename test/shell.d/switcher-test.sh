#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

ROOT="$ROOT" run_node_test <<'JS'
const switcher = requireFromRoot('shell/plugins/switcher/SwitcherModel.js')

let order = []
for (const address of ['0xA', 'b', '0xc', 'a']) order = switcher.touch(order, address)
assertDeepEqual(order, ['a', 'c', 'b'], 'the window focused last goes first, whichever way Hyprland writes its address')
assertDeepEqual(switcher.demote(order, '0xa'), ['c', 'b', 'a'], 'a minimized window goes to the back')
assertDeepEqual(switcher.forget(order, 'c'), ['a', 'b'], 'a closed window leaves the order')

const windows = [
  { address: '0xd', parent: '', focusHistory: 1 },
  { address: '0xb', parent: '' },
  { address: '0xe', parent: '', focusHistory: 0 },
  { address: '0xa', parent: '' },
  { address: '0xf', parent: '0xa' },
  { address: '0xg', parent: '', shown: false, focusHistory: 2 },
  { address: '0xq', parent: '', workspace: 'special:qconsole' },
  { address: '0xs', parent: '', appId: 'org.omarchy.screensaver' }
]
const addresses = list => list.map(window => window.address)
assertDeepEqual(
  addresses(switcher.orderWindows(['b', 'f', 'a'], windows)),
  ['0xb', '0xa', '0xe', '0xd'],
  'windows list in the order last used, those not used since the shell started after them by focus history, dialogs, helpers and windows never shown left out'
)
assertDeepEqual(addresses(switcher.orderWindows(['f', 'b'], windows)).slice(0, 2), ['0xa', '0xb'], 'a window whose dialog was used last comes first')

const pick = (order, list, focused, delta = 1) => switcher.orderWindows(order, list)[switcher.firstPick(order, list, focused, delta)].address
assertEqual(pick(['f', 'a', 'b'], windows, '0xf'), '0xb', 'Tab from a focused dialog goes past its owner to the window used before')
assertEqual(pick(['f', 'a', 'b'], windows, ''), '0xa', 'with nothing focused, Tab goes to the window used last')

const minimized = [{ address: 'a', minimized: true }, { address: 'b' }, { address: 'c' }]
assertDeepEqual(addresses(switcher.orderWindows(['b', 'a'], minimized)), ['b', 'c', 'a'], 'a minimized window goes after every other, unused ones too')
assertEqual(switcher.orderWindows([], minimized).pop().address, 'a', 'a minimized window goes last before anything is used')

assertEqual(switcher.dialogFor(['b', 'f'], windows, '0xa').address, '0xf', 'an owner comes up with its dialog')
assertEqual(switcher.dialogFor([], windows, '0xb'), null, 'a window with no dialog comes up alone')
const nested = windows.concat([{ address: '0xh', parent: '0xf' }])
assertEqual(switcher.dialogFor(['b', 'f'], nested, '0xa').address, '0xh', 'an owner comes up with the dialog open on top of its dialog')
assertDeepEqual(switcher.lineage(nested, '0xh'), ['a', 'f', 'h'], 'a dialog comes up after the windows it belongs to')

assertEqual(switcher.startIndex(3, 1, true), 1, 'Tab starts on the window used before the focused one')
assertEqual(switcher.startIndex(3, 1, false), 0, 'with nothing focused, Tab starts on the window used last')
assertEqual(switcher.startIndex(1, 1, true), 0, 'a lone window stays picked')
assertEqual(switcher.startIndex(3, -1, true), 2, 'Shift + Tab starts from the other end')
assertEqual(switcher.stepIndex(2, 3, 1), 0, 'Tab wraps past the last window')
assertEqual(switcher.stepIndex(0, 3, -1), 2, 'Shift + Tab wraps past the first window')
assertEqual(switcher.indexAfterRemoval(2, 0, 3), 1, 'the pick stays on its window when one before it closes')
assertEqual(switcher.indexAfterRemoval(2, 2, 2), 1, 'the pick moves back when the last window closes')

const options = { maxWidth: 500, maxHeight: 1000, thumbHeight: 100, minThumbHeight: 40, gap: 10, padding: 0, header: 0, minAspect: 0.5, maxAspect: 2.5 }
const wrapped = switcher.layout([2, 2, 2], options)
assertDeepEqual(wrapped.rows, [[0, 1], [2]], 'thumbnails wrap onto a new row when the row is full')
assertEqual(wrapped.items[2].x, 105, 'a short row is centered')
assertEqual(switcher.rowNeighbor(wrapped, 0, 1), 2, 'Down goes to the nearest thumbnail in the row below')
assertEqual(switcher.rowNeighbor(wrapped, 2, 1), 2, 'Down stays put on the last row')
const shrunk = switcher.layout([2, 2, 2, 2, 2, 2], Object.assign({}, options, { maxHeight: 150 }))
assert(shrunk.height <= 150 && shrunk.thumbHeight < 100, 'thumbnails shrink until the rows fit')

const tall = switcher.layout(new Array(40).fill(2), Object.assign({}, options, { maxHeight: 150 }))
assertEqual(tall.height, 150, 'rows that do not fit at the smallest thumbnails stop at the height there is')
assert(tall.contentHeight > tall.height, 'and scroll through the rest')
const last = tall.items[39]
assertEqual(switcher.scrollFor(tall, 39, 0), tall.contentHeight - tall.height, 'the rows scroll down to show the last thumbnail picked')
assertEqual(switcher.scrollFor(tall, 0, tall.contentHeight - tall.height), 0, 'and back up to show the first')
assertEqual(switcher.scrollFor(tall, 20, tall.items[20].y - 5), tall.items[20].y - 5, 'a thumbnail in view stays where it is')
JS

pass "the window switcher orders, picks and lays out windows the way Windows does"
