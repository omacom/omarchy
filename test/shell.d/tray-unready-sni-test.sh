#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "tray menu ObjectModel readiness" <<'JS'
const fs = require('fs')
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')
const source = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')

assert(
  !tray.menuModelHasChildren({ values: [] }),
  'empty QsMenuOpener ObjectModel is not ready'
)
assert(
  tray.menuModelHasChildren({ values: [{ text: 'Open' }] }),
  'non-empty QsMenuOpener ObjectModel is ready'
)
assert(
  !tray.menuModelHasChildren({ length: 1 }),
  'array-style length on the ObjectModel itself is not treated as readiness'
)

const openTray = source.slice(
  source.indexOf('function openTrayMenu('),
  source.indexOf('function trayIconSource(')
)
assert(!/item\.display\(/.test(openTray), 'unready SNI path does not take a platform popup grab')
assert(
  /if \(!item \|\| !item\.menu\) return/.test(openTray),
  'SNI without a menu is a no-op'
)
assert(/^\s*trayMenuPending = false\n\s*if \(!item \|\| !item\.menu\) return/m.test(openTray), 'any new click, even on an item without a menu, cancels the previous pending one')
assert(/trayMenuPending = true\n\s*trayMenuPendingTimer\.restart\(\)\n\s*syncTrayMenuOpen\(\)/.test(openTray), 'a click marks the menu pending for a bounded time, then opens it if rows are already there')

const sync = source.slice(
  source.indexOf('function syncTrayMenuOpen()'),
  source.indexOf('function openTrayMenu(')
)
assert(
  /var hasChildren = TrayModel\.menuModelHasChildren\(trayMenuOpener\.children\)/.test(sync),
  'readiness uses ObjectModel values through the production helper'
)
assert(
  /if \(hasChildren && trayMenuPending\) \{\s*trayMenuPending = false\s*trayMenuOpen = true/.test(sync),
  'rows open the popup only for a pending click, once'
)
assert(
  /else if \(!hasChildren && trayMenuOpen\) \{(\s*\/\/.*)*\s*trayMenuOpen = false\s*\}/.test(sync),
  'dropping back to zero rows releases the popup without cancelling a click on another item'
)

const opener = source.slice(
  source.indexOf('QsMenuOpener {\n    id: trayMenuOpener'),
  source.indexOf('PopupCard {\n    id: trayMenuPopup')
)
assert(/onChildrenChanged: Qt\.callLater\(root\.syncTrayMenuOpen\)/.test(opener), 'a menu handle that loads late is observed')
assert(
  /target: trayMenuOpener\.children\s*function onValuesChanged\(\) \{ Qt\.callLater\(root\.syncTrayMenuOpen\) \}/.test(opener),
  'rows added to or removed from a loaded menu are observed once the update settles, so replacing every row does not close the menu'
)
assert(
  /id: trayMenuPendingTimer\s*interval: \d+\s*onTriggered: root\.trayMenuPending = false/.test(opener),
  'a pending click expires'
)
assert(
  /function onActivePopoutChanged\(\) \{\s*if \(root\.bar\.activePopout\) root\.trayMenuPending = false/.test(opener),
  'another bar popup cancels a pending tray click'
)

const closeFn = source.slice(
  source.indexOf('function close()'),
  source.indexOf('function syncTrayMenuOpen()')
)
assert(/trayMenuPending = false/.test(closeFn), 'close() cancels a pending open so a dismissed menu cannot reopen itself')
assert(!/activeTrayItem = null/.test(closeFn), 'close() keeps the active item so the menu fades out with its rows')
JS
