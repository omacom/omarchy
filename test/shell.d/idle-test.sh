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
assert(
  /Hyprland\.toplevels\.values/.test(serviceSource),
  'idle reads the live toplevels when it asks which screensaver windows exist'
)
assert(
  /id: screensaverLaunchGraceTimer[\s\S]*?onTriggered: \{\s*\n\s*root\.syncScreensaverWindows\(\)/.test(serviceSource),
  'idle re-checks the live screensaver windows when the launch grace ends'
)
assert(
  /function handleActiveSignal\(\) \{[\s\S]*?syncScreensaverWindows\(\)[\s\S]*?if \(root\.screensaverStartedThisCycle/.test(serviceSource),
  'idle re-checks the live screensaver windows before holding a cycle open for activity'
)
assert(
  /if \(root\.screensaverWindowCount > 0\) screensaverLaunchGraceTimer\.restart\(\)/.test(serviceSource),
  'idle re-checks shortly after it holds a cycle open for activity'
)
assert(
  /function handleScreensaverWindowOpened\(address\) \{\s*\n\s*setScreensaverWindow\(address, true\)\s*\n\s*\}/.test(serviceSource),
  'idle keeps the launch grace re-check when a screensaver window opens'
)
assert(
  /target: Hyprland\.toplevels\s*\n\s*function onValuesChanged\(\) \{ root\.handleToplevelsChanged\(\) \}/.test(serviceSource),
  'idle watches the live toplevel list for a screensaver window that goes away'
)
assert(
  /function handleToplevelsChanged\(\) \{[\s\S]*?if \(screensaverLaunchGraceTimer\.running\) return\s*\n\s*\n\s*var tracked = root\.screensaverWindows\s*\n\s*syncScreensaverWindows\(\)/.test(serviceSource),
  'idle compares the live list against the tracked windows without cancelling on its own'
)
assert(
  /function handleToplevelsChanged\(\) \{[\s\S]*?root\.handleScreensaverWindowClosed\(gone\[i\]\)/.test(serviceSource),
  'idle hands a screensaver window that vanished without a closewindow to the close handler'
)
assert(
  /root\.cancelIdleCycle\("screensaver-dismissed"\)/.test(serviceSource),
  'idle keeps one dismissal decision for the closeevent and toplevels paths'
)
assert(
  /if \(screensaverLaunchGraceTimer\.running\) return/.test(serviceSource),
  'idle leaves the launch window to the grace timer'
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

assertDeepEqual(
  idle.screensaverWindowsFrom(
    [{ address: 'a', appId: 'org.omarchy.screensaver' }, { address: 'b', appId: 'org.omarchy.screensaver' }],
    'org.omarchy.screensaver'
  ),
  { windows: { a: true, b: true }, count: 2 },
  'idle counts the live screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsFrom(undefined, 'org.omarchy.screensaver'),
  { windows: {}, count: 0 },
  'idle has no screensaver windows without a toplevel list'
)
assertDeepEqual(
  idle.screensaverWindowsFrom(
    [{ address: 'a', appId: 'foot' }, { address: 'b', appId: 'org.omarchy.screensaver' }],
    'org.omarchy.screensaver'
  ),
  { windows: { b: true }, count: 1 },
  'idle ignores live windows that are not the screensaver'
)
assertDeepEqual(
  idle.screensaverWindowsFrom([{ appId: 'org.omarchy.screensaver' }, { address: 'a' }], 'org.omarchy.screensaver'),
  { windows: {}, count: 0 },
  'idle ignores a live window with no address or screensaver app id'
)
assertDeepEqual(
  idle.screensaverWindowsFrom(
    [{ address: 'a', appId: 'org.omarchy.screensaver' }, { address: 'a', appId: 'org.omarchy.screensaver' }],
    'org.omarchy.screensaver'
  ),
  { windows: { a: true }, count: 1 },
  'idle counts a live screensaver address once'
)
assertDeepEqual(
  idle.screensaverWindowsFrom([{ address: 'a', appId: 'org.omarchy.screensaver' }], ''),
  { windows: {}, count: 0 },
  'idle matches no window when the screensaver app id is empty'
)
assertDeepEqual(
  idle.screensaverWindowsFrom([{ address: 'a', appId: null }], 'org.omarchy.screensaver', { a: true }),
  { windows: { a: true }, count: 1 },
  'idle keeps a live window with no app id yet that the events already tracked'
)
assertDeepEqual(
  idle.screensaverWindowsFrom([{ address: 'a', appId: null }], 'org.omarchy.screensaver', {}),
  { windows: {}, count: 0 },
  'idle does not turn a live window with no app id yet into a screensaver window'
)
assertDeepEqual(
  idle.screensaverWindowsFrom([{ address: 'a', appId: null }], 'org.omarchy.screensaver'),
  { windows: {}, count: 0 },
  'idle keeps no unassociated window without a tracked set'
)
assertDeepEqual(
  idle.screensaverWindowsFrom(
    [{ address: 'a', appId: null }, { address: 'b', appId: 'foot' }],
    'org.omarchy.screensaver',
    { a: true, b: true }
  ),
  { windows: { a: true }, count: 1 },
  'idle still drops an unassociated window that is not the screensaver'
)
assert(
  /appId: toplevel && toplevel\.wayland \? String\(toplevel\.wayland\.appId \|\| ""\) : null/.test(serviceSource),
  'idle reports an unattached wayland handle as an unknown app id rather than an absent one'
)
assert(
  /screensaverWindowsFrom\(entries, root\.screensaverClass, root\.screensaverWindows\)/.test(serviceSource),
  'idle gives the live read the tracked windows so it keeps ones it cannot identify yet'
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
