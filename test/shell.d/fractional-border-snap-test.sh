#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const barSource = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')

const tooltipWindow = barSource.slice(
  barSource.indexOf('id: tooltipWindow'),
  barSource.indexOf('id: tooltipBubble')
)
const tooltipBubble = barSource.slice(
  barSource.indexOf('id: tooltipBubble'),
  barSource.indexOf('id: tooltipLabel')
)

// Window is padded beyond ceil(bubble) so a 1px border survives at small text
// sizes (e.g. 9) and 1.25x fractional device pixels.
assert(
  /implicitWidth:\s*Math\.ceil\(tooltipBubble\.implicitWidth\)\s*\+\s*2/.test(tooltipWindow)
    && /implicitHeight:\s*Math\.ceil\(tooltipBubble\.implicitHeight\)\s*\+\s*2/.test(tooltipWindow),
  'bar tooltip window pads 2 logical px beyond the ceil of the bubble'
)

assert(
  /anchors\.centerIn:\s*parent/.test(tooltipBubble),
  'bar tooltip bubble is centered inside the padded transparent window'
)

assert(
  !/width:\s*tooltipWindow\.width/.test(tooltipBubble)
    && !/height:\s*tooltipWindow\.height/.test(tooltipBubble),
  'bar tooltip bubble is not stretched to the window edge (keeps inset for the border)'
)
JS
