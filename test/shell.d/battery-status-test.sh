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

# Multi-battery machines aggregate across every pack instead of reporting the
# first one: a small parked tablet cell must not shadow the bigger base pack
# doing all the work.
multi_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$multi_dir"' EXIT

mkdir -p "$multi_dir/bin" "$multi_dir/power/BAT0" "$multi_dir/power/BAT1"
printf '15780000\n' >"$multi_dir/power/BAT0/energy_now"
printf '0\n' >"$multi_dir/power/BAT0/power_now"
printf '86\n' >"$multi_dir/power/BAT0/cycle_count"
printf '36100000\n' >"$multi_dir/power/BAT1/energy_now"
printf '14660000\n' >"$multi_dir/power/BAT1/power_now"
printf '129\n' >"$multi_dir/power/BAT1/cycle_count"
cat >"$multi_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  case "$2" in
  *BAT0)
    cat <<'INFO'
  native-path:          BAT0
  state:                pending-charge
  energy:               15.78 Wh
  energy-full:          19.72 Wh
  energy-rate:          0 W
  percentage:           80%
INFO
    ;;
  *BAT1)
    cat <<'INFO'
  native-path:          BAT1
  state:                discharging
  energy:               36.1 Wh
  energy-full:          53.09 Wh
  energy-rate:          14.66 W
  time to empty:        2.5 hours
  percentage:           68%
INFO
    ;;
  esac
  exit 0
fi

exit 1
STUB
chmod +x "$multi_dir/bin/upower"

multi_output=$(OMARCHY_POWER_SUPPLY_PATH="$multi_dir/power" PATH="$multi_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t71%' <<<"$multi_output" >/dev/null || fail "battery status aggregates percentage across packs" "$multi_output"
grep -Fx $'state\tdischarging' <<<"$multi_output" >/dev/null || fail "battery status reports the working pack state" "$multi_output"
grep -Fx $'rate\t14.7W' <<<"$multi_output" >/dev/null || fail "battery status sums the live pack rates" "$multi_output"
grep -Fx $'size\t72Wh' <<<"$multi_output" >/dev/null || fail "battery status sums pack capacities" "$multi_output"
grep -Fx $'time\t3h 32m' <<<"$multi_output" >/dev/null || fail "battery status estimates time from aggregate energy" "$multi_output"
grep -Fx $'cycles\t86, 129' <<<"$multi_output" >/dev/null || fail "battery status reports every pack cycle count" "$multi_output"

pass "battery status aggregates multi-battery machines"
