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
