#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const barQml = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
const tooltip = barQml.slice(barQml.indexOf('id: tooltipWindow'), barQml.indexOf('Component {', barQml.indexOf('id: tooltipWindow')))

assert(
  /implicitWidth:\s*Math\.ceil\(tooltipBubble\.implicitWidth\)\s*\+\s*2\s*\*\s*Style\.spacing\.hairline/.test(tooltip),
  'tooltip window reserves horizontal hairline slack'
)
assert(
  /implicitHeight:\s*Math\.ceil\(tooltipBubble\.implicitHeight\)\s*\+\s*2\s*\*\s*Style\.spacing\.hairline/.test(tooltip),
  'tooltip window reserves vertical hairline slack'
)
assert(
  /anchors\.fill:\s*parent[\s\S]*anchors\.margins:\s*Style\.spacing\.hairline/.test(tooltip),
  'tooltip border surface stays inside the popup clip edge'
)
JS

pass "Tooltip border keeps device-pixel slack at fractional scales"
