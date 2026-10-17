#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-brightness-auto"
shipped_unit="$ROOT/default/systemd/user/omarchy-brightness-auto.service"

[[ -x $script ]] || fail "automatic brightness command is installed"
source "$script"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

generic_sensor="$test_tmp/iio/iio:device0"
apple_sensor="$test_tmp/devices/usb/1-1/1-1:1.8/iio:device1"
mkdir -p "$generic_sensor" "$apple_sensor"
printf '50\n' >"$generic_sensor/in_illuminance_input"
printf '05ac\n' >"$test_tmp/devices/usb/1-1/idVendor"
printf '1114\n' >"$test_tmp/devices/usb/1-1/idProduct"
printf '10\n' >"$apple_sensor/in_illuminance_raw"
printf '0.5\n' >"$apple_sensor/in_illuminance_offset"
printf '2\n' >"$apple_sensor/in_illuminance_scale"
ln -s "$apple_sensor" "$test_tmp/iio/iio:device1"

read -r sensor kind < <(find_sensor "$test_tmp/iio")
[[ $sensor == $test_tmp/iio/iio:device1 && $kind == "apple" ]] ||
  fail "Apple ambient sensor is preferred when several sensors exist"
[[ $(read_lux "$sensor") == "21" ]] || fail "raw sensor values use their IIO offset and scale"
[[ $(curve_brightness 200) == "30" ]] || fail "brightness curve keeps its calibrated midpoint"
[[ $(target_with_offset "$(curve_brightness 3276800)" -46) == "89" ]] ||
  fail "a manual baseline does not cap bright-light headroom"
[[ $(smooth_lux 100 200) == "125" ]] || fail "ambient readings are smoothed"
[[ $(smooth_lux 200.005 200) == "200" ]] || fail "smoothing settles on a steady reading"
[[ $(step_toward 45 35) == "38" ]] || fail "brightness changes are capped per poll"
reading_changed 172800 172900 && fail "sensor jitter under 1% is no change"
reading_changed 172800 175000 || fail "a light change over 1% is a change"
reading_changed 5 6 || fail "a small change in dim light is a change"
reading_changed 12.5 bad || fail "a reading that is not a number is a change"
reading_changed 0.1 0.9 || fail "a fractional change in dark light is a change"
reading_changed 12.5 12.55 && fail "fractional jitter under 1% is no change"
pass "automatic brightness sensor and curve behavior"

(
  lux_read_count="$test_tmp/lux-read-count"
  sleep_count="$test_tmp/contention-sleep-count"
  contention_channel="$test_tmp/contention-channel"
  write_count="$test_tmp/contention-write-count"
  contention_writes="$test_tmp/contention-writes"
  printf '0\n' >"$lux_read_count"
  printf '0\n' >"$sleep_count"
  printf '0\n' >"$contention_channel"
  printf '0\n' >"$write_count"
  : >"$contention_writes"
  smoothing_new_weight=1

  read_lux() {
    local count=""
    read -r count <"$lux_read_count"
    printf '%s\n' "$(( count + 1 ))" >"$lux_read_count"
    (( count == 0 )) && printf '200\n' || printf '240\n'
  }
  read_brightness() { printf '30\n'; }
  select_monitor() { printf 'eDP-1\n'; }
  find_illuminance_channel() { printf '%s\n' "$contention_channel"; }
  log_state() { :; }
  wait_for_tick() {
    local count=""
    read -r count <"$sleep_count"
    (( count < 2 )) || return 1
    printf '%s\n' "$(( count + 1 ))" >"$sleep_count"
    printf '%s\n' "$(( count + 1 ))" >"$contention_channel"
  }
  write_brightness() {
    local count=""
    read -r count <"$write_count"
    printf '%s\n' "$2" >>"$contention_writes"
    printf '%s\n' "$(( count + 1 ))" >"$write_count"
    (( count > 0 )) || return 75
  }

  control_session ignored generic eDP-1
  [[ $(cat "$contention_writes") == $'32\n32' ]] ||
    fail "a contended automatic write retries without advancing its brightness state"
)
pass "automatic brightness retries a contended write"

(
  sleep_count="$test_tmp/steady-retry-sleep-count"
  steady_channel="$test_tmp/steady-retry-channel"
  write_count="$test_tmp/steady-retry-write-count"
  steady_writes="$test_tmp/steady-retry-writes"
  printf '0\n' >"$sleep_count"
  printf '200\n' >"$steady_channel"
  printf '0\n' >"$write_count"
  : >"$steady_writes"
  smoothing_new_weight=1

  read_lux() { cat "$steady_channel"; }
  read_brightness() { printf '30\n'; }
  select_monitor() { printf 'eDP-1\n'; }
  find_illuminance_channel() { printf '%s\n' "$steady_channel"; }
  log_state() { :; }
  wait_for_tick() {
    local count=""
    read -r count <"$sleep_count"
    (( count < 2 )) || return 1
    printf '%s\n' "$(( count + 1 ))" >"$sleep_count"
    printf '240\n' >"$steady_channel"
  }
  write_brightness() {
    local count=""
    read -r count <"$write_count"
    printf '%s\n' "$2" >>"$steady_writes"
    printf '%s\n' "$(( count + 1 ))" >"$write_count"
    (( count > 0 )) || return 75
  }

  control_session ignored generic eDP-1
  [[ $(cat "$steady_writes") == $'32\n32' ]] ||
    fail "a contended automatic write retries after the light settles"
)
pass "automatic brightness retries a contended write after the light settles"

(
  sleep_count="$test_tmp/manual-sleep-count"
  manual_channel="$test_tmp/manual-channel"
  manual_brightness="$test_tmp/manual-brightness"
  manual_writes="$test_tmp/manual-writes"
  printf '0\n' >"$sleep_count"
  printf '200\n' >"$manual_channel"
  printf '30\n' >"$manual_brightness"
  : >"$manual_writes"

  read_lux() { cat "$manual_channel"; }
  read_brightness() { cat "$manual_brightness"; }
  select_monitor() { printf 'eDP-1\n'; }
  find_illuminance_channel() { printf '%s\n' "$manual_channel"; }
  log_state() { :; }
  wait_for_tick() {
    local count=""
    read -r count <"$sleep_count"
    (( count < 8 )) || return 1
    printf '%s\n' "$(( count + 1 ))" >"$sleep_count"
    (( count == 0 )) && printf '3200\n' >"$manual_channel"
    (( count == 1 )) && printf '40\n' >"$manual_brightness"
    true
  }
  write_brightness() {
    printf '%s\n' "$2" >>"$manual_writes"
    printf '%s\n' "$2" >"$manual_brightness"
  }

  control_session ignored generic eDP-1
  [[ $(cat "$manual_brightness") == "40" ]] ||
    fail "a manual change during a ramp is the new baseline" "writes: $(paste -sd ' ' "$manual_writes")"
)
pass "a manual change during a ramp is the new baseline"

indexed_sensor="$test_tmp/iio-indexed/iio:device0"
mkdir -p "$indexed_sensor"
printf '10\n' >"$indexed_sensor/in_illuminance0_raw"
printf '0.5\n' >"$indexed_sensor/in_illuminance0_offset"
printf '2\n' >"$indexed_sensor/in_illuminance_scale"
if ! read -r sensor kind < <(find_sensor "$test_tmp/iio-indexed"); then
  fail "indexed IIO illuminance channels are discovered"
fi
[[ $sensor == $indexed_sensor && $kind == "generic" ]] ||
  fail "indexed IIO illuminance channels are discovered"
[[ $(read_lux "$sensor") == "21" ]] ||
  fail "indexed IIO channels use channel and shared calibration attributes"
pass "automatic brightness supports indexed IIO illuminance channels"

mock_bin="$test_tmp/bin"
systemctl_state="$test_tmp/systemctl-state"
systemctl_calls="$test_tmp/systemctl-calls"
monitors_file="$test_tmp/monitors.json"
mkdir -p "$mock_bin"
printf 'disabled inactive\n' >"$systemctl_state"
printf '%s\n' '[{"name":"eDP-1","make":"BOE","model":"Panel","disabled":false}]' >"$monitors_file"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
[[ ${1:-} == "monitors" && ${2:-} == "-j" ]] || exit 1
cat "$MONITORS_FILE"
SH

cat >"$mock_bin/omarchy-brightness-display" <<'SH'
#!/bin/bash
[[ ${BRIGHTNESS_AVAILABLE:-1} == "1" ]] || exit 1
if (( $# == 2 )) && [[ $1 == "--monitor" ]]; then
  printf '%s\n' "${BRIGHTNESS_VALUE:-30}"
elif (( $# == 5 )) && [[ $1 == "--no-osd" && $2 == "--monitor" && $5 == "--nonblocking" ]]; then
  printf '%s\n' "$*" >>"$BRIGHTNESS_WRITES"
else
  exit 2
fi
SH

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
read -r enabled active <"$SYSTEMCTL_STATE"
case "$*" in
  "--user daemon-reload") ;;
  "--user is-enabled --quiet omarchy-brightness-auto.service") [[ $enabled == "enabled" ]] ;;
  "--user is-active --quiet omarchy-brightness-auto.service") [[ $active == "active" ]] ;;
  "--user enable --now omarchy-brightness-auto.service")
    printf 'enabled active\n' >"$SYSTEMCTL_STATE"
    printf '%s\n' "$*" >>"$SYSTEMCTL_CALLS"
    ;;
  "--user disable --now omarchy-brightness-auto.service")
    printf 'disabled inactive\n' >"$SYSTEMCTL_STATE"
    printf '%s\n' "$*" >>"$SYSTEMCTL_CALLS"
    ;;
  *) exit 2 ;;
esac
SH
chmod +x "$mock_bin"/*

brightness_writes="$test_tmp/brightness-writes"
: >"$brightness_writes"
if ! BRIGHTNESS_WRITES="$brightness_writes" PATH="$mock_bin:$PATH" write_brightness eDP-1 31; then
  fail "automatic brightness keeps silent writes compatible with older display commands"
fi
grep -Fx -- '--no-osd --monitor eDP-1 31% --nonblocking' "$brightness_writes" >/dev/null ||
  fail "automatic brightness keeps silent writes compatible with older display commands"
pass "automatic brightness keeps silent writes compatible with older display commands"

run_auto() {
  XDG_CONFIG_HOME="$test_tmp/config" OMARCHY_PATH="$ROOT" \
    OMARCHY_AUTO_BRIGHTNESS_IIO_ROOT="${AUTO_IIO_ROOT:-$test_tmp/iio-generic}" \
    SYSTEMCTL_STATE="$systemctl_state" SYSTEMCTL_CALLS="$systemctl_calls" \
    MONITORS_FILE="$monitors_file" BRIGHTNESS_WRITES="$test_tmp/brightness-writes" \
    PATH="$mock_bin:$PATH" "$script" "$@"
}

mkdir -p "$test_tmp/iio-generic/iio:device0"
printf '200\n' >"$test_tmp/iio-generic/iio:device0/in_illuminance_input"

status=$(run_auto status)
jq -e '.supported == true and .enabled == false and .active == false' <<<"$status" >/dev/null ||
  fail "automatic brightness reports supported disabled state" "$status"
status=$(BRIGHTNESS_AVAILABLE=0 run_auto status)
jq -e '.supported == false' <<<"$status" >/dev/null ||
  fail "automatic brightness hides when its mapped display is not controllable" "$status"

printf '%s\n' '[
  {"name":"DP-1","make":"Apple Computer Inc","model":"StudioDisplay","disabled":false},
  {"name":"DP-3","make":"Apple Computer Inc","model":"StudioDisplay","disabled":false}
]' >"$monitors_file"
status=$(AUTO_IIO_ROOT="$test_tmp/iio" run_auto status)
jq -e '.supported == true' <<<"$status" >/dev/null ||
  fail "automatic brightness supports a group of Apple displays" "$status"

installed_unit="$test_tmp/config/systemd/user/omarchy-brightness-auto.service"
run_auto on
cmp -s "$shipped_unit" "$installed_unit" || fail "turning automatic brightness on installs its unit"
run_auto toggle
[[ ! -e $installed_unit ]] || fail "turning automatic brightness off removes its unit"
grep -Fx -- '--user enable --now omarchy-brightness-auto.service' "$systemctl_calls" >/dev/null ||
  fail "automatic brightness can be enabled"
grep -Fx -- '--user disable --now omarchy-brightness-auto.service' "$systemctl_calls" >/dev/null ||
  fail "automatic brightness can be disabled"
pass "automatic brightness exposes persistent service controls"

session_sensor="$test_tmp/session-sensor"
tick_count="$test_tmp/tick-count"
mkdir -p "$session_sensor"
printf '200\n' >"$session_sensor/in_illuminance_input"
printf '0\n' >"$tick_count"
: >"$brightness_writes"
(
  wait_for_tick() {
    local count=""
    read -r count <"$tick_count"
    (( count == 0 )) || return 1
    printf '1\n' >"$tick_count"
    printf '[]\n' >"$monitors_file"
    monitors_changed=1
  }

  if MONITORS_FILE="$monitors_file" BRIGHTNESS_WRITES="$brightness_writes" \
    PATH="$mock_bin:$PATH" control_session "$session_sensor" generic eDP-1 2>/dev/null; then
    fail "automatic brightness detects display loss under steady light"
  fi
)
[[ ! -s $brightness_writes ]] || fail "display loss does not write a stale brightness target"
pass "automatic brightness remaps after display loss under steady light"

printf '0\n' >"$tick_count"
lux_reads="$test_tmp/steady-lux-reads"
: >"$lux_reads"
(
  wait_for_tick() {
    local count=""
    read -r count <"$tick_count"
    (( count < 3 )) || return 1
    printf '%s\n' "$(( count + 1 ))" >"$tick_count"
  }
  read_lux() {
    printf 'read\n' >>"$lux_reads"
    printf '200\n'
  }
  read_brightness() { printf '30\n'; }
  select_monitor() { printf 'eDP-1\n'; }
  log_state() { :; }

  control_session "$session_sensor" generic eDP-1 || true
)
(( $(wc -l <"$lux_reads") == 1 )) || fail "steady light reads only the raw sensor value on each poll"
pass "steady light reads only the raw sensor value on each poll"

(
  exec {events}< <(printf 'workspace>>2\nmonitoraddedv2>>1,DP-2,Apple\n')
  monitors_changed=0
  next_tick=$(( ${EPOCHREALTIME//[!0-9]/} + 500000 ))
  wait_for_tick && fail "the poll stops when the Hyprland event stream ends"
  (( monitors_changed == 1 )) || fail "a monitor event asks for a monitor check"

  exec {events}< <(sleep 2)
  monitors_changed=0
  next_tick=$(( ${EPOCHREALTIME//[!0-9]/} + 100000 ))
  wait_for_tick || fail "the poll returns at its deadline without events"
  (( monitors_changed == 0 )) || fail "a poll without events asks for no monitor check"
  true
)
pass "automatic brightness waits on Hyprland events between polls"

(
  lid_file="$test_tmp/lid-closed"
  session_started="$test_tmp/clamshell-session"
  omarchy-hw-laptop-closed() { [[ $(<"$lid_file") == 1 ]]; }
  hyprctl() { printf '%s\n' '[{"name":"DP-1","make":"Apple Computer Inc","model":"StudioDisplay","disabled":false}]'; }
  open_events() { exec {events}</dev/null; }
  control_session() { printf '%s\n' "$2" >"$session_started"; }
  log_state() { :; }

  printf '1\n' >"$lid_file"
  : >"$session_started"
  find_sensor() { printf '%s generic\n' "$generic_sensor"; }
  controller_pass && fail "clamshell mode does not start a session"
  [[ ! -s $session_started ]] || fail "clamshell mode does not drive an external display from a covered sensor"

  printf '0\n' >"$lid_file"
  controller_pass || true
  [[ $(<"$session_started") == generic ]] || fail "a built-in sensor starts a session again after the lid opens"

  printf '1\n' >"$lid_file"
  : >"$session_started"
  find_sensor() { printf '%s apple\n' "$apple_sensor"; }
  controller_pass || true
  [[ $(<"$session_started") == apple ]] || fail "an Apple display sensor keeps working with the lid closed"
)
pass "automatic brightness does not drive an external display from a closed lid"

grep -Fx 'ExecStart=/usr/bin/omarchy-brightness-auto' "$shipped_unit" >/dev/null ||
  fail "automatic brightness unit runs the package command"
grep -Fx 'WantedBy=graphical-session.target' "$shipped_unit" >/dev/null ||
  fail "automatic brightness unit follows the graphical session"
grep -F 'omarchy-brightness-auto.service' "$ROOT/install/user/first-run/enable-user-units.sh" >/dev/null &&
  fail "automatic brightness must remain opt-in"
pass "automatic brightness ships disabled by default"
