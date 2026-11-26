#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-apple-gmux"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

acpi="$test_tmp/acpi"
mkdir -p "$acpi/PNP0C0A:00" "$acpi/APP0001:00"

detect() {
  OMARCHY_ACPI_DEVICES_PATH="$acpi" "$detector"
}

# Other Apple ACPI devices (the SMC is APP0001) must not read as a gmux, or
# single-GPU Macs would get the drop-in.
! detect || fail "a Mac without gmux is not detected"
pass "a Mac without gmux is not detected"

mkdir -p "$acpi/APP000B:00"
detect || fail "a Mac with gmux is detected"
pass "a Mac with gmux is detected"
