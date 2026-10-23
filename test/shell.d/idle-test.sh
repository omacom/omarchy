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
assertEqual(idle.optionalSecondsFromConfig(null), -1, 'idle disables a null optional timeout')
assertEqual(idle.optionalSecondsFromConfig(0), -1, 'idle disables a zero optional timeout')
assertEqual(idle.optionalSecondsFromConfig(0.5), -1, 'idle disables an optional timeout flooring below one second')
assertEqual(idle.optionalSecondsFromConfig('-1'), -1, 'idle disables a negative optional timeout')
assertEqual(idle.optionalSecondsFromConfig('nope'), -1, 'idle disables an invalid optional timeout')
assertEqual(idle.optionalSecondsFromConfig(true), -1, 'idle rejects a boolean optional timeout')
assertEqual(idle.optionalSecondsFromConfig([900]), -1, 'idle rejects an array optional timeout')
assertEqual(idle.optionalSecondsFromConfig({ value: 900 }), -1, 'idle rejects an object optional timeout')
assertEqual(idle.optionalSecondsFromConfig('999999999'), idle.MAX_TIMEOUT_SECONDS, 'idle clamps an optional timeout at the safe timer ceiling')
assertEqual(idle.MAX_TIMEOUT_SECONDS, 2147483, 'idle derives the safe timer ceiling in seconds')

assertEqual(idle.shouldSuspend(true, true, true, 900), true, 'idle suspend runs only when its input clock and inhibitor gate are idle')
assertEqual(idle.shouldSuspend(false, true, true, 900), false, 'idle suspend waits for its input clock')
assertEqual(idle.shouldSuspend(true, false, true, 900), false, 'idle suspend waits for its inhibitor gate')
assertEqual(idle.shouldSuspend(true, true, false, 900), false, 'idle suspend follows Stay Awake')
assertEqual(idle.shouldSuspend(true, true, true, -1), false, 'idle suspend remains disabled without a valid timeout')
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

idle_service="$ROOT/shell/plugins/services/idle/Service.qml"
suspend_input_monitor=$(sed -n '/id: suspendInputIdleMonitor/,/^  }$/p' "$idle_service")
suspend_inhibitor_monitor=$(sed -n '/id: suspendInhibitorMonitor/,/^  }$/p' "$idle_service")
grep -F 'enabled: root.idleEnabled && root.suspendTimeoutSeconds > 0 && root.suspendMonitorArmed' <<<"$suspend_input_monitor" >/dev/null ||
  fail "idle suspend follows the Stay Awake state and remains opt-in"
grep -F 'respectInhibitors: false' <<<"$suspend_input_monitor" >/dev/null ||
  fail "idle suspend counts from physical input rather than compositor window events"
grep -F 'timeout: 1' <<<"$suspend_inhibitor_monitor" >/dev/null ||
  fail "idle suspend uses a short inhibitor gate"
grep -F 'respectInhibitors: true' <<<"$suspend_inhibitor_monitor" >/dev/null ||
  fail "idle suspend respects system sleep inhibitors"
maybe_suspend=$(sed -n '/^  function maybeSuspend()/,/^  }$/p' "$idle_service")
grep -F 'IdleModel.shouldSuspend(' <<<"$maybe_suspend" >/dev/null ||
  fail "idle suspend delegates its launch decision to the tested model"
grep -F 'onSuspendTimeoutSecondsChanged: root.rearmSuspendMonitors()' "$idle_service" >/dev/null ||
  fail "idle suspend re-arms monitors after a timeout change"
rearm_suspend_monitors=$(sed -n '/^  function rearmSuspendMonitors()/,/^  }$/p' "$idle_service")
grep -F 'root.suspendMonitorArmed = false' <<<"$rearm_suspend_monitors" >/dev/null &&
  grep -F 'Qt.callLater(function() { root.suspendMonitorArmed = true })' <<<"$rearm_suspend_monitors" >/dev/null ||
  fail "idle suspend disables then enables monitors after a timeout change"
grep -F 'omarchy-toggle-enabled suspend-off || systemctl suspend' "$idle_service" >/dev/null ||
  fail "idle suspend honors suspend-off before using systemctl suspend"
pass "Idle suspend is opt-in, input-timed, inhibitor-aware, and safely re-armed"

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
