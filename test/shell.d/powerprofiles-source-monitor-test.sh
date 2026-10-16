#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# The power source is whatever $tmp_dir/source says: battery, usb-c or ac.
mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/omarchy-power-present" <<EOF
#!/bin/bash
[[ \$(<"$tmp_dir/source") != battery ]]
EOF
cat >"$tmp_dir/bin/omarchy-hw-asus-rog-usbc-power" <<EOF
#!/bin/bash
[[ \$(<"$tmp_dir/source") == usb-c ]]
EOF
cat >"$tmp_dir/bin/omarchy-powerprofiles-set" <<EOF
#!/bin/bash
printf '%s\n' "\$*" >>"$tmp_dir/calls"
EOF
chmod +x "$tmp_dir/bin/"*
export PATH="$tmp_dir/bin:$PATH"

monitor="$ROOT/bin/omarchy-powerprofiles-source-monitor"
acad='UDEV  [100.1] change   /devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0003:00/power_supply/ACAD (power_supply)'
usbc='UDEV  [100.2] change   /devices/platform/USBC000:00/power_supply/ucsi-source-psy-USBC000:001 (power_supply)'
bat='UDEV  [100.3] change   /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0A:00/power_supply/BAT1 (power_supply)'

# run <source at start> <source after the events> <event lines...>
run() {
  local start=$1 after=$2
  shift 2
  printf '%s\n' "$start" >"$tmp_dir/source"
  : >"$tmp_dir/calls"
  {
    sleep 0.3
    printf '%s\n' "$after" >"$tmp_dir/source"
    printf '%s\n' "$@"
    sleep 1.5
  } | "$monitor" --consume
}

run ac usb-c "$acad" "$usbc"
[[ $(<"$tmp_dir/calls") == "ac" ]] || fail "unplugging the barrel with USB-C in re-applies the profile once" "$(cat "$tmp_dir/calls")"
run usb-c ac "$acad" "$usbc"
[[ $(<"$tmp_dir/calls") == "ac" ]] || fail "plugging the barrel in on USB-C re-applies the profile once" "$(cat "$tmp_dir/calls")"
pass "a swap between the barrel and USB-C re-applies the profile once"

run battery ac "$acad"
[[ ! -s $tmp_dir/calls ]] || fail "plugging in is left to the battery service" "$(cat "$tmp_dir/calls")"
run usb-c battery "$usbc"
[[ ! -s $tmp_dir/calls ]] || fail "unplugging is left to the battery service" "$(cat "$tmp_dir/calls")"
run ac ac "$acad"
[[ ! -s $tmp_dir/calls ]] || fail "an event that changes no source does nothing" "$(cat "$tmp_dir/calls")"
run usb-c ac "$bat"
[[ ! -s $tmp_dir/calls ]] || fail "battery uevents are ignored" "$(cat "$tmp_dir/calls")"
pass "plug, unplug, battery and no-change events are left alone"

unit="$ROOT/default/systemd/user/omarchy-powerprofiles-source-monitor.service"
grep -Fx 'ConditionPathExists=|/sys/class/firmware-attributes/asus-armoury/attributes/charge_mode/current_value' "$unit" >/dev/null &&
  grep -Fx 'ConditionPathExists=|/sys/devices/platform/asus-nb-wmi/charge_mode' "$unit" >/dev/null ||
  fail "the source monitor runs only where charge_mode exists"
grep -F 'omarchy-powerprofiles-source-monitor.service' "$ROOT/install/user/first-run/enable-user-units.sh" >/dev/null ||
  fail "first run enables the source monitor"
pass "the source monitor is enabled everywhere and runs only on ASUS charge_mode hardware"
