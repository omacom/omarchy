#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/install/hardware/intel/ipu7-camera.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
SH
chmod +x "$stub_bin/omarchy-pkg-add"

# Runs the script against an ACPI tree holding one device per HID:STATUS pair.
run_install() {
  local acpi="$test_tmp/acpi" device i=0
  rm -rf "$acpi"
  for device in "$@"; do
    mkdir -p "$acpi/${device%%=*}:0$i"
    echo "${device%%=*}" >"$acpi/${device%%=*}:0$i/hid"
    echo "${device#*=}" >"$acpi/${device%%=*}:0$i/status"
    i=$((i + 1))
  done
  : >"$calls"
  PATH="$stub_bin:$PATH" TEST_LOG="$calls" OMARCHY_ACPI_DEVICES_PATH="$acpi" \
    bash -euo pipefail -c 'source "$1"' bash "$install_script"
}

# ThinkPad X9 Gen 1: the IMX471 is fitted; the firmware also lists absent
# OmniVision sensors.
run_install SONY471A=15 OVTI01AF=0 OVTI13B1=0 INT3472=15
grep -Fxq 'intel-ipu7-camera' "$calls" || fail "a fitted IMX471 installs the IPU7 camera stack" "$(cat "$calls")"
pass "a fitted IMX471 installs the IPU7 camera stack"

# A firmware table that lists the IMX471 without fitting it.
run_install SONY471A=0 INT3472=15
[[ ! -s $calls ]] || fail "an absent IMX471 installs nothing" "$(cat "$calls")"
pass "an absent IMX471 installs nothing"
