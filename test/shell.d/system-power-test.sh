#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash

printf 'systemd-run %s\n' "$*" >>"$CALL_LOG"
[[ ${FAIL_SYSTEMD_RUN:-false} == "true" ]] && exit 1
exit 0
SH

# uwsm and systemctl are what a real systemd-run would execute. Stub them so a
# test run cannot stop the session or reboot the machine, and so the expected
# log fails if the script starts calling them directly.
for command in omarchy-state omarchy-hyprland-window-close-all sleep omarchy-osd uwsm systemctl; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash

printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done
chmod +x "$mock_bin"/*

run_power_command() {
  local action="$1"

  : >"$call_log"
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-$action"
}

assert_power_calls() {
  local action="$1"
  local systemctl_action="$2"
  local osd_message="$3"
  local expected_log="$test_tmp/$action-expected.log"

  cat >"$expected_log" <<EOF
systemd-run --user --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms systemctl $systemctl_action --no-wall
omarchy-osd -i $action -m $osd_message -d 5000
omarchy-state clear re*-required
omarchy-hyprland-window-close-all 
sleep 1
EOF

  diff -u "$expected_log" "$call_log" || fail "$action runs after being scheduled outside the terminal scope"
  pass "$action runs after being scheduled outside the terminal scope"
}

run_power_command reboot
assert_power_calls reboot reboot Rebooting

run_power_command shutdown
assert_power_calls shutdown poweroff "Shutting down"

run_power_command logout
cat >"$test_tmp/logout-expected.log" <<EOF
systemd-run --user --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms uwsm stop
omarchy-osd -i logout -m Logging out -d 5000
omarchy-hyprland-window-close-all 
sleep 1
EOF
diff -u "$test_tmp/logout-expected.log" "$call_log" || fail "logout runs after being scheduled outside the terminal scope"
pass "logout runs after being scheduled outside the terminal scope"

for action in reboot shutdown logout; do
  : >"$call_log"
  if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" FAIL_SYSTEMD_RUN=true "$ROOT/bin/omarchy-system-$action"; then
    fail "$action aborts when scheduling fails"
  fi

  if (( $(wc -l <"$call_log") != 1 )); then
    fail "$action leaves state and windows alone when scheduling fails"
  fi
  pass "$action leaves state and windows alone when scheduling fails"
done
