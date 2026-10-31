#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix="$ROOT/install/hardware/apple/fix-suspend-radeon.sh"
migration="$ROOT/migrations/1791525672.sh"

grep -Fxq 'run_logged "$OMARCHY_INSTALL/hardware/apple/fix-suspend-radeon.sh"' "$ROOT/install/hardware/all.sh" ||
  fail "hardware setup runs the Radeon s2idle fix"
grep -Fq 'if [[ $product_name == MacBookPro14,3 ]]; then' "$fix" ||
  fail "the s2idle fix is limited to the tested MacBookPro14,3"
grep -Fq 'KERNEL_CMDLINE[default]+=" mem_sleep_default=s2idle button.lid_init_state=open"' "$fix" ||
  fail "the s2idle fix installs the sleep kernel parameters"
grep -Fq 'ATTR{idVendor}=="05ac", ATTR{idProduct}=="8600", ATTR{power/wakeup}="disabled"' "$fix" ||
  fail "the s2idle fix stops the T1 from waking the machine"
pass "MacBookPro14,3 setup sleeps in s2idle and ignores T1 wakes"

grep -Fq '[[ $product_name == MacBookPro14,3 ]] || exit 0' "$migration" ||
  fail "the migration is a no-op on other machines"
grep -Fq 'source "$OMARCHY_PATH/install/hardware/apple/fix-suspend-radeon.sh"' "$migration" ||
  fail "the migration applies the same setup leaf"
grep -Fq 'for param in mem_sleep_default=s2idle button.lid_init_state=open; do' "$migration" ||
  fail "the migration rebuilds the UKI only when the booted command line lacks the parameters"
pass "existing MacBookPro14,3 installs get the s2idle setup once"
