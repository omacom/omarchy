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

# Some laptops (e.g. ThinkPads with a second, unpopulated battery bay) expose
# a phantom BAT device with no real capacity data alongside the real one.
# `upower -e` lists BAT0 first in that case, but BAT0 carries no usable data;
# the real battery is BAT1. Make sure the script picks the device with real
# capacity data rather than blindly taking the first one listed.
mkdir -p "$tmp_dir/power/BAT1"
printf '1\n' >"$tmp_dir/power/BAT0/cycle_count"
printf '80\n' >"$tmp_dir/power/BAT1/cycle_count"
printf '900000\n' >"$tmp_dir/power/BAT1/current_now"
printf '12000000\n' >"$tmp_dir/power/BAT1/voltage_now"
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  case "$2" in
    */battery_BAT0)
      cat <<'INFO'
  native-path:          BAT0
  state:                unknown
  energy:               0 Wh
  energy-full:          0 Wh
  energy-rate:          0 W
  percentage:           0%
INFO
      ;;
    */battery_BAT1)
      cat <<'INFO'
  native-path:          BAT1
  state:                charging
  energy:               38.3 Wh
  energy-full:          56.4 Wh
  energy-rate:          29.7 W
  time to full:         36.5 minutes
  percentage:           68%
  charge-start-threshold:        75%
  charge-end-threshold:          80%
INFO
      ;;
  esac
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

dual_battery_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t68%' <<<"$dual_battery_output" >/dev/null || fail "battery status prefers the real battery's percentage over a phantom BAT device"
grep -Fx $'state\tcharging' <<<"$dual_battery_output" >/dev/null || fail "battery status prefers the real battery's state over a phantom BAT device"
grep -Fx $'cycles\t80' <<<"$dual_battery_output" >/dev/null || fail "battery status reads cycle count from the real battery, not the phantom device"
grep -Fx $'threshold\t75-80%' <<<"$dual_battery_output" >/dev/null || fail "battery status reads charge thresholds from the real battery"

pass "battery status prefers a real battery with capacity data over a phantom BAT device"

# If upower ever reports a native-path that doesn't resolve to a real sysfs
# directory (an absolute path from a different upower build, an unexpected
# device name), the script must degrade gracefully -- report what upower gave
# it and skip the sysfs-only extras -- rather than reading through a bogus
# concatenated path.
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          /sys/devices/platform/battery/power_supply/BAT0
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

unresolvable_native_path_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t51%' <<<"$unresolvable_native_path_output" >/dev/null || fail "battery status still reports percentage with an unresolvable native-path"
grep -Fx $'rate\t7.3W' <<<"$unresolvable_native_path_output" >/dev/null || fail "battery status falls back to upower's energy-rate with an unresolvable native-path"
grep -q $'^cycles\t' <<<"$unresolvable_native_path_output" && fail "battery status should not report cycles with an unresolvable native-path"

pass "battery status degrades gracefully when native-path doesn't resolve to a sysfs directory"
