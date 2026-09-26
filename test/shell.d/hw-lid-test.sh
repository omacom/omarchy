#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

lid_path="$test_tmp/lid"

has_lid() {
  OMARCHY_ACPI_LID_PATH="$lid_path" "$ROOT/bin/omarchy-hw-lid"
}

if has_lid; then
  fail "a missing ACPI lid tree means no lid switch"
fi
pass "lid detection handles a missing ACPI lid tree"

mkdir -p "$lid_path"
if has_lid; then
  fail "an empty ACPI lid tree means no lid switch"
fi
pass "lid detection handles an empty ACPI lid tree"

mkdir -p "$lid_path/LID0"
printf 'state:      open\n' >"$lid_path/LID0/state"
has_lid || fail "an ACPI lid button is a lid switch"
pass "lid detection finds an ACPI lid button"

printf 'state:      closed\n' >"$lid_path/LID0/state"
has_lid || fail "a closed lid is still a lid switch"
pass "lid detection does not depend on the lid being open"
