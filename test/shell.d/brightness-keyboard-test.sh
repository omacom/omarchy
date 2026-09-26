#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
leds_path="$test_tmp/leds"
state="$test_tmp/brightness"
saved="$test_tmp/saved"
mkdir -p "$mock_bin" "$leds_path/chromeos::kbd_backlight"

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl %s\n' "$*" >>"$CALL_LOG"

state="${BRIGHTNESS_STATE:?}"
saved="${BRIGHTNESS_SAVED:?}"

if [[ $1 == "-d" && $3 == "get" ]]; then
  cat "$state"
elif [[ $1 == "-d" && $3 == "max" ]]; then
  printf '100\n'
elif [[ $1 == "-sd" && $3 == "set" ]]; then
  cat "$state" >"$saved"
  printf '%s\n' "$4" >"$state"
elif [[ $1 == "-rd" ]]; then
  cat "$saved" >"$state"
elif [[ $1 == "-d" && $3 == "set" ]]; then
  printf '%s\n' "$4" >"$state"
fi
SH

chmod +x "$mock_bin"/*

run_keyboard() {
  CALL_LOG="$call_log" BRIGHTNESS_STATE="$state" BRIGHTNESS_SAVED="$saved" \
    OMARCHY_LEDS_PATH="$leds_path" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-brightness-keyboard" "$@"
}

begin() {
  printf '%s\n' "$1" >"$state"
  printf '%s\n' "$2" >"$saved"
  : >"$call_log"
}

level() { cat "$state"; }
save_level() { cat "$saved"; }

# A blank records the level it found, so the following wake has something to
# put back.
begin 40 7
run_keyboard off
[[ $(level) == "0" ]] || fail "off blanks the backlight" "actual: $(level)"
pass "off blanks the backlight"
[[ $(save_level) == "40" ]] || fail "off saves the lit level" "actual: $(save_level)"
pass "off saves the lit level"

run_keyboard restore
[[ $(level) == "40" ]] || fail "restore brings the saved level back" "actual: $(level)"
pass "restore brings the saved level back"

# The level being something other than zero is proof that it was set after the
# blank -- the backlight hotkeys stay bound while locked -- so that choice is
# newer than the saved value and has to survive the wake.
begin 40 7
run_keyboard off
printf '55\n' >"$state"
: >"$call_log"
run_keyboard restore
[[ $(level) == "55" ]] || fail "restore leaves a level changed while blanked" "actual: $(level)"
pass "restore leaves a level changed while blanked"
grep -q -- '-rd' "$call_log" && fail "restore does not write when the level changed" "$(cat "$call_log")"
pass "restore does not write when the level changed"

# Turning the backlight off by hand before locking is a choice, not state to be
# undone on the next wake.
begin 0 40
run_keyboard off
[[ $(save_level) == "0" ]] || fail "off saves a deliberate zero" "actual: $(save_level)"
pass "off saves a deliberate zero"
run_keyboard restore
[[ $(level) == "0" ]] || fail "restore keeps a deliberate zero off" "actual: $(level)"
pass "restore keeps a deliberate zero off"
