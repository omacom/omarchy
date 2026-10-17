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

const chromeA = { id: 'chrome_status_icon_1', title: '', tooltipTitle: 'LM Studio' }
const chromeB = { id: 'chrome_status_icon_1', title: '', tooltipTitle: 'ChatGPT' }
const dropbox = { id: 'dropbox', title: 'Dropbox', tooltipTitle: 'Dropbox' }

assertEqual(tray.stateKey(chromeA), 'chrome_status_icon_1\nLM Studio', 'tray keys a colliding electron icon by tooltip')
assert(tray.stateKey(chromeA) !== tray.stateKey(chromeB), 'tray gives colliding electron icons different keys')
assertEqual(tray.stateKey(dropbox), 'dropbox\nDropbox', 'tray keeps a label on a unique id')
assertEqual(tray.stateKey({ id: 'solo' }), 'solo', 'tray keeps a bare id when the icon has no label')
assert(tray.appliesStored(['chrome_status_icon_1'], chromeA, false), 'tray still honors a stored bare id when the id is unique')
assert(!tray.appliesStored(['chrome_status_icon_1'], chromeA, true), 'tray does not apply a shared bare id to every colliding icon')
assert(tray.appliesStored([tray.stateKey(chromeB)], chromeB, true), 'tray applies a stored per-icon key while the id is shared')
assert(!tray.appliesStored([tray.stateKey(chromeA)], chromeB, true), 'tray does not pin the other colliding icon')
assertDeepEqual(tray.toggleStored(['dropbox'], [], dropbox, false), { keys: [], others: [] }, 'tray unpins an icon pinned under its bare id on the first click')
assertDeepEqual(tray.toggleStored([], ['dropbox'], dropbox, false), { keys: ['dropbox\nDropbox'], others: [] }, 'tray pins an icon hidden under its bare id and shows it')
assertDeepEqual(tray.toggleStored(['chrome_status_icon_1'], [], chromeA, true), { keys: [tray.stateKey(chromeA)], others: [] }, 'tray pins one colliding icon in place of a shared bare id')
assertDeepEqual(tray.toggleStored([tray.stateKey(chromeB)], [], chromeA, true), { keys: [tray.stateKey(chromeB), tray.stateKey(chromeA)], others: [] }, 'tray pins one colliding icon without unpinning the other')
assertDeepEqual(tray.toggleStored([tray.stateKey(chromeA)], [], chromeA, true), { keys: [], others: [] }, 'tray unpins a colliding icon by its own key')

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
