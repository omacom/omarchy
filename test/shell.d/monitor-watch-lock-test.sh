#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
watch_pid=""
events_fd=""

# The watcher runs in a session of its own, so its delayed retries go with it
# even if one forks while it is being killed.
stop_watcher() {
  if [[ -n $watch_pid ]]; then
    kill -KILL -- "-$watch_pid" 2>/dev/null || true
    wait "$watch_pid" 2>/dev/null || true
    watch_pid=""
  fi

  if [[ -n $events_fd ]]; then
    exec {events_fd}>&-
    events_fd=""
  fi

  return 0
}

cleanup() {
  stop_watcher
  rm -rf "$test_tmp"
}
trap cleanup EXIT

fake_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
events="$test_tmp/events"
mkdir -p "$fake_bin"

cat >"$fake_bin/socat" <<'SH'
#!/bin/bash
exec cat "$OMARCHY_TEST_EVENTS"
SH

# The watcher's delayed clamshell retries would interleave with the event under
# test, so they never wake.
cat >"$fake_bin/sleep" <<'SH'
#!/bin/bash
exec /usr/bin/sleep infinity
SH

cat >"$fake_bin/hyprctl" <<'SH'
#!/bin/bash
exit 0
SH

# No monitor is modeless and none is an active external, so neither the recovery
# loop nor the docked poll gets in the way of what is under test.
cat >"$fake_bin/omarchy-hyprland-monitor-modeless" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$fake_bin/omarchy-hyprland-monitor-external-active" <<'SH'
#!/bin/bash
exit 1
SH

for command in omarchy-hw-laptop-closed omarchy-hw-external-monitors omarchy-hyprland-session-locked; do
  cat >"$fake_bin/$command" <<SH
#!/bin/bash
exit \$(<"\$OMARCHY_TEST_FACTS/$command")
SH
done

for command in omarchy-system-lock omarchy-hyprland-monitor-clamshell; do
  cat >"$fake_bin/$command" <<SH
#!/bin/bash
echo $command >>"\$OMARCHY_TEST_CALL_LOG"
SH
done

# The watcher asks this only when it handles an event, never from its delayed
# clamshell retries, so its entry marks the end of an event.
cat >"$fake_bin/omarchy-hw-laptop" <<'SH'
#!/bin/bash
echo omarchy-hw-laptop >>"$OMARCHY_TEST_CALL_LOG"
SH

chmod +x "$fake_bin"/*

# Each fact is an exit status: 0 closed / connected / locked, 1 not.
set_facts() {
  mkdir -p "$test_tmp/facts"
  echo "$1" >"$test_tmp/facts/omarchy-hw-laptop-closed"
  echo "$2" >"$test_tmp/facts/omarchy-hw-external-monitors"
  echo "$3" >"$test_tmp/facts/omarchy-hyprland-session-locked"
}

start_watcher() {
  rm -f "$events"
  mkfifo "$events"
  : >"$call_log"

  PATH="$fake_bin:$PATH" \
  XDG_RUNTIME_DIR="$test_tmp" \
  HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_EVENTS="$events" \
  OMARCHY_TEST_FACTS="$test_tmp/facts" \
  OMARCHY_TEST_CALL_LOG="$call_log" \
    setsid "$ROOT/bin/omarchy-hyprland-monitor-watch" &
  watch_pid=$!

  exec {events_fd}>"$events"
}

await_call() {
  local waited

  for (( waited = 0; waited < 40; waited++ )); do
    grep -qx "$1" "$call_log" 2>/dev/null && return 0
    sleep 0.05
  done

  return 1
}

# Starts a watcher, lets its startup sync land, then removes a monitor and
# leaves in `calls` what the removal did.
remove_monitor() {
  set_facts "$@"
  start_watcher
  await_call omarchy-hw-laptop || fail "the watcher finishes its startup sync"
  : >"$call_log"

  printf 'monitorremovedv2>>1,DP-1,Test Monitor\n' >&"$events_fd"
  await_call omarchy-hw-laptop || fail "the watcher handles a removed monitor"
  mapfile -t calls <"$call_log"
  stop_watcher
}

# With the lid shut and the last external gone nothing is visible, and the
# panel about to come back is hidden, so the session has to be locked first.
remove_monitor 0 1 1
[[ ${calls[*]} == "omarchy-system-lock omarchy-hyprland-monitor-clamshell omarchy-hw-laptop" ]] ||
  fail "losing the last external display with the lid closed locks before re-enabling the panel" "calls: ${calls[*]}"
pass "losing the last external display with the lid closed locks before re-enabling the panel"

# Clamshell mode carries on while another external display is still connected.
remove_monitor 0 0 1
[[ ${calls[*]} != *omarchy-system-lock* ]] ||
  fail "removing one of several external displays with the lid closed does not lock" "calls: ${calls[*]}"
pass "removing one of several external displays with the lid closed does not lock"

# Unplugging with the lid open leaves the user looking at the panel.
remove_monitor 1 1 1
[[ ${calls[*]} != *omarchy-system-lock* ]] ||
  fail "unplugging with the lid open does not lock" "calls: ${calls[*]}"
pass "unplugging with the lid open does not lock"

# An already-locked session is secure; locking again would only reset its layout.
remove_monitor 0 1 0
[[ ${calls[*]} != *omarchy-system-lock* ]] ||
  fail "an already-locked session is not locked again" "calls: ${calls[*]}"
pass "an already-locked session is not locked again"
