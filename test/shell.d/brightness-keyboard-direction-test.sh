#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The fake /sys/class/leds is bind-mounted in a private mount namespace, so the
# test runs without root and never shadows the machine's real LEDs.
if [[ ${OMARCHY_KBD_TEST_NAMESPACE:-0} != "1" ]]; then
  if unshare --user --map-current-user --keep-caps --mount true 2>/dev/null; then
    exec env OMARCHY_KBD_TEST_NAMESPACE=1 \
      unshare --user --map-current-user --keep-caps --mount --propagation private bash "$0"
  else
    skip "unprivileged mount namespaces unavailable; skipping keyboard direction tests"
    exit 0
  fi
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
state_file="$test_tmp/cur"
mkdir -p "$mock_bin"

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl %s\n' "$*" >>"$CALL_LOG"
case " $* " in
  *" max "*) printf '100\n' ;;
  *" get "*) cat "$CUR_FILE" ;;
  *" set "*) printf '%s\n' "${*: -1}" | tr -dc '0-9' >"$CUR_FILE" ;;
esac
SH
chmod +x "$mock_bin/brightnessctl"

fake_leds="$test_tmp/leds"
mkdir -p "$fake_leds/fake_kbd_backlight"

mount --bind "$fake_leds" /sys/class/leds || fail "a fake /sys/class/leds mounts in the test's namespace"

run_keyboard() {
  CALL_LOG="$call_log" CUR_FILE="$state_file" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-brightness-keyboard" "$@"
}

# An unknown direction used to fall into the "down" branch and silently lower
# the keyboard backlight. It must be rejected before any hardware is touched.
printf '10\n' >"$state_file"
: >"$call_log"
status=0
run_keyboard --no-osd bogus >/dev/null 2>"$test_tmp/stderr" || status=$?
(( status == 1 )) || fail "unknown direction is rejected" "exit $status"
grep -q 'Usage:' "$test_tmp/stderr" || fail "unknown direction prints usage" "$(cat "$test_tmp/stderr")"
if [[ -s $call_log ]]; then
  fail "unknown direction never touches the backlight" "$(cat "$call_log")"
fi
[[ $(cat "$state_file") == "10" ]] || fail "unknown direction leaves the brightness unchanged"
pass "unknown direction is rejected with usage"

printf '10\n' >"$state_file"
: >"$call_log"
run_keyboard --no-osd up
grep -q 'brightnessctl -d fake_kbd_backlight set 20' "$call_log" || \
  fail "up raises the brightness by one step" "$(cat "$call_log")"
pass "up raises the brightness by one step"

printf '10\n' >"$state_file"
: >"$call_log"
run_keyboard --no-osd down
grep -q 'brightnessctl -d fake_kbd_backlight set 0' "$call_log" || \
  fail "down lowers the brightness by one step" "$(cat "$call_log")"
pass "down lowers the brightness by one step"

printf '100\n' >"$state_file"
: >"$call_log"
run_keyboard --no-osd cycle
grep -q 'brightnessctl -d fake_kbd_backlight set 0' "$call_log" || \
  fail "cycle wraps to zero at maximum" "$(cat "$call_log")"
pass "cycle wraps to zero at maximum"

: >"$call_log"
run_keyboard --no-osd off
grep -q 'brightnessctl -sd fake_kbd_backlight set 0' "$call_log" || \
  fail "off sets the backlight to zero" "$(cat "$call_log")"
pass "off sets the backlight to zero"

: >"$call_log"
run_keyboard --no-osd restore
grep -q 'brightnessctl -rd fake_kbd_backlight' "$call_log" || \
  fail "restore re-enables the backlight" "$(cat "$call_log")"
pass "restore re-enables the backlight"
