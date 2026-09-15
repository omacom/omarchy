#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const lockViewQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

assert(
  /Keys\.priority:\s*Keys\.BeforeItem/.test(lockViewQml),
  'the password field intercepts keys before TextInput inserts them'
)

assert(
  /var clearPassword = root\.displaysBlank/.test(lockViewQml),
  'a blanked lock screen treats the wake key like Escape: clear and swallow'
)

assert(
  /event\.accepted = clearPassword/.test(lockViewQml),
  'a key that wakes a blanked lock screen is swallowed instead of typed'
)

assert(
  /root\.wakeRequested\(\)/.test(lockViewQml),
  'the swallowed wake key still requests a display wake'
)
JS
