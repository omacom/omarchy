#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelQml = fs.readFileSync(path.join(root, 'shell/Ui/KeyboardPanel.qml'), 'utf8')
const pluginBarApiQml = fs.readFileSync(path.join(root, 'shell/Ui/PluginBarApi.qml'), 'utf8')
const barQml = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')

assert(
  /exclusionMode: ExclusionMode\.Auto/.test(panelQml),
  'bar panels respect the reserved area of an on-screen keyboard'
)
assert(
  !/exclusionMode: ExclusionMode\.Ignore/.test(panelQml),
  'bar panels do not cover exclusive zones (OSK taps would dismiss the popdown)'
)
assert(
  /WlrLayershell\.keyboardFocus: open/.test(panelQml) &&
    /focusPrimed \? WlrKeyboardFocus\.OnDemand : WlrKeyboardFocus\.Exclusive/.test(panelQml),
  'bar panels settle on OnDemand keyboard focus so pointer input can reach an OSK'
)
assert(
  /localX = x - root\.originX/.test(panelQml) && /localY = y - root\.originY/.test(panelQml),
  'panel cards are positioned in the inset overlay, not double-offset by the bar exclusive zone'
)
assert(
  !/root\.x/.test(panelQml) && !/root\.y/.test(panelQml),
  'panel positioning never reads PanelWindow x/y (undefined there, NaNs the card origin to top-left)'
)
assert(
  /barReserved: insetOverlay && !\(bar && bar\.barHidden\)/.test(panelQml) &&
    /originX: \(barPos === "left" && barReserved\)/.test(panelQml) &&
    /originY: \(barPos === "top" && barReserved\)/.test(panelQml),
  'a hidden bar does not shift the card when an OSK insets the overlay'
)
assert(
  /property bool barHidden: false/.test(pluginBarApiQml) &&
    /api\.barHidden = Qt\.binding\(function\(\) \{ return root\.barHidden \}\)/.test(barQml),
  'third-party panels see the hidden bar too, through the widget bar facade'
)
assert(
  /insetOverlay: backingWindowVisible/.test(panelQml),
  'panel overlay measurements wait for the mapped surface instead of trusting pre-map geometry'
)

// Evaluate the production geometry against a full-screen bar window. Its
// dimensions must not become the reserved strip size after upstream's drag fix.
const originBody = panelQml.match(/property point cardOrigin: \{([\s\S]*?)\n  \}/)[1]
const place = new Function('root', 'Qt', 'with (root) {' + originBody + '}')
const geometry = {
  anchorItem: {}, bar: {}, centerOnBar: false, barPos: 'right',
  screenW: 1200, screenH: 1000, contentWidth: 300, contentHeight: 200,
  drawnHeight: 400, barThickness: 34, gap: 8, margin: 16,
  anchorScreenPos: {x: 1166, y: 950}, anchorW: 34, anchorH: 34,
  originX: 0, originY: 0, insetOverlay: false, width: 1200, height: 700,
}
const qt = {point: (x, y) => ({x, y})}
assert(place(geometry, qt).y === 584, 'fullscreen placement clamps the animated drawn height')
geometry.insetOverlay = true
assert(place(geometry, qt).y === 284, 'OSK-inset placement also clamps the animated drawn height')

function expression(name) {
  const found = panelQml.match(new RegExp('property real ' + name + ': ([^\\n]+)'))
  assert(found, name + ' binding exists')
  return new Function('barPos', 'barReserved', 'barThickness', 'barW', 'barH', 'return ' + found[1])
}
for (const edge of ['top', 'bottom', 'left', 'right']) {
  assert(expression('originX')(edge, true, 34, 1920, 1080) === (edge === 'left' ? 34 : 0), 'horizontal inset uses the strip at ' + edge)
  assert(expression('originY')(edge, true, 34, 1920, 1080) === (edge === 'top' ? 34 : 0), 'vertical inset uses the strip at ' + edge)
  for (const inset of [false, true]) {
    for (const axis of ['Width', 'Height']) {
      const body = panelQml.match(new RegExp('property real availableCard' + axis + ': \\{([\\s\\S]*?)\\n  \\}'))
      assert(body, axis + ' budget binding exists')
      const run = new Function('root', 'width', 'height', 'screenW', 'screenH', 'barPos', 'barThickness', 'barW', 'barH', 'gap', 'margin', body[1])
      const horizontal = edge === 'top' || edge === 'bottom'
      const surface = axis === 'Width' ? (inset && !horizontal ? 1886 : 1920) : (inset ? (horizontal ? 746 : 780) : 1080)
      const reserve = !inset && ((axis === 'Width') !== horizontal) ? 42 : 0
      const actual = run({insetOverlay: inset}, !horizontal ? 1886 : 1920, horizontal ? 746 : 780, 1920, 1080, edge, 34, 1920, 1080, 8, 16)
      assert(actual === surface - reserve - 32, axis + ' budget respects the actual overlay and strip at ' + edge)
    }
  }
}
JS
