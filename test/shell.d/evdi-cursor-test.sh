#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/home/.config/hypr" "$test_tmp/evdi"

looknfeel="$test_tmp/home/.config/hypr/looknfeel.lua"
printf '%s\n' '-- User look and feel' >"$looknfeel"

run_fix() {
  HOME="$test_tmp/home" \
    OMARCHY_EVDI_MODULE_PATH="$1" \
    bash -euo pipefail -c 'source "$ROOT/install/user/hardware/fix-evdi-cursor.sh"'
}

run_fix "$test_tmp/evdi" >/dev/null
grep -F 'no_hardware_cursors = true' "$looknfeel" >/dev/null
pass "evdi/DisplayLink setup enables software cursors"

run_fix "$test_tmp/evdi" >/dev/null
(( $(grep -c 'no_hardware_cursors = true' "$looknfeel") == 1 )) || fail "evdi cursor setup is idempotent"
pass "evdi cursor setup is idempotent"

printf '%s\n' '-- User look and feel' >"$looknfeel"
run_fix "$test_tmp/no-evdi" >/dev/null
if grep -q 'no_hardware_cursors' "$looknfeel"; then
  fail "evdi cursor setup ignores machines without evdi"
fi
pass "evdi cursor setup ignores machines without evdi"
