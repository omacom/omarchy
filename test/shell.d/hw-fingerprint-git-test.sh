#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

write_usb_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0 spec
  for spec in "$@"; do
    local dev="$tmp_dir/devices/1-$index"
    mkdir -p "$dev"
    printf '%s\n' "${spec%%:*}" > "$dev/idVendor"
    [[ $spec == *:* ]] && printf '%s\n' "${spec#*:}" > "$dev/idProduct"
    index=$((index + 1))
  done
}

hw_fingerprint_git() {
  OMARCHY_USB_DEVICES_PATH="$tmp_dir/devices" "$ROOT/bin/omarchy-hw-fingerprint-git"
}

assert_detects() {
  hw_fingerprint_git || fail "$1"
  pass "$1"
}

assert_rejects() {
  if hw_fingerprint_git; then
    fail "$1"
  fi
  pass "$1"
}

write_usb_devices '06cb:010b'
assert_detects "the Synaptics 06cb:010b reader needs libfprint-git"

write_usb_devices '1d6b:0002' '06cb:010b'
assert_detects "the reader is found among other devices"

write_usb_devices '06cb:00bd'
assert_rejects "another Synaptics reader does not"

write_usb_devices '27c6:5395'
assert_rejects "a Goodix reader does not"

write_usb_devices '06cb'
assert_rejects "a device with no product id is skipped"

write_usb_devices
assert_rejects "an empty bus matches nothing"
