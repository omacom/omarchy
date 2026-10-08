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
    local remainder=${spec#*:}
    local product_id=${remainder%%:*}
    # A spec with no third field describes a device with no product
    # descriptor. Without this guard ${remainder#*:} would return the product
    # id unchanged and quietly write it out as the product string.
    local product=""
    if [[ $remainder == *:* ]]; then
      product=${remainder#*:}
    fi
    local dev="$tmp_dir/devices/1-$index"

    mkdir -p "$dev"
    printf '%s\n' "$vendor" >"$dev/idVendor"
    printf '%s\n' "$product_id" >"$dev/idProduct"
    [[ -n $product ]] && printf '%s\n' "$product" >"$dev/product"
    index=$((index + 1))
  done
}

# A copy of the command reads its platform file from a fixture root: none
# unless a case writes one, whatever the machine running the suite has installed.
platform_root="$tmp_dir/platform"
mkdir -p "$platform_root" "$tmp_dir/bin"
platform_root_copy "$ROOT/bin/omarchy-hw-fingerprint" "$tmp_dir/bin/omarchy-hw-fingerprint" "$platform_root"

hw_fingerprint() {
  OMARCHY_USB_DEVICES_PATH="$tmp_dir/devices" "$tmp_dir/bin/omarchy-hw-fingerprint"
}

assert_detects() {
  local description="$1"

  hw_fingerprint || fail "$description"
  pass "$description"
}

assert_rejects() {
  local description="$1"

  if hw_fingerprint; then
    fail "$description"
  fi
  pass "$description"
}

write_usb_devices '10a5:a305:FPC L:0000 FW:1425046'
assert_detects "an FPC reader is detected by its product string"

write_usb_devices '10a5:1234:Generic USB Device'
assert_rejects "a generic 10a5 USB device is not detected"

write_usb_devices '10a5:9800:FPC Sensor Controller L:0002 FW:25.26.23.14'
assert_detects "an FPC reader is detected by its sensor-controller string"

# Pins the match to a prefix. FPC abbreviates unrelated things too, and this
# branch is trusted with no kernel-driver check, so the token is not enough.
write_usb_devices '0bda:5842:USB2.0 FPC Camera'
assert_rejects "an FPC token mid-string is not detected"

write_usb_devices '1234:5678:Goodix Fingerprint USB Device'
assert_detects "a reader is detected by an existing product-name match"

write_usb_devices '27c6:1234'
assert_detects "a reader is detected by an existing vendor match"

bind_driver() {
  local dev="$1" driver="$2"

  # sysfs links the interface at a driver directory, and the detector's [[ -e ]]
  # follows the link, so the target has to exist for this to model anything.
  mkdir -p "$tmp_dir/drivers/$driver" "$tmp_dir/devices/$dev"
  ln -sf "$tmp_dir/drivers/$driver" "$tmp_dir/devices/$dev/driver"
}

write_usb_devices '27c6:1234'
bind_driver '1-0/1-0:1.0' uvcvideo
assert_rejects "a vendor guess bound to a kernel driver is rejected"

write_usb_devices '27c6:1234'
bind_driver '1-0/1-0:1.0' usbfs
assert_detects "a vendor guess claimed through usbfs is still detected"

write_usb_devices '27c6:1234'
bind_driver '1-0/1-0:1.0' usbfs
bind_driver '1-0/1-0:1.1' uvcvideo
assert_rejects "a real driver alongside a usbfs claim is still rejected"

# The product-name branch is trusted outright, whatever is bound to it.
write_usb_devices '27c6:1234:Goodix Fingerprint USB Device'
bind_driver '1-0/1-0:1.0' uvcvideo
assert_detects "a self-named reader is detected with a driver bound"

write_usb_devices '1234:5678:Generic USB Device'
assert_rejects "a machine with no matching USB devices detects nothing"

# A reader the platform names: a file and the value it reads once usable, as a
# Mac's Secure Enclave reports Touch ID. No USB device takes part.
write_platform_readers() {
  printf '%s\n' "$@" >"$platform_root/fingerprint-readers"
}
write_sep() {
  mkdir -p "$tmp_dir/sep/$1.sep/diag"
  printf '%s\n' "$2" >"$tmp_dir/sep/$1.sep/diag/touchid"
}
write_usb_devices '1234:5678:Generic USB Device'
rm -rf "$tmp_dir/sep"
write_sep 396400000 ready
write_platform_readers '# Touch ID' '' "$tmp_dir/sep/*.sep/diag/touchid ready"
assert_detects "a reader the platform names is detected once its file reads the value"

write_sep 396400000 absent
assert_rejects "a reader the platform names is not detected while its file reads another value"

write_sep 196400000 ready
assert_detects "any file the platform's glob matches can show the reader"

rm -rf "$tmp_dir/sep"
assert_rejects "a reader whose file is missing is not detected"

write_sep 396400000 ready
printf '%s ready\r\n' "$tmp_dir/sep/*.sep/diag/touchid" >"$platform_root/fingerprint-readers"
assert_detects "a fingerprint-readers file saved with CRLF line ends reads the same"

write_platform_readers "sep/*.sep/diag/touchid ready" "$tmp_dir/sep/*.sep/diag/touchid" \
  "$tmp_dir/sep/*.sep/diag/touchid ready now" "#$tmp_dir/sep/*.sep/diag/touchid ready"
assert_rejects "relative paths, a missing value, an extra word and comments name no reader"

# A platform file that matches nothing never hides a USB reader on the same
# machine: the USB scan still runs after it.
write_usb_devices '1234:5678:Goodix Fingerprint USB Device'
write_sep 396400000 absent
write_platform_readers "$tmp_dir/sep/*.sep/diag/touchid ready"
assert_detects "a USB reader is detected while the platform's reader is not ready"
write_platform_readers "$tmp_dir/nowhere/*/diag/touchid ready"
assert_detects "a USB reader is detected while the platform's glob matches nothing"
write_usb_devices '27c6:1234'
assert_detects "a USB reader found by vendor is detected beside a platform file"

rm -f "$platform_root/fingerprint-readers"
