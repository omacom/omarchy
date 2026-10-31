#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

match="$ROOT/bin/omarchy-hw-match-device-tree"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

bash -n "$match" || fail "hw-match-device-tree has valid syntax"

# Root reads only the live device tree, as omarchy-hw-platform does.
if (( EUID != 0 )) && unshare --user --map-root-user true 2>/dev/null; then
  mkdir -p "$test_tmp/root/proc/device-tree"
  printf '%s\0' omarchy,no-such-board >"$test_tmp/root/proc/device-tree/compatible"
  if OMARCHY_PROC_ROOT="$test_tmp/root/proc" unshare --user --map-root-user "$match" omarchy,no-such-board; then
    fail "root ignores a fixture device tree in its environment"
  fi
  pass "root ignores a fixture device tree in its environment"
else
  skip "no unprivileged user namespace; skipping the root override probe"
fi

require_platform_fixtures "device tree matching"

# The Surface Pro 11 models share a DMI name and differ in their first string.
surface="$test_tmp/surface"
mkdir -p "$surface/proc/device-tree"
printf '%s\0' microsoft,denali-oled microsoft,denali qcom,x1e80100 >"$surface/proc/device-tree/compatible"

on_surface() {
  OMARCHY_PROC_ROOT="$surface/proc" "$match" "$@"
}

on_surface microsoft,denali-oled || fail "hw-match-device-tree finds the first compatible string"
on_surface qcom,x1e80100 || fail "hw-match-device-tree finds a later compatible string"
on_surface MICROSOFT,Denali-OLED || fail "hw-match-device-tree ignores case"
on_surface asus,zenbook-a16-ux3607oa microsoft,denali-oled || fail "hw-match-device-tree accepts any of several strings"
pass "hw-match-device-tree finds a compatible string"

# A Turkish locale lowercases I to a dotless i, which matches nothing.
turkish=$(locale -a 2>/dev/null | grep -i -m1 -E '^tr_TR\.utf-?8$' || true)
if [[ -n $turkish ]]; then
  LC_ALL=$turkish on_surface MICROSOFT,DENALI-OLED ||
    fail "hw-match-device-tree ignores case in a Turkish locale"
  pass "hw-match-device-tree ignores case in a Turkish locale"
else
  skip "no Turkish locale installed; skipping the locale probe"
fi

for other in microsoft,denali-lcd microsoft,denali-ole denali-oled 'microsoft,denali.oled' 'microsoft,*' ''; do
  if on_surface "$other"; then
    fail "hw-match-device-tree matches whole strings only" "matched: '$other'"
  fi
done
if on_surface; then
  fail "hw-match-device-tree matches nothing without a string"
fi
if on_surface --help; then
  fail "hw-match-device-tree treats an option-shaped string literally"
fi
pass "hw-match-device-tree matches whole strings only"

# The sysfs path serves when only that fixture root is named, and a fixture
# without a device tree (an ACPI machine) never falls back to the live one.
sysfs="$test_tmp/sysfs"
mkdir -p "$sysfs/sys/firmware/devicetree/base" "$test_tmp/acpi/proc"
printf '%s\0' asus,zenbook-a16-ux3607oa qcom,glymur >"$sysfs/sys/firmware/devicetree/base/compatible"
OMARCHY_SYS_ROOT="$sysfs/sys" "$match" asus,zenbook-a16-ux3607oa ||
  fail "hw-match-device-tree reads the sysfs device tree fixture"
OMARCHY_PROC_ROOT="$test_tmp/acpi/proc" OMARCHY_SYS_ROOT="$sysfs/sys" "$match" asus,zenbook-a16-ux3607oa ||
  fail "hw-match-device-tree falls back to sysfs when procfs shows no device tree"
if OMARCHY_PROC_ROOT="$test_tmp/acpi/proc" "$match" asus,zenbook-a16-ux3607oa microsoft,denali-oled qcom,x1e80100; then
  fail "hw-match-device-tree finds nothing on a machine without a device tree"
fi
if OMARCHY_IMAGE_ROOT="$test_tmp/acpi" "$match" asus,zenbook-a16-ux3607oa microsoft,denali-oled qcom,x1e80100; then
  fail "hw-match-device-tree reads no live device tree when an image root is named"
fi
pass "hw-match-device-tree follows the fixture roots"
