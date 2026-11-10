#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')
const serviceSource = fs.readFileSync(root + '/shell/plugins/services/idle/Service.qml', 'utf8')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')
assertEqual(idle.optionalSecondsFromConfig('42.9'), 42, 'idle floors an optional timeout')
assertEqual(idle.optionalSecondsFromConfig(undefined), -1, 'idle disables an omitted optional timeout')
assertEqual(idle.optionalSecondsFromConfig(true), -1, 'idle rejects a boolean optional timeout')
assertEqual(idle.optionalSecondsFromConfig([900]), -1, 'idle rejects an array optional timeout')
assertEqual(idle.optionalSecondsFromConfig('999999999'), idle.MAX_TIMEOUT_SECONDS, 'idle clamps an optional timeout at the safe timer ceiling')
assertEqual(idle.MAX_TIMEOUT_SECONDS, 2147483, 'idle derives the safe timer ceiling in seconds')
assertEqual(idle.shouldSuspend(true, true, true, 900), true, 'idle suspend runs with a pending clock and clear inhibitor gate')
assertEqual(idle.shouldSuspend(false, true, true, 900), false, 'idle suspend needs a pending clock')
assertEqual(idle.shouldSuspend(true, false, true, 900), false, 'idle suspend waits for inhibitors')
assertEqual(idle.shouldSuspend(true, true, false, 900), false, 'idle suspend follows Stay Awake')
assertEqual(idle.secondsFromConfig(0, 300), 0, 'idle keeps an explicit zero timeout')
assertEqual(idle.firstIdleTimeout(150, 300), 150, 'idle uses the sooner of screensaver and lock')
assertEqual(idle.firstIdleTimeout(0, 300), 300, 'idle ignores a disabled screensaver when computing first idle')
assertEqual(idle.firstIdleTimeout(150, 0), 150, 'idle ignores a disabled lock when computing first idle')
assertEqual(idle.firstIdleTimeout(0, 0), 0, 'idle has no first-idle timeout when both actions are disabled')
assertEqual(idle.firstIdleTimeout(150, 300, 120), 120, 'idle includes suspend when choosing the first idle deadline')
assertEqual(idle.delayAfterFirstIdle(300, 150), 150, 'idle delays lock until its own timeout')
assertEqual(idle.delayAfterFirstIdle(150, 150), 0, 'idle fires an action immediately when it is the first timeout')
assertEqual(idle.delayAfterFirstIdle(0, 150), 0, 'idle does not schedule a disabled action')

assert(
  serviceSource.includes('IdleModel.firstIdleTimeout(screensaverTimeoutSeconds, lockTimeoutSeconds, suspendTimeoutSeconds)'),
  'idle shares the first user-idle deadline with suspend'
)
assert(
  /id: suspendTimer[\s\S]*?onTriggered: root\.attemptSuspend\(\)/.test(serviceSource),
  'idle uses a timer rather than an IdleMonitor as the suspend clock'
)
assert(
  /id: suspendInhibitorMonitor[\s\S]*?respectInhibitors: true/.test(serviceSource),
  'idle keeps an inhibitor-aware gate for suspend'
)
assert(
  /systemd-inhibit --list --json=short[\s\S]*?index\(\\"idle\\"\)/.test(serviceSource),
  'idle defers suspend for logind idle blockers'
)
assert(
  /id: suspendRetryTimer[\s\S]*?interval: 60000/.test(serviceSource),
  'idle retries after a temporary inhibitor'
)
assert(
  /id: lockStateProbe[\s\S]*?omarchy-shell lock isLocked/.test(serviceSource),
  'idle cancels a pending suspend after unlock'
)
assert(
  /onSuspendTimeoutSecondsChanged: root\.rearmIdleMonitor\(\)/.test(serviceSource),
  'idle re-arms after a suspend timeout change'
)
JS

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists enabled state"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists disabled state"

pass "Stay Awake toggle persists state"
