#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const lockViewQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

// `omarchy-brightness-display on` skips its dispatch when the display still
// looks lit, so a wake that overtakes an in-flight blank does nothing and the
// blank then takes the panel down behind it, with the blanked flag already
// false and the keyboard monitor disarmed.
assert(
  /if \(blankProcess\.running\) root\.wakeHeld = true\s*else if \(!wakeProcess\.running\) wakeProcess\.running = true/.test(serviceQml),
  'a wake waits for an in-flight blank instead of racing its DPMS off'
)

// A screen change mid-blank clears displaysBlank without anyone asking for a
// wake, so the flag alone would light a lock nobody touched.
assert(
  /id: blankProcess[\s\S]*?onExited: \{\s*if \(root\.wakeHeld && !root\.displaysBlank && !wakeProcess\.running\) wakeProcess\.running = true\s*root\.wakeHeld = false/.test(serviceQml),
  'the blank runs only a wake it actually held back, once its own DPMS off has landed'
)

assert(
  /function runBlank\(\) \{[^}]*root\.wakeHeld = false/.test(serviceQml),
  'a later blank supersedes a wake held back by an earlier one'
)

// Armed at blank time the idle notification never primes under someone typing
// straight in, so it has to be armed for the whole lock.
assert(
  /IdleMonitor \{\s*id: blankWakeMonitor\s*enabled: root\.lockRequested\s*timeout: 1\s*respectInhibitors: false\s*onIsIdleChanged: if \(!isIdle && root\.displaysBlank\) root\.runWake\(\)/.test(serviceQml),
  'the keyboard wake monitor is armed for the whole lock and only wakes a blanked screen'
)

// Keys the field cannot hear still reach the compositor; blanking under them
// would leave the monitor with no idle edge to wake on.
assert(
  /if \(root\.lockRequested && !blankWakeMonitor\.isIdle\) \{\s*root\.armBlankTimer\(\)\s*return\s*\}/.test(serviceQml),
  'the blank waits while the compositor still sees input'
)

// The blanked flag clears when the wake is dispatched, not when the compositor
// has handed the surface its keyboard focus back, so one call can land early.
assert(
  /running: root\.inputEnabled && !root\.authenticatingPassword && !root\.displaysBlank && !passwordInput\.activeFocus\s*\n\s*onTriggered: root\.forcePasswordFocus\(\)/.test(lockViewQml),
  'the refocus retries until the field holds focus, and idles while blanked'
)
JS
