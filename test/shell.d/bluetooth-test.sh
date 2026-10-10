#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -q '^ConditionPathIsDirectory=/sys/class/bluetooth$' "$ROOT/default/systemd/user/bt-agent.service" || \
  fail "bt-agent is skipped on machines without Bluetooth hardware"
pass "bt-agent is skipped on machines without Bluetooth hardware"

files_unit="$ROOT/default/systemd/user/omarchy-bluetooth-files.service"
grep -Fx 'ExecStart=/usr/bin/omarchy-bluetooth-files-agent' "$files_unit" >/dev/null || \
  fail "bluetooth file receiving runs the Object Push agent"
pass "bluetooth file receiving runs the Object Push agent"

grep -q 'bt-obex' "$files_unit" && \
  fail "bluetooth file receiving does not hand pushes to a receiver that auto-accepts them"
pass "bluetooth file receiving does not hand pushes to a receiver that auto-accepts them"

[[ -x $ROOT/bin/omarchy-bluetooth-files-agent ]] || \
  fail "the Object Push agent ships as an executable"
pass "the Object Push agent ships as an executable"

grep -Fx 'ConditionPathIsDirectory=/sys/class/bluetooth' "$files_unit" >/dev/null || \
  fail "bluetooth file receiving is skipped on machines without Bluetooth hardware"
pass "bluetooth file receiving is skipped on machines without Bluetooth hardware"

grep -Fx 'ExecCondition=/usr/bin/systemctl is-active --quiet bluetooth.service' "$files_unit" >/dev/null || \
  fail "bluetooth file receiving is skipped when bluetooth.service is inactive"
pass "bluetooth file receiving is skipped when bluetooth.service is inactive"

grep -qx 'bluez-obex' "$ROOT/install/omarchy-base.packages" || \
  fail "bluez-obex ships with the base package set"
pass "bluez-obex ships with the base package set"

# obexd stores nothing until the agent answers AuthorizePush, so the agent is
# where "paired devices only" and "never over an existing download" have to
# hold. The fakes stand in for obexd's and BlueZ's D-Bus connections; the
# destination logic runs against a real directory.
python3 - "$ROOT" <<'PY'
import importlib.machinery
import importlib.util
import os
import sys
import tempfile

from gi.repository import GLib

root = sys.argv[1]
loader = importlib.machinery.SourceFileLoader("agent", os.path.join(root, "bin/omarchy-bluetooth-files-agent"))
spec = importlib.util.spec_from_loader("agent", loader)
agent = importlib.util.module_from_spec(spec)
loader.exec_module(agent)


def check(condition, description, detail=""):
    if not condition:
        print(f"not ok - {description}" + (f"\n{detail}" if detail else ""), file=sys.stderr)
        sys.exit(1)
    print(f"ok - {description}")


PAIRED = "C0:7A:D6:CB:7C:86"
UNPAIRED = "AA:BB:CC:DD:EE:FF"
TRANSFER = "/org/bluez/obex/session1/transfer1"
SESSION = "/org/bluez/obex/session1"


class FakeConnection:
    """The two calls the agent makes: obexd properties and BlueZ's objects."""

    def __init__(self, objects=None, properties=None):
        self.objects = objects or {}
        self.properties = properties or {}

    def call_sync(self, service, path, interface, method, parameters, *rest):
        if method == "GetManagedObjects":
            return GLib.Variant("(a{oa{sa{sv}}})", (self.objects,))
        if method == "Get":
            interface_name, name = parameters.unpack()
            value = self.properties.get((path, interface_name, name))
            if value is None:
                raise GLib.Error.new_literal(GLib.quark_from_string("omarchy.test"), 0, f"no {name}")
            if not isinstance(value, GLib.Variant):
                value = GLib.Variant("s", value)
            return GLib.Variant("(v)", (value,))
        raise AssertionError(f"unexpected call {service} {path} {interface} {method}")


def properties_for(name, root, destination=PAIRED):
    return {
        (TRANSFER, "org.bluez.obex.Transfer1", "Session"): SESSION,
        (SESSION, "org.bluez.obex.Session1", "Destination"): destination,
        (SESSION, "org.bluez.obex.Session1", "Root"): root,
        (TRANSFER, "org.bluez.obex.Transfer1", "Name"): name,
    }


def objects_for(address, paired):
    return {
        f"/org/bluez/hci0/dev_{address.replace(':', '_')}": {
            "org.bluez.Device1": {"Address": GLib.Variant("s", address), "Paired": GLib.Variant("b", paired)}
        }
    }


with tempfile.TemporaryDirectory() as directory:
    unpaired = agent.Receiver(
        FakeConnection(properties=properties_for("report.pdf", directory, UNPAIRED)),
        FakeConnection(objects=objects_for(UNPAIRED, False)),
        directory,
    )
    check(unpaired.authorize(TRANSFER) is None, "the agent refuses a push from a device BlueZ does not list as paired")
    check(os.listdir(directory) == [], "a refused push leaves the downloads directory alone")

    unknown = agent.Receiver(
        FakeConnection(properties=properties_for("report.pdf", directory, UNPAIRED)),
        FakeConnection(objects=objects_for(PAIRED, True)),
        directory,
    )
    check(unknown.authorize(TRANSFER) is None, "the agent refuses a push whose sender BlueZ does not know at all")
    check(os.listdir(directory) == [], "a push from an unknown device leaves the downloads directory alone")

    nameless = agent.Receiver(
        FakeConnection(properties={}),
        FakeConnection(objects=objects_for(PAIRED, True)),
        directory,
    )
    check(nameless.authorize(TRANSFER) is None, "the agent refuses a transfer that names no file")

    # obexd stores nothing outside its root folder, so a session rooted
    # elsewhere is an obexd the agent did not start.
    foreign = agent.Receiver(
        FakeConnection(properties=properties_for("report.pdf", "/var/cache/obexd")),
        FakeConnection(objects=objects_for(PAIRED, True)),
        directory,
    )
    check(foreign.authorize(TRANSFER) is None, "the agent refuses a push through an obexd rooted somewhere else")
    check(os.listdir(directory) == [], "a push through a foreign obexd leaves the downloads directory alone")

    paired = agent.Receiver(
        FakeConnection(properties=properties_for("report.pdf", directory)),
        FakeConnection(objects=objects_for(PAIRED, True)),
        directory,
    )
    first = paired.authorize(TRANSFER)
    check(first == os.path.join(directory, "report.pdf"), "the agent claims the incoming name for a paired sender", first)
    check(os.path.exists(first), "the claimed name is taken before the transfer starts")
    check((os.stat(first).st_mode & 0o777) == 0o600, "the claim is private to the user")

    with open(first, "w", encoding="utf-8") as existing:
        existing.write("already here")

    second = paired.authorize(TRANSFER)
    check(second == os.path.join(directory, "report (1).pdf"), "a second push of the same name gets the next free name", second)
    check(open(first, encoding="utf-8").read() == "already here", "the push never lands on the existing download")

    third = paired.authorize(TRANSFER)
    check(third == os.path.join(directory, "report (2).pdf"), "further pushes keep counting", third)

    escaped = agent.claim_path(directory, "../escape.pdf")
    check(escaped == os.path.join(directory, "escape.pdf"),
          "a name carrying a path cannot leave the downloads directory")

with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_DOWNLOAD_DIR"] = directory
    check(agent.downloads_dir() == directory, "the agent honours XDG_DOWNLOAD_DIR")
    del os.environ["XDG_DOWNLOAD_DIR"]

config_home = tempfile.mkdtemp()
home = os.path.join(config_home, "home")
os.makedirs(home)
os.environ["HOME"] = home
os.environ["XDG_CONFIG_HOME"] = os.path.join(home, ".config")
os.makedirs(os.environ["XDG_CONFIG_HOME"])
check(agent.downloads_dir() == os.path.join(home, "Downloads"), "the agent falls back to ~/Downloads")
with open(os.path.join(os.environ["XDG_CONFIG_HOME"], "user-dirs.dirs"), "w", encoding="utf-8") as user_dirs:
    user_dirs.write('# XDG user directories\nXDG_DOWNLOAD_DIR="$HOME/Telechargements"\n')
check(agent.downloads_dir() == os.path.join(home, "Telechargements"), "the agent reads the desktop's download directory")
PY

run_node_test <<'JS'
const fs = require('fs')
const bluetooth = requireFromRoot('shell/plugins/panels/bluetooth/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/bluetooth/Panel.qml', 'utf8')

assert(/IpcHandler[\s\S]*?function toggleBluetooth\(\) \{ root\.toggleBluetooth\(\) \}/.test(panelSource), 'bluetooth exposes the radio toggle over IPC')
assert(/manageIpc: false/.test(panelSource), 'bluetooth owns its IPC handler so it can extend the target methods')

// Receiving is the user unit's job, not the panel's: the switch asks the helper
// for a direction and reads the result back off its exit code, so the row can
// never disagree with systemd about whether files are being accepted.
assert(/function toggleFileReceive\(\)[\s\S]*?execDetached\(\["omarchy-bluetooth-files", fileReceiveActive \? "off" : "on"\]\)/.test(panelSource), 'bluetooth toggles file receiving through the unit helper')
assert(/id: fileStateProc[\s\S]*?command: \["omarchy-bluetooth-files", "is-on"\][\s\S]*?onExited: function\(exitCode\) \{\s*root\.fileReceiveActive = exitCode === 0/.test(panelSource), 'bluetooth reads the receiver state from the helper exit code')
assert(/function toggleFiles\(\) \{ root\.toggleFileReceive\(\) \}/.test(panelSource), 'bluetooth exposes the file receiver over IPC')
assert(/return \["files"\]\.concat\(Model\.visibleSections/.test(panelSource), 'bluetooth keeps the file receiver above the device sections')
assert(/if \(section === "files"\) return true/.test(panelSource), 'bluetooth reaches the file receiver with the keyboard cursor')

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

# AutoEnable=false was the old attempt at persistence and never worked. Left set,
# it would also keep bluetoothd from powering the adapter up after an unblock.
grep -q 'AutoEnable=false' "$ROOT/install/hardware/bluetooth.sh" &&
  fail "bluetooth install leaves AutoEnable at its default"
pass "bluetooth install leaves AutoEnable at its default"

# The switch reads the unit back instead of trusting the click, so the helper
# only has to move the unit and report it: `on` and `off` enable or disable it
# (the enable is what brings the receiver up at the next login), `toggle` picks
# the direction from the unit's own state, and `is-on` is the exit code the
# switch paints.
files_tmp=$(mktemp -d)
trap 'rm -rf "$device_tmp" "$files_tmp"' EXIT

mkdir -p "$files_tmp/bin"

cat >"$files_tmp/bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl %s\n' "$*" >>"$SYSTEMCTL_LOG"

# The unit's enabled state is the only thing the helper asks about, and the
# file stands in for it so `toggle` can be driven both ways.
[[ $* == *is-enabled* ]] && exit "$(cat "$SYSTEMCTL_STATE" 2>/dev/null || printf 1)"

exit "${SYSTEMCTL_EXIT:-0}"
SH
chmod +x "$files_tmp/bin/systemctl"

export SYSTEMCTL_LOG="$files_tmp/log"

files_run() {
  : >"$SYSTEMCTL_LOG"
  PATH="$files_tmp/bin:$PATH" SYSTEMCTL_STATE="$files_tmp/enabled" "$ROOT/bin/omarchy-bluetooth-files" "$@"
}

if files_run bogus >/dev/null 2>&1; then
  fail "bluetooth files rejects an unknown direction"
fi
pass "bluetooth files rejects an unknown direction"

printf 1 >"$files_tmp/enabled"
files_run on >/dev/null
grep -qx 'systemctl --user enable --now omarchy-bluetooth-files.service' "$SYSTEMCTL_LOG" ||
  fail "bluetooth files turns receiving on through the unit" "$(cat "$SYSTEMCTL_LOG")"
pass "bluetooth files turns receiving on through the unit"

files_run off >/dev/null
grep -qx 'systemctl --user disable --now omarchy-bluetooth-files.service' "$SYSTEMCTL_LOG" ||
  fail "bluetooth files turns receiving off through the unit" "$(cat "$SYSTEMCTL_LOG")"
pass "bluetooth files turns receiving off through the unit"

files_run toggle >/dev/null
grep -qx 'systemctl --user enable --now omarchy-bluetooth-files.service' "$SYSTEMCTL_LOG" ||
  fail "bluetooth files toggles a disabled receiver on" "$(cat "$SYSTEMCTL_LOG")"
pass "bluetooth files toggles a disabled receiver on"

printf 0 >"$files_tmp/enabled"
files_run toggle >/dev/null
grep -qx 'systemctl --user disable --now omarchy-bluetooth-files.service' "$SYSTEMCTL_LOG" ||
  fail "bluetooth files toggles an enabled receiver off" "$(cat "$SYSTEMCTL_LOG")"
pass "bluetooth files toggles an enabled receiver off"

files_run is-on >/dev/null
grep -qx 'systemctl --user is-active --quiet omarchy-bluetooth-files.service' "$SYSTEMCTL_LOG" ||
  fail "bluetooth files reads the receiver state from the unit" "$(cat "$SYSTEMCTL_LOG")"
pass "bluetooth files reads the receiver state from the unit"

if SYSTEMCTL_EXIT=3 files_run is-on >/dev/null 2>&1; then
  fail "bluetooth files reports a stopped receiver as off"
fi
pass "bluetooth files reports a stopped receiver as off"
