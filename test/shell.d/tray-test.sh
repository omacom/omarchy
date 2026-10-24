#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "tray model helpers" <<'JS'
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')

assert(tray.itemNamed({ id: 'dropbox-client' }, 'dropbox'), 'tray matches item ids')
assert(tray.itemNamed({ title: 'Dropbox' }, 'dropbox'), 'tray matches item titles')
assert(tray.itemNamed({ tooltipTitle: 'LocalSend' }, 'localsend'), 'tray matches item tooltips')
assert(!tray.itemNamed({ id: 'nextcloud' }, 'dropbox'), 'tray ignores items named for something else')

const layout = {
  left: [{ id: 'omarchy.menu' }],
  center: [],
  right: [{ id: 'omarchy.dropbox' }, { id: 'omarchy.tray' }]
}

assert(tray.layoutHasWidget(layout, 'omarchy.dropbox'), 'tray finds dedicated dropbox widget in layout')
assert(tray.ownedByOmarchy({ id: 'dropbox' }, layout), 'tray suppresses dropbox when dedicated widget is in bar')
assert(!tray.ownedByOmarchy({ id: 'dropbox' }, { left: [], center: [], right: [] }), 'tray keeps dropbox when dedicated widget is absent')
assert(tray.ownedByOmarchy({ id: 'qlBCprNUqU', title: 'localsend' }, { left: [], center: [], right: [] }), 'tray suppresses localsend regardless of layout')
assert(!tray.ownedByOmarchy({ id: 'nextcloud' }, layout), 'tray keeps unrelated tray items')
assert(tray.ownedByOmarchy({ id: 'superwhisper' }, { left: [], center: [], right: [{ id: 'superwhisper.panel' }] }), 'tray suppresses superwhisper when its panel widget is in bar')
assert(!tray.ownedByOmarchy({ id: 'superwhisper' }, { left: [], center: [], right: [] }), 'tray keeps superwhisper when its panel widget is absent')
assert(tray.ownedByOmarchy({ id: 'dropbox' }, { left: [], center: [], right: [{ id: 'omarchy.tray' }], tray: [{ id: 'omarchy.dropbox' }] }), 'tray suppresses dropbox when its widget is in the tray section')

// The bar outlines as much of the tray section as the sliding drawer shows,
// never past the drawer.
assertDeepEqual(tray.shownSpan(0, 100, 20, 30), { start: 20, length: 30 }, 'a section inside the open drawer shows whole')
assertDeepEqual(tray.shownSpan(0, 40, 20, 30), { start: 20, length: 20 }, 'a section past the drawer\'s far edge is cut there')
assertDeepEqual(tray.shownSpan(10, 100, 0, 30), { start: 10, length: 20 }, 'a section sliding in from behind the drawer\'s near edge is cut there')
assertEqual(tray.shownSpan(0, 10, 50, 30), null, 'a section still outside the drawer shows nothing')
assertDeepEqual(tray.shownSpan(0, 50, 50.5, 0), { start: 50, length: 0 }, 'an empty section shows on the drawer\'s edge once within a pixel of it')
assertEqual(tray.shownSpan(0, 50, 52, 0), null, 'an empty section further out shows nothing')
JS

run_node_test "tray section host lifecycle" <<'JS'
const fs = require('fs')
const trayQml = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')
assert(/Component\.onDestruction: if \(root && root\.sectionHost === sectionArea\) root\.sectionHost = null/.test(trayQml),
  'tray section host unregisters only while its widget still exists')
// The bar outlines the section during a drag, as it does the center box, so
// an empty one shows no place of its own and takes no room.
assert(!/dropSpace|widgetsExtent/.test(trayQml), 'an empty tray section shows no drop slot of its own')
JS

run_node_test "tray drawer opens away from its fixed edge" <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')
const horizontal = source.slice(source.indexOf('id: horizontalTray'), source.indexOf('id: verticalTray'))
const vertical = source.slice(source.indexOf('id: verticalTray'), source.indexOf('id: managePopup'))

// A collapsed drawer keeps no room: opening, it grows the tray between the
// pinned icons and the chevron.
assert(
  /implicitWidth: pinnedRow\.implicitWidth \+ chevronWidth \+ root\.revealExtent/.test(horizontal) &&
    /implicitHeight: pinnedCol\.implicitHeight \+ chevronHeight \+ root\.revealExtent/.test(vertical) &&
    !/containmentMask/.test(source),
  'the drawer grows the tray as it opens instead of keeping its room while closed'
)
// The pinned icons sit against the fixed edge and the drawer opens between
// them and the chevron, the way the chevron points.
assert(
  /readonly property bool fixedAtStart: fixedEdge === "start"/.test(source) &&
    /id: pinnedRow\s*x: root\.fixedAtStart \? 0 : drawerArea\.width/.test(horizontal) &&
    /id: pinnedCol\s*y: root\.fixedAtStart \? 0 : drawerArea\.height/.test(vertical) &&
    (source.match(/text: root\.fixedAtStart \? "\\uf054" : "\\uf053"/g) || []).length === 2,
  'the pinned icons sit against the fixed edge, and the drawer opens away from it'
)
JS
