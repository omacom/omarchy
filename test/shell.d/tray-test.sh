#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "tray model helpers" <<'JS'
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')

// Bright wallpaper requires dark bar icons, but opaque dark menus still need
// light text. Evaluate the real binding rather than pinning a particular color.
const foreground = source.match(/readonly property color foreground: (.*)/)[1]
const colors = { foreground: '#eeeeee', bar: { text: '#eeeeee' }, popups: { text: '#ffffff' } }
const bar = { foreground: '#eeeeee', barForeground: '#101315' }
assertEqual(vm.runInNewContext(foreground, { bar, Color: colors }), '#ffffff', 'tray popup text uses the popup palette rather than wallpaper contrast')
const icon = source.slice(source.indexOf('  component TrayIcon:'))
const tint = icon.match(/property color tint: (.*)/)[1]
assertEqual(vm.runInNewContext(tint, { root: { bar }, Color: colors }), '#101315', 'bar tray icons retain wallpaper contrast')
assert(/colorizationColor: trayIconRoot\.tint/.test(icon), 'symbolic tray icons use their surface-specific tint')
assert(/id: rowIcon[\s\S]*?tint: root\.foreground/.test(source), 'management-popup icons override the bar tint with the popup foreground')

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
