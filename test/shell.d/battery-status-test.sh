#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
# Apple Silicon: a battery not called BAT*, power_now signed by direction, and
# the thresholds and cycle count only under the native path.
mkdir -p "$tmp_dir/power/macsmc-battery"
printf '%s\n' '-10800000' >"$tmp_dir/power/macsmc-battery/power_now"
printf '75\n' >"$tmp_dir/power/macsmc-battery/charge_control_start_threshold"
printf '80\n' >"$tmp_dir/power/macsmc-battery/charge_control_end_threshold"
printf '212\n' >"$tmp_dir/power/macsmc-battery/cycle_count"
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

# A wireless mouse enumerates first, as a battery_ device that is not a power
# supply; the machine's own battery follows it.
if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/line_power_macsmc_ac"
  echo "/org/freedesktop/UPower/devices/battery_hidpp_battery_0"
  echo "/org/freedesktop/UPower/devices/battery_${OMARCHY_TEST_NATIVE_PATH//-/_}"
  exit 0
fi

if [[ $1 == "-i" && $2 == */battery_hidpp_battery_0 ]]; then
  cat <<'INFO'
  native-path:          hidpp_battery_0
  model:                Wireless Mouse
  power supply:         no
  state:                discharging
  percentage:           5%
INFO
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          macsmc-battery
  power supply:         yes
  state:                discharging
  energy:               28.3 Wh
  energy-full:          56.7 Wh
  energy-rate:          7.3 W
  time to empty:        2.5 hours
  percentage:           51%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

shell_output=$(OMARCHY_TEST_NATIVE_PATH=macsmc-battery OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t51%' <<<"$shell_output" >/dev/null || fail "battery status reports the machine's battery, not the mouse's"
grep -Fx $'state\tdischarging' <<<"$shell_output" >/dev/null || fail "battery status reports state"
grep -Fx $'rate\t10.8W' <<<"$shell_output" >/dev/null || fail "battery status reports live sysfs power rate"
grep -Fx $'size\t56Wh' <<<"$shell_output" >/dev/null || fail "battery status reports full capacity"
grep -Fx $'time\t2h 30m' <<<"$shell_output" >/dev/null || fail "battery status reports remaining time"
grep -Fx $'cycles\t212' <<<"$shell_output" >/dev/null || fail "battery status reports native-path cycle count"
grep -Fx $'threshold\t75-80%' <<<"$shell_output" >/dev/null || fail "battery status reports native-path charge thresholds"

# The BAT* name the script used to key on is one of many; CMB0 is another.
mkdir -p "$tmp_dir/power/CMB0"
printf '7300000\n' >"$tmp_dir/power/CMB0/power_now"
sed -i 's/native-path:          macsmc-battery/native-path:          CMB0/' "$tmp_dir/bin/upower"
generic_output=$(OMARCHY_TEST_NATIVE_PATH=CMB0 OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$generic_output" >/dev/null || fail "battery status accepts arbitrary UPower battery paths"
pass "battery status supports Apple Silicon and arbitrary native battery paths"

# An 80% hold threshold doesn't trip while the battery is still below it.
hold_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir"' EXIT

mkdir -p "$hold_dir/bin" "$hold_dir/power/BAT0" "$hold_dir/power/ac"
printf 'Mains\n' >"$hold_dir/power/ac/type"
printf '1\n' >"$hold_dir/power/ac/online"
printf '80\n' >"$hold_dir/power/BAT0/charge_control_end_threshold"
cat >"$hold_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          BAT0
  power supply:         yes
  state:                charging
  energy-full:          69.6 Wh
  energy-rate:          0.1 W
  time to full:         0.2 hours
  percentage:           79.5%
  charge-end-threshold: 80%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$hold_dir/bin/upower"

hold_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'state\tcharging' <<<"$hold_output" >/dev/null || fail "a hold below its threshold is still charging"
pass "battery status doesn't trip a hold early"

# Once the battery reaches the threshold, idle charging is holding.
sed -i 's/percentage:           79.5%/percentage:           80.0%/' "$hold_dir/bin/upower"
held_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t80%' <<<"$held_output" >/dev/null || fail "threshold percentage still displays as 80%"
grep -Fx $'state\tholding' <<<"$held_output" >/dev/null || fail "idle charging at the threshold is holding"
pass "battery status reports holding once the raw percentage reaches the threshold"

# Dual-battery laptops (e.g. ThinkPad BAT0 + BAT1) provide a combined DisplayDevice.
dual_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$dual_dir"' EXIT

mkdir -p "$dual_dir/bin" "$dual_dir/power/BAT0" "$dual_dir/power/BAT1"
printf '100\n' >"$dual_dir/power/BAT0/capacity"
printf '80\n' >"$dual_dir/power/BAT1/capacity"
printf '120\n' >"$dual_dir/power/BAT0/cycle_count"
printf '0\n' >"$dual_dir/power/BAT0/power_now"

cat >"$dual_dir/bin/upower" <<'STUB'
#!/bin/bash
if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" && $2 == */DisplayDevice ]]; then
  cat <<'INFO'
  power supply:         yes
  state:                discharging
  energy:               54.0 Wh
  energy-full:          63.0 Wh
  energy-rate:          12.5 W
  time to empty:        4.3 hours
  percentage:           86%
INFO
  exit 0
fi

if [[ $1 == "-i" && $2 == */battery_BAT0 ]]; then
  cat <<'INFO'
  native-path:          BAT0
  power supply:         yes
  state:                fully-charged
  energy:               18.0 Wh
  energy-full:          18.0 Wh
  percentage:           100%
INFO
  exit 0
fi

if [[ $1 == "-i" && $2 == */battery_BAT1 ]]; then
  cat <<'INFO'
  native-path:          BAT1
  power supply:         yes
  state:                discharging
  energy:               36.0 Wh
  energy-full:          45.0 Wh
  percentage:           80%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$dual_dir/bin/upower"

dual_output=$(OMARCHY_POWER_SUPPLY_PATH="$dual_dir/power" PATH="$dual_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t86%' <<<"$dual_output" >/dev/null || fail "battery status prefers combined DisplayDevice percentage on dual-battery systems"
grep -Fx $'rate\t12.5W' <<<"$dual_output" >/dev/null || fail "battery status preserves combined DisplayDevice rate on dual-battery systems"
grep -Fx $'size\t63Wh' <<<"$dual_output" >/dev/null || fail "battery status prefers combined DisplayDevice capacity on dual-battery systems"
grep -Fx $'cycles\t120' <<<"$dual_output" >/dev/null || fail "battery status falls back to BAT* cycle count when DisplayDevice lacks native path"
pass "battery status prefers combined DisplayDevice on multi-battery systems"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
