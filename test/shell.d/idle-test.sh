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

service_qml="$ROOT/shell/plugins/services/idle/Service.qml"

rg -q 'IdleInhibitor' "$service_qml" || fail "Stay Awake registers a Wayland idle inhibitor"
rg -q 'enabled: *root\.stayAwake' "$service_qml" || fail "the Wayland idle inhibitor follows Stay Awake"
rg -q '"--what=idle"' "$service_qml" || fail "Stay Awake holds a logind idle inhibitor"
if rg -q -- '--what=[^"]*sleep' "$service_qml"; then
  fail "Stay Awake does not block suspend"
fi

# The inhibitor is held through a pipe whose other end this shell owns: a
# SIGKILLed shell closes the pipe, the reader hits EOF, and systemd-inhibit
# releases. A detached `sleep infinity` would outlive the shell and stack up
# an orphan on every restart.
rg -q 'stdinEnabled: true' "$service_qml" || fail "the inhibitor process holds this shell's end of a pipe"
rg -q '^[[:space:]]+"cat"$' "$service_qml" || fail "the inhibitor is held by a pipe reader, not a long-lived sleep"
if rg -q '"infinity"' "$service_qml"; then
  fail "the inhibitor does not depend on a long-lived sleep"
fi

# A command that never execs (a missing systemd-inhibit) reports runningChanged
# but never exited, so recovery must run inside onRunningChanged, and only
# there: an onExited-keyed retry strands Stay Awake uninhibited.
inhibitor_block=$(awk '/id: sleepInhibitorProcess/,/^  }/' "$service_qml")
[[ -n $inhibitor_block ]] || fail "the idle inhibitor process is present"
reconcile_calls=$(printf '%s\n' "$inhibitor_block" | grep -c 'reconcileIdleInhibitor' || true)
reconcile_in_running=$(printf '%s\n' "$inhibitor_block" | awk '/onRunningChanged:/,/^    }/' | grep -c 'reconcileIdleInhibitor' || true)
(( reconcile_calls >= 1 )) || fail "the inhibitor process recovers from unexpected exits"
if (( reconcile_calls != reconcile_in_running )); then
  fail "inhibitor recovery runs only from onRunningChanged, where clean exits and failed starts both land"
fi

# One surface per connected output: a single window with no explicit screen
# binds the primary output and leaves secondary monitors uninhibited.
rg -q 'model: Quickshell\.screens' "$service_qml" || fail "the inhibitor surface is created per connected screen"
rg -q 'screen: modelData' "$service_qml" || fail "each inhibitor surface targets its own output"

# A state-file write landing while a probe is in flight has already been
# consumed by the watcher without being read; the probe exit must re-run it.
rg -q 'hasPendingStayAwakeProbe' "$service_qml" || fail "state writes during an in-flight probe are not dropped"

pass "Stay Awake persists state, keeps the toggle shell-IPC-free, and publishes Wayland and logind idle inhibitors"

# Runtime coverage: with a compositor, start a real shell from this tree and
# drive the actual omarchy-toggle-idle path, then assert the systemd inhibitor
# is acquired, released, never orphaned, and converges. Everything is polled:
# the state-file watcher, the QML reconcile, and the systemd-inhibit process
# are all asynchronous.
require_compositor "idle inhibitor runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping idle inhibitor runtime test"
  exit 0
fi

require_command systemd-inhibit
require_command jq

runtime_tmp=$(mktemp -d)
test_root="$runtime_tmp/omarchy"
runtime_home="$runtime_tmp/home"
stub_bin="$runtime_tmp/bin"
qs_log="$runtime_tmp/quickshell.log"
mkdir -p "$test_root" "$runtime_home" "$stub_bin"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"

QS_PID=""

cleanup_runtime() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  rm -f "$(shell_ipc_socket "$test_root")"
  rm -rf "$runtime_tmp" "$test_tmp"
  return 0
}
trap cleanup_runtime EXIT

shell_ipc() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" "$@"
}

fail_with_shell_log() {
  sed -n '1,240p' "$qs_log" >&2
  fail "$1"
}

poll_until() {
  local description="$1" attempts=0

  shift
  until "$@"; do
    if (( ++attempts >= 100 )); then
      fail_with_shell_log "$description"
    fi
    sleep 0.1
  done
}

start_test_shell() {
  # Appended, not truncated: the SIGKILL/restart coverage relaunches the
  # shell and later phases still need the earlier log.
  OMARCHY_PATH="$test_root" \
  HOME="$runtime_home" \
  XDG_CONFIG_HOME="$runtime_home/.config" \
  XDG_CACHE_HOME="$runtime_home/.cache" \
  XDG_STATE_HOME="$runtime_home/.local/state" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    quickshell -p "$test_root/shell" --no-color >>"$qs_log" 2>&1 &
  QS_PID=$!
}

shell_ready() {
  kill -0 "$QS_PID" 2>/dev/null && shell_ipc -q idle status >/dev/null 2>&1
}

wait_for_shell_ready() {
  for _ in {1..80}; do
    shell_ready && return 0
    kill -0 "$QS_PID" 2>/dev/null || fail_with_shell_log "test shell exited before idle IPC was available"
    sleep 0.1
  done
  shell_ready || fail_with_shell_log "test shell did not expose idle IPC"
}

# Layer-shell coverage: the inhibitor surface is per output, and it dies with
# the shell. The baseline is taken before the test shell starts: a session
# shell may hold its own surfaces, and they must count as a constant, not as
# part of this test's deltas.
layer_checks=0
expected_layers=0
layer_baseline=0
if command -v hyprctl >/dev/null 2>&1 && hyprctl layers -j >/dev/null 2>&1; then
  layer_count() {
    local count
    count=$(hyprctl layers -j 2>/dev/null |
      jq -r '[.. | objects | select(.namespace? == "omarchy-stay-awake")] | length' 2>/dev/null) || count=""
    [[ $count =~ ^[0-9]+$ ]] || count=-1
    printf '%s' "$count"
  }

  monitors=$(hyprctl monitors -j 2>/dev/null | jq -r 'length' 2>/dev/null) || monitors=""
  layer_baseline=$(layer_count)
  if [[ $monitors =~ ^[0-9]+$ ]] && (( monitors >= 1 )) && (( layer_baseline >= 0 )); then
    layer_checks=1
    expected_layers=$((layer_baseline + monitors))
  fi
fi

if (( layer_checks == 0 )); then
  skip "hyprctl layers unavailable; skipping inhibitor surface assertions"
fi

layers_at_shell_count() {
  (( layer_checks == 1 )) && [[ $(layer_count) -eq $expected_layers ]]
}

layers_at_baseline() {
  (( layer_checks == 1 )) && [[ $(layer_count) -eq $layer_baseline ]]
}

start_test_shell
wait_for_shell_ready

if (( layer_checks == 1 )); then
  poll_until "the idle inhibitor surface is mapped once per connected output" layers_at_shell_count
  pass "the idle inhibitor surface is mapped once per connected output"
fi

# Count only this feature's inhibitor. A shell already running in the session
# can hold one too, so assert against a baseline instead of an absolute.
inhibitor_count() {
  local count

  count=$(systemd-inhibit --list 2>/dev/null | grep -c 'omarchy-shell.*idle.*Stay awake is enabled' || true)
  printf '%s' "${count:-0}"
}

baseline=$(inhibitor_count)

inhibitor_acquired() { (( $(inhibitor_count) > baseline )); }
inhibitor_released() { (( $(inhibitor_count) <= baseline )); }

assert_inhibitor_count() {
  local expected=$1 description=$2
  local count
  count=$(inhibitor_count)
  (( count == expected )) || fail "$description" "expected $expected inhibitor(s), found $count"
}

HOME="$runtime_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
poll_until "enabling Stay Awake acquires a systemd idle inhibitor" inhibitor_acquired
assert_inhibitor_count "$((baseline + 1))" "enabling Stay Awake acquires a systemd idle inhibitor"
pass "enabling Stay Awake acquires a systemd idle inhibitor"

HOME="$runtime_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
poll_until "disabling Stay Awake releases the systemd idle inhibitor" inhibitor_released
assert_inhibitor_count "$baseline" "disabling Stay Awake releases the systemd idle inhibitor"
pass "disabling Stay Awake releases the systemd idle inhibitor"

# Rapid off/on without waiting for each transition: the probe, the watcher,
# and a still-dying process can all be in flight, and the result must still
# converge on exactly one inhibitor — not zero, not two.
HOME="$runtime_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
HOME="$runtime_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
HOME="$runtime_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
poll_until "a rapid off/on converges back onto an inhibitor" inhibitor_acquired
assert_inhibitor_count "$((baseline + 1))" "a rapid off/on converges on exactly one inhibitor"
pass "a rapid off/on converges on exactly one inhibitor"

# SIGKILL the shell: without a pipe to EOF on, its systemd-inhibit child would
# outlive the shell and keep holding the inhibitor after every restart. The
# restart below must then reacquire exactly one from the persisted state file.
kill -9 "$QS_PID" 2>/dev/null || true
wait "$QS_PID" 2>/dev/null || true
poll_until "a SIGKILLed shell releases its inhibitor instead of orphaning it" inhibitor_released
assert_inhibitor_count "$baseline" "a SIGKILLed shell releases its inhibitor instead of orphaning it"
pass "a SIGKILLed shell releases its inhibitor instead of orphaning it"

if (( layer_checks == 1 )); then
  poll_until "a SIGKILLed shell unmaps its inhibitor surfaces" layers_at_baseline
  pass "a SIGKILLed shell unmaps its inhibitor surfaces"
fi

start_test_shell
wait_for_shell_ready

stay_awake_reported() {
  shell_ipc idle status 2>/dev/null | jq -e '.stayAwake == true' >/dev/null 2>&1
}
poll_until "the restarted shell reads the persisted Stay Awake state" stay_awake_reported
pass "the restarted shell reads the persisted Stay Awake state"

poll_until "the restarted shell reacquires its systemd idle inhibitor" inhibitor_acquired
assert_inhibitor_count "$((baseline + 1))" "the restarted shell holds exactly one inhibitor"
pass "the restarted shell reacquires its systemd idle inhibitor"

if (( layer_checks == 1 )); then
  poll_until "the restarted shell remaps its inhibitor surfaces" layers_at_shell_count
  pass "the restarted shell remaps its inhibitor surfaces"
fi

# A systemd-inhibit that fails on every attempt must back off instead of
# spinning: attempts stay bounded, the shell stays healthy, and a fixed
# dependency is picked up by the next retry without restarting the shell.
cat >"$stub_bin/systemd-inhibit" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$stub_bin/systemd-inhibit"

HOME="$runtime_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
poll_until "disabling Stay Awake releases the inhibitor before the failure test" inhibitor_released
pass "disabling Stay Awake releases the inhibitor before the failure test"

HOME="$runtime_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
sleep 2
assert_inhibitor_count "$baseline" "a failing inhibitor dependency holds no inhibitor"

exit_log_count() {
  local count
  count=$(grep -c 'idle-inhibitor exitCode' "$qs_log" || true)
  printf '%s' "${count:-0}"
}

exits_before=$(exit_log_count)
sleep 5
exits_after=$(exit_log_count)
retry_window=$((exits_after - exits_before))

kill -0 "$QS_PID" 2>/dev/null || fail_with_shell_log "test shell died while retrying a failing inhibitor dependency"
shell_ready || fail_with_shell_log "test shell lost idle IPC while retrying a failing inhibitor dependency"
if (( retry_window < 1 || retry_window > 10 )); then
  fail "failing inhibitor attempts are backed off, not spun" "expected 1-10 attempts in 5s, saw $retry_window"
fi
pass "failing inhibitor attempts are backed off, not spun"

rm -f "$stub_bin/systemd-inhibit"
poll_until "a fixed inhibitor dependency is picked up by the retry loop" inhibitor_acquired
assert_inhibitor_count "$((baseline + 1))" "a fixed inhibitor dependency recovers without a shell restart"
pass "a fixed inhibitor dependency recovers without a shell restart"

HOME="$runtime_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
poll_until "disabling Stay Awake after recovery releases the inhibitor" inhibitor_released
pass "disabling Stay Awake after recovery releases the inhibitor"
