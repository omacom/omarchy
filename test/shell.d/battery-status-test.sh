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

# Firmware that doesn't know the present rate leaves current_now in place but
# gives nothing on read; UPower's rate, from the falling charge, stands.
rm "$tmp_dir/power/CMB0/power_now"
: >"$tmp_dir/power/CMB0/current_now"
printf '12900000\n' >"$tmp_dir/power/CMB0/voltage_now"
unknown_rate_output=$(OMARCHY_TEST_NATIVE_PATH=CMB0 OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$unknown_rate_output" >/dev/null || fail "an unreadable current_now leaves UPower's rate in place" "$unknown_rate_output"
pass "battery status keeps UPower's rate when the battery has no live reading"

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

# A load bigger than the adapter drains a battery still reading 100%.
sed -i 's/state:                fully-charged/state:                discharging/' "$hold_dir/bin/upower"
printf '10000000\n' >"$hold_dir/power/BAT0/power_now"
draining_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $draining_output == "Battery 100%  ·  5h 19m left  ·  "*"10W"*"53Wh" ]] || fail "a battery draining on AC at 100% is not fully charged" "$draining_output"
sed -i 's/state:                discharging/state:                fully-charged/' "$hold_dir/bin/upower"

# A battery with no time estimate and no capacity reading leaves both out.
sed -i 's/state:                fully-charged/state:                discharging/; s/percentage:           100%/percentage:           60%/; /energy/d' "$hold_dir/bin/upower"
printf '0\n' >"$hold_dir/power/ac/online"
printf '9000000\n' >"$hold_dir/power/BAT0/power_now"
sparse_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status")
[[ $sparse_output == "Battery 60%  ·  "$' '"9W" ]] || fail "missing readings drop out of the status line" "$sparse_output"
pass "battery status leaves out readings it doesn't have"

# UPower 1.91+ prints hwdb 75/80% thresholds even when disabled (sysfs is 100%).
# Battery health and charge limit state must reflect reality, not hwdb defaults.
hwdb_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$hold_dir" "$hwdb_dir"' EXIT
mkdir -p "$hwdb_dir/bin" "$hwdb_dir/power/BAT1" "$hwdb_dir/power/ACAD" "$hwdb_dir/sleep-run" "$hwdb_dir/sleep-state" "$hwdb_dir/bat-state"
printf 'Mains\n' >"$hwdb_dir/power/ACAD/type"
printf '0\n' >"$hwdb_dir/power/ACAD/online"
printf 'Battery\n' >"$hwdb_dir/power/BAT1/type"
printf '1\n' >"$hwdb_dir/power/BAT1/present"
printf '100\n' >"$hwdb_dir/power/BAT1/charge_control_end_threshold"
printf '0\n' >"$hwdb_dir/power/BAT1/charge_control_start_threshold"
printf '300000\n' >"$hwdb_dir/power/BAT1/current_now"
printf '17000000\n' >"$hwdb_dir/power/BAT1/voltage_now"
cat >"$hwdb_dir/bin/upower" <<'STUB'
#!/bin/bash
if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  exit 0
fi
if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          BAT1
  power supply:         yes
  state:                discharging
  energy:               55.0 Wh
  energy-full:          63.5 Wh
  energy-full-design:   72.6 Wh
  energy-rate:          5.1 W
  percentage:           87%
  charge-start-threshold:        75%
  charge-end-threshold:          80%
  charge-threshold-supported:    yes
INFO
  exit 0
fi
exit 1
STUB
chmod +x "$hwdb_dir/bin/upower"

hwdb_out=$(OMARCHY_POWER_SUPPLY_PATH="$hwdb_dir/power" OMARCHY_SLEEP_RUN_DIR="$hwdb_dir/sleep-run" OMARCHY_BATTERY_STATE_DIR="$hwdb_dir/bat-state" PATH="$hwdb_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'health\t87%' <<<"$hwdb_out" >/dev/null || fail "battery status computes health from full/design energy" "$hwdb_out"
grep -Fx $'limit_supported\t1' <<<"$hwdb_out" >/dev/null || fail "battery status reports charge limit support" "$hwdb_out"
grep -Fx $'limit_state\toff' <<<"$hwdb_out" >/dev/null || fail "sysfs 100% overrides UPower hwdb default threshold" "$hwdb_out"
grep -Fx $'limit_end\t80' <<<"$hwdb_out" >/dev/null || fail "battery status keeps UPower target limit for the 80% button" "$hwdb_out"
! grep -q '^threshold'$'\t' <<<"$hwdb_out" || fail "disabled hwdb threshold is not emitted as active" "$hwdb_out"

# Top-up-once marker reports limit_state=once when limit is off.
printf '1795760000\n' >"$hwdb_dir/bat-state/top-up-once"
once_out=$(OMARCHY_POWER_SUPPLY_PATH="$hwdb_dir/power" OMARCHY_SLEEP_RUN_DIR="$hwdb_dir/sleep-run" OMARCHY_BATTERY_STATE_DIR="$hwdb_dir/bat-state" PATH="$hwdb_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'limit_state\tonce' <<<"$once_out" >/dev/null || fail "top-up-once marker sets limit_state=once" "$once_out"
pass "battery status reports health, accurate limit state, and top-up-once"

# Sleep drain hook: charge-based battery (voltage_min_design), S0ix wrap guard,
# and battery-status --shell exposure.
mkdir -p "$hwdb_dir/suspend_stats" "$hwdb_dir/cpuidle"
printf '[s2idle]\n' >"$hwdb_dir/mem_sleep"
printf '1000.00 0.00\n' >"$hwdb_dir/uptime"
printf '4000000\n' >"$hwdb_dir/power/BAT1/charge_now"
printf '4640000\n' >"$hwdb_dir/power/BAT1/charge_full"
printf '15640000\n' >"$hwdb_dir/power/BAT1/voltage_min_design"
printf '10000000\n' >"$hwdb_dir/cpuidle/low_power_idle_system_residency_us"

sleep_env=(
  OMARCHY_POWER_SUPPLY_PATH="$hwdb_dir/power"
  OMARCHY_SLEEP_RUN_DIR="$hwdb_dir/sleep-run"
  OMARCHY_SLEEP_STATE_DIR="$hwdb_dir/sleep-state"
  OMARCHY_SUSPEND_STATS_PATH="$hwdb_dir/suspend_stats"
  OMARCHY_CPUIDLE_PATH="$hwdb_dir/cpuidle"
  OMARCHY_MEM_SLEEP_PATH="$hwdb_dir/mem_sleep"
  OMARCHY_UPTIME_PATH="$hwdb_dir/uptime"
  OMARCHY_PMC_DEBUG_PATH="$hwdb_dir/no-pmc"
  OMARCHY_AMD_PMC_DEBUG_PATH="$hwdb_dir/no-amd"
)

env "${sleep_env[@]}" "$ROOT/default/systemd/system-sleep/omarchy-sleep-stats" pre suspend

# Simulate 2-hour battery sleep with ~2% drain and 95% S0ix residency.
printf '8200.00 0.00\n' >"$hwdb_dir/uptime"
printf '3907200\n' >"$hwdb_dir/power/BAT1/charge_now"
printf '6840000000\n' >"$hwdb_dir/suspend_stats/last_hw_sleep"
printf '10000000\n' >"$hwdb_dir/cpuidle/low_power_idle_system_residency_us"
env "${sleep_env[@]}" "$ROOT/default/systemd/system-sleep/omarchy-sleep-stats" post suspend

sleep_out=$(OMARCHY_POWER_SUPPLY_PATH="$hwdb_dir/power" OMARCHY_SLEEP_RUN_DIR="$hwdb_dir/sleep-run" OMARCHY_BATTERY_STATE_DIR="$hwdb_dir/bat-state" PATH="$hwdb_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'sleep_duration\t2h' <<<"$sleep_out" >/dev/null || fail "battery status formats last sleep duration" "$sleep_out"
grep -Fx $'sleep_drain_pct_hr\t1.0%/h' <<<"$sleep_out" >/dev/null || fail "battery status reports sleep drain rate in %/h" "$sleep_out"
grep -Fx $'sleep_drain_w\t0.7W' <<<"$sleep_out" >/dev/null || fail "battery status reports sleep drain in watts" "$sleep_out"
grep -Fx $'sleep_s0ix\t95%' <<<"$sleep_out" >/dev/null || fail "battery status reports S0ix residency" "$sleep_out"
grep -Fx $'sleep_mode\ts2idle' <<<"$sleep_out" >/dev/null || fail "battery status reports sleep mode" "$sleep_out"

# Wrapped PMC counter (>105% of wall time) is rejected instead of emitting >100% S0ix.
printf '8200.00 0.00\n' >"$hwdb_dir/uptime"
env "${sleep_env[@]}" "$ROOT/default/systemd/system-sleep/omarchy-sleep-stats" pre suspend
printf '11800.00 0.00\n' >"$hwdb_dir/uptime"
printf '3850000\n' >"$hwdb_dir/power/BAT1/charge_now"
printf '523986009990\n' >"$hwdb_dir/suspend_stats/last_hw_sleep"
printf '999999999999\n' >"$hwdb_dir/cpuidle/low_power_idle_system_residency_us"
env "${sleep_env[@]}" "$ROOT/default/systemd/system-sleep/omarchy-sleep-stats" post suspend

wrap_out=$(OMARCHY_POWER_SUPPLY_PATH="$hwdb_dir/power" OMARCHY_SLEEP_RUN_DIR="$hwdb_dir/sleep-run" OMARCHY_BATTERY_STATE_DIR="$hwdb_dir/bat-state" PATH="$hwdb_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
! grep -q '^sleep_s0ix'$'\t' <<<"$wrap_out" || fail "wrapped S0ix counter is suppressed" "$wrap_out"

# AC-plugged sleep suppresses sleep drain fields in battery-status --shell.
printf '1\n' >"$hwdb_dir/power/ACAD/online"
printf '11800.00 0.00\n' >"$hwdb_dir/uptime"
env "${sleep_env[@]}" "$ROOT/default/systemd/system-sleep/omarchy-sleep-stats" pre suspend
printf '15400.00 0.00\n' >"$hwdb_dir/uptime"
printf '4640000\n' >"$hwdb_dir/power/BAT1/charge_now"
env "${sleep_env[@]}" "$ROOT/default/systemd/system-sleep/omarchy-sleep-stats" post suspend

ac_sleep_out=$(OMARCHY_POWER_SUPPLY_PATH="$hwdb_dir/power" OMARCHY_SLEEP_RUN_DIR="$hwdb_dir/sleep-run" OMARCHY_BATTERY_STATE_DIR="$hwdb_dir/bat-state" PATH="$hwdb_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
! grep -q '^sleep_duration'$'\t' <<<"$ac_sleep_out" || fail "AC-plugged sleep is not reported as battery drain" "$ac_sleep_out"
pass "omarchy-sleep-stats tracks battery drain, clamps wrapped S0ix, and ignores AC sleep"

# omarchy-battery-limit CLI transitions (on/off/once/toggle/status) via stubbed busctl.
printf 'false\n' >"$hwdb_dir/upower-enabled"
cat >"$hwdb_dir/bin/busctl" <<STUB
#!/bin/bash
if [[ \$* == *"tree --list org.freedesktop.UPower"* ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  exit 0
fi
if [[ \$1 == "get-property" ]]; then
  case "\$5" in
    PowerSupply|ChargeThresholdSupported) echo "b true" ;;
    ChargeThresholdEnabled) echo "b \$(cat "$hwdb_dir/upower-enabled")" ;;
    ChargeThresholdSettingsSupported) echo "u 3" ;;
    ChargeEndThreshold) echo "u 80" ;;
    ChargeStartThreshold) echo "u 75" ;;
    NativePath) echo 's "BAT1"' ;;
  esac
  exit 0
fi
if [[ \$1 == "call" && \$5 == "EnableChargeThreshold" ]]; then
  printf '%s\n' "\$7" >"$hwdb_dir/upower-enabled"
  exit 0
fi
exit 1
STUB
chmod +x "$hwdb_dir/bin/busctl"

limit_env=(OMARCHY_POWER_SUPPLY_PATH="$hwdb_dir/power" OMARCHY_BATTERY_STATE_DIR="$hwdb_dir/limit-state" PATH="$hwdb_dir/bin:$PATH")
[[ $(env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" status) == "off" ]] || fail "battery-limit reports initial off state"
env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" on
[[ $(env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" status) == "on" ]] || fail "battery-limit enables charge limit"
env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" once
[[ $(env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" status) == "once" ]] || fail "battery-limit sets one-time top-up state"
env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" toggle
[[ $(env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" status) == "off" ]] || fail "battery-limit toggle turns limit off from one-time top-up"
env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" toggle
[[ $(env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" status) == "on" ]] || fail "battery-limit toggle turns limit on from off"
env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" off
[[ $(env "${limit_env[@]}" "$ROOT/bin/omarchy-battery-limit" status) == "off" ]] || fail "battery-limit disables charge limit"
pass "omarchy-battery-limit handles status, on, off, once, and toggle"
