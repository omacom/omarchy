#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')

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

assertDeepEqual(
  idle.dismissStateAfter(false, true, true),
  { settled: true, dismiss: false },
  'idle settles the dismiss monitor once the screensaver goes quiet'
)
assertDeepEqual(
  idle.dismissStateAfter(true, false, true),
  { settled: false, dismiss: true },
  'idle dismisses the screensaver on input after it has settled'
)
assertDeepEqual(
  idle.dismissStateAfter(false, false, true),
  { settled: false, dismiss: false },
  'idle ignores the activity caused by launching the screensaver'
)
assertDeepEqual(
  idle.dismissStateAfter(true, false, false),
  { settled: false, dismiss: false },
  'idle never dismisses without a screensaver on screen'
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

service_qml="$ROOT/shell/plugins/services/idle/Service.qml"
[[ -f $service_qml ]] || fail "idle Service.qml is present"

rg -q 'id: dismissMonitor' "$service_qml" ||
  fail "idle arms a dismiss IdleMonitor while the screensaver is visible"

rg -q 'enabled: root.screensaverVisible' "$service_qml" ||
  fail "dismiss IdleMonitor is enabled only while a screensaver window is present"

rg -Fq "pkill -f 'bash .*bin/omarchy-screensaver\$'" "$service_qml" ||
  fail "dismiss signals the screensaver script rather than its terminal"

# Launch blip must still be ignored on the main monitor once a window exists;
# real pointer/touch wake is the dismiss monitor's job (#12650).
rg -q 'screensaverWindowCount > 0 || screensaverLaunchGraceTimer.running' "$service_qml" ||
  fail "main idle monitor still ignores launch activity while a screensaver window exists"

# Menu-launched screensavers must keep their tracked windows across idle-cycle start.
if rg -n 'function startIdleCycle' -A20 "$service_qml" | rg -q 'resetScreensaverWindows'; then
  fail "startIdleCycle must not clear tracked screensaver windows"
fi

pass "idle dismisses the screensaver on pointer activity after launch grace"
