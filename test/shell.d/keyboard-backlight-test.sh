#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

keyboard_command="$ROOT/bin/omarchy-brightness-keyboard"
keyboard_service="$ROOT/default/systemd/user/omarchy-keyboard-backlight.service"
first_run_units="$ROOT/install/user/first-run/enable-user-units.sh"
migration="$ROOT/migrations/1789840930.sh"
system_wake="$ROOT/bin/omarchy-system-wake"
lock_service="$ROOT/shell/plugins/lock/Service.qml"

bash -n "$keyboard_command"
bash -n "$migration"
grep -F '# omarchy:args=[--no-osd] <up|down|cycle|off|restore>' "$keyboard_command" >/dev/null
grep -F 'persist_brightness "$new_brightness"' "$keyboard_command" >/dev/null
grep -F 'restore_persisted || brightnessctl -rd "$device" >/dev/null' "$keyboard_command" >/dev/null
grep -Fx 'omarchy-brightness-keyboard restore' "$system_wake" >/dev/null
grep -F 'omarchy-brightness-keyboard off' "$lock_service" >/dev/null
! grep -F 'restore-persisted' "$keyboard_command" >/dev/null
! grep -F 'dbus-monitor' "$ROOT/bin/omarchy-brightness-keyboard" "$keyboard_service" >/dev/null
[[ ! -e $ROOT/bin/omarchy-keyboard-backlight-monitor ]] ||
  fail "keyboard backlight restore still has a dedicated sleep monitor"
pass "keyboard brightness persists user-selected levels and restores them on wake"

grep -Fx 'Type=oneshot' "$keyboard_service" >/dev/null
grep -Fx 'ExecStart=/usr/bin/omarchy-brightness-keyboard restore' "$keyboard_service" >/dev/null
grep -Fx 'WantedBy=graphical-session.target' "$keyboard_service" >/dev/null
grep -Fx 'After=graphical-session.target' "$keyboard_service" >/dev/null
grep -Fx 'ConditionPathExistsGlob=/sys/class/leds/*kbd_backlight*' "$keyboard_service" >/dev/null
grep -F 'omarchy-keyboard-backlight.service' "$first_run_units" >/dev/null
grep -F 'omarchy-keyboard-backlight.service' "$migration" >/dev/null
pass "keyboard brightness restore is a hardware-gated login oneshot"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mock_bin="$tmpdir/bin"
led_dir="$tmpdir/leds"
state_home="$tmpdir/state"
call_log="$tmpdir/calls"
current_file="$tmpdir/current"
saved_file="$tmpdir/saved"
max_file="$tmpdir/max"
mkdir -p "$mock_bin" "$led_dir/test::kbd_backlight" "$state_home"

printf '1\n' >"$current_file"
printf '1\n' >"$saved_file"
printf '2\n' >"$max_file"

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$CALL_LOG"

save=0
restore=0
device=""
action=""
value=""

while (( $# )); do
  case "$1" in
  -s)
    save=1
    shift
    ;;
  -r)
    restore=1
    shift
    ;;
  -d)
    device="$2"
    shift 2
    ;;
  -sd)
    save=1
    device="$2"
    shift 2
    ;;
  -rd)
    restore=1
    device="$2"
    shift 2
    ;;
  max)
    action="max"
    shift
    ;;
  get)
    action="get"
    shift
    ;;
  set)
    action="set"
    value="$2"
    shift 2
    ;;
  *)
    shift
    ;;
  esac
done

[[ $device == "test::kbd_backlight" ]] || exit 1

if (( restore )); then
  cat "$SAVED_FILE" >"$CURRENT_FILE"
  cat "$CURRENT_FILE"
  exit 0
fi

if [[ $action == "max" ]]; then
  cat "$MAX_FILE"
  exit 0
elif [[ $action == "get" ]]; then
  cat "$CURRENT_FILE"
  exit 0
elif [[ $action == "set" ]]; then
  (( save )) && cat "$CURRENT_FILE" >"$SAVED_FILE"
  printf '%s\n' "$value" >"$CURRENT_FILE"
  exit 0
fi

exit 1
SH
chmod +x "$mock_bin/brightnessctl"

sed "s|/sys/class/leds/\*kbd_backlight\*|$led_dir/*kbd_backlight*|" \
  "$keyboard_command" >"$tmpdir/omarchy-brightness-keyboard"
chmod +x "$tmpdir/omarchy-brightness-keyboard"

run_keyboard() {
  CALL_LOG="$call_log" \
    CURRENT_FILE="$current_file" \
    SAVED_FILE="$saved_file" \
    MAX_FILE="$max_file" \
    XDG_STATE_HOME="$state_home" \
    PATH="$mock_bin:$PATH" \
    "$tmpdir/omarchy-brightness-keyboard" --no-osd "$@"
}

state_path="$state_home/omarchy/keyboard-backlight"

: >"$call_log"
run_keyboard up
[[ $(<"$current_file") == 2 ]] || fail "up raises keyboard brightness" "actual: $(<"$current_file")"
[[ $(<"$state_path") == 2 ]] || fail "up persists the selected keyboard brightness" "actual: $(<"$state_path")"
pass "up persists the selected keyboard brightness"

printf '0\n' >"$current_file"
: >"$call_log"
run_keyboard restore
[[ $(<"$current_file") == 2 ]] || fail "restore prefers the persisted keyboard brightness" "actual: $(<"$current_file")"
! grep -Eq '(^|[[:space:]])(-r|-rd)($|[[:space:]])' "$call_log" ||
  fail "restore still uses brightnessctl -r when a persisted level exists"
pass "restore prefers the persisted keyboard brightness"

rm -f "$state_path"
printf '0\n' >"$current_file"
printf '1\n' >"$saved_file"
: >"$call_log"
run_keyboard restore
[[ $(<"$current_file") == 1 ]] || fail "restore falls back to brightnessctl without a persisted level" "actual: $(<"$current_file")"
grep -Eq '(^|[[:space:]])(-r|-rd)($|[[:space:]])' "$call_log" ||
  fail "restore does not fall back to brightnessctl without a persisted level"
pass "restore falls back to brightnessctl without a persisted level"

printf 'bogus\n' >"$state_path"
printf '0\n' >"$current_file"
printf '1\n' >"$saved_file"
run_keyboard restore
[[ $(<"$current_file") == 1 ]] || fail "restore falls back when the persisted level is invalid" "actual: $(<"$current_file")"
pass "restore falls back when the persisted level is invalid"

printf '2\n' >"$current_file"
printf '1\n' >"$saved_file"
printf '1\n' >"$state_path"
run_keyboard off
[[ $(<"$current_file") == 0 ]] || fail "off blanks the keyboard backlight" "actual: $(<"$current_file")"
[[ $(<"$state_path") == 1 ]] || fail "off overwrites a user-selected keyboard brightness" "actual: $(<"$state_path")"
[[ $(<"$saved_file") == 2 ]] || fail "off still saves via brightnessctl" "actual: $(<"$saved_file")"
pass "off blanks without overwriting a user-selected keyboard brightness"

rm -f "$state_path"
printf '2\n' >"$current_file"
run_keyboard off
[[ $(<"$state_path") == 2 ]] || fail "off seeds persist when no user-selected level exists" "actual: $(<"$state_path")"
pass "off seeds persist when no user-selected level exists"

printf '0\n' >"$current_file"
run_keyboard off
[[ $(<"$state_path") == 2 ]] || fail "a second off does not persist the blanked level" "actual: $(<"$state_path")"
pass "a second off does not persist the blanked level"
