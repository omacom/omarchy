#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "tray menu ObjectModel readiness" <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')

// Behavioral: ObjectModel cardinality is under .values, not .length
function menuHasChildren(model) {
  return Boolean(model && model.values && model.values.length > 0)
}
assert(!menuHasChildren({ values: [] }), 'empty ObjectModel is not ready')
assert(menuHasChildren({ values: [{ text: 'Open' }] }), 'non-empty ObjectModel is ready')
assert(!menuHasChildren({ length: 2 }), 'array-style .length alone is not readiness')

const openTray = source.slice(
  source.indexOf('function openTrayMenu('),
  source.indexOf('function trayIconSource(')
)
assert(!/item\.display\(/.test(openTray), 'unready SNI path does not take a platform popup grab')
assert(/if \(!item \|\| !item\.menu\) return/.test(openTray), 'SNI without a menu is a no-op')
assert(
  /trayMenuOpen\s*=\s*trayMenuOpener\.children\.values\.length\s*>\s*0/.test(openTray),
  'initial open uses children.values.length (ObjectModel rows)'
)
assert(
  !/trayMenuOpen\s*=\s*trayMenuOpener\.children\.length\s*>\s*0/.test(openTray),
  'initial open must not read children.length (undefined on ObjectModel)'
)

const opener = source.slice(
  source.indexOf('QsMenuOpener {\n    id: trayMenuOpener'),
  source.indexOf('PopupCard {\n    id: trayMenuPopup')
)
assert(/onChildrenChanged/.test(opener), 'late-ready SNI menus are observed')
assert(
  /children\.values\.length\s*>\s*0/.test(opener),
  'late-ready handler opens when children.values.length > 0'
)
assert(
  /children\.values\.length\s*===\s*0/.test(opener),
  'dropping to zero values.length releases the popup'
)
assert(
  !/children\.length\s*>\s*0/.test(opener) && !/children\.length\s*===\s*0/.test(opener),
  'late-ready handler must not read children.length'
)
JS
