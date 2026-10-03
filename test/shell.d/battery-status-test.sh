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

# power_now can exist yet fail to read (ENODEV on some hardware). The failed
# read must not clobber the good UPower rate with 0W (#12735). A fake cat that
# refuses power_now stands in for the failing kernel read either way.
mkdir -p "$tmp_dir/enodev/bin" "$tmp_dir/enodev/power/BAT0"
printf '0\n' >"$tmp_dir/enodev/power/BAT0/power_now"
cat >"$tmp_dir/enodev/bin/upower" <<'STUB'
#!/bin/bash

if [[ $1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ $1 == "-i" ]]; then
  cat <<'INFO'
  native-path:          BAT0
  state:                discharging
  energy:               37.9 Wh
  energy-full:          40.0 Wh
  energy-rate:          5.5 W
  time to empty:        6.9 hours
  percentage:           94%
INFO
  exit 0
fi

exit 1
STUB
cat >"$tmp_dir/enodev/bin/cat" <<'STUB'
#!/bin/bash

for arg in "$@"; do
  [[ $arg == *power_now ]] && exit 1
done
exec /usr/bin/cat "$@"
STUB
chmod +x "$tmp_dir/enodev/bin/upower" "$tmp_dir/enodev/bin/cat"

enodev_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/enodev/power" PATH="$tmp_dir/enodev/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t5.5W' <<<"$enodev_output" >/dev/null || fail "battery status keeps the UPower rate when power_now fails to read"

# A non-numeric sysfs value is no reading at all.
printf 'unknown\n' >"$tmp_dir/power/BAT0/current_now"
rm -f "$tmp_dir/power/BAT0/power_now"
garbage_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$garbage_output" >/dev/null || fail "battery status keeps the UPower rate when sysfs is non-numeric"

# Same for power_now itself: each guard has to earn its keep independently.
printf 'unknown\n' >"$tmp_dir/power/BAT0/power_now"
unknown_output=$(OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell)
grep -Fx $'rate\t7.3W' <<<"$unknown_output" >/dev/null || fail "battery status keeps the UPower rate when power_now is non-numeric"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
