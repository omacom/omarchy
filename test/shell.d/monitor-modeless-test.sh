#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
watch_pid=""
events_fd=""
relight_pid=""

# The watcher forks delayed clamshell retries and the recovery loop. Orphaning
# those would leave them running against a deleted test tree.
# Closing the event stream first would let the watcher exit on its own and
# reparent the recovery loop, which then outlives the test and keeps reloading.
stop_watcher() {
  if [[ -n $watch_pid ]]; then
    # The watcher leads its own process group, and everything it forks stays
    # in it however deep or late, so one kill reaches all of it at once. A
    # snapshot of its children would miss one forked after it was taken.
    kill -KILL -- "-$watch_pid" 2>/dev/null || true
    wait "$watch_pid" 2>/dev/null || true
    # A killed process can still finish the write it was in, into a log the
    # next scenario reuses; let the whole group go before moving on.
    for _ in {1..100}; do
      pgrep -g "$watch_pid" -r R,S,D,T,t >/dev/null || break
      sleep 0.02
    done
    watch_pid=""
  fi

  if [[ -n $events_fd ]]; then
    exec {events_fd}>&-
    events_fd=""
  fi

  return 0
}

# A relight run on its own waits on a monitor that will not wake, so a failed
# assertion would otherwise leave it running against a deleted test tree.
stop_relight() {
  local child descendants

  if [[ -n $relight_pid ]]; then
    descendants=$(pgrep -P "$relight_pid" 2>/dev/null || true)
    for child in $descendants; do
      descendants+=" $(pgrep -P "$child" 2>/dev/null || true)"
    done

    kill -KILL "$relight_pid" $descendants 2>/dev/null || true
    wait "$relight_pid" 2>/dev/null || true
    relight_pid=""
  fi

  return 0
}

cleanup() {
  stop_watcher
  stop_relight
  rm -rf "$test_tmp"
}
trap cleanup EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

# The recovery loop backs off from 3s, doubling; run its sleeps at a
# fifteenth of their length so the scenarios do not wait them out. The
# doubling ratios survive, which the echoed-event bound below relies on.
cat >"$fake_bin/sleep" <<'SH'
#!/bin/bash
exec /usr/bin/sleep "$(awk -v d="${1:-0}" 'BEGIN { printf "%g", d / 15 }')"
SH
chmod +x "$fake_bin/sleep"

monitors_file="$test_tmp/monitors.json"
reload_log="$test_tmp/reload.log"
recovered="$test_tmp/recovered.json"
events="$test_tmp/events"
modeless_lock="$test_tmp/omarchy-monitor-modeless.lock"
hyprctl_fail="$test_tmp/hyprctl-fails"

# The monitor list lives in a file so a reload can "fix" it mid-run.
cat >"$fake_bin/hyprctl" <<'SH'
#!/bin/bash

# Mirrors are absent from plain `monitors`, so the helper must ask for `all`.
if [[ ${1:-} == "monitors" && ${2:-} == "all" && ${3:-} == "-j" ]]; then
  [[ -f $OMARCHY_TEST_HYPRCTL_FAIL_FLAG ]] && exit 4
  cat "$OMARCHY_TEST_MONITORS_FILE"
elif [[ ${1:-} == "reload" ]]; then
  printf 'reload\n' >>"$OMARCHY_TEST_RELOAD_LOG"
  [[ -f $OMARCHY_TEST_RECOVERED_MONITORS ]] &&
    cp "$OMARCHY_TEST_RECOVERED_MONITORS" "$OMARCHY_TEST_MONITORS_FILE"
elif [[ ${1:-} == "eval" ]]; then
  printf '%s\n' "$2" >>"$OMARCHY_TEST_EVAL_LOG"
  # The kernel accepts a mode the sleeping monitor offers, the link trains, and
  # the monitor wakes announcing its real modes.
  if [[ -n ${OMARCHY_TEST_WAKES_CONNECTOR:-} ]]; then
    printf 'enabled\n' >"$OMARCHY_TEST_WAKES_CONNECTOR/enabled"
    printf '5120x1440\n1920x1080\n' >"$OMARCHY_TEST_WAKES_CONNECTOR/modes"
  fi
  if [[ -n ${OMARCHY_TEST_BLANKS_MONITOR:-} ]]; then
    jq --arg name "$OMARCHY_TEST_BLANKS_MONITOR" \
      'map(if .name == $name then .dpmsStatus = false else . end)' \
      "$OMARCHY_TEST_MONITORS_FILE" >"$OMARCHY_TEST_MONITORS_FILE.next"
    mv "$OMARCHY_TEST_MONITORS_FILE.next" "$OMARCHY_TEST_MONITORS_FILE"
  fi
  # A waking monitor usually leaves the bus a moment after it is first driven.
  # Most come back within seconds. One was seen never to.
  if [[ -n ${OMARCHY_TEST_DROPS_CONNECTOR:-} ]]; then
    (
      sleep 2
      printf 'disconnected\n' >"$OMARCHY_TEST_DROPS_CONNECTOR/status"
      printf 'disabled\n' >"$OMARCHY_TEST_DROPS_CONNECTOR/enabled"
      if [[ ${OMARCHY_TEST_DROP_RETURNS:-0} == 1 ]]; then
        sleep 4
        printf 'connected\n' >"$OMARCHY_TEST_DROPS_CONNECTOR/status"
        printf 'enabled\n' >"$OMARCHY_TEST_DROPS_CONNECTOR/enabled"
      fi
    ) >/dev/null 2>&1 &
  fi
fi
SH

cat >"$fake_bin/omarchy-hyprland-reload-guard" <<'SH'
#!/bin/bash

[[ ${1:-} == "paused" && ${OMARCHY_TEST_GUARD_PAUSED:-0} == 1 ]]
SH

cat >"$fake_bin/socat" <<'SH'
#!/bin/bash

exec cat "$OMARCHY_TEST_EVENTS"
SH

# A desktop, so the clamshell half of the watcher stays idle.
cat >"$fake_bin/omarchy-hw-laptop" <<'SH'
#!/bin/bash

exit 1
SH

cat >"$fake_bin/omarchy-hyprland-monitor-clamshell" <<'SH'
#!/bin/bash

exit 0
SH

cp "$fake_bin/omarchy-hyprland-monitor-clamshell" "$fake_bin/omarchy-system-lid-inhibit"

# No external monitor plugged in, so the unlit poll stays out of the modeless
# scenarios. The unlit scenarios at the end swap in the real command.
cp "$fake_bin/omarchy-hw-laptop" "$fake_bin/omarchy-hw-external-monitors"

chmod +x "$fake_bin"/*
ln -s "$ROOT/bin/omarchy-hyprland-monitor-modeless" "$fake_bin/omarchy-hyprland-monitor-modeless"

MODELESS=0
WORKING=1
UNDETERMINED=2

assert_state() {
  local expected="$1" actual=0

  printf '%s' "$2" >"$monitors_file"
  PATH="$fake_bin:$PATH" OMARCHY_TEST_MONITORS_FILE="$monitors_file" \
  OMARCHY_TEST_HYPRCTL_FAIL_FLAG="$hyprctl_fail" \
    "$ROOT/bin/omarchy-hyprland-monitor-modeless" || actual=$?

  (( actual == expected )) || fail "$3" "expected exit $expected, got $actual"
  pass "$3"
}

reloads() {
  wc -l <"$reload_log" | tr -d ' '
}

# A monitor powered off at boot reports an EDID with no modes, so Hyprland
# brings it up at 0x0.
assert_state $MODELESS '[{"name":"DP-1","width":0,"height":0,"disabled":false}]' \
  "a monitor brought up with no mode is detected"

assert_state $MODELESS \
  '[{"name":"DP-1","width":2560,"height":1440,"disabled":false},{"name":"DP-2","width":0,"height":0,"disabled":false}]' \
  "one modeless monitor among working ones is detected"

# Hyprland drops mirrors from `monitors`, so only `monitors all` sees them.
assert_state $MODELESS \
  '[{"name":"HDMI-A-1","width":0,"height":0,"disabled":false,"mirrorOf":"eDP-1"}]' \
  "a modeless mirrored monitor is detected"

assert_state $WORKING '[{"name":"DP-1","width":2560,"height":1440,"disabled":false}]' \
  "a working monitor is not reported as modeless"

# A monitor turned off on purpose is 0x0 too, and re-applying config would fight
# the user over it.
assert_state $WORKING '[{"name":"DP-1","width":0,"height":0,"disabled":true}]' \
  "a deliberately disabled monitor is not reported as modeless"

assert_state $WORKING '[]' "a session with no monitors is not reported as modeless"

# Nothing fires an event for this state, so taking an unanswered query for a
# healthy monitor would leave the screen black for good.
assert_state $UNDETERMINED 'not json' "an unreadable monitor payload cannot say"

printf '%s' '[{"name":"DP-1","width":0,"height":0,"disabled":false}]' >"$monitors_file"
touch "$hyprctl_fail"
unreachable=0
PATH="$fake_bin:$PATH" OMARCHY_TEST_MONITORS_FILE="$monitors_file" \
OMARCHY_TEST_HYPRCTL_FAIL_FLAG="$hyprctl_fail" \
  "$ROOT/bin/omarchy-hyprland-monitor-modeless" || unreachable=$?
rm -f "$hyprctl_fail"
(( unreachable == UNDETERMINED )) || fail "an unreachable compositor cannot say" "got $unreachable"
pass "an unreachable compositor cannot say"

start_watcher() {
  : >"$reload_log"
  rm -f "$events"
  mkfifo "$events"

  PATH="$fake_bin:$PATH" \
  XDG_RUNTIME_DIR="$test_tmp" \
  HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_EVENTS="$events" \
  OMARCHY_TEST_MONITORS_FILE="$monitors_file" \
  OMARCHY_TEST_RELOAD_LOG="$reload_log" \
  OMARCHY_TEST_RECOVERED_MONITORS="$recovered" \
  OMARCHY_TEST_GUARD_PAUSED="${1:-0}" \
  OMARCHY_TEST_HYPRCTL_FAIL_FLAG="$hyprctl_fail" \
    setsid "$ROOT/bin/omarchy-hyprland-monitor-watch" &
  watch_pid=$!

  exec {events_fd}>"$events"
}

await_reloads() {
  local waited

  for (( waited = 0; waited < 100; waited++ )); do
    (( $(reloads) >= $1 )) && return 0
    sleep 0.05
  done

  return 1
}

# The watcher reloads until the monitor reports a mode, then stops. It has to
# stop on its own: powering the monitor on fires no event to stop it.
printf '%s' '[{"name":"DP-1","width":0,"height":0,"disabled":false}]' >"$monitors_file"
printf '%s' '[{"name":"DP-1","width":2560,"height":1440,"disabled":false}]' >"$recovered"
start_watcher

await_reloads 1 || fail "a monitor with no mode is reloaded at startup"
sleep 0.6
(( $(reloads) == 1 )) || fail "recovery stops once the monitor reports a mode" "$(<"$reload_log")"
pass "recovery reloads until the monitor comes back, then stops on its own"

# A reload lands a monitor at 0x0 the same way a boot does, and no hotplug
# follows. The watcher's own recovery reload comes back through this event too,
# which the lock makes a no-op rather than a second loop.
printf '%s' '[{"name":"DP-1","width":0,"height":0,"disabled":false}]' >"$monitors_file"
rm -f "$recovered"
printf 'configreloaded>>\n' >&"$events_fd"

await_reloads 2 || fail "a monitor left at 0x0 by a reload is recovered"
pass "a monitor left at 0x0 by a reload is recovered"

before=$(reloads)
printf 'configreloaded>>\n' >&"$events_fd"
printf 'configreloaded>>\n' >&"$events_fd"
# One loop at the stub-compressed delays reloads at most twice in
# this window; a stacked second loop would add its own faster cadence.
sleep 1
(( $(reloads) - before <= 2 )) ||
  fail "an echoed configreloaded does not stack a second recovery loop" "$before -> $(reloads)"
pass "an echoed configreloaded does not stack a second recovery loop"

stop_watcher

# A package transaction has config half-replaced; reloading into that is exactly
# what the reload guard exists to prevent.
printf '%s' '[{"name":"DP-1","width":0,"height":0,"disabled":false}]' >"$monitors_file"
start_watcher 1

sleep 0.6
[[ ! -s $reload_log ]] || fail "recovery holds off while the reload guard is paused" "$(<"$reload_log")"
pass "recovery holds off while the reload guard is paused"

stop_watcher

# An unanswerable query is not a healthy monitor. Giving up on one would strand
# the screen, because nothing fires an event to start recovery again.
printf '%s' '[{"name":"DP-1","width":0,"height":0,"disabled":false}]' >"$monitors_file"
rm -f "$recovered"
touch "$hyprctl_fail"
start_watcher

sleep 0.6
[[ ! -s $reload_log ]] || fail "an unanswerable query does not trigger a reload" "$(<"$reload_log")"
rm -f "$hyprctl_fail"

await_reloads 1 || fail "recovery keeps asking after the compositor could not answer"
pass "recovery keeps asking after the compositor could not answer"

stop_watcher

# An event landing while a worker is on its way out must not be dropped: it is
# the last one that will ever come for this state.
printf '%s' '[{"name":"DP-1","width":2560,"height":1440,"disabled":false}]' >"$monitors_file"
rm -f "$recovered"
start_watcher

# The healthy startup worker has to be gone before the lock stands in for one on
# its way out, or it would hold it here and loop on the 0x0 state below instead.
flock -w 5 "$modeless_lock" -c true || fail "the startup worker released the recovery lock"

flock "$modeless_lock" -c 'sleep 0.5' &
lock_holder=$!
sleep 0.1

printf '%s' '[{"name":"DP-1","width":0,"height":0,"disabled":false}]' >"$monitors_file"
printf 'configreloaded>>\n' >&"$events_fd"
wait "$lock_holder" 2>/dev/null || true

await_reloads 1 || fail "a trigger contending with the recovery lock is not dropped"
pass "a trigger contending with the recovery lock is not dropped"

stop_watcher

# Nothing to recover means nothing to run.
printf '%s' '[{"name":"DP-1","width":2560,"height":1440,"disabled":false}]' >"$monitors_file"
start_watcher

sleep 0.6
[[ ! -s $reload_log ]] || fail "a healthy machine is left alone" "$(<"$reload_log")"
pass "a healthy machine is never reloaded"

stop_watcher

# A monitor that slept through a blank offers fewer modes than Hyprland
# remembers, so the kernel refuses the wake modeset: connected, wanted on, and
# not driven.
drm_path="$test_tmp/drm"
eval_log="$test_tmp/eval.log"
unlit_lock="$test_tmp/omarchy-monitor-unlit.lock"
lit_monitor='[{"name":"DP-1","width":5120,"height":1440,"disabled":false,"dpmsStatus":true,"availableModes":["5120x1440@59.98Hz","1920x1080@239.76Hz","1920x1080@60.00Hz","1280x720@59.94Hz"]}]'

for command in omarchy-hyprland-monitor-unlit omarchy-hyprland-monitor-relight omarchy-hw-external-monitors omarchy-restart-hyprctl; do
  ln -sf "$ROOT/bin/$command" "$fake_bin/$command"
done

write_connector() {
  local connector="$drm_path/card1-$1"

  mkdir -p "$connector"
  printf '%s\n' "$2" >"$connector/status"
  printf '%s\n' "$3" >"$connector/enabled"
  printf '2560x1440\n1920x1080\n1280x720\n' >"$connector/modes"
}

UNLIT=0
LIT=1

assert_unlit() {
  local expected="$1" actual=0

  printf '%s' "$2" >"$monitors_file"
  PATH="$fake_bin:$PATH" OMARCHY_DRM_PATH="$drm_path" OMARCHY_TEST_MONITORS_FILE="$monitors_file" \
  OMARCHY_TEST_HYPRCTL_FAIL_FLAG="$hyprctl_fail" \
    "$ROOT/bin/omarchy-hyprland-monitor-unlit" >"$test_tmp/unlit.out" || actual=$?

  (( actual == expected )) || fail "$3" "expected exit $expected, got $actual"
  pass "$3"
}

write_connector DP-1 connected disabled
assert_unlit $UNLIT "$lit_monitor" "a connected monitor Hyprland wants on but the kernel is not driving is unlit"
[[ $(<"$test_tmp/unlit.out") == "$drm_path/card1-DP-1" ]] ||
  fail "the unlit connector is named" "$(<"$test_tmp/unlit.out")"
pass "the unlit connector is named"

# A mode the kernel still lists was refused for another reason, such as a
# monitor switched off at its own button. Modesetting into that again is not a
# recovery, and froze an NVIDIA session when it was last tried.
assert_unlit $LIT '[{"name":"DP-1","width":2560,"height":1440,"disabled":false,"dpmsStatus":true}]' \
  "a dark monitor whose mode the kernel still offers is left alone"

# That one is the modeless recovery's to handle.
assert_unlit $LIT '[{"name":"DP-1","width":0,"height":0,"disabled":false,"dpmsStatus":true}]' \
  "a monitor with no mode at all is not reported unlit"

# Every blank looks like this from the kernel's side, all night long.
assert_unlit $LIT '[{"name":"DP-1","width":5120,"height":1440,"disabled":false,"dpmsStatus":false}]' \
  "a monitor blanked by DPMS is dark on purpose"

assert_unlit $LIT '[{"name":"DP-1","width":5120,"height":1440,"disabled":true,"dpmsStatus":true}]' \
  "a monitor turned off in the config is dark on purpose"

touch "$hyprctl_fail"
assert_unlit $UNDETERMINED "$lit_monitor" "an unreachable compositor cannot say whether a dark monitor is wanted"

# The poll runs this every two seconds, so a healthy desk must cost no hyprctl.
write_connector DP-1 connected enabled
assert_unlit $LIT "$lit_monitor" "a driven monitor is settled without asking the compositor"
rm -f "$hyprctl_fail"

# The internal panel is dark with the lid shut and comes back with the hardware.
rm -rf "$drm_path"
write_connector eDP-1 connected disabled
assert_unlit $LIT '[{"name":"eDP-1","width":2880,"height":1800,"disabled":false,"dpmsStatus":true}]' \
  "an internal panel is never reported unlit"

start_unlit_watcher() {
  : >"$eval_log"

  export OMARCHY_DRM_PATH="$drm_path" OMARCHY_TEST_EVAL_LOG="$eval_log"
  start_watcher
}

# The modeset the kernel accepts wakes the monitor, and only then is the
# configured mode worth asking for again.
rm -rf "$drm_path"
write_connector DP-1 connected disabled
printf '%s' "$lit_monitor" >"$monitors_file"
rm -f "$recovered"
export OMARCHY_TEST_WAKES_CONNECTOR="$drm_path/card1-DP-1"
start_unlit_watcher

await_reloads 1 || fail "an unlit monitor is woken and its config restored" "$(<"$eval_log")"
[[ $(<"$eval_log") == 'hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "auto", scale = 1 })' ]] ||
  fail "an unlit monitor is woken once, at the largest size it offers asleep" "$(<"$eval_log")"
flock -w 5 "$unlit_lock" -c true || fail "the relight finishes once the monitor is driven"
sleep 0.6
(( $(reloads) == 1 )) || fail "a relit monitor is left alone" "$(<"$reload_log")"
pass "an unlit monitor is woken at a size it offers asleep, then its config is restored"

stop_watcher
unset OMARCHY_TEST_WAKES_CONNECTOR

# Waking a monitor the idle timer just blanked would undo every blank.
write_connector DP-1 connected disabled
printf '%s' '[{"name":"DP-1","width":5120,"height":1440,"disabled":false,"dpmsStatus":false}]' >"$monitors_file"
start_unlit_watcher

sleep 0.6
[[ ! -s $eval_log && ! -s $reload_log ]] || fail "a blanked monitor is left dark" "$(<"$eval_log")"
pass "a blanked monitor is left dark"

stop_watcher

# The small mode is a runtime rule that outlives a failed attempt. Left behind,
# it would bring the monitor up small the next time it was plugged in.
write_connector DP-1 connected disabled
printf '%s' "$lit_monitor" >"$monitors_file"
start_unlit_watcher

await_reloads 1 || fail "a monitor that will not wake still gets its config restored" "$(<"$eval_log")"
[[ -s $eval_log ]] || fail "a monitor that will not wake was tried"
pass "a monitor that will not wake still gets its config restored"

# Let the relight see the monitor driven and finish, so it does not outlive the test.
write_connector DP-1 connected enabled
flock -w 10 "$unlit_lock" -c true || fail "the relight stops once the monitor is driven"

stop_watcher

# The relight on its own, so what it reports can be read.
run_relight() {
  rm -rf "$drm_path"
  write_connector DP-1 connected disabled
  if [[ -n ${1:-} ]]; then
    write_connector "$1" connected disabled
  fi
  printf '%s' "$lit_monitor" >"$monitors_file"
  : >"$reload_log"
  : >"$eval_log"

  PATH="$fake_bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test OMARCHY_DRM_PATH="$drm_path" OMARCHY_TEST_EVAL_LOG="$eval_log" \
  OMARCHY_TEST_MONITORS_FILE="$monitors_file" OMARCHY_TEST_RELOAD_LOG="$reload_log" \
  OMARCHY_TEST_RECOVERED_MONITORS="$recovered" OMARCHY_TEST_HYPRCTL_FAIL_FLAG="$hyprctl_fail" \
    "$ROOT/bin/omarchy-hyprland-monitor-relight" >"$test_tmp/relight.out" 2>&1
}

export OMARCHY_TEST_WAKES_CONNECTOR="$drm_path/card1-DP-1" OMARCHY_TEST_DROPS_CONNECTOR="$drm_path/card1-DP-1"

# The usual wake: driven for a moment, off the bus, then back for good.
OMARCHY_TEST_DROP_RETURNS=1 run_relight
grep -q "DP-1 woke, restored its configured mode" "$test_tmp/relight.out" ||
  fail "a monitor that drops off the bus and returns is reported woken" "$(<"$test_tmp/relight.out")"
pass "a monitor that drops off the bus and returns is reported woken"

# The same wake, except the monitor never comes back. Being driven for that
# first moment is not a wake, and saying so would hide a monitor that needs
# its cable pulled.
run_relight
! grep -q "woke" "$test_tmp/relight.out" ||
  fail "a monitor that drops off the bus for good is not reported woken" "$(<"$test_tmp/relight.out")"
grep -q "DP-1 dropped off the bus while waking and did not come back" "$test_tmp/relight.out" ||
  fail "a monitor that drops off the bus for good is reported lost" "$(<"$test_tmp/relight.out")"
(( $(reloads) == 1 )) || fail "a lost monitor still gets its config restored, once" "$(<"$reload_log")"
pass "a monitor that drops off the bus for good is reported lost, with its config restored"

unset OMARCHY_TEST_WAKES_CONNECTOR OMARCHY_TEST_DROPS_CONNECTOR

# Hyprland can only ask for a mode it remembers, so a size the kernel lists but
# Hyprland never had would be refused three times over while a smaller one both
# know goes untried.
printf '%s' '[{"name":"DP-1","width":5120,"height":1440,"disabled":false,"dpmsStatus":true,"availableModes":["5120x1440@59.98Hz","1280x720@120.00Hz","1280x720@59.94Hz"]}]' >"$test_tmp/narrow.json"
lit_monitor=$(<"$test_tmp/narrow.json")
export OMARCHY_TEST_WAKES_CONNECTOR="$drm_path/card1-DP-1"
run_relight
[[ $(<"$eval_log") == 'hl.monitor({ output = "DP-1", mode = "1280x720@59.94", position = "auto", scale = 1 })' ]] ||
  fail "the wake mode is one both the kernel and Hyprland have, at the rate nearest 60 Hz" "$(<"$eval_log")"
pass "the wake mode is one both the kernel and Hyprland have, at the rate nearest 60 Hz"
unset OMARCHY_TEST_WAKES_CONNECTOR

two_monitors='[{"name":"DP-1","width":5120,"height":1440,"disabled":false,"dpmsStatus":true,"availableModes":["5120x1440@59.98Hz","1920x1080@60.00Hz"]},
{"name":"DP-2","width":5120,"height":1440,"disabled":false,"dpmsStatus":true,"availableModes":["5120x1440@59.98Hz","1920x1080@60.00Hz"]}]'
lit_monitor=$two_monitors
OMARCHY_TEST_WAKES_CONNECTOR="$drm_path/card1-DP-1" OMARCHY_TEST_BLANKS_MONITOR=DP-2 run_relight DP-2
grep -q 'output = "DP-1"' "$eval_log" && ! grep -q 'output = "DP-2"' "$eval_log" ||
  fail "a monitor blanked while another recovers is left alone" "$(<"$eval_log")"
pass "a monitor blanked while another recovers is left alone"

# One monitor that will not wake must not keep a second from being tried. The
# relight stays running for the first, and the watcher starts no other while it
# does, so the second has only this one to rely on.
run_relight &
relight_pid=$!

evals_for() {
  grep -c "output = \"$1\"" "$eval_log" || true
}

for (( waited = 0; waited < 400 && $(evals_for DP-1) < 3; waited++ )); do
  sleep 0.5
done
(( $(evals_for DP-1) == 3 )) || fail "a monitor that will not wake is tried three times" "$(<"$eval_log")"

write_connector DP-2 connected disabled
for (( waited = 0; waited < 400 && $(evals_for DP-2) < 1; waited++ )); do
  sleep 0.5
done
(( $(evals_for DP-2) >= 1 )) || fail "a second monitor is tried while the first stays dark" "$(<"$eval_log")"
(( $(evals_for DP-1) == 3 )) || fail "the monitor already given up on is not tried again" "$(<"$eval_log")"
pass "a second monitor is tried while one that will not wake stays dark"

# Let the relight see both driven and finish, so it does not outlive the test.
write_connector DP-1 connected enabled
write_connector DP-2 connected enabled
wait "$relight_pid" || true
relight_pid=""
