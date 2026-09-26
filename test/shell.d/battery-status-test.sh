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
wedge_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t6.5W' <<<"$wedge_output" >/dev/null || fail "battery status estimates rate from charge deltas when UPower is wedged"
grep -Fx $'time\t4h 22m' <<<"$wedge_output" >/dev/null || fail "battery status estimates time left from energy when UPower is wedged"

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
(( history_lines == 2 )) || fail "battery status keeps the reference sample alongside new samples" "lines=$history_lines"

# A sane sysfs reading wins even when UPower is wedged, as before the fallback.
printf '900000\n' >"$tmp_dir/wedge/power/BAT0/current_now"
healthy_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t10.8W' <<<"$healthy_output" >/dev/null || fail "battery status prefers usable sysfs over the delta estimate"

# A sample from another battery must not be reused.
printf -- '-65000000\n' >"$tmp_dir/wedge/power/BAT0/current_now"
printf 'BAT1 discharging 1800000000 4609000 12000000\n' >"$tmp_dir/wedge-other.cache"
other_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge-other.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$other_output" >/dev/null || fail "battery status ignores samples from another battery"

# A sample from another state must not be reused either.
printf 'BAT0 charging 1800000000 4609000 12000000\n' >"$tmp_dir/wedge-state.cache"
state_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/wedge-state.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$state_output" >/dev/null || fail "battery status ignores samples from another state"

# A stale cache must not feed the estimate; the wedged UPower 0W stands.
printf 'BAT0 discharging 1799999000 4609000 12000000\n' >"$tmp_dir/stale.cache"
stale_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/wedge/power" OMARCHY_BATTERY_CACHE="$tmp_dir/stale.cache" PATH="$tmp_dir/wedge/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t0W' <<<"$stale_output" >/dev/null || fail "battery status ignores a stale charge cache"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
