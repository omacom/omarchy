#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/leds/dell::kbd_backlight" "$test_tmp/runtime"
export BRIGHTNESS_FIXTURE="$test_tmp"
export OMARCHY_LEDS_PATH="$test_tmp/leds"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
export PATH="$test_tmp/bin:$PATH"
state_file="$XDG_RUNTIME_DIR/omarchy-keyboard-backlight-dell::kbd_backlight"

cat >"$test_tmp/bin/brightnessctl" <<'SH'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$*" >>"$BRIGHTNESS_FIXTURE/calls"
case "$1" in
-d) shift 2 ;;
-sd)
  cp "$BRIGHTNESS_FIXTURE/brightness" "$BRIGHTNESS_FIXTURE/legacy-saved"
  shift 2
  ;;
-rd)
  [[ ! -f $BRIGHTNESS_FIXTURE/legacy-saved ]] || cp "$BRIGHTNESS_FIXTURE/legacy-saved" "$BRIGHTNESS_FIXTURE/brightness"
  exit 0
  ;;
*) exit 1 ;;
esac
case "$1" in
get)
  [[ ${FAIL_GET:-0} != "1" ]] || exit 1
  cat "$BRIGHTNESS_FIXTURE/brightness"
  ;;
max) cat "$BRIGHTNESS_FIXTURE/max" ;;
set)
  [[ ${FAIL_SET:-0} != "1" ]] || exit 1
  printf '%s\n' "$2" >"$BRIGHTNESS_FIXTURE/brightness"
  ;;
*) exit 1 ;;
esac
SH

cat >"$test_tmp/bin/omarchy-osd" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$BRIGHTNESS_FIXTURE/osd"
SH
chmod +x "$test_tmp/bin/brightnessctl" "$test_tmp/bin/omarchy-osd"

run_keyboard() {
  "$ROOT/bin/omarchy-brightness-keyboard" --no-osd "$@"
}

reset_fixture() {
  rm -f "$state_file" "$state_file.tmp" "$test_tmp/legacy-saved"
  printf '%s\n' "${1:-2}" >"$test_tmp/brightness"
  printf '2\n' >"$test_tmp/max"
  : >"$test_tmp/calls"
  : >"$test_tmp/osd"
}

assert_brightness() {
  [[ $(<"$test_tmp/brightness") == "$1" ]] || fail "$2" "brightness: $(<"$test_tmp/brightness"), expected: $1"
  pass "$2"
}

# A manually selected zero must replace any earlier non-zero restore state.
reset_fixture 2
run_keyboard off
run_keyboard restore
run_keyboard down
run_keyboard down
run_keyboard off
run_keyboard restore
assert_brightness 0 "manual off survives lock and restore after an earlier lit lock"

# Firmware timeout before the first lock must not require an earlier snapshot.
reset_fixture 0
run_keyboard up
printf '0\n' >"$test_tmp/brightness"
: >"$test_tmp/calls"
run_keyboard off
run_keyboard off
if grep -Eq -- 'set 0$' "$test_tmp/calls"; then
  fail "blanking an already timed-out keyboard must not send set 0"
fi
run_keyboard restore
assert_brightness 1 "a manual level survives timeout before the first lock"

# Repeated blanks and wakes must retain the last intentional level.
run_keyboard off
run_keyboard off
run_keyboard restore
run_keyboard restore
assert_brightness 1 "repeated blank and restore retain the selected level"

reset_fixture 2
run_keyboard cycle
run_keyboard off
run_keyboard restore
assert_brightness 0 "cycle to zero stays off after lock and restore"

reset_fixture 0
run_keyboard up
run_keyboard up
printf '0\n' >"$test_tmp/brightness"
run_keyboard off
run_keyboard restore
assert_brightness 2 "the most recent successful manual level is restored"

# Without a recorded selection, only a positive reading can seed the state.
reset_fixture 2
run_keyboard off
run_keyboard off
run_keyboard restore
assert_brightness 2 "a lit first lock seeds the initial restore level"

reset_fixture 0
run_keyboard off
run_keyboard restore
assert_brightness 0 "an unknown initial zero is not guessed to be a timeout"
[[ ! -e $state_file ]] || fail "an unknown zero must not be saved as a user selection"
pass "an unknown zero leaves user state unset"

reset_fixture 0
run_keyboard up
if FAIL_SET=1 run_keyboard up; then
  fail "a failed manual change must report failure"
fi
printf '0\n' >"$test_tmp/brightness"
run_keyboard restore
assert_brightness 1 "a failed manual change preserves the last successful level"

run_keyboard off
if FAIL_SET=1 run_keyboard restore; then
  fail "a failed restore must report failure"
fi
run_keyboard restore
assert_brightness 1 "a failed restore can be retried without losing state"

if FAIL_GET=1 run_keyboard off; then
  fail "a failed brightness read must report failure"
fi
assert_brightness 1 "a failed read does not blank the keyboard"

reset_fixture 2
mkdir "$state_file"
if run_keyboard off >/dev/null 2>&1; then
  fail "a failed initial state save must report failure"
fi
assert_brightness 2 "a failed initial state save does not blank the keyboard"
rmdir "$state_file"

# Preserve ordinary adjustment behavior on devices with many levels.
reset_fixture 0
printf '512\n' >"$test_tmp/max"
"$ROOT/bin/omarchy-brightness-keyboard" up
assert_brightness 51 "many-level keyboards retain their ten-percent step"
grep -Fqx -- '-i keyboard -p 9' "$test_tmp/osd" || fail "manual changes still show the brightness OSD"
pass "manual changes still show the brightness OSD"
