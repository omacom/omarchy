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
assert(
  /trayMenuOpen = TrayModel\.menuModelHasChildren\(trayMenuOpener\.children\)/.test(openTray),
  'initial open uses ObjectModel values through the production helper'
)

const opener = source.slice(
  source.indexOf('QsMenuOpener {\n    id: trayMenuOpener'),
  source.indexOf('PopupCard {\n    id: trayMenuPopup')
)
assert(/onChildrenChanged/.test(opener), 'late-ready SNI menus are observed')
assert(
  /var hasChildren = TrayModel\.menuModelHasChildren\(children\)/.test(opener),
  'late-ready handler uses the same production ObjectModel helper'
)
assert(
  /if \(root\.activeTrayItem && hasChildren && !root\.trayMenuOpen\)/.test(opener),
  'a non-empty late-ready menu opens the popup'
)
assert(
  /else if \(root\.trayMenuOpen && !hasChildren\)/.test(opener),
  'dropping back to zero rows releases the popup'
)
JS
