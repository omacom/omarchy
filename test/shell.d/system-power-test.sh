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

for command in omarchy-session omarchy-state omarchy-hyprland-window-close-all sleep; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash

printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
if [[ $(basename "$0") == omarchy-session && ${FAIL_SESSION:-false} == true ]]; then exit 1; fi
SH
done
cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

run_power_command() {
  local action="$1"

  : >"$call_log"
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-$action"
}

assert_power_calls() {
  local action="$1"
  local systemctl_action="$2"
  local expected_log="$test_tmp/$action-expected.log"

  cat >"$expected_log" <<EOF
omarchy-session prepare-exit
systemd-run --user --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms systemctl $systemctl_action --no-wall
omarchy-state clear re*-required
omarchy-hyprland-window-close-all 
sleep 1
EOF

  diff -u "$expected_log" "$call_log" || fail "$action runs after being scheduled outside the terminal scope"
  pass "$action runs after being scheduled outside the terminal scope"
}

run_power_command reboot
assert_power_calls reboot reboot

run_power_command shutdown
assert_power_calls shutdown poweroff

for action in reboot shutdown; do
  : >"$call_log"
  if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" FAIL_SYSTEMD_RUN=true "$ROOT/bin/omarchy-system-$action"; then
    fail "$action aborts when scheduling fails"
  fi

  if (( $(wc -l <"$call_log") != 3 )) || ! tail -1 "$call_log" | grep -qxF "omarchy-session cancel-exit"; then
    fail "$action leaves state and windows alone when scheduling fails"
  fi
  pass "$action leaves state and windows alone when scheduling fails"
done

FAIL_SESSION=true run_power_command reboot
assert_power_calls reboot reboot
pass "a failed session save cannot prevent reboot"
