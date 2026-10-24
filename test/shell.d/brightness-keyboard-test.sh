#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
runtime_dir="$test_tmp/runtime"
leds="$test_tmp/leds"
level="$test_tmp/level"
mkdir -p "$mock_bin" "$runtime_dir" "$leds/tpacpi::kbd_backlight"

# A keyboard backlight with three levels, whose current level lives in a file
# so a case can change it the way the firmware's Fn key does, behind the script.
cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
args=("$@")
for (( i = 0; i < ${#args[@]}; i++ )); do
  case ${args[i]} in
    -s*) cp "$LEVEL_FILE" "$XDG_RUNTIME_DIR/brightnessctl-saved" ;;
    -r*) cp "$XDG_RUNTIME_DIR/brightnessctl-saved" "$LEVEL_FILE" ;;
    get) cat "$LEVEL_FILE" ;;
    max) echo 2 ;;
    set) echo "${args[i + 1]}" >"$LEVEL_FILE" ;;
  esac
done
SH
chmod +x "$mock_bin/brightnessctl"

brightness_keyboard="$test_tmp/omarchy-brightness-keyboard"
sed "s|/sys/class/leds|$leds|g" "$ROOT/bin/omarchy-brightness-keyboard" >"$brightness_keyboard"
chmod +x "$brightness_keyboard"
grep -qF "$leds/" "$brightness_keyboard" || fail "omarchy-brightness-keyboard reads LEDs from the fixture"

run_keyboard() {
  LEVEL_FILE="$level" XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$PATH" "$brightness_keyboard" "$@"
}

set_level() { echo "$1" >"$level"; }

# Each case starts from a fresh session: nothing saved, no level picked.
new_session() {
  rm -rf "$runtime_dir"
  mkdir -p "$runtime_dir"
  set_level "$1"
}

assert_level() {
  local actual
  actual=$(<"$level")
  [[ $actual == "$1" ]] || fail "$2" "expected: $1, actual: $actual"
  pass "$2"
}

new_session 2
run_keyboard off
assert_level 0 "blanking turns the keyboard backlight off"
run_keyboard restore
assert_level 2 "waking restores the level the blank turned off"

new_session 2
run_keyboard off
run_keyboard off
run_keyboard restore
assert_level 2 "a second blank before a wake keeps the level saved by the first"

# The lock blanked a dark keyboard, the user lit it after unlocking, then a
# screensaver came and went without a blank: the wake must not bring back 0.
new_session 0
run_keyboard off
run_keyboard restore
set_level 2
run_keyboard restore
assert_level 2 "a wake without a blank leaves the level the user set alone"

new_session 1
run_keyboard restore
assert_level 1 "a wake with nothing saved changes nothing"

# A T2 MacBook's keyboard comes back from suspend dark, and a lock taken right
# before sleeping blanks only after resume, finding 0 where the user had a level.
new_session 0
run_keyboard --no-osd up
run_keyboard --no-osd up
set_level 0
run_keyboard off
run_keyboard restore
assert_level 2 "a keyboard that came back dark is restored to the level picked with the keys"

new_session 1
run_keyboard --no-osd down
run_keyboard off
run_keyboard restore
assert_level 0 "a dark level picked with the keys stays dark after a wake"
