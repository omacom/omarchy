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

# Snapdragon laptops name the system battery qcom-battmgr-bat rather than BAT*,
# and a peripheral battery listed first must not be picked instead.
arm_dir="$tmp_dir/arm"
mkdir -p "$arm_dir/bin" "$arm_dir/power/qcom-battmgr-bat"
printf '203\n' >"$arm_dir/power/qcom-battmgr-bat/cycle_count"
cat >"$arm_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_hidpp_battery_0"
  echo "/org/freedesktop/UPower/devices/battery_qcom_battmgr_bat"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" && $2 == */battery_hidpp_battery_0 ]]; then
  cat <<'INFO'
  native-path:          hidpp_battery_0
  power supply:         no
  percentage:           15%
INFO
  exit 0
fi

if [[ $1 == "-i" && $2 == */battery_qcom_battmgr_bat ]]; then
  cat <<'INFO'
  native-path:          qcom-battmgr-bat
  power supply:         yes
  state:                charging
  energy:               29.5 Wh
  energy-full:          39.42 Wh
  energy-rate:          28.8 W
  time to full:         20.6 minutes
  percentage:           74.8351%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$arm_dir/bin/upower"

arm_output=$(OMARCHY_POWER_SUPPLY_PATH="$arm_dir/power" PATH="$arm_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t74%' <<<"$arm_output" >/dev/null || fail "battery status finds a non-BAT system battery" "$arm_output"
grep -Fx $'state\tcharging' <<<"$arm_output" >/dev/null || fail "battery status skips peripheral batteries" "$arm_output"
grep -Fx $'cycles\t203' <<<"$arm_output" >/dev/null || fail "battery status reads cycles from the found battery" "$arm_output"

pass "battery status finds non-BAT system batteries and skips peripherals"
