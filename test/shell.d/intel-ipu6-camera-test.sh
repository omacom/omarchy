#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-intel-ipu6"
leaf="$ROOT/install/hardware/intel/ipu6-camera.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "ipu6-camera" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/intel/ipu6-camera.sh' "$all" ||
  fail "IPU6 camera support is set up during hardware setup"
pass "IPU6 camera support is set up during hardware setup"

[[ -n $migration ]] || fail "a migration sets it up on existing installs"
pass "a migration sets it up on existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

# --- detector ----------------------------------------------------------------

pci="$test_tmp/pci"

make_pci_device() {
  local slot="$1" driver="${2-}"

  mkdir -p "$pci/$slot"
  [[ -n $driver ]] || return 0
  ln -sfn "../../../bus/pci/drivers/$driver" "$pci/$slot/driver"
}

rm -rf "$pci" && make_pci_device 0000:00:02.0 i915 && make_pci_device 0000:00:05.0 intel-ipu6
OMARCHY_PCI_DEVICES_PATH="$pci" bash "$detector" ||
  fail "the detector matches a controller bound to intel-ipu6"
pass "the detector matches a controller bound to intel-ipu6"

rm -rf "$pci" && make_pci_device 0000:00:05.0 intel-ipu7
OMARCHY_PCI_DEVICES_PATH="$pci" bash "$detector" &&
  fail "the detector rejects a controller bound to another driver"
pass "the detector rejects a controller bound to another driver"

# A machine whose kernel has no IPU6 driver still has the PCI device, and
# libcamera has nothing to work with there.
rm -rf "$pci" && make_pci_device 0000:00:05.0
OMARCHY_PCI_DEVICES_PATH="$pci" bash "$detector" &&
  fail "the detector rejects an unbound controller"
pass "the detector rejects an unbound controller"

rm -rf "$pci" && mkdir -p "$pci"
OMARCHY_PCI_DEVICES_PATH="$pci" bash "$detector" &&
  fail "the detector rejects a machine with no camera controller"
pass "the detector rejects a machine with no camera controller"

# --- install leaf ------------------------------------------------------------

call_log="$test_tmp/calls.log"

cat >"$test_tmp/bin/omarchy-hw-intel-ipu6" <<'SH'
#!/bin/bash
[[ ${TEST_HAS_IPU6:-yes} == yes ]]
SH

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$test_tmp/bin"/*

run_leaf() {
  : >"$call_log"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    TEST_HAS_IPU6="${1-yes}" \
    bash -c 'source "$1"' bash "$leaf"
}

run_leaf || fail "the leaf sets up the camera on IPU6 hardware"
grep -q 'pkg-add libcamera pipewire-libcamera gst-plugin-libcamera' "$call_log" ||
  fail "the leaf installs the libcamera stack"
pass "the leaf sets up the camera on IPU6 hardware"

run_leaf no || fail "the leaf no-ops on other hardware"
[[ -s $call_log ]] && fail "the leaf no-ops on other hardware"
pass "the leaf no-ops on other hardware"
