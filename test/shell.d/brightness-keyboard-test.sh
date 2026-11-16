#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
# Releasing the paused blank lets a failed run reap its jobs before the cleanup.
trap 'touch "$test_tmp/pause.go"; wait || true; rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
leds="$test_tmp/leds"
level_file="$test_tmp/level"
mkdir -p "$mock_bin" "$leds/asus::kbd_backlight" "$test_tmp/runtime"

# A device holding one level, as the LED class does.
cat >"$mock_bin/brightnessctl" <<SH
#!/bin/bash
[[ \$1 == "-d" ]] || exit 1
case "\$3" in
get)
  [[ -z \${FAIL_GET:-} ]] || exit 1
  if [[ -n \${PAUSE_GET:-} ]]; then
    touch "\$PAUSE_GET.started"
    for _ in {1..100}; do [[ -e "\$PAUSE_GET.go" ]] && break; sleep 0.05; done
  fi
  cat "$level_file"
  ;;
max) echo 3 ;;
set)
  [[ -z \${FAIL_SET:-} ]] || exit 1
  echo "\$4" >"$level_file"
  ;;
*) exit 1 ;;
esac
SH
chmod +x "$mock_bin/brightnessctl"

keyboard="$test_tmp/omarchy-brightness-keyboard"
sed -e "s|/sys/class/leds|$leds|g" "$ROOT/bin/omarchy-brightness-keyboard" >"$keyboard"
chmod +x "$keyboard"

run_keyboard() {
  PATH="$mock_bin:$PATH" XDG_RUNTIME_DIR="$test_tmp/runtime" "$keyboard" "$@"
}

level() {
  cat "$level_file"
}

echo 3 >"$level_file"
run_keyboard off
[[ $(level) == "0" ]] || fail "off turns the backlight off"
run_keyboard restore
[[ $(level) == "3" ]] || fail "restore brings back the level from before off"
pass "off and restore round-trip the backlight level"

# The lock blanks again after a resume without waking in between.
echo 3 >"$level_file"
run_keyboard off
run_keyboard off
run_keyboard restore
[[ $(level) == "3" ]] || fail "a second off before restore keeps the level saved by the first (got $(level))"
pass "blanking twice before a wake restores the level from before the first"

# A backlight the user turned off stays off across a lock.
echo 0 >"$level_file"
run_keyboard off
run_keyboard restore
[[ $(level) == "0" ]] || fail "a backlight that was off before the lock stays off (got $(level))"
pass "a backlight that was off before blanking stays off"

# A restore the device rejects keeps the level for the next wake.
echo 3 >"$level_file"
run_keyboard off
FAIL_SET=1 run_keyboard restore
[[ $(level) == "0" ]] || fail "a rejected restore leaves the backlight where it was (got $(level))"
run_keyboard restore
[[ $(level) == "3" ]] || fail "a failed restore keeps the saved level for the next one (got $(level))"
pass "a failed restore keeps the saved level"

# A level that cannot be read is left lit rather than lost.
echo 2 >"$level_file"
FAIL_GET=1 run_keyboard off
[[ $(level) == "2" ]] || fail "off leaves a backlight it could not read alone (got $(level))"
pass "off leaves a backlight it could not read alone"

# A wake with no blank before it, as after an idle cycle without a lock.
echo 1 >"$level_file"
run_keyboard restore
[[ $(level) == "1" ]] || fail "restore with nothing saved leaves the backlight alone (got $(level))"
pass "restore with nothing saved leaves the backlight alone"

# An empty record, as a save that ran out of space leaves, is no record.
echo 3 >"$level_file"
: >"$test_tmp/runtime/omarchy-brightness-keyboard-asus::kbd_backlight"
run_keyboard off
[[ $(level) == "0" ]] || fail "off blanks over an empty record once it has saved the level (got $(level))"
run_keyboard restore
[[ $(level) == "3" ]] || fail "an empty record is replaced rather than blanked over (got $(level))"
pass "an empty record is replaced rather than blanked over"

# A wake that starts while a blank is still saving waits for it to finish.
echo 3 >"$level_file"
pause="$test_tmp/pause"
PAUSE_GET="$pause" run_keyboard off >/dev/null 2>&1 &
blank=$!
for _ in {1..100}; do [[ -e $pause.started ]] && break; sleep 0.05; done
[[ -e $pause.started ]] || fail "the blank reached its save"
run_keyboard restore >/dev/null 2>&1 &
wake=$!
sleep 0.5
touch "$pause.go"
wait "$blank" "$wake"
[[ $(level) == "3" ]] || fail "a wake overlapping a blank restores the level once the blank is done (got $(level))"
pass "a wake overlapping a blank waits for it"
