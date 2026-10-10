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
assertEqual(
  idle.secondsFromConfig('999999999', 10),
  idle.MAX_TIMEOUT_SECONDS,
  'idle clamps a timeout whose milliseconds overflow the int32 timer'
)
assertEqual(
  idle.secondsFromConfig(idle.MAX_TIMEOUT_SECONDS, 10),
  idle.MAX_TIMEOUT_SECONDS,
  'idle keeps the largest timeout that still fits the int32 timer'
)
assert(
  idle.MAX_TIMEOUT_SECONDS * 1000 <= 2147483647,
  'idle timeout ceiling stays inside a signed 32-bit millisecond interval'
)
assertEqual(idle.MAX_TIMEOUT_SECONDS, 2147483, 'idle timeout ceiling is the largest whole second that fits')
assertEqual(idle.secondsFromConfig(0, 300), 0, 'idle keeps an explicit zero timeout')
assertEqual(idle.firstIdleTimeout(150, 300), 150, 'idle uses the sooner of screensaver and lock')
assertEqual(idle.firstIdleTimeout(0, 300), 300, 'idle ignores a disabled screensaver when computing first idle')
assertEqual(idle.firstIdleTimeout(150, 0), 150, 'idle ignores a disabled lock when computing first idle')
assertEqual(idle.firstIdleTimeout(0, 0), 0, 'idle has no first-idle timeout when both actions are disabled')
assertEqual(idle.delayAfterFirstIdle(300, 150), 150, 'idle delays lock until its own timeout')
assertEqual(idle.delayAfterFirstIdle(150, 150), 0, 'idle fires an action immediately when it is the first timeout')
assertEqual(idle.delayAfterFirstIdle(0, 150), 0, 'idle does not schedule a disabled action')

assert(
  serviceSource.includes('IdleModel.firstIdleTimeout(screensaverTimeoutSeconds, lockTimeoutSeconds)'),
  'idle ignores a zero timeout when computing the first idle deadline'
)
assert(
  /enabled: root\.idleEnabled && root\.idleTimersEnabled/.test(serviceSource),
  'idle monitor is off when both screensaver and lock are disabled'
)
assert(
  /if \(root\.lockEnabled\) \{\s*\n\s*if \(root\.lockDelaySeconds === 0\) lockSystem/.test(serviceSource),
  'idle does not lock immediately when lock timeout is disabled'
)
assert(
  /id: screensaverTimer[\s\S]*?onTriggered: if \(root\.screensaverEnabled\) root\.launchScreensaver\(\)/.test(serviceSource),
  'idle does not launch a pending screensaver once its timeout is set to 0'
)
assert(
  /id: lockTimer[\s\S]*?onTriggered: if \([^)]*root\.lockEnabled\) root\.lockSystem\("lock-timeout"\)/.test(serviceSource),
  'idle does not fire a pending lock once its timeout is set to 0'
)
assert(
  /lockTimer\.interval = root\.lockDelaySeconds \* 1000\s*\n\s*lockTimer\.restart\(\)/.test(serviceSource) &&
    !/interval: root\.lockDelaySeconds/.test(serviceSource),
  'idle keeps a pending lock on its deadline when shell.json changes mid-cycle'
)
assert(
  /screensaverTimer\.interval = root\.screensaverDelaySeconds \* 1000\s*\n\s*screensaverTimer\.restart\(\)/.test(serviceSource) &&
    !/interval: root\.screensaverDelaySeconds/.test(serviceSource),
  'idle keeps a pending screensaver on its deadline when shell.json changes mid-cycle'
)
assert(
  /onIdleTimersEnabledChanged: if \(!idleTimersEnabled\) cancelIdleCycle\(/.test(serviceSource),
  'idle ends a running cycle when both timeouts are set to 0'
)

assertDeepEqual(idle.eventParts({ data: 'a,b,c' }, 2), ['a', 'b', 'c'], 'idle parses raw event data')
assertDeepEqual(
  idle.eventParts({ parse: function(count) { return ['parsed', count] } }, 4),
  ['parsed', 4],
  'idle prefers event parser when available'
)

assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true }, 'b', true),
  { windows: { a: true, b: true }, count: 2 },
  'idle adds visible screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true, b: true }, 'a', false),
  { windows: { b: true }, count: 1 },
  'idle removes closed screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true }, '', false),
  { windows: { a: true }, count: 1 },
  'idle leaves screensaver windows unchanged without an address'
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

if rg -q 'omarchy-shell' "$ROOT/bin/omarchy-toggle-idle"; then
  fail "Stay Awake toggle avoids reentrant shell IPC"
fi

pass "Stay Awake toggle persists state without reentrant shell IPC"

# The int32 ceiling is enforced once, inside secondsFromConfig. Reading a
# timeout straight off idleConfig would walk around it and bring the 1ms timer
# storm back, so keep both timeouts wired through the model.
idle_service="$ROOT/shell/plugins/services/idle/Service.qml"

for timeout in screensaver lock; do
  rg -q "readonly property int ${timeout}TimeoutSeconds: secondsFromConfig\(idleConfig\.${timeout}," "$idle_service" ||
    fail "idle ${timeout} timeout is clamped through secondsFromConfig"
done

pass "idle timeouts reach the timers through the clamping model"
