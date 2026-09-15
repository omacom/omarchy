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

# Two packs: the composite DisplayDevice describes the machine, while the live
# rate sums every pack's sysfs telemetry and thresholds come from a real pack.
dual_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$dual_dir"' EXIT

mkdir -p "$dual_dir/bin" "$dual_dir/power/BAT0" "$dual_dir/power/BAT1"
printf '0\n' >"$dual_dir/power/BAT0/power_now"
printf '2500000\n' >"$dual_dir/power/BAT1/current_now"
printf '12000000\n' >"$dual_dir/power/BAT1/voltage_now"
cat >"$dual_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  case $2 in
  *battery_BAT0)
    cat <<'INFO'
  native-path:          BAT0
  state:                fully-charged
  energy:               24.8 Wh
  energy-full:          31.0 Wh
  energy-rate:          0 W
  percentage:           80%
  charge-start-threshold: 75%
  charge-end-threshold: 80%
INFO
    ;;
  *battery_BAT1)
    cat <<'INFO'
  native-path:          BAT1
  state:                charging
  energy:               26.1 Wh
  energy-full:          67.0 Wh
  energy-rate:          31.0 W
  time to full:         1.2 hours
  percentage:           39%
INFO
    ;;
  *DisplayDevice)
    cat <<'INFO'
  state:                charging
  energy:               50.9 Wh
  energy-full:          98.0 Wh
  energy-rate:          31.0 W
  time to full:         1.5 hours
  percentage:           52%
INFO
    ;;
  esac
  exit 0
fi

exit 1
STUB
chmod +x "$dual_dir/bin/upower"

dual_output=$(OMARCHY_POWER_SUPPLY_PATH="$dual_dir/power" PATH="$dual_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t52%' <<<"$dual_output" >/dev/null || fail "dual battery reports the composite percentage" "$dual_output"
grep -Fx $'state\tcharging' <<<"$dual_output" >/dev/null || fail "dual battery reports the composite state" "$dual_output"
grep -Fx $'size\t98Wh' <<<"$dual_output" >/dev/null || fail "dual battery reports the combined capacity" "$dual_output"
grep -Fx $'time\t1h 30m' <<<"$dual_output" >/dev/null || fail "dual battery reports the composite time to full" "$dual_output"
grep -Fx $'rate\t30W' <<<"$dual_output" >/dev/null || fail "dual battery sums the live rate across packs" "$dual_output"
grep -Fx $'threshold\t75-80%' <<<"$dual_output" >/dev/null || fail "dual battery keeps the pack's charge thresholds" "$dual_output"

pass "dual battery describes the machine through UPower's composite device"
