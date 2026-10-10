#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
mkdir -p "$mock_bin"
export PATH="$mock_bin:$PATH" CALL_LOG="$call_log" OMARCHY_PATH="$ROOT"
export XDG_RUNTIME_DIR="$test_tmp/runtime" DBUS_SESSION_BUS_ADDRESS="unix:path=$test_tmp/runtime/bus"

cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash

printf 'systemd-run %s\n' "$*" >>"$CALL_LOG"
[[ ${FAIL_SYSTEMD_RUN:-false} == "true" ]] && exit 1
if [[ ${1:-} == "--user" ]]; then
  printf '%s %s\n' "${XDG_RUNTIME_DIR:-}" "${DBUS_SESSION_BUS_ADDRESS:-}" >"$CALL_LOG.bus"
  [[ ${FAIL_USER_BUS:-false} == "true" ]] && exit 1
  [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} && -n ${XDG_RUNTIME_DIR:-} ]] || exit 1
fi
[[ " $* " == *" --on-active="* ]] && exit 0
while [[ $1 == --* ]]; do shift; done
# Capture the service command so its exit status is tested separately.
printf '%q ' "$@" >"$CALL_LOG.worker"
SH

cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash

printf 'systemd-inhibit %s\n' "$*" >>"$CALL_LOG"
[[ ${FAIL_INHIBIT:-false} == "true" ]] && exit 17
while [[ $1 == --* ]]; do shift; done
touch "$CALL_LOG.inhibited"
trap 'rm -f "$CALL_LOG.inhibited"' EXIT
"$@"
SH

for command in omarchy-state omarchy-hyprland-window-close-all omarchy-osd omarchy-notification-send sleep systemctl; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash

command=${0##*/}
printf '%s %s\n' "$command" "$*" >>"$CALL_LOG"
case $command in
  omarchy-hyprland-window-close-all)
    if [[ ${BLOCK_WINDOW_CLOSE:-false} == "true" ]]; then
      for (( attempt = 0; attempt < 200; attempt++ )); do
        if [[ -f $CALL_LOG.poweroff ]]; then
          touch "$CALL_LOG.close-finished"
          exit 0
        fi
        /usr/bin/sleep 0.01
      done
      touch "$CALL_LOG.close-timeout"
      exit 1
    fi
    ;;
  omarchy-notification-send)
    [[ ${FAIL_NOTIFICATION:-false} != "true" ]] || exit 42
    ;;
  sleep)
    if [[ $1 == "2" ]]; then
      # Synchronize with background preparation without a fixed test-time sleep.
      for (( attempt = 0; attempt < 200; attempt++ )); do
        grep -q '^omarchy-hyprland-window-close-all ' "$CALL_LOG" && break
        /usr/bin/sleep 0.01
      done
      touch "$CALL_LOG.grace"
    fi
    ;;
  systemctl)
    [[ $* == "poweroff --no-wall" && -f $CALL_LOG.inhibited && -f $CALL_LOG.grace ]] || exit 2
    touch "$CALL_LOG.poweroff"
    [[ ${FAIL_POWEROFF:-false} != "true" ]]
    ;;
esac
SH
done
chmod +x "$mock_bin"/*

run_power_command() {
  local action="$1"

  : >"$call_log"
  rm -f "$CALL_LOG.grace"
  "$ROOT/bin/omarchy-system-$action"
}

run_power_command reboot
printf '%s\n' \
  'systemd-run --user --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms systemctl reboot --no-wall' \
  'omarchy-osd -i reboot -m Rebooting -d 5000' \
  'omarchy-state clear re*-required' \
  'omarchy-hyprland-window-close-all ' \
  'sleep 1' >"$test_tmp/reboot-expected.log"
diff -u "$test_tmp/reboot-expected.log" "$call_log" || fail "reboot runs after being scheduled outside the terminal scope"
pass "reboot runs after being scheduled outside the terminal scope"

run_power_command shutdown || fail "shutdown service is scheduled"
grep -q '^systemd-run --user --collect --quiet --property=Type=exec --property=RuntimeMaxSec=30s .* --inhibit$' "$CALL_LOG" || fail "shutdown uses a bounded service outside the launching terminal"
bash "$CALL_LOG.worker" || fail "protected shutdown succeeds"
grep -q '^systemd-inhibit --what=sleep:idle:handle-lid-switch .* --mode=block .* --inhibited$' "$CALL_LOG" || fail "shutdown blocks sleep and lid handling"
inhibit_line=$(grep -n '^systemd-inhibit ' "$CALL_LOG" | cut -d: -f1)
osd_line=$(grep -n '^omarchy-osd ' "$CALL_LOG" | cut -d: -f1)
(( inhibit_line < osd_line )) || fail "inhibition precedes preparation"
grep -q '^omarchy-state clear re\*-required$' "$CALL_LOG" || fail "shutdown clears restart state"
grep -q '^omarchy-hyprland-window-close-all ' "$CALL_LOG" || fail "shutdown closes windows"
grep -q '^systemctl poweroff --no-wall$' "$CALL_LOG" || fail "poweroff runs after the grace period while inhibited"
[[ ! -f $CALL_LOG.inhibited ]] || fail "accepted poweroff releases inhibition"
! grep -q '^omarchy-notification-send ' "$CALL_LOG" || fail "successful shutdown sends no failure notification"
pass "shutdown stays inhibited through preparation and the poweroff request"

: >"$call_log"
rm -f "$CALL_LOG.grace" "$CALL_LOG.poweroff"
# Dev link/unlink can leave the user manager pointing at a removed checkout.
OMARCHY_PATH="$test_tmp/removed-checkout" bash "$CALL_LOG.worker" || fail "shutdown uses its own script when the service environment is stale"
[[ -f $CALL_LOG.poweroff ]] || fail "shutdown reaches poweroff with a stale service environment"
[[ ! -f $CALL_LOG.inhibited ]] || fail "shutdown releases inhibition with a stale service environment"
! grep -q '^omarchy-notification-send ' "$CALL_LOG" || fail "stale service environment sends no failure notification"
pass "shutdown uses its own script when the service environment is stale"

: >"$call_log"
rm -f "$CALL_LOG.grace" "$CALL_LOG.poweroff"
BLOCK_WINDOW_CLOSE=true bash "$CALL_LOG.worker" || fail "shutdown proceeds while window closing is blocked"
for (( attempt = 0; attempt < 200; attempt++ )); do
  [[ -f $CALL_LOG.close-finished || -f $CALL_LOG.close-timeout ]] && break
  /usr/bin/sleep 0.01
done
[[ -f $CALL_LOG.close-finished && ! -f $CALL_LOG.close-timeout ]] || fail "poweroff releases the blocked window helper before its timeout"
pass "blocked window closing cannot delay poweroff"

for action in reboot shutdown; do
  : >"$call_log"
  if FAIL_SYSTEMD_RUN=true "$ROOT/bin/omarchy-system-$action"; then
    fail "$action aborts when scheduling fails"
  fi

  if (( $(wc -l <"$call_log") != 2 )); then
    fail "$action leaves state and windows alone when scheduling fails" "$(cat "$call_log")"
  fi
  pass "$action leaves state and windows alone when scheduling fails"
done

for failure in FAIL_INHIBIT FAIL_POWEROFF; do
  : >"$call_log"
  rm -f "$CALL_LOG.grace"
  env "$failure=true" bash "$CALL_LOG.worker"
  status=$?
  expected_status=1
  [[ $failure == "FAIL_INHIBIT" ]] && expected_status=17
  if (( status != expected_status )); then
    fail "$failure propagates to the service"
  fi
  grep -q '^omarchy-notification-send -u critical Shutdown failed Could not complete shutdown. Please try again.$' "$CALL_LOG" || fail "$failure notifies the user"
  [[ ! -f $CALL_LOG.inhibited ]] || fail "$failure releases inhibition"
  if [[ $failure == "FAIL_INHIBIT" ]]; then
    (( $(wc -l <"$call_log") == 2 )) || fail "inhibitor failure leaves applications alone"
  else
    grep -q '^systemctl poweroff --no-wall$' "$CALL_LOG" || fail "rejection test reaches poweroff"
  fi
  pass "$failure notifies the user and leaves no inhibitor behind"
done

: >"$call_log"
FAIL_INHIBIT=true FAIL_NOTIFICATION=true bash "$CALL_LOG.worker"
[[ $? == 17 ]] || fail "notification failure preserves the shutdown error"
pass "notification failure preserves the shutdown error"

empty_runtime="$test_tmp/empty-runtime"
mkdir -p "$empty_runtime"

: >"$call_log"
FAIL_USER_BUS=true XDG_RUNTIME_DIR="$empty_runtime" env -u DBUS_SESSION_BUS_ADDRESS "$ROOT/bin/omarchy-system-reboot"
grep -Fq "systemd-run --user --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms systemctl reboot --no-wall" "$call_log" ||
  fail "reboot still tries the user manager first" "$(cat "$call_log")"
grep -Fq "systemd-run --system --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms systemctl reboot --no-wall" "$call_log" ||
  fail "reboot falls back to the system manager without a user bus" "$(cat "$call_log")"
grep -Fq "omarchy-hyprland-window-close-all" "$call_log" ||
  fail "reboot still closes windows after the system-manager fallback"
pass "reboot falls back to the system manager without a user bus"

: >"$call_log"
FAIL_USER_BUS=true XDG_RUNTIME_DIR="$empty_runtime" env -u DBUS_SESSION_BUS_ADDRESS "$ROOT/bin/omarchy-system-shutdown" ||
  fail "shutdown service is scheduled without a user bus"
grep -q '^systemd-run --user --collect --quiet --property=Type=exec --property=RuntimeMaxSec=30s .* --inhibit$' "$call_log" ||
  fail "shutdown still tries the user manager first" "$(cat "$call_log")"
grep -q '^systemd-run --system --collect --quiet --property=Type=exec --property=RuntimeMaxSec=30s .* --inhibit$' "$call_log" ||
  fail "shutdown falls back to the system manager without a user bus" "$(cat "$call_log")"
pass "shutdown falls back to the system manager without a user bus"

for action in reboot shutdown; do
  : >"$call_log"
  rm -f "$CALL_LOG.grace"
  FAIL_USER_BUS=true env -u XDG_RUNTIME_DIR -u DBUS_SESSION_BUS_ADDRESS "$ROOT/bin/omarchy-system-$action"
  [[ $(<"$CALL_LOG.bus") == /run/user/$(id -u)* ]] ||
    fail "$action restores XDG_RUNTIME_DIR for the user manager" "$(cat "$CALL_LOG.bus")"
  pass "$action restores XDG_RUNTIME_DIR for the user manager"
done

bus_runtime="$test_tmp/session-runtime"
mkdir -p "$bus_runtime"
# Some sandboxes deny binding a Unix socket, so skip only the case that needs one.
if ! command -v python3 >/dev/null ||
  ! python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' "$bus_runtime/bus" 2>/dev/null; then
  skip "cannot bind a Unix socket here; skipping session bus reconstruction"
  exit 0
fi

for action in reboot shutdown; do
  : >"$call_log"
  rm -f "$CALL_LOG.grace"
  XDG_RUNTIME_DIR="$bus_runtime" env -u DBUS_SESSION_BUS_ADDRESS "$ROOT/bin/omarchy-system-$action"
  [[ $(<"$CALL_LOG.bus") == "$bus_runtime unix:path=$bus_runtime/bus" ]] ||
    fail "$action reconstructs the session bus from XDG_RUNTIME_DIR/bus" "$(cat "$CALL_LOG.bus")"
  ! grep -q '^systemd-run --system' "$call_log" ||
    fail "$action does not use the system manager when the session bus socket exists" "$(cat "$call_log")"
  pass "$action reconstructs the session bus from XDG_RUNTIME_DIR/bus"
done
