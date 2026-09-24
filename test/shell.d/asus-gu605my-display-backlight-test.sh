#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/asus/fix-asus-gu605my-display-backlight.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "fix-asus-gu605my-display-backlight" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/asus/fix-asus-gu605my-display-backlight.sh' "$all" ||
  fail "the backlight fix runs during hardware setup"
pass "the backlight fix runs during hardware setup"

[[ -n $migration ]] || fail "a migration applies the fix on existing installs"
pass "a migration applies the fix on existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${TEST_PRODUCT_NAME:-} == *"$1"* ]]
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$test_tmp/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio\n' >>"$CALL_LOG"
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$test_tmp/bin"/*

conf="$test_tmp/limine-entry-tool.d/asus-gu605my-display-backlight.conf"
call_log="$test_tmp/calls.log"

# Sourced the way run_logged runs it.
run_leaf() {
  rm -rf "${conf%/*}"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    TEST_PRODUCT_NAME="$1" \
    OMARCHY_GU605MY_BACKLIGHT_CONF="$conf" \
    bash -c 'source "$1"' bash "$leaf"
}

run_leaf "ROG Zephyrus G16 GU605MY_GU605MY" || fail "the leaf writes the kernel option on the GU605MY"
grep -qx 'KERNEL_CMDLINE\[default\]+=" i915.enable_dpcd_backlight=3"' "$conf" ||
  fail "the leaf writes the kernel option on the GU605MY"
pass "the leaf writes the kernel option on the GU605MY"

run_leaf "ROG Zephyrus G16 GU605MV_GU605MV" || fail "the leaf no-ops on other GU605 variants"
[[ -e $conf ]] && fail "the leaf no-ops on other GU605 variants"
pass "the leaf no-ops on other GU605 variants"

run_migration() {
  : >"$call_log"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    TEST_PRODUCT_NAME="$1" \
    OMARCHY_GU605MY_BACKLIGHT_CONF="$conf" \
    bash -euo pipefail "$migration" >/dev/null
}

rm -rf "${conf%/*}"
run_migration "ROG Zephyrus G16 GU605MY_GU605MY" || fail "the migration applies the fix and asks for a reboot"
[[ -f $conf ]] || fail "the migration writes the kernel option"
grep -q '^limine-mkinitcpio$' "$call_log" || fail "the migration rebuilds the boot image"
grep -q 'state set reboot-required' "$call_log" || fail "the migration asks for a reboot"
pass "the migration applies the fix and asks for a reboot"

run_migration "ROG Zephyrus G16 GU605MY_GU605MY" || fail "the migration no-ops when the fix is already present"
[[ -s $call_log ]] && fail "the migration no-ops when the fix is already present"
pass "the migration no-ops when the fix is already present"

rm -rf "${conf%/*}"
run_migration "ROG Zephyrus G14 GA403UV" || fail "the migration no-ops on other hardware"
[[ -s $call_log || -e $conf ]] && fail "the migration no-ops on other hardware"
pass "the migration no-ops on other hardware"
