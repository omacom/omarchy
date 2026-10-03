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
if [[ ${1:-} == "--user" ]]; then
  [[ ${FAIL_USER_BUS:-false} == "true" ]] && exit 1
  [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} && -n ${XDG_RUNTIME_DIR:-} ]] || exit 1
fi
exit 0
SH

for command in omarchy-state omarchy-hyprland-window-close-all sleep; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash

printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done
chmod +x "$mock_bin"/*

run_power_command() {
  local action="$1"

  : >"$call_log"
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" \
    XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$test_tmp/runtime}" \
    DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$test_tmp/runtime/bus}" \
    "$ROOT/bin/omarchy-system-$action"
}

assert_power_calls() {
  local action="$1"
  local systemctl_action="$2"
  local expected_log="$test_tmp/$action-expected.log"

  cat >"$expected_log" <<EOF
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
  if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" FAIL_SYSTEMD_RUN=true \
    XDG_RUNTIME_DIR="$test_tmp/runtime" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=$test_tmp/runtime/bus" \
    "$ROOT/bin/omarchy-system-$action"; then
    fail "$action aborts when scheduling fails"
  fi

  if (( $(wc -l <"$call_log") != 2 )); then
    fail "$action leaves state and windows alone when scheduling fails" "$(cat "$call_log")"
  fi
  pass "$action leaves state and windows alone when scheduling fails"
done

empty_runtime="$test_tmp/empty-runtime"
mkdir -p "$empty_runtime"

for action in reboot shutdown; do
  unit=reboot
  [[ $action == shutdown ]] && unit=poweroff

  : >"$call_log"
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" FAIL_USER_BUS=true \
    XDG_RUNTIME_DIR="$empty_runtime" \
    env -u DBUS_SESSION_BUS_ADDRESS \
    "$ROOT/bin/omarchy-system-$action"

  grep -Fq "systemd-run --user --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms systemctl $unit --no-wall" "$call_log" ||
    fail "$action still tries the user manager first" "$(cat "$call_log")"
  grep -Fq "systemd-run --system --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms systemctl $unit --no-wall" "$call_log" ||
    fail "$action falls back to the system manager without a user bus" "$(cat "$call_log")"
  grep -Fq "omarchy-hyprland-window-close-all" "$call_log" ||
    fail "$action still closes windows after the system-manager fallback"
  pass "$action falls back to the system manager without a user bus"
done

bus_runtime="$test_tmp/session-runtime"
mkdir -p "$bus_runtime"
python3 -c 'import os, socket, sys
path = sys.argv[1]
if os.path.exists(path):
    os.unlink(path)
sock = socket.socket(socket.AF_UNIX)
sock.bind(path)
' "$bus_runtime/bus"

: >"$call_log"
PATH="$mock_bin:$PATH" CALL_LOG="$call_log" \
  XDG_RUNTIME_DIR="$bus_runtime" \
  env -u DBUS_SESSION_BUS_ADDRESS \
  "$ROOT/bin/omarchy-system-reboot"

grep -Fq 'systemd-run --user --collect --quiet --on-active=2s --timer-property=AccuracySec=100ms systemctl reboot --no-wall' "$call_log" ||
  fail "reboot reconstructs the session bus from XDG_RUNTIME_DIR/bus" "$(cat "$call_log")"
grep -Fq 'systemd-run --system' "$call_log" &&
  fail "reboot does not use the system manager when the session bus socket exists" "$(cat "$call_log")"
pass "reboot reconstructs the session bus from XDG_RUNTIME_DIR/bus"
