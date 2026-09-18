#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')

const kindBlock = panelSource.match(/readonly property string kind: \{[\s\S]*?\n  \}/)
assert(kindBlock, 'network bar exposes a connection kind')
assert(
  /if \(wifiDevice && wifiDevice\.connected\) return "wifi"/.test(kindBlock[0]),
  'network bar derives Wi-Fi connection state from the live device'
)
assert(
  !/if \(connectedWifiNetwork\) return "wifi"/.test(kindBlock[0]),
  'network bar does not depend on scan-derived Wi-Fi state for connectivity'
)
JS
