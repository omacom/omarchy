#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/Ui/KeyboardPanel.qml', 'utf8')
const closeMatch = source.match(/function close\(\) \{[\s\S]*?\n  \}/)

assert(!!closeMatch, 'KeyboardPanel defines close()')
assert(/try \{/.test(closeMatch[0]) && /catch \(e\)/.test(closeMatch[0]),
  'KeyboardPanel close() catches a throwing owner.close()')
assert(/owner\.controller\.hide/.test(closeMatch[0]),
  'KeyboardPanel close() still hides the owner controller after a throw')
assert(/else\s*\n\s*root\.open = false/.test(closeMatch[0]),
  'KeyboardPanel close() still clears open when there is no owner controller')
JS
