#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
led_dir="$test_tmp/leds"
script="$test_tmp/omarchy-brightness-keyboard"
mkdir -p "$mock_bin" "$led_dir/smc::kbd_backlight"

sed "s|/sys/class/leds/\*kbd_backlight\*|$led_dir/*kbd_backlight*|" \
  "$ROOT/bin/omarchy-brightness-keyboard" >"$script"

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
case "${@: -2:1} ${@: -1}" in
  *" max") printf '%s\n' "$KBD_MAX" ;;
  *" get") cat "$KBD_STATE" ;;
  "set "*) printf '%s\n' "${@: -1}" >"$KBD_STATE" ;;
esac
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf '%s\n' "${@: -1}" >>"$KBD_OSD"
SH

chmod +x "$mock_bin"/*

# Presses the key the given number of times from a starting level and prints
# the raw level and OSD percentage after each press.
press() {
  local max="$1" start="$2" direction="$3" count="$4" i

  printf '%s\n' "$start" >"$test_tmp/state"
  : >"$test_tmp/osd"

  for (( i = 0; i < count; i++ )); do
    KBD_MAX="$max" KBD_STATE="$test_tmp/state" KBD_OSD="$test_tmp/osd" PATH="$mock_bin:$PATH" \
      bash "$script" "$direction"
    printf '%s:%s ' "$(<"$test_tmp/state")" "$(tail -n 1 "$test_tmp/osd")"
  done
}

# A MacBook Air keyboard backlight ranges over 0-255.
up=$(press 255 0 up 12)
expected_up="3:1 26:10 51:20 77:30 102:40 128:50 153:60 179:70 204:80 230:90 255:100 255:100 "
[[ $up == "$expected_up" ]] || fail "raising a 255-level keyboard steps through 1% and then 10% levels" "actual: $up"
pass "raising a 255-level keyboard steps through 1% and then 10% levels"

down=$(press 255 255 down 12)
expected_down="230:90 204:80 179:70 153:60 128:50 102:40 77:30 51:20 26:10 3:1 0:0 0:0 "
[[ $down == "$expected_down" ]] || fail "lowering a 255-level keyboard lands on the same levels as raising it" "actual: $down"
pass "lowering a 255-level keyboard lands on the same levels as raising it"

off_level=$(press 255 13 up 1)
[[ $off_level == "26:10 " ]] || fail "raising from between levels moves to the next level" "actual: $off_level"
off_level=$(press 255 13 down 1)
[[ $off_level == "3:1 " ]] || fail "lowering from between levels moves to the previous level" "actual: $off_level"
pass "a level between steps moves to the neighbouring step"

up=$(press 512 0 up 2)
[[ $up == "5:1 51:10 " ]] || fail "a 512-level keyboard shows round percentages" "actual: $up"
pass "a 512-level keyboard shows round percentages"

up=$(press 3 0 up 4)
[[ $up == "1:33 2:67 3:100 3:100 " ]] || fail "raising a 3-level keyboard steps one level at a time" "actual: $up"
down=$(press 3 3 down 4)
[[ $down == "2:67 1:33 0:0 0:0 " ]] || fail "lowering a 3-level keyboard steps one level at a time" "actual: $down"
pass "a 3-level keyboard steps one level at a time"

cycle=$(press 3 0 cycle 5)
[[ $cycle == "1:33 2:67 3:100 0:0 1:33 " ]] || fail "cycling wraps from the top level to off" "actual: $cycle"
cycle=$(press 255 230 cycle 2)
[[ $cycle == "255:100 0:0 " ]] || fail "cycling reaches full brightness before wrapping" "actual: $cycle"
pass "cycling reaches every level and wraps to off"
