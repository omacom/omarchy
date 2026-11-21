#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelQml = fs.readFileSync(path.join(root, 'shell/Ui/KeyboardPanel.qml'), 'utf8')

// Surface exclusion and OSK input delivery need compositor acceptance checks;
// source-string assertions cannot establish either behavior.

// Evaluate the production geometry bindings, in surface coordinates, against
// a full-screen bar window whose dimensions say nothing about the strip.
const bindings = {}
for (const [type, name] of [['bool', 'barReserved'], ['real', 'originX'], ['real', 'originY'],
  ['real', 'surfaceW'], ['real', 'surfaceH'], ['real', 'barInset'],
  ['real', 'availableCardWidth'], ['real', 'availableCardHeight']]) {
  const found = panelQml.match(new RegExp('property ' + type + ' ' + name + ': ([^\\n]+(?:\\n    [^\\n]+)*)'))
  assert(found, name + ' binding exists')
  bindings[name] = new Function('root', 'with (root) { return (' + found[1] + ') }')
}
const originBody = panelQml.match(/property point cardOrigin: \{([\s\S]*?)\n  \}/)[1]
const place = new Function('root', 'Qt', 'with (root) {' + originBody + '}')
const qt = {point: (x, y) => ({x, y})}
function panel(props) {
  const root = Object.assign({
    anchorItem: {}, bar: {barHidden: false}, centerOnBar: false, barPos: 'top',
    screenW: 1920, screenH: 1080, width: 1920, height: 1080, insetOverlay: false,
    contentWidth: 300, contentHeight: 200, drawnHeight: 200, barThickness: 34, gap: 12, margin: 4,
    anchorScreenPos: {x: 800, y: 400}, anchorW: 34, anchorH: 34,
  }, props)
  root.root = root
  for (const name of Object.keys(bindings)) root[name] = bindings[name](root)
  root.cardOrigin = place(root, qt)
  return root
}

const right = {barPos: 'right', screenW: 1200, screenH: 1000, drawnHeight: 400, margin: 16, anchorScreenPos: {x: 1166, y: 950}}
assert(panel(right).cardOrigin.y === 584, 'fullscreen placement clamps the animated drawn height')
assert(panel({...right, insetOverlay: true, width: 1166, height: 700}).cardOrigin.y === 284,
  'OSK-inset placement also clamps the animated drawn height')

for (const inset of [false, true]) {
  for (const hidden of [false, true]) {
    for (const edge of ['top', 'left']) {
      const p = panel({barPos: edge, insetOverlay: inset, bar: {barHidden: hidden}})
      assert(p.barReserved === (inset && !hidden), 'only a visible bar reserves space on an inset surface')
      assert(p[edge === 'left' ? 'originX' : 'originY'] === (inset && !hidden ? 34 : 0), 'hiding the ' + edge + ' bar removes its offset')
    }
  }
}

// A 300px band (an OSK, a reserved area) insets the surface opposite the bar.
// The card sits a gap past the bar, or past a hidden bar's strip, wherever the
// surface's edges fall.
const expected = {top: {y: 12}, bottom: {y: 534}, left: {x: 12}, right: {x: 1274}}
for (const edge of ['top', 'bottom', 'left', 'right']) {
  const horizontal = edge === 'top' || edge === 'bottom'
  for (const hidden of [false, true]) {
    const strip = hidden ? 0 : 34
    const p = panel({barPos: edge, insetOverlay: true, bar: {barHidden: hidden},
      width: horizontal ? 1920 : 1920 - 300 - strip, height: horizontal ? 1080 - 300 - strip : 1080})
    const axis = horizontal ? 'y' : 'x'
    const want = expected[edge][axis] + (hidden && (edge === 'top' || edge === 'left') ? 34 : 0)
    assert(p.cardOrigin[axis] === want, 'card sits a gap past the ' + (hidden ? 'hidden ' : '') + edge + ' bar on an inset surface')
    assert(p.cardOrigin[horizontal ? 'x' : 'y'] === (horizontal ? 667 : 317), 'card stays under its icon along the ' + edge + ' bar')
    const budget = horizontal ? p.availableCardHeight : p.availableCardWidth
    assert(budget === (horizontal ? p.surfaceH : p.surfaceW) - (hidden ? 34 : 0) - 16, edge + ' budget leaves the strip, gap and margin')
  }
  const fullscreen = panel({barPos: edge})
  assert((horizontal ? fullscreen.availableCardHeight : fullscreen.availableCardWidth) === (horizontal ? 1080 : 1920) - 34 - 16,
    edge + ' budget keeps the strip out before the surface is inset')
}
JS
