#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Clicking the tray icon whose menu is already open must close that menu
# (#15347): the popup's focus grab hands the second click to the icon's
# MouseArea, so openTrayMenu sees it again. The toggle is pure control flow
# over component state, so run the extracted function body against stand-in
# state, the way bar-click-clipping-test.sh runs Util.itemContainsPoint.

run_node_test <<'JS'
const fs = require('fs')
const tray = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')
const match = tray.match(/function openTrayMenu\(item, anchorItem, mouse\) \{([\s\S]*?)\n  \}/)
assert(match, 'openTrayMenu is present in Tray.qml')

// openTrayMenu reads and assigns component properties as bare names, so seed
// them as globals and read them back after each call. The real close() the
// toggle calls is extracted too, so the state after closing is Tray.qml's own.
const closeMatch = tray.match(/function close\(\) \{([\s\S]*?)\n  \}/)
assert(closeMatch, 'close is present in Tray.qml')
const closeBody = new Function(closeMatch[1])

function runOpenTrayMenu(state, item, anchorItem, mouse) {
  globalThis.activeTrayItem = state.activeTrayItem
  globalThis.activeTrayAnchor = state.activeTrayAnchor
  globalThis.trayMenuOpen = state.trayMenuOpen
  const calls = { resets: 0, closes: 0 }
  const fn = new Function(
    'item', 'anchorItem', 'mouse', 'resetTrayMenu', 'close',
    match[1]
  )
  fn(
    item, anchorItem, mouse,
    function () { calls.resets++ },
    function () { calls.closes++; closeBody() }
  )
  return {
    trayMenuOpen: globalThis.trayMenuOpen,
    activeTrayItem: globalThis.activeTrayItem,
    activeTrayAnchor: globalThis.activeTrayAnchor,
    resets: calls.resets,
    closes: calls.closes,
  }
}

function trayItem(id) {
  return { id: id, menu: { id: 'menu-of-' + id } }
}

const anchorOf = {}
const mouseOf = {}

// First click opens the icon's menu.
let state = { activeTrayItem: null, activeTrayAnchor: null, trayMenuOpen: false }
let result = runOpenTrayMenu(state, trayItem('telegram'), anchorOf, mouseOf)
assert(result.trayMenuOpen === true, 'first click opens the menu')
assert(result.activeTrayItem && result.activeTrayItem.id === 'telegram', 'first click selects the clicked item')
assert(result.resets === 1, 'first click resets stale menu state')

// Second click on the same icon closes the menu instead of reopening it.
state = { activeTrayItem: trayItem('telegram'), activeTrayAnchor: anchorOf, trayMenuOpen: true }
result = runOpenTrayMenu(state, state.activeTrayItem, anchorOf, mouseOf)
assert(result.closes === 1, 'second click on the same icon closes the menu')
assert(result.trayMenuOpen === false, 'second click on the same icon leaves the menu closed')
assert(result.resets === 0, 'closing does not tear the menu down before the popup fades')

// Clicking a different icon while one is open still switches menus.
state = { activeTrayItem: trayItem('telegram'), activeTrayAnchor: anchorOf, trayMenuOpen: true }
result = runOpenTrayMenu(state, trayItem('discord'), anchorOf, mouseOf)
assert(result.trayMenuOpen === true, 'clicking another icon keeps a menu open')
assert(result.activeTrayItem.id === 'discord', 'clicking another icon switches to it')
assert(result.resets === 1, 'switching menus resets the previous one')

// A menuless icon still falls through to display(), untouched by the toggle.
const menuless = { id: 'plain', display(displayWindow, x, y) { this.displayed = [displayWindow, x, y] } }
const windowAnchor = { QsWindow: { contentItem: { mapFromItem() { return { x: 3, y: 4 } } }, window: { id: 'window' } } }
state = { activeTrayItem: trayItem('telegram'), activeTrayAnchor: anchorOf, trayMenuOpen: true }
result = runOpenTrayMenu(state, menuless, windowAnchor, { x: 3, y: 4 })
assert(result.trayMenuOpen === true && result.closes === 0, 'menuless icons do not toggle the menu')
assert(menuless.displayed && menuless.displayed[1] === 3, 'menuless icons still display their own popup')
JS
