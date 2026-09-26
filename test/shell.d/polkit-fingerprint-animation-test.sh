#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const polkitQml = fs.readFileSync(path.join(root, 'shell/plugins/polkit/PolkitAgent.qml'), 'utf8')

assert(
  /id: fingerprintGlyph/.test(polkitQml),
  'the fingerprint sensor glyph is addressable for animation'
)

assert(
  /running: root\.fingerprintMode/.test(polkitQml),
  'the sensor glyph pulses only while the fingerprint prompt is live'
)
JS
