#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
mkdir -p "$mock_bin"
export PATH="$mock_bin:$PATH" CALL_LOG="$call_log" OMARCHY_PATH="$ROOT"
export HYPRLAND_INSTANCE_SIGNATURE="test-session"
export EXPECTED_PATH="$PATH" EXPECTED_OMARCHY_PATH="$OMARCHY_PATH"

cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash

printf 'systemd-run %s\n' "$*" >>"$CALL_LOG"
[[ ${FAIL_SYSTEMD_RUN:-false} == "true" ]] && exit 1
forwarded=()
while [[ $1 == --* ]]; do
  if [[ $1 == --setenv=* ]]; then
    name=${1#--setenv=}
    forwarded+=("$name=${!name}")
  fi
  shift
done
# Capture the service command so its exit status is tested separately.
printf '%q ' /usr/bin/env "${forwarded[@]}" "$@" >"$CALL_LOG.worker"
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

for command in uwsm omarchy-state omarchy-hyprland-window-close-all omarchy-osd omarchy-shell omarchy-notification-send sleep timeout systemctl; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash

command=${0##*/}
printf '%s %s\n' "$command" "$*" >>"$CALL_LOG"
case $command in
  omarchy-osd)
    [[ $PATH == "$EXPECTED_PATH" && $OMARCHY_PATH == "$EXPECTED_OMARCHY_PATH" && $HYPRLAND_INSTANCE_SIGNATURE == "test-session" ]] || exit 38
    touch "$CALL_LOG.environment"
    ;;
  omarchy-hyprland-window-close-all)
    if [[ ${BLOCK_WINDOW_CLOSE:-false} == "true" ]]; then
      /usr/bin/sleep 10
    fi
    ;;
  sleep)
    if [[ $1 == "0.500" ]]; then
      /usr/bin/sleep 0.05
      touch "$CALL_LOG.fade"
    else
      /usr/bin/sleep 0.3
    fi
    ;;
  omarchy-shell)
    if [[ $1 == "shell" && $2 == "showShutdownCover" && -n ${SHUTDOWN_COVER_MS:-} ]]; then
      echo "$SHUTDOWN_COVER_MS"
    fi
    ;;
  omarchy-notification-send)
    [[ ${FAIL_NOTIFICATION:-false} != "true" ]] || exit 42
    ;;
  timeout)
    [[ $1 == "2s" ]] || exit 2
    shift
    /usr/bin/timeout 0.2s "$@"
    status=$?
    touch "$CALL_LOG.grace"
    exit "$status"
    ;;
  uwsm | systemctl)
    [[ -f $CALL_LOG.grace ]] || exit 2
    if [[ ${SHUTDOWN_COVER_MS:-0} =~ ^[1-9][0-9]*$ ]]; then
      [[ -f $CALL_LOG.fade ]] || exit 2
    fi
    if [[ $1 == "poweroff" ]]; then
      [[ -f $CALL_LOG.inhibited ]] || exit 2
    fi
    touch "$CALL_LOG.poweroff"
    [[ ${FAIL_POWEROFF:-false} != "true" && ${FAIL_EXIT:-false} != "true" ]]
    ;;
esac
SH
done
chmod +x "$mock_bin"/*

run_power_command() {
  local action="$1"

  : >"$call_log"
  rm -f "$CALL_LOG.grace" "$CALL_LOG.worker" "$CALL_LOG.environment"
  "$ROOT/bin/omarchy-system" "$action"
}

# The OSD waits so a quick exit doesn't flash it, and the exit never waits for the OSD.
assert_delayed_osd() {
  local label="$1" exit_line osd_line
  exit_line=$(grep -n -m1 -E '^(systemctl|uwsm) ' "$CALL_LOG" | cut -d: -f1)
  osd_line=$(grep -n -m1 '^omarchy-osd ' "$CALL_LOG" | cut -d: -f1)
  grep -q '^sleep 2$' "$CALL_LOG" && (( exit_line < osd_line )) || fail "$label shows its OSD only after the exit request"
}

for action in reboot logout; do
  run_power_command "$action" || fail "$action service is scheduled"
  (( $(wc -l <"$call_log") == 1 )) || fail "$action preparation runs outside the launching terminal"
  [[ -s $CALL_LOG.worker ]] || fail "$action schedules its worker"
  grep -q -- '--property=RuntimeMaxSec=30s' "$CALL_LOG" || fail "$action bounds the worker lifetime"
  PATH=/stale/bin OMARCHY_PATH=/stale/checkout HYPRLAND_INSTANCE_SIGNATURE=stale /bin/bash "$CALL_LOG.worker" || fail "$action worker succeeds"
  [[ -f $CALL_LOG.environment ]] || fail "$action forwards the caller environment over stale manager values"
  grep -q '^timeout 2s omarchy-hyprland-window-close-all --wait$' "$CALL_LOG" || fail "$action waits for application exit with a deadline"
  assert_delayed_osd "$action"
  rm -f "$CALL_LOG.grace"
  BLOCK_WINDOW_CLOSE=true bash "$CALL_LOG.worker" || fail "$action proceeds after the close deadline"
  ! grep -q '^omarchy-notification-send ' "$CALL_LOG" || fail "$action does not report a close timeout as failure"
  : >"$call_log"
  rm -f "$CALL_LOG.grace"
  if FAIL_EXIT=true bash "$CALL_LOG.worker"; then
    fail "$action propagates a rejected exit request"
  fi
  grep -q "^omarchy-notification-send -u critical ${action^} failed " "$CALL_LOG" || fail "$action reports a rejected exit request"
  ! grep -q '^omarchy-osd ' "$CALL_LOG" || fail "$action shows no OSD when the exit is rejected quickly"
  grep -q '^omarchy-shell -q osd close$' "$CALL_LOG" || fail "$action closes its OSD when the exit is rejected"
  if [[ $action == "logout" ]]; then
    ! grep -q 'showShutdownCover\|hideShutdownCover' "$CALL_LOG" || fail "logout does not show or hide the shutdown cover"
  else
    grep -q '^omarchy-shell shell showShutdownCover$' "$CALL_LOG" || fail "$action shows the shutdown cover"
    ! grep -q '^omarchy-shell -q shell hideShutdownCover$' "$CALL_LOG" || fail "$action skips hiding the cover when the shell did not show one"
  fi
  pass "$action waits outside the launching terminal and delays its OSD"
done

run_power_command shutdown || fail "shutdown service is scheduled"
grep -q '^systemd-run --user --collect --quiet --property=Type=exec --property=RuntimeMaxSec=30s .* shutdown --execute$' "$CALL_LOG" || fail "shutdown uses a bounded service outside the launching terminal"
PATH=/stale/bin OMARCHY_PATH=/stale/checkout HYPRLAND_INSTANCE_SIGNATURE=stale /bin/bash "$CALL_LOG.worker" || fail "protected shutdown succeeds"
[[ -f $CALL_LOG.environment ]] || fail "shutdown forwards the caller environment over stale manager values"
grep -q '^systemd-inhibit --what=sleep:idle:handle-lid-switch .* --mode=block .* --inhibited$' "$CALL_LOG" || fail "shutdown blocks sleep and lid handling"
inhibit_line=$(grep -n '^systemd-inhibit ' "$CALL_LOG" | cut -d: -f1)
osd_line=$(grep -n '^omarchy-osd ' "$CALL_LOG" | cut -d: -f1)
(( inhibit_line < osd_line )) || fail "inhibition precedes preparation"
grep -q '^omarchy-state clear re\*-required$' "$CALL_LOG" || fail "shutdown clears restart state"
grep -q '^timeout 2s omarchy-hyprland-window-close-all --wait$' "$CALL_LOG" || fail "shutdown waits for applications with a deadline"
assert_delayed_osd shutdown
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
[[ -f $CALL_LOG.poweroff ]] || fail "poweroff follows the window-close deadline"
! grep -q '^omarchy-notification-send ' "$CALL_LOG" || fail "shutdown does not report a close timeout as failure"
pass "blocked window closing cannot prevent poweroff"

for action in reboot shutdown logout; do
  : >"$call_log"
  if FAIL_SYSTEMD_RUN=true "$ROOT/bin/omarchy-system" "$action"; then
    fail "$action aborts when scheduling fails"
  fi

  if (( $(wc -l <"$call_log") != 1 )); then
    fail "$action leaves state and windows alone when scheduling fails"
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

for action in logout reboot shutdown; do
  for route in "$action" "system $action"; do
    : >"$call_log"
    read -ra args <<<"$route"
    "$ROOT/bin/omarchy" "${args[@]}" || fail "$route dispatches"
    grep -q "omarchy-system $action --execute$" "$call_log" || fail "$route forwards the action"
    : >"$call_log"
    "$ROOT/bin/omarchy" "${args[@]}" --help >/dev/null || fail "$route help succeeds"
    [[ ! -s $call_log ]] || fail "$route help never schedules a session exit"
  done
  pass "$action aliases and system routes forward the action safely"
done

for action in logout reboot shutdown; do
  : >"$call_log"
  "$ROOT/bin/omarchy-system" "$action" --help >/dev/null || fail "direct $action help succeeds"
  if "$ROOT/bin/omarchy-system" "$action" --typo >/dev/null 2>&1; then
    fail "direct $action rejects an unknown mode"
  fi
  if "$ROOT/bin/omarchy-system" "$action" --execute unexpected >/dev/null 2>&1; then
    fail "direct $action rejects extra arguments"
  fi
  [[ ! -s $call_log ]] || fail "direct $action help and invalid arguments never schedule an exit"
  pass "direct $action help and invalid arguments are safe"
done
"$ROOT/bin/omarchy" system lock --help | grep -q 'omarchy-system-lock' || fail "system lock remains routed to its own command"
pass "existing system subcommands keep their routes"

cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash

printf 'busctl %s\n' "$*" >>"$CALL_LOG"
printf 's "%s"\n' "${FIRMWARE_SETUP:-yes}"
SH
chmod +x "$mock_bin/busctl"
run_power_command firmware || fail "firmware reboot service is scheduled"
if FIRMWARE_SETUP=no bash "$CALL_LOG.worker"; then
  fail "firmware reboot fails without firmware setup support"
fi
! grep -q 'omarchy-hyprland-window-close-all' "$CALL_LOG" || fail "unsupported firmware reboot leaves applications open"
! grep -q 'showShutdownCover' "$CALL_LOG" || fail "unsupported firmware reboot never shows the shutdown cover"
grep -q '^omarchy-notification-send -u critical Reboot to BIOS failed ' "$CALL_LOG" || fail "unsupported firmware reboot is reported"
: >"$call_log"
rm -f "$CALL_LOG.fade" "$CALL_LOG.grace"
FIRMWARE_SETUP=yes SHUTDOWN_COVER_MS=400 bash "$CALL_LOG.worker" || fail "supported firmware reboot waits for the shutdown cover fade before rebooting"
grep -q '^omarchy-shell shell showShutdownCover$' "$CALL_LOG" || fail "firmware reboot shows the shutdown cover"
! grep -q '^sleep 2$' "$CALL_LOG" && ! grep -q '^omarchy-osd ' "$CALL_LOG" || fail "firmware reboot skips the delayed OSD when the shutdown cover is shown"
grep -q '^systemctl reboot --firmware-setup --no-wall$' "$CALL_LOG" || fail "firmware reboot asks for the firmware setup"
: >"$call_log"
rm -f "$CALL_LOG.fade" "$CALL_LOG.grace"
if FIRMWARE_SETUP=yes SHUTDOWN_COVER_MS=400 FAIL_EXIT=true bash "$CALL_LOG.worker"; then
  fail "rejected firmware reboot with cover propagates failure"
fi
grep -q '^omarchy-shell -q shell hideShutdownCover$' "$CALL_LOG" || fail "rejected exit hides the shutdown cover when shown"
pass "firmware reboot checks support before closing applications"
