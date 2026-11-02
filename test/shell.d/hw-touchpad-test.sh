#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

touchpad="$ROOT/bin/omarchy-hw-touchpad"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
input_class="$test_tmp/input"
mkdir -p "$stub_bin"

# Hyprland's mice, in its order, from a space-separated MICE.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

jq -n --arg names "${MICE:-}" \
  '{mice: [$names | split(" ")[] | select(. != "") | {name: .}], keyboards: []}'
SH

# udev's properties for an event device, kept beside it in the fixture.
cat >"$stub_bin/udevadm" <<'SH'
#!/bin/bash

cat "${!#}/udev" 2>/dev/null
SH

chmod +x "$stub_bin"/*

# An event device as sysfs shows it: its input device's name, and what udev
# made of it.
event_device() {
  mkdir -p "$input_class/$1/device"
  printf '%s\n' "$2" >"$input_class/$1/device/name"
  printf '%s\n' "$3" >"$input_class/$1/udev"
}

detected() {
  MICE="$1" OMARCHY_INPUT_CLASS_PATH="$input_class" PATH="$stub_bin:$PATH" bash "$touchpad"
}

# Apple Silicon's trackpad is named after its MTP HID interface, so neither
# word is in its name; udev still calls it a touchpad.
event_device event1 "Apple MTP keyboard" "ID_INPUT_KEYBOARD=1"
event_device event2 "Apple MTP multi-touch" "ID_INPUT_TOUCHPAD=1"
[[ $(detected "apple-mtp-multi-touch") == "apple-mtp-multi-touch" ]] ||
  fail "the Apple Silicon trackpad is detected" "$(detected "apple-mtp-multi-touch")"
pass "the Apple Silicon trackpad is detected"

# omarchy-toggle-input-device passes the name straight to hl.device, so a name
# that does not match leaves the menu entry hidden and the toggle dead.
for name in "elan-touchpad" "apple-magic-trackpad-2"; do
  [[ $(detected "$name") == "$name" ]] || fail "the touchpads that already worked still do" "$(detected "$name")"
done
pass "the touchpads that already worked still do"

# Some touchscreens' mouse interfaces are called multi-touch as well. A named
# touchpad wins over one listed first, and without one it takes udev calling
# the device a touchpad, not its name.
rm -rf "$input_class"
event_device event5 "ELAN9008:00 04F3:2C82 Multi-Touch" "ID_INPUT_TOUCHSCREEN=1"
event_device event7 "SYNA2BA6:00 06CB:CEF5 Touchpad" "ID_INPUT_TOUCHPAD=1"
[[ $(detected "elan9008:00-04f3:2c82-multi-touch syna2ba6:00-06cb:cef5-touchpad") == "syna2ba6:00-06cb:cef5-touchpad" ]] ||
  fail "a touchscreen listed first does not take the touchpad's place" "$(detected "elan9008:00-04f3:2c82-multi-touch syna2ba6:00-06cb:cef5-touchpad")"
[[ -z $(detected "elan9008:00-04f3:2c82-multi-touch") ]] ||
  fail "a multi-touch touchscreen alone is no touchpad" "$(detected "elan9008:00-04f3:2c82-multi-touch")"
pass "a multi-touch touchscreen is never taken for the touchpad"

# Hyprland turns commas into dashes as well as spaces.
event_device event9 "Acme, Inc. Precision Pad" "ID_INPUT_TOUCHPAD=1"
[[ $(detected "acme--inc.-precision-pad") == "acme--inc.-precision-pad" ]] ||
  fail "a touchpad named with a comma is found by Hyprland's name for it" "$(detected "acme--inc.-precision-pad")"
pass "a touchpad named with a comma is found by Hyprland's name for it"

# Hyprland adds -1, -2 and so on to a name another device already took, as when
# the MTP interface exposes the trackpad twice; that name is the one to toggle,
# and an unrelated name that merely starts the same is not.
event_device event11 "Apple MTP multi-touch" "ID_INPUT_TOUCHPAD=1"
[[ $(detected "apple-mtp-multi-touch-1") == "apple-mtp-multi-touch-1" ]] ||
  fail "a touchpad under Hyprland's numbered name is found" "$(detected "apple-mtp-multi-touch-1")"
[[ -z $(detected "apple-mtp-multi-touch-extra") ]] ||
  fail "a name that only starts with the touchpad's is not taken for it" "$(detected "apple-mtp-multi-touch-extra")"
pass "a touchpad under Hyprland's numbered name for a duplicate is found"

# udev's touchpad has to be one of Hyprland's mice for its name to toggle.
[[ -z $(detected "logitech-mx-master-3") ]] ||
  fail "a udev touchpad Hyprland does not list is not reported" "$(detected "logitech-mx-master-3")"
pass "an ordinary mouse is not mistaken for a touchpad"

[[ -z $(detected "") ]] ||
  fail "no touchpad answers with an empty detection" "$(detected "")"
pass "no touchpad answers with an empty detection"
