#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

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
assertEqual(idle.inhibitorCountFromText('{"count":2,"holders":[]}'), 2, 'inhibitor parses a numeric count')
assertEqual(idle.inhibitorCountFromText('{}'), 0, 'inhibitor treats an empty object as zero')
assertEqual(idle.inhibitorCountFromText(''), 0, 'inhibitor treats missing text as zero')
assertEqual(idle.inhibitorCountFromText('not-json'), 0, 'inhibitor treats unparseable text as zero')
assertEqual(idle.inhibitorCountFromText(undefined), 0, 'inhibitor treats undefined as zero')
assertEqual(idle.inhibitorCountFromText('{"count":"2"}'), 0, 'inhibitor ignores a non-numeric count')
assertEqual(idle.inhibitorTransition(0, 1), 'cancel', 'a first inhibitor cancels an idle cycle')
assertEqual(idle.inhibitorTransition(1, 0), 'rearm', 'releasing the last inhibitor re-arms idle')
assertEqual(idle.inhibitorTransition(0, 0), 'noop', 'no inhibitor counts mean no transition')
assertEqual(idle.inhibitorTransition(1, 2), 'noop', 'an added inhibitor while others remain is no-op')
assertEqual(idle.inhibitorTransition(2, 1), 'noop', 'a removed inhibitor while others remain is no-op')
JS

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists enabled state"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists disabled state"

pass "Stay Awake toggle persists state"
