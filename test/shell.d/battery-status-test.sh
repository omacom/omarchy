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

# Several packs: UPower serves one file per device from $multi_dir/upower.
multi_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$multi_dir"' EXIT
mkdir -p "$multi_dir/bin" "$multi_dir/upower" "$multi_dir/power/BAT0" "$multi_dir/power/BAT1" "$multi_dir/power/ac"
printf 'Mains\n' >"$multi_dir/power/ac/type"
printf '1\n' >"$multi_dir/power/ac/online"
printf '321\n' >"$multi_dir/power/BAT0/cycle_count"
printf '27\n' >"$multi_dir/power/BAT1/cycle_count"
cat >"$multi_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  for file in "$UPOWER_DIR"/battery_*; do echo "/org/freedesktop/UPower/devices/${file##*/}"; done
  exit 0
fi

[[ $1 == "-i" && -r $UPOWER_DIR/${2##*/} ]] || exit 1

# upower prints a decimal comma outside the C locale.
if [[ $LC_ALL == "C" ]]; then
  cat "$UPOWER_DIR/${2##*/}"
else
  sed 's/\([0-9]\)\.\([0-9]\)/\1,\2/g' "$UPOWER_DIR/${2##*/}"
fi
STUB
chmod +x "$multi_dir/bin/upower"

# Writes a UPower device: name, state, percentage, energy, energy-full, rate.
upower_device() {
  printf '  native-path:          %s\n  power supply:         yes\n  state:                %s\n  percentage:           %s%%\n  energy:               %s Wh\n  energy-full:          %s Wh\n  energy-rate:          %s W\n' "$@" >"$multi_dir/upower/battery_$1"
}

multi_status() {
  UPOWER_DIR="$multi_dir/upower" OMARCHY_POWER_SUPPLY_PATH="$multi_dir/power" PATH="$multi_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" "$@"
}

upower_device BAT0 discharging 50 10 20 4
upower_device BAT1 discharging 70 35 50 6
upower_device DisplayDevice discharging 64.2 45 70 10
printf '  time to empty:        4.2 hours\n' >>"$multi_dir/upower/battery_DisplayDevice"
mv "$multi_dir/upower/battery_DisplayDevice" "$multi_dir/upower/DisplayDevice"
printf '0\n' >"$multi_dir/power/ac/online"
output=$(multi_status --shell)
grep -Fx $'percentage\t64%' <<<"$output" >/dev/null || fail "two packs report UPower's combined charge" "$output"
grep -Fx $'size\t70Wh' <<<"$output" >/dev/null || fail "two packs report their combined size" "$output"
grep -Fx $'time\t4h 30m' <<<"$output" >/dev/null || fail "two packs work the time left out from the draw they show" "$output"
grep -Fx $'rate\t10W' <<<"$output" >/dev/null || fail "two packs report the combined rate" "$output"
grep -Fx $'pack.0.path\tBAT0' <<<"$output" >/dev/null || fail "each pack is listed" "$output"
grep -Fx $'pack.1.cycles\t27' <<<"$output" >/dev/null || fail "each pack has its own cycle count" "$output"
if grep -q '^cycles' <<<"$output"; then fail "two packs have no single cycle count" "$output"; fi
[[ $(multi_status) == "Battery 64%  ·  4h 30m left  ·  "*"10W"*"/"*"70Wh" ]] || fail "two packs keep the familiar summary" "$(multi_status)"
danish_multi=$(OMARCHY_LANGUAGE_FILE="$tmp_dir/language" multi_status --shell)
grep -Fx $'time\t4 t 30 min' <<<"$danish_multi" >/dev/null || fail "two packs' time follows the Omarchy language" "$danish_multi"
pass "battery status describes two packs together"

# A dead pack: no energy, no flow and no cell voltage. UPower still counts it.
upower_device BAT0 unknown 0 0 20 0
printf '0\n' >"$multi_dir/power/BAT0/voltage_now"
printf '11400000\n' >"$multi_dir/power/BAT1/voltage_now"
printf '  time to empty:        5.8 hours\n' >>"$multi_dir/upower/battery_BAT1"
upower_device DisplayDevice discharging 49 35 70 6
mv "$multi_dir/upower/battery_DisplayDevice" "$multi_dir/upower/DisplayDevice"
output=$(multi_status --shell)
grep -Fx $'percentage\t70%' <<<"$output" >/dev/null || fail "a dead pack does not drag the charge down" "$output"
grep -Fx $'size\t50Wh' <<<"$output" >/dev/null || fail "a dead pack does not add capacity" "$output"
grep -Fx $'time\t5h 50m' <<<"$output" >/dev/null || fail "the live pack's time is used" "$output"
pass "battery status leaves a dead pack out"

# Drained flat, but the cells still show a voltage: only drained, not dead.
printf '10900000\n' >"$multi_dir/power/BAT0/voltage_now"
output=$(multi_status --shell)
grep -Fx $'percentage\t49%' <<<"$output" >/dev/null || fail "a drained pack still counts" "$output"
pass "battery status keeps a drained pack"

# Both packs at their 75-80% limits on AC are holding.
printf '1\n' >"$multi_dir/power/ac/online"
printf '75\n' >"$multi_dir/power/BAT0/charge_control_start_threshold"
printf '80\n' >"$multi_dir/power/BAT0/charge_control_end_threshold"
printf '75\n' >"$multi_dir/power/BAT1/charge_control_start_threshold"
printf '80\n' >"$multi_dir/power/BAT1/charge_control_end_threshold"
upower_device BAT0 pending-charge 77 15.4 20 0
upower_device BAT1 pending-charge 79 39.5 50 0
upower_device DisplayDevice pending-charge 78.4 54.9 70 0
mv "$multi_dir/upower/battery_DisplayDevice" "$multi_dir/upower/DisplayDevice"
output=$(multi_status --shell)
grep -Fx $'state\tholding' <<<"$output" >/dev/null || fail "packs at their limits are holding" "$output"
grep -Fx $'threshold\t75-80%' <<<"$output" >/dev/null || fail "the limit is reported" "$output"
[[ $(multi_status) == "Battery 78%  ·  Holding at 75-80%  ·  0W"*"/"*"70Wh" ]] || fail "holding keeps the familiar summary" "$(multi_status)"

# Packs held at different limits share none to report.
printf '60\n' >"$multi_dir/power/BAT1/charge_control_start_threshold"
printf '70\n' >"$multi_dir/power/BAT1/charge_control_end_threshold"
upower_device BAT1 pending-charge 69 34.5 50 0
upower_device DisplayDevice pending-charge 71.3 49.9 70 0
mv "$multi_dir/upower/battery_DisplayDevice" "$multi_dir/upower/DisplayDevice"
output=$(multi_status --shell)
grep -Fx $'state\tholding' <<<"$output" >/dev/null || fail "packs at different limits are holding" "$output"
if grep -q '^threshold' <<<"$output"; then fail "different limits report no shared limit" "$output"; fi
grep -Fx $'pack.1.thresholdEnd\t70' <<<"$output" >/dev/null || fail "each pack keeps its own limit" "$output"
[[ $(multi_status) == "Battery 71%  ·  Holding  ·  0W"*"/"*"70Wh" ]] || fail "holding without a shared limit names none" "$(multi_status)"
printf '75\n' >"$multi_dir/power/BAT1/charge_control_start_threshold"
printf '80\n' >"$multi_dir/power/BAT1/charge_control_end_threshold"
pass "battery status reports a charge limit only when the packs share one"

# One pack waiting below its limit while the other charges is not holding.
upower_device BAT0 pending-charge 60 12 20 0
upower_device BAT1 charging 50 25 50 20
upower_device DisplayDevice charging 52.9 37 70 20
mv "$multi_dir/upower/battery_DisplayDevice" "$multi_dir/upower/DisplayDevice"
output=$(multi_status --shell)
grep -Fx $'state\tcharging' <<<"$output" >/dev/null || fail "a pack waiting for its turn is not holding" "$output"
grep -Fx $'time\t57m' <<<"$output" >/dev/null || fail "time to full counts each pack up to its own limit" "$output"

# A pack held at its limit takes no more charge while the other fills.
upower_device BAT0 pending-charge 77 15.4 20 0
output=$(multi_status --shell)
grep -Fx $'state\tcharging' <<<"$output" >/dev/null || fail "a pack held at its limit beside a charging one is not holding" "$output"
grep -Fx $'time\t45m' <<<"$output" >/dev/null || fail "time to full skips a pack already held at its limit" "$output"
pass "battery status reports holding only when every pack is at its limit"

# An empty bay lists a battery with no capacity; the machine has one pack,
# and the headline describes it even when the bay is listed first.
upower_device BAT0 unknown 0 0 0 0
output=$(multi_status --shell)
if grep -q '^pack\.' <<<"$output"; then fail "an empty bay is not a pack" "$output"; fi
grep -Fx $'percentage\t50%' <<<"$output" >/dev/null || fail "the fitted pack supplies the headline" "$output"
grep -Fx $'size\t50Wh' <<<"$output" >/dev/null || fail "the fitted pack supplies the size" "$output"
pass "battery status ignores an empty bay"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
