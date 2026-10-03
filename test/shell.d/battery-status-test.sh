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

battery_status() {
  OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-status" --shell
}

for unusable in "0" "-1" "unknown" "a[\$(touch $tmp_dir/evaluated)]"; do
  printf '%s\n' "$unusable" >"$tmp_dir/power/BAT0/cycle_count"
  unusable_output=$(battery_status)

  grep -Fx $'percentage\t51%' <<<"$unusable_output" >/dev/null || fail "battery status still reports the rest of the battery" "cycle_count=$unusable"

  if grep -q $'^cycles\t' <<<"$unusable_output"; then
    fail "battery status hides an unusable cycle count" "cycle_count=$unusable"
  fi
done

if [[ -e $tmp_dir/evaluated ]]; then
  fail "battery status reads the cycle count as data, not code"
fi

pass "battery status hides an unusable cycle count"

for usable in "1337:1337" "010:10" " 450 :450"; do
  printf '%s\n' "${usable%:*}" >"$tmp_dir/power/BAT0/cycle_count"
  usable_output=$(battery_status)

  grep -Fx $'cycles\t'"${usable##*:}" <<<"$usable_output" >/dev/null || fail "battery status reports a real cycle count" "cycle_count=${usable%:*}"
done

# A pack whose firmware reports nothing must not hide a sibling's real count.
mkdir -p "$tmp_dir/power/BAT1"
printf '0\n' >"$tmp_dir/power/BAT0/cycle_count"
printf '450\n' >"$tmp_dir/power/BAT1/cycle_count"
battery_status | grep -Fx $'cycles\t450' >/dev/null || fail "battery status reports a real cycle count from a second pack"

pass "battery status reports a real cycle count"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status owns capacity and remaining calculations"
