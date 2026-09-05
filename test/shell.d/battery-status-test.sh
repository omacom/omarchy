#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
mkdir -p "$tmp_dir/power/BAT0"
printf 'Battery\n' >"$tmp_dir/power/BAT0/type"
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

# Ordinary laptops still enumerate DisplayDevice. Combined capacity is only
# for multiple packs; one BAT* must keep the sysfs live rate.
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  if [[ $* == *DisplayDevice* ]]; then
    cat <<'INFO'
  native-path:          DisplayDevice
  state:                discharging
  energy-full:          56.7 Wh
  energy-rate:          7.3 W
  time to empty:        2.5 hours
  percentage:           12%
INFO
  else
    cat <<'INFO'
  native-path:          BAT0
  state:                discharging
  energy-full:          56.7 Wh
  energy-rate:          7.3 W
  time to empty:        2.5 hours
  percentage:           51%
INFO
  fi
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

shell_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t51%' <<<"$shell_output" >/dev/null ||
  fail "single-pack status stays on BAT0 when DisplayDevice is also listed" "$shell_output"
grep -Fx $'rate\t10.8W' <<<"$shell_output" >/dev/null ||
  fail "single-pack status keeps the live sysfs power rate" "$shell_output"
pass "single-pack status stays on BAT0 when DisplayDevice is also listed"

# Dual-battery machines report a combined DisplayDevice; reading only BAT0
# leaves the power panel stuck on the idle internal pack.
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  echo "/org/freedesktop/UPower/devices/battery_BAT1"
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  if [[ $* == *DisplayDevice* ]]; then
    cat <<'INFO'
  native-path:          DisplayDevice
  state:                discharging
  energy:               24.76 Wh
  energy-full:          66.01 Wh
  energy-rate:          12.0 W
  time to empty:        2.0 hours
  percentage:           37%
INFO
  else
    cat <<'INFO'
  native-path:          BAT0
  state:                fully-charged
  energy:               23.5 Wh
  energy-full:          24.0 Wh
  energy-rate:          0.0 W
  percentage:           98%
INFO
  fi
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

shell_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'percentage\t37%' <<<"$shell_output" >/dev/null ||
  fail "battery status uses UPower DisplayDevice on dual-battery systems" "$shell_output"
grep -Fx $'state\tdischarging' <<<"$shell_output" >/dev/null ||
  fail "battery status uses DisplayDevice state, not BAT0" "$shell_output"
pass "battery status uses UPower DisplayDevice on dual-battery systems"

# DisplayDevice exists on desktops with no pack. Combined-capacity display is
# only meaningful when a BAT* device is also enumerated.
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/DisplayDevice"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          DisplayDevice
  state:                unknown
  percentage:           0%
INFO
  exit 0
fi

exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

shell_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
[[ -z $shell_output ]] ||
  fail "battery status ignores DisplayDevice when no BAT pack exists" "$shell_output"
pass "battery status ignores DisplayDevice when no BAT pack exists"
