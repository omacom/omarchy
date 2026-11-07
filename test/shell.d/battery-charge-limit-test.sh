#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
mkdir -p "$tmp_dir/state"
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "-e" ]]; then
  if [[ -n ${UPOWER_DEVICES:-} ]]; then printf '%b' "$UPOWER_DEVICES"; else echo "/org/freedesktop/UPower/devices/battery_BAT0"; fi
  exit 0
fi
exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

# Fake busctl backed by files so get/set round-trips without D-Bus.
cat >"$tmp_dir/bin/busctl" <<'STUB'
#!/bin/bash
state_dir="${BUSCTL_STATE_DIR:-/tmp/busctl-state}"
mkdir -p "$state_dir"
device=${3:-}
prop=${5:-}
device_state="$state_dir/${device##*/}"
mkdir -p "$device_state"
[[ -f $device_state/supported ]] || printf 'true' >"$device_state/supported"
[[ -f $device_state/enabled ]] || printf 'true' >"$device_state/enabled"
if [[ $1 == "get-property" ]]; then
  case "$prop" in
    ChargeThresholdSupported) printf 'b %s\n' "$(cat "$device_state/supported")" ;;
    ChargeThresholdEnabled) printf 'b %s\n' "$(cat "$device_state/enabled")" ;;
    ChargeStartThreshold) printf 'u 75\n' ;;
    ChargeEndThreshold) printf 'u 80\n' ;;
    *) exit 1 ;;
  esac
  exit 0
fi
if [[ $1 == "call" ]]; then
  value="${7:-}"
  [[ $value == "true" || $value == "false" ]] || exit 1
  printf '%s' "$value" >"$device_state/enabled"
  exit 0
fi
exit 1
STUB
chmod +x "$tmp_dir/bin/busctl"

run() {
  BUSCTL_STATE_DIR="$tmp_dir/state" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-charge-limit" "$@"
}

mkdir -p "$tmp_dir/state/battery_BAT0"
printf 'true' >"$tmp_dir/state/battery_BAT0/enabled"
printf 'true' >"$tmp_dir/state/battery_BAT0/supported"

shell_output=$(run status --shell)
grep -Fx $'enabled\ttrue' <<<"$shell_output" >/dev/null || fail "charge limit reports enabled state" "$shell_output"
grep -Fx $'start\t75' <<<"$shell_output" >/dev/null || fail "charge limit reports start threshold" "$shell_output"
grep -Fx $'end\t80' <<<"$shell_output" >/dev/null || fail "charge limit reports end threshold" "$shell_output"
grep -Fx $'supported\ttrue' <<<"$shell_output" >/dev/null || fail "charge limit reports support" "$shell_output"
pass "charge limit status --shell reports threshold state"

run full >/dev/null
[[ $(cat "$tmp_dir/state/battery_BAT0/enabled") == "false" ]] || fail "charge limit full disables the threshold"
shell_output=$(run status --shell)
grep -Fx $'enabled\tfalse' <<<"$shell_output" >/dev/null || fail "charge limit reports disabled state" "$shell_output"
pass "charge limit full disables the threshold"

run 80 >/dev/null
[[ $(cat "$tmp_dir/state/battery_BAT0/enabled") == "true" ]] || fail "charge limit 80 enables the threshold"
pass "charge limit 80 enables the threshold"

run toggle >/dev/null
[[ $(cat "$tmp_dir/state/battery_BAT0/enabled") == "false" ]] || fail "charge limit toggle flips enabled to disabled"
run toggle >/dev/null
[[ $(cat "$tmp_dir/state/battery_BAT0/enabled") == "true" ]] || fail "charge limit toggle flips disabled to enabled"
pass "charge limit toggle flips the threshold"

printf 'false' >"$tmp_dir/state/battery_BAT0/supported"
if run status --shell >/dev/null 2>&1; then
  fail "charge limit reports unknown without a capable battery"
fi
pass "charge limit exits non-zero without a capable battery"

mkdir -p "$tmp_dir/state/battery_macsmc_battery" "$tmp_dir/state/battery_BAT1" "$tmp_dir/state/battery_BAT2"
printf 'true' >"$tmp_dir/state/battery_macsmc_battery/supported"
printf 'true' >"$tmp_dir/state/battery_macsmc_battery/enabled"
printf 'false' >"$tmp_dir/state/battery_BAT1/supported"
printf 'true' >"$tmp_dir/state/battery_BAT1/enabled"
printf 'true' >"$tmp_dir/state/battery_BAT2/supported"
printf 'true' >"$tmp_dir/state/battery_BAT2/enabled"
devices='/org/freedesktop/UPower/devices/line_power_AC\n/org/freedesktop/UPower/devices/battery_macsmc_battery\n/org/freedesktop/UPower/devices/battery_BAT1\n/org/freedesktop/UPower/devices/battery_BAT2\n/org/freedesktop/UPower/devices/DisplayDevice\n'
run_devices() { BUSCTL_STATE_DIR="$tmp_dir/state" UPOWER_DEVICES="$devices" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-charge-limit" "$@"; }
run_devices full >/dev/null
[[ $(cat "$tmp_dir/state/battery_macsmc_battery/enabled") == "false" ]] || fail "full disables capable macsmc battery"
[[ $(cat "$tmp_dir/state/battery_BAT2/enabled") == "false" ]] || fail "full disables capable BAT2 battery"
[[ $(cat "$tmp_dir/state/battery_BAT1/enabled") == "true" ]] || fail "full skips unsupported batteries"
printf 'false' >"$tmp_dir/state/battery_BAT1/enabled"
run_devices 80 >/dev/null
[[ $(cat "$tmp_dir/state/battery_macsmc_battery/enabled") == "true" ]] || fail "80 enables capable macsmc battery"
[[ $(cat "$tmp_dir/state/battery_BAT2/enabled") == "true" ]] || fail "80 enables capable BAT2 battery"
[[ $(cat "$tmp_dir/state/battery_BAT1/enabled") == "false" ]] || fail "80 skips unsupported batteries"
shell_output=$(run_devices status --shell) || fail "charge limit discovers non-BAT batteries and survives multiple batteries" "$shell_output"
grep -Fx $'supported\ttrue' <<<"$shell_output" >/dev/null || fail "multi-battery shell output reports support" "$shell_output"
grep -Fx $'end\t80' <<<"$shell_output" >/dev/null || fail "multi-battery shell output reports threshold" "$shell_output"
pass "charge limit updates all capable batteries and skips unsupported devices"

