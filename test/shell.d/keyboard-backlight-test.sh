#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

keyboard_command="$ROOT/bin/omarchy-brightness-keyboard"
watcher="$ROOT/bin/omarchy-thinkpad-keyboard-backlight"
keyboard_service="$ROOT/default/systemd/user/omarchy-thinkpad-keyboard-backlight.service"
first_run_units="$ROOT/install/user/first-run/enable-user-units.sh"
migration="$ROOT/migrations/1789840930.sh"

bash -n "$keyboard_command"
bash -n "$migration"
if grep -F 'persist_brightness' "$keyboard_command"; then
  fail "keyboard brightness persists every up/down/cycle"
fi
if grep -F 'ConditionPathExistsGlob=/sys/class/leds/*kbd_backlight*' "$keyboard_service"; then
  fail "ThinkPad backlight unit matches every keyboard LED"
fi
grep -F 'ConditionPathExists=/sys/class/leds/tpacpi::kbd_backlight/brightness_hw_changed' "$keyboard_service" >/dev/null
grep -Fx 'Restart=on-failure' "$keyboard_service" >/dev/null
grep -F 'omarchy-thinkpad-keyboard-backlight.service' "$first_run_units" >/dev/null
grep -F 'omarchy-thinkpad-keyboard-backlight.service' "$migration" >/dev/null
if grep -F 'omarchy-keyboard-backlight.service' "$first_run_units" "$migration" "$keyboard_service"; then
  fail "old generic keyboard backlight unit name is still wired"
fi
[[ ! -e $ROOT/default/systemd/user/omarchy-keyboard-backlight.service ]] ||
  fail "generic keyboard backlight unit file is still present"
pass "ThinkPad keyboard backlight wiring is limited to tpacpi"

unit_root=$(mktemp -d)
OMARCHY_THINKPAD_KBD_UNIT_ROOT="$unit_root" "$watcher" --unit >/dev/null
rm -rf "$unit_root"
pass "ThinkPad backlight watcher drops paused and suppressed levels"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mock_bin="$tmpdir/bin"
led_root="$tmpdir/leds"
led_dir="$led_root/tpacpi::kbd_backlight"
other_dir="$tmpdir/other-leds/other::kbd_backlight"
state_home="$tmpdir/state"
runtime="$tmpdir/runtime"
call_log="$tmpdir/calls"
current_file="$led_dir/brightness"
mkdir -p "$mock_bin" "$led_dir" "$other_dir" "$state_home" "$runtime"
printf '0\n' >"$current_file"
printf '2\n' >"$led_dir/max_brightness"
printf '0\n' >"$led_dir/brightness_hw_changed"
printf '0\n' >"$other_dir/brightness"
printf '2\n' >"$other_dir/max_brightness"

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
device=""
action=""
value=""
restore=0
while (( $# )); do
  case "$1" in
  -r|-rd) restore=1; shift ;;
  -d) device="$2"; shift 2 ;;
  -s|-sd) shift; [[ $1 == -* ]] || true ;;
  max) action=max; shift ;;
  get) action=get; shift ;;
  set) action=set; value="$2"; shift 2 ;;
  *) shift ;;
  esac
done
if (( restore )); then
  printf 'restored\n' >"$CURRENT_FILE"
  exit 0
fi
if [[ $action == max ]]; then
  cat "$MAX_FILE"
elif [[ $action == get ]]; then
  cat "$CURRENT_FILE"
elif [[ $action == set ]]; then
  printf '%s\n' "$value" >"$CURRENT_FILE"
else
  exit 1
fi
SH
chmod +x "$mock_bin/brightnessctl" "$watcher" "$keyboard_command"

sed "s|^leds_root=/sys/class/leds|leds_root=$led_root|" \
  "$keyboard_command" >"$tmpdir/omarchy-brightness-keyboard"
chmod +x "$tmpdir/omarchy-brightness-keyboard"

run_keyboard() {
  CALL_LOG="$call_log" \
    CURRENT_FILE="$current_file" \
    MAX_FILE="$led_dir/max_brightness" \
    XDG_STATE_HOME="$state_home" \
    XDG_RUNTIME_DIR="$runtime" \
    OMARCHY_THINKPAD_KBD_LED_DIR="$led_dir" \
    OMARCHY_THINKPAD_KBD_STATE="$state_home/omarchy/keyboard-backlight" \
    OMARCHY_THINKPAD_KBD_LOCK="$state_home/omarchy/keyboard-backlight.lock" \
    OMARCHY_THINKPAD_KBD_SUPPRESS="$runtime/suppress" \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$tmpdir/omarchy-brightness-keyboard" --no-osd "$@"
}

state_path="$state_home/omarchy/keyboard-backlight"
mkdir -p "$(dirname "$state_path")"
: >"$call_log"
printf '2\n' >"$state_path"
printf '0\n' >"$current_file"
run_keyboard restore
[[ $(<"$current_file") == 2 ]] || fail "ThinkPad restore writes the saved firmware level" "actual: $(<"$current_file")"
if grep -Eq '(^|[[:space:]])(-r|-rd)($|[[:space:]])' "$call_log"; then
  fail "ThinkPad restore falls back to brightnessctl -r when a saved level exists"
fi
pass "ThinkPad restore writes the saved firmware level"

rm -f "$state_path"
: >"$call_log"
printf '0\n' >"$current_file"
run_keyboard restore
[[ $(<"$current_file") == restored ]] || fail "ThinkPad restore without a saved level uses brightnessctl" "actual: $(<"$current_file")"
pass "ThinkPad restore without a saved level uses brightnessctl"

printf 'bogus\n' >"$state_path"
: >"$call_log"
printf '0\n' >"$current_file"
run_keyboard restore
[[ $(<"$current_file") == restored ]] || fail "invalid ThinkPad saved level falls back to brightnessctl" "actual: $(<"$current_file")"
pass "invalid ThinkPad saved level falls back to brightnessctl"

printf '9\n' >"$state_path"
: >"$call_log"
printf '0\n' >"$current_file"
run_keyboard restore
[[ $(<"$current_file") == restored ]] || fail "out-of-range ThinkPad saved level falls back to brightnessctl" "actual: $(<"$current_file")"
pass "out-of-range ThinkPad saved level falls back to brightnessctl"

other_current="$other_dir/brightness"
sed "s|^leds_root=/sys/class/leds|leds_root=$tmpdir/other-leds|" \
  "$keyboard_command" >"$tmpdir/other-keyboard"
chmod +x "$tmpdir/other-keyboard"
: >"$call_log"
printf '2\n' >"$state_path"
printf '0\n' >"$other_current"
CALL_LOG="$call_log" \
  CURRENT_FILE="$other_current" \
  MAX_FILE="$other_dir/max_brightness" \
  XDG_STATE_HOME="$state_home" \
  PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$tmpdir/other-keyboard" --no-osd restore
[[ $(<"$other_current") == restored ]] || fail "non-ThinkPad restore ignores the ThinkPad state file" "actual: $(<"$other_current")"
pass "non-ThinkPad restore ignores the ThinkPad state file"

both_root="$tmpdir/both-leds"
both_tpacpi="$both_root/tpacpi::kbd_backlight"
both_other="$both_root/other::kbd_backlight"
mkdir -p "$both_tpacpi" "$both_other"
printf '0\n' >"$both_tpacpi/brightness"
printf '2\n' >"$both_tpacpi/max_brightness"
printf '0\n' >"$both_other/brightness"
printf '2\n' >"$both_other/max_brightness"
sed "s|^leds_root=/sys/class/leds|leds_root=$both_root|" \
  "$keyboard_command" >"$tmpdir/both-keyboard"
chmod +x "$tmpdir/both-keyboard"
: >"$call_log"
printf '2\n' >"$state_path"
CALL_LOG="$call_log" \
  CURRENT_FILE="$both_tpacpi/brightness" \
  MAX_FILE="$both_tpacpi/max_brightness" \
  XDG_STATE_HOME="$state_home" \
  XDG_RUNTIME_DIR="$runtime" \
  OMARCHY_THINKPAD_KBD_LED_DIR="$both_tpacpi" \
  OMARCHY_THINKPAD_KBD_STATE="$state_path" \
  OMARCHY_THINKPAD_KBD_LOCK="$state_home/omarchy/keyboard-backlight.lock" \
  OMARCHY_THINKPAD_KBD_SUPPRESS="$runtime/suppress" \
  PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$tmpdir/both-keyboard" --no-osd restore
grep -F -- '-d tpacpi::kbd_backlight set 2' "$call_log" >/dev/null ||
  fail "restore does not prefer tpacpi::kbd_backlight when another keyboard LED exists" "$(cat "$call_log")"
pass "restore prefers tpacpi::kbd_backlight when another keyboard LED exists"

seed_led="$tmpdir/seed-led"
mkdir -p "$seed_led"
printf '2\n' >"$seed_led/max_brightness"
printf '2\n' >"$seed_led/brightness"
printf '2\n' >"$seed_led/brightness_hw_changed"
seed_state="$tmpdir/seed-state"
seed_event="$tmpdir/seed-events"
seed_dbus="$tmpdir/seed-dbus"
mkfifo "$seed_event" "$seed_dbus"
rm -f "$seed_state"
OMARCHY_THINKPAD_KBD_LED_DIR="$seed_led" \
  OMARCHY_THINKPAD_KBD_STATE="$seed_state" \
  OMARCHY_THINKPAD_KBD_LOCK="$tmpdir/seed.lock" \
  OMARCHY_THINKPAD_KBD_SUPPRESS="$tmpdir/seed.suppress" \
  OMARCHY_THINKPAD_KBD_EVENT_FIFO="$seed_event" \
  OMARCHY_THINKPAD_KBD_DBUS_FIFO="$seed_dbus" \
  CALL_LOG="$call_log" \
  CURRENT_FILE="$seed_led/brightness" \
  MAX_FILE="$seed_led/max_brightness" \
  PATH="$mock_bin:$PATH" \
  "$watcher" &
seed_pid=$!
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ -f $seed_state && $(<"$seed_state") == 2 ]] && break
  sleep 0.05
done
kill "$seed_pid" 2>/dev/null || true
wait "$seed_pid" 2>/dev/null || true
[[ $(<"$seed_state") == 2 ]] || fail "watcher does not seed a missing state file from a live non-zero level" "actual: $(cat "$seed_state" 2>/dev/null || echo missing)"
pass "watcher seeds a missing state file from a live non-zero level"

printf '0\n' >"$seed_led/brightness"
rm -f "$seed_state"
OMARCHY_THINKPAD_KBD_LED_DIR="$seed_led" \
  OMARCHY_THINKPAD_KBD_STATE="$seed_state" \
  OMARCHY_THINKPAD_KBD_LOCK="$tmpdir/seed.lock" \
  OMARCHY_THINKPAD_KBD_SUPPRESS="$tmpdir/seed.suppress" \
  OMARCHY_THINKPAD_KBD_EVENT_FIFO="$seed_event" \
  OMARCHY_THINKPAD_KBD_DBUS_FIFO="$seed_dbus" \
  CALL_LOG="$call_log" \
  CURRENT_FILE="$seed_led/brightness" \
  MAX_FILE="$seed_led/max_brightness" \
  PATH="$mock_bin:$PATH" \
  "$watcher" &
seed_pid=$!
sleep 0.2
kill "$seed_pid" 2>/dev/null || true
wait "$seed_pid" 2>/dev/null || true
if [[ -e $seed_state ]]; then
  fail "watcher seeds 0 into a missing state file" "actual: $(<"$seed_state")"
fi
pass "watcher does not seed 0 into a missing state file"

event_fifo="$tmpdir/events"
dbus_fifo="$tmpdir/dbus"
mkfifo "$event_fifo" "$dbus_fifo"
printf '2\n' >"$state_path"
printf '0\n' >"$current_file"
: >"$call_log"
OMARCHY_THINKPAD_KBD_LED_DIR="$led_dir" \
  OMARCHY_THINKPAD_KBD_STATE="$state_path" \
  OMARCHY_THINKPAD_KBD_LOCK="$state_home/omarchy/keyboard-backlight.lock" \
  OMARCHY_THINKPAD_KBD_SUPPRESS="$runtime/suppress" \
  OMARCHY_THINKPAD_KBD_EVENT_FIFO="$event_fifo" \
  OMARCHY_THINKPAD_KBD_DBUS_FIFO="$dbus_fifo" \
  OMARCHY_THINKPAD_KBD_DEBOUNCE=0.05 \
  OMARCHY_THINKPAD_KBD_RESUME_DELAY=0.05 \
  OMARCHY_THINKPAD_KBD_SUPPRESS_S=0.2 \
  CALL_LOG="$call_log" \
  CURRENT_FILE="$current_file" \
  MAX_FILE="$led_dir/max_brightness" \
  PATH="$mock_bin:$PATH" \
  "$watcher" &
watcher_pid=$!
cleanup_watcher() {
  kill "$watcher_pid" 2>/dev/null || true
  wait "$watcher_pid" 2>/dev/null || true
}
trap 'cleanup_watcher; rm -rf "$tmpdir"' EXIT

for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ $(<"$current_file") == 2 ]] && break
  sleep 0.05
done
[[ $(<"$current_file") == 2 ]] || fail "watcher restores the saved level when it starts" "actual: $(<"$current_file")"
pass "watcher restores the saved level when it starts"

printf '1\n' >"$event_fifo"
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ $(<"$state_path") == 1 ]] && break
  sleep 0.05
done
[[ $(<"$state_path") == 1 ]] || fail "watcher stores a firmware level after debounce" "actual: $(<"$state_path")"
pass "watcher stores a firmware level after debounce"

printf 'boolean true\n' >"$dbus_fifo"
sleep 0.05
printf '0\n' >"$event_fifo"
sleep 0.12
[[ $(<"$state_path") == 1 ]] || fail "watcher stores a firmware level during suspend" "actual: $(<"$state_path")"
printf 'boolean false\n' >"$dbus_fifo"
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ $(<"$current_file") == 1 ]] && break
  sleep 0.05
done
[[ $(<"$current_file") == 1 ]] || fail "watcher restores after resume" "actual: $(<"$current_file")"
pass "watcher ignores firmware events across suspend and restores after resume"

printf '1\n' >"$event_fifo"
sleep 0.08
[[ $(<"$state_path") == 1 ]] || fail "watcher stores the level it just restored" "actual: $(<"$state_path")"
printf '0\n' >"$event_fifo"
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ $(<"$state_path") == 0 ]] && break
  sleep 0.05
done
[[ $(<"$state_path") == 0 ]] || fail "a different firmware level during suppress is kept" "actual: $(<"$state_path")"
pass "a different firmware level during suppress is kept"

cleanup_watcher
trap 'rm -rf "$tmpdir"' EXIT
pass "ThinkPad keyboard backlight watcher"
