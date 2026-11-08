#!/bin/bash

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
lid="$TMPDIR/lid/LID0/state"
runtime="$TMPDIR/run"
state_dir="$TMPDIR/home/.local/state/omarchy"
mkdir -p "$led" "$(dirname "$lid")" "$TMPDIR/bin" "$state_dir/toggles" "$TMPDIR/config" "$runtime"
chmod 700 "$runtime"
echo 0 > "$led/brightness"
echo 2 > "$led/max_brightness"
echo "state:      open" > "$lid"
: > "$TMPDIR/sensor"
: > "$TMPDIR/writes"
cp "$SHELL_TEST_DIR/fixtures/keyboard-backlight-auto/shell.qml" "$TMPDIR/config/shell.qml"
ln -s "$ROOT/shell/Commons" "$TMPDIR/config/Commons"
ln -s "$ROOT/shell/plugins" "$TMPDIR/config/plugins"

cat > "$TMPDIR/bin/omarchy-hw-ambient-light" <<'EOF'
#!/bin/bash
exit 0
EOF

# Like monitor-sensor, each start reports the current light ($TMPDIR/current)
# first, then streams whatever the test appends to $TMPDIR/sensor. The first
# run exits straight away, the way monitor-sensor does when the claim fails.
cat > "$TMPDIR/bin/monitor-sensor" <<EOF
#!/bin/bash
echo "\${LC_ALL:-unset}" > "$TMPDIR/monitor-locale"
if [[ ! -e $TMPDIR/monitor-started ]]; then
  touch "$TMPDIR/monitor-started"
  exit 1
fi
[[ -s $TMPDIR/current ]] && echo "=== Has ambient light sensor (value: \$(< "$TMPDIR/current").000000, unit: lux)"
exec tail -n 0 -f "$TMPDIR/sensor"
EOF

# Writes land a little after the call, like a real sysfs write through logind,
# and fail (counted in $TMPDIR/failures) while $TMPDIR/write-fails exists.
cat > "$TMPDIR/bin/brightnessctl" <<EOF
#!/bin/bash
if [[ -e $TMPDIR/write-fails ]]; then
  echo fail >> "$TMPDIR/failures"
  exit 1
fi
level=\${@: -1}
sleep 0.2
echo "\$level" > "$led/brightness"
echo "\$level" >> "$TMPDIR/writes"
EOF
chmod +x "$TMPDIR/bin/"*

start_shell() {
  OMARCHY_PATH="$ROOT" \
  OMARCHY_LEDS_PATH="$TMPDIR/leds" \
  OMARCHY_ACPI_LID_PATH="$TMPDIR/lid" \
  HOME="$TMPDIR/home" \
  XDG_RUNTIME_DIR="$runtime" \
  QT_QPA_PLATFORM=offscreen \
  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    quickshell -p "$TMPDIR/config" --no-color >> "$TMPDIR/quickshell.log" 2>&1 &
  QS_PID=$!
}

stop_shell() {
  kill "$QS_PID" 2>/dev/null || true
  wait "$QS_PID" 2>/dev/null || true
  QS_PID=""
  wait_for "monitor-sensor stops with the shell" monitor_stopped
}

ipc() {
  XDG_RUNTIME_DIR="$runtime" quickshell ipc --pid "$QS_PID" call omarchy.keyboard-backlight "$1" >/dev/null 2>&1
}

sense() {
  echo "    Light changed: $1.000000 (lux)" >> "$TMPDIR/sensor"
}

# Settles the room at a light level: two readings past the settle time.
settle() {
  sense "$1"
  sleep 0.4
  sense "$1"
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
  fail "$description" "writes: $(writes)"
}

monitor_running() {
  pgrep -f "tail -n 0 -f $TMPDIR/sensor" >/dev/null
}

monitor_stopped() {
  ! monitor_running
}

manual_off_saved() {
  [[ -s $state_dir/keyboard-backlight-manual-off ]]
}

manual_off_cleared() {
  ! manual_off_saved
}

failures() {
  if [[ -f $TMPDIR/failures ]]; then
    wc -l < "$TMPDIR/failures"
  else
    echo 0
  fi
}

failures_are() {
  (( $(failures) == $1 ))
}

writes_are() {
  [[ $(writes) == "$1" ]]
}

writes_stay() {
  sleep "${2:-0.8}"
  writes_are "$1"
}

start_shell
wait_for "monitor-sensor restarts after exiting early" monitor_running
pass "monitor-sensor restarts after exiting early"

[[ $(< "$TMPDIR/monitor-locale") == "C" ]] || fail "monitor-sensor runs in the C locale"
pass "monitor-sensor runs in the C locale"

# Dark: on. Further dark readings must not read the write back as a manual off.
echo "=== Has ambient light sensor (value: 1.000000, unit: lux)" >> "$TMPDIR/sensor"
sleep 0.4
sense 0
wait_for "turns on in the dark" writes_are "2"
# One reading only: a stale read would record a phantom off here, and a later
# reading would clear it again before the check.
sense 1
sleep 0.4
manual_off_saved && fail "its own write is not taken as a manual off"
pass "its own write is not taken as a manual off"

# Bright: off. Further bright readings must not record a phantom level or off.
settle 70
wait_for "turns off in bright light" writes_are "2 0"
for lux in 72 70 71; do sense "$lux"; sleep 0.1; done
sleep 0.3
manual_off_saved && fail "turning off is not taken as a manual off"
pass "turning off is not taken as a manual off"

# Dark again: back on, which a phantom manual off would have held off
settle 1
wait_for "turns back on in the dark" writes_are "2 0 2"
pass "turns back on in the dark"

# Lock blanks while dark, the room turns bright, and wake restores the lit
# level: nothing is written while blanked, then it turns off from the light.
ipc pause
echo 0 > "$led/brightness"
settle 70
writes_stay "2 0 2" 0.5 || fail "nothing is written while blanked" "writes: $(writes)"
pass "nothing is written while blanked"
echo 2 > "$led/brightness"
ipc resume
settle 72
wait_for "decides again from the light after wake" writes_are "2 0 2 0"
manual_off_saved && fail "the blank is not taken as a manual off"
pass "decides again from the light after wake"

# Steady dark, then the keys turn it off and the session locks before the
# sensor reports anything new: the off is kept through blank and wake.
settle 1
wait_for "turns on in the dark before locking" writes_are "2 0 2 0 2"
echo 0 > "$led/brightness"
ipc pause
echo 0 > "$led/brightness"
echo 0 > "$led/brightness"
ipc resume
writes_stay "2 0 2 0 2" || fail "a key press made just before locking is kept at wake" "writes: $(writes)"
manual_off_saved || fail "a key press made just before locking is held as a manual off"
pass "a key press made just before locking is kept at wake"

# The keys turn it back on; then a wake restores an old level without a blank
# before it. That level is the session's, so it decides again from the light.
echo 2 > "$led/brightness"
sense 1
wait_for "turning it back on with the keys clears the hold" manual_off_cleared
echo 0 > "$led/brightness"
ipc resume
wait_for "a restore without a blank is not taken as the user's" writes_are "2 0 2 0 2 2"
manual_off_saved && fail "a restore without a blank is not held as a manual off"
pass "a restore without a blank is not taken as the user's"

# Steady dark, and the keys turn it off: `omarchy-brightness-keyboard` nudges
# a refresh, so the off is saved at once rather than at the next reading.
echo 0 > "$led/brightness"
ipc refresh
manual_off_saved || fail "a key press in steady light is saved at once"
pass "a key press in steady light is saved at once"
echo 2 > "$led/brightness"
ipc refresh
manual_off_saved && fail "turning it back on with the keys clears the saved hold at once"
pass "turning it back on with the keys clears the saved hold at once"

# Bright, then the lid closes (docked) and the sensor reads dark under it:
# nothing changes while it's closed.
settle 70
wait_for "turns off in bright light before the lid closes" writes_are "2 0 2 0 2 2 0"
echo "state:      closed" > "$lid"
ipc lid
sleep 0.3
settle 0
writes_stay "2 0 2 0 2 2 0" || fail "nothing is lit under a closed lid" "writes: $(writes)"
pass "nothing is lit under a closed lid"

# The lid opens in a bright room. The last reading came from under the lid, so
# the light is read afresh rather than acted on.
echo 70 > "$TMPDIR/current"
echo "state:      open" > "$lid"
ipc lid
writes_stay "2 0 2 0 2 2 0" || fail "the reading taken under the lid is not used once it opens" "writes: $(writes)"
pass "the reading taken under the lid is not used once it opens"

# Closed again, then opened in the dark: on, from the fresh reading alone.
echo "state:      closed" > "$lid"
ipc lid
sleep 0.3
echo 0 > "$TMPDIR/current"
echo "state:      open" > "$lid"
ipc lid
wait_for "decides from the light once the lid opens" writes_are "2 0 2 0 2 2 0 2"
pass "decides from the light once the lid opens"

# A write that fails leaves the level where it was. That isn't the user's
# choice, so it must not be held as a manual off.
settle 70
wait_for "turns off before a failing write" writes_are "2 0 2 0 2 2 0 2 0"
touch "$TMPDIR/write-fails"
settle 1
wait_for "the write fails" failures_are 1
sleep 0.2
manual_off_saved && fail "a failed write is not taken as a manual off"
pass "a failed write is not taken as a manual off"

# In steady light nothing else would decide again, so it's retried, but only a
# few times.
wait_for "a failed write is retried" failures_are 4
sleep 1.5
failures_are 4 || fail "a failed write is retried a bounded number of times" "failures: $(failures)"
pass "a failed write is retried a bounded number of times"
rm "$TMPDIR/write-fails"
settle 0
wait_for "turns on once writes work again" writes_are "2 0 2 0 2 2 0 2 0 2"
pass "turns on once writes work again"

# A write that fails once and then works lands with no new reading.
touch "$TMPDIR/write-fails"
settle 70
wait_for "the write to turn off fails" failures_are 5
rm "$TMPDIR/write-fails"
wait_for "a failed write is retried until it lands" writes_are "2 0 2 0 2 2 0 2 0 2 0"
pass "a failed write is retried until it lands"
settle 0
wait_for "turns back on in the dark after the retry" writes_are "2 0 2 0 2 2 0 2 0 2 0 2"

# The keys turn it off in steady dark, and the shell restarts before anything
# saw it (firmware-handled keys announce nothing): the off is still held.
echo 0 > "$led/brightness"
stop_shell
rm -f "$state_dir/keyboard-backlight-manual-off"
start_shell
wait_for "monitor-sensor starts again" monitor_running
settle 0
writes_stay "2 0 2 0 2 2 0 2 0 2 0 2" || fail "an off made while the shell was down is held" "writes: $(writes)"
manual_off_saved || fail "an off made while the shell was down is saved"
pass "an off made while the shell was down is held"

# A shell restarted while the session has the keys blanked leaves them alone
# until the wake.
echo 2 > "$led/brightness"
ipc refresh
manual_off_saved && fail "turning it back on before the blank clears the hold"
echo 2 > "$runtime/omarchy-brightness-keyboard-test::kbd_backlight"
echo 0 > "$led/brightness"
stop_shell
start_shell
wait_for "monitor-sensor starts while blanked" monitor_running
settle 70
sleep 0.4
settle 0
writes_stay "2 0 2 0 2 2 0 2 0 2 0 2" || fail "a shell restarted while blanked writes nothing" "writes: $(writes)"
manual_off_saved && fail "a shell restarted while blanked does not take the blank as a manual off"
pass "a shell restarted while blanked writes nothing"
rm "$runtime/omarchy-brightness-keyboard-test::kbd_backlight"
echo 2 > "$led/brightness"
ipc resume
settle 70
wait_for "decides again after the wake" writes_are "2 0 2 0 2 2 0 2 0 2 0 2 0"
pass "decides again after the wake"

# Toggling off still releases the sensor after the early restart
touch "$state_dir/toggles/keyboard-backlight-auto-off"
ipc sync
wait_for "toggling off stops monitor-sensor" monitor_stopped
pass "toggling off stops monitor-sensor"
