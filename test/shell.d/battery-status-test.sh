#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Every run of the script shares this scratch cache. Without it, a fixture that
# reaches the script's state handling would clear (or write) the battery history
# in the developer's real $XDG_RUNTIME_DIR.
export OMARCHY_BATTERY_CACHE="$tmp_dir/rate.cache"

# The real runtime directory must stay untouched too, so point it at scratch and
# seed a history that no fixture is allowed to clear.
export XDG_RUNTIME_DIR="$tmp_dir/runtime"
mkdir -p "$XDG_RUNTIME_DIR"
runtime_cache="$XDG_RUNTIME_DIR/omarchy-battery-rate.cache"
printf 'BAT0 discharging 1 4600000 12000000\n' >"$runtime_cache"

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

# A bogus EC reading (e.g. MSI BIF0_9 reports current_now=-65A for a ~7.5W
# discharge) must not clobber the good UPower rate with -1124W.
mkdir -p "$tmp_dir/bogus/bin" "$tmp_dir/bogus/power/BAT0"
cat >"$tmp_dir/bogus/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          BAT0
  power supply:         yes
  state:                discharging
  energy:               28.3 Wh
  energy-full:          56.7 Wh
  energy-rate:          7.3 W
  percentage:           51%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bogus/bin/upower"
printf '12000000\n' >"$tmp_dir/bogus/power/BAT0/voltage_now"
printf -- '-65000000\n' >"$tmp_dir/bogus/power/BAT0/current_now"
bogus_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/bogus/power" PATH="$tmp_dir/bogus/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$bogus_output" >/dev/null || fail "battery status keeps the UPower rate when sysfs current is bogus" "$bogus_output"

# A sysfs reading far above UPower's own rate is an EC fault, not a load.
printf -- '-2000000\n' >"$tmp_dir/bogus/power/BAT0/current_now"
high_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/bogus/power" PATH="$tmp_dir/bogus/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$high_output" >/dev/null || fail "battery status rejects a sysfs rate far above UPower's" "$high_output"

# A non-numeric sysfs value is no reading at all.
printf 'unknown\n' >"$tmp_dir/bogus/power/BAT0/current_now"
garbage_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/bogus/power" PATH="$tmp_dir/bogus/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$garbage_output" >/dev/null || fail "battery status keeps the UPower rate when sysfs is non-numeric" "$garbage_output"

# A sane negative discharge current keeps the live sysfs rate, shown as magnitude.
printf -- '-500000\n' >"$tmp_dir/bogus/power/BAT0/current_now"
negative_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/bogus/power" PATH="$tmp_dir/bogus/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t6W' <<<"$negative_output" >/dev/null || fail "battery status reports live sysfs rate as magnitude when discharging" "$negative_output"
pass "battery status rejects implausible sysfs readings and keeps a sane one"

# When UPower wedges at 0W and sysfs is bogus, estimate from charge_now deltas:
# 9000uAh dropped in 60s at 12V -> ~6.5W.
mkdir -p "$tmp_dir/wedge/bin" "$tmp_dir/wedge/power/BAT0"
cat >"$tmp_dir/wedge/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          BAT0
  power supply:         yes
  state:                discharging
  energy:               28.3 Wh
  energy-full:          56.7 Wh
  energy-rate:          0 W
  percentage:           51%
INFO
  exit 0
fi

exit 1
STUB
cat >"$tmp_dir/wedge/bin/date" <<'STUB'
#!/bin/bash

if [[ $1 == "+%s" ]]; then
  echo 1800000060
  exit 0
fi

exec /usr/bin/date "$@"
STUB
chmod +x "$tmp_dir/wedge/bin/upower" "$tmp_dir/wedge/bin/date"
printf -- '-65000000\n' >"$tmp_dir/wedge/power/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/wedge/power/BAT0/voltage_now"
printf '4600000\n' >"$tmp_dir/wedge/power/BAT0/charge_now"
printf 'BAT0 discharging 1800000000 4609000 12000000\n' >"$tmp_dir/wedge.cache"
printf 'BAT0 discharging 1800000055 4608000 12000000\n' >>"$tmp_dir/wedge.cache"
wedge_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t6.5W' <<<"$wedge_output" >/dev/null || fail "battery status estimates rate from charge deltas when UPower is wedged" "$wedge_output"
grep -Fx $'time\t4h 22m' <<<"$wedge_output" >/dev/null || fail "battery status derives time left from the estimated rate" "$wedge_output"

# A panel closed for less than the maximum window must still estimate on the
# next open, so an ordinary glance is not punished with 30s of UPower's 0W.
printf 'BAT0 discharging 1799999950 4619000 12000000\n' >"$tmp_dir/closed.cache"
printf 'BAT0 discharging 1800000000 4610000 12000000\n' >>"$tmp_dir/closed.cache"
closed_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/closed.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.5W' <<<"$closed_output" >/dev/null || fail "battery status estimates on reopen after a short close" "$closed_output"

# A close longer than the maximum window leaves nothing recent enough to
# measure, so the estimate waits for a fresh window.
printf 'BAT0 discharging 1799999760 4619000 12000000\n' >"$tmp_dir/closed-long.cache"
closed_long_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/closed-long.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$closed_long_output" >/dev/null || fail "battery status does not estimate across a close longer than the window"
if [[ -n $(awk -F'\t' '/^time/{print $2}' <<<"$closed_long_output") ]]; then
  fail "battery status reports no time across a close longer than the window"
fi

# Samples older than the maximum window are dropped, so the reference is the
# oldest sample that is still inside it.
printf 'BAT0 discharging 1799999920 4620000 12000000\n' >"$tmp_dir/window.cache"
printf 'BAT0 discharging 1799999960 4610000 12000000\n' >>"$tmp_dir/window.cache"
printf 'BAT0 discharging 1800000000 4606000 12000000\n' >>"$tmp_dir/window.cache"
printf 'BAT0 discharging 1800000040 4602000 12000000\n' >>"$tmp_dir/window.cache"
window_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/window.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t4.3W' <<<"$window_output" >/dev/null || fail "battery status measures within the maximum window"

# The oldest sample inside the window is the reference, so a burst of newer
# samples cannot shrink the measurement window and inflate the rate.
printf 'BAT0 discharging 1800000000 4610000 12000000\n' >"$tmp_dir/wedge-ref.cache"
printf 'BAT0 discharging 1800000025 4609500 12000000\n' >>"$tmp_dir/wedge-ref.cache"
ref_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge-ref.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.2W' <<<"$ref_output" >/dev/null || fail "battery status measures from the oldest sample in the window"

# A younger sample must not become the reference window until 30s has passed.
printf 'BAT0 discharging 1800000050 4609000 12000000\n' >"$tmp_dir/wedge-young.cache"
young_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge-young.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$young_output" >/dev/null || fail "battery status does not estimate over a sub-30s window"

# Cache fields reach shell arithmetic, so a non-numeric reading must be dropped
# rather than evaluated or carried forward. The sample is inside the window so
# the window filter cannot account for dropping it.
printf 'BAT0 discharging 1800000025 46abc 12000000\n' >"$tmp_dir/wedge-bad.cache"
bad_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge-bad.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$bad_output" >/dev/null || fail "battery status ignores cache samples with non-numeric fields"
if grep -q '46abc' "$tmp_dir/wedge-bad.cache"; then
  fail "battery status drops non-numeric cache samples"
fi

# A sample that reaches the arithmetic with its voltage missing must be dropped,
# not averaged as if the voltage were zero.
printf 'BAT0 discharging 1800000025 4609000\n' >"$tmp_dir/novolt.cache"
novolt_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/novolt.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$novolt_output" >/dev/null || fail "battery status ignores a sample without a voltage"

# A sample from another battery must not be reused. It is 35s old, so the
# window filter keeps it and only the identity check can drop it.
printf 'BAT1 discharging 1800000025 4609000 12000000\n' >"$tmp_dir/wedge-other.cache"
other_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge-other.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$other_output" >/dev/null || fail "battery status ignores samples from another battery"

# A sample from another state must not be reused either.
printf 'BAT0 charging 1800000025 4609000 12000000\n' >"$tmp_dir/wedge-state.cache"
state_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge-state.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$state_output" >/dev/null || fail "battery status ignores samples from another state"

# A cache older than the maximum window must not feed the estimate; the wedged
# UPower 0W stands.
printf 'BAT0 discharging 1799999000 4609000 12000000\n' >"$tmp_dir/stale.cache"
stale_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/stale.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$stale_output" >/dev/null || fail "battery status ignores a stale charge cache"

# A sample dated in the future (a wall-clock correction) is not a usable window.
printf 'BAT0 discharging 1800000900 4609000 12000000\n' >"$tmp_dir/future.cache"
future_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/future.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$future_output" >/dev/null || fail "battery status ignores future-dated samples"
if grep -q '1800000900' "$tmp_dir/future.cache"; then
  fail "battery status drops future-dated cache samples"
fi

# A hold at a charge limit interrupts sampling, so the discharge history from
# before it must not be measured across it: unplugging within the window would
# otherwise report the hold's elapsed time as draw time.
printf 'BAT0 discharging 1799999950 4619000 12000000\n' >"$tmp_dir/hold.cache"
printf 'BAT0 discharging 1800000000 4610000 12000000\n' >>"$tmp_dir/hold.cache"
sed -i 's/state:                discharging/state:                pending-charge/' "$tmp_dir/wedge/bin/upower"
hold_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/hold.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
sed -i 's/state:                pending-charge/state:                discharging/' "$tmp_dir/wedge/bin/upower"
grep -Fx $'rate\t0W' <<<"$hold_output" >/dev/null || fail "battery status does not estimate while a hold is in progress" "$hold_output"
if grep -q '^BAT0 ' "$tmp_dir/hold.cache" 2>/dev/null; then
  fail "battery status drops a charge history the hold interrupted"
fi
pass "battery status drops a charge history a hold interrupted"

pass "battery status estimates from a bounded, validated charge history"

# The history must retain older samples so the window grows instead of resetting.
history_lines=$(grep -c '^BAT0 discharging ' "$tmp_dir/wedge.cache")
(( history_lines == 3 )) || fail "battery status keeps the reference sample alongside new samples" "lines=$history_lines"

# A sane sysfs reading wins even when UPower is wedged, as before the fallback.
printf '900000\n' >"$tmp_dir/wedge/power/BAT0/current_now"
healthy_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t10.8W' <<<"$healthy_output" >/dev/null || fail "battery status prefers usable sysfs over the delta estimate"
pass "battery status prefers a usable sysfs rate over the estimate"

# Cycle count: an EC reporting 0 while UPower says N/A means "unknown", so the
# row is omitted; a real count is shown.
printf '0\n' >"$tmp_dir/wedge/power/BAT0/cycle_count"
unknown_cycles_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/cycles.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
if grep -q $'^cycles\t' <<<"$unknown_cycles_output"; then
  fail "battery status omits an unknown cycle count"
fi
printf '7\n' >"$tmp_dir/wedge/power/BAT0/cycle_count"
known_cycles_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/cycles.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'cycles\t7' <<<"$known_cycles_output" >/dev/null || fail "battery status reports a known cycle count"
rm -f "$tmp_dir/wedge/power/BAT0/cycle_count"
pass "battery status suppresses an unknown cycle count"

# No run above may have fallen back to the runtime directory: a fully charged
# fixture clears the charge history, and doing that to the real cache would cost
# the machine 30s of readings.
[[ $(cat "$runtime_cache" 2>/dev/null) == "BAT0 discharging 1 4600000 12000000" ]] ||
  fail "battery status tests leave the runtime charge cache alone"
pass "battery status tests leave the runtime charge cache alone"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
