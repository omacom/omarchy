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
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  case "$2" in
    *DisplayDevice)
      cat <<'INFO'
  state:                discharging
  energy:               28.3 Wh
  energy-full:          56.7 Wh
  energy-rate:          7.3 W
  time to empty:        2.5 hours
  percentage:           51%
INFO
      ;;
    *BAT0)
      cat <<'INFO'
  native-path:          BAT0
  state:                discharging
  energy:               28.3 Wh
  energy-full:          56.7 Wh
  energy-rate:          7.3 W
  time to empty:        2.5 hours
  percentage:           51%
INFO
      ;;
    *)
      exit 1
      ;;
  esac
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

pass "battery status reports single-battery aggregate from DisplayDevice"

# Dual-battery: BAT0 full/idle, BAT1 draining. DisplayDevice holds the combined
# figures the bar icon already shows; the panel must match it, not BAT0 alone.
mkdir -p "$tmp_dir/power/BAT1"
printf '0\n' >"$tmp_dir/power/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/power/BAT0/voltage_now"
printf '1500000\n' >"$tmp_dir/power/BAT1/current_now"
printf '11000000\n' >"$tmp_dir/power/BAT1/voltage_now"
printf '100\n' >"$tmp_dir/power/BAT0/cycle_count"
printf '200\n' >"$tmp_dir/power/BAT1/cycle_count"

cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  echo "/org/freedesktop/UPower/devices/line_power_ADP1"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  case "$2" in
    *DisplayDevice)
      cat <<'INFO'
  state:                discharging
  energy:               30.15 Wh
  energy-full:          71.5 Wh
  energy-rate:          12.0 W
  time to empty:        2.5 hours
  percentage:           42.1678%
INFO
      ;;
    *BAT0)
      cat <<'INFO'
  native-path:          BAT0
  state:                fully-charged
  energy:               23.5 Wh
  energy-full:          24.0 Wh
  energy-rate:          0.0 W
  percentage:           98%
INFO
      ;;
    *BAT1)
      cat <<'INFO'
  native-path:          BAT1
  state:                discharging
  energy:               6.65 Wh
  energy-full:          47.5 Wh
  energy-rate:          12.0 W
  time to empty:        0.55 hours
  percentage:           14%
INFO
      ;;
    *)
      exit 1
      ;;
  esac
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

dual_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t42%' <<<"$dual_output" >/dev/null || fail "dual-battery status uses DisplayDevice percentage" "$dual_output"
grep -Fx $'state\tdischarging' <<<"$dual_output" >/dev/null || fail "dual-battery status uses DisplayDevice state" "$dual_output"
grep -Fx $'size\t71Wh' <<<"$dual_output" >/dev/null || fail "dual-battery status uses DisplayDevice capacity" "$dual_output"
grep -Fx $'time\t2h 30m' <<<"$dual_output" >/dev/null || fail "dual-battery status uses DisplayDevice remaining time" "$dual_output"
# BAT0 contributes 0W, BAT1 1.5A * 11V = 16.5W
grep -Fx $'rate\t16.5W' <<<"$dual_output" >/dev/null || fail "dual-battery status sums live sysfs power across BATs" "$dual_output"
grep -Fx $'cycles\t100' <<<"$dual_output" >/dev/null || fail "dual-battery status still reports a cycle count" "$dual_output"

# Guard against regressing to BAT0-only selection.
if grep -Fx $'percentage\t98%' <<<"$dual_output" >/dev/null; then
  fail "dual-battery status must not report BAT0-only percentage" "$dual_output"
fi

pass "dual-battery status matches DisplayDevice aggregate"

# No DisplayDevice (stubbed/old UPower): still report the first BAT.
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" && $2 == *BAT0 ]]; then
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
# Restore BAT0 current for the single-battery sysfs rate path.
printf '900000\n' >"$tmp_dir/power/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/power/BAT0/voltage_now"
# BAT1 still present on disk would sum into rate; remove it for this case.
rm -rf "$tmp_dir/power/BAT1"

fallback_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'percentage\t51%' <<<"$fallback_output" >/dev/null || fail "battery status falls back to first BAT without DisplayDevice" "$fallback_output"
grep -Fx $'rate\t10.8W' <<<"$fallback_output" >/dev/null || fail "fallback still reports live sysfs power rate" "$fallback_output"

pass "battery status falls back when DisplayDevice is absent"

# Drivers that report native-path as a full /sys/devices/... path still resolve
# through the power_supply class basename, so live wattage stays available.
mkdir -p "$tmp_dir/power/BAT1"
printf '0\n' >"$tmp_dir/power/BAT0/power_now"
printf '45000000\n' >"$tmp_dir/power/BAT1/power_now"
rm -f "$tmp_dir/power/BAT0/current_now" "$tmp_dir/power/BAT0/voltage_now"
rm -f "$tmp_dir/power/BAT1/current_now" "$tmp_dir/power/BAT1/voltage_now"

cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  case "$2" in
    *DisplayDevice)
      cat <<'INFO'
  state:                charging
  energy:               56.1 Wh
  energy-full:          66.0 Wh
  energy-rate:          5.0 W
  time to full:         0.3 hours
  percentage:           85%
INFO
      ;;
    *BAT0)
      cat <<'INFO'
  native-path:          BAT0
  state:                fully-charged
  energy-full:          24.0 Wh
  energy-rate:          0.0 W
  percentage:           98%
INFO
      ;;
    *BAT1)
      cat <<'INFO'
  native-path:          /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0A:01/power_supply/BAT1
  state:                charging
  energy-full:          42.0 Wh
  energy-rate:          5.0 W
  percentage:           79%
INFO
      ;;
    *)
      exit 1
      ;;
  esac
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

abs_path_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

# BAT0 0W + BAT1 45W via basename of the absolute native-path; not the stale 5W.
grep -Fx $'rate\t45W' <<<"$abs_path_output" >/dev/null || fail "absolute native-path still sums live sysfs power" "$abs_path_output"
grep -Fx $'state\tcharging' <<<"$abs_path_output" >/dev/null || fail "absolute native-path path keeps DisplayDevice state" "$abs_path_output"

pass "battery status resolves absolute native-path via basename"

# A pack with no readable sysfs node at all must not replace the DisplayDevice
# rate with a subtotal: a low enough result reads as a held charge.
mkdir -p "$tmp_dir/power/AC"
printf 'Mains\n' >"$tmp_dir/power/AC/type"
printf '1\n' >"$tmp_dir/power/AC/online"
printf '0\n' >"$tmp_dir/power/BAT0/power_now"
rm -rf "$tmp_dir/power/BAT1"

cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  case "$2" in
    *DisplayDevice)
      cat <<'INFO'
  state:                charging
  energy:               56.1 Wh
  energy-full:          66.0 Wh
  energy-rate:          45.0 W
  time to full:         0.3 hours
  percentage:           85%
INFO
      ;;
    *BAT0)
      cat <<'INFO'
  native-path:          BAT0
  state:                fully-charged
  energy-full:          24.0 Wh
  energy-rate:          0.0 W
  percentage:           98%
  charge-start-threshold: 75%
  charge-end-threshold:   80%
INFO
      ;;
    *BAT1)
      cat <<'INFO'
  native-path:          BAT1
  state:                charging
  energy-full:          42.0 Wh
  energy-rate:          45.0 W
  percentage:           79%
INFO
      ;;
    *)
      exit 1
      ;;
  esac
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

partial_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)

grep -Fx $'rate\t45W' <<<"$partial_output" >/dev/null || fail "unresolvable pack keeps the DisplayDevice rate instead of a subtotal" "$partial_output"
grep -Fx $'state\tcharging' <<<"$partial_output" >/dev/null || fail "a charging pack is not reported as holding" "$partial_output"

pass "battery status keeps the aggregate rate when a pack has no readable sysfs"

# battery_info remains an alias of the primary pack so concurrent design/health
# work that still reads that name does not silently drop those keys. Patch a
# temporary copy the same way #10377 would compose onto this branch.
tmp_script=$(mktemp)
trap 'rm -rf "$tmp_dir"; rm -f "$tmp_script"' EXIT
cp "$ROOT/bin/omarchy-battery-status" "$tmp_script"
chmod +x "$tmp_script"

python3 - "$tmp_script" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
needle = "  cycles=$(cat \"$power_supply_path\"/BAT*/cycle_count 2>/dev/null | head -1)\n"
insert = (
    "  # Composed design/health keys still read battery_info.\n"
    "  design=$(awk '/energy-full-design:/ { printf \"%d\", $2; exit }' <<<\"$battery_info\")\n"
    "  health=$(awk '/^[[:space:]]*capacity:/ { gsub(/%/, \"\", $2); printf \"%d\", $2; exit }' <<<\"$battery_info\")\n"
    "  [[ -n $design ]] && (( design > 0 )) && printf 'design\\t%sWh\\n' \"$design\"\n"
    "  [[ -n $health ]] && (( health > 0 )) && printf 'health\\t%s%%\\n' \"$health\"\n\n"
)
if needle not in text:
    raise SystemExit("cycles line not found for composition stub")
path.write_text(text.replace(needle, insert + needle, 1))
PY

cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  case "$2" in
    *DisplayDevice)
      cat <<'INFO'
  state:                discharging
  energy:               28.3 Wh
  energy-full:          56.7 Wh
  energy-rate:          7.3 W
  time to empty:        2.5 hours
  percentage:           51%
INFO
      ;;
    *BAT0)
      cat <<'INFO'
  native-path:          BAT0
  state:                discharging
  energy:               28.3 Wh
  energy-full:          56.7 Wh
  energy-full-design:   78.9 Wh
  energy-rate:          7.3 W
  time to empty:        2.5 hours
  percentage:           51%
  capacity:             71.8%
  capacity-level:       Normal
INFO
      ;;
    *)
      exit 1
      ;;
  esac
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"
printf '900000\n' >"$tmp_dir/power/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/power/BAT0/voltage_now"
rm -f "$tmp_dir/power/BAT0/power_now"
rm -rf "$tmp_dir/power/AC" "$tmp_dir/power/BAT1"

composed_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$tmp_script" --shell)

grep -Fx $'design\t78Wh' <<<"$composed_output" >/dev/null || fail "battery_info alias still supplies design capacity for composed keys" "$composed_output"
grep -Fx $'health\t71%' <<<"$composed_output" >/dev/null || fail "battery_info alias still supplies pack health for composed keys" "$composed_output"
grep -Fx $'health\t0%' <<<"$composed_output" >/dev/null && fail "composed health must not read capacity-level" "$composed_output"

pass "battery_info alias keeps composed design/health keys working"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
