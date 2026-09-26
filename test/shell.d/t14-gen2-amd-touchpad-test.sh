#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-thinkpad-t14-gen2-amd"
leaf="$ROOT/install/hardware/lenovo/fix-t14-gen2-amd-touchpad.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "fix-t14-gen2-amd-touchpad" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/lenovo/fix-t14-gen2-amd-touchpad.sh' "$all" ||
  fail "the T14 Gen 2a touchpad driver installs during hardware setup"
pass "the T14 Gen 2a touchpad driver installs during hardware setup"

[[ -n $migration ]] || fail "a migration installs the driver on existing installs"
pass "a migration installs the driver on existing installs"

grep -qx 'thinkpad-t14-amd-touchpad-dkms' "$ROOT/install/omarchy-other.packages" ||
  fail "the package is listed for the ISO"
pass "the package is listed for the ISO"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${TEST_PRODUCT_NAME:-} == *"$1"* ]]
SH

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALL_LOG"
exit "${TEST_PKG_ADD_STATUS:-0}"
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$test_tmp/bin"/*

call_log="$test_tmp/calls.log"

# Fake sysfs: an ACPI bus with SMB0001 and a serio bus whose touchpad port
# reports LEN2073, the shape of the real machine.
make_sysfs() {
  local acpi="$test_tmp/acpi" serio="$test_tmp/serio"
  rm -rf "$acpi" "$serio"
  mkdir -p "$acpi/${1-SMB0001:00}" "$serio/serio0" "$serio/serio1"
  printf 'PNP: LEN0071 PNP0303\n' >"$serio/serio0/firmware_id"
  printf 'PNP: %s PNP0f13\n' "${2-LEN2073}" >"$serio/serio1/firmware_id"
}

run_detector() {
  make_sysfs "${2-SMB0001:00}" "${3-LEN2073}"
  PATH="$test_tmp/bin:$PATH" \
    TEST_PRODUCT_NAME="${1-ThinkPad T14 Gen 2a}" \
    OMARCHY_ACPI_DEVICES="$test_tmp/acpi" \
    OMARCHY_SERIO_DEVICES="$test_tmp/serio" \
    bash "$detector"
}

run_detector || fail "the detector matches the T14 Gen 2a with SMB0001 and LEN2073"
pass "the detector matches the T14 Gen 2a with SMB0001 and LEN2073"

run_detector "ThinkPad P14s Gen 2a" || fail "the detector matches the P14s Gen 2a"
pass "the detector matches the P14s Gen 2a"

run_detector "ThinkPad T14 Gen 2" && fail "the detector rejects the Intel T14 Gen 2"
pass "the detector rejects the Intel T14 Gen 2"

run_detector "ThinkPad T14 Gen 2a" "SMB0002:00" &&
  fail "the detector rejects a machine without the SMB0001 ACPI node"
pass "the detector rejects a machine without the SMB0001 ACPI node"

run_detector "ThinkPad T14 Gen 2a" "SMB0001:00" "LEN0411" &&
  fail "the detector rejects another touchpad"
pass "the detector rejects another touchpad"

# Sourced the way run_logged runs it.
run_leaf() {
  : >"$call_log"
  make_sysfs
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    TEST_PRODUCT_NAME="${1-ThinkPad T14 Gen 2a}" \
    TEST_PKG_ADD_STATUS="${2:-0}" \
    OMARCHY_ACPI_DEVICES="$test_tmp/acpi" \
    OMARCHY_SERIO_DEVICES="$test_tmp/serio" \
    bash -c 'source "$1"' bash "$leaf"
}

run_leaf || fail "the leaf installs the package on the target machine"
grep -q 'pkg-add thinkpad-t14-amd-touchpad-dkms' "$call_log" ||
  fail "the leaf installs the package on the target machine"
pass "the leaf installs the package on the target machine"

run_leaf "ThinkPad X1" || fail "the leaf no-ops on other hardware"
[[ -s $call_log ]] && fail "the leaf no-ops on other hardware"
pass "the leaf no-ops on other hardware"

run_leaf "ThinkPad T14 Gen 2a" 1 && fail "a failing package install fails the leaf"
pass "a failing package install fails the leaf"

# The migration runner uses bash -euo pipefail and only records the migration
# when it exits clean, so a failed install has to leave reboot-required unset.
run_migration() {
  : >"$call_log"
  make_sysfs
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    TEST_PRODUCT_NAME="${1-ThinkPad T14 Gen 2a}" \
    TEST_PKG_ADD_STATUS="${2:-0}" \
    OMARCHY_ACPI_DEVICES="$test_tmp/acpi" \
    OMARCHY_SERIO_DEVICES="$test_tmp/serio" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration || fail "the migration installs the driver and asks for a reboot"
grep -q 'state set reboot-required' "$call_log" ||
  fail "the migration installs the driver and asks for a reboot"
pass "the migration installs the driver and asks for a reboot"

run_migration "ThinkPad T14 Gen 2a" 1 && fail "a failing install leaves the migration pending"
grep -q 'state set reboot-required' "$call_log" &&
  fail "a failing install does not mark reboot-required"
pass "a failing install leaves the migration pending without marking reboot-required"

run_migration "ThinkPad X1" || fail "the migration no-ops on other hardware"
[[ -s $call_log ]] && fail "the migration no-ops on other hardware"
pass "the migration no-ops on other hardware"
