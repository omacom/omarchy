#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

write_usb_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local vendor=${spec%%:*}
    local product=${spec#*:}
    local dev="$tmp_dir/devices/1-$index"

    mkdir -p "$dev"
    printf '%s\n' "$vendor" >"$dev/idVendor"
    printf '%s\n' "$product" >"$dev/idProduct"
    index=$((index + 1))
  done
}

hw_fingerprint_validity() {
  OMARCHY_USB_DEVICES_PATH="$tmp_dir/devices" "$ROOT/bin/omarchy-hw-fingerprint-validity"
}

assert_detects() {
  local description="$1"

  hw_fingerprint_validity || fail "$description"
  pass "$description"
}

assert_rejects() {
  local description="$1"

  if hw_fingerprint_validity; then
    fail "$description"
  fi
  pass "$description"
}

# The full python-validity supported set, straight from its SupportedDevices
# enum (validitysensor/usb.py).
write_usb_devices '06cb:009a'
assert_detects "the Synaptics Metallica MIS Touch reader is detected"

write_usb_devices '138a:0090'
assert_detects "a Validity 0090 reader is detected"

write_usb_devices '138a:0097'
assert_detects "a Validity 0097 reader is detected"

write_usb_devices '138a:009d'
assert_detects "a Validity 009d reader is detected"

# Other Validity and Synaptics IDs python-validity has no firmware for must
# not take the python-validity path; libfprint or nothing will serve them.
write_usb_devices '138a:0091'
assert_rejects "a Validity reader outside the supported set is not detected"

write_usb_devices '138a:0011'
assert_rejects "an older Validity reader is not detected"

write_usb_devices '06cb:0081'
assert_rejects "a Synaptics Prometheus reader is not detected"

write_usb_devices '06cb:0010'
assert_rejects "a plain Synaptics USB device is not detected"

# Other vendors that also appear in the fingerprint setup never match.
write_usb_devices '10a5:9800'
assert_rejects "an FPC reader is not detected"

write_usb_devices '27c6:1234'
assert_rejects "a Goodix reader is not detected"

# A machine with no matching USB devices detects nothing.
write_usb_devices '1234:5678'
assert_rejects "a machine with no matching USB devices detects nothing"

write_usb_devices
assert_rejects "a machine with no USB devices detects nothing"

# A device that only declares a vendor descriptor still needs a product id
# before its identity can be pinned down.
mkdir -p "$tmp_dir/devices/1-0"
printf '%s\n' '06cb' >"$tmp_dir/devices/1-0/idVendor"
assert_rejects "a device without an idProduct is not detected"