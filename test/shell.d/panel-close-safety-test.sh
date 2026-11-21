#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const keyboardPanel = fs.readFileSync(path.join(root, 'shell/Ui/KeyboardPanel.qml'), 'utf8')
const popupCard = fs.readFileSync(path.join(root, 'shell/Ui/PopupCard.qml'), 'utf8')

// If a plugin's close() method throws an exception, the panel must catch it
// and force root.open = false so full-screen overlay mouse areas do not remain
// mapped and wedge desktop pointer input (omacom/omarchy#13382).
assert(
  /function close\(\)\s*\{\s*try\s*\{\s*if\s*\(owner\s*&&\s*"close"\s*in\s*owner\)\s*\{\s*owner\.close\(\)\s*return\s*\}\s*\}\s*catch\s*\(e\)\s*\{[\s\S]*?\}\s*root\.open\s*=\s*false\s*\}/.test(
    keyboardPanel
  ),
  'KeyboardPanel guards owner.close() with try/catch and falls back to root.open = false'
)

assert(
  /function close\(\)\s*\{\s*try\s*\{\s*if\s*\(owner\s*&&\s*"close"\s*in\s*owner\)\s*\{\s*owner\.close\(\)\s*return\s*\}\s*\}\s*catch\s*\(e\)\s*\{[\s\S]*?\}\s*root\.open\s*=\s*false\s*\}/.test(
    popupCard
  ),
  'PopupCard guards owner.close() with try/catch and falls back to root.open = false'
)
JS
