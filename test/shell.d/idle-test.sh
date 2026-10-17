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

assertDeepEqual(
  idle.activitySettings({}),
  { gamepad: true, audio: true, gamepadGrace: 120 },
  'idle watches gamepads and audio by default'
)
assertDeepEqual(
  idle.activitySettings({ inhibitWhenAudioPlaying: false, gamepadGrace: '45.7' }),
  { gamepad: true, audio: false, gamepadGrace: 45 },
  'idle honours configured activity settings'
)

assertEqual(idle.activityWatchWanted({ gamepad: false, audio: true }), true, 'idle watches when audio alone is enabled')
assertEqual(idle.activityWatchWanted({ gamepad: false, audio: false }), false, 'idle skips the probe when both signals are off')

assertDeepEqual(
  idle.activityCommand({ gamepad: true, audio: true, gamepadGrace: 120 }),
  ['omarchy-idle-activity', '--gamepad-grace', '120'],
  'idle probes both signals without extra flags'
)
assertDeepEqual(
  idle.activityCommand({ gamepad: false, audio: true, gamepadGrace: 30 }),
  ['omarchy-idle-activity', '--no-gamepad', '--gamepad-grace', '30'],
  'idle disables the gamepad signal on request'
)

assertEqual(idle.isActivityLine('ACTIVE\n'), true, 'idle reads an ACTIVE probe line')
assertEqual(idle.isActivityLine('IDLE'), false, 'idle reads an IDLE probe line')
JS

# The probe carries the gamepad and audio detection the compositor cannot do.
run_python_test() {
  python3 - "$ROOT/bin/omarchy-idle-activity" <<'PYTEST'
import importlib.machinery
import importlib.util
import os
import struct
import sys

loader = importlib.machinery.SourceFileLoader("idle_activity", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
probe = importlib.util.module_from_spec(spec)
loader.exec_module(probe)

failures = []


def check(description, actual, expected):
    if actual != expected:
        failures.append("%s (got %r, want %r)" % (description, actual, expected))


DEVICES = """I: Bus=0005 Vendor=045e Product=028e
N: Name="Xbox Wireless Controller"
H: Handlers=event25 js0
B: EV=20001b

I: Bus=0005 Vendor=045e Product=028e
N: Name="Xbox Wireless Controller Keyboard"
H: Handlers=sysrq kbd event27
B: EV=100013

I: Bus=0005 Vendor=045e Product=028e
N: Name="Xbox Wireless Controller Mouse"
H: Handlers=event28 mouse3
B: EV=7
"""

check(
    "probe picks the joystick node and ignores the pad's keyboard and mouse nodes",
    probe.parse_gamepad_nodes(DEVICES),
    {"/dev/input/event25"},
)
check("probe finds no joystick without a js handler", probe.parse_gamepad_nodes(""), set())


def feed(batches):
    """Replay batches of input_events through one fake evdev descriptor."""
    read_end, write_end = os.pipe()
    pads = probe.Gamepads()
    pads.descriptors = {"/fake": read_end}
    seen = []
    try:
        for batch in batches:
            os.write(write_end, b"".join(batch))
            seen.append(pads.poll(0.2))
    finally:
        os.close(write_end)
        os.close(read_end)
    return seen


def event(kind, code, value):
    return probe.EVENT.pack(0, 0, kind, code, value)


check("probe counts a button press", feed([[event(probe.EV_KEY, 0x130, 1)]]), [True])
check(
    "probe treats the first axis sample as a resting baseline",
    feed([[event(probe.EV_ABS, 0, 512)]]),
    [False],
)
check(
    "probe ignores analogue stick drift",
    feed([[event(probe.EV_ABS, 0, 0)], [event(probe.EV_ABS, 0, 200)]]),
    [False, False],
)
check(
    "probe counts a deliberate stick push",
    feed([[event(probe.EV_ABS, 0, 0)], [event(probe.EV_ABS, 0, 12000)]]),
    [False, True],
)
check(
    "probe counts a d-pad press despite its tiny range",
    feed([[event(probe.EV_ABS, 0x10, 0)], [event(probe.EV_ABS, 0x10, 1)]]),
    [False, True],
)

if failures:
    for failure in failures:
        print(failure, file=sys.stderr)
    sys.exit(1)
PYTEST
}

if run_python_test; then
  pass "Idle activity probe reads gamepad input the compositor ignores"
else
  fail "Idle activity probe reads gamepad input the compositor ignores"
fi

[[ $("$ROOT/bin/omarchy-idle-activity" --once --no-audio) == "IDLE" ]] ||
  fail "Idle activity probe reports idle when every signal is disabled"
pass "Idle activity probe reports idle when every signal is disabled"

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
