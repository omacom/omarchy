#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command quickshell

TMPDIR=$(mktemp -d)
QS_PID=""
cleanup() {
  [[ -n $QS_PID ]] && kill "$QS_PID" 2>/dev/null
  pkill -f "tail -n \+1 -f $TMPDIR/sensor" 2>/dev/null || true
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

led="$TMPDIR/leds/test::kbd_backlight"
mkdir -p "$led" "$TMPDIR/bin" "$TMPDIR/home/.local/state/omarchy/toggles" "$TMPDIR/config"
echo 0 > "$led/brightness"
echo 2 > "$led/max_brightness"
: > "$TMPDIR/sensor"
: > "$TMPDIR/writes"
cp "$SHELL_TEST_DIR/fixtures/keyboard-backlight/shell.qml" "$TMPDIR/config/shell.qml"

cat > "$TMPDIR/bin/omarchy-hw-ambient-light" <<'EOF'
#!/bin/bash
exit 0
EOF

# Feeds whatever the test appends to $TMPDIR/sensor. The first run exits
# straight away, the way monitor-sensor does when the claim fails.
cat > "$TMPDIR/bin/monitor-sensor" <<EOF
#!/bin/bash
echo "\${LC_ALL:-unset}" > "$TMPDIR/monitor-locale"
if [[ ! -e $TMPDIR/monitor-started ]]; then
  touch "$TMPDIR/monitor-started"
  exit 1
fi
exec tail -n +1 -f "$TMPDIR/sensor"
EOF

# Writes land a little after the call, like a real sysfs write through logind.
cat > "$TMPDIR/bin/brightnessctl" <<EOF
#!/bin/bash
level=\${@: -1}
sleep 0.2
echo "\$level" > "$led/brightness"
echo "\$level" >> "$TMPDIR/writes"
EOF
chmod +x "$TMPDIR/bin/"*

OMARCHY_PATH="$ROOT" \
OMARCHY_LEDS_PATH="$TMPDIR/leds" \
HOME="$TMPDIR/home" \
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$TMPDIR}" \
QT_QPA_PLATFORM=offscreen \
PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  quickshell -p "$TMPDIR/config" --no-color > "$TMPDIR/quickshell.log" 2>&1 &
QS_PID=$!

ipc() {
  quickshell ipc --pid "$QS_PID" call omarchy.keyboard-backlight "$1" >/dev/null 2>&1
}

sense() {
  echo "    Light changed: $1.000000 (lux)" >> "$TMPDIR/sensor"
}

writes() {
  paste -sd ' ' "$TMPDIR/writes"
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
  pgrep -f "tail -n \+1 -f $TMPDIR/sensor" >/dev/null
}

manual_off_saved() {
  [[ -s $TMPDIR/home/.local/state/omarchy/keyboard-backlight-manual-off ]]
}

writes_are() {
  [[ $(writes) == "$1" ]]
}

wait_for "monitor-sensor restarts after exiting early" monitor_running
pass "monitor-sensor restarts after exiting early"

[[ $(< "$TMPDIR/monitor-locale") == "C" ]] || fail "monitor-sensor runs in the C locale"
pass "monitor-sensor runs in the C locale"

# Dark: on. Further dark readings must not read the write back as a manual off.
echo "=== Has ambient light sensor (value: 1.000000, unit: lux)" >> "$TMPDIR/sensor"
sleep 0.4
sense 0
wait_for "turns on in the dark" writes_are "2"
for lux in 1 0 1; do sense "$lux"; sleep 0.1; done
sleep 0.3
manual_off_saved && fail "its own write is not taken as a manual off"
pass "its own write is not taken as a manual off"

# Bright: off. Further bright readings must not record a phantom level or off.
sense 70
sleep 0.4
sense 71
wait_for "turns off in bright light" writes_are "2 0"
for lux in 72 70 71; do sense "$lux"; sleep 0.1; done
sleep 0.3
manual_off_saved && fail "turning off is not taken as a manual off"
pass "turning off is not taken as a manual off"

# Dark again: back on, which a phantom manual off would have held off
sense 1
sleep 0.4
sense 0
wait_for "turns back on in the dark" writes_are "2 0 2"
pass "turns back on in the dark"

# Lock blanks while dark, the room turns bright, and wake restores the lit
# level: nothing is written while blanked, then it turns off from the light.
ipc pause
echo 0 > "$led/brightness"
sense 70
sleep 0.4
sense 71
sleep 0.5
writes_are "2 0 2" || fail "nothing is written while blanked" "writes: $(writes)"
pass "nothing is written while blanked"
echo 2 > "$led/brightness"
ipc resume
sense 72
sleep 0.4
sense 70
wait_for "decides again from the light after wake" writes_are "2 0 2 0"
manual_off_saved && fail "the blank is not taken as a manual off"
pass "decides again from the light after wake"

# Toggling off still releases the sensor after the early restart
touch "$TMPDIR/home/.local/state/omarchy/toggles/keyboard-backlight-auto-off"
ipc sync
wait_for "toggling off stops monitor-sensor" bash -c "! pgrep -f 'tail -n \+1 -f $TMPDIR/sensor' >/dev/null"
pass "toggling off stops monitor-sensor"
