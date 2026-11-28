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

state_file="$test_home/.local/state/omarchy/indicators/stay-awake"
duration_file="$test_home/.local/state/omarchy/stay-awake-last-duration"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" --menu-duration 60
deadline=$(cat "$state_file")
(( deadline > $(date +%s) )) || fail "Timed Stay Awake records a future deadline"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" --expire "$deadline"
[[ -f $state_file ]] || fail "An early expiry leaves Stay Awake active"
expired=$(($(date +%s) - 1))
printf '%s\n' "$expired" > "$state_file"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" --expire "$deadline"
[[ -f $state_file ]] || fail "A stale expiry leaves Stay Awake active"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" --expire "$expired"
[[ ! -f $state_file ]] || fail "A matching expiry restores idle behavior"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ $(cat "$duration_file") == 60 ]] || fail "Allow Sleep preserves the last duration"
pass "Timed Stay Awake expires and remembers its duration"
