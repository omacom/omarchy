#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
auto_tmp=""
QS_PID=""
# Releasing the paused blank lets a failed run reap its jobs before the cleanup;
# the automatic backlight's Quickshell goes first so the wait can't hang on it.
cleanup() {
  if [[ -n $QS_PID ]]; then
    kill "$QS_PID" 2>/dev/null || true
  fi
  if [[ -n $auto_tmp ]]; then
    pkill -f "tail -n 0 -f $auto_tmp/sensor" 2>/dev/null || true
  fi
  touch "$test_tmp/pause.go"
  wait || true
  rm -rf "$test_tmp"
  if [[ -n $auto_tmp ]]; then
    rm -rf "$auto_tmp"
  fi
}
trap cleanup EXIT

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

# The automatic keyboard backlight: the real service under Quickshell, driven
# through the real off/restore and up/down the way lock blanking,
# omarchy-system-wake, and the backlight keys do. Only the LED path in a copy
# of the script is redirected, and omarchy-shell forwards to this Quickshell.
if ! command -v quickshell >/dev/null 2>&1 || ! command -v flock >/dev/null 2>&1; then
  skip "quickshell or flock not installed; skipping the automatic keyboard backlight checks"
  exit 0
fi

auto_tmp=$(mktemp -d)
led="$auto_tmp/leds/test::kbd_backlight"
runtime="$auto_tmp/run"
mkdir -p "$led" "$auto_tmp/bin" "$auto_tmp/home/.local/state/omarchy/toggles" "$auto_tmp/config" "$runtime"
chmod 700 "$runtime"
echo 0 > "$led/brightness"
echo 2 > "$led/max_brightness"
: > "$auto_tmp/sensor"
cp "$SHELL_TEST_DIR/fixtures/keyboard-backlight-auto/shell.qml" "$auto_tmp/config/shell.qml"
ln -s "$ROOT/shell/Commons" "$auto_tmp/config/Commons"
ln -s "$ROOT/shell/plugins" "$auto_tmp/config/plugins"

cat > "$auto_tmp/bin/omarchy-hw-ambient-light" <<'EOF'
#!/bin/bash
exit 0
EOF

cat > "$auto_tmp/bin/monitor-sensor" <<EOF
#!/bin/bash
exec tail -n 0 -f "$auto_tmp/sensor"
EOF

# get, max, and set. Writes land a little after the call, and lighting the keys
# takes longer than blanking them, so a write still in flight when the lock
# blanks lands after the blank unless something orders them.
cat > "$auto_tmp/bin/brightnessctl" <<EOF
#!/bin/bash
[[ \${1:-} == -d ]] && shift 2
case \${1:-} in
  get) cat "$led/brightness" ;;
  max) cat "$led/max_brightness" ;;
  set)
    if (( \$2 > 0 )); then sleep 0.5; else sleep 0.1; fi
    echo "\$2" > "$led/brightness"
    ;;
esac
EOF

cat > "$auto_tmp/bin/omarchy-osd" <<'EOF'
#!/bin/bash
exit 0
EOF

sed "s|/sys/class/leds|$auto_tmp/leds|" "$ROOT/bin/omarchy-brightness-keyboard" > "$auto_tmp/bin/omarchy-brightness-keyboard"
chmod +x "$auto_tmp/bin/"*

OMARCHY_PATH="$ROOT" \
OMARCHY_LEDS_PATH="$auto_tmp/leds" \
HOME="$auto_tmp/home" \
XDG_RUNTIME_DIR="$runtime" \
QT_QPA_PLATFORM=offscreen \
PATH="$auto_tmp/bin:$ROOT/bin:$PATH" \
  quickshell -p "$auto_tmp/config" --no-color > "$auto_tmp/quickshell.log" 2>&1 &
QS_PID=$!

cat > "$auto_tmp/bin/omarchy-shell" <<EOF
#!/bin/bash
[[ \$1 == -q ]] && shift
XDG_RUNTIME_DIR="$runtime" quickshell ipc --pid "$QS_PID" call "\$@" >/dev/null 2>&1 || true
EOF
chmod +x "$auto_tmp/bin/omarchy-shell"

auto_keyboard() {
  XDG_RUNTIME_DIR="$runtime" PATH="$auto_tmp/bin:$ROOT/bin:$PATH" omarchy-brightness-keyboard "$@"
}

sense() {
  echo "    Light changed: $1.000000 (lux)" >> "$auto_tmp/sensor"
}

brightness_is() {
  [[ $(< "$led/brightness") == "$1" ]]
}

manual_off_saved() {
  [[ -s $auto_tmp/home/.local/state/omarchy/keyboard-backlight-manual-off ]]
}

wait_for() {
  local description="$1"
  shift
  for _ in {1..100}; do
    "$@" && return 0
    sleep 0.1
  done
  sed -n '1,80p' "$auto_tmp/quickshell.log" >&2
  fail "$description"
}

monitor_running() {
  pgrep -f "tail -n 0 -f $auto_tmp/sensor" >/dev/null
}

wait_for "monitor-sensor starts" monitor_running

# Steady dark: on.
echo "=== Has ambient light sensor (value: 1.000000, unit: lux)" >> "$auto_tmp/sensor"
sleep 0.4
sense 0
wait_for "turns on in the dark" brightness_is 2

# The keys turn it off, no new reading, then lock blank and wake.
echo 0 > "$led/brightness"
sleep 0.4
auto_keyboard off
sleep 0.5
auto_keyboard restore
sleep 1
brightness_is 0 || fail "a key press before a lock is kept at wake" "brightness: $(< "$led/brightness")"
manual_off_saved || fail "a key press before a lock is held as a manual off"
pass "a key press before a lock is kept at wake"

# The keys turn it back on, seen at the next reading.
echo 2 > "$led/brightness"
sense 1
wait_for "turning it back on with the keys clears the hold" bash -c "! [[ -s $auto_tmp/home/.local/state/omarchy/keyboard-backlight-manual-off ]]"

# The keys turn it off, no new reading, then a wake with no blank before it:
# omarchy-system-wake when the idle screensaver is dismissed before the lock,
# or an unlock before the lock screen blanks.
echo 0 > "$led/brightness"
sleep 0.4
auto_keyboard restore
sleep 1
brightness_is 0 || fail "a key press is kept through a wake without a blank" "brightness: $(< "$led/brightness")"
manual_off_saved || fail "a key press before a wake without a blank is held as a manual off"
pass "a key press is kept through a wake without a blank"

# Back on with the keys, then a blank that runs off twice before the wake.
# The second off lands while paused, so the blank is not taken as the user's.
echo 2 > "$led/brightness"
sense 0
wait_for "turning it back on with the keys clears the hold again" bash -c "! [[ -s $auto_tmp/home/.local/state/omarchy/keyboard-backlight-manual-off ]]"
auto_keyboard off
auto_keyboard off
sleep 0.5
auto_keyboard restore
wait_for "a repeated off during a blank is not taken as the user's" brightness_is 2
manual_off_saved && fail "a repeated off during a blank is not held as a manual off"
pass "a repeated off during a blank is not taken as the user's"

# Steady dark and lit, and the keys turn it down to off. The key press tells
# the service at once, so the off is saved with no new reading. (The wake above
# had it decide again from the light, so let that write finish first.)
sleep 1.2
auto_keyboard down
auto_keyboard down
wait_for "the keys turn it off" brightness_is 0
manual_off_saved || fail "a key press in steady light is saved at once"
pass "a key press in steady light is saved at once"
auto_keyboard up
manual_off_saved && fail "turning it back on with the keys clears the hold at once"
pass "turning it back on with the keys clears the hold at once"

# Bright and off, then the room turns dark and the lock blanks while the write
# that lights the keys is still in flight: the blank waits for it and saves the
# lit level (1, picked with the keys above), so nothing is left lit behind the
# blank.
sense 70
sleep 0.4
sense 70
wait_for "turns off in bright light" brightness_is 0
sense 0
sleep 0.4
sense 0
sleep 0.1
auto_keyboard off
sleep 1
brightness_is 0 || fail "a write in flight when the lock blanks is not left lit" "brightness: $(< "$led/brightness")"
pass "a write in flight when the lock blanks is not left lit"
auto_keyboard restore
wait_for "the wake restores the lit level" brightness_is 1
manual_off_saved && fail "a write in flight when the lock blanks is not taken as the user's"
pass "the wake restores the lit level"
