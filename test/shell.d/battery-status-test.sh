#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

export OMARCHY_BATTERY_CACHE="$tmp_dir/rate.cache"

mkdir -p "$tmp_dir/bin"
mkdir -p "$tmp_dir/power/BAT0"
printf '900000\n' >"$tmp_dir/power/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/power/BAT0/voltage_now"
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          BAT0
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

shell_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t51%' <<<"$shell_output" >/dev/null || fail "battery status reports percentage"
grep -Fx $'state\tdischarging' <<<"$shell_output" >/dev/null || fail "battery status reports state"
grep -Fx $'rate\t10.8W' <<<"$shell_output" >/dev/null || fail "battery status reports live sysfs power rate"
grep -Fx $'size\t56Wh' <<<"$shell_output" >/dev/null || fail "battery status reports full capacity"
grep -Fx $'time\t2h 30m' <<<"$shell_output" >/dev/null || fail "battery status reports remaining time"

# A bogus EC reading (e.g. MSI BIF0_9 reports current_now=-65A for a ~7.5W
# discharge) must not clobber the good UPower rate with -1124W.
printf -- '-65000000\n' >"$tmp_dir/power/BAT0/current_now"
bogus_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$bogus_output" >/dev/null || fail "battery status keeps the UPower rate when sysfs current is bogus"

# A non-numeric sysfs value is no reading at all.
printf 'unknown\n' >"$tmp_dir/power/BAT0/current_now"
garbage_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$garbage_output" >/dev/null || fail "battery status keeps the UPower rate when sysfs is non-numeric"

# A sane negative discharge current keeps the live sysfs rate, shown as magnitude.
printf -- '-500000\n' >"$tmp_dir/power/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/power/BAT0/voltage_now"
negative_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t6W' <<<"$negative_output" >/dev/null || fail "battery status reports live sysfs rate as magnitude when discharging"

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
grep -Fx $'rate\t6.5W' <<<"$wedge_output" >/dev/null || fail "battery status estimates rate from charge deltas when UPower is wedged"
grep -Fx $'time\t4h 22m' <<<"$wedge_output" >/dev/null || fail "battery status estimates time left from energy when UPower is wedged"

# A panel closed for less than the maximum window must still estimate on the
# next open, so an ordinary glance is not punished with 30s of UPower's 0W.
printf 'BAT0 discharging 1799999950 4619000 12000000\n' >"$tmp_dir/closed.cache"
printf 'BAT0 discharging 1800000000 4610000 12000000\n' >>"$tmp_dir/closed.cache"
closed_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/closed.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.5W' <<<"$closed_output" >/dev/null || fail "battery status estimates on reopen after a short close"
grep -Fx $'time\t3h 47m' <<<"$closed_output" >/dev/null || fail "battery status estimates time on reopen after a short close"

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

# UPower can also report a rate while omitting its time estimate entirely; the
# remaining time must still come from energy over that rate.
mkdir -p "$tmp_dir/notime/bin" "$tmp_dir/notime/power/BAT0"
cat >"$tmp_dir/notime/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          BAT0
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
chmod +x "$tmp_dir/notime/bin/upower"
printf -- '-65000000\n' >"$tmp_dir/notime/power/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/notime/power/BAT0/voltage_now"
notime_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/notime/power" OMARCHY_BATTERY_CACHE="$tmp_dir/notime.cache" PATH="$tmp_dir/notime/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'time\t3h 52m' <<<"$notime_output" >/dev/null || fail "battery status estimates time left when UPower omits it"

# A younger sample must not become the reference window until 30s has passed.
printf 'BAT0 discharging 1800000050 4609000 12000000\n' >"$tmp_dir/wedge-young.cache"
young_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge-young.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$young_output" >/dev/null || fail "battery status does not estimate over a sub-30s window"

# The history must retain older samples so the window grows instead of resetting.
grep -c '^BAT0 discharging ' "$tmp_dir/wedge.cache" >/dev/null || fail "battery status keeps charge history"
history_lines=$(grep -c '^BAT0 discharging ' "$tmp_dir/wedge.cache")
(( history_lines == 3 )) || fail "battery status keeps the reference sample alongside new samples" "lines=$history_lines"

# A sane sysfs reading wins even when UPower is wedged, as before the fallback.
printf '900000\n' >"$tmp_dir/wedge/power/BAT0/current_now"
healthy_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t10.8W' <<<"$healthy_output" >/dev/null || fail "battery status prefers usable sysfs over the delta estimate"

# A sample from another battery must not be reused. It is 35s old, so the
# window filter keeps it and only the identity check can drop it.
printf -- '-65000000\n' >"$tmp_dir/wedge/power/BAT0/current_now"
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

# Time to full must use the untruncated energy-full: 0.8Wh at 5W is about 9m,
# not the 1m that the whole-Wh display capacity would give.
mkdir -p "$tmp_dir/charging/bin" "$tmp_dir/charging/power/BAT0"
cat >"$tmp_dir/charging/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          BAT0
  state:                charging
  energy:               55.9 Wh
  energy-full:          56.7 Wh
  energy-rate:          5 W
  percentage:           99%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/charging/bin/upower"
printf -- '-65000000\n' >"$tmp_dir/charging/power/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/charging/power/BAT0/voltage_now"
printf '4900000\n' >"$tmp_dir/charging/power/BAT0/charge_now"
charging_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/charging/power" OMARCHY_BATTERY_CACHE="$tmp_dir/charging.cache" PATH="$tmp_dir/charging/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'time\t9m' <<<"$charging_output" >/dev/null || fail "battery status uses untruncated capacity for time to full"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
