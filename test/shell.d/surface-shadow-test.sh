#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const geometry = requireFromRoot('shell/Commons/ShadowGeometry.js')
const read = file => fs.readFileSync(path.join(root, file), 'utf8')
const make = values => geometry.spec(Object.fromEntries(Object.entries(values).map(([k,v]) => ['popups.shadow-' + k, v])), 'popups')
const insets = s => [s.left, s.right, s.top, s.bottom]

assert(!make({}).enabled, 'old themes have no shadows')
assertDeepEqual(insets(make({})), [0,0,0,0], 'disabled shadows do not change window geometry')
assertDeepEqual(insets(make({alpha: '0.5'})), [25,25,19,31], 'default geometry includes blur and downward offset')
assertDeepEqual(insets(make({alpha: 1, blur: 10, spread: 2, 'offset-x': -4, 'offset-y': 6})), [17,9,7,19], 'negative and positive offsets reserve asymmetric space')
assertDeepEqual(insets(make({alpha: 1, blur: 4.5, spread: 0, 'offset-x': 0.25, 'offset-y': -0.25})), [6,6,6,6], 'fractional extents round outward')
assertDeepEqual(insets(make({alpha: 1, blur: 0, spread: -64, 'offset-x': 128, 'offset-y': -128})), [0,129,129,0], 'shrunk offset shadows never produce negative insets')
assert(!make({alpha: -2}).enabled, 'negative alpha disables shadows')
assert(!make({alpha: 'invalid'}).enabled, 'invalid alpha preserves opt-in default')
for (const raw of ['NaN', 'Infinity', '-Infinity', 'bad', '']) {
  const s = make({alpha: 1, blur: raw, spread: raw, 'offset-x': raw, 'offset-y': raw})
  assertDeepEqual([s.blur,s.spread,s.offsetX,s.offsetY], [24,0,0,6], `invalid geometry falls back: ${raw}`)
}
const max = make({alpha: 9, blur: 1e10, spread: 1e10, 'offset-x': -1e10, 'offset-y': 1e10})
assertDeepEqual([max.alpha,max.blur,max.spread,max.offsetX,max.offsetY], [1,128,64,-128,128], 'render extents are bounded')
assert(!geometry.spec({'bar.shadow-alpha': 1}, 'bar').enabled, 'the bar cannot opt in')
assert(!geometry.spec({'.shadow-alpha': 1}, '').enabled, 'ordinary controls cannot opt in')

// Exercise the actual parser and merge functions, not a parallel TOML parser.
const color = read('shell/Commons/Color.qml')
function qmlFunction(source, name) {
  const start = source.indexOf('  function ' + name + '(')
  assert(start >= 0, `find production ${name}`)
  const end = source.indexOf('\n  }', start)
  return source.slice(start, end + 4)
}
const scope = { themeShellValues: {}, userShellValues: {}, shellValues: {}, Style: { applyShellValues() {} } }
vm.createContext(scope)
for (const name of ['parseShell', 'mergeShell', 'loadShell', 'loadUserShell']) vm.runInContext(qmlFunction(color, name), scope)
scope.loadShell('[popups]\nshadow-alpha = 0.4\nshadow-color = "#334455"\nshadow-offset-y = -4\n')
scope.loadUserShell('[popups]\nshadow-alpha = 0\n')
assert(!geometry.spec(scope.shellValues, 'popups').enabled, 'user override disables theme shadow')
scope.loadShell('[popups]\nshadow-alpha = 0.8\nshadow-offset-y = 2\n')
assert(!geometry.spec(scope.shellValues, 'popups').enabled, 'user disable survives a theme switch')
scope.loadUserShell('')
assertEqual(geometry.spec(scope.shellValues, 'popups').alpha, 0.8, 'removing override restores theme shadow')
scope.loadShell('')
assert(!geometry.spec(scope.shellValues, 'popups').enabled, 'switching to an old theme removes shadow')

const surfaces = {
  'shell/Ui/KeyboardPanel.qml': 'popups',
  'shell/Ui/PopupCard.qml': 'popups',
  'shell/Ui/ConfirmDialog.qml': 'popups',
  'shell/Ui/Dropdown.qml': 'popups',
  'shell/Ui/SearchableDropdown.qml': 'popups',
  'shell/Ui/MultiSelect.qml': 'popups',
  'shell/Ui/PanelToolTip.qml': 'tooltip',
  'shell/Ui/Button.qml': 'tooltip',
  'shell/plugins/menu/Menu.qml': 'menu',
  'shell/plugins/clipboard/Clipboard.qml': 'menu',
  'shell/plugins/emojis/Emojis.qml': 'menu',
  'shell/plugins/reminders/ReminderFlow.qml': 'menu',
  'shell/plugins/polkit/PolkitAgent.qml': 'polkit',
  'shell/plugins/osd/Osd.qml': 'popups',
  'shell/plugins/panels/tailscale/Panel.qml': 'popups',
  'shell/plugins/panels/wifiqr/Panel.qml': 'popups',
}
for (const [file, section] of Object.entries(surfaces)) {
  assert(read(file).includes(`shadowSection: "${section}"`), `${file} opts its outer surface into ${section}`)
}
for (const file of ['Dropdown', 'SearchableDropdown', 'MultiSelect', 'PanelToolTip', 'Button']) {
  const source = read(`shell/Ui/${file}.qml`)
  for (const side of ['left', 'right', 'top', 'bottom']) {
    assert(source.includes(`${side}Margin: shadowInsets.enabled ? Math.max(margins, shadowInsets.${side}) : margins`), `${file} reserves ${side} window-edge clearance only when enabled`)
  }
}
const shared = read('shell/Ui/BorderSurface.qml')
assert(shared.includes('property string shadowSection: ""'), 'shared controls default to no shadow')
assert(shared.includes('active: root.shadowSpec.enabled'), 'disabled shadows allocate no renderer')
const renderer = read('shell/Ui/SurfaceShadow.qml')
assert(renderer.includes('maskInverted: true'), 'renderer excludes card interior for translucent backgrounds')
const lock = read('shell/plugins/lock/LockView.qml')
assert(lock.includes('Shadow.surfaceSpec("lock")') && lock.includes('clip: true'), 'lock keeps password clipping with sibling shadow')
const notifications = read('shell/plugins/notifications/Service.qml')
assert(notifications.includes('import qs.Ui') && notifications.includes('Shadow.surfaceSpec("notifications")'), 'toast service imports the renderer and opts in')
assert(!read('shell/plugins/notifications/components/NotificationCard.qml').includes('shadowSection:'), 'notification history remains flat')
const popup = read('shell/Ui/PopupCard.qml')
assert(popup.includes('mask: Region { item: card }'), 'popup shadow padding does not capture input')
assert(popup.includes('implicitWidth: contentWidth + shadowSpec.left + shadowSpec.right'), 'popup window includes horizontal shadow extents')
assert(popup.includes('implicitHeight: contentHeight + shadowSpec.top + shadowSpec.bottom'), 'popup window includes vertical shadow extents')
assert(popup.includes('point.x - root.shadowSpec.left') && popup.includes('point.y - root.shadowSpec.top'), 'popup anchors retain visible card alignment')
const bar = read('shell/plugins/bar/Bar.qml')
assertEqual((bar.match(/shadowSection:/g) || []).length, 1, 'only the bar-owned tooltip opts in, never the bar')
assert(bar.includes('shadowSection: "tooltip"') && bar.includes('mask: Region { item: tooltipBubble }'), 'bar tooltip is padded without expanding input')
JS
