#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

panel="$ROOT/shell/plugins/panels/bluetooth/Panel.qml"

grep -Fq 'readonly property var devices: adapter && adapter.devices ? adapter.devices.values : []' "$panel" ||
  fail "bluetooth panel scopes device rows to its active adapter"
pass "bluetooth panel scopes device rows to its active adapter"

grep -Fq 'if (adapter && adapter.adapterId) command.push(String(adapter.adapterId))' "$panel" ||
  fail "bluetooth panel passes its adapter id to device actions"
pass "bluetooth panel passes its adapter id to device actions"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
log="$test_tmp/bluetooth.log"

cat >"$mock_bin/bluetoothctl" <<'SH'
#!/bin/bash
printf 'bluetoothctl %s\n' "$*" >>"$BLUETOOTH_TEST_LOG"
[[ ${1:-} == "show" ]] && printf '\tPowered: yes\n'
exit 0
SH

cat >"$mock_bin/omarchy-bluetooth-power" <<'SH'
#!/bin/bash
printf 'power %s\n' "$*" >>"$BLUETOOTH_TEST_LOG"
exit 0
SH

chmod +x "$mock_bin/bluetoothctl" "$mock_bin/omarchy-bluetooth-power"

run_device() {
  : >"$log"
  PATH="$mock_bin:$PATH" BLUETOOTH_TEST_LOG="$log" \
    "$ROOT/bin/omarchy-bluetooth-device" "$@" || fail "bluetooth device action exits cleanly: $*"
}

run_device connect aa:bb:cc:dd:ee:ff hci1
grep -Fxq 'power on' "$log" || fail "scoped Bluetooth action lifts Omarchy power state"
grep -Fxq 'bluetoothctl trust /org/bluez/hci1/dev_AA_BB_CC_DD_EE_FF' "$log" ||
  fail "Bluetooth connect trusts the device on hci1"
grep -Fxq 'bluetoothctl connect /org/bluez/hci1/dev_AA_BB_CC_DD_EE_FF' "$log" ||
  fail "Bluetooth connect targets the device object on hci1"
! grep -Fxq 'bluetoothctl connect aa:bb:cc:dd:ee:ff' "$log" ||
  fail "Bluetooth connect never falls back to an ambiguous device address"
pass "Bluetooth connect stays on the panel adapter"

run_device pair 01:23:45:67:89:ab hci2
grep -Fxq 'bluetoothctl pair /org/bluez/hci2/dev_01_23_45_67_89_AB' "$log" ||
  fail "Bluetooth pair targets the device object on hci2"
grep -Fxq 'bluetoothctl trust /org/bluez/hci2/dev_01_23_45_67_89_AB' "$log" ||
  fail "Bluetooth pair trusts the device on hci2"
grep -Fxq 'bluetoothctl connect /org/bluez/hci2/dev_01_23_45_67_89_AB' "$log" ||
  fail "Bluetooth pair connects the device on hci2"
pass "Bluetooth pair stays on the panel adapter"

run_device forget 10:20:30:40:50:60 hci3
grep -Fxq 'bluetoothctl disconnect /org/bluez/hci3/dev_10_20_30_40_50_60' "$log" ||
  fail "Bluetooth forget disconnects the device on hci3"
grep -Fxq 'bluetoothctl remove /org/bluez/hci3/dev_10_20_30_40_50_60' "$log" ||
  fail "Bluetooth forget removes the device from hci3"
pass "Bluetooth forget stays on the panel adapter"

run_device connect AA:BB:CC:DD:EE:FF
grep -Fxq 'bluetoothctl trust AA:BB:CC:DD:EE:FF' "$log" ||
  fail "Bluetooth device CLI keeps unscoped trust behavior"
grep -Fxq 'bluetoothctl connect AA:BB:CC:DD:EE:FF' "$log" ||
  fail "Bluetooth device CLI keeps unscoped connect behavior"
pass "Bluetooth device CLI keeps two-argument behavior"

if PATH="$mock_bin:$PATH" BLUETOOTH_TEST_LOG="$log" \
    "$ROOT/bin/omarchy-bluetooth-device" connect AA:BB:CC:DD:EE:FF ../../hci1 >/dev/null 2>&1; then
  fail "Bluetooth device helper rejects an invalid adapter id"
fi
pass "Bluetooth device helper rejects an invalid adapter id"
