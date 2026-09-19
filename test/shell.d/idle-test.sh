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

assertEqual(idle.screensaverLaunchCompleteAfter(0, 2, false), false, 'idle launch incomplete with no windows')
assertEqual(idle.screensaverLaunchCompleteAfter(1, 2, false), false, 'idle launch incomplete until all monitors map')
assertEqual(idle.screensaverLaunchCompleteAfter(2, 2, false), true, 'idle launch complete when expected windows map')
assertEqual(idle.screensaverLaunchCompleteAfter(1, 2, true), true, 'idle launch complete via grace with partial windows')
assertEqual(idle.screensaverLaunchCompleteAfter(0, 2, true), false, 'idle grace without windows stays incomplete')

assertDeepEqual(
  idle.dismissStateAfter({ visible: true, launchComplete: true, locking: false, settled: false, isIdle: true }),
  { settled: true, dismiss: false },
  'idle settles the dismiss monitor once the screensaver goes quiet'
)
assertDeepEqual(
  idle.dismissStateAfter({ visible: true, launchComplete: true, locking: false, settled: true, isIdle: false }),
  { settled: false, dismiss: true },
  'idle dismisses the screensaver on input after it has settled'
)
assertDeepEqual(
  idle.dismissStateAfter({ visible: true, launchComplete: true, locking: false, settled: false, isIdle: false }),
  { settled: false, dismiss: false },
  'idle ignores the activity caused by launching the screensaver'
)
assertDeepEqual(
  idle.dismissStateAfter({ visible: false, launchComplete: true, locking: false, settled: true, isIdle: false }),
  { settled: false, dismiss: false },
  'idle never dismisses without a screensaver on screen'
)
assertDeepEqual(
  idle.dismissStateAfter({ visible: true, launchComplete: false, locking: false, settled: true, isIdle: false }),
  { settled: false, dismiss: false },
  'idle never dismisses before launch completes'
)
assertDeepEqual(
  idle.dismissStateAfter({ visible: true, launchComplete: true, locking: true, settled: true, isIdle: false }),
  { settled: false, dismiss: false },
  'idle never dismisses during lock handoff'
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
