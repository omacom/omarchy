#!/bin/bash
# A rejected password disables the field and Qt clears activeFocus. Enabling
# the field again does not focus it, and inputEnabled never flips, so focus
# has to be taken from onAuthenticatingPasswordChanged.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const view = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

assert(
  /onAuthenticatingPasswordChanged:\s*\{\s*if \(!authenticatingPassword && inputEnabled\) Qt\.callLater\(forcePasswordFocus\)/.test(view),
  'a finished password check focuses the field again'
)

assert(
  /enabled:\s*root\.inputEnabled && !root\.authenticatingPassword/.test(view),
  'the field is still disabled for the duration of the password check'
)
JS
