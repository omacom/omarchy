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

for command in uwsm omarchy-state omarchy-hyprland-window-close-all omarchy-osd omarchy-notification-send sleep timeout systemctl; do
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

for action in reboot logout; do
  run_power_command "$action" || fail "$action service is scheduled"
  (( $(wc -l <"$call_log") == 1 )) || fail "$action preparation runs outside the launching terminal"
  [[ -s $CALL_LOG.worker ]] || fail "$action schedules its worker"
  grep -q -- '--property=RuntimeMaxSec=30s' "$CALL_LOG" || fail "$action bounds the worker lifetime"
  PATH=/stale/bin OMARCHY_PATH=/stale/checkout HYPRLAND_INSTANCE_SIGNATURE=stale /bin/bash "$CALL_LOG.worker" || fail "$action worker succeeds"
  [[ -f $CALL_LOG.environment ]] || fail "$action forwards the caller environment over stale manager values"
  grep -q '^timeout 2s omarchy-hyprland-window-close-all --wait$' "$CALL_LOG" || fail "$action waits for application exit with a deadline"
  ! grep -q '^sleep ' "$CALL_LOG" || fail "$action has no fixed sleep"
  rm -f "$CALL_LOG.grace"
  BLOCK_WINDOW_CLOSE=true bash "$CALL_LOG.worker" || fail "$action proceeds after the close deadline"
  ! grep -q '^omarchy-notification-send ' "$CALL_LOG" || fail "$action does not report a close timeout as failure"
  rm -f "$CALL_LOG.grace"
  if FAIL_EXIT=true bash "$CALL_LOG.worker"; then
    fail "$action propagates a rejected exit request"
  fi
  grep -q "^omarchy-notification-send -u critical ${action^} failed " "$CALL_LOG" || fail "$action reports a rejected exit request"
  pass "$action waits outside the launching terminal without a fixed delay"
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
! grep -q '^sleep ' "$CALL_LOG" || fail "shutdown has no fixed sleep"
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

# Last: this overwrites the shared worker file the sections above reuse.
run_power_command reboot-boot-menu || fail "reboot-boot-menu service is scheduled"
[[ -s $CALL_LOG.worker ]] || fail "reboot-boot-menu schedules its worker"
PATH=/stale/bin OMARCHY_PATH=/stale/checkout HYPRLAND_INSTANCE_SIGNATURE=stale /bin/bash "$CALL_LOG.worker" || fail "reboot-boot-menu worker succeeds"
grep -q '^systemctl reboot --boot-loader-menu=0 --no-wall$' "$call_log" || fail "reboot-boot-menu asks systemd for the boot loader menu"
grep -q '^omarchy-state clear re\*-required$' "$call_log" || fail "reboot-boot-menu clears restart state"
pass "reboot-boot-menu reboots into the boot loader menu through the graceful session exit"
