#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

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
  energy-full:          55.0 Wh
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
grep -Fx $'size\t55Wh' <<<"$shell_output" >/dev/null || fail "battery status reports full capacity"
grep -Fx $'time\t2h 30m' <<<"$shell_output" >/dev/null || fail "battery status reports remaining time"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"

# Multi-battery machines expose one UPower device per pack: the status must
# combine them instead of reporting the first pack alone.
multi_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$multi_dir"' EXIT

mkdir -p "$multi_dir/bin" "$multi_dir/power/BAT0" "$multi_dir/power/BAT1"
printf '6000000\n' >"$multi_dir/power/BAT0/power_now"
printf '4000000\n' >"$multi_dir/power/BAT1/power_now"
cat >"$multi_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  if [[ $2 == *BAT1 ]]; then
    cat <<'INFO'
  native-path:          BAT1
  state:                discharging
  energy:               30.0 Wh
  energy-full:          50.0 Wh
  energy-rate:          5.0 W
  time to empty:        3.0 hours
  percentage:           60%
INFO
  else
    cat <<'INFO'
  native-path:          BAT0
  state:                discharging
  energy:               20.0 Wh
  energy-full:          50.0 Wh
  energy-rate:          5.0 W
  time to empty:        2.0 hours
  percentage:           40%
INFO
  fi
  exit 0
fi

exit 1
STUB
chmod +x "$multi_dir/bin/upower"

multi_output=$(OMARCHY_POWER_SUPPLY_PATH="$multi_dir/power" PATH="$multi_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

# (20 + 30) / (50 + 50) = 50%, not BAT0's 40% alone.
grep -Fx $'percentage\t50%' <<<"$multi_output" >/dev/null || fail "battery status weights percentage across packs" "$multi_output"
pass "battery status weights percentage across packs"

grep -Fx $'size\t100Wh' <<<"$multi_output" >/dev/null || fail "battery status sums capacity across packs" "$multi_output"
pass "battery status sums capacity across packs"

# Live sysfs draw summed across packs: 6W + 4W.
grep -Fx $'rate\t10W' <<<"$multi_output" >/dev/null || fail "battery status sums power draw across packs" "$multi_output"
pass "battery status sums power draw across packs"

# The most urgent pack sets the remaining time: min(2h, 3h).
grep -Fx $'time\t2h' <<<"$multi_output" >/dev/null || fail "battery status reports the most urgent pack time" "$multi_output"
pass "battery status reports the most urgent pack time"

grep -Fx $'state\tdischarging' <<<"$multi_output" >/dev/null || fail "battery status reports combined state" "$multi_output"
pass "battery status reports combined state"
