#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A second blank without a restore in between must not overwrite the level the
# first blank saved with the already-zeroed brightness (#15618), or every wake
# restores 0 and the backlight stays off.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
runtime_dir="$test_tmp/runtime"
leds_dir="$test_tmp/leds"
state_file="$test_tmp/brightness"
mkdir -p "$mock_bin" "$runtime_dir" "$leds_dir"

# A fixture LED the copied command discovers instead of the machine's own.
mkdir -p "$leds_dir/mock::kbd_backlight"

brightness=2
max=3

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl %s\n' "$*" >>"$CALL_LOG"

args="$*"
state="$BRIGHTNESS_STATE"
save="$XDG_RUNTIME_DIR/brightnessctl/leds/mock::kbd_backlight"
current=$(cat "$state")

case "$args" in
  *" set "*)
    if [[ $args == *"-s"* ]]; then
      mkdir -p "$(dirname "$save")"
      printf '%s\n' "$current" >"$save"
    fi
    printf '%s\n' "${args##* set }" >"$state"
    ;;
  *"-r"*)
    if [[ -f $save ]]; then
      cat "$save" >"$state"
      rm -f "$save"
    fi
    ;;
  *" get")
    printf '%s\n' "$current"
    ;;
  *" max")
    printf '%s\n' "$BRIGHTNESS_MAX"
    ;;
esac
SH
chmod +x "$mock_bin/brightnessctl"

# A copy of the command discovers its LED from the fixture directory.
keyboard_brightness="$test_tmp/copy/omarchy-brightness-keyboard"
mkdir -p "$test_tmp/copy"
sed "s|/sys/class/leds|$leds_dir|g" "$ROOT/bin/omarchy-brightness-keyboard" >"$keyboard_brightness"
chmod +x "$keyboard_brightness"
grep -qF "$leds_dir" "$keyboard_brightness" || fail "omarchy-brightness-keyboard reads its LED class from the fixture"

run_keyboard() {
  CALL_LOG="$call_log" BRIGHTNESS_STATE="$state_file" BRIGHTNESS_MAX="$max" \
    XDG_RUNTIME_DIR="$runtime_dir" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$keyboard_brightness" "$@"
}

printf '2\n' >"$state_file"

run_keyboard --no-osd off
[[ $(cat "$state_file") == "0" ]] || fail "blanking a lit keyboard sets the brightness to 0" "state: $(cat "$state_file")"
[[ $(cat "$runtime_dir/brightnessctl/leds/mock::kbd_backlight") == "2" ]] || \
  fail "blanking a lit keyboard saves its level" "saved: $(cat "$runtime_dir/brightnessctl/leds/mock::kbd_backlight")"
pass "blanking a lit keyboard saves its level and goes dark"

run_keyboard --no-osd off
[[ $(cat "$state_file") == "0" ]] || fail "blanking a dark keyboard leaves it dark"
[[ $(cat "$runtime_dir/brightnessctl/leds/mock::kbd_backlight") == "2" ]] || \
  fail "a second blank keeps the level the first one saved" \
    "saved: $(cat "$runtime_dir/brightnessctl/leds/mock::kbd_backlight")"
pass "a second blank does not overwrite the saved level with 0"

run_keyboard --no-osd restore
[[ $(cat "$state_file") == "2" ]] || fail "wake restores the level the first blank saved" "state: $(cat "$state_file")"
pass "wake restores the level the first blank saved"

# The save happens only when there is something to save: a lit keyboard still
# records its own level.
printf '1\n' >"$state_file"
run_keyboard --no-osd off
[[ $(cat "$runtime_dir/brightnessctl/leds/mock::kbd_backlight") == "1" ]] || \
  fail "blanking from another level saves that level" \
    "saved: $(cat "$runtime_dir/brightnessctl/leds/mock::kbd_backlight")"
pass "blanking from another level saves that level"

# Restoring with nothing saved leaves the keyboard as it is.
rm -f "$runtime_dir/brightnessctl/leds/mock::kbd_backlight"
run_keyboard --no-osd restore
[[ $(cat "$state_file") == "0" ]] || fail "restoring with nothing saved leaves the brightness alone"
pass "restoring with nothing saved leaves the brightness alone"
