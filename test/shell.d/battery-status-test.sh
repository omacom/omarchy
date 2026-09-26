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

# Display rounding is half-up to match the bar widget, but the charge-hold
# check must compare UPower's raw percentage: 79.5% displays as 80%, and an
# 80% hold threshold must not trip while the raw value is still below it.
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

grep -Fx $'percentage\t80%' <<<"$hold_output" >/dev/null || fail "display percentage rounds half-up"
grep -Fx $'state\tcharging' <<<"$hold_output" >/dev/null || fail "hold threshold compares the raw percentage"
pass "battery status rounds display percentage without tripping a hold early"

# Once the raw value reaches the threshold, idle charging is holding.
sed -i 's/percentage:           79.5%/percentage:           80.0%/' "$hold_dir/bin/upower"
held_output=$(OMARCHY_POWER_SUPPLY_PATH="$hold_dir/power" PATH="$hold_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t80%' <<<"$held_output" >/dev/null || fail "threshold percentage still displays as 80%"
grep -Fx $'state\tholding' <<<"$held_output" >/dev/null || fail "idle charging at the threshold is holding"
pass "battery status reports holding once the raw percentage reaches the threshold"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
