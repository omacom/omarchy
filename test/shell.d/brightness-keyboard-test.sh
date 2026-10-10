#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
runtime_dir="$test_tmp/runtime"
state_dir="$test_tmp/state"
mkdir -p "$mock_bin" "$runtime_dir" "$state_dir"

mock_sys_leds="/sys/class/leds"

# Mock brightnessctl
cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl %s\n' "$*" >>"$CALL_LOG"

device=""
args=("$@")
for (( i=0; i<${#args[@]}; i++ )); do
  if [[ ${args[i]} == "-d" && $(( i + 1 )) -lt ${#args[@]} ]]; then
    device="${args[i+1]}"
  fi
done

if [[ $* == *" max"* ]]; then
  echo "${MOCK_MAX:-1000}"
elif [[ $* == *" get"* ]]; then
  echo "${MOCK_CURRENT:-500}"
elif [[ $* == *" -sd "* ]]; then
  # Simulate saving current brightness and setting target
  echo "${MOCK_CURRENT:-500}" > "$MOCK_SAVED_FILE"
elif [[ $* == *" -rd "* ]]; then
  if [[ -s "$MOCK_SAVED_FILE" ]]; then
    saved=$(cat "$MOCK_SAVED_FILE")
    echo "$saved"
  fi
fi
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$mock_bin"/*

saved_file="$runtime_dir/brightnessctl/leds/:white:kbd_backlight"
mkdir -p "$(dirname "$saved_file")"
export MOCK_SAVED_FILE="$saved_file"


run_kbd() {
  CALL_LOG="$call_log" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  XDG_STATE_HOME="$state_dir" \
  PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-brightness-keyboard" "$@"
}

# Test 1: off with positive brightness calls brightnessctl -sd
: >"$call_log"
MOCK_CURRENT=500 MOCK_MAX=1000 run_kbd off
grep -Fq 'brightnessctl -sd :white:kbd_backlight set 0' "$call_log" ||
  fail "off saves state when current brightness is positive"
pass "off saves state when current brightness is positive"

# Test 2: off when brightness is already 0 calls brightnessctl -d set 0 (omits -s to protect saved state)
: >"$call_log"
MOCK_CURRENT=0 MOCK_MAX=1000 run_kbd off
grep -Fq 'brightnessctl -d :white:kbd_backlight set 0' "$call_log" ||
  fail "off does not overwrite saved state when current brightness is already 0"
! grep -Fq 'brightnessctl -sd' "$call_log" ||
  fail "off must not pass -s when current brightness is 0"
pass "off avoids zero-clobbering when backlight is already 0"

# Test 3: up increments by 10% and persists state
: >"$call_log"
MOCK_CURRENT=500 MOCK_MAX=1000 run_kbd up
grep -Fq 'brightnessctl -d :white:kbd_backlight set 600' "$call_log" ||
  fail "up steps brightness by 10%"
[[ $(cat "$state_dir/omarchy/keyboard-brightness" 2>/dev/null) == "600" ]] ||
  fail "up persists new brightness level"
pass "up steps brightness by 10% and persists target"

# Test 4: down decrements by 10% and persists state
: >"$call_log"
MOCK_CURRENT=500 MOCK_MAX=1000 run_kbd down
grep -Fq 'brightnessctl -d :white:kbd_backlight set 400' "$call_log" ||
  fail "down steps brightness down by 10%"
[[ $(cat "$state_dir/omarchy/keyboard-brightness" 2>/dev/null) == "400" ]] ||
  fail "down persists new brightness level"
pass "down steps brightness down by 10% and persists target"

# Test 5: restore with persistent state recovers saved target
: >"$call_log"
echo "750" > "$state_dir/omarchy/keyboard-brightness"
rm -f "$saved_file"
MOCK_CURRENT=0 MOCK_MAX=1000 run_kbd restore
grep -Fq 'brightnessctl -d :white:kbd_backlight set 750' "$call_log" ||
  fail "restore uses persistent state when run file is absent"
pass "restore recovers target brightness from persistent state"

# Test 6: restore without any saved state falls back to 30% default
: >"$call_log"
rm -f "$state_dir/omarchy/keyboard-brightness" "$saved_file"
MOCK_CURRENT=0 MOCK_MAX=1000 run_kbd restore
grep -Fq 'brightnessctl -d :white:kbd_backlight set 300' "$call_log" ||
  fail "restore falls back to 30% of max when no state exists"
pass "restore falls back to 30% when no state exists"
