#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelQml = fs.readFileSync(path.join(root, 'shell/Ui/KeyboardPanel.qml'), 'utf8')

// Surface exclusion and OSK input delivery need compositor acceptance checks;
// source-string assertions cannot establish either behavior.

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
const reserveBody = panelQml.match(/property bool barReserved: ([^\n]+)/)[1]
const reservesBar = new Function('insetOverlay', 'bar', 'return ' + reserveBody)
for (const inset of [false, true]) {
  for (const hidden of [false, true]) {
    const reserved = reservesBar(inset, {barHidden: hidden})
    assert(reserved === (inset && !hidden), 'only a visible bar reserves space on an inset surface')
    for (const edge of ['top', 'left']) {
      const axis = edge === 'left' ? 'originX' : 'originY'
      assert(expression(axis)(edge, reserved, 34, 1920, 1080) === (inset && !hidden ? 34 : 0),
        'hiding the ' + edge + ' bar removes its card offset')
    }
  }
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
