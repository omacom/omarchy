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
sleep_dir="$test_tmp/system-sleep"
sleep_hook="$sleep_dir/camera-sleep-hook"

cat >"$test_tmp/bin/omarchy-hw-intel-ipu6" <<'SH'
#!/bin/bash
[[ ${TEST_HAS_IPU6:-yes} == yes ]]
SH

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

# INSTALLED lists installed packages; HOOK_OWNED=yes makes the sleep hook owned.
cat >"$test_tmp/bin/pacman" <<'SH'
#!/bin/bash
case "$1" in
  -Q) grep -qx "$2" <<<"${INSTALLED:-}" ;;
  -Qo) [[ ${HOOK_OWNED:-no} == yes ]] ;;
  *) printf 'pacman %s\n' "$*" >>"$CALL_LOG" ;;
esac
SH

chmod +x "$test_tmp/bin"/*

ipu7_hook() {
  mkdir -p "$sleep_dir"
  printf '#!/bin/bash\nsystemctl stop v4l2-relayd@ipu7.service\n' >"$sleep_hook"
}

run_leaf() {
  : >"$call_log"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_SYSTEM_SLEEP_PATH="$sleep_dir" \
    TEST_HAS_IPU6="${1-yes}" \
    bash -euo pipefail -c 'source "$1"' bash "$leaf"
}

run_leaf || fail "the leaf sets up the camera on IPU6 hardware"
grep -q 'pkg-add libcamera pipewire-libcamera gst-plugin-libcamera' "$call_log" ||
  fail "the leaf installs the libcamera stack"
grep -q '^pacman -R' "$call_log" && fail "a machine without the IPU7 stack removes nothing" "$(<"$call_log")"
grep -q '^state ' "$call_log" && fail "a machine without the IPU7 stack asks for no reboot" "$(<"$call_log")"
pass "the leaf sets up the camera on IPU6 hardware"

# Meteor Lake with ov08x40, where the IPU7 leaf installed its stack (#7697).
ipu7_hook
INSTALLED=intel-ipu7-camera run_leaf || fail "the leaf replaces the IPU7 stack on IPU6 hardware"
[[ $(sed -n 1p "$call_log") == 'pacman -R --noconfirm intel-ipu7-camera' ]] ||
  fail "the IPU7 stack is removed with a plain -R before libcamera is installed" "$(<"$call_log")"
grep -qx 'state set reboot-required' "$call_log" ||
  fail "removing the IPU7 stack asks for a reboot" "$(<"$call_log")"
[[ ! -e $sleep_hook ]] || fail "the IPU7 sleep hook is removed"
grep -q 'pkg-add libcamera' "$call_log" || fail "libcamera is still installed after the IPU7 stack goes"
pass "the IPU7 stack is replaced by libcamera on IPU6 hardware"

# Already removed by hand with an older package, which left its hook behind.
ipu7_hook
run_leaf || fail "a leftover IPU7 sleep hook is cleaned up"
[[ ! -e $sleep_hook ]] || fail "a leftover IPU7 sleep hook is cleaned up"
pass "a leftover IPU7 sleep hook is cleaned up"

ipu7_hook
HOOK_OWNED=yes run_leaf || fail "a packaged sleep hook is left alone"
[[ -e $sleep_hook ]] || fail "a packaged sleep hook is left alone"
pass "a packaged sleep hook is left alone"

printf '#!/bin/bash\nexit 0\n' >"$sleep_hook"
run_leaf || fail "an unrelated camera-sleep-hook is left alone"
[[ -e $sleep_hook ]] || fail "an unrelated camera-sleep-hook is left alone"
pass "an unrelated camera-sleep-hook is left alone"

# Panther Lake binds intel-ipu7, so the stack it needs stays.
ipu7_hook
INSTALLED=intel-ipu7-camera run_leaf no || fail "the leaf no-ops on other hardware"
[[ -s $call_log ]] && fail "the leaf no-ops on other hardware" "$(<"$call_log")"
[[ -e $sleep_hook ]] || fail "the IPU7 sleep hook stays on IPU7 hardware"
pass "the leaf no-ops on other hardware, IPU7 stack included"
