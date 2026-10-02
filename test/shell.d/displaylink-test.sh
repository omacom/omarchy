#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

usb_path="$test_tmp/usb"
mock_bin="$test_tmp/bin"
setup_log="$test_tmp/setup-log"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash
printf 'pkg-aur-add:%s\n' "$*" >>"$OMARCHY_TEST_SETUP_LOG"
SH

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo:%s\n' "$*" >>"$OMARCHY_TEST_SETUP_LOG"
SH

chmod +x "$mock_bin"/*

# idVendor is read with a whole-line match, so the fixtures write the vendor id
# exactly as the kernel does, newline included.
write_devices() {
  rm -rf "$usb_path"
  mkdir -p "$usb_path"

  local device vendor
  while (( $# )); do
    device="$1"
    vendor="$2"
    mkdir -p "$usb_path/$device"
    printf '%s\n' "$vendor" >"$usb_path/$device/idVendor"
    shift 2
  done
}

has_displaylink() {
  OMARCHY_USB_DEVICES_PATH="$usb_path" "$ROOT/bin/omarchy-hw-displaylink"
}

run_install() {
  OMARCHY_TEST_SETUP_LOG="$setup_log" OMARCHY_USB_DEVICES_PATH="$usb_path" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-install-displaylink"
}

write_devices
if has_displaylink; then
  fail "an empty USB tree has no DisplayLink device"
fi
pass "DisplayLink detection handles an empty USB tree"

write_devices "1-1" "0bda" "1-2" "8087"
if has_displaylink; then
  fail "a USB tree without the DisplayLink vendor id is not a match"
fi
pass "DisplayLink detection ignores other USB vendors"

write_devices "1-1" "0bda" "2-1" "17e9"
has_displaylink || fail "a DisplayLink device is detected"
pass "DisplayLink detection finds the dock vendor id"

write_devices "1-1" "17e90"
if has_displaylink; then
  fail "a vendor id that only starts with 17e9 is not a match"
fi
pass "DisplayLink detection matches the whole vendor id"

write_devices "1-1" "17e9"
attached=$(run_install)
[[ $attached == *"Replug the dock"* ]] || \
  fail "the installer asks for a replug when the dock is already attached" "$attached"
pass "the installer asks for a replug when the dock is already attached"

write_devices "1-1" "0bda"
detached=$(run_install)
[[ $detached == *"Plug the dock in"* ]] || \
  fail "the installer invites a plug-in when no dock is attached" "$detached"
pass "the installer invites a plug-in when no dock is attached"

grep -qx 'pkg-aur-add:evdi-dkms displaylink' "$setup_log" || \
  fail "the installer adds the kernel module and the userspace driver"
grep -qx 'sudo:systemctl enable --now displaylink.service' "$setup_log" || \
  fail "the installer enables the DisplayLink Manager service"
pass "the installer adds the driver packages and enables its service"
