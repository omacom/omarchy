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

// The pairing agent auto-accepts, so pairing must only be possible while a
// panel is open or a pairing this machine started is under way. BlueZ leaves
// adapters pairable by default and nothing else in Omarchy writes the
// property, so the panel owns it through PairableGate; the gate's behavior is
// covered at runtime by bluetooth-pairable-gate-test.sh.
const gateSource = fs.readFileSync(root + '/shell/plugins/panels/bluetooth/PairableGate.qml', 'utf8')
const gateUse = panelSource.match(/PairableGate \{[\s\S]*?\n {2}\}/)
assert(gateUse, 'bluetooth panel owns the adapter pairable state through PairableGate')
assert(/Instantiator \{\s*model: Bluetooth\.adapters \? Bluetooth\.adapters\.values : \[\]\s*delegate: PairableGate \{/.test(panelSource), 'bluetooth gates every controller, not only the default adapter')
assert(/adapter: root\.bar \? modelData : null/.test(gateUse[0]), 'bluetooth hands a gate its adapter only once the bar can list sibling widgets')
assert(/open: root\.pairingHeld/.test(gateUse[0]), 'bluetooth holds pairing while the panel is open or a pairing is held over IPC')
assert(/readonly property bool pairingHeld: !destroying && \(opened \|\| Commons\.BluetoothPairing\.holds > 0\)/.test(panelSource), 'bluetooth counts an open panel and the shared IPC holds alike, and drops both while being torn down')
assert(/siblingOpen: function\(\) \{ return root\.heldSibling\(\) !== null \}/.test(gateUse[0]), 'bluetooth leaves pairing on for a sibling instance that holds it')
assert(/function heldSibling\(\)[\s\S]*?items\[i\]\.pairingHeld === true/.test(panelSource), 'bluetooth sibling check reads the same hold the gate does')
assert(/ShellIpc \{[\s\S]*?function holdPairing\(\): string \{ return Commons\.BluetoothPairing\.hold\(\) \}[\s\S]*?function releasePairing\(token: string\): string \{ return Commons\.BluetoothPairing\.release\(token\) \}/.test(panelSource), 'bluetooth exposes the shared pairing hold over IPC for omarchy-bluetooth-device, released by token')
const pairingSource = fs.readFileSync(root + '/shell/Commons/BluetoothPairing.qml', 'utf8')
assert(/^pragma Singleton/m.test(pairingSource) && /singleton BluetoothPairing 1\.0 BluetoothPairing\.qml/.test(fs.readFileSync(root + '/shell/Commons/qmldir', 'utf8')), 'the pairing holds live in a singleton that outlives any widget instance')
assert(/readonly property int holds: tokens\.length/.test(pairingSource) && /function release\(token\) \{\s*var index = tokens\.indexOf\(String\(token \|\| ""\)\)\s*if \(index === -1\) return "unknown"/.test(pairingSource), 'each pairing hold is a token, so a command releases only the hold it took')
assert(/Timer \{[\s\S]*?onTriggered: root\.tokens = \[\]/.test(pairingSource), 'pairing holds that are never released expire')
assert(!/adapter\.pairable = /.test(panelSource), 'bluetooth panel writes pairable only through the gate')
assert(/Component\.onDestruction: \{[\s\S]{0,200}pairable = false/.test(gateSource), 'a destroyed gate turns pairing off when no sibling holds it')

const agentService = fs.readFileSync(root + '/default/systemd/user/bt-agent.service', 'utf8')
assert(!/only `pairable: true` when the user/.test(agentService), 'bt-agent no longer claims a pairable gate that did not exist')
assert(/refuses bonding while it is off/.test(agentService), 'bt-agent documents the panel-owned pairable window')
assert(/with it removed from\s*#? ?the bar, or the shell not running/.test(agentService), 'bt-agent documents that the gate lives in the bar widget')

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
export PAIRABLE_FILE="$device_tmp/pairable"

cat >"$mock_bin/bluetoothctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$BLUETOOTHCTL_LOG"
[[ $1 == "power" && $2 == "on" ]] && echo yes >"$POWERED_FILE"
# bluetoothctl takes on/off and reports yes/no.
[[ $1 == "pairable" && $2 == "on" ]] && echo yes >"$PAIRABLE_FILE"
[[ $1 == "pairable" && $2 == "off" ]] && echo no >"$PAIRABLE_FILE"
[[ $1 == "pair" && -n ${MOCK_PAIR_DELAY:-} ]] && sleep "$MOCK_PAIR_DELAY"
[[ $1 == "list" ]] &&
  for c in ${MOCK_CONTROLLERS:-AA:BB:CC:DD:EE:FF}; do printf 'Controller %s mock\n' "$c"; done
# Per-controller state where a test set it, the shared file otherwise.
if [[ $1 == "show" ]]; then
  state="$POWERED_FILE"
  [[ -n ${2:-} && -f "$POWERED_FILE.$2" ]] && state="$POWERED_FILE.$2"
  printf '\tPowered: %s\n' "$(cat "$state")"
  printf '\tPairable: %s\n' "$(cat "$PAIRABLE_FILE" 2>/dev/null || echo yes)"
fi
exit 0
SH

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

[[ $1 == "-q" ]] && shift
printf 'omarchy-shell %s\n' "$*" >>"$BLUETOOTHCTL_LOG"
[[ -n ${SHELL_RUNNING:-} ]] || exit 1
if [[ $* == "omarchy.bluetooth holdPairing" ]]; then
  echo 0123456789abcdef0123456789abcdef
else
  echo ok
fi
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

chmod +x "$mock_bin/bluetoothctl" "$mock_bin/rfkill" "$mock_bin/omarchy-shell"

# $ROOT/bin so omarchy-bluetooth-device resolves the real omarchy-bluetooth-power.
bluetooth_run() {
  local powered="$1"
  shift

  echo "$powered" >"$POWERED_FILE"
  : >"$device_tmp/log"
  PATH="$mock_bin:$ROOT/bin:$PATH" BLUETOOTHCTL_LOG="$device_tmp/log" XDG_RUNTIME_DIR="$device_tmp" \
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

# The shell owns the adapter's pairable state, so a pairing this command runs
# asks the shell to hold it for the duration, from the panel or the command
# line alike, and the property itself is left to the shell.
echo no >"$PAIRABLE_FILE"
pair_log=$(SHELL_RUNNING=1 bluetooth_run yes "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF)
pair_order=$(grep -xE 'omarchy-shell omarchy.bluetooth (holdPairing|releasePairing 0123456789abcdef0123456789abcdef)|pair AA:BB:CC:DD:EE:FF|connect AA:BB:CC:DD:EE:FF' "$pair_log" | paste -sd,)
[[ $pair_order == "omarchy-shell omarchy.bluetooth holdPairing,pair AA:BB:CC:DD:EE:FF,connect AA:BB:CC:DD:EE:FF,omarchy-shell omarchy.bluetooth releasePairing 0123456789abcdef0123456789abcdef" ]] ||
  fail "bluetooth asks the shell to hold pairing around its own pairing and releases that hold by its token" "$(cat "$pair_log")"
pass "bluetooth asks the shell to hold pairing around its own pairing and releases that hold by its token"

grep -q "^pairable" "$pair_log" &&
  fail "bluetooth leaves the pairable property to a running shell" "$(cat "$pair_log")"
pass "bluetooth leaves the pairable property to a running shell"

# Without a shell (a TTY or ssh session) nothing else owns the property, so the
# command sets it for the pairing and puts it back afterwards. A Low Energy
# device pairs without bonding otherwise.
echo no >"$PAIRABLE_FILE"
tty_log=$(bluetooth_run yes "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF)
tty_order=$(grep -xE 'pairable on|pair AA:BB:CC:DD:EE:FF|connect AA:BB:CC:DD:EE:FF|pairable off' "$tty_log" | paste -sd,)
[[ $tty_order == "pairable on,pair AA:BB:CC:DD:EE:FF,connect AA:BB:CC:DD:EE:FF,pairable off" ]] ||
  fail "bluetooth turns pairable on for its own pairing without a shell and back off after" "$(cat "$tty_log")"
pass "bluetooth turns pairable on for its own pairing without a shell and back off after"

# A hold request that got no token has nothing to release; a blind release
# could take another pairing's hold, so the shell's expiry covers that case.
grep -q "releasePairing" "$tty_log" &&
  fail "bluetooth does not release a hold it has no token for" "$(cat "$tty_log")"
pass "bluetooth does not release a hold it has no token for"

# An adapter already pairable without a shell was made so by hand; leave it.
echo yes >"$PAIRABLE_FILE"
pairable_log=$(bluetooth_run yes "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF)
grep -q "^pairable" "$pairable_log" &&
  fail "bluetooth leaves an already pairable adapter as it found it" "$(cat "$pairable_log")"
pass "bluetooth leaves an already pairable adapter as it found it"

# Two pairings at once without a shell share the property through a lock: the
# first to find it off turns it on and leaves a marker, and only the last one
# out turns it back off, so neither can take bonding away from the other.
echo no >"$PAIRABLE_FILE"
echo yes >"$POWERED_FILE"
: >"$device_tmp/log"
(
  export PATH="$mock_bin:$ROOT/bin:$PATH" BLUETOOTHCTL_LOG="$device_tmp/log" XDG_RUNTIME_DIR="$device_tmp" OMARCHY_BLUETOOTH_POWER_WAIT_SECONDS=0
  MOCK_PAIR_DELAY=1 "$ROOT/bin/omarchy-bluetooth-device" pair AA:BB:CC:DD:EE:FF &
  sleep 0.3
  MOCK_PAIR_DELAY=0 "$ROOT/bin/omarchy-bluetooth-device" pair 11:22:33:44:55:66
  wait
)
concurrent_log="$device_tmp/log"
(( $(grep -cx "pairable on" "$concurrent_log") == 1 )) ||
  fail "bluetooth turns pairable on once for two overlapping pairings" "$(cat "$concurrent_log")"
pass "bluetooth turns pairable on once for two overlapping pairings"
(( $(grep -cx "pairable off" "$concurrent_log") == 1 )) && [[ $(grep -xE 'connect .*|pairable off' "$concurrent_log" | tail -n 1) == "pairable off" ]] ||
  fail "bluetooth turns pairable off only after the last overlapping pairing" "$(cat "$concurrent_log")"
pass "bluetooth turns pairable off only after the last overlapping pairing"
[[ ! -e $device_tmp/omarchy-bluetooth-pairable.restore ]] ||
  fail "bluetooth clears its restore marker once pairing is back off"
pass "bluetooth clears its restore marker once pairing is back off"

echo no >"$PAIRABLE_FILE"
connect_log=$(bluetooth_run yes "$ROOT/bin/omarchy-bluetooth-device" connect AA:BB:CC:DD:EE:FF)
grep -q "^pairable\|holdPairing" "$connect_log" &&
  fail "bluetooth does not make the adapter pairable to connect a known device" "$(cat "$connect_log")"
pass "bluetooth does not make the adapter pairable to connect a known device"
echo yes >"$PAIRABLE_FILE"

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
