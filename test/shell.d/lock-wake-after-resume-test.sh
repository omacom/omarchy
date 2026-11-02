#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const viewQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

// The lock knows when it turned the displays off and when a wake brought them back.
assert(/property bool displaysBlank: false/.test(serviceQml), 'the lock tracks whether it blanked the displays')
assert(
  /function runBlank\(\) \{\s*displaysBlank = true/.test(serviceQml),
  'blanking the displays marks them as blank'
)
assert(
  /function runWake\(\) \{\s*displaysBlank = false/.test(serviceQml),
  'a wake clears the blank state'
)

// Keys hit at a dark panel wake it instead of landing in the password field.
assert(/property bool displaysBlank: false/.test(viewQml), 'the lock view knows when the displays are blank')
assert(/displaysBlank: root\.displaysBlank/.test(serviceQml), 'the lock view is told when the displays are blank')
assert(
  /Keys\.onPressed: function\(event\) \{[\s\S]*?var wasBlank = root\.displaysBlank\s*root\.wakeRequested\(\)[\s\S]*?if \(wasBlank\) \{\s*event\.accepted = true\s*return\s*\}/.test(viewQml),
  'a key pressed at a blank panel is consumed after requesting the wake, judged before the wake clears the state'
)
assert(
  /var wasBlank = root\.displaysBlank[\s\S]*?event\.isAutoRepeat[\s\S]*?if \(wasBlank\)/.test(viewQml),
  'the auto-repeat drop keeps its place ahead of the wake-key swallow'
)

// A panel relit behind the lock's back must not keep eating the first key, so
// Hyprland is asked for the real state while the lock has the displays off.
assert(
  /id: displayStateTimer[\s\S]*?running: root\.lockRequested && root\.displaysBlank/.test(serviceQml),
  'the display state is polled only while the lock has the displays off'
)
assert(
  /function applyDisplayState\(text\) \{[\s\S]*?if \(!displayStateTimer\.running\) return[\s\S]*?dpmsStatus === true\) \{\s*displaysBlank = false/.test(serviceQml),
  'a lit display clears the blank state, and an answer landing after the wake stopped the poll is dropped'
)

// Resume is detected from the clock jump the frozen shell sees on its first
// tick back, and the panel is woken without waiting for input.
assert(
  /id: resumeWatchTimer[\s\S]*?running: root\.lockRequested[\s\S]*?onRunningChanged: lastTick = running \? Date\.now\(\) : 0[\s\S]*?now - lastTick > interval \+ 2000[\s\S]*?if \(resumed\) \{[\s\S]*?root\.runWake\(\)/.test(serviceQml),
  'the lock wakes the panel on its own after resume'
)
JS
