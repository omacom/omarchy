#!/bin/bash

# Drives the real keyboard backlight service through the real
# omarchy-brightness-keyboard, the way lock blanking, omarchy-system-wake, and
# the backlight keys do. Only the LED path in a copy of the script is
# redirected, and omarchy-shell forwards to this Quickshell instance.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command quickshell
require_command flock

TMPDIR=$(mktemp -d)
QS_PID=""
cleanup() {
  [[ -n $QS_PID ]] && kill "$QS_PID" 2>/dev/null
  pkill -f "tail -n 0 -f $TMPDIR/sensor" 2>/dev/null || true
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

led="$TMPDIR/leds/test::kbd_backlight"
runtime="$TMPDIR/run"
mkdir -p "$led" "$TMPDIR/bin" "$TMPDIR/home/.local/state/omarchy/toggles" "$TMPDIR/config" "$runtime"
chmod 700 "$runtime"
echo 0 > "$led/brightness"
echo 2 > "$led/max_brightness"
: > "$TMPDIR/sensor"
cp "$SHELL_TEST_DIR/fixtures/keyboard-backlight-auto/shell.qml" "$TMPDIR/config/shell.qml"
ln -s "$ROOT/shell/Commons" "$TMPDIR/config/Commons"
ln -s "$ROOT/shell/plugins" "$TMPDIR/config/plugins"

cat > "$TMPDIR/bin/omarchy-hw-ambient-light" <<'EOF'
#!/bin/bash
exit 0
EOF

cat > "$TMPDIR/bin/monitor-sensor" <<EOF
#!/bin/bash
exec tail -n 0 -f "$TMPDIR/sensor"
EOF

# get, max, and set. Writes land a little after the call, and lighting the keys
# takes longer than blanking them, so a write still in flight when the lock
# blanks lands after the blank unless something orders them.
cat > "$TMPDIR/bin/brightnessctl" <<EOF
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

cat > "$TMPDIR/bin/omarchy-osd" <<'EOF'
#!/bin/bash
exit 0
EOF

sed "s|/sys/class/leds|$TMPDIR/leds|" "$ROOT/bin/omarchy-brightness-keyboard" > "$TMPDIR/bin/omarchy-brightness-keyboard"
chmod +x "$TMPDIR/bin/"*

OMARCHY_PATH="$ROOT" \
OMARCHY_LEDS_PATH="$TMPDIR/leds" \
HOME="$TMPDIR/home" \
XDG_RUNTIME_DIR="$runtime" \
QT_QPA_PLATFORM=offscreen \
PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  quickshell -p "$TMPDIR/config" --no-color > "$TMPDIR/quickshell.log" 2>&1 &
QS_PID=$!

cat > "$TMPDIR/bin/omarchy-shell" <<EOF
#!/bin/bash
[[ \$1 == -q ]] && shift
XDG_RUNTIME_DIR="$runtime" quickshell ipc --pid "$QS_PID" call "\$@" >/dev/null 2>&1 || true
EOF
chmod +x "$TMPDIR/bin/omarchy-shell"

keyboard() {
  XDG_RUNTIME_DIR="$runtime" PATH="$TMPDIR/bin:$ROOT/bin:$PATH" omarchy-brightness-keyboard "$@"
}

sense() {
  echo "    Light changed: $1.000000 (lux)" >> "$TMPDIR/sensor"
}

brightness_is() {
  [[ $(< "$led/brightness") == "$1" ]]
}

manual_off_saved() {
  [[ -s $TMPDIR/home/.local/state/omarchy/keyboard-backlight-manual-off ]]
}

wait_for() {
  local description="$1"
  shift
  for _ in {1..100}; do
    "$@" && return 0
    sleep 0.1
  done
  sed -n '1,80p' "$TMPDIR/quickshell.log" >&2
  fail "$description"
}

monitor_running() {
  pgrep -f "tail -n 0 -f $TMPDIR/sensor" >/dev/null
}

wait_for "monitor-sensor starts" monitor_running

# Steady dark: on.
echo "=== Has ambient light sensor (value: 1.000000, unit: lux)" >> "$TMPDIR/sensor"
sleep 0.4
sense 0
wait_for "turns on in the dark" brightness_is 2

# The keys turn it off, no new reading, then lock blank and wake.
echo 0 > "$led/brightness"
sleep 0.4
keyboard off
sleep 0.5
keyboard restore
sleep 1
brightness_is 0 || fail "a key press before a lock is kept at wake" "brightness: $(< "$led/brightness")"
manual_off_saved || fail "a key press before a lock is held as a manual off"
pass "a key press before a lock is kept at wake"

# The keys turn it back on, seen at the next reading.
echo 2 > "$led/brightness"
sense 1
wait_for "turning it back on with the keys clears the hold" bash -c "! [[ -s $TMPDIR/home/.local/state/omarchy/keyboard-backlight-manual-off ]]"

# The keys turn it off, no new reading, then a wake with no blank before it:
# omarchy-system-wake when the idle screensaver is dismissed before the lock,
# or an unlock before the lock screen blanks.
echo 0 > "$led/brightness"
sleep 0.4
keyboard restore
sleep 1
brightness_is 0 || fail "a key press is kept through a wake without a blank" "brightness: $(< "$led/brightness")"
manual_off_saved || fail "a key press before a wake without a blank is held as a manual off"
pass "a key press is kept through a wake without a blank"

# Back on with the keys, then a blank that runs off twice before the wake.
# The second off lands while paused, so the blank is not taken as the user's.
echo 2 > "$led/brightness"
sense 0
wait_for "turning it back on with the keys clears the hold again" bash -c "! [[ -s $TMPDIR/home/.local/state/omarchy/keyboard-backlight-manual-off ]]"
keyboard off
keyboard off
sleep 0.5
keyboard restore
wait_for "a repeated off during a blank is not taken as the user's" brightness_is 2
manual_off_saved && fail "a repeated off during a blank is not held as a manual off"
pass "a repeated off during a blank is not taken as the user's"

# Steady dark and lit, and the keys turn it down to off. The key press tells
# the service at once, so the off is saved with no new reading. (The wake above
# had it decide again from the light, so let that write finish first.)
sleep 1.2
keyboard down
keyboard down
wait_for "the keys turn it off" brightness_is 0
manual_off_saved || fail "a key press in steady light is saved at once"
pass "a key press in steady light is saved at once"
keyboard up
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
keyboard off
sleep 1
brightness_is 0 || fail "a write in flight when the lock blanks is not left lit" "brightness: $(< "$led/brightness")"
pass "a write in flight when the lock blanks is not left lit"
keyboard restore
wait_for "the wake restores the lit level" brightness_is 1
manual_off_saved && fail "a write in flight when the lock blanks is not taken as the user's"
pass "the wake restores the lit level"
