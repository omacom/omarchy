#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
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
  *" -r "*) printf 'restored\n' ;;
  *" set "*) printf '%s\n' "${*: -1}" | tr -dc '0-9' >"$CUR_FILE" ;;
esac
SH
chmod +x "$mock_bin/brightnessctl"

fake_leds="$test_tmp/leds"
mkdir -p "$fake_leds/fake_kbd_backlight"

if mount --bind "$fake_leds" /sys/class/leds 2>/dev/null; then
  trap 'umount /sys/class/leds 2>/dev/null || true; rm -rf "$test_tmp"' EXIT
else
  skip "cannot bind-mount a fake /sys/class/leds; skipping keyboard direction tests"
  exit 0
fi

run_keyboard() {
  CALL_LOG="$call_log" CUR_FILE="$state_file" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-brightness-keyboard" "$@"
}

# An unknown direction used to fall into the "down" branch and silently lower
# the keyboard backlight. It must be rejected before any hardware is touched.
printf '10\n' >"$state_file"
: >"$call_log"
if run_keyboard --no-osd bogus >/dev/null 2>"$test_tmp/stderr"; then
  fail "unknown direction is rejected"
fi
grep -q 'Usage:' "$test_tmp/stderr" || fail "unknown direction prints usage" "$(cat "$test_tmp/stderr")"
if grep -q ' set ' "$call_log"; then
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
