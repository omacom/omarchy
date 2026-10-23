#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export OMARCHY_POWER_SUPPLY_PATH="$fixture/power"
export OMARCHY_PLATFORM_DRIVERS_PATH="$fixture/drivers"
getter="$ROOT/bin/omarchy-battery-limit-get"
mkdir -p "$fixture/power/BAT0" "$fixture/drivers/lg-laptop" "$fixture/device"
printf '100\n' > "$fixture/power/BAT0/charge_control_end_threshold"
[[ $("$getter" --options) == "80 90 100" ]] || fail "unknown driver keeps usual presets"
# A registered driver alone is not proof of a bound device with charge control.
ln -s "$fixture/device" "$fixture/drivers/lg-laptop/lg-laptop"
[[ $("$getter" --options) == "80 90 100" ]] || fail "LG without charge control keeps usual presets"
printf '100\n' > "$fixture/device/battery_care_limit"
[[ $("$getter" --options) == "80 100" ]] || fail "bound LG control excludes 90"
[[ $("$getter") == "100" ]] || fail "options do not change readback or hardware"
pass "LG presets require a bound driver with its charge control"

mkdir -p "$fixture/power/other-battery"
printf '80\n' > "$fixture/power/other-battery/charge_control_end_threshold"
[[ $("$getter" --options) == "80 100" ]] || fail "multi-battery picker respects LG restriction"
[[ $("$getter") == "mixed" ]] || fail "mixed limits remain visible"
printf 'Device\n' > "$fixture/power/other-battery/scope"
[[ $("$getter") == "100" ]] || fail "peripheral ignored"
pass "multiple batteries and mixed readings retain the common presets"

printf 'invalid\n' > "$fixture/power/BAT0/charge_control_end_threshold"
if "$getter" --options; then fail "invalid readings must not advertise presets"; fi
rm -r "$fixture/power/BAT0"
if "$getter" --options; then fail "peripherals alone must not advertise presets"; fi
if "$getter" --unknown; then fail "invalid option must fail"; fi
pass "unavailable hardware and invalid arguments fail closed"
