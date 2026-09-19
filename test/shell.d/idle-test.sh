#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')
assertEqual(idle.secondsFromConfig('0', 10), 0, 'idle accepts a zero timeout')
assertEqual(idle.keyboardBacklightTimeoutSeconds(undefined), 0, 'keyboard backlight timeout defaults off when idle config is missing')
assertEqual(idle.keyboardBacklightTimeoutSeconds({}), 0, 'keyboard backlight timeout defaults off when the key is omitted')
assertEqual(idle.keyboardBacklightTimeoutSeconds({ keyboardBacklight: 0 }), 0, 'keyboard backlight timeout 0 disables the feature')
assertEqual(idle.keyboardBacklightTimeoutSeconds({ keyboardBacklight: 30 }), 30, 'keyboard backlight timeout uses a positive idle.keyboardBacklight')
assertEqual(idle.keyboardBacklightTimeoutSeconds({ keyboardBacklight: -5 }), 0, 'keyboard backlight timeout rejects a negative value')

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

idle_service="$ROOT/shell/plugins/services/idle/Service.qml"
default_shell_json="$ROOT/config/omarchy/shell.json"
grep -F 'id: keyboardBacklightMonitor' "$idle_service" >/dev/null
grep -F 'respectInhibitors: false' "$idle_service" >/dev/null
grep -F 'omarchy-brightness-keyboard --no-osd off' "$idle_service" >/dev/null
grep -F 'omarchy-brightness-keyboard --no-osd restore' "$idle_service" >/dev/null
grep -F 'enabled: root.keyboardBacklightTimeoutEnabled' "$idle_service" >/dev/null
grep -F 'if (root.idledThisCycle) return' "$idle_service" >/dev/null
grep -F 'onKeyboardBacklightTimeoutEnabledChanged' "$idle_service" >/dev/null
grep -F 'root.keyboardBacklightTimeoutArmed = root.keyboardBacklightTimeoutEnabled' "$idle_service" >/dev/null
grep -F 'function enqueueKeyboardCommand' "$idle_service" >/dev/null
grep -F 'function pumpKeyboardCommand' "$idle_service" >/dev/null
grep -F 'id: keyboardCommandProcess' "$idle_service" >/dev/null
if grep -q 'keyboardBacklight' "$default_shell_json"; then
  fail "default shell.json leaves keyboard backlight timeout omitted (opt-in)"
fi
pass "keyboard backlight timeout is opt-in and independent of stay-awake"
