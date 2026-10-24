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


run_node_test "tray submenu stack swaps are deferred and generation-owned" <<'JS'
const fs = require('fs')
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')
const traySource = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')

assert(tray.submenuTransitionCurrent(7, 7, true), 'current open menu generation may apply deferred work')
assert(!tray.submenuTransitionCurrent(7, 7, false), 'closed menu rejects deferred work')
assert(!tray.submenuTransitionCurrent(7, 8, true), 'close then reopen rejects previous-generation work')

const enterMatch = traySource.match(/function enterSubmenu\(entry, title\) \{([\s\S]*?)\n  \}/)
assert(enterMatch && /Qt\.callLater/.test(enterMatch[1]), 'enterSubmenu defers model mutation')
assert(/submenuTransitionCurrent\(generation, root\.trayMenuGeneration, root\.trayMenuOpen\)/.test(enterMatch[1]), 'enterSubmenu owns a menu generation')
assert(/opener\.destroy\(\)/.test(enterMatch[1]), 'stale unpublished enter opener is destroyed')
// Split a function into what runs inside the click and its one deferred callback
const deferral = body => {
  const code = body.replace(/\/\/.*$/gm, '')
  const parts = code.match(/^([\s\S]*?)Qt\.callLater\(function\(\) \{([\s\S]*?)\n    \}\)([\s\S]*)$/)
  if (!parts || code.split('Qt.callLater').length !== 2) return { click: code, deferred: '' }
  return { click: parts[1] + parts[3], deferred: parts[2] }
}
const enter = deferral(enterMatch[1])
assert(!/submenuStack\s*=[^=]/.test(enter.click), 'enterSubmenu does not swap the stack inside the click')
assert(/root\.submenuStack = stack/.test(enter.deferred), 'enterSubmenu publishes the stack from the deferred callback')

const leaveMatch = traySource.match(/function leaveSubmenu\(\) \{([\s\S]*?)\n  \}/)
assert(leaveMatch && /Qt\.callLater/.test(leaveMatch[1]), 'leaveSubmenu defers model mutation')
const leave = deferral(leaveMatch[1])
assert(!/submenuStack\s*=[^=]|\.destroy\(\)/.test(leave.click), 'leaveSubmenu does not swap the stack or destroy the opener inside the click')
assert(/root\.submenuStack = stack/.test(leave.deferred), 'leaveSubmenu publishes the stack from the deferred callback')
assert(/submenuTransitionCurrent\(generation, root\.trayMenuGeneration, root\.trayMenuOpen\)/.test(leaveMatch[1]), 'leaveSubmenu owns a menu generation')

const resetMatch = traySource.match(/function resetTrayMenu\(\) \{([\s\S]*?)\n  \}/)
assert(resetMatch && /trayMenuGeneration\+\+/.test(resetMatch[1]), 'reset invalidates queued submenu work')
const closeMatch = traySource.match(/function close\(\) \{([\s\S]*?)\n  \}/)
assert(closeMatch && /trayMenuGeneration\+\+/.test(closeMatch[1]), 'close invalidates queued submenu work before fade reset')
JS
