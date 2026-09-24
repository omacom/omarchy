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
[[ ${FAIL_INHIBIT:-false} == "true" ]] && exit 1
while [[ $1 == --* ]]; do shift; done
touch "$CALL_LOG.inhibited"
trap 'rm -f "$CALL_LOG.inhibited"' EXIT
"$@"
SH

for command in omarchy-state omarchy-hyprland-window-close-all omarchy-osd sleep systemctl; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash

command=${0##*/}
printf '%s %s\n' "$command" "$*" >>"$CALL_LOG"
case $command in
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
grep -q '^systemd-run --user --collect --quiet --property=Type=exec --property=RuntimeMaxSec=30s systemd-inhibit ' "$CALL_LOG" || fail "shutdown uses a bounded service outside the launching terminal"
bash "$CALL_LOG.worker" || fail "protected shutdown succeeds"
grep -q '^systemd-inhibit --what=sleep:idle:handle-lid-switch .* --mode=block .* --inhibited$' "$CALL_LOG" || fail "shutdown blocks sleep and lid handling"
inhibit_line=$(grep -n '^systemd-inhibit ' "$CALL_LOG" | cut -d: -f1)
osd_line=$(grep -n '^omarchy-osd ' "$CALL_LOG" | cut -d: -f1)
(( inhibit_line < osd_line )) || fail "inhibition precedes preparation"
grep -q '^omarchy-state clear re\*-required$' "$CALL_LOG" || fail "shutdown clears restart state"
grep -q '^omarchy-hyprland-window-close-all ' "$CALL_LOG" || fail "shutdown closes windows"
grep -q '^systemctl poweroff --no-wall$' "$CALL_LOG" || fail "poweroff runs after the grace period while inhibited"
[[ ! -f $CALL_LOG.inhibited ]] || fail "accepted poweroff releases inhibition"
pass "shutdown stays inhibited through preparation and the poweroff request"

for action in reboot shutdown; do
  : >"$call_log"
  if FAIL_SYSTEMD_RUN=true "$ROOT/bin/omarchy-system-$action"; then
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
  if env "$failure=true" bash "$CALL_LOG.worker"; then
    fail "$failure propagates to the service"
  fi
  [[ ! -f $CALL_LOG.inhibited ]] || fail "$failure releases inhibition"
  if [[ $failure == "FAIL_INHIBIT" ]]; then
    (( $(wc -l <"$call_log") == 1 )) || fail "inhibitor failure leaves applications alone"
  else
    grep -q '^systemctl poweroff --no-wall$' "$CALL_LOG" || fail "rejection test reaches poweroff"
  fi
  pass "$failure leaves no inhibitor behind"
done
