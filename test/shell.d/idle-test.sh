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
  idle.lidProbeUpdate({ lidPresent: false, lidStayAwake: true }, 'lid'),
  { lidPresent: true, lidStayAwake: true },
  'lid probe records a lid switch without touching the flag'
)
assertDeepEqual(
  idle.lidProbeUpdate({ lidPresent: true, lidStayAwake: false }, 'yes'),
  { lidPresent: true, lidStayAwake: true },
  'lid probe records the stay-awake flag without touching lid presence'
)
assertDeepEqual(
  idle.lidProbeUpdate({ lidPresent: true, lidStayAwake: true }, 'garbage'),
  { lidPresent: true, lidStayAwake: true },
  'lid probe ignores lines it does not understand'
)
assert(idle.lidInhibitorWanted(true, true), 'lid inhibitor is held while the flag is set on a laptop')
assert(!idle.lidInhibitorWanted(false, true), 'lid inhibitor is never held without a lid switch')
assert(!idle.lidInhibitorWanted(true, false), 'lid inhibitor is released when the flag is cleared')

const fs = require('fs')
const serviceSource = fs.readFileSync(root + '/shell/plugins/services/idle/Service.qml', 'utf8')
assert(
  /systemd-inhibit[\s\S]*?--what=handle-lid-switch/.test(serviceSource),
  'idle service keeps a closed lid awake with a logind handle-lid-switch inhibitor'
)
assert(
  /id: lidInhibitor[\s\S]*?stdinEnabled: true[\s\S]*?"cat"\]/.test(serviceSource),
  'lid inhibitor ends with the shell\'s stdin pipe so nothing lingers'
)
assert(
  !/HandleLidSwitch|logind\.conf|sudo|pkexec/.test(serviceSource),
  'lid stay awake never edits logind configuration or escalates privileges'
)
assert(/function setLidStayAwake\(value\)/.test(serviceSource), 'idle service exposes setLidStayAwake to the power panel')
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

# omarchy-toggle-lid mirrors omarchy-toggle-idle: the flag file is the whole
# interface, and the idle service picks it up through its directory watcher.
lid_path="$test_tmp/lid"
mkdir -p "$lid_path/LID0"
printf 'state:      open\n' >"$lid_path/LID0/state"

lid_toggle() {
  HOME="$test_home" OMARCHY_ACPI_LID_PATH="$lid_path" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-toggle-lid" "$@"
}

[[ $(lid_toggle stay-awake) == "stay-awake" ]] || fail "lid toggle reports the stay-awake state"
[[ -f $test_home/.local/state/omarchy/indicators/lid-stay-awake ]] || fail "lid toggle persists the stay-awake state"
pass "lid toggle persists the stay-awake state"

[[ $(lid_toggle suspend) == "suspend" ]] || fail "lid toggle reports the suspend state"
[[ ! -f $test_home/.local/state/omarchy/indicators/lid-stay-awake ]] || fail "lid toggle persists the suspend state"
pass "lid toggle persists the suspend state"

lid_toggle >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/lid-stay-awake ]] || fail "lid toggle flips suspend to stay-awake"
lid_toggle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/lid-stay-awake ]] || fail "lid toggle flips stay-awake back to suspend"
pass "lid toggle flips between the two states"

lid_toggle status | grep -q '"enabled":false' || fail "lid toggle status reports the current state"
pass "lid toggle status reports the current state"

if HOME="$test_home" OMARCHY_ACPI_LID_PATH="$test_tmp/no-lid" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-toggle-lid" stay-awake 2>/dev/null; then
  fail "lid toggle refuses on hardware without a lid switch"
fi
[[ ! -f $test_home/.local/state/omarchy/indicators/lid-stay-awake ]] || fail "lid toggle leaves no flag behind without a lid switch"
pass "lid toggle refuses on hardware without a lid switch"

if rg -q 'omarchy-shell' "$ROOT/bin/omarchy-toggle-lid"; then
  fail "lid toggle avoids reentrant shell IPC"
fi
pass "lid toggle avoids reentrant shell IPC"
