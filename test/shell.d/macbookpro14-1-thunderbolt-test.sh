#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/apple/fix-thunderbolt-suspend.sh"

bash -n "$setup" || fail "MacBookPro14,1 Thunderbolt setup has valid syntax"
bash -n "$ROOT/migrations/1788921301.sh" || fail "MacBookPro14,1 Thunderbolt migration has valid syntax"
grep -Fxq 'run_logged "$OMARCHY_INSTALL/hardware/apple/fix-thunderbolt-suspend.sh"' "$ROOT/install/hardware/all.sh" ||
  fail "MacBookPro14,1 Thunderbolt setup runs with the other hardware scripts"

# The installer is offline, so the ISO's mirror must carry what the setup adds.
packages=$(sed -n 's/^ *omarchy-pkg-add //p' "$setup")
[[ -n $packages ]] || fail "MacBookPro14,1 Thunderbolt setup adds its packages"
for package in $packages; do
  grep -Fxq "$package" "$ROOT/install/omarchy-other.packages" ||
    fail "the ISO can supply $package offline"
done

pass "MacBookPro14,1 Thunderbolt setup installs only what the offline ISO carries"
