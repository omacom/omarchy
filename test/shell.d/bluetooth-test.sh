#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -Fx 'ExecStart=/usr/bin/omarchy-bluetooth-agent' "$ROOT/default/systemd/user/bt-agent.service" >/dev/null || \
  fail "bt-agent runs the Omarchy agent that accepts RequestAuthorization"
grep -q 'bt-agent -c' "$ROOT/default/systemd/user/bt-agent.service" && \
  fail "bt-agent must not use bluez-tools bt-agent (it rejects RequestAuthorization)"
[[ -x $ROOT/bin/omarchy-bluetooth-agent ]] || fail "omarchy-bluetooth-agent is executable"
grep -q 'RequestAuthorization' "$ROOT/bin/omarchy-bluetooth-agent" || \
  fail "omarchy-bluetooth-agent implements RequestAuthorization"
python3 - "$ROOT/bin/omarchy-bluetooth-agent" <<'PY'
import ast, sys
path = sys.argv[1]
tree = ast.parse(open(path, encoding="utf-8").read())
keep = {"adapters_from_pairing_marker", "read_pairing_marker", "pairing_marker_path"}
mod = ast.Module([node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name in keep], [])
ns = {"os": __import__("os")}
exec(compile(mod, path, "exec"), ns)
adapter = "/org/bluez/hci0"
other = "/org/bluez/hci1"
objects = {
    adapter: {"org.bluez.Adapter1": {"Pairable": True}},
    other: {"org.bluez.Adapter1": {"Pairable": True}},
}
renewed = ns["adapters_from_pairing_marker"](objects, adapter + "\n")
assert renewed == {adapter}, renewed
default_only = ns["adapters_from_pairing_marker"](objects, "")
assert default_only == set(), default_only
closed = ns["adapters_from_pairing_marker"](
    {adapter: {"org.bluez.Adapter1": {"Pairable": False}}},
    adapter + "\n",
)
assert closed == set(), closed
print("ok - a restarted agent renews only an open panel adapter")
print("ok - bluez pairable defaults are not a pairing window")
print("ok - a closed window stays closed after restart")
PY

run_node_test <<'JS'
const bluetooth = requireFromRoot('shell/plugins/panels/bluetooth/Model.js')

assert(bluetooth.keepPairable(true, false) === true, 'an open panel keeps the adapter pairable')
assert(bluetooth.keepPairable(false, true) === true, 'an open sibling keeps the adapter pairable')
assert(bluetooth.keepPairable(false, false) === false, 'a closed panel clears pairable')
assertEqual(
  bluetooth.pairingMarkerText(true, false, '/org/bluez/hci0'),
  '/org/bluez/hci0\n',
  'an open panel records its adapter for the agent restart'
)
assertEqual(bluetooth.pairingMarkerText(false, false, '/org/bluez/hci0'), '', 'a closed panel clears the restart marker')
assertEqual(bluetooth.pairingMarkerText(true, false, ''), '', 'an open panel without an adapter path does not invent consent')
assertEqual(bluetooth.connectAction({ connected: false, paired: true }), 'connect', 'bluetooth connects a paired device')
assertEqual(bluetooth.connectAction({ connected: false, bonded: true }), 'connect', 'bluetooth connects a bonded device')
assertEqual(bluetooth.connectAction({ connected: false, trusted: true }), 'pair', 'bluetooth pairs a device that is only trusted')
assertEqual(bluetooth.connectAction({ connected: true, paired: false }), '', 'bluetooth leaves an already connected device alone')

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
# The bond is what pair waits on and trust follows; MOCK_BONDED stands in for it.
[[ $1 == "info" ]] && printf '\tBonded: %s\n' "${MOCK_BONDED:-no}"
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

# omarchy-bluetooth-power / -device wrap bluetoothctl in `timeout`. macOS has no
# GNU timeout; a passthrough stub keeps the suite hermetic on every platform.
if ! command -v timeout >/dev/null 2>&1; then
  cat >"$mock_bin/timeout" <<'SH'
#!/bin/bash
shift
exec "$@"
SH
  chmod +x "$mock_bin/timeout"
fi

# $ROOT/bin so omarchy-bluetooth-device resolves the real omarchy-bluetooth-power.
bluetooth_run() {
  local powered="$1"
  shift

  echo "$powered" >"$POWERED_FILE"
  : >"$device_tmp/log"
  PATH="$mock_bin:$ROOT/bin:$PATH" BLUETOOTHCTL_LOG="$device_tmp/log" \
    OMARCHY_BLUETOOTH_POWER_WAIT_SECONDS=0 OMARCHY_BLUETOOTH_BOND_WAIT_SECONDS=0 "$@" ||
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

# Trust without a bond leaves BlueZ reconnecting a device that can never finish
# pairing. pair/connect must wait for Bonded before trusting.
pair_log=$(bluetooth_run yes "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF)
grep -q "^trust " "$pair_log" &&
  fail "bluetooth does not trust a device that never bonded" "$(cat "$pair_log")"
pass "bluetooth does not trust a device that never bonded"

awk '/^connect AA:BB:CC:DD:EE:FF$/ { connected = 1 }
     /^info AA:BB:CC:DD:EE:FF$/ && connected { ok = 1 }
     END { exit ok ? 0 : 1 }' "$pair_log" ||
  fail "bluetooth checks for the bond after connecting" "$(cat "$pair_log")"
pass "bluetooth checks for the bond after connecting"

bonded_pair_log=$(MOCK_BONDED=yes bluetooth_run yes "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF)
awk '/^info AA:BB:CC:DD:EE:FF$/ { seen = 1 }
     /^trust AA:BB:CC:DD:EE:FF$/ && !done { ok = seen; done = 1 }
     END { exit ok ? 0 : 1 }' "$bonded_pair_log" ||
  fail "bluetooth trusts a device once it reports a bond" "$(cat "$bonded_pair_log")"
pass "bluetooth trusts a device once it reports a bond"

connect_log=$(bluetooth_device_log yes)
grep -q "^trust " "$connect_log" &&
  fail "bluetooth does not trust an unbonded device on connect" "$(cat "$connect_log")"
pass "bluetooth does not trust an unbonded device on connect"

bonded_connect_log=$(MOCK_BONDED=yes bluetooth_device_log yes)
grep -qx "trust AA:BB:CC:DD:EE:FF" "$bonded_connect_log" ||
  fail "bluetooth trusts a bonded device on connect" "$(cat "$bonded_connect_log")"
pass "bluetooth trusts a bonded device on connect"

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
