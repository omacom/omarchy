#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-google-pixelbook-eve"
leaf="$ROOT/install/hardware/google/fix-pixelbook-eve-backlight.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "fix-pixelbook-eve-backlight" "$ROOT"/migrations/*.sh | head -1 || true)

grep -q 'run_logged .*hardware/google/fix-pixelbook-eve-backlight.sh' "$all" ||
  fail "the Pixelbook backlight fix runs during hardware setup"
pass "the Pixelbook backlight fix runs during hardware setup"

if [[ -z $migration ]]; then
  fail "a migration applies the Pixelbook backlight fix to existing installs"
fi
pass "a migration applies the Pixelbook backlight fix to existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

# sudo records the command and captures what `tee` would write; nothing runs as root.
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
if [[ $1 == "tee" ]]; then
  cat >"$TEST_TMP/written-$(basename "$2")"
fi
if [[ $1 == "limine-mkinitcpio" ]]; then
  exit "${TEST_REBUILD_STATUS:-0}"
fi
if [[ $1 == "install" ]]; then
  touch "${@: -1}"
fi
exit 0
SH

cat >"$test_tmp/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
exit 0
SH

# Lets a case pretend Limine is missing, even on a machine that has it.
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
for cmd in "$@"; do
  if [[ $cmd == "limine-mkinitcpio" && ${TEST_LIMINE_ABSENT:-} == "1" ]]; then
    exit 1
  fi
  command -v -- "$cmd" &>/dev/null || exit 1
done
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
exit "${TEST_STATE_STATUS:-0}"
SH

chmod +x "$test_tmp/bin"/*

vendor_file="$test_tmp/sys_vendor"
product_file="$test_tmp/product_name"
call_log="$test_tmp/calls.log"

dmi() {
  printf '%s\n' "$1" >"$vendor_file"
  printf '%s\n' "$2" >"$product_file"
}

run_detector() {
  OMARCHY_DMI_SYS_VENDOR="${1-$vendor_file}" OMARCHY_DMI_PRODUCT_NAME="$product_file" bash "$detector"
}

dmi "Google" "Eve"
run_detector || fail "the detector matches the Pixelbook (Eve)"
pass "the detector matches the Pixelbook (Eve)"

dmi "Google" "Atlas"
run_detector && fail "the detector rejects another Chromebook"
pass "the detector rejects another Chromebook"

dmi "Acme" "Eve"
run_detector && fail "the detector rejects another vendor's Eve"
pass "the detector rejects another vendor's Eve"

# An exact match must not be satisfied by a name that merely contains it.
dmi "Google" "Eve Pro"
run_detector && fail "the detector rejects a longer product name"
pass "the detector rejects a longer product name"

dmi "Google" "Eve"
run_detector "$test_tmp/absent" &&
  fail "the detector fails closed when the vendor attribute is missing"
pass "the detector fails closed when the vendor attribute is missing"

# Sourced the way run_logged runs it.
run_leaf() {
  : >"$call_log"
  rm -f "$test_tmp"/written-*
  dmi "$1" "$2"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    TEST_TMP="$test_tmp" \
    OMARCHY_DMI_SYS_VENDOR="$vendor_file" \
    OMARCHY_DMI_PRODUCT_NAME="$product_file" \
    bash -eEc 'source "$1"' bash "$leaf"
}

run_leaf "Google" "Eve" || fail "the leaf writes the drop-in on the Pixelbook"
grep -qx 'KERNEL_CMDLINE\[default\]+=" i915.enable_dpcd_backlight=1"' \
  "$test_tmp/written-google-pixelbook-eve-backlight.conf" ||
  fail "the leaf writes the drop-in on the Pixelbook"
pass "the leaf writes the drop-in on the Pixelbook"

run_leaf "Google" "Atlas" || fail "the leaf no-ops on other hardware"
[[ -s $call_log ]] && fail "the leaf no-ops on other hardware"
pass "the leaf no-ops on other hardware"

# The migration runner uses bash -euo pipefail and only records the migration
# when it exits clean.
run_migration() {
  : >"$call_log"
  dmi "$1" "$2"
  printf '%s\n' "$3" >"$test_tmp/cmdline"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    TEST_TMP="$test_tmp" \
    TEST_REBUILD_STATUS="${4:-0}" \
    TEST_LIMINE_ABSENT="${5:-}" \
    TEST_STATE_STATUS="${6:-0}" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_DMI_SYS_VENDOR="$vendor_file" \
    OMARCHY_DMI_PRODUCT_NAME="$product_file" \
    OMARCHY_RUNNING_CMDLINE="$test_tmp/cmdline" \
    OMARCHY_PIXELBOOK_EVE_BACKLIGHT_MARKER="$test_tmp/marker" \
    bash -euo pipefail "$migration" >/dev/null
}

stock_cmdline="quiet splash"

rm -f "$test_tmp/marker"
run_migration "Google" "Eve" "$stock_cmdline" 1 &&
  fail "a failed rebuild leaves the migration pending, unmarked and without reboot-required"
[[ -e $test_tmp/marker ]] &&
  fail "a failed rebuild leaves the migration pending, unmarked and without reboot-required"
grep -q 'state set reboot-required' "$call_log" &&
  fail "a failed rebuild leaves the migration pending, unmarked and without reboot-required"
pass "a failed rebuild leaves the migration pending, unmarked and without reboot-required"

# If asking for the reboot fails, the rebuild must not be marked done either.
run_migration "Google" "Eve" "$stock_cmdline" 0 "" 1 &&
  fail "a failed reboot request leaves the migration pending and unmarked"
[[ -e $test_tmp/marker ]] &&
  fail "a failed reboot request leaves the migration pending and unmarked"
pass "a failed reboot request leaves the migration pending and unmarked"

# The retry after a failed rebuild must still rebuild, even though the drop-in exists now.
run_migration "Google" "Eve" "$stock_cmdline" ||
  fail "the migration writes the drop-in, rebuilds, marks and asks for a reboot"
grep -q 'sudo tee /etc/limine-entry-tool.d/google-pixelbook-eve-backlight.conf' "$call_log" &&
  grep -q 'sudo limine-mkinitcpio' "$call_log" &&
  grep -q 'state set reboot-required' "$call_log" &&
  [[ -e $test_tmp/marker ]] ||
  fail "the migration writes the drop-in, rebuilds, marks and asks for a reboot"
pass "the migration writes the drop-in, rebuilds, marks and asks for a reboot"

# A second user before the reboot: the marker stops a repeat rebuild.
run_migration "Google" "Eve" "$stock_cmdline" || fail "a second run before the reboot no-ops"
[[ -s $call_log ]] && fail "a second run before the reboot no-ops"
pass "a second run before the reboot no-ops"

rm -f "$test_tmp/marker"
run_migration "Google" "Eve" "$stock_cmdline i915.enable_dpcd_backlight=1" ||
  fail "the migration no-ops when the kernel already has the parameter"
[[ -s $call_log || -e $test_tmp/marker ]] &&
  fail "the migration no-ops when the kernel already has the parameter"
pass "the migration no-ops when the kernel already has the parameter"

# A value the user chose themselves is left alone.
run_migration "Google" "Eve" "$stock_cmdline i915.enable_dpcd_backlight=0" ||
  fail "the migration keeps a user's own backlight setting"
[[ -s $call_log || -e $test_tmp/marker ]] && fail "the migration keeps a user's own backlight setting"
pass "the migration keeps a user's own backlight setting"

# Without Limine there is no boot image to rebuild, so nothing is written.
run_migration "Google" "Eve" "$stock_cmdline" 0 1 ||
  fail "the migration no-ops without limine-mkinitcpio"
[[ -s $call_log || -e $test_tmp/marker ]] && fail "the migration no-ops without limine-mkinitcpio"
pass "the migration no-ops without limine-mkinitcpio"

run_migration "Google" "Atlas" "$stock_cmdline" || fail "the migration no-ops on other hardware"
[[ -s $call_log ]] && fail "the migration no-ops on other hardware"
pass "the migration no-ops on other hardware"
