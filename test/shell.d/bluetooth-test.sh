#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -q '^ConditionPathIsDirectory=/sys/class/bluetooth$' "$ROOT/default/systemd/user/bt-agent.service" || \
  fail "bt-agent is skipped on machines without Bluetooth hardware"
pass "bt-agent is skipped on machines without Bluetooth hardware"

run_node_test <<'JS'
const fs = require('fs')
const bluetooth = requireFromRoot('shell/plugins/panels/bluetooth/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/bluetooth/Panel.qml', 'utf8')

assert(/IpcHandler[\s\S]*?function toggleBluetooth\(\) \{ root\.toggleBluetooth\(\) \}/.test(panelSource), 'bluetooth exposes the radio toggle over IPC')
assert(/manageIpc: false/.test(panelSource), 'bluetooth owns its IPC handler so it can extend the target methods')

// Writing adapter.enabled sets BlueZ Powered, which does not survive a reboot.
assert(/function toggleBluetooth\(\)[\s\S]*?execDetached\(\["omarchy-bluetooth-power", adapter\.enabled \? "off" : "on"\]\)/.test(panelSource), 'bluetooth toggles the radio through the rfkill soft block')
assert(!/adapter\.enabled = /.test(panelSource), 'bluetooth never writes the adapter power state directly')

// Discovery is a BlueZ session that nothing ends at panel close: it persists
// until StopDiscovery or until quickshell's D-Bus connection drops with the
// shell, and a leaked session keeps the radio in inquiry, starving A2DP audio
// on the same controller. The panel tracks the stop it owes and settles it
// once closed.
const retryTimer = panelSource.match(/id: discoveryRetry[\s\S]*?onTriggered: \{[\s\S]*?\n {4}\}/)
assert(retryTimer, 'bluetooth has the discovery retry timer')
assert(/owesDiscoveryStop = true/.test(retryTimer[0]), 'bluetooth takes on the stop it owes when it starts discovery')

// Quickshell only forwards a discovering write that differs from BlueZ's last
// confirmed state, so a stop written in the same instant as an in-flight
// StartDiscovery would be swallowed. Binding the stop timer to the confirmed
// state means a confirmation landing at any point after close re-arms it.
const stopTimer = panelSource.match(/id: discoveryStop[\s\S]*?onTriggered: \{[\s\S]*?\n {4}\}/)
assert(stopTimer, 'bluetooth has the discovery stop timer')
assert(/running: !root\.opened && root\.owesDiscoveryStop[\s\S]*discovering === true/.test(stopTimer[0]), 'bluetooth arms the stop off the confirmed discovery state while closed')
assert(/discovering = false/.test(stopTimer[0]), 'bluetooth stops discovery after the panel closes')

// One widget instance exists per monitor and they share the default adapter,
// so a closing instance hands the scan to a panel still open on another
// monitor instead of stopping it — that is the popout handoff between
// monitors.
assert(/function openSibling\(\)/.test(panelSource), 'bluetooth can see panel instances on other monitors')
assert(/sibling\.owesDiscoveryStop = true/.test(stopTimer[0]), 'bluetooth moves the stop it owes to an open panel on another monitor instead of stopping its scan')

// The debt clears when BlueZ confirms discovery down, and a destroyed
// instance hands it to a surviving sibling instead of taking it to the grave.
assert(/onDiscoveringChanged[\s\S]{0,120}owesDiscoveryStop = false/.test(panelSource), 'bluetooth settles the stop it owes once discovery is confirmed down')
assert(/Component\.onDestruction: \{[\s\S]{0,400}owesDiscoveryStop = true[\s\S]{0,200}discovering = false/.test(panelSource), 'bluetooth passes the stop it owes to a sibling when an instance is destroyed')

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
  { address: '1', name: 'Deadbeef', deviceName: '', connected: false, state: -1, batteryAvailable: false, battery: 0, pairing: false },
  'bluetooth projects device rows with primitives only'
)
assertEqual(
  bluetooth.deviceLabel(bluetooth.deviceRow({ name: 'Generic', deviceName: 'MX Master 3S', address: '2', connected: true })),
  'MX Master 3S',
  'bluetooth keeps deviceName in row projections so labels survive QObject-free rows'
)

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
export BONDED_FILE="$device_tmp/bonded"

cat >"$mock_bin/bluetoothctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$BLUETOOTHCTL_LOG"
# MOCK_INFO_FAIL_AT=N fails the Nth lookup silently; MOCK_INFO=down fails every
# lookup; MOCK_INFO=missing reports an uncached device until it is paired.
if [[ $1 == "info" ]]; then
  [[ $(grep -c '^info ' "$BLUETOOTHCTL_LOG") == "${MOCK_INFO_FAIL_AT:-0}" ]] && exit 1
  if [[ ${MOCK_INFO:-} == "down" ]]; then
    echo "DeviceSet $2 not available"
    exit 1
  fi
  if [[ ${MOCK_INFO:-} == "missing" ]] && ! grep -q '^pair ' "$BLUETOOTHCTL_LOG"; then
    echo "Device $2 not available"
    exit 1
  fi
fi
if [[ $1 == "info" ]]; then
  printf '\tName: %s\n\tPaired: %s\n\tBonded: %s\n\tTrusted: yes\n\tConnected: yes\n' "${MOCK_NAME:-Mouse}" "${MOCK_PAIRED:-yes}" "$(cat "$BONDED_FILE")"
fi
[[ $1 == "untrust" && ${MOCK_UNTRUST_FAIL:-0} == "1" ]] && exit 1
[[ $1 == "pair" && ${MOCK_PAIR_FAIL:-0} == 1 ]] && exit 1
[[ $1 == "disconnect" && ${MOCK_DISCONNECT_FAIL:-0} == 1 ]] && exit 1
[[ $1 == "pair" && ${MOCK_SAVE_BOND:-1} == 1 ]] && echo yes >"$BONDED_FILE"
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

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl %s\n' "$*" >>"$BLUETOOTHCTL_LOG"
exit "${MOCK_AGENT_STATUS:-0}"
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

chmod +x "$mock_bin/bluetoothctl" "$mock_bin/rfkill" "$mock_bin/systemctl"

# $ROOT/bin so omarchy-bluetooth-device resolves the real omarchy-bluetooth-power.
bluetooth_run() {
  local powered="$1"
  shift

  echo "$powered" >"$POWERED_FILE"
  echo "${MOCK_BONDED:-yes}" >"$BONDED_FILE"
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

grep -Eq '^(pair |systemctl )' "$unpowered_log" &&
  fail "bluetooth leaves paired devices and the agent alone when reconnecting"
pass "bluetooth leaves paired devices and the agent alone when reconnecting"

bonded_pair_log=$(bluetooth_run yes "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF)
grep -qx 'connect AA:BB:CC:DD:EE:FF' "$bonded_pair_log" ||
  fail "bluetooth pair reconnects an already bonded device"
grep -Eq '^(pair |systemctl |untrust |disconnect )' "$bonded_pair_log" &&
  fail "bluetooth pair preserves an existing bond" "$(cat "$bonded_pair_log")"
pass "bluetooth pair preserves an existing bond"

repair_log=$(MOCK_PAIRED=no MOCK_BONDED=no bluetooth_device_log yes)
expected_repair=$(printf '%s\n' \
  'show' \
  'info AA:BB:CC:DD:EE:FF' \
  'systemctl --user start bt-agent.service' \
  'untrust AA:BB:CC:DD:EE:FF' \
  'pair AA:BB:CC:DD:EE:FF' \
  'info AA:BB:CC:DD:EE:FF' \
  'trust AA:BB:CC:DD:EE:FF' \
  'connect AA:BB:CC:DD:EE:FF')
[[ $(cat "$repair_log") == "$expected_repair" ]] ||
  fail "bluetooth pairs trusted devices without keys before connecting" "$(cat "$repair_log")"
pass "bluetooth pairs trusted devices without keys before connecting"

# BlueZ fails untrust and info for a device it has not cached yet. Neither may
# stop a fresh pairing, even with the adapter starting down.
fresh_pair_log=$(MOCK_UNTRUST_FAIL=1 MOCK_INFO=missing MOCK_BONDED=no bluetooth_run no "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF)
for step in 'rfkill unblock bluetooth' 'pair AA:BB:CC:DD:EE:FF' 'connect AA:BB:CC:DD:EE:FF'; do
  grep -qx "$step" "$fresh_pair_log" ||
    fail "bluetooth pairs a new device despite failed info and untrust: missing '$step'" "$(cat "$fresh_pair_log")"
done
pass "bluetooth pairs a new device despite failed info and untrust"

# A transient lookup failure is retried, so it routes by the real bond state.
flaky_log=$(MOCK_INFO_FAIL_AT=1 MOCK_BONDED=yes bluetooth_device_log yes)
grep -Eq '^(untrust |pair )' "$flaky_log" &&
  fail "bluetooth keeps a bond through a transient lookup failure" "$(cat "$flaky_log")"
grep -qx 'connect AA:BB:CC:DD:EE:FF' "$flaky_log" ||
  fail "bluetooth connects through a transient lookup failure" "$(cat "$flaky_log")"
pass "bluetooth keeps a bond through a transient lookup failure"

flaky_unbonded_log=$(MOCK_INFO_FAIL_AT=1 MOCK_BONDED=no bluetooth_device_log yes)
grep -qx 'pair AA:BB:CC:DD:EE:FF' "$flaky_unbonded_log" ||
  fail "bluetooth still pairs a trusted unbonded device after a transient lookup failure" "$(cat "$flaky_unbonded_log")"
pass "bluetooth still pairs a trusted unbonded device after a transient lookup failure"

# A successful pair must survive one failed verification lookup.
flaky_verify_log=$(MOCK_INFO_FAIL_AT=2 MOCK_BONDED=no bluetooth_device_log yes)
grep -qx 'connect AA:BB:CC:DD:EE:FF' "$flaky_verify_log" ||
  fail "bluetooth connects after a transient verification failure" "$(cat "$flaky_verify_log")"
pass "bluetooth connects after a transient verification failure"

# State that stays unreadable must change nothing, for either request.
for action in connect pair; do
  : >"$device_tmp/log"
  echo yes >"$BONDED_FILE"
  if env PATH="$mock_bin:$ROOT/bin:$PATH" BLUETOOTHCTL_LOG="$device_tmp/log" MOCK_INFO=down \
    "$ROOT/bin/omarchy-bluetooth-device" $action AA:BB:CC:DD:EE:FF 2>/dev/null; then
    fail "bluetooth $action reports unreadable device state"
  fi
  grep -Eq '^(untrust |pair |trust |connect )' "$device_tmp/log" &&
    fail "bluetooth $action changes nothing when device state is unreadable" "$(cat "$device_tmp/log")"
  (( $(grep -c '^info ' "$device_tmp/log") == 3 )) ||
    fail "bluetooth $action retries an unreadable lookup" "$(cat "$device_tmp/log")"
  pass "bluetooth $action changes nothing when device state is unreadable"
done

# A stale disconnect result must not prevent a fresh pairing request.
temporary_log=$(MOCK_PAIRED=yes MOCK_BONDED=no MOCK_DISCONNECT_FAIL=1 bluetooth_device_log yes)
expected_temporary=${expected_repair/'pair AA:BB:CC:DD:EE:FF'/$'disconnect AA:BB:CC:DD:EE:FF\npair AA:BB:CC:DD:EE:FF'}
[[ $(cat "$temporary_log") == "$expected_temporary" ]] ||
  fail "bluetooth replaces temporary pairing with a saved bond" "$(cat "$temporary_log")"
pass "bluetooth replaces temporary pairing with a saved bond"

# A failed pair must not create a trusted record that subsequent clicks connect.
for setting in MOCK_PAIR_FAIL=1 MOCK_AGENT_STATUS=1 MOCK_SAVE_BOND=0; do
  : >"$device_tmp/log"
  echo no >"$BONDED_FILE"
  if env PATH="$mock_bin:$ROOT/bin:$PATH" BLUETOOTHCTL_LOG="$device_tmp/log" \
    MOCK_NAME='Bonded: yes' "$setting" \
    "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF; then
    fail "bluetooth reports failure with $setting"
  fi
  grep -Eq '^(trust |connect )' "$device_tmp/log" &&
    fail "bluetooth does not trust or connect with $setting" "$(cat "$device_tmp/log")"
  pass "bluetooth does not trust or connect with $setting"
done

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

# AutoEnable=false was the old attempt at persistence and never worked. Left set,
# it would also keep bluetoothd from powering the adapter up after an unblock.
grep -q 'AutoEnable=false' "$ROOT/install/hardware/bluetooth.sh" &&
  fail "bluetooth install leaves AutoEnable at its default"
pass "bluetooth install leaves AutoEnable at its default"
