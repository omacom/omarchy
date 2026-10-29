#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
sys_root="$test_tmp/sys"
mkdir -p "$mock_bin" "$sys_root/class/leds"

state_file="$test_tmp/current_brightness"
saved_file="$test_tmp/saved_brightness"

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl %s\n' "$*" >>"$CALL_LOG"

device=""
save=0
restore=0
args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d)
      device="$2"
      shift 2
      ;;
    -sd|-ds)
      save=1
      device="$2"
      shift 2
      ;;
    -rd|-dr)
      restore=1
      device="$2"
      shift 2
      ;;
    -s)
      save=1
      shift
      ;;
    -r)
      restore=1
      shift
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

if (( restore )); then
  if [[ -f "$SAVED_FILE" ]]; then
    cat "$SAVED_FILE" >"$STATE_FILE"
  fi
  exit 0
fi

op="${args[0]:-}"
val="${args[1]:-}"

case "$op" in
  get)
    cat "$STATE_FILE"
    ;;
  max)
    echo "255"
    ;;
  set)
    if (( save )); then
      cat "$STATE_FILE" >"$SAVED_FILE"
    fi
    echo "$val" >"$STATE_FILE"
    ;;
  *)
    exit 0
    ;;
esac
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$mock_bin"/*

run_kb() {
  local scenario="$1"
  shift
  : >"$call_log"
  CALL_LOG="$call_log" \
    STATE_FILE="$state_file" \
    SAVED_FILE="$saved_file" \
    OMARCHY_SYS_ROOT="$sys_root" \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-brightness-keyboard" "$@"
}

# Test 1: No device found exits 1
rm -rf "$sys_root/class/leds"/*
if run_kb no_dev off >"$test_tmp/no_dev.err" 2>&1; then
  fail "fails when no keyboard backlight device exists"
fi
grep -q "No keyboard backlight device found" "$test_tmp/no_dev.err" || fail "reports missing device error"
pass "omarchy-brightness-keyboard fails when no keyboard backlight device exists"

# Setup fixture device
mkdir -p "$sys_root/class/leds/smc::kbd_backlight"

# Test 2: First off saves non-zero level and blanks backlight
echo "25" >"$state_file"
rm -f "$saved_file"
run_kb first_off off
[[ $(cat "$state_file") == "0" ]] || fail "first off sets brightness to 0"
[[ $(cat "$saved_file") == "25" ]] || fail "first off saves non-zero level"
grep -q "brightnessctl -sd smc::kbd_backlight set 0" "$call_log" || fail "first off calls brightnessctl with -s"
pass "omarchy-brightness-keyboard off saves active brightness level and turns off light"

# Test 3: Second off does NOT overwrite saved level with 0
: >"$call_log"
run_kb second_off off
[[ $(cat "$state_file") == "0" ]] || fail "second off keeps brightness at 0"
[[ $(cat "$saved_file") == "25" ]] || fail "second off does not overwrite saved level with 0"
grep -q "brightnessctl -d smc::kbd_backlight set 0" "$call_log" || fail "second off calls brightnessctl without -s"
! grep -q "brightnessctl -sd" "$call_log" || fail "second off must not pass -s"
pass "omarchy-brightness-keyboard off preserves previously saved level when already at 0"

# Test 4: Restore brings back the original level
: >"$call_log"
run_kb restore restore
[[ $(cat "$state_file") == "25" ]] || fail "restore brings back saved brightness"
grep -q "brightnessctl -rd smc::kbd_backlight" "$call_log" || fail "restore calls brightnessctl with -rd"
pass "omarchy-brightness-keyboard restore restores original brightness level"

# Test 5: Step adjustments (up, down, cycle)
echo "25" >"$state_file"
run_kb step_up --no-osd up
[[ $(cat "$state_file") == "50" ]] || fail "up increases brightness by step"

run_kb step_down --no-osd down
[[ $(cat "$state_file") == "25" ]] || fail "down decreases brightness by step"

echo "255" >"$state_file"
run_kb step_cycle --no-osd cycle
[[ $(cat "$state_file") == "0" ]] || fail "cycle wraps around to 0 when exceeding max"
pass "omarchy-brightness-keyboard step adjustments (up, down, cycle) work correctly"
