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
grep -Fx $'time\t2h 37m' <<<"$shell_output" >/dev/null || fail "battery status works the time left out from the draw it shows"
grep -Fx $'cycles\t212' <<<"$shell_output" >/dev/null || fail "battery status reports native-path cycle count"
grep -Fx $'threshold\t75-80%' <<<"$shell_output" >/dev/null || fail "battery status reports native-path charge thresholds"
line_output=$(OMARCHY_TEST_NATIVE_PATH=macsmc-battery OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $line_output == *$' '"10.8W"$' / '"56Wh" ]] || fail "a draw signed negative still shows in the status line" "$line_output"

# The BAT* name the script used to key on is one of many; CMB0 is another.
mkdir -p "$tmp_dir/power/CMB0"
printf '7300000\n' >"$tmp_dir/power/CMB0/power_now"
sed -i 's/native-path:          macsmc-battery/native-path:          CMB0/' "$tmp_dir/bin/upower"
generic_output=$(OMARCHY_TEST_NATIVE_PATH=CMB0 OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$generic_output" >/dev/null || fail "battery status accepts arbitrary UPower battery paths"
grep -Fx $'time\t3h 53m' <<<"$generic_output" >/dev/null || fail "battery status time left follows the live draw"
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

# Charging counts up to the charge limit, not to a full battery.
printf '27800000\n' >"$hold_dir/power/BAT0/power_now"
sed -i 's/percentage:           80.0%/percentage:           40.0%/; s/energy-full:          69.6 Wh/energy:               27.84 Wh\n  energy-full:          69.6 Wh/' "$hold_dir/bin/upower"
charging_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'time\t1h' <<<"$charging_output" >/dev/null || fail "time to full counts up to the charge limit" "$charging_output"
pass "battery status times charging to the charge limit"

# UPower's own estimate stands in when the draw is too small to divide by...
printf '100000\n' >"$hold_dir/power/BAT0/power_now"
idle_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'time\t12m' <<<"$idle_output" >/dev/null || fail "a negligible draw falls back to UPower's time" "$idle_output"

# ...and when the energy reading is missing.
printf '27800000\n' >"$hold_dir/power/BAT0/power_now"
sed -i '/energy:               27.84 Wh/d' "$hold_dir/bin/upower"
unread_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'time\t12m' <<<"$unread_output" >/dev/null || fail "a missing energy reading falls back to UPower's time" "$unread_output"
pass "battery status falls back to UPower's time when it cannot work it out"

# Another battery's charge limit does not shorten this one's time to full.
sed -i 's/energy-full:          69.6 Wh/energy:               27.84 Wh\n  energy-full:          69.6 Wh/' "$hold_dir/bin/upower"
rm "$hold_dir/power/BAT0/charge_control_end_threshold"
sed -i '/charge-end-threshold: 80%/d' "$hold_dir/bin/upower"
mkdir -p "$hold_dir/power/BAT1"
printf '60\n' >"$hold_dir/power/BAT1/charge_control_end_threshold"
unlimited_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'time\t1h 30m' <<<"$unlimited_output" >/dev/null || fail "time to full ignores another battery's charge limit" "$unlimited_output"
pass "battery status times charging to its own battery's limit"

# The status line and its durations follow the Omarchy language.
echo "da" >"$tmp_dir/language"
danish_output=$(OMARCHY_LANGUAGE_FILE="$tmp_dir/language" OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $danish_output == "Batteri 40%  ·  1 t 30 min til fuld  ·  "* ]] || fail "battery status reads in the Omarchy language" "$danish_output"
danish_time=$(OMARCHY_LANGUAGE_FILE="$tmp_dir/language" OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'time\t1 t 30 min' <<<"$danish_time" >/dev/null || fail "battery status durations follow the Omarchy language" "$danish_time"
pass "battery status reads in the Omarchy language"

# A full battery says so, with no time to count and no 0W draw.
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
  state:                fully-charged
  energy:               53.2 Wh
  energy-full:          53.2 Wh
  energy-rate:          0 W
  percentage:           100%
INFO
  exit 0
fi

exit 1
STUB
printf '0\n' >"$hold_dir/power/BAT0/power_now"
full_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $full_output == "Battery 100%  ·  Fully charged  ·  53Wh" ]] || fail "a full battery shows no time or draw" "$full_output"

# A battery with no time estimate and no capacity reading leaves both out.
sed -i 's/state:                fully-charged/state:                discharging/; s/percentage:           100%/percentage:           60%/; /energy/d' "$hold_dir/bin/upower"
printf '0\n' >"$hold_dir/power/ac/online"
printf '9000000\n' >"$hold_dir/power/BAT0/power_now"
sparse_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $sparse_output == "Battery 60%  ·  "$' '"9W" ]] || fail "missing readings drop out of the status line" "$sparse_output"
pass "battery status leaves out readings it doesn't have"

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

# Dual-battery charging preserves UPower's combined time to full when individual limits differ
dual_charge_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$dual_dir" "$dual_charge_dir"' EXIT

mkdir -p "$dual_charge_dir/bin" "$dual_charge_dir/power/BAT0" "$dual_charge_dir/power/BAT1" "$dual_charge_dir/power/AC"
printf '80\n' >"$dual_charge_dir/power/BAT0/charge_control_end_threshold"
printf '1\n' >"$dual_charge_dir/power/AC/online"
printf 'Mains\n' >"$dual_charge_dir/power/AC/type"

cat >"$dual_charge_dir/bin/upower" <<'STUB'
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
  state:                charging
  energy:               85.0 Wh
  energy-full:          100.0 Wh
  energy-rate:          10.0 W
  time to full:         1.5 hours
  percentage:           85%
INFO
  exit 0
fi

if [[ $1 == "-i" && $2 == */battery_BAT0 ]]; then
  cat <<'INFO'
  native-path:          BAT0
  power supply:         yes
  state:                charging
  energy:               40.0 Wh
  energy-full:          50.0 Wh
  percentage:           80%
INFO
  exit 0
fi

if [[ $1 == "-i" && $2 == */battery_BAT1 ]]; then
  cat <<'INFO'
  native-path:          BAT1
  power supply:         yes
  state:                charging
  energy:               45.0 Wh
  energy-full:          50.0 Wh
  percentage:           90%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$dual_charge_dir/bin/upower"

dual_charge_output=$(OMARCHY_POWER_SUPPLY_PATH="$dual_charge_dir/power" PATH="$dual_charge_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'state\tcharging' <<<"$dual_charge_output" >/dev/null || fail "dual-battery charging reports charging state"
grep -Fx $'time\t1h 30m' <<<"$dual_charge_output" >/dev/null || fail "dual-battery charging keeps combined UPower time to full" "$dual_charge_output"
pass "dual-battery charging keeps combined UPower estimate when individual battery limits differ"

# Single-battery laptops also have a DisplayDevice created by UPower, but must
# keep reading live instantaneous rate from sysfs power_now rather than stale energy-rate.
single_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$dual_dir" "$dual_charge_dir" "$single_dir"' EXIT

mkdir -p "$single_dir/bin" "$single_dir/power/BAT0"
printf '75\n' >"$single_dir/power/BAT0/capacity"
printf '15000000\n' >"$single_dir/power/BAT0/power_now"

cat >"$single_dir/bin/upower" <<'STUB'
#!/bin/bash
if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" && $2 == */DisplayDevice ]]; then
  cat <<'INFO'
  power supply:         yes
  state:                discharging
  energy-rate:          9.0 W
  percentage:           75%
INFO
  exit 0
fi

if [[ $1 == "-i" && $2 == */battery_BAT0 ]]; then
  cat <<'INFO'
  native-path:          BAT0
  power supply:         yes
  state:                discharging
  energy-rate:          9.0 W
  percentage:           75%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$single_dir/bin/upower"

single_output=$(OMARCHY_POWER_SUPPLY_PATH="$single_dir/power" PATH="$single_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t75%' <<<"$single_output" >/dev/null || fail "single-battery status reports percentage"
grep -Fx $'rate\t15W' <<<"$single_output" >/dev/null || fail "single-battery status keeps live rate from sysfs power_now instead of DisplayDevice"
pass "single-battery systems keep live sysfs rate despite DisplayDevice presence"

# Desktop systems with 0 batteries (only peripheral or no batteries) must exit 0 cleanly with no output.
desktop_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$dual_dir" "$dual_charge_dir" "$single_dir" "$desktop_dir"' EXIT
mkdir -p "$desktop_dir/bin" "$desktop_dir/power"

cat >"$desktop_dir/bin/upower" <<'STUB'
#!/bin/bash
if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/mouse_dev"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi
if [[ $1 == "-i" && $2 == */DisplayDevice ]]; then
  cat <<'INFO'
  power supply:         no
  state:                unknown
INFO
  exit 0
fi
exit 1
STUB
chmod +x "$desktop_dir/bin/upower"

desktop_output=$(OMARCHY_POWER_SUPPLY_PATH="$desktop_dir/power" PATH="$desktop_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
[[ -z $desktop_output ]] || fail "desktop system with no battery outputs nothing"
pass "desktop system with no battery exits cleanly with no output"
