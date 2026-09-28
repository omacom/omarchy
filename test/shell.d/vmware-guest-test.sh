#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/vmware.sh"
all="$ROOT/install/hardware/all.sh"
packages="$ROOT/install/omarchy-other.packages"

grep -q 'run_logged .*hardware/vmware.sh' "$all" ||
  fail "the VMware guest tools install during hardware setup"
pass "the VMware guest tools install during hardware setup"

# The ISO builder reads this list, so an offline install has the package.
grep -qx 'open-vm-tools' "$packages" ||
  fail "the ISO carries open-vm-tools for offline installs"
pass "the ISO carries open-vm-tools for offline installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/state"

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALL_LOG"
exit "${TEST_PKG_ADD_STATUS:-0}"
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
if [[ $1 == "is-enabled" ]]; then
  [[ ${TEST_UNIT_ENABLED:-0} == "1" ]]
  exit
fi
printf 'systemctl %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$test_tmp/bin"/*

call_log="$test_tmp/calls.log"

# Each argument is a PCI device as "vendor:device:class", in sysfs's own format.
write_pci_devices() {
  rm -rf "$test_tmp/devices"
  mkdir -p "$test_tmp/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$test_tmp/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$test_tmp/devices/$slot/vendor"
    printf '%s\n' "$(cut -d: -f2 <<<"$spec")" >"$test_tmp/devices/$slot/device"
    printf '%s\n' "${spec##*:}" >"$test_tmp/devices/$slot/class"
    index=$((index + 1))
  done
}

# VMware SVGA II adapter, the device every VMware guest has.
vmware_guest() {
  write_pci_devices 0x15ad:0x0405:0x030000 0x15ad:0x07b0:0x020000
}

# AMD Cezanne integrated graphics.
amd_laptop() {
  write_pci_devices 0x1002:0x15e7:0x030000
}

# Sourced the way run_logged runs it; the real detector from $ROOT/bin runs
# against the fake sysfs.
run_leaf() {
  : >"$call_log"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    TEST_PKG_ADD_STATUS="${1:-0}" \
    TEST_UNIT_ENABLED="${TEST_UNIT_ENABLED:-0}" \
    OMARCHY_PCI_DEVICES_PATH="$test_tmp/devices" \
    bash -eE -c 'source "$1"' bash "$leaf"
}

vmware_guest
run_leaf || fail "the leaf installs and enables the guest tools on a VMware guest"
expected=$'pkg-add open-vm-tools\nsystemctl enable vmtoolsd.service vmware-vmblock-fuse.service'
[[ $(<"$call_log") == "$expected" ]] ||
  fail "the leaf installs and enables the guest tools on a VMware guest" "$(<"$call_log")"
pass "the leaf installs and enables the guest tools on a VMware guest"

amd_laptop
run_leaf || fail "the leaf no-ops on other hardware"
[[ -s $call_log ]] && fail "the leaf no-ops on other hardware" "$(<"$call_log")"
pass "the leaf no-ops on other hardware"

vmware_guest
run_leaf 1 && fail "a failing package install fails the leaf"
grep -q '^systemctl' "$call_log" && fail "a failing package install skips enabling the units"
pass "a failing package install fails the leaf without enabling the units"

# The migration runner uses bash -euo pipefail and only records the migration
# when it exits clean, so a failed install has to leave the marker unset.
migration="$ROOT/migrations/1789452465.sh"
[[ -f $migration ]] || fail "a migration installs the guest tools on existing installs"
pass "a migration installs the guest tools on existing installs"

marker="$test_tmp/state/marker"

run_migration() {
  : >"$call_log"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    TEST_PKG_ADD_STATUS="${1:-0}" \
    TEST_UNIT_ENABLED="${TEST_UNIT_ENABLED:-0}" \
    OMARCHY_PCI_DEVICES_PATH="$test_tmp/devices" \
    OMARCHY_VMWARE_TOOLS_MARKER="$marker" \
    bash -euo pipefail "$migration" >/dev/null
}

vmware_guest
run_migration || fail "the migration installs, enables, and starts the guest tools"
expected=$'pkg-add open-vm-tools\nsystemctl enable vmtoolsd.service vmware-vmblock-fuse.service\nsystemctl start vmtoolsd.service\nsystemctl start vmware-vmblock-fuse.service'
[[ $(<"$call_log") == "$expected" ]] ||
  fail "the migration installs, enables, and starts the guest tools" "$(<"$call_log")"
[[ -e $marker ]] || fail "the migration records machine-wide completion"
pass "the migration installs, enables, and starts the guest tools"

run_migration || fail "the migration no-ops once the marker exists"
[[ -s $call_log ]] && fail "the migration no-ops once the marker exists" "$(<"$call_log")"
pass "the migration no-ops once the marker exists"

rm -f "$marker"
TEST_UNIT_ENABLED=1 run_migration || fail "the migration no-ops when the unit is already enabled"
[[ -s $call_log || -e $marker ]] && fail "an installer-provisioned guest is left alone without sudo" "$(<"$call_log")"
pass "an installer-provisioned guest is left alone without sudo"

rm -f "$marker"
amd_laptop
run_migration || fail "the migration no-ops on other hardware"
[[ -s $call_log ]] && fail "the migration no-ops on other hardware" "$(<"$call_log")"
[[ -e $marker ]] && fail "the migration leaves no marker on other hardware"
pass "the migration no-ops on other hardware"

rm -f "$marker"
vmware_guest
run_migration 1 && fail "a failing package install leaves the migration pending"
grep -q '^systemctl' "$call_log" && fail "a failing package install skips the units"
[[ -e $marker ]] && fail "a failing package install leaves no marker"
pass "a failing package install leaves the migration pending without a marker"
