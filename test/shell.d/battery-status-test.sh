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

# Some HP firmware has no power_now and a current_now whose read() fails, and
# UPower then reports 0W as well. The rate comes from how fast charge_now
# moves between runs instead, kept as samples under XDG_RUNTIME_DIR.
estimate_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$estimate_dir"' EXIT

mkdir -p "$estimate_dir/bin" "$estimate_dir/power/BAT0" "$estimate_dir/run"
printf 'Discharging\n' >"$estimate_dir/power/BAT0/status"
: >"$estimate_dir/power/BAT0/current_now"
printf '10000000\n' >"$estimate_dir/power/BAT0/voltage_now"
printf '900000\n' >"$estimate_dir/power/BAT0/charge_now"
printf '3200000\n' >"$estimate_dir/power/BAT0/charge_full"
cat >"$estimate_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<INFO
  native-path:          BAT0
  power supply:         yes
  state:                ${OMARCHY_TEST_STATE:-discharging}
  energy:               9 Wh
  energy-full:          32 Wh
  energy-rate:          ${OMARCHY_TEST_RATE:-0} W
${OMARCHY_TEST_TIME_LINE:-}
  percentage:           28%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$estimate_dir/bin/upower"

samples_file="$estimate_dir/run/omarchy-battery-samples-BAT0"

estimate_status() {
  XDG_RUNTIME_DIR="$estimate_dir/run" OMARCHY_POWER_SUPPLY_PATH="$estimate_dir/power" PATH="$estimate_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell 2>/dev/null
}

estimate_output=$(estimate_status)
grep -Fx $'rate\t0W' <<<"$estimate_output" >/dev/null || fail "a first sample has nothing to measure against yet" "$estimate_output"
[[ -s $samples_file ]] || fail "the first run records a sample"
pass "battery estimate waits for a second sample"

# 100 mAh over ten minutes at 10V is 6W, and 9 Wh left at that pace is 1.5h.
# A run a second later still rounds the same way.
printf '%s 1000000 Discharging uAh\n' "$(( $(date +%s) - 600 ))" >"$samples_file"
estimate_output=$(estimate_status)
grep -Fx $'rate\t6W' <<<"$estimate_output" >/dev/null || fail "the rate comes from charge_now's movement" "$estimate_output"
grep -Fx $'time\t1h 30m' <<<"$estimate_output" >/dev/null || fail "the time left comes from the estimated rate" "$estimate_output"
pass "battery estimate reports rate and time left while discharging"

# Charging measures upwards and reports the time to full: 23 Wh to go.
printf 'Charging\n' >"$estimate_dir/power/BAT0/status"
printf '%s 800000 Charging uAh\n' "$(( $(date +%s) - 600 ))" >"$samples_file"
estimate_output=$(OMARCHY_TEST_STATE=charging estimate_status)
grep -Fx $'rate\t6W' <<<"$estimate_output" >/dev/null || fail "the rate is measured while charging" "$estimate_output"
grep -Fx $'time\t3h 50m' <<<"$estimate_output" >/dev/null || fail "the time to full comes from the estimated rate" "$estimate_output"
pass "battery estimate reports rate and time to full while charging"

# Samples from the other direction, or a reading that moved the wrong way,
# don't give a rate.
printf 'Discharging\n' >"$estimate_dir/power/BAT0/status"
printf '%s 800000 Charging uAh\n' "$(( $(date +%s) - 600 ))" >"$samples_file"
estimate_output=$(estimate_status)
grep -Fx $'rate\t0W' <<<"$estimate_output" >/dev/null || fail "samples from another state are ignored" "$estimate_output"
printf '%s 800000 Discharging uAh\n' "$(( $(date +%s) - 600 ))" >"$samples_file"
estimate_output=$(estimate_status)
grep -Fx $'rate\t0W' <<<"$estimate_output" >/dev/null || fail "a reading that rose while discharging gives no rate" "$estimate_output"
pass "battery estimate ignores samples that don't fit the battery state"

# A working rate is never replaced. (The failing current_now read is set
# aside here: it zeroes UPower's rate before the estimate is reached, which is
# a separate bug.)
mv "$estimate_dir/power/BAT0/current_now" "$estimate_dir/current_now"
printf '%s 1000000 Discharging uAh\n' "$(( $(date +%s) - 600 ))" >"$samples_file"
estimate_output=$(OMARCHY_TEST_RATE=7.3 estimate_status)
grep -Fx $'rate\t7.3W' <<<"$estimate_output" >/dev/null || fail "a nonzero UPower rate is kept" "$estimate_output"
[[ ! -e $samples_file ]] || fail "a working rate clears the kept samples"
mv "$estimate_dir/current_now" "$estimate_dir/power/BAT0/current_now"
pass "battery estimate only runs when no source reports a rate"

# Charging with a working rate, then unplugging, must not measure against the
# discharge samples from before the charge.
printf '%s 1000000 Discharging uAh\n' "$(( $(date +%s) - 1200 ))" >"$samples_file"
printf 'Full\n' >"$estimate_dir/power/BAT0/status"
estimate_status >/dev/null
[[ ! -e $samples_file ]] || fail "a battery that stops discharging clears the kept samples"
printf 'Discharging\n' >"$estimate_dir/power/BAT0/status"
estimate_output=$(estimate_status)
grep -Fx $'rate\t0W' <<<"$estimate_output" >/dev/null || fail "samples from before a charge are not measured against" "$estimate_output"
pass "battery estimate restarts its history when the state changes"

# Without XDG_RUNTIME_DIR, samples go in a private directory of this user's
# own, and never through a link someone else planted at that name.
fallback_tmp="$estimate_dir/tmp"
mkdir -p "$fallback_tmp"
no_runtime_status() {
  env -u XDG_RUNTIME_DIR TMPDIR="$fallback_tmp" OMARCHY_POWER_SUPPLY_PATH="$estimate_dir/power" PATH="$estimate_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell 2>/dev/null
}
no_runtime_status >/dev/null
[[ -s $fallback_tmp/omarchy-battery-$UID/omarchy-battery-samples-BAT0 ]] || fail "samples fall back to a per-user directory"
[[ $(stat -c %a "$fallback_tmp/omarchy-battery-$UID") == 700 ]] || fail "the per-user directory is private"
rm -rf "$fallback_tmp/omarchy-battery-$UID"
mkdir -p "$estimate_dir/elsewhere"
ln -s "$estimate_dir/elsewhere" "$fallback_tmp/omarchy-battery-$UID"
no_runtime_status >/dev/null
[[ -z $(ls -A "$estimate_dir/elsewhere") ]] || fail "samples never follow a link at the per-user directory"
pass "battery estimate keeps samples per user without XDG_RUNTIME_DIR"

# The open panel's refreshes can overlap. Concurrent runs must leave a
# well-formed samples file and no temp files behind.
for _ in {1..20}; do
  estimate_status >/dev/null &
done
wait
malformed=$(awk 'NF != 4 || $2 !~ /^[0-9]+$/' "$samples_file")
[[ -z $malformed ]] || fail "concurrent runs leave every sample whole" "$malformed"
leftovers=$(find "$estimate_dir/run" -name 'omarchy-battery-samples-BAT0.*')
[[ -z $leftovers ]] || fail "concurrent runs leave no temp files" "$leftovers"
pass "battery estimate survives overlapping runs"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
