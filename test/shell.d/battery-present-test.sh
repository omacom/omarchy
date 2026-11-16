#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/macsmc-ac" "$test_tmp/CMB0"
printf 'Mains\n' >"$test_tmp/macsmc-ac/type"
printf 'Battery\n' >"$test_tmp/CMB0/type"
printf '1\n' >"$test_tmp/CMB0/present"

OMARCHY_POWER_SUPPLY_PATH="$test_tmp" "$ROOT/bin/omarchy-battery-present" || fail "battery presence accepts non-BAT native paths"
pass "battery presence accepts non-BAT native paths"

printf '0\n' >"$test_tmp/CMB0/present"
if OMARCHY_POWER_SUPPLY_PATH="$test_tmp" "$ROOT/bin/omarchy-battery-present"; then
  fail "battery presence rejects an absent battery"
fi
pass "battery presence rejects an absent battery"

# A wireless mouse registers a Battery of its own, scoped Device; it must not
# make a desktop look like a laptop.
printf '1\n' >"$test_tmp/CMB0/present"
printf 'System\n' >"$test_tmp/CMB0/scope"
mkdir -p "$test_tmp/hidpp_battery_0"
printf 'Battery\n' >"$test_tmp/hidpp_battery_0/type"
printf '1\n' >"$test_tmp/hidpp_battery_0/present"
printf 'Device\n' >"$test_tmp/hidpp_battery_0/scope"
OMARCHY_POWER_SUPPLY_PATH="$test_tmp" "$ROOT/bin/omarchy-battery-present" || fail "battery presence accepts a System-scoped battery beside a peripheral"
pass "battery presence accepts a System-scoped battery beside a peripheral"

rm -r "$test_tmp/CMB0"
if OMARCHY_POWER_SUPPLY_PATH="$test_tmp" "$ROOT/bin/omarchy-battery-present"; then
  fail "battery presence ignores a peripheral's Device-scoped battery"
fi
pass "battery presence ignores a peripheral's Device-scoped battery"
