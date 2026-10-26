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

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"

# The hwdb default 75-80% is not a charge cap. A hot cell on AC, with the
# kernel cap still at 100%, is holding for heat. UPower's thresholds lose to sysfs.
reason_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$reason_dir"' EXIT
mkdir -p "$reason_dir/bin" "$reason_dir/power/macsmc-battery" "$reason_dir/power/ac"
printf 'Mains\n' >"$reason_dir/power/ac/type"
printf '1\n' >"$reason_dir/power/ac/online"
printf '100\n' >"$reason_dir/power/macsmc-battery/charge_control_end_threshold"
printf '100\n' >"$reason_dir/power/macsmc-battery/charge_control_start_threshold"
printf '469\n' >"$reason_dir/power/macsmc-battery/temp"
printf '[auto] inhibit-charge auto-discharge\n' >"$reason_dir/power/macsmc-battery/charge_behaviour"
printf '0\n' >"$reason_dir/power/macsmc-battery/power_now"
cat >"$reason_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_macsmc_battery"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          macsmc-battery
  power supply:         yes
  state:                pending-charge
  energy-full:          38 Wh
  energy-rate:          0 W
  percentage:           54%
  charge-start-threshold:        75%
  charge-end-threshold:          80%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$reason_dir/bin/upower"

heat_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'state\tholding' <<<"$heat_shell" >/dev/null || fail "a hot pending charge is holding" "$heat_shell"
grep -Fx $'threshold\t100%' <<<"$heat_shell" >/dev/null || fail "sysfs charge cap wins over UPower's hwdb 75-80" "$heat_shell"
grep -Fx $'hold\theat' <<<"$heat_shell" >/dev/null || fail "a hot cell with no cap is a heat hold" "$heat_shell"
grep -Fx $'temperature\t46.9°C' <<<"$heat_shell" >/dev/null || fail "battery status reports the cell temperature" "$heat_shell"
heat_line=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $heat_line == "Battery 54%  ·  Holding (Heat)  ·  38Wh" ]] || fail "the status line names a heat hold" "$heat_line"
# The pause continues while the cell cools back through the mid-40s.
printf '445\n' >"$reason_dir/power/macsmc-battery/temp"
cooling_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'hold\theat' <<<"$cooling_shell" >/dev/null || fail "a cell cooling through 44.5°C is still a heat hold" "$cooling_shell"
printf '390\n' >"$reason_dir/power/macsmc-battery/temp"
warm_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -q $'^hold\t' <<<"$warm_shell" && fail "a 39°C pause with no cap stays unnamed" "$warm_shell"
printf '469\n' >"$reason_dir/power/macsmc-battery/temp"
pass "battery status names a heat hold and ignores the hwdb charge limit"

# Sitting on a charge window is optimizing, including when the cell is also hot.
printf '80\n' >"$reason_dir/power/macsmc-battery/charge_control_end_threshold"
printf '75\n' >"$reason_dir/power/macsmc-battery/charge_control_start_threshold"
printf '480\n' >"$reason_dir/power/macsmc-battery/temp"
sed -i 's/percentage:           54%/percentage:           80%/' "$reason_dir/bin/upower"
optimizing_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'hold\toptimizing' <<<"$optimizing_shell" >/dev/null || fail "a charge window is optimizing even when warm" "$optimizing_shell"
grep -Fx $'threshold\t75-80%' <<<"$optimizing_shell" >/dev/null || fail "an optimizing hold still reports its window" "$optimizing_shell"
optimizing_line=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $optimizing_line == *"Holding (Optimizing)"* ]] || fail "the status line names an optimizing hold" "$optimizing_line"
pass "battery status names an optimizing hold"

# Below the window, with a cool cell, the pause stays unnamed.
printf '300\n' >"$reason_dir/power/macsmc-battery/temp"
sed -i 's/percentage:           80%/percentage:           50%/' "$reason_dir/bin/upower"
below_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'state\tholding' <<<"$below_shell" >/dev/null || fail "pending charge below the window is still holding" "$below_shell"
grep -q $'^hold\t' <<<"$below_shell" && fail "a pause below the cap with a cool cell stays unnamed" "$below_shell"
below_line=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $below_line == *"Holding at 75-80%"* ]] || fail "an unnamed hold still says where" "$below_line"
pass "battery status leaves a cool pause below the cap unnamed"

# A single end cap is a limit, not optimized charging.
printf '60\n' >"$reason_dir/power/macsmc-battery/charge_control_end_threshold"
rm -f "$reason_dir/power/macsmc-battery/charge_control_start_threshold"
sed -i '/charge-start-threshold:/d; /charge-end-threshold:/d; s/percentage:           50%/percentage:           60%/' "$reason_dir/bin/upower"
limit_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'hold\tlimit' <<<"$limit_shell" >/dev/null || fail "a single charge cap is a limit hold" "$limit_shell"
limit_line=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $limit_line == *"Holding (Limit)"* ]] || fail "the status line names a limit hold" "$limit_line"
pass "battery status names a single charge cap as a limit"

# inhibit-charge selected, below any cap, is a limit even when the cell is cool.
printf '100\n' >"$reason_dir/power/macsmc-battery/charge_control_end_threshold"
printf '100\n' >"$reason_dir/power/macsmc-battery/charge_control_start_threshold"
printf '[inhibit-charge] auto auto-discharge\n' >"$reason_dir/power/macsmc-battery/charge_behaviour"
printf '300\n' >"$reason_dir/power/macsmc-battery/temp"
sed -i 's/percentage:           60%/percentage:           40%/' "$reason_dir/bin/upower"
inhibit_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'hold\tlimit' <<<"$inhibit_shell" >/dev/null || fail "inhibit-charge is a limit hold" "$inhibit_shell"
pass "battery status names an inhibit as a limit"

# A freezing cell, with no cap and no inhibit, is cold.
printf '[auto] inhibit-charge auto-discharge\n' >"$reason_dir/power/macsmc-battery/charge_behaviour"
printf -- '-10\n' >"$reason_dir/power/macsmc-battery/temp"
cold_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'hold\tcold' <<<"$cold_shell" >/dev/null || fail "a freezing cell is a cold hold" "$cold_shell"
grep -Fx $'temperature\t-1°C' <<<"$cold_shell" >/dev/null || fail "battery status keeps the sign on a cold cell" "$cold_shell"
cold_line=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $cold_line == *"Holding (Cold)"* ]] || fail "the status line names a cold hold" "$cold_line"
pass "battery status names a cold hold"

# With no sysfs cap, UPower's window is still the one that was set.
rm -f "$reason_dir/power/macsmc-battery/charge_control_end_threshold" "$reason_dir/power/macsmc-battery/charge_control_start_threshold"
rm -f "$reason_dir/power/macsmc-battery/temp"
printf '[auto]\n' >"$reason_dir/power/macsmc-battery/charge_behaviour"
cat >"$reason_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_macsmc_battery"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          macsmc-battery
  power supply:         yes
  state:                pending-charge
  energy-full:          38 Wh
  energy-rate:          0 W
  percentage:           80%
  charge-start-threshold:        75%
  charge-end-threshold:          80%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$reason_dir/bin/upower"
upower_shell=$(OMARCHY_POWER_SUPPLY_PATH="$reason_dir/power" PATH="$reason_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'threshold\t75-80%' <<<"$upower_shell" >/dev/null || fail "UPower's window stands in when sysfs has no cap" "$upower_shell"
grep -Fx $'hold\toptimizing' <<<"$upower_shell" >/dev/null || fail "UPower's window is optimizing once the battery reaches it" "$upower_shell"
pass "battery status falls back to UPower's charge window"
