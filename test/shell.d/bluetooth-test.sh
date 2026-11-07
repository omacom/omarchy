#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const bluetooth = requireFromRoot('shell/plugins/panels/bluetooth/Model.js')

assert(bluetooth.isUuidLike('0000110b-0000-1000-8000-00805f9b34fb'), 'bluetooth detects UUID-like names')
assert(bluetooth.isAddressLike('AA:BB:CC:DD:EE:FF'), 'bluetooth detects address-like names')
assertEqual(bluetooth.normalizedAddress('AA:BB_CC-dd-ee-ff'), 'aabbccddeeff', 'bluetooth normalizes BlueZ and PipeWire address formats')
assert(!bluetooth.hasHumanName({ name: 'AA:BB:CC:DD:EE:FF' }), 'bluetooth rejects address-only device labels')
assert(bluetooth.hasHumanName({ deviceName: 'MX Master 3S' }), 'bluetooth accepts human device labels')

const devices = [
  { name: 'Speaker', connected: false, paired: true, address: '2' },
  { name: 'Headphones', connected: true, address: '1' },
  { name: 'Keyboard', connected: false, address: '3' },
  { name: 'AA:BB:CC:DD:EE:FF', connected: true, address: '4' },
  { name: 'Mouse', connected: false, trusted: true, address: '5' }
]

const arrayLikeDevices = {
  0: devices[0],
  1: devices[1],
  length: 2
}
assertDeepEqual(
  bluetooth.toArray(arrayLikeDevices).map(bluetooth.deviceLabel),
  ['Speaker', 'Headphones'],
  'bluetooth converts Quickshell QObjectList-style values into arrays'
)

const lists = bluetooth.deviceLists(devices)
assertDeepEqual(lists.connected.map(bluetooth.deviceLabel), ['Headphones'], 'bluetooth groups connected devices')
assertDeepEqual(lists.known.map(bluetooth.deviceLabel), ['Mouse', 'Speaker'], 'bluetooth groups known devices by label')
assertDeepEqual(lists.discovered.map(bluetooth.deviceLabel), ['Keyboard'], 'bluetooth groups discovered devices')
assertDeepEqual(bluetooth.visibleSections(lists, true), ['connected', 'known', 'discovered'], 'bluetooth shows discovered section while scanning')
assertDeepEqual(bluetooth.visibleSections(lists, false), ['connected', 'known'], 'bluetooth hides discovered section when not scanning')

const arrayLikeLists = bluetooth.deviceLists({
  0: { name: 'Earbuds', connected: true, address: '6' },
  1: { name: 'Trackpad', paired: true, address: '7' },
  2: { name: 'Gamepad', address: '8' },
  length: 3
})
assertDeepEqual(arrayLikeLists.connected.map(bluetooth.deviceLabel), ['Earbuds'], 'bluetooth groups connected devices from array-like values')
assertDeepEqual(arrayLikeLists.known.map(bluetooth.deviceLabel), ['Trackpad'], 'bluetooth groups known devices from array-like values')
assertDeepEqual(arrayLikeLists.discovered.map(bluetooth.deviceLabel), ['Gamepad'], 'bluetooth groups discovered devices from array-like values')

assertDeepEqual(
  bluetooth.deviceRow({ name: 'Deadbeef', address: '1', connected: false }),
  { address: '1', name: 'Deadbeef', deviceName: '', connected: false, state: -1, batteryAvailable: false, battery: 0, percentage: null, charge: '', pairing: false },
  'bluetooth projects device rows with primitives only'
)
assertEqual(
  bluetooth.deviceLabel(bluetooth.deviceRow({ name: 'Generic', deviceName: 'MX Master 3S', address: '2', connected: true })),
  'MX Master 3S',
  'bluetooth keeps deviceName in row projections so labels survive QObject-free rows'
)

assertEqual(bluetooth.upowerAddress('/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF'), 'aabbccddeeff', 'bluetooth reads a BlueZ path as a battery address')
assertEqual(bluetooth.upowerAddress('hid-aa:bb:cc:dd:ee:ff-battery'), 'aabbccddeeff', 'bluetooth reads a colon address out of a HID supply')
assertEqual(bluetooth.upowerAddress('hid-04_4b_ed_eb_f5_10-battery-144'), '044bedebf510', 'bluetooth reads an underscore address out of a HID supply')
assertEqual(bluetooth.upowerAddress('/org/freedesktop/UPower/devices/touchpad_hid_04o4boedoebof5o10_battery_144'), '044bedebf510', 'bluetooth reads the colon-as-o address in a UPower object path')
assertEqual(bluetooth.upowerAddress('hid-F0T5474067XG9KPAV-battery-144'), '', 'bluetooth leaves a serial HID supply with no address unmatched')
assertEqual(bluetooth.upowerAddress('hidpp_battery_0'), '', 'bluetooth leaves a HID++ supply with no address unmatched')

// James's pair: the trackpad is connected over Bluetooth and UPower knows the
// BlueZ path; the keyboard is on a cable, so BlueZ does not list it as
// connected. The hover names both, and UPower's level wins over a stale
// BlueZ percentage because only UPower knows charging.
const trackpad = { name: 'Magic Trackpad', address: 'AA:BB:CC:DD:EE:01', connected: true, batteryAvailable: true, battery: 0.1 }
const pairedKeyboard = { name: 'Magic Keyboard', address: 'AA:BB:CC:DD:EE:02', connected: false, paired: true }
const readouts = bluetooth.batteryReadouts(
  [trackpad, pairedKeyboard, { name: 'WH-1000XM5', address: 'AA:BB:CC:DD:EE:03', connected: true, batteryAvailable: true, battery: 0.8 }],
  [
    { type: 14, model: 'Magic Trackpad', percentage: 0.39, state: 2, nativePath: '/org/bluez/hci0/dev_AA_BB_CC_DD_EE_01', powerSupply: false },
    { type: 6, model: 'Magic Keyboard', percentage: 0.22, state: 1, nativePath: 'hidpp_battery_0', powerSupply: false },
    { type: 2, model: 'Internal', percentage: 0.77, state: 2, nativePath: 'BAT0', powerSupply: true, isLaptopBattery: true },
    { type: 1, model: 'AC', percentage: 0, state: 0, nativePath: 'AC', powerSupply: true },
    { type: 6, model: 'Ghost', percentage: 0, state: 0, nativePath: 'hidpp_battery_1', powerSupply: false }
  ]
)
assertDeepEqual(readouts.map((entry) => [entry.name, entry.percentage, entry.charge, entry.matched]), [
  ['Magic Keyboard', 22, 'charging', false],
  ['Magic Trackpad', 39, 'discharging', true],
  ['WH-1000XM5', 80, '', true]
], 'bluetooth lists UPower peripheral batteries, prefers them over BlueZ, and skips the laptop supply')
assertDeepEqual(bluetooth.unmatchedBatteries(readouts).map((entry) => entry.name), ['Magic Keyboard'], 'bluetooth keeps a cabled keyboard out of the BlueZ device rows')
assertEqual(
  bluetooth.batteryForAddress(readouts, 'aa:bb:cc:dd:ee:01').percentage,
  39,
  'bluetooth attaches the UPower reading to the connected device'
)
assertDeepEqual(
  bluetooth.deviceRow(trackpad, bluetooth.batteryForAddress(readouts, trackpad.address)),
  { address: 'AA:BB:CC:DD:EE:01', name: 'Magic Trackpad', deviceName: '', connected: true, state: -1, batteryAvailable: true, battery: 0.39, percentage: 39, charge: 'discharging', pairing: false },
  'bluetooth rows take the UPower level and charging state'
)

// A HID supply with no address in its native path cannot be identified as the
// connected keyboard, even when the model and the percentage match.
const keyboardReadouts = bluetooth.batteryReadouts(
  [{ name: 'Magic Keyboard', deviceName: 'Magic Keyboard', address: '11:22:33:44:55:66', connected: true }],
  [
    { type: 6, model: 'Magic Keyboard', percentage: 0.22, state: 0, nativePath: 'hidpp_battery_0' },
    { type: 6, model: 'other', percentage: 0.22, state: 1, nativePath: '/org/bluez/hci0/dev_11_22_33_44_55_66' }
  ]
)
assertDeepEqual(keyboardReadouts.map((entry) => [entry.name, entry.percentage, entry.charge, entry.matched]), [
  ['Magic Keyboard', 22, 'charging', true],
  ['Magic Keyboard', 22, '', false]
], 'bluetooth leaves an address-less HID supply as its own row')

// Quickshell does not expose UPower's Serial. A HID++ supply with no address
// stays separate, and the connected row keeps the BlueZ fallback reading.
const hidppKeyboard = { name: 'MX Keys', address: '11:22:33:44:55:66', connected: true, batteryAvailable: true, battery: 0.4 }
const hidppSupply = { type: 6, model: 'MX Keys', percentage: 0.22, state: 1, nativePath: 'hidpp_battery_0' }
const hidppReadouts = bluetooth.batteryReadouts(
  [hidppKeyboard],
  [hidppSupply]
)
assertDeepEqual(hidppReadouts.map((entry) => [entry.name, entry.percentage, entry.charge, entry.matched]), [
  ['MX Keys', 22, 'charging', false],
  ['MX Keys', 40, '', true]
], 'bluetooth keeps an unidentified HID++ supply separate from the BlueZ fallback')

const hidppTwinReadouts = bluetooth.batteryReadouts(
  [hidppKeyboard],
  [
    { type: 6, model: 'MX Keys', percentage: 0.4, state: 2, nativePath: '/org/bluez/hci0/dev_11_22_33_44_55_66' },
    hidppSupply
  ]
)
assertDeepEqual(hidppTwinReadouts.map((entry) => [entry.percentage, entry.charge, entry.matched]), [
  [22, 'charging', false],
  [40, 'discharging', true]
], 'bluetooth does not fold an unidentified HID++ supply into a matching BlueZ UPower reading')

// Stripping path words down to hex would turn "hid-aa:bb:..." into
// "daabb...", which must not identify a different connected device.
const differentAddressReadouts = bluetooth.batteryReadouts(
  [{ name: 'Keyboard', address: 'DA:AB:BC:CD:DE:EF', connected: true, batteryAvailable: true, battery: 0.4 }],
  [{ type: 6, model: 'Other keyboard', percentage: 0.22, state: 1, nativePath: 'hid-aa:bb:cc:dd:ee:ff-battery' }]
)
assertDeepEqual(differentAddressReadouts.map((entry) => [entry.address, entry.percentage, entry.matched]), [
  ['aabbccddeeff', 22, false],
  ['daabbccddeef', 40, true]
], 'bluetooth matches parsed addresses rather than hex substrings across path boundaries')

// One connected keyboard and a cabled keyboard of the same model at the same
// percentage. The cable path is the USB serial from the live machine, and it
// does not contain the radio address.
const sameModelKeyboards = bluetooth.batteryReadouts(
  [{ name: 'Magic Keyboard', address: '11:22:33:44:55:66', connected: true }],
  [
    { type: 6, model: 'Magic Keyboard', percentage: 0.22, state: 2, nativePath: '/org/bluez/hci0/dev_11_22_33_44_55_66' },
    { type: 6, model: 'Magic Keyboard', percentage: 0.22, state: 1, nativePath: 'hid-F0T5474067XG9KPAV-battery-144' }
  ]
)
assertDeepEqual(sameModelKeyboards.map((entry) => [entry.name, entry.percentage, entry.charge, entry.matched]), [
  ['Magic Keyboard', 22, 'discharging', true],
  ['Magic Keyboard', 22, 'charging', false]
], 'bluetooth keeps a cabled keyboard of the same model and percentage as its own row')

// BlueZ and HID both carry this address. The discharging copy is listed
// first; the charging copy, and its percentage, are the ones that remain.
const chargingCopy = bluetooth.batteryReadouts(
  [{ name: 'Magic Keyboard', address: '11:22:33:44:55:66', connected: true }],
  [
    { type: 6, model: 'Magic Keyboard', percentage: 0.4, state: 2, nativePath: '/org/bluez/hci0/dev_11_22_33_44_55_66' },
    { type: 6, model: 'Magic Keyboard', percentage: 0.22, state: 1, nativePath: 'hid-11:22:33:44:55:66-battery' }
  ]
)
assertEqual(chargingCopy.length, 1, 'bluetooth keeps one row when BlueZ and HID share an address')
assertEqual(chargingCopy[0].charge, 'charging', 'bluetooth prefers charging over a discharging copy of the same address')
assertEqual(chargingCopy[0].percentage, 22, 'bluetooth keeps the percentage from the charging copy')

// Two supplies with the same model and no address must not be pinned onto one
// connected device. An empty battery that says it is discharging still shows.
const ambiguous = bluetooth.batteryReadouts(
  [{ name: 'MX Master', address: '01:02:03:04:05:06', connected: true }],
  [
    { type: 5, model: 'MX Master', percentage: 0.5, state: 2, nativePath: 'hidpp_battery_2' },
    { type: 5, model: 'MX Master', percentage: 0.4, state: 2, nativePath: 'hidpp_battery_3' },
    { type: 6, model: 'Dead', percentage: 0, state: 2, nativePath: 'hidpp_battery_4' }
  ]
)
assertDeepEqual(ambiguous.map((entry) => [entry.name, entry.percentage, entry.matched]), [
  ['Dead', 0, false],
  ['MX Master', 40, false],
  ['MX Master', 50, false]
], 'bluetooth does not guess when two supplies share a name, and keeps an empty discharging battery')

const chargingWord = (key, english) => key === 'power.charging' ? 'Oplader' : english
assertEqual(
  bluetooth.formatBatteryStatus({ percentage: 22, charge: 'charging' }, chargingWord, (n) => String(n)),
  '22% · Oplader',
  'bluetooth battery status uses the charging translation'
)
assertEqual(
  bluetooth.formatBatteryTooltip(readouts, (key, english) => english, (n) => String(n)),
  'Magic Keyboard 22% · Charging\nMagic Trackpad 39%\nWH-1000XM5 80%',
  'bluetooth tooltip names every peripheral battery and only marks charging'
)
assertEqual(
  bluetooth.formatBatteryStatus({ percentage: 39, charge: 'discharging' }, (key, english) => english, (n) => String(n)),
  '39%',
  'bluetooth hides a discharging state'
)
assertEqual(
  bluetooth.formatBatteryStatus({ percentage: 100, charge: 'full' }, (key, english) => english, (n) => String(n)),
  '100%',
  'bluetooth hides a full state'
)

// James's trackpad, from the live machine. UPower's native path is the kernel
// HID supply (lowercase address, report id 144). BlueZ spells the same address
// in uppercase and the alias uses a curly apostrophe, so it is not the UPower
// model name. The keyboard's native path is a serial, not an address, and it
// stays its own row. The trackpad's own row shows 39%, with no discharging word.
const jamesTrackpad = {
  name: 'James Caudill\u2019s Trackpad',
  address: '04:4B:ED:EB:F5:10',
  connected: true,
  batteryAvailable: false
}
const jamesUpower = [
  { type: 14, model: 'Apple Inc. Magic Trackpad', percentage: 0.39, state: 2, nativePath: 'hid-04:4b:ed:eb:f5:10-battery-144', powerSupply: false },
  { type: 6, model: 'Apple Inc. Magic Keyboard', percentage: 0.49, state: 1, nativePath: 'hid-F0T5474067XG9KPAV-battery-144', powerSupply: false }
]
const james = bluetooth.batteryReadouts([jamesTrackpad], jamesUpower)
assertDeepEqual(james.map((entry) => [entry.name, entry.percentage, entry.charge, entry.matched]), [
  ['James Caudill\u2019s Trackpad', 39, 'discharging', true],
  ['Apple Inc. Magic Keyboard', 49, 'charging', false]
], 'bluetooth attaches the hid- trackpad supply to the uppercase BlueZ address')
assertEqual(
  bluetooth.formatBatteryStatus(bluetooth.deviceRow(jamesTrackpad, bluetooth.batteryForAddress(james, jamesTrackpad.address)), (key, english) => english, (n) => String(n)),
  '39%',
  'bluetooth shows the trackpad percentage on its own row without a discharging label'
)
assertEqual(
  bluetooth.formatBatteryTooltip(james, (key, english) => english, (n) => String(n)),
  'James Caudill\u2019s Trackpad 39%\nApple Inc. Magic Keyboard 49% · Charging',
  'bluetooth hover names the trackpad from BlueZ and only marks the keyboard charging'
)
const jamesObjectPath = bluetooth.batteryReadouts([jamesTrackpad], [
  { type: 14, model: 'Apple Inc. Magic Trackpad', percentage: 0.39, state: 2, nativePath: '/org/freedesktop/UPower/devices/touchpad_hid_04o4boedoebof5o10_battery_144', powerSupply: false },
  jamesUpower[1]
])
assertEqual(jamesObjectPath[0].matched, true, 'bluetooth still attaches the trackpad when UPower encoded the colons as o')
assertEqual(jamesObjectPath[0].name, 'James Caudill\u2019s Trackpad', 'bluetooth keeps the BlueZ alias on the object-path match')
assertEqual(jamesObjectPath[1].matched, false, 'bluetooth does not treat the keyboard serial as the trackpad address')

// A vendor-prefixed model is not an identity. With no address in the native
// path, the supply stays its own row instead of attaching to the device.
const productName = bluetooth.batteryReadouts(
  [{ name: 'James Caudill\u2019s Trackpad', deviceName: 'Magic Trackpad', address: '11:22:33:44:55:66', connected: true, batteryAvailable: false }],
  [{ type: 14, model: 'Apple Inc. Magic Trackpad', percentage: 0.39, state: 2, nativePath: 'hidpp_battery_9', powerSupply: false }]
)
assertDeepEqual(productName.map((entry) => [entry.name, entry.percentage, entry.matched]), [
  ['Apple Inc. Magic Trackpad', 39, false]
], 'bluetooth does not attach a supply that shares only a product name')

assertDeepEqual(
  bluetooth.withPendingAction({ a: 'connecting' }, 'b', 'forgetting'),
  { a: 'connecting', b: 'forgetting' },
  'bluetooth adds pending actions immutably'
)
assertDeepEqual(bluetooth.withPendingAction({ a: 'connecting' }, 'a', ''), {}, 'bluetooth clears pending actions immutably')

const bluetoothSink = {
  isSink: true,
  isStream: false,
  ready: true,
  name: 'bluez_output.AA_BB_CC_DD_EE_FF.1',
  properties: {
    'device.product.name': 'JBL Go 3'
  }
}
assert(
  bluetooth.bluetoothSinkMatchesDevice(bluetoothSink, { address: 'AA:BB:CC:DD:EE:FF', name: 'JBL Go 3' }),
  'bluetooth matches audio sinks by device address'
)
assert(
  bluetooth.bluetoothSinkMatchesDevice(
    {
      isSink: true,
      isStream: false,
      ready: true,
      name: 'alsa_output.usb-speaker',
      properties: { 'device.product.name': 'JBL Go 3' }
    },
    { address: '11:22:33:44:55:66', name: 'JBL Go 3' }
  ),
  'bluetooth matches audio sinks by human device label when address is unavailable'
)
assert(
  !bluetooth.bluetoothSinkMatchesDevice({ isSink: false, isStream: false, ready: true, name: 'bluez_output.AA_BB_CC_DD_EE_FF.1', properties: {} }, { address: 'AA:BB:CC:DD:EE:FF', name: 'JBL Go 3' }),
  'bluetooth ignores non-sink nodes when matching audio outputs'
)
JS

# Turning Bluetooth off is an rfkill soft block, not a bluetoothctl power off,
# because only the block survives a reboot. These mocks stand in for that pair:
# rfkill moves the block, and bluetoothd powers the adapter up once it is gone.
device_tmp=$(mktemp -d)
trap 'rm -rf "$device_tmp"' EXIT

mock_bin="$device_tmp/bin"
mkdir -p "$mock_bin"
export POWERED_FILE="$device_tmp/powered"

cat >"$mock_bin/bluetoothctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$BLUETOOTHCTL_LOG"
[[ $1 == "power" && $2 == "on" ]] && echo yes >"$POWERED_FILE"
[[ $1 == "list" ]] &&
  for c in ${MOCK_CONTROLLERS:-AA:BB:CC:DD:EE:FF}; do printf 'Controller %s mock\n' "$c"; done
# Per-controller state where a test set it, the shared file otherwise.
if [[ $1 == "show" ]]; then
  state="$POWERED_FILE"
  [[ -n ${2:-} && -f "$POWERED_FILE.$2" ]] && state="$POWERED_FILE.$2"
  printf '\tPowered: %s\n' "$(cat "$state")"
fi
exit 0
SH

cat >"$mock_bin/rfkill" <<'SH'
#!/bin/bash

printf 'rfkill %s\n' "$*" >>"$BLUETOOTHCTL_LOG"
# Lifting the block is normally all it takes: AutoEnable is left at its default,
# so bluetoothd powers the adapter up on its own. RFKILL_INERT stands in for the
# adapter that was powered down without a block, where it does not.
[[ $1 == "unblock" && -z ${RFKILL_INERT:-} ]] && echo yes >"$POWERED_FILE"
[[ $1 == "block" ]] && echo no >"$POWERED_FILE"
exit 0
SH

chmod +x "$mock_bin/bluetoothctl" "$mock_bin/rfkill"

# $ROOT/bin so omarchy-bluetooth-device resolves the real omarchy-bluetooth-power.
bluetooth_run() {
  local powered="$1"
  shift

  echo "$powered" >"$POWERED_FILE"
  : >"$device_tmp/log"
  PATH="$mock_bin:$ROOT/bin:$PATH" BLUETOOTHCTL_LOG="$device_tmp/log" \
    OMARCHY_BLUETOOTH_POWER_WAIT_SECONDS=0 "$@" ||
    fail "$* exits cleanly with Powered: $powered"
  printf '%s' "$device_tmp/log"
}

bluetooth_power() {
  bluetooth_run "$1" "$ROOT/bin/omarchy-bluetooth-power" "$2"
}

# Off has to be the block. A bluetoothctl power off would read the same until the
# next boot, then quietly come back on.
off_log=$(bluetooth_power yes off)
grep -qx "rfkill block bluetooth" "$off_log" ||
  fail "bluetooth turns off with an rfkill block" "$(cat "$off_log")"
pass "bluetooth turns off with an rfkill block"

grep -q "power off" "$off_log" &&
  fail "bluetooth does not also power the adapter down" "$(cat "$off_log")"
pass "bluetooth does not also power the adapter down"

# Unblocking is enough on its own, so there is nothing left to ask bluetoothctl.
on_log=$(bluetooth_power no on)
grep -qx "rfkill unblock bluetooth" "$on_log" ||
  fail "bluetooth turns on by lifting the block" "$(cat "$on_log")"
pass "bluetooth turns on by lifting the block"

grep -q "power on" "$on_log" &&
  fail "bluetooth leaves the power-on to bluetoothd when the block is lifted" "$(cat "$on_log")"
pass "bluetooth leaves the power-on to bluetoothd when the block is lifted"

# An adapter powered down without a block is one bluetoothd will not pick up.
inert_log=$(RFKILL_INERT=1 bluetooth_power no on)
grep -qx "power on" "$inert_log" ||
  fail "bluetooth powers the adapter on when unblocking does not" "$(cat "$inert_log")"
pass "bluetooth powers the adapter on when unblocking does not"

# The panel switch reads Powered, so that is what toggle has to invert.
toggle_on_log=$(bluetooth_power yes toggle)
grep -qx "rfkill block bluetooth" "$toggle_on_log" ||
  fail "bluetooth toggles a powered adapter off" "$(cat "$toggle_on_log")"
pass "bluetooth toggles a powered adapter off"

toggle_off_log=$(bluetooth_power no toggle)
grep -qx "rfkill unblock bluetooth" "$toggle_off_log" ||
  fail "bluetooth toggles an unpowered adapter on" "$(cat "$toggle_off_log")"
pass "bluetooth toggles an unpowered adapter on"

# The power-on shortcut is the whole point of skipping the stabilization sleep:
# pair/connect from the panel run against an adapter that is already powered.
bluetooth_device_log() {
  bluetooth_run "$1" "$ROOT/bin/omarchy-bluetooth-device" connect AA:BB:CC:DD:EE:FF
}

powered_log=$(bluetooth_device_log yes)
grep -q "rfkill" "$powered_log" &&
  fail "bluetooth skips the power-on delay when the adapter is already powered"
pass "bluetooth skips the power-on delay when the adapter is already powered"

grep -qx "connect AA:BB:CC:DD:EE:FF" "$powered_log" ||
  fail "bluetooth still connects when the adapter is already powered"
pass "bluetooth still connects when the adapter is already powered"

# Connecting to a device while Bluetooth is off has to lift the block first —
# BlueZ refuses to power an adapter up while one is set.
unpowered_log=$(bluetooth_device_log no)
grep -qx "rfkill unblock bluetooth" "$unpowered_log" ||
  fail "bluetooth lifts the block before connecting" "$(cat "$unpowered_log")"
pass "bluetooth lifts the block before connecting"

grep -qx "connect AA:BB:CC:DD:EE:FF" "$unpowered_log" ||
  fail "bluetooth connects once the adapter is up" "$(cat "$unpowered_log")"
pass "bluetooth connects once the adapter is up"

# Blocking hits every radio at once, so the read has to span them too. A bare
# bluetoothctl show reports the default controller and misses a powered dongle.
echo yes >"$POWERED_FILE.11:22:33:44:55:66"
export MOCK_CONTROLLERS="AA:BB:CC:DD:EE:FF 11:22:33:44:55:66"
multi_log=$(bluetooth_power no toggle)
unset MOCK_CONTROLLERS
rm -f "$POWERED_FILE.11:22:33:44:55:66"

grep -qx "rfkill block bluetooth" "$multi_log" ||
  fail "bluetooth counts a secondary controller as on" "$(cat "$multi_log")"
pass "bluetooth counts a secondary controller as on"
