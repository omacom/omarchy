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
exit 0
SH

cat >"$mock_bin/rfkill" <<'SH'
#!/bin/bash

printf 'rfkill %s\n' "$*" >>"$BLUETOOTHCTL_LOG"
if [[ $* == *"list bluetooth"* ]]; then
  [[ -n ${RFKILL_LIST:-} ]] && printf '%s\n' "$RFKILL_LIST"
  exit 0
fi
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

# On laptops with a platform ACPI switch (e.g. ThinkPad's tpacpi_bluetooth_sw),
# off must block only the hci* switches so the platform switch does not cut USB
# power and detach the adapter from BlueZ.
platform_off_log=$(RFKILL_LIST=$'0 tpacpi_bluetooth_sw\n5 hci0\n6 hci1' bluetooth_power yes off)
grep -qx "rfkill block 5 6" "$platform_off_log" ||
  fail "bluetooth blocks only hci* rfkill switches when present" "$(cat "$platform_off_log")"
grep -qx "rfkill block bluetooth" "$platform_off_log" &&
  fail "bluetooth does not block platform ACPI rfkill switches" "$(cat "$platform_off_log")"
pass "bluetooth blocks only hci* rfkill switches and leaves platform switches alone"

platform_on_log=$(RFKILL_LIST=$'0 tpacpi_bluetooth_sw\n5 hci0' bluetooth_power no on)
grep -qx "rfkill unblock bluetooth" "$platform_on_log" ||
  fail "bluetooth still unblocks all bluetooth rfkill switches on power-on" "$(cat "$platform_on_log")"
pass "bluetooth unblocks all bluetooth rfkill switches on power-on"

# CLI tests for `omarchy-bluetooth` (`omarchy bluetooth ...`).
cli_tmp=$(mktemp -d)
trap 'rm -rf "$device_tmp" "$cli_tmp"' EXIT

mkdir -p "$cli_tmp/bin" "$cli_tmp/state"
BT_STATE_DIR="$cli_tmp/state"
printf 'yes\n' >"$BT_STATE_DIR/powered"
printf 'yes\n' >"$BT_STATE_DIR/airpods_connected"
printf 'no\n' >"$BT_STATE_DIR/mouse_connected"
printf 'no\n' >"$BT_STATE_DIR/speaker_paired"
printf 'no\n' >"$BT_STATE_DIR/speaker_connected"
printf 'no\n' >"$BT_STATE_DIR/speaker_trusted"
printf 'yes\n' >"$BT_STATE_DIR/mouse_present"
: >"$BT_STATE_DIR/bt.log"

cat >"$cli_tmp/bin/bluetoothctl" <<'PY'
#!/usr/bin/python3
import os
import sys

state = os.environ["TEST_STATE_DIR"]
args = sys.argv[1:]

with open(os.path.join(state, "bt.log"), "a", encoding="utf-8") as log:
    log.write("bluetoothctl " + " ".join(args) + "\n")

def read_s(name, default=""):
    try:
        return open(os.path.join(state, name), encoding="utf-8").read().strip()
    except OSError:
        return default

def write_s(name, value):
    with open(os.path.join(state, name), "w", encoding="utf-8") as fh:
        fh.write(value + "\n")

cmd = []
i = 0
while i < len(args):
    if args[i] == "--timeout":
        i += 2
    else:
        cmd.append(args[i])
        i += 1

if cmd == ["list"]:
    if os.environ.get("TEST_NO_CTRL") != "1":
        print("Controller 50:2E:66:58:2A:60 dhh-bc [default]")
    raise SystemExit(0)

if cmd[:1] == ["show"]:
    powered = read_s("powered", "yes")
    print("Controller 50:2E:66:58:2A:60 (public)")
    print("\tName: dhh-bc")
    print("\tAlias: dhh-bc")
    print(f"\tPowered: {powered}")
    print("\tDiscoverable: no")
    print("\tPairable: yes")
    print("\tDiscovering: no")
    raise SystemExit(0)

if cmd[:1] == ["power"] and len(cmd) >= 2:
    write_s("powered", "yes" if cmd[1] == "on" else "no")
    raise SystemExit(0)

if cmd[:1] == ["devices"]:
    filt = cmd[1] if len(cmd) >= 2 else ""
    if not filt or (filt == "Connected" and read_s("airpods_connected", "yes") == "yes") or filt in ("Paired", "Trusted"):
        print("Device AA:BB:CC:DD:EE:01 AirPods Pro")
    if read_s("mouse_present", "yes") == "yes":
        if not filt or (filt == "Connected" and read_s("mouse_connected", "no") == "yes") or filt in ("Paired", "Trusted"):
            print("Device AA:BB:CC:DD:EE:02 MX Master 3S")
    if (
        not filt
        or (filt == "Connected" and read_s("speaker_connected", "no") == "yes")
        or (filt == "Paired" and read_s("speaker_paired", "no") == "yes")
        or (filt == "Trusted" and read_s("speaker_trusted", "no") == "yes")
    ):
        print("Device AA:BB:CC:DD:EE:03 JBL Go 3")
    if not filt:
        print("Device AA:BB:CC:DD:EE:04 AA-BB-CC-DD-EE-04")
    raise SystemExit(0)

if cmd[:1] == ["info"] and len(cmd) >= 2:
    mac = cmd[1].upper()
    if mac == "AA:BB:CC:DD:EE:01":
        print("Device AA:BB:CC:DD:EE:01 (public)")
        print("\tName: AirPods Pro")
        print("\tAlias: AirPods Pro")
        print("\tIcon: audio-headset")
        print("\tPaired: yes")
        print("\tBonded: yes")
        print("\tTrusted: yes")
        print("\tBlocked: no")
        print(f"\tConnected: {read_s('airpods_connected', 'yes')}")
        print("\tRSSI: 0xffffffc6 (-58)")
        print("\tBattery Percentage: 0x55 (85)")
        print("\tUUID: Audio Sink (0000110b-0000-1000-8000-00805f9b34fb)")
        print("\tUUID: Handsfree (0000111e-0000-1000-8000-00805f9b34fb)")
        raise SystemExit(0)
    if mac == "AA:BB:CC:DD:EE:02" and read_s("mouse_present", "yes") == "yes":
        print("Device AA:BB:CC:DD:EE:02 (random)")
        print("\tName: MX Master 3S")
        print("\tAlias: MX Master 3S")
        print("\tIcon: input-mouse")
        print("\tPaired: yes")
        print("\tTrusted: yes")
        print(f"\tConnected: {read_s('mouse_connected', 'no')}")
        raise SystemExit(0)
    if mac == "AA:BB:CC:DD:EE:03":
        print("Device AA:BB:CC:DD:EE:03 (public)")
        print("\tName: JBL Go 3")
        print("\tAlias: JBL Go 3")
        print("\tIcon: audio-card")
        print(f"\tPaired: {read_s('speaker_paired', 'no')}")
        print(f"\tTrusted: {read_s('speaker_trusted', 'no')}")
        print(f"\tConnected: {read_s('speaker_connected', 'no')}")
        raise SystemExit(0)
    if mac == "AA:BB:CC:DD:EE:04":
        print("Device AA:BB:CC:DD:EE:04 (random)")
        print("\tAlias: AA-BB-CC-DD-EE-04")
        print("\tPaired: no")
        print("\tTrusted: no")
        print("\tConnected: no")
        raise SystemExit(0)
    print(f"Device {mac} not available")
    raise SystemExit(1)

if cmd[:2] == ["scan", "on"]:
    if os.environ.get("TEST_FAIL_SCAN") == "1":
        print("Failed to start discovery: org.bluez.Error.NotReady")
        raise SystemExit(1)
    print("Discovery started")
    raise SystemExit(0)

if cmd[:1] == ["pair"] and len(cmd) >= 2:
    if cmd[1].upper() == "AA:BB:CC:DD:EE:03":
        write_s("speaker_paired", "yes")
    raise SystemExit(0)

if cmd[:1] == ["trust"] and len(cmd) >= 2:
    if os.environ.get("TEST_FAIL_TRUST") == "1":
        print("Failed to set trust: org.bluez.Error.Failed")
        raise SystemExit(1)
    if cmd[1].upper() == "AA:BB:CC:DD:EE:03":
        write_s("speaker_trusted", "yes")
    raise SystemExit(0)

if cmd[:1] == ["untrust"] and len(cmd) >= 2:
    if cmd[1].upper() == "AA:BB:CC:DD:EE:03":
        write_s("speaker_trusted", "no")
    raise SystemExit(0)

if cmd[:1] == ["connect"] and len(cmd) >= 2:
    if os.environ.get("TEST_TIMEOUT_CONNECT") == "1":
        raise SystemExit(0)
    if os.environ.get("TEST_FAIL_CONNECT") == "1":
        print("Failed to connect: org.bluez.Error.Failed br-connection-page-timeout")
        raise SystemExit(1)
    mac = cmd[1].upper()
    if mac == "AA:BB:CC:DD:EE:01":
        write_s("airpods_connected", "yes")
    elif mac == "AA:BB:CC:DD:EE:02":
        write_s("mouse_connected", "yes")
    elif mac == "AA:BB:CC:DD:EE:03":
        write_s("speaker_connected", "yes")
    raise SystemExit(0)

if cmd[:1] == ["disconnect"] and len(cmd) >= 2:
    mac = cmd[1].upper()
    if mac == "AA:BB:CC:DD:EE:01":
        write_s("airpods_connected", "no")
    elif mac == "AA:BB:CC:DD:EE:02":
        write_s("mouse_connected", "no")
    elif mac == "AA:BB:CC:DD:EE:03":
        write_s("speaker_connected", "no")
    raise SystemExit(0)

if cmd[:1] == ["remove"] and len(cmd) >= 2:
    if cmd[1].upper() == "AA:BB:CC:DD:EE:02":
        write_s("mouse_present", "no")
    raise SystemExit(0)

raise SystemExit(0)
PY

cat >"$cli_tmp/bin/rfkill" <<'SH'
#!/bin/bash
printf 'rfkill %s\n' "$*" >>"$TEST_STATE_DIR/bt.log"
[[ $1 == "block" ]] && printf 'no\n' >"$TEST_STATE_DIR/powered"
[[ $1 == "unblock" ]] && printf 'yes\n' >"$TEST_STATE_DIR/powered"
exit 0
SH

chmod +x "$cli_tmp/bin/bluetoothctl" "$cli_tmp/bin/rfkill"

bt_cli() {
  PATH="$cli_tmp/bin:$ROOT/bin:$PATH" TEST_STATE_DIR="$BT_STATE_DIR" \
    OMARCHY_BLUETOOTH_POWER_WAIT_SECONDS=0 "$ROOT/bin/omarchy-bluetooth" "$@"
}

out=$(bt_cli status --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["available"] is True and d["powered"] is True and d["power"] == "on", d
assert d["controller"]["address"] == "50:2E:66:58:2A:60", d
assert len(d["connected"]) == 1, d
c = d["connected"][0]
assert c["label"] == "AirPods Pro" and c["battery"] == 85 and c["rssi"] == -58, c
PY
pass "bluetooth CLI status --json reports controller, power, and connected device battery/RSSI"

out=$(bt_cli list --json)
python3 - "$out" <<'PY'
import json, sys
devs = json.loads(sys.argv[1])
assert [d["label"] for d in devs] == ["AirPods Pro", "MX Master 3S", "JBL Go 3"], devs
PY
out=$(bt_cli list --all --json)
python3 - "$out" <<'PY'
import json, sys
devs = json.loads(sys.argv[1])
assert len(devs) == 4 and any(d["address"] == "AA:BB:CC:DD:EE:04" for d in devs), devs
PY
out=$(bt_cli list --connected --json)
python3 - "$out" <<'PY'
import json, sys
assert [d["label"] for d in json.loads(sys.argv[1])] == ["AirPods Pro"]
PY
out=$(bt_cli list --paired --json)
python3 - "$out" <<'PY'
import json, sys
assert [d["label"] for d in json.loads(sys.argv[1])] == ["AirPods Pro", "MX Master 3S"]
PY
pass "bluetooth CLI list sorts devices, hides unnamed BLE beacons by default, and filters"

out=$(bt_cli info "airpods pro" --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["address"] == "AA:BB:CC:DD:EE:01" and d["profiles"] == ["Audio Sink", "Handsfree"], d
PY
out=$(bt_cli info "aa-bb-cc-dd-ee-01" --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["label"] == "AirPods Pro"
PY
pass "bluetooth CLI info resolves devices by name or hyphen/colon MAC address"

for blank in "" "   "; do
  status=0
  bt_cli forget "$blank" >/dev/null 2>&1 || status=$?
  (( status == 2 )) || fail "blank device name should exit 2" "got $status"
done
pass "bluetooth CLI rejects blank device names before matching"

status=0
TEST_FAIL_TRUST=1 bt_cli pair "JBL Go 3" >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "pair should fail when trust fails" "got $status"
pass "bluetooth CLI pair surfaces trust failures"

: >"$BT_STATE_DIR/bt.log"
out=$(bt_cli pair "JBL Go 3" --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["paired"] is True and d["trusted"] is True and d["connected"] is True, d
PY
grep -q "bluetoothctl trust AA:BB:CC:DD:EE:03" "$BT_STATE_DIR/bt.log" || fail "pair trusts device"
grep -q "bluetoothctl --timeout 20 connect AA:BB:CC:DD:EE:03" "$BT_STATE_DIR/bt.log" || fail "pair connects device"
pass "bluetooth CLI pair pairs, trusts, and connects a device resolved by name"

out=$(bt_cli untrust "JBL Go 3" --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["trusted"] is False
PY
out=$(bt_cli disconnect "AirPods Pro" --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["connected"] is False
PY
out=$(bt_cli forget "MX Master 3S" --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["forgotten"]["address"] == "AA:BB:CC:DD:EE:02"
PY
pass "bluetooth CLI untrust, disconnect, and forget work by device name"

status=0
TEST_FAIL_CONNECT=1 bt_cli connect "AirPods Pro" >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "failed bluetooth connect should exit 1" "got $status"
status=0
TEST_TIMEOUT_CONNECT=1 bt_cli connect "AirPods Pro" >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "bluetooth connect must fail when bluetoothctl --timeout exits 0 without connecting" "got $status"
status=0
TEST_NO_CTRL=1 bt_cli scan --timeout 1 >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "bluetooth scan without an adapter should fail clearly" "got $status"
pass "bluetooth CLI connect reports failures, silent timeouts, and missing adapters"

status=0
TEST_FAIL_SCAN=1 bt_cli scan --timeout 1 >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "failed bluetooth scan should exit 1" "got $status"
pass "bluetooth CLI scan reports discovery failures"

: >"$BT_STATE_DIR/bt.log"
out=$(bt_cli off --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["powered"] is False
PY
grep -qx "rfkill block bluetooth" "$BT_STATE_DIR/bt.log" || fail "bluetooth off uses rfkill via omarchy-bluetooth-power"

: >"$BT_STATE_DIR/bt.log"
out=$(bt_cli scan --timeout 1 --json)
grep -qx "rfkill unblock bluetooth" "$BT_STATE_DIR/bt.log" || fail "bluetooth scan powers adapter on via rfkill unblock"
grep -q "bluetoothctl --timeout 1 scan on" "$BT_STATE_DIR/bt.log" || fail "bluetooth scan passes --timeout to bluetoothctl"
pass "bluetooth CLI off/on/toggle uses rfkill persistence and scan auto-powers adapter on"

status=0
bt_cli scan --timeout 0 >/dev/null 2>&1 || status=$?
(( status == 2 )) || fail "invalid --timeout should exit 2" "got $status"
pass "bluetooth CLI scan rejects out-of-range --timeout with exit 2"
