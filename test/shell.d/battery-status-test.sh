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

# UPower latched energy-full on a Smart Battery blip (a MacBook Air: 484 Wh on
# a 54 Wh pack) and reads a tenth of the charge; the kernel's charge registers
# still have it right. UPower's time to full counts to the latched value too.
latch_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$latch_dir"' EXIT

mkdir -p "$latch_dir/bin" "$latch_dir/power/BAT0" "$latch_dir/power/ac"
printf 'Mains\n' >"$latch_dir/power/ac/type"
printf '1\n' >"$latch_dir/power/ac/online"
printf '6833000\n' >"$latch_dir/power/BAT0/charge_now"
printf '6876000\n' >"$latch_dir/power/BAT0/charge_full"
printf '7600000\n' >"$latch_dir/power/BAT0/voltage_min_design"
printf '8533000\n' >"$latch_dir/power/BAT0/voltage_now"
printf '0\n' >"$latch_dir/power/BAT0/current_now"
printf '274\n' >"$latch_dir/power/BAT0/cycle_count"
cat >"$latch_dir/bin/upower" <<'STUB'
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
  energy:               51.4 Wh
  energy-full:          484.515 Wh
  energy-full-design:   54.34 Wh
  energy-rate:          3.2 W
  time to full:         5.6 days
  percentage:           10.6099%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$latch_dir/bin/upower"

latched_output=$(OMARCHY_POWER_SUPPLY_PATH="$latch_dir/power" PATH="$latch_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t99%' <<<"$latched_output" >/dev/null || fail "a latched energy-full gives way to the kernel's charge registers" "$latched_output"
grep -Fx $'size\t52Wh' <<<"$latched_output" >/dev/null || fail "a latched energy-full gives way to the kernel's full charge" "$latched_output"
grep -Fx $'time\t' <<<"$latched_output" >/dev/null || fail "UPower's time to full against a latched energy-full is not shown" "$latched_output"
grep -Fx $'source\tkernel' <<<"$latched_output" >/dev/null || fail "battery status names the kernel as its source past a latch" "$latched_output"
grep -Fx $'state\tcharging' <<<"$latched_output" >/dev/null || fail "the kernel registers leave UPower's state alone" "$latched_output"
grep -Fx $'cycles\t274' <<<"$latched_output" >/dev/null || fail "battery status still reports the cycle count past a latch" "$latched_output"

# Charging past a latch times the kernel's full charge against the live draw
# (a MacBook Pro: 733 Wh latched on a 77 Wh pack, charging at 32 W).
printf '2693000\n' >"$latch_dir/power/BAT0/charge_now"
printf '4806000\n' >"$latch_dir/power/BAT0/charge_full"
printf '11400000\n' >"$latch_dir/power/BAT0/voltage_min_design"
printf '11400000\n' >"$latch_dir/power/BAT0/voltage_now"
printf '2800000\n' >"$latch_dir/power/BAT0/current_now"
sed -i 's/energy:               51.4 Wh/energy:               30.7 Wh/; s/energy-full:          484.515 Wh/energy-full:          733.4 Wh/; s/energy-full-design:   54.34 Wh/energy-full-design:   76.6 Wh/; s/energy-rate:          3.2 W/energy-rate:          31.9 W/; s/time to full:         5.6 days/time to full:         21.7 hours/; s/percentage:           10.6099%/percentage:           4.2%/' "$latch_dir/bin/upower"
charging_latched_output=$(OMARCHY_POWER_SUPPLY_PATH="$latch_dir/power" PATH="$latch_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t56%' <<<"$charging_latched_output" >/dev/null || fail "a charge-counting battery's percentage comes from its charge registers" "$charging_latched_output"
grep -Fx $'size\t54Wh' <<<"$charging_latched_output" >/dev/null || fail "a charge-counting battery's size converts at its design voltage" "$charging_latched_output"
grep -Fx $'time\t45m' <<<"$charging_latched_output" >/dev/null || fail "time to full past a latch counts to the kernel's full charge" "$charging_latched_output"

# A battery that counts energy answers from energy_now and energy_full.
rm "$latch_dir/power/BAT0"/charge_* "$latch_dir/power/BAT0"/voltage_*
printf '30700000\n' >"$latch_dir/power/BAT0/energy_now"
printf '54800000\n' >"$latch_dir/power/BAT0/energy_full"
printf '31900000\n' >"$latch_dir/power/BAT0/power_now"
energy_latched_output=$(OMARCHY_POWER_SUPPLY_PATH="$latch_dir/power" PATH="$latch_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t56%' <<<"$energy_latched_output" >/dev/null || fail "an energy-counting battery's percentage comes from its energy registers" "$energy_latched_output"
grep -Fx $'size\t54Wh' <<<"$energy_latched_output" >/dev/null || fail "an energy-counting battery's size comes from energy_full" "$energy_latched_output"
grep -Fx $'source\tkernel' <<<"$energy_latched_output" >/dev/null || fail "an energy-counting battery past a latch names the kernel as its source" "$energy_latched_output"

# With no registers to read, UPower's figures stand, wrong as they are.
rm "$latch_dir/power/BAT0"/energy_*
bare_latched_output=$(OMARCHY_POWER_SUPPLY_PATH="$latch_dir/power" PATH="$latch_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t4%' <<<"$bare_latched_output" >/dev/null || fail "a latch with no kernel registers keeps UPower's percentage" "$bare_latched_output"
grep -q $'^source\t' <<<"$bare_latched_output" && fail "a latch with no kernel registers names no other source" "$bare_latched_output"
pass "battery status reads the kernel's charge registers past a latched UPower energy-full"

# A full charge a little over the design capacity is a healthy new pack, and
# UPower's figures stand; the registers are not read, and no source is named.
printf '2693000\n' >"$latch_dir/power/BAT0/charge_now"
printf '4806000\n' >"$latch_dir/power/BAT0/charge_full"
printf '11400000\n' >"$latch_dir/power/BAT0/voltage_min_design"
sed -i 's/energy-full:          733.4 Wh/energy-full:          78.1 Wh/; s/percentage:           4.2%/percentage:           39.3%/' "$latch_dir/bin/upower"
healthy_output=$(OMARCHY_POWER_SUPPLY_PATH="$latch_dir/power" PATH="$latch_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t39%' <<<"$healthy_output" >/dev/null || fail "a plausible energy-full keeps UPower's percentage" "$healthy_output"
grep -Fx $'size\t78Wh' <<<"$healthy_output" >/dev/null || fail "a plausible energy-full keeps UPower's size" "$healthy_output"
grep -q $'^source\t' <<<"$healthy_output" && fail "a plausible energy-full names no other source" "$healthy_output"
pass "battery status keeps UPower's figures while its energy-full is plausible"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
