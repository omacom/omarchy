#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = name => fs.readFileSync(path.join(root, name), 'utf8')
const indicator = read('shell/plugins/bar/indicators/PasswordlessSudo.qml')
const widget = read('shell/plugins/bar/widgets/Indicators.qml')
const manifest = JSON.parse(read('shell/plugins/bar/widgets/Indicators.manifest.json'))
assert(widget.match(/defaultIndicatorEntries: \[ "PasswordlessSudo", "ScreenRecording"/), 'passwordless sudo is included in the default indicator tray')
assert(manifest.barWidget.schema.find(field => field.key === 'items').options.some(option => option.value === 'PasswordlessSudo'), 'passwordless sudo is configurable alongside Night Light')
assert(indicator.includes('useActiveColor: true') && indicator.includes('activeColor: Commons.Color.urgent'), 'active passwordless sudo uses the theme danger color')
assertEqual(indicator.match(/activeText: "([^"]+)"/)[1], indicator.match(/inactiveText: "([^"]+)"/)[1], 'sudo keeps the same icon in both states')
assert(!widget.includes('sudoHorizontal') && !widget.includes('sudoVertical'), 'sudo participates in the normal indicator blocks')
assert(!indicator.includes('visible:'), 'sudo uses the shared indicator visibility and hover behavior')
assert(indicator.includes('command: ["omarchy-sudo-passwordless", "--active"]'), 'indicator uses the noninteractive grant probe')
assert(indicator.includes('root.granted = exitCode === 0 && exitStatus === 0'), 'failed or interrupted probes do not claim an active grant')
assert(!indicator.includes('Timer'), 'indicator does not poll the sudo probe')
assert(indicator.includes('function onRefreshRequested() { root.refresh() }'), 'indicator probes when the indicator host asks for a refresh')
assert(indicator.includes('command: ["omarchy-sudo-passwordless", "--disable"]'), 'active indicator revokes access through a background process')
assert(indicator.includes('if (root.granted) disableProc.running = true'), 'active click bypasses the terminal launcher')
assert(indicator.includes('root.indicatorHost.refresh()'), 'disabling access refreshes all indicator instances immediately')
const press = new Function('root', 'disableProc', indicator.match(/onPressed: function\(\) \{([\s\S]*?)\n  \}/)[1])
const launched = []
const button = { granted: true, bar: { run: command => launched.push(command) } }
const revoke = { running: false }
press(button, revoke)
assert(revoke.running && launched.length === 0, 'clicking active sudo starts background revocation without a terminal')
button.granted = false
press(button, revoke)
assert(launched.length === 0, 'repeat clicks during revocation cannot open the enable flow')
revoke.running = false
press(button, revoke)
assertDeepEqual(launched, ['omarchy-launch-floating-terminal-with-presentation omarchy-sudo-passwordless'], 'inactive click still opens interactive setup')
JS

# Run the public grant flows against the fixture's stand-ins and check the
# refreshes they push, without touching the host shell or user timers.
source "$SHELL_TEST_DIR/fixtures/passwordless-sudo-test.sh"
refresh="omarchy-shell -q omarchy.indicators refresh"
run_grant_flow() {
  : >"$test_tmp/commands"
  env "$@" /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" "${grant_args[@]}" >"$test_tmp/public.log" 2>&1 || true
}
refresh_follows() {
  grep -A1 -- "$1" "$test_tmp/commands" | grep -qxF -- "$refresh"
}
user_timers() {
  grep -c '^systemd-run --user ' "$test_tmp/commands" || true
}

grant_args=(15)
before=$EPOCHSECONDS
run_grant_flow TEST_STATUS=3 TEST_CONFIRM_STATUS=0
after=$EPOCHSECONDS
refresh_follows ' __enable [0-9]* 15$' || fail "timed enable must refresh the indicator after the grant changes"
timer=$(grep '^systemd-run --user ' "$test_tmp/commands") || fail "timed enable must schedule an expiry refresh"
timer_pattern="^systemd-run --user --quiet --collect --on-calendar=@([0-9]+) --timer-property=AccuracySec=1s -- $test_tmp/bin/omarchy-shell -q omarchy.indicators refresh$"
[[ $timer =~ $timer_pattern ]] || fail "unexpected expiry refresh timer: $timer"
deadline=${BASH_REMATCH[1]}
(( deadline >= before + 15 * 60 + 2 && deadline <= after + 15 * 60 + 2 )) || fail "expiry refresh must fire just after the wall-clock deadline"
pass "timed enable refreshes now and on a wall-clock timer just after expiry"

run_grant_flow TEST_STATUS=0
refresh_follows ' __enable [0-9]* 15$' || fail "renewal must refresh the indicator"
(( $(user_timers) == 1 )) || fail "renewal must schedule an expiry refresh"
pass "renewing a timed grant refreshes and reschedules the expiry refresh"

run_grant_flow TEST_STATUS=0 TEST_ENABLE_FAIL=1
refresh_follows ' __enable [0-9]* 15$' || fail "failed renewal must still refresh the indicator"
(( $(user_timers) == 0 )) || fail "failed renewal must not schedule an expiry refresh"
pass "a failed grant change still refreshes the indicator"

grant_args=(permanent)
run_grant_flow TEST_STATUS=3 TEST_CONFIRM_STATUS=0
refresh_follows ' __enable [0-9]* permanent$' || fail "permanent enable must refresh the indicator"
(( $(user_timers) == 0 )) || fail "permanent enable must not schedule an expiry refresh"
pass "permanent enable refreshes without scheduling an expiry refresh"

assert_disable_refreshes() {
  run_grant_flow TEST_STATUS=0
  refresh_follows ' __disable [0-9]*$' || fail "disable ${grant_args[*]} must refresh the indicator"
  (( $(user_timers) == 0 )) || fail "disable must not schedule an expiry refresh"
}
grant_args=()
assert_disable_refreshes
grant_args=(--disable)
assert_disable_refreshes
pass "disabling access refreshes the indicator"
