#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export test_tmp

omarchy-drive-info() {
  printf '%s\n' "$1" >> "$test_tmp/drives"
  printf '%s (1T) - Test disk\n' "$1"
}
gum() {
  local row
  IFS= read -r row
  cat >/dev/null
  printf '%s\n' "$row"
  return "${CHOOSE_RESULT:-0}"
}
lsblk() { printf '%s\n' /dev/sda /dev/nvme0n1 /dev/loop0; }
export -f omarchy-drive-info gum lsblk

run_select() {
  : > "$test_tmp/drives"
  bash "$ROOT/bin/omarchy-drive-select" "$@"
}
selected=$(run_select /dev/sda /dev/nvme0n1)
[[ $selected == "/dev/sda" ]] || fail "selection returns only the device path"
[[ $(<"$test_tmp/drives") == $'/dev/sda\n/dev/nvme0n1' ]] || fail "each argument is inspected separately"
pass "multiple device arguments produce separate choices"

run_select $'/dev/sda\n/dev/nvme0n1' >/dev/null
[[ $(<"$test_tmp/drives") == $'/dev/sda\n/dev/nvme0n1' ]] || fail "newline-delimited caller input remains supported"
pass "the encrypted-drive caller's newline-delimited input remains supported"

run_select >/dev/null
[[ $(<"$test_tmp/drives") == $'/dev/sda\n/dev/nvme0n1' ]] || fail "automatic discovery filters unsupported devices"
pass "automatic drive discovery is unchanged"

if CHOOSE_RESULT=1 run_select /dev/sda > "$test_tmp/selection"; then
  fail "cancelled selection must fail"
fi
[[ ! -s $test_tmp/selection ]] || fail "cancelled selection emits no device"
pass "cancelling does not return a drive"
