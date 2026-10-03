#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/Ui/KeyboardPanel.qml', 'utf8')
// Comments stripped, so a commented-out fallback cannot satisfy the assertions.
const closeMatch = source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*\/\/.*\n/gm, '').match(/function close\(\) \{[\s\S]*?\n  \}/)

assert(!!closeMatch, 'KeyboardPanel defines close()')
const catchMatch = closeMatch[0].match(/try \{\s*\n\s*owner\.close\(\)\s*\n\s*\} catch \(e\) \{([\s\S]*?)\n      \}/)

assert(!!catchMatch, 'KeyboardPanel close() catches a throwing owner.close()')
assert(/owner\.controller\.hide\(\)/.test(catchMatch[1]),
  'KeyboardPanel close() hides the owner controller after a throw')
assert(/else root\.open = false/.test(catchMatch[1]),
  'KeyboardPanel close() clears open after a throw when the owner has no controller')
const outsideCatch = closeMatch[0].replace(catchMatch[1], '')
assert((outsideCatch.match(/root\.open = false/g) || []).length === 1 && /\} else \{\s*\n\s*root\.open = false/.test(outsideCatch),
  'KeyboardPanel close() leaves open bound to its owner when owner.close() succeeds')
JS
