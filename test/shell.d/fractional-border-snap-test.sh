#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const barSource = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
const panelSource = fs.readFileSync(path.join(root, 'shell/plugins/panels/monitor/Panel.qml'), 'utf8')

const tooltipBlock = barSource.slice(
  barSource.indexOf('id: tooltipBubble'),
  barSource.indexOf('id: tooltipLabel')
)

assert(
  /width:\s*tooltipWindow\.width/.test(tooltipBlock)
    && /height:\s*tooltipWindow\.height/.test(tooltipBlock),
  'bar tooltip bubble fills its rounded-up window'
)

assert(
  /readonly property real cellWidth: root\.scaleValues\.length > 0\s*\n\s*\?\s*Math\.floor\(\(width - spacing \* \(columns - 1\)\) \/ columns\)/.test(panelSource),
  'monitor scaleRow.cellWidth snaps with Math.floor'
)

function cellWidth(width, spacing, columns) {
  return columns > 0 ? Math.floor((width - spacing * (columns - 1)) / columns) : 0
}

const width = 280
const spacing = 3
const columns = 6
const snapped = cellWidth(width, spacing, columns)

assertEqual(Number.isInteger(snapped), true, 'cellWidth is an integer logical pixel')
assert(snapped * columns + spacing * (columns - 1) <= width, 'floored cellWidth does not overflow the row')
assertEqual(snapped, 44, 'six-preset 280px row floors to 44px cells')

const remainderAt125 = (snapped * 1.25) % 1
assertEqual(remainderAt125, 0, '1.25x maps floored cellWidth onto whole device pixels')

const raw = (width - spacing * (columns - 1)) / columns
assert(!(Number.isInteger(raw)), 'raw unfloored cellWidth stays fractional (regression fixture)')
assert((raw * 1.25) % 1 !== 0, 'raw cellWidth leaves a 1.25x device-pixel remainder')
JS
