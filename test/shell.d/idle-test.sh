#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

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
suspend_monitor=$(sed -n '/^  IdleMonitor {$/,/^  }$/p' "$idle_service" | sed -n '/id: suspendIdleMonitor/,/^  }$/p')
grep -F 'enabled: root.idleEnabled && root.suspendTimeoutSeconds > 0' <<<"$suspend_monitor" >/dev/null ||
  fail "idle suspend follows the Stay Awake state and remains opt-in"
grep -F 'respectInhibitors: true' <<<"$suspend_monitor" >/dev/null ||
  fail "idle suspend respects system sleep inhibitors"
grep -F 'omarchy-toggle-enabled suspend-off || systemctl suspend' "$idle_service" >/dev/null ||
  fail "idle suspend honors suspend-off before using systemctl suspend"
pass "Idle suspend is opt-in and follows idle and suspend inhibition"

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
