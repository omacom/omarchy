#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
runtime_dir="$test_tmp/runtime"
brightness_file="$test_tmp/brightness"
mock_leds="$test_tmp/sys/class/leds"
command="$test_tmp/omarchy-brightness-keyboard"
state_file="$runtime_dir/omarchy-keyboard-backlight-mock_kbd_backlight"
mkdir -p "$mock_bin" "$runtime_dir" "$mock_leds/mock_kbd_backlight"

sed "s|/sys/class/leds/\\*kbd_backlight\\*|$mock_leds/*kbd_backlight*|" \
  "$ROOT/bin/omarchy-brightness-keyboard" >"$command"
chmod +x "$command"

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
device=""
operation=""
value=""

while (( $# > 0 )); do
  case "$1" in
    -d)
      device="$2"
      shift 2
      ;;
    get|max)
      operation="$1"
      shift
      ;;
    set)
      operation="$1"
      value="$2"
      shift 2
      ;;
    *) shift ;;
  esac
done

[[ $device == "mock_kbd_backlight" ]] || exit 1

case "$operation" in
  get) cat "$BRIGHTNESS_FILE" ;;
  max) printf '2\n' ;;
  set)
    [[ ${FAIL_SET:-0} == 1 ]] && exit 1
    printf '%s\n' "$value" >"$BRIGHTNESS_FILE"
    ;;
  *) exit 1 ;;
esac
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$mock_bin"/*

run_brightness() {
  BRIGHTNESS_FILE="$brightness_file" FAIL_SET="${FAIL_SET:-0}" XDG_RUNTIME_DIR="$runtime_dir" PATH="$mock_bin:$PATH" \
    "$command" --no-osd "$@"
}

assert_brightness() {
  local expected="$1"
  local description="$2"
  local actual
  actual=$(<"$brightness_file")
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected, actual: $actual"
  pass "$description"
}

printf '2\n' >"$brightness_file"
run_brightness off
run_brightness off
assert_brightness 0 "blanking turns the keyboard off"
run_brightness restore
assert_brightness 2 "a keyboard that starts on is restored to its previous level"
[[ ! -e $state_file ]] || fail "restoring clears the saved keyboard brightness"
pass "restoring clears the saved keyboard brightness"

printf '0\n' >"$brightness_file"
run_brightness off
run_brightness off
[[ $(<"$state_file") == 0 ]] || fail "blanking saves an initial brightness of zero"
pass "blanking saves an initial brightness of zero"
run_brightness restore
assert_brightness 0 "a keyboard that starts off remains off"
[[ ! -e $state_file ]] || fail "restoring an off keyboard clears its saved brightness"
pass "restoring an off keyboard clears its saved brightness"

printf '1\n' >"$brightness_file"
printf '2\n' >"$state_file"
run_brightness down
assert_brightness 0 "manually turning the keyboard off leaves it off"
[[ ! -e $state_file ]] || fail "manual brightness changes clear the saved level"
pass "manual brightness changes clear the saved level"

run_brightness off
run_brightness restore
assert_brightness 0 "a manually disabled keyboard remains off after blank and restore"

printf '1\n' >"$brightness_file"
printf '2\n' >"$state_file"
if FAIL_SET=1 run_brightness down; then
  fail "a failed manual brightness change is reported"
fi
assert_brightness 1 "a failed manual brightness change leaves the keyboard unchanged"
[[ $(<"$state_file") == 2 ]] || fail "a failed manual brightness change preserves the saved level"
pass "a failed manual brightness change preserves the saved level"

# Hold the lock as an in-flight off would, and finish that off only after a restore has started.
rm -f "$state_file"
printf '2\n' >"$brightness_file"
exec {held_fd}>"$state_file.lock"
flock "$held_fd"
run_brightness restore {held_fd}>&- &
restore_pid=$!
restore_waiting() {
  local children
  children=$(pgrep -d, -P "$restore_pid" || true)
  pgrep -x -P "$restore_pid${children:+,$children}" flock >/dev/null
}
for _ in {1..50}; do
  restore_waiting && break
  sleep 0.1
done
restore_waiting || fail "a restore waits for the blank lock"
pass "a restore waits for the blank lock"
printf '2\n' >"$state_file"
printf '0\n' >"$brightness_file"
exec {held_fd}>&-
for _ in {1..50}; do
  kill -0 "$restore_pid" 2>/dev/null || break
  sleep 0.1
done
kill -0 "$restore_pid" 2>/dev/null && kill "$restore_pid" && fail "a restore finishes once the blank releases its lock"
wait "$restore_pid"
assert_brightness 2 "a restore waits for an in-flight blank to save its level"

rm -f "$state_file"
printf '1\n' >"$brightness_file"
rm -rf "$runtime_dir"
printf 'not a directory\n' >"$runtime_dir"
if run_brightness off >/dev/null 2>&1; then
  fail "a failed state save is reported"
fi
assert_brightness 1 "a failed state save does not turn the keyboard off"
