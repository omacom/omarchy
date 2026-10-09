#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/hyprctl" <<'SH'
#!/bin/bash
[[ $1 == "devices" && $2 == "-j" ]] || exit 1
cat "$FIXTURE/devices.json"
SH
cat >"$tmp_dir/bin/udevadm" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$FIXTURE/queries"
[[ $1 == "info" && $2 == "--query=property" && $3 == --path=* ]] || exit 1
cat "${3#--path=}/properties" 2>/dev/null
SH
chmod +x "$tmp_dir/bin/"*

reset_fixture() {
  rm -rf "$tmp_dir/input"
  mkdir -p "$tmp_dir/input"
  : >"$tmp_dir/queries"
}

mice() {
  jq -n --args '$ARGS.positional | map({name: .}) | {mice: .}' -- "$@" >"$tmp_dir/devices.json"
}

event() {
  local number=$1 name=$2
  shift 2
  mkdir -p "$tmp_dir/input/event$number/device"
  printf '%s\n' "$name" >"$tmp_dir/input/event$number/device/name"
  printf '%s\n' "$@" >"$tmp_dir/input/event$number/properties"
}

check() {
  local expected=$1 description=$2 actual
  actual=$(PATH="$tmp_dir/bin:$PATH" FIXTURE="$tmp_dir" \
    OMARCHY_INPUT_CLASS_PATH="$tmp_dir/input" \
    "${TOUCHPAD_TEST_COMMAND:-$ROOT/bin/omarchy-hw-touchpad}") || fail "$description" "command failed"
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected; got: $actual"
  pass "$description"
}

reset_fixture
event 1 'SynPS/2 Synaptics TouchPad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
event 2 'Apple Wireless Trackpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=external
mice apple-wireless-trackpad synps/2-synaptics-touchpad
check synps/2-synaptics-touchpad 'internal pad wins when external pad registers first'
mice synps/2-synaptics-touchpad apple-wireless-trackpad
check synps/2-synaptics-touchpad 'internal pad wins when it registers first'
mv "$tmp_dir/input/event1" "$tmp_dir/input/event3"
mice apple-wireless-trackpad synps/2-synaptics-touchpad
check synps/2-synaptics-touchpad 'sysfs enumeration does not determine the preferred pad'

for name in apple-magic-trackpad bluetooth-keyboard-touchpad unknown-touchpad; do
  reset_fixture
  mice "$name"
  check "$name" 'a single external or unknown pad remains usable'
  [[ ! -s $tmp_dir/queries ]] || fail 'single pad avoids udev probing'
done
pass 'single pad avoids udev probing'

reset_fixture
mice external-trackpad unknown-touchpad
event 1 'Unknown Touchpad' ID_INPUT_TOUCHPAD=1
check external-trackpad 'unknown integration retains the existing fallback'
rm "$tmp_dir/input/event1/properties"
check external-trackpad 'failed udev query retains the existing fallback'
event 2 'Absent Touchpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
check external-trackpad 'an internal pad absent from Hyprland is not returned'
event 1 'Unknown Touchpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal ID_INPUT_POINTINGSTICK=1
check external-trackpad 'a pointing stick is not promoted'

reset_fixture
mice external-trackpad first-touchpad second-touchpad
event 1 'First Touchpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
event 2 'Second Touchpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
check external-trackpad 'multiple internal pads retain the existing fallback'

reset_fixture
mice external-trackpad acme-touchpad-pro
event 1 'ACME,Touchpad Pro' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
check acme-touchpad-pro 'case commas and spaces follow Hyprland normalization'
event 1 $'ACME\nTouchpad Pro' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
check acme-touchpad-pro 'embedded newlines follow Hyprland normalization'

reset_fixture
mice external-trackpad acme-touchpad acme-touchpad-1
event 1 'Acme Touchpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
event 2 'Acme Touchpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=external
check external-trackpad 'duplicate kernel names cannot identify which pad is internal'
rm "$tmp_dir/input/event2/device/name"
check external-trackpad 'an incomplete name inventory cannot promote a namesake'

reset_fixture
mice external-trackpad acme-touchpad-1
event 1 'Acme Touchpad-1' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
check external-trackpad 'numeric suffix ambiguity keeps the fallback'

reset_fixture
mice external-trackpad acme-touchpad acme-touchpad-1
event 1 'Acme Touchpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
check external-trackpad 'a Hyprland suffix family blocks priority without a sysfs duplicate'
jq '.keyboards = [{name: "acme-touchpad-1"}] | .mice |= map(select(.name != "acme-touchpad-1"))' \
  "$tmp_dir/devices.json" >"$tmp_dir/with-keyboard.json"
mv "$tmp_dir/with-keyboard.json" "$tmp_dir/devices.json"
check external-trackpad 'a suffix collision in another HID class also blocks priority'

reset_fixture
mice external-trackpad 'odd-$(touch${ifs}sentinel)-touchpad'
event 1 'Odd $(touch${IFS}sentinel) Touchpad' ID_INPUT_TOUCHPAD=1 ID_INPUT_TOUCHPAD_INTEGRATION=internal
(
  cd "$tmp_dir"
  check 'odd-$(touch${ifs}sentinel)-touchpad' 'shell syntax in names remains data'
  [[ ! -e sentinel ]] || fail 'device names are never executed'
)

reset_fixture
mice
if PATH="$tmp_dir/bin:$PATH" FIXTURE="$tmp_dir" \
  OMARCHY_INPUT_CLASS_PATH="$tmp_dir/input" \
  "${TOUCHPAD_TEST_COMMAND:-$ROOT/bin/omarchy-hw-touchpad}" >"$tmp_dir/output"; then
  fail 'no matching pad returns failure'
else
  status=$?
  [[ $status == 1 && ! -s $tmp_dir/output ]] || fail 'no matching pad returns empty output and exit 1'
fi
pass 'no matching pad returns empty output and exit 1'
