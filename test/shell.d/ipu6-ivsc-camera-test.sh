#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-intel-ivsc"
leaf="$ROOT/install/hardware/intel/ipu6-ivsc-camera.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "ipu6-ivsc-camera" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/intel/ipu6-ivsc-camera.sh' "$all" ||
  fail "the IVSC load order fix runs during hardware setup"
pass "the IVSC load order fix runs during hardware setup"

[[ -n $migration ]] || fail "a migration applies the fix on existing installs"
pass "a migration applies the fix on existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/root"

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

# install(1) with the destination rooted in the sandbox.
cat >"$test_tmp/bin/install" <<'SH'
#!/bin/bash
args=("${@:1:$#-1}")
exec /usr/bin/install "${args[@]}" "$TEST_ROOT${*: -1}"
SH

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALL_LOG"
exit "${TEST_PKG_ADD_STATUS:-0}"
SH

cat >"$test_tmp/bin/pacman" <<'SH'
#!/bin/bash
[[ $1 == -Qqs ]] && printf 'linux\n'
SH

cat >"$test_tmp/bin/setfacl" <<'SH'
#!/bin/bash
printf 'setfacl %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$test_tmp/bin/udevadm" <<'SH'
#!/bin/bash
printf 'udevadm %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$test_tmp/bin"/*

# A sysfs ACPI tree with the given HIDs.
acpi_tree() {
  local dir="$test_tmp/acpi-$RANDOM"
  local i=0
  mkdir -p "$dir"
  for hid in "$@"; do
    mkdir -p "$dir/$hid:0$i"
    printf '%s\n' "$hid" >"$dir/$hid:0$i/hid"
    ((i++)) || true
  done
  printf '%s\n' "$dir"
}

run_detector() {
  OMARCHY_ACPI_DEVICES="$1" bash "$detector"
}

for hid in INTC1059 INTC1095 INTC100A INTC10CF; do
  run_detector "$(acpi_tree PNP0C0F "$hid" OVTI01A0)" ||
    fail "the detector matches a MEI based IVSC ($hid)"
done
pass "the detector matches every MEI based IVSC"

run_detector "$(acpi_tree PNP0C0F OVTI08F4 INTC10E1)" &&
  fail "the detector rejects a CVS based camera (Lunar/Panther Lake)"
pass "the detector rejects a CVS based camera"

run_detector "$(acpi_tree PNP0C0F)" && fail "the detector rejects a laptop without an IVSC"
pass "the detector rejects a laptop without an IVSC"

run_detector "$test_tmp/absent" && fail "the detector fails closed without an ACPI tree"
pass "the detector fails closed without an ACPI tree"

call_log="$test_tmp/calls.log"

# Sourced the way run_logged runs it.
run_leaf() {
  : >"$call_log"
  rm -rf "$test_tmp/root"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    TEST_ROOT="$test_tmp/root" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_ACPI_DEVICES="$1" \
    bash -eE -c 'source "$1"' bash "$leaf"
}

run_leaf "$(acpi_tree INTC1095)" || fail "the leaf installs the load order fix on an IVSC laptop"
rules="$test_tmp/root/etc/udev/rules.d/90-intel-ipu6-ivsc.rules"
conf="$test_tmp/root/etc/modprobe.d/intel-ipu6-ivsc.conf"
[[ -f $rules && -f $conf ]] || fail "the leaf installs the udev rule and the modprobe blacklist"
grep -q '^blacklist intel_ipu6$' "$conf" || fail "the modprobe config blacklists intel_ipu6"
grep -q 'SUBSYSTEM=="mei".*intel_vsc-92335fcf.*modprobe.*intel_ipu6' "$rules" ||
  fail "the udev rule loads intel_ipu6 on the IVSC CSI client"
pass "the leaf installs the udev rule and the modprobe blacklist"

grep -q '^pkg-add .*v4l2loopback-dkms v4l2loopback-utils v4l2-relayd libcamera gst-plugin-libcamera frei0r-plugins$' "$call_log" ||
  fail "the leaf installs the relay stack"
grep -q '^pkg-add linux-headers ' "$call_log" ||
  fail "the leaf installs the headers for the kernels found by the stubbed pacman"
pass "the leaf installs the relay stack and matching kernel headers"

for path in etc/udev/rules.d/71-intel-ipu6-isys.rules etc/v4l2-relayd.d/ipu6.conf \
  etc/systemd/system/ipu6-loopback.service etc/systemd/system/v4l2-relayd@ipu6.service.d/ipu6.conf \
  etc/modprobe.d/v4l2loopback-exclusive-caps.conf usr/share/libcamera/ipa/simple/ov01a10.yaml; do
  [[ -f $test_tmp/root/$path ]] || fail "the leaf installs $path"
done
grep -A1 'ISYS Capture \*"' "$test_tmp/root/etc/udev/rules.d/71-intel-ipu6-isys.rules" | grep -q 'TAG-="uaccess".*MODE="0600"' ||
  fail "the raw ISYS nodes are hidden from users"
grep -q 'SYSTEMD_WANTS}="v4l2-relayd@ipu6.service"' "$test_tmp/root/etc/udev/rules.d/71-intel-ipu6-isys.rules" ||
  fail "the relay starts when the IPU6 registers its capture nodes"
grep -q '^VIDEOSRC="libcamerasrc.*frei0r-filter-hqdn3d' "$test_tmp/root/etc/v4l2-relayd.d/ipu6.conf" ||
  fail "the relay reads the camera through libcamera and denoises it"
grep -q 'LIBCAMERA_PIPELINES_MATCH_LIST=simple' "$test_tmp/root/etc/systemd/system/v4l2-relayd@ipu6.service.d/ipu6.conf" ||
  fail "the relay only enumerates the IPU6 pipeline"
pass "the leaf installs the relay, its loopback device and hides the raw nodes"

# Pacman failures must surface rather than leave a half-applied fix behind.
TEST_PKG_ADD_STATUS=1 run_leaf "$(acpi_tree INTC1095)" && fail "a failing package install fails the leaf"
[[ -e $rules ]] && fail "a failing package install skips the udev rule"
pass "a failing package install fails the leaf without installing the rule"

run_leaf "$(acpi_tree PNP0C0F)" || fail "the leaf no-ops on other hardware"
[[ -e $test_tmp/root ]] && fail "the leaf no-ops on other hardware"
pass "the leaf no-ops on other hardware"

run_migration() {
  : >"$call_log"
  rm -rf "$test_tmp/root"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    TEST_ROOT="$test_tmp/root" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_ACPI_DEVICES="$1" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration "$(acpi_tree INTC1095)" || fail "the migration applies the fix and asks for a reboot"
[[ -f $rules ]] || fail "the migration installs the udev rule"
grep -q 'udevadm control --reload' "$call_log" || fail "the migration reloads udev"
grep -q 'systemctl daemon-reload' "$call_log" || fail "the migration reloads systemd"
grep -q 'udevadm trigger --action=add --subsystem-match=video4linux' "$call_log" ||
  fail "the migration re-triggers the video nodes so the relay starts now"
grep -q 'state set reboot-required' "$call_log" || fail "the migration asks for a reboot"
pass "the migration applies the fix and asks for a reboot"

run_migration "$(acpi_tree PNP0C0F)" || fail "the migration no-ops on other hardware"
[[ -s $call_log ]] && fail "the migration no-ops on other hardware"
pass "the migration no-ops on other hardware"
