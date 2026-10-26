#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Run the complete setup leaf, including the code after package installation.
# Redirect only its filesystem roots; package and service calls are stubs.
sed -e "s|/sys/bus/acpi/devices|$tmp_dir/acpi|g" \
  -e "s|/etc/|$tmp_dir/etc/|g" \
  "$ROOT/install/hardware/nvidia.sh" >"$tmp_dir/nvidia.sh"

omarchy-hw-aarch64-n1x() { return 1; }
omarchy-hw-nvidia-gsp() { return 0; }
omarchy-hw-x86() { [[ $TEST_ARCH == "x86" ]]; }
lspci() { echo '01:00.0 VGA compatible controller: NVIDIA Corporation'; }
omarchy-pkg-add() { printf '%s\n' "$@" >"$TEST_PACKAGES"; }
systemctl() { printf '%s\n' "$*" >>"$TEST_SERVICES"; }
export -f omarchy-hw-aarch64-n1x omarchy-hw-nvidia-gsp omarchy-hw-x86 lspci omarchy-pkg-add systemctl
export TEST_PACKAGES="$tmp_dir/packages" TEST_SERVICES="$tmp_dir/services"

while IFS='|' read -r description architecture controller expected; do
  mkdir -p "$tmp_dir/acpi/controller"
  rm -f "$tmp_dir/acpi/controller/hid" "$TEST_PACKAGES" "$TEST_SERVICES"
  if [[ $controller != "missing" ]]; then
    printf '%s\n' "$controller" >"$tmp_dir/acpi/controller/hid"
  fi

  TEST_ARCH="$architecture" bash -euo pipefail "$tmp_dir/nvidia.sh"
  [[ -s $TEST_PACKAGES ]] || fail "$description reaches the package installation"
  [[ -f $tmp_dir/etc/modprobe.d/nvidia.conf && -f $tmp_dir/etc/mkinitcpio.conf.d/nvidia.conf ]] ||
    fail "$description completes setup after the guard"

  actual=""
  [[ ! -f $TEST_SERVICES ]] || actual=$(<"$TEST_SERVICES")
  [[ $actual == "$expected" ]] || fail "$description" "expected '$expected', got '$actual'"
  pass "$description"
done <<'CASES'
x86 exact controller enables Dynamic Boost|x86|NVDA0820|enable nvidia-powerd
ARM exact controller does not enable Dynamic Boost|arm|NVDA0820|
x86 with no controller ID does not enable Dynamic Boost|x86|missing|
x86 controller prefix does not match|x86|NVDA0820extra|
x86 controller suffix does not match|x86|extraNVDA0820|
x86 lowercase controller does not match|x86|nvda0820|
x86 different controller does not match|x86|NVDA0821|
CASES
