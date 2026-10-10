#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
mkdir -p "$mock_bin"
export PATH="$mock_bin:$PATH" CALL_LOG="$call_log" OMARCHY_PATH="$ROOT"

cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash

printf 'systemd-run %s\n' "$*" >>"$CALL_LOG"
[[ ${FAIL_SYSTEMD_RUN:-false} == "true" ]] && exit 1
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
  omarchy-osd)
    if [[ ${BLOCK_OSD:-false} == "true" ]]; then
      touch "$CALL_LOG.osd-blocked"
      for (( attempt = 0; attempt < 200; attempt++ )); do
        if [[ -f $CALL_LOG.power-request ]]; then
          touch "$CALL_LOG.osd-finished"
          exit 0
        fi
        /usr/bin/sleep 0.01
      done
      touch "$CALL_LOG.osd-timeout"
      exit 1
    fi
    ;;
  omarchy-hyprland-window-close-all)
    if [[ ${BLOCK_WINDOW_CLOSE:-false} == "true" ]]; then
      for (( attempt = 0; attempt < 200; attempt++ )); do
        if [[ -f $CALL_LOG.power-request ]]; then
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
        if grep -q '^omarchy-hyprland-window-close-all ' "$CALL_LOG" &&
          grep -q '^omarchy-osd ' "$CALL_LOG" &&
          { [[ ${BLOCK_OSD:-false} != "true" ]] || [[ -f $CALL_LOG.osd-blocked ]]; }; then
          break
        fi
        /usr/bin/sleep 0.01
      done
      touch "$CALL_LOG.grace"
    fi
    ;;
  systemctl)
    [[ $* == "$POWER_COMMAND --no-wall" && -f $CALL_LOG.inhibited && -f $CALL_LOG.grace ]] || exit 2
    if [[ ${BLOCK_OSD:-false} == "true" ]]; then
      grep -q '^omarchy-state clear re\*-required$' "$CALL_LOG" || exit 3
      grep -q '^omarchy-hyprland-window-close-all ' "$CALL_LOG" || exit 3
      [[ -f $CALL_LOG.osd-blocked && ! -f $CALL_LOG.osd-finished && ! -f $CALL_LOG.osd-timeout ]] || exit 3
    fi
    touch "$CALL_LOG.power-request"
    [[ ${FAIL_POWER_REQUEST:-false} != "true" ]]
    ;;
esac
SH
done
chmod +x "$mock_bin"/*

run_power_command() {
  local action="$1"

  : >"$call_log"
  rm -f "$CALL_LOG".*
  "$ROOT/bin/omarchy-system-$action"
}

for action in shutdown reboot; do
  if [[ $action == "shutdown" ]]; then
    export POWER_COMMAND=poweroff
    title="Shutdown"
    message="Shutting down"
  else
    export POWER_COMMAND=reboot
    title="Reboot"
    message="Rebooting"
  fi

  run_power_command "$action" || fail "$action service is scheduled"
  grep -q '^systemd-run --user --collect --quiet --property=Type=exec --property=RuntimeMaxSec=30s .* --inhibit$' "$CALL_LOG" || fail "$action uses a bounded service outside the launching terminal"
  bash "$CALL_LOG.worker" || fail "protected $action succeeds"
  grep -q '^systemd-inhibit --what=sleep:idle:handle-lid-switch .* --mode=block .* --inhibited$' "$CALL_LOG" || fail "$action blocks sleep and lid handling"
  inhibit_line=$(grep -n '^systemd-inhibit ' "$CALL_LOG" | cut -d: -f1)
  osd_line=$(grep -n '^omarchy-osd ' "$CALL_LOG" | cut -d: -f1)
  grep -Fqx "omarchy-osd -i $action -m $message -d 5000" "$CALL_LOG" || fail "$action shows its progress message"
  (( inhibit_line < osd_line )) || fail "inhibition precedes preparation"
  grep -q '^omarchy-state clear re\*-required$' "$CALL_LOG" || fail "$action clears restart state"
  grep -q '^omarchy-hyprland-window-close-all ' "$CALL_LOG" || fail "$action closes windows"
  grep -q "^systemctl $POWER_COMMAND --no-wall$" "$CALL_LOG" || fail "$POWER_COMMAND runs after the grace period while inhibited"
  [[ ! -f $CALL_LOG.inhibited ]] || fail "accepted $POWER_COMMAND releases inhibition"
  ! grep -q '^omarchy-notification-send ' "$CALL_LOG" || fail "successful $action sends no failure notification"
  pass "$action stays inhibited through preparation and the $POWER_COMMAND request"

  : >"$call_log"
  rm -f "$CALL_LOG.grace" "$CALL_LOG.power-request"
  # Dev link/unlink can leave the user manager pointing at a removed checkout.
  OMARCHY_PATH="$test_tmp/removed-checkout" bash "$CALL_LOG.worker" || fail "$action uses its own script when the service environment is stale"
  [[ -f $CALL_LOG.power-request ]] || fail "$action reaches $POWER_COMMAND with a stale service environment"
  [[ ! -f $CALL_LOG.inhibited ]] || fail "$action releases inhibition with a stale service environment"
  ! grep -q '^omarchy-notification-send ' "$CALL_LOG" || fail "stale service environment sends no failure notification"
  pass "$action uses its own script when the service environment is stale"

  : >"$call_log"
  rm -f "$CALL_LOG.grace" "$CALL_LOG.power-request"
  BLOCK_WINDOW_CLOSE=true bash "$CALL_LOG.worker" || fail "$action proceeds while window closing is blocked"
  for (( attempt = 0; attempt < 200; attempt++ )); do
    [[ -f $CALL_LOG.close-finished || -f $CALL_LOG.close-timeout ]] && break
    /usr/bin/sleep 0.01
  done
  [[ -f $CALL_LOG.close-finished && ! -f $CALL_LOG.close-timeout ]] || fail "$POWER_COMMAND releases the blocked window helper before its timeout"
  pass "blocked window closing cannot delay $POWER_COMMAND"

  : >"$call_log"
  if FAIL_SYSTEMD_RUN=true "$ROOT/bin/omarchy-system-$action"; then
    fail "$action aborts when scheduling fails"
  fi

  if (( $(wc -l <"$call_log") != 1 )); then
    fail "$action leaves state and windows alone when scheduling fails"
  fi
  pass "$action leaves state and windows alone when scheduling fails"

  for failure in FAIL_INHIBIT FAIL_POWER_REQUEST; do
    : >"$call_log"
    rm -f "$CALL_LOG.grace"
    env "$failure=true" bash "$CALL_LOG.worker"
    status=$?
    expected_status=1
    [[ $failure == "FAIL_INHIBIT" ]] && expected_status=17
    if (( status != expected_status )); then
      fail "$action $failure propagates to the service"
    fi
    grep -Fqx "omarchy-notification-send -u critical $title failed Could not complete $action. Please try again." "$CALL_LOG" || fail "$action $failure notifies the user"
    [[ ! -f $CALL_LOG.inhibited ]] || fail "$action $failure releases inhibition"
    if [[ $failure == "FAIL_INHIBIT" ]]; then
      (( $(wc -l <"$call_log") == 2 )) || fail "inhibitor failure leaves applications alone"
    else
      grep -q "^systemctl $POWER_COMMAND --no-wall$" "$CALL_LOG" || fail "rejection test reaches $POWER_COMMAND"
    fi
    pass "$action $failure notifies the user and leaves no inhibitor behind"
  done

  : >"$call_log"
  FAIL_INHIBIT=true FAIL_NOTIFICATION=true bash "$CALL_LOG.worker"
  [[ $? == 17 ]] || fail "notification failure preserves the $action error"
  pass "notification failure preserves the $action error"
done

export POWER_COMMAND=reboot
run_power_command reboot || fail "reboot service is scheduled with a stalled OSD"
BLOCK_OSD=true bash "$CALL_LOG.worker" || fail "reboot prepares applications while its OSD is stalled"
for (( attempt = 0; attempt < 200; attempt++ )); do
  [[ -f $CALL_LOG.osd-finished || -f $CALL_LOG.osd-timeout ]] && break
  /usr/bin/sleep 0.01
done
[[ -f $CALL_LOG.osd-finished && ! -f $CALL_LOG.osd-timeout ]] || fail "reboot completes before the stalled OSD times out"
! grep -q '^omarchy-notification-send ' "$CALL_LOG" || fail "a stalled OSD does not report reboot failure"
pass "reboot clears state and requests window closing before reboot even while its OSD is stalled"
