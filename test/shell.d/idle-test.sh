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

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.normalizeWindowAddress('59dac128e760'), '0x59dac128e760', 'idle adds the hyprctl prefix to socket addresses')
assertEqual(idle.normalizeWindowAddress('0xABC'), '0xabc', 'idle normalizes window address case')
assertEqual(idle.normalizeWindowAddress('bad;rm -rf'), '', 'idle rejects addresses that are not hex')

// A window opened by this cycle's launch is owned; one opened outside it is not.
let owned = idle.ownedWindowsAfterOpen({}, '59dac1', true)
assertDeepEqual(idle.addressesToClose(owned), ['0x59dac1'], 'idle owns windows opened by the cycle launch')
owned = idle.ownedWindowsAfterOpen({}, '0xbeef', false)
assertDeepEqual(idle.addressesToClose(owned), [], 'idle does not own a screensaver the user started')

// Closing a window that already went away removes it from ownership.
owned = idle.ownedWindowsAfterClose({ '0x59dac1': true, '0xbeef': true }, '59dac1')
assertDeepEqual(idle.addressesToClose(owned), ['0xbeef'], 'idle forgets windows that closed')

assertEqual(
  idle.closeWindowsCommand(['0x59dac1']),
  'hyprctl dispatch "hl.dsp.window.close({ window = \\"address:0x59dac1\\" })" >/dev/null 2>&1',
  'idle closes owned windows by address'
)
assertEqual(idle.closeWindowsCommand([]), 'true', 'idle close command is a no-op with no windows')
assertEqual(idle.closeWindowsCommand(['nope;x']), 'true', 'idle never builds a close command from a non-hex address')

// A cancel during launch can only claim windows the launch has yet to open.
assertEqual(idle.lateWindowBudget(2, 0), 2, 'idle allows one late window per screen when none opened')
assertEqual(idle.lateWindowBudget(2, 1), 1, 'idle allows only the remaining late windows')
assertEqual(idle.lateWindowBudget(1, 1), 0, 'idle allows no late window once every screen has one')
assertEqual(idle.lateWindowBudget(1, 3), 0, 'idle never allows a negative budget')
JS

pass "idle screensaver ownership and close-by-address"
