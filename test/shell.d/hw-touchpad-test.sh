#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Stub only hyprctl: the real jq pipeline in omarchy-hw-touchpad runs
# unmodified against canned device lists.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
cat "$HYPRCTL_DEVICES"
SH
chmod +x "$stub_bin/hyprctl"

detect() {
  PATH="$stub_bin:$ROOT/bin:$PATH" HYPRCTL_DEVICES="$1" "$ROOT/bin/omarchy-hw-touchpad"
}

devices="$test_tmp/devices.json"

# The MacBookPro11,5 layout: the trackpad reports the bare bcm5974 driver
# name next to an unrelated Broadcom Bluetooth controller that must not win.
cat >"$devices" <<'JSON'
{"mice": [{"name": "bcm5974"}, {"name": "broadcom-corp.-bluetooth-usb-host-controller-1"}]}
JSON
[[ $(detect "$devices") == "bcm5974" ]] ||
  fail "detection finds the bcm5974 trackpad without matching the Bluetooth controller"
pass "detection finds the bcm5974 trackpad"

cat >"$devices" <<'JSON'
{"mice": [{"name": "broadcom-corp.-bluetooth-usb-host-controller-1"}, {"name": "bcm5974"}]}
JSON
[[ $(detect "$devices") == "bcm5974" ]] ||
  fail "detection skips non-trackpad devices regardless of order"
pass "detection skips non-trackpad devices"

cat >"$devices" <<'JSON'
{"mice": [{"name": "elan-touchpad"}, {"name": "Logitech USB Mouse"}]}
JSON
[[ $(detect "$devices") == "elan-touchpad" ]] ||
  fail "detection still matches classic touchpad names"
pass "detection still matches classic touchpad names"

cat >"$devices" <<'JSON'
{"mice": [{"name": "Apple Internal Trackpad"}]}
JSON
[[ $(detect "$devices") == "Apple Internal Trackpad" ]] ||
  fail "detection still matches trackpad names"
pass "detection still matches trackpad names"

cat >"$devices" <<'JSON'
{"mice": [{"name": "Logitech USB Mouse"}]}
JSON
set +e
output=$(detect "$devices")
status=$?
set -e
(( status != 0 )) || fail "detection errors when no touchpad exists"
[[ -z $output ]] || fail "detection prints nothing when no touchpad exists"
pass "detection errors when no touchpad exists"
