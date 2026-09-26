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

run_node_test "tray drawer expand and pin invariants" <<'JS'
const fs = require('fs')
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')
const traySource = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')

assert(/property\s+bool\s+drawerPinned\s*:\s*false/.test(traySource), 'tray defines drawerPinned state')
assert(/function\s+toggleExpanded\s*\(\)/.test(traySource), 'tray exposes toggleExpanded helper')
assert(/TrayModel\.toggleExpandedState\(drawerPinned,\s*drawerAreaHovered\)/.test(traySource), 'toggleExpanded delegates to TrayModel.toggleExpandedState')
assert(/readonly\s+property\s+bool\s+drawerHovered\s*:\s*TrayModel\.drawerHovered\(/.test(traySource), 'drawerHovered delegates to TrayModel')
assert(/readonly\s+property\s+bool\s+expanded\s*:\s*TrayModel\.drawerExpanded\(/.test(traySource), 'expanded delegates to TrayModel')
assert(/property\s+real\s+revealProgress\s*:\s*TrayModel\.drawerRevealProgress\(/.test(traySource), 'revealProgress delegates to TrayModel')
assert(!/onHoveredChanged:\s*root\.expanded\s*=\s*hovered/.test(traySource), 'hover-exit does not unconditionally overwrite root.expanded')

// Ensure both horizontal and vertical layouts wire expandIcon and HoverHandler
const hoverMatches = traySource.match(/root\.drawerAreaHovered\s*=\s*hovered[\s\S]*?root\.drawerHoverSuppressed\s*=\s*false/g) || []
assertEqual(hoverMatches.length, 2, 'both horizontal and vertical HoverHandlers manage hover and reset suppression')

const toggleMatches = traySource.match(/root\.toggleExpanded\(\)/g) || []
assertEqual(toggleMatches.length, 2, 'both horizontal and vertical expandIcons invoke toggleExpanded on left-click')

class TrayState {
  constructor() {
    this.drawerPinned = false
    this.drawerAreaHovered = false
    this.drawerHoverSuppressed = false
    this.managePopupOpen = false
    this.trayMenuOpen = false
  }
  get drawerHovered() {
    return tray.drawerHovered(this.drawerAreaHovered, this.drawerHoverSuppressed)
  }
  get expanded() {
    return tray.drawerExpanded(this.drawerPinned, this.drawerHovered)
  }
  get revealProgress() {
    return tray.drawerRevealProgress(this.expanded, this.managePopupOpen, this.trayMenuOpen)
  }
  setHovered(hovered) {
    this.drawerAreaHovered = hovered
    if (!hovered) this.drawerHoverSuppressed = false
  }
  toggleExpanded() {
    const next = tray.toggleExpandedState(this.drawerPinned, this.drawerAreaHovered)
    this.drawerPinned = next.drawerPinned
    this.drawerHoverSuppressed = next.drawerHoverSuppressed
  }
}

const sim = new TrayState()
assertEqual(sim.expanded, false, 'initially collapsed')
assertEqual(sim.revealProgress, 0, 'reveal progress initially 0')

// Hover in
sim.setHovered(true)
assertEqual(sim.expanded, true, 'hover reveals drawer')
assertEqual(sim.revealProgress, 1, 'reveal progress 1 on hover')

// Hover out without click
sim.setHovered(false)
assertEqual(sim.expanded, false, 'hover exit collapses drawer')
assertEqual(sim.revealProgress, 0, 'reveal progress 0 after hover exit')

// Hover in, then click to pin
sim.setHovered(true)
sim.toggleExpanded()
assertEqual(sim.drawerPinned, true, 'click pins drawer open')
assertEqual(sim.expanded, true, 'drawer stays expanded when pinned')

// Hover out while pinned
sim.setHovered(false)
assertEqual(sim.drawerPinned, true, 'drawer remains pinned after hover ends')
assertEqual(sim.expanded, true, 'drawer stays expanded across hover exit')
assertEqual(sim.revealProgress, 1, 'reveal progress remains 1 when pinned')

// Click to collapse while hovering
sim.setHovered(true)
sim.toggleExpanded()
assertEqual(sim.drawerPinned, false, 'clicking pinned drawer unpins')
assertEqual(sim.expanded, false, 'unpinning immediately collapses drawer even while hovering')
assertEqual(sim.revealProgress, 0, 'reveal progress 0 after unpin')

// Hover out clears suppression
sim.setHovered(false)
assertEqual(sim.drawerHoverSuppressed, false, 'hover exit resets suppression')

// Next hover works normally
sim.setHovered(true)
assertEqual(sim.expanded, true, 'subsequent hover re-opens drawer')
sim.setHovered(false)

// Touch tap sequence (click without hover)
sim.toggleExpanded()
assertEqual(sim.drawerPinned, true, 'touch tap pins open')
assertEqual(sim.expanded, true, 'touch tap expands')
sim.toggleExpanded()
assertEqual(sim.drawerPinned, false, 'second touch tap unpins')
assertEqual(sim.drawerHoverSuppressed, false, 'hover suppression is not set when unpinning without hover')

// Mouse enters after touch tap unpin
sim.setHovered(true)
assertEqual(sim.drawerHovered, true, 'mouse hover works immediately after tap unpin')
assertEqual(sim.expanded, true, 'drawer reveals on hover after tap unpin')
sim.setHovered(false)

// Open manage popup or tray item menu keeps drawer revealed
sim.managePopupOpen = true
assertEqual(sim.revealProgress, 1, 'manage popup keeps drawer revealed')
sim.managePopupOpen = false
sim.trayMenuOpen = true
assertEqual(sim.revealProgress, 1, 'tray item menu keeps drawer revealed')
sim.trayMenuOpen = false
assertEqual(sim.revealProgress, 0, 'closing menus restores collapsed progress when unpinned')
JS
