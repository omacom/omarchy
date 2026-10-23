#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const bar = requireFromRoot('shell/plugins/bar/BarModel.js')
const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')

// A bar long enough for every widget keeps the list it was given, and keeps
// the very same array: a wide display must not rebind its sections on every
// layout pass just because the filter ran.
const keys = ['a#1', 'b#2', 'c#3']
const entries = {
  'a#1': { id: 'omarchy.clock' },
  'b#2': { id: 'omarchy.active-window', minBarWidth: 1600 },
  'c#3': { id: 'omarchy.power' }
}
assert(bar.fittingKeys(keys, entries, 5120) === keys, 'a bar with room for everything is handed its own list back')
assertDeepEqual(bar.fittingKeys(keys, entries, 1600), keys, 'a widget shows on a bar exactly as long as its minBarWidth')
assertDeepEqual(bar.fittingKeys(keys, entries, 1280), ['a#1', 'c#3'], 'a narrower bar leaves out the widget that asked for more room')

// The setting is opt-in: nothing without it is ever dropped, however narrow
// the bar, and a malformed value is ignored rather than hiding a widget.
assertDeepEqual(bar.fittingKeys(keys, { 'a#1': {}, 'b#2': {}, 'c#3': {} }, 1), keys, 'widgets without minBarWidth survive any width')
for (const bad of [0, -100, 'wide', null, NaN, {}])
  assertDeepEqual(
    bar.fittingKeys(['b#2'], { 'b#2': { id: 'x', minBarWidth: bad } }, 320),
    ['b#2'],
    `an unusable minBarWidth (${String(bad)}) does not hide a widget`
  )

// A string entry carries no settings, and an unmeasured bar (a list that is
// not drawn) must not filter on a length it does not have yet.
assertDeepEqual(bar.fittingKeys(['s#1'], { 's#1': 'omarchy.clock' }, 320), ['s#1'], 'a bare string entry is never filtered')
assertDeepEqual(bar.fittingKeys(keys, entries, 0), keys, 'a bar that has not been measured yet filters nothing')
assertDeepEqual(bar.fittingKeys(null, entries, 1280), [], 'a missing key list yields no keys')

// The centered group stays centered while it fits between the two edge
// sections: the placement every bar had before this existed.
assertEqual(bar.centerBoxX(5120, 200, 300, 300, 400, 4720), 2460, 'the center box sits dead center when the group fits')
assertEqual(bar.centerBoxX(5120, 200, 0, 0, 0, 0), 2460, 'with no room reported the box is centered as before')

// Once it does not fit, it slides along the room instead of overprinting a
// neighbour. Centered would put the box at 540, which would run centerBegin
// back to 140 -- past the left section ending at 600.
assertEqual(bar.centerBoxX(1280, 200, 400, 100, 600, 1200), 1000, 'the group slides clear of the left section rather than overlapping it')
assertEqual(bar.centerBoxX(1280, 200, 100, 400, 0, 600), 100, 'the group slides clear of the right section too')

// Wider than the room there is no overlap-free placement; it starts where the
// room does, deterministically, and minBarWidth is what keeps a bar out of it.
assertEqual(bar.centerBoxX(1280, 400, 400, 400, 500, 800), 900, 'a group wider than the room starts where the room starts')

// Nonsense insets fall back to centering rather than throwing a bar off screen.
for (const [start, end] of [[NaN, 1200], [600, NaN], [900, 300]])
  assertEqual(bar.centerBoxX(1280, 200, 0, 0, start, end), 540, `unusable room (${start}, ${end}) leaves the box centered`)

// A drag's landing places index the configured section, but a bar that leaves
// a widget out draws fewer rows than the section has. The place keeps its own
// number -- the room is named `region:index` and the drop is saved against it
// -- and gains the position to open the gap at.
const full = ['hidden#1', 'a#2', 'b#3']
const shown = ['a#2', 'b#3']
assertDeepEqual(
  bar.spacerPlaces([2], full, shown),
  [{ at: 1, place: 2 }],
  'a gap before the last widget opens before it, not after it, when an earlier widget is hidden'
)
assertDeepEqual(
  bar.spacerPlaces([0, 1, 2, 3], full, shown),
  [{ at: 0, place: 0 }, { at: 0, place: 1 }, { at: 1, place: 2 }, { at: 2, place: 3 }],
  'every place maps to the widgets this bar actually draws before it'
)
assertDeepEqual(bar.spacerPlaces([2], full, full), [2], 'a bar showing the whole section keeps its places untouched')
assertDeepEqual(bar.spacerPlaces([], full, shown), [], 'no drag, no places')

// The gap lands where the map says, and is still named by its own place, which
// is what the drag state and the saved drop are keyed by.
const mapped = bar.sectionRows(shown, bar.spacerPlaces([2], full, shown), {})
assertDeepEqual(
  mapped.map(row => row.kind + ':' + (row.place === undefined ? row.key : row.place)),
  ['widget:a#2', 'spacer:2', 'widget:b#3'],
  'the spacer sits between the shown widgets and keeps the place it was given'
)

// The engine has to actually consult both, or the model above is dead code.
assert(
  /readonly property var shownKeys: BarModel\.fittingKeys\(keys, root\.layoutWidgets\.entries, window \? window\.barLength : 0\)/.test(barSource),
  'every module list filters its keys by the length of the bar it is drawn on'
)
assert(
  /BarModel\.sectionRows\(shownKeys,/.test(barSource) && !/BarModel\.sectionRows\(keys,/.test(barSource),
  'module list rows are built from the filtered keys, not the configured ones'
)
assert(
  /readonly property var spacerRooms: BarModel\.spacerPlaces\(root\.sectionSpacers\(region, window\), keys, shownKeys\)/.test(barSource) &&
  /BarModel\.sectionRows\(shownKeys, spacerRooms, rowMemo\)/.test(barSource),
  'a drag opens its gaps against the widgets the bar draws, not the configured section'
)
assert(
  /BarModel\.slotEdge\(moduleListRoot\.shownKeys\.length, moduleListRoot\.shownKeys\.indexOf/.test(barSource),
  'slot edges are measured against the widgets actually shown'
)
assert(
  /x: root\.vertical \? 0 : \(sections\.besideRight \? beginList\.width : BarModel\.centerBoxX\(/.test(barSource),
  'the center box is placed within the room left by the edge sections'
)
assert(
  /startInset: leftModules\.x \+ leftModules\.width \+ Style\.space\(4\)/.test(barSource) &&
  /endInset: rightModules\.x - Style\.space\(4\)/.test(barSource),
  'the horizontal bar reports the room between its left and right sections'
)
assert(
  /readonly property int barLength: root\.vertical \? height : width/.test(barSource),
  'each bar surface publishes the length it runs on'
)
JS
