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

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"

# Multi-battery setup with UPower DisplayDevice
mkdir -p "$tmp_dir/multi/power/BAT0"
mkdir -p "$tmp_dir/multi/power/BAT1"
printf '0\n' >"$tmp_dir/multi/power/BAT0/power_now"
printf '53\n' >"$tmp_dir/multi/power/BAT0/cycle_count"
printf '16000000\n' >"$tmp_dir/multi/power/BAT1/power_now"
printf '55\n' >"$tmp_dir/multi/power/BAT1/cycle_count"

cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  if [[ $2 == *DisplayDevice ]]; then
    cat <<'INFO'
    present:             yes
    state:               charging
    energy:              10.0 Wh
    energy-full:         50.0 Wh
    energy-rate:         15.0 W
    time to full:        2.0 hours
    percentage:          20%
INFO
    exit 0
  fi
fi

exit 1
STUB

multi_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/multi/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t20%' <<<"$multi_output" >/dev/null || fail "multi-battery status reports composite percentage"
grep -Fx $'state\tcharging' <<<"$multi_output" >/dev/null || fail "multi-battery status reports composite state"
grep -Fx $'rate\t16W' <<<"$multi_output" >/dev/null || fail "multi-battery status sums sysfs power rates"
grep -Fx $'size\t50Wh' <<<"$multi_output" >/dev/null || fail "multi-battery status reports composite full capacity"
grep -Fx $'time\t2h' <<<"$multi_output" >/dev/null || fail "multi-battery status reports composite remaining time"
grep -Fx $'cycles\t53 / 55' <<<"$multi_output" >/dev/null || fail "multi-battery status reports combined cycle counts"

pass "battery status aggregates multiple batteries via DisplayDevice"
