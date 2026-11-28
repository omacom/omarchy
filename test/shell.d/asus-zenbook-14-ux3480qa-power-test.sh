#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-hw-aarch64-qualcomm" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${1:-} == "UX3480QA" ]]
SH
cat >"$mock_bin/udevadm" <<'SH'
#!/bin/bash
printf "%s\n" "$*" >>"$TEST_UDEVADM_LOG"
SH
cat >"$mock_bin/systemd-detect-virt" <<'SH'
#!/bin/bash
[[ ${TEST_IN_CHROOT:-0} == 1 ]]
SH
chmod +x "$mock_bin"/*

sysfs="$test_tmp/sysfs"
mkdir -p "$sysfs/drivers/dwc3-qcom" "$sysfs/drivers/xhci-hcd" "$sysfs/drivers/qcom-qmp-combo-phy" \
  "$sysfs/soc0/a200000.usb/xhci-hcd.1.auto" "$sysfs/soc0/a600000.usb/xhci-hcd.3.auto" \
  "$sysfs/soc0/fd5000.phy" "$sysfs/platform/devices"
ln -s "$sysfs/drivers/dwc3-qcom" "$sysfs/soc0/a200000.usb/driver"
ln -s "$sysfs/drivers/xhci-hcd" "$sysfs/soc0/a200000.usb/xhci-hcd.1.auto/driver"
ln -s "$sysfs/drivers/dwc3-qcom" "$sysfs/soc0/a600000.usb/driver"
ln -s "$sysfs/drivers/xhci-hcd" "$sysfs/soc0/a600000.usb/xhci-hcd.3.auto/driver"
ln -s "$sysfs/drivers/qcom-qmp-combo-phy" "$sysfs/soc0/fd5000.phy/driver"
ln -s "$sysfs/soc0/a200000.usb" "$sysfs/platform/devices/a200000.usb"
ln -s "$sysfs/soc0/a200000.usb/xhci-hcd.1.auto" "$sysfs/platform/devices/xhci-hcd.1.auto"
ln -s "$sysfs/soc0/a600000.usb" "$sysfs/platform/devices/a600000.usb"
ln -s "$sysfs/soc0/a600000.usb/xhci-hcd.3.auto" "$sysfs/platform/devices/xhci-hcd.3.auto"
ln -s "$sysfs/soc0/fd5000.phy" "$sysfs/platform/devices/fd5000.phy"

run_udev="$test_tmp/run-udev"
mkdir -p "$run_udev"

# 1. Install chroot skips live udev reload and trigger even when /run/udev exists.
chroot_nm="$test_tmp/chroot-nm"
chroot_udev="$test_tmp/chroot-udev"
chroot_log="$test_tmp/chroot-udevadm.log"
: >"$chroot_log"
PATH="$mock_bin:$ROOT/bin:$PATH" \
  TEST_IN_CHROOT=1 TEST_UDEVADM_LOG="$chroot_log" \
  OMARCHY_ZENBOOK_UX3480QA_NM_CONF_DIR="$chroot_nm" \
  OMARCHY_ZENBOOK_UX3480QA_UDEV_RULES_DIR="$chroot_udev" \
  OMARCHY_ZENBOOK_UX3480QA_RUN_UDEV_DIR="$run_udev" \
  OMARCHY_ZENBOOK_UX3480QA_PLATFORM_DEVICES_DIR="$sysfs/platform/devices" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/asus/fix-asus-zenbook-14-ux3480qa-power.sh"
[[ ! -s $chroot_log ]] || fail "chroot install must skip live udevadm calls" "$(cat "$chroot_log")"
pass "chroot install writes rules without calling udevadm"

# 2. Live booted system reloads udev and triggers only a200000.usb and its xhci-hcd child.
live_nm="$test_tmp/live-nm"
live_udev="$test_tmp/live-udev"
live_log="$test_tmp/live-udevadm.log"
: >"$live_log"
PATH="$mock_bin:$ROOT/bin:$PATH" \
  TEST_IN_CHROOT=0 TEST_UDEVADM_LOG="$live_log" \
  OMARCHY_ZENBOOK_UX3480QA_NM_CONF_DIR="$live_nm" \
  OMARCHY_ZENBOOK_UX3480QA_UDEV_RULES_DIR="$live_udev" \
  OMARCHY_ZENBOOK_UX3480QA_RUN_UDEV_DIR="$run_udev" \
  OMARCHY_ZENBOOK_UX3480QA_PLATFORM_DEVICES_DIR="$sysfs/platform/devices" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/asus/fix-asus-zenbook-14-ux3480qa-power.sh"
grep -qxF "control --reload" "$live_log" || fail "live run must reload udev" "$(cat "$live_log")"
grep -qxF "trigger --action=change --sysname-match=a200000.usb --subsystem-match=platform" "$live_log" ||
  fail "live run must trigger a200000.usb" "$(cat "$live_log")"
grep -qxF "trigger --action=change --sysname-match=xhci-hcd.1.auto --subsystem-match=platform" "$live_log" ||
  fail "live run must trigger a200000.usb xhci-hcd child" "$(cat "$live_log")"
! grep -qE "a600000\.usb|xhci-hcd\.3\.auto|fd5000\.phy" "$live_log" ||
  fail "live run must not trigger external USB3 controllers or QMP PHYs" "$(cat "$live_log")"
pass "live run reloads udev and triggers only internal a200000.usb and its xhci-hcd child"
