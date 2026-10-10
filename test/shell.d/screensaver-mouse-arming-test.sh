#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

screensaver="$ROOT/bin/omarchy-screensaver"
arm=$'\e[?1003h\e[?1006h'
disarm=$'\e[?1003l\e[?1006l'

test_tmp=$(mktemp -d)
screensaver_pid=""

cleanup() {
  [[ -n $screensaver_pid ]] && kill "$screensaver_pid" 2>/dev/null
  [[ -f $test_tmp/ttfx.pids ]] && xargs -r kill <"$test_tmp/ttfx.pids" 2>/dev/null
  rm -rf "$test_tmp"
}
trap cleanup EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Hyprland reports however many monitors and mapped screensavers the test has
# put in the state files, and logs each query so polling can be observed.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$TEST_DIR/hyprctl.log"
case "$1" in
  monitors)
    jq -n --argjson n "$(cat "$TEST_DIR/monitors")" '[range($n) | {id: .}]'
    ;;
  clients)
    jq -n --argjson n "$(cat "$TEST_DIR/screensavers")" \
      '[range($n) | {mapped: true, class: "org.omarchy.screensaver"}] + [{mapped: true, class: "foot"}]'
    ;;
  activewindow)
    echo '{"class": "org.omarchy.screensaver"}'
    ;;
esac
SH

# A renderer that stays up, so the read loop is what decides when to exit.
cat >"$stub_bin/ttfx" <<'SH'
#!/bin/bash

echo $$ >>"$TEST_DIR/ttfx.pids"
exec sleep 30
SH

cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash

exit 0
SH

# Stubbed so teardown cannot kill a real screensaver or renderer.
cat >"$stub_bin/pkill" <<'SH'
#!/bin/bash

printf 'pkill %s\n' "$*" >>"$TEST_DIR/pkill.log"
SH

# Already at fullscreen size, so the resize wait returns at once.
cat >"$stub_bin/stty" <<'SH'
#!/bin/bash

echo "50 200"
SH

chmod +x "$stub_bin"/*

# Starts the screensaver with its keyboard on a FIFO the test writes to.
start_screensaver() {
  local monitors="$1" screensavers="$2"
  rm -f "$test_tmp"/*.log "$test_tmp/out" "$test_tmp/keys"
  printf '%s' "$monitors" >"$test_tmp/monitors"
  printf '%s' "$screensavers" >"$test_tmp/screensavers"
  : >"$test_tmp/hyprctl.log"
  mkfifo "$test_tmp/keys"
  exec 3<>"$test_tmp/keys"

  TEST_DIR="$test_tmp" PATH="$stub_bin:$PATH" HOME="$test_tmp" \
    bash "$screensaver" <"$test_tmp/keys" >"$test_tmp/out" 2>/dev/null &
  screensaver_pid=$!
}

armed() {
  [[ $(cat "$test_tmp/out") == *"$arm"* ]]
}

# Polls in 0.1s steps so slow machines pass without slowing fast ones.
wait_until() {
  local tenths="$1"
  shift
  local i
  for ((i = 0; i < tenths; i++)); do
    "$@" && return 0
    sleep 0.1
  done
  "$@"
}

screensaver_exited() {
  ! kill -0 "$screensaver_pid" 2>/dev/null
}

press_key_and_wait_for_exit() {
  printf 'x' >&3
  wait_until 30 screensaver_exited || fail "a keypress dismisses the screensaver"
  wait "$screensaver_pid" 2>/dev/null || true
  screensaver_pid=""
  exec 3>&-
}

# Two monitors with only one screensaver mapped: the launcher is still warping
# the pointer between them, so arming now would dismiss on its own warp.
start_screensaver 2 1
sleep 1.5
! armed || fail "mouse reporting waits for a screensaver on every monitor" "$(cat -v "$test_tmp/out")"

printf '2' >"$test_tmp/screensavers"
mapped_at=$SECONDS
wait_until 30 armed || fail "mouse reporting arms once every monitor has a screensaver" "$(cat -v "$test_tmp/out")"
pass "mouse reporting arms once every monitor has a screensaver"

press_key_and_wait_for_exit
[[ $(cat "$test_tmp/out") == *"$arm"*"$disarm"* ]] ||
  fail "dismissal turns mouse reporting back off" "$(cat -v "$test_tmp/out")"
grep -Fq 'rg.omarchy.screensaver' "$test_tmp/pkill.log" ||
  fail "dismissal closes the screensaver windows" "$(cat "$test_tmp/pkill.log" 2>/dev/null)"
pass "dismissal turns mouse reporting off and closes the screensaver"

# A terminal that never maps must not leave the mouse dead: the wait is capped
# at the launcher's own 5s per monitor.
start_screensaver 1 0
sleep 3
! armed || fail "mouse reporting keeps waiting before the cap" "$(cat -v "$test_tmp/out")"
wait_until 50 armed || fail "mouse reporting arms when a screensaver never maps" "$(cat -v "$test_tmp/out")"
pass "mouse reporting arms when a screensaver never maps"
press_key_and_wait_for_exit

# The keyboard works from the first frame, and dismissing before arming stops
# the arming job rather than leaving it polling Hyprland or arming later.
start_screensaver 2 0
sleep 0.3
press_key_and_wait_for_exit
polls=$(grep -c '^clients' "$test_tmp/hyprctl.log" || true)
sleep 0.5
(( $(grep -c '^clients' "$test_tmp/hyprctl.log" || true) == polls )) ||
  fail "dismissal before arming stops the arming job" "$(cat "$test_tmp/hyprctl.log")"
! armed || fail "dismissal before arming never arms" "$(cat -v "$test_tmp/out")"
pass "a keypress before arming dismisses and stops the arming job"
