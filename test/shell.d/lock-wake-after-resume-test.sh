#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const viewQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

// The lock knows when it blanked the panel and when a wake brought it back.
assert(/property bool displaysBlank: false/.test(serviceQml), 'the lock tracks whether it blanked the panel')
assert(
  /function runBlank\(\) \{\s*root\.displaysBlank = true/.test(serviceQml),
  'blanking the panel marks the displays as blank'
)
assert(
  /function runWake\(\) \{\s*root\.displaysBlank = false/.test(serviceQml),
  'a wake clears the blank state'
)

// Keys hit at a dark panel wake it instead of landing in the password field.
assert(/property bool displaysBlank: false/.test(viewQml), 'the lock view knows when the panel is blank')
assert(/displaysBlank: root\.screenBlank\(/.test(serviceQml), 'the lock view is told when its panel is blank')
assert(
  /Keys\.onPressed: function\(event\) \{[\s\S]*?var wasBlank = root\.displaysBlank\s*root\.wakeRequested\(\)\s*if \(wasBlank\) \{\s*event\.accepted = true\s*return\s*\}/.test(viewQml),
  'a key pressed at a blank panel is consumed after requesting the wake, judged before the wake clears the state'
)

// Resume is detected from the clock jump the frozen shell sees on its first
// tick back, and the panel is woken without waiting for input.
assert(
  /id: resumeWatchTimer[\s\S]*?running: root\.lockRequested[\s\S]*?now - lastTick > interval \+ 2000[\s\S]*?if \(resumed\) \{[\s\S]*?root\.runWake\(\)/.test(serviceQml),
  'the lock wakes the panel on its own after resume'
)
JS
