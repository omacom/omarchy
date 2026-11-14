#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-fingerprint"
predicate="$ROOT/bin/omarchy-hw-fingerprint-controlvault3"

extract_ids() {
  grep -o 'controlvault3_products="[^"]*"' "$1"
}

detector_ids=$(extract_ids "$detector")
predicate_ids=$(extract_ids "$predicate")
[[ -n $detector_ids && $detector_ids == "$predicate_ids" ]] ||
  fail "ControlVault 3 USB ids match in detection and driver selection" "$detector_ids vs $predicate_ids"
pass "ControlVault 3 USB ids match in detection and driver selection"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

write_device() {
  local vendor="$1"
  local product_id="$2"
  local dev="$tmp_dir/devices/1-0"

  rm -rf "$tmp_dir/devices"
  mkdir -p "$dev"
  printf '%s\n' "$vendor" >"$dev/idVendor"
  printf '%s\n' "$product_id" >"$dev/idProduct"
}

predicate_matches() {
  OMARCHY_USB_DEVICES_PATH="$tmp_dir/devices" "$predicate"
}

write_device 0a5c 5843
predicate_matches || fail "ControlVault 3 id 5843 selects the Broadcom driver"
pass "ControlVault 3 id 5843 selects the Broadcom driver"

for product_id in 5842 5844 5845; do
  write_device 0a5c "$product_id"
  predicate_matches || fail "ControlVault 3 id ${product_id} selects the Broadcom driver"
  pass "ControlVault 3 id ${product_id} selects the Broadcom driver"
done

write_device 0a5c 5865
if predicate_matches; then
  fail "ControlVault 3+ does not select the ControlVault 3 driver"
fi
pass "ControlVault 3+ does not select the ControlVault 3 driver"

write_device 0a5c bd1f
if predicate_matches; then
  fail "a Broadcom wireless adapter does not select the ControlVault 3 driver"
fi
pass "a Broadcom wireless adapter does not select the ControlVault 3 driver"

write_device 27c6 5843
if predicate_matches; then
  fail "the ControlVault product id on another vendor is not the Broadcom reader"
fi
pass "the ControlVault product id on another vendor is not the Broadcom reader"
