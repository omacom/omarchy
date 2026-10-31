#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertDeepEqual(idle.stayAwakeState('no', 1000), { enabled: false, until: 0 }, 'missing state allows idle')
assertDeepEqual(idle.stayAwakeState('yes:', 1000), { enabled: true, until: 0 }, 'legacy empty state stays awake indefinitely')
assertDeepEqual(idle.stayAwakeState('yes:2000', 1000), { enabled: true, until: 2000 }, 'future deadline survives reload')
assertDeepEqual(idle.stayAwakeState('yes:1000', 1000), { enabled: false, until: 0 }, 'deadline expires at boundary')
assertDeepEqual(idle.stayAwakeState('yes:999', 1000), { enabled: false, until: 0 }, 'past deadline allows idle')
assertDeepEqual(idle.stayAwakeState('yes:invalid', 1000), { enabled: false, until: 0 }, 'invalid deadline allows idle')

for (const raw of ['yes:1e300', 'yes:Infinity', 'yes:0x1000', 'yes:2000.5', 'yes: 2000 ', 'yes:\n', 'yes:2000\nno', 'yes:2000' + '\n'.repeat(70), 'yes:86401001']) {
  assertDeepEqual(idle.stayAwakeState(raw, 1000), { enabled: false, until: 0 }, 'malformed or excessive deadline allows idle: ' + JSON.stringify(raw))
}
assertDeepEqual(idle.stayAwakeState('yes:2000\n', 1000), { enabled: true, until: 2000 }, 'a trailing newline is allowed')
assertDeepEqual(idle.stayAwakeState('yes:12345:6789:1234\n', 1000), { enabled: true, until: 0 }, 'update ownership tokens still inhibit idle')
assertEqual(idle.stayAwakeDeadline(3600, 1000), 3601000, 'one hour produces an absolute deadline')
assertEqual(idle.stayAwakeDeadline(86400, 1000), 86401000, 'one day is the maximum duration')
for (const seconds of [0, -1, 1.5, 86401, Infinity, NaN, 1e300, '$(touch /tmp/should-not-exist)']) {
  assertEqual(idle.stayAwakeDeadline(seconds, 1000), 0, 'invalid duration is rejected: ' + String(seconds))
}

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
mkdir -p "$test_home" "$test_tmp/bin"
cat > "$test_tmp/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$HOME/unexpected-shell-calls"
exit 1
SH
chmod +x "$test_tmp/bin/omarchy-shell"
export PATH="$test_tmp/bin:$PATH"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists enabled state"

printf '9999999999999' > "$test_home/.local/state/omarchy/indicators/stay-awake"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ ! -s $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Indefinite Stay Awake clears deadline"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists disabled state"

# Expired deadlines need no cleanup process: both the CLI and the shell ignore them.
printf '1' > "$test_home/.local/state/omarchy/indicators/stay-awake"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" status | jq -e '.enabled == false' >/dev/null || fail "Expired state allows idle in the CLI"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" >/dev/null
[[ ! -s $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Toggle from expired state enables indefinitely"

state_file="$test_home/.local/state/omarchy/indicators/stay-awake"
victim="$test_tmp/preserve-me"
printf 'unchanged' > "$victim"
rm "$state_file"
ln -s "$victim" "$state_file"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ $(cat "$victim") == "unchanged" && ! -L $state_file ]] || fail "State writes replace symlinks without truncating targets"

rm "$state_file"
mkdir "$state_file"
if HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null 2>&1; then
  fail "A failed state write must return failure"
fi
[[ -z $(find "${state_file%/*}" -name '.stay-awake.*' -print) ]] || fail "Failed writes clean up temporary files"

[[ ! -e $test_home/unexpected-shell-calls ]] || fail "Stay Awake toggle avoids reentrant shell IPC"
pass "Stay Awake toggle persists state atomically without reentrant shell IPC"

# All checks above run without a compositor; the persistence fixture below needs one.
rm -rf "$test_tmp"

require_compositor "idle state persistence test"
require_command quickshell
require_command jq

test_tmp=$(mktemp -d)
test_home="$test_tmp/home with spaces"
fixture="$test_tmp/idle"
qs_pid=""
cleanup() {
  if [[ -n $qs_pid ]]; then
    kill "$qs_pid" 2>/dev/null || true
    wait "$qs_pid" 2>/dev/null || true
  fi
  if [[ -n ${boundary_tmp:-} ]]; then rm -rf -- "$boundary_tmp"; fi
  if [[ -n ${update_state_dir:-} ]]; then rm -rf -- "$update_state_dir"; fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT
mkdir -p "$test_home" "$fixture" "$test_tmp/bin"
ln -s "$ROOT/shell/Commons" "$fixture/Commons"
cat > "$fixture/shell.qml" <<'QML'
import QtQuick
import Quickshell
ShellRoot {
  Loader {
    source: "file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/services/idle/Service.qml"
    onLoaded: item.shell = { shellConfig: { idle: { screensaver: 86400, lock: 86400 } } }
  }
}
QML
cat > "$test_tmp/bin/bash" <<'BASH'
#!/bin/bash
if [[ ${1:-} == "-c" && ${2:-} == *'head -c'* ]]; then
  if [[ -e $HOME/fail-read ]]; then printf 'yes:'; exit 1; fi
  if [[ -e $HOME/delay-read ]]; then
    /bin/bash "$@"
    touch "$HOME/read-finished"
    sleep 0.4
    exit 0
  fi
fi
if [[ ${1:-} == "-c" && ${2:-} == *mktemp* ]]; then
  [[ ! -e $HOME/fail-write ]] || exit 1
  [[ ! -e $HOME/delay-write ]] || sleep 0.3
fi
exec /bin/bash "$@"
BASH
cat > "$test_tmp/bin/omarchy-notification-send" <<'BASH'
#!/bin/bash
printf '%s\n' "$*" >> "$HOME/notifications"
BASH
cat > "$test_tmp/bin/systemd-run" <<'SH'
#!/bin/bash
[[ ! -e $HOME/fail-schedule ]] || exit 1
for arg in "$@"; do
  if [[ $arg == --on-calendar=* ]]; then
    systemd-analyze calendar "${arg#--on-calendar=}" >/dev/null || exit 1
  fi
done
python3 - "$HOME/expiry-schedules" "$@" <<'PYTHON'
import json, sys
with open(sys.argv[1], 'a') as out:
    out.write(json.dumps(sys.argv[2:]) + '\n')
PYTHON
SH
chmod +x "$test_tmp/bin/"*
call() { quickshell ipc -p "$fixture" call idle "$@"; }
await_state() {
  local predicate="$1"
  for _ in {1..60}; do
    if call status 2>/dev/null | jq -e "$predicate" >/dev/null 2>&1; then return 0; fi
    sleep 0.05
  done
  cat "$test_tmp/shell.log" >&2
  fail "idle state reaches $predicate"
}
start_shell() {
  HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" XDG_STATE_HOME="$test_home/.local/state" \
    OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$PATH" \
    quickshell -p "$fixture" --no-color > "$test_tmp/shell.log" 2>&1 &
  qs_pid=$!
  await_state '.stayAwakeStateLoaded == true'
}
stop_shell() {
  quickshell kill -p "$fixture" >/dev/null
  wait "$qs_pid" || true
  qs_pid=""
}
state_file="$test_home/.local/state/omarchy/indicators/stay-awake"
start_shell
await_state '.enabled == true'
call stayAwakeFor 60 >/dev/null
await_state '.stayAwakeUntil > 0'
for _ in {1..50}; do [[ -s $state_file ]] && break; sleep 0.05; done
deadline=$(cat "$state_file")
stop_shell
start_shell
await_state ".stayAwakeUntil == $deadline"
pass "timed state survives a shell restart without extending its deadline"

for invalid in 0 -1 86401; do
  [[ $(call stayAwakeFor "$invalid") == "invalid duration" ]] || fail "Invalid duration is refused"
  await_state ".stayAwakeUntil == $deadline"
done
pass "invalid requests do not change the running timer"

call stayAwakeFor 1 >/dev/null
await_state '.stayAwakeUntil > 0'
expiry=$(call status | jq -r .stayAwakeUntil)
for _ in {1..60}; do
  [[ -s $test_home/expiry-schedules ]] && \
    jq -se --arg calendar "--on-calendar=@$(( (expiry + 999) / 1000 ))" 'any(.[]; index($calendar) != null)' "$test_home/expiry-schedules" >/dev/null && break
  sleep 0.02
done
python3 - "$test_home/expiry-schedules" "$expiry" "$ROOT" <<'PYTHON'
import json, sys
calls = [json.loads(line) for line in open(sys.argv[1])]
calendar = '--on-calendar=@' + str((int(sys.argv[2]) + 999) // 1000)
matching = [args for args in calls if calendar in args]
assert len(matching) == 1, matching
args = matching[0]
assert '--user' in args and '--collect' in args
assert args[-5:] == ['--', sys.argv[3] + '/bin/omarchy-shell', '-q', 'idle', 'refresh'], args
PYTHON
sleep 1.2
call refresh >/dev/null
await_state '.enabled == true'
[[ -s $state_file ]] || fail "Expiry does not need to delete the deadline"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" status | jq -e '.enabled == false' >/dev/null
stop_shell
start_shell
await_state '.enabled == true'
pass "expiry restores idle even across restart, without a cleanup write"

for raw in '1e300' 'Infinity' 'not a deadline' $'\n' $'2000\nno'; do
  call disable >/dev/null
  await_state '.stayAwake == true'
  sleep 0.15
  printf '%s' "$raw" > "$state_file"
  sleep 0.1
  await_state '.enabled == true'
done
pass "malformed state does not disable idle"

printf 'preserve this' > "$test_home/victim"
rm "$state_file"
ln -s "$test_home/victim" "$state_file"
call stayAwakeFor 60 >/dev/null
await_state '.stayAwakeUntil > 0'
for _ in {1..50}; do [[ ! -L $state_file ]] && break; sleep 0.05; done
[[ $(cat "$test_home/victim") == "preserve this" && ! -L $state_file ]] || fail "Atomic writer must preserve symlink targets"
pass "the shell replaces state symlinks without truncating their targets"

# Force overlapping asynchronous saves. Only the newest request should remain.
touch "$test_home/delay-write"
call stayAwakeFor 60 >/dev/null
call enable >/dev/null
call disable >/dev/null
call stayAwakeFor 1800 >/dev/null
sleep 1
await_state '.stayAwakeUntil > (now * 1000 + 1700000)'
latest=$(call status | jq -r .stayAwakeUntil)
[[ $(cat "$state_file") == "$latest" ]] || fail "The latest queued choice reaches disk"
rm "$test_home/delay-write"
stop_shell
start_shell
await_state ".stayAwakeUntil == $latest"
pass "overlapping choices persist the latest duration through a shell restart"

# Hold a completed old read open while an external command changes the file.
call enable >/dev/null
await_state '.enabled == true'
sleep 0.2
touch "$test_home/delay-read"
: > "$state_file"
for _ in {1..50}; do [[ -e $test_home/read-finished ]] && break; sleep 0.02; done
[[ -e $test_home/read-finished ]] || fail "Delayed read starts"
rm "$state_file" "$test_home/delay-read"
sleep 0.7
await_state '.enabled == true'
pass "a file change during an in-flight probe is not lost"

# Failed reads must not turn a partial 'yes:' response into indefinite mode.
touch "$test_home/fail-read"
: > "$state_file"
sleep 0.3
await_state '.enabled == true'
rm "$test_home/fail-read" "$state_file"
pass "read errors cannot become an indefinite stay-awake session"

touch "$test_home/fail-write"
call stayAwakeFor 60 >/dev/null
sleep 0.3
await_state '.enabled == true'
[[ ! -e $state_file ]] || fail "Failed writes leave prior state intact"
[[ -s $test_home/notifications ]] || fail "Failed writes notify the user"
rm "$test_home/fail-write"
pass "failed saves preserve the prior setting and notify the user"

call stayAwakeFor 60 >/dev/null
await_state '.stayAwakeUntil > 0'
for _ in {1..60}; do [[ -s $state_file ]] && break; sleep 0.02; done
saved=$(cat "$state_file")
touch "$test_home/fail-write"
call stayAwakeFor 1800 >/dev/null
sleep 0.3
await_state ".stayAwakeUntil == $saved"
[[ $(cat "$state_file") == "$saved" ]] || fail "Failed writes preserve the saved deadline"
rm "$test_home/fail-write"
pass "a failed save restores the previously saved duration"

# A stale timer refresh must never cancel a newer user choice.
call disable >/dev/null
sleep 0.2
call refresh >/dev/null
await_state '.stayAwake == true and .stayAwakeUntil == 0'
pass "a superseded timer event preserves a newer indefinite choice"

touch "$test_home/fail-schedule"
call stayAwakeFor 1800 >/dev/null
sleep 0.3
await_state '.enabled == true'
[[ ! -e $state_file ]] || fail "A scheduler failure cannot leave an unexpiring session"
rm "$test_home/fail-schedule"
pass "scheduler failure resumes idle and clears the unschedulable choice"

# Pause update publication after its ownership read, then make a newer choice.
# Only filesystem state is exercised: never acquire a real sleep inhibitor.
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
trap cleanup EXIT
export SUDO_TEST_HOME="$test_home"
copy_boundary_file bin/omarchy-update-stay-awake
runtime_dir="/run/user/$(id -u)"
update_state_name="omarchy-update-stay-awake-test-$BASHPID-$RANDOM"
update_state_dir="$runtime_dir/$update_state_name"
sed -i "s#state_dir=\"\$state_base/omarchy-update-stay-awake\"#state_dir=\"\$state_base/$update_state_name\"#" "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake"
cat > "$SUDO_TEST_ROOT/mock/systemd-inhibit" <<'BASH'
#!/bin/bash
while [[ $1 == --* ]]; do shift; done
exec "$@"
BASH
cat > "$SUDO_TEST_ROOT/mock/pkexec" <<'BASH'
#!/bin/bash
exec "$@"
BASH
cat > "$SUDO_TEST_ROOT/mock/setpriv" <<'BASH'
#!/bin/bash
while [[ ${1:-} == --* ]]; do
  case "$1" in
    --reuid|--regid) shift 2 ;;
    --clear-groups) shift ;;
    *) exit 90 ;;
  esac
done
exec "$@"
BASH
cat > "$SUDO_TEST_ROOT/bin/mv" <<'BASH'
#!/bin/bash
# Pause the marker publication, after the shared lock and ownership read.
if [[ ${!#} == */indicators/stay-awake && -e $SUDO_TEST_HOME/pause-rename ]]; then
  rm "$SUDO_TEST_HOME/pause-rename"
  touch "$SUDO_TEST_HOME/rename-ready"
  for _ in {1..200}; do
    [[ ! -e $SUDO_TEST_HOME/rename-ready ]] && break
    sleep 0.02
  done
fi
exec /usr/bin/mv "$@"
BASH
chmod +x "$SUDO_TEST_ROOT/mock/"* "$SUDO_TEST_ROOT/bin/mv"
update_idle() {
  XDG_RUNTIME_DIR="$runtime_dir" "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" "$@"
}
for phase in start stop; do
  for choice in timed indefinite off cli-on cli-off cli-toggle; do
    original=$(( $(date +%s%3N) + 60000 ))
    printf '%s' "$original" > "$state_file"
    await_state ".stayAwakeUntil == $original"
    if [[ $phase == "stop" ]]; then update_idle start; fi
    touch "$test_home/pause-rename"
    update_idle "$phase" &
    update_pid=$!
    for _ in {1..100}; do [[ -e $test_home/rename-ready ]] && break; sleep 0.02; done
    [[ -e $test_home/rename-ready ]] || fail "Update reaches paused $phase"
    choice_pid=""
    case "$choice" in
      timed) call stayAwakeFor 10800 >/dev/null ;;
      indefinite) call disable >/dev/null ;;
      off) call enable >/dev/null ;;
      cli-*)
        HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" "${choice#cli-}" >/dev/null &
        choice_pid=$!
        ;;
    esac
    sleep 0.3
    rm "$test_home/rename-ready"
    wait "$update_pid"
    if [[ -n $choice_pid ]]; then wait "$choice_pid"; fi
    sleep 0.3
    if [[ $phase == "start" ]]; then update_idle stop; fi
    case "$choice" in
      timed) await_state '.stayAwakeUntil > (now * 1000 + 10700000)' ;;
      indefinite|cli-on)
        await_state '.stayAwake == true and .stayAwakeUntil == 0'
        [[ -f $state_file && ! -s $state_file ]] || fail "Indefinite choice survives update $phase"
        ;;
      off|cli-off|cli-toggle)
        await_state '.enabled == true'
        [[ ! -e $state_file ]] || fail "Turn off survives update $phase"
        ;;
    esac
    pass "a newer $choice choice survives overlapping update $phase"
  done
done
