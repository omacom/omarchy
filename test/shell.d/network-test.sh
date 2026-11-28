#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')

// scannerEnabled lives on a shared WifiDevice with no reference counting, so
// the panel has to own what it enabled. Run the helper's own JavaScript against
// stand-in devices: the two invariants it carries are that a closed panel never
// takes a device, and that adopting a new one releases the previous.
const scannerHelper = panelSource.match(/function setScannerEnabled\(enabled\) \{[\s\S]*?\n {2}\}/)
assert(scannerHelper, 'network has a scanner ownership helper')

var opened = false
var wifiDevice = { scannerEnabled: false }
var scannerDevice = null
eval(scannerHelper[0])

setScannerEnabled(true)
assert(
  scannerDevice === null && wifiDevice.scannerEnabled === false,
  'network does not let a closed panel claim or enable a scanner device'
)

var previousScannerDevice = { scannerEnabled: true }
var replacementScannerDevice = { scannerEnabled: false }
opened = true
scannerDevice = previousScannerDevice
wifiDevice = replacementScannerDevice
setScannerEnabled(true)
assert(
  previousScannerDevice.scannerEnabled === false &&
    scannerDevice === replacementScannerDevice &&
    replacementScannerDevice.scannerEnabled === true,
  'network releases the previous scanner device before enabling its replacement'
)

// Redundant writes to scannerEnabled must be skipped so opening when already
// false (or reopening while still true) does not hit NetworkManager's D-Bus.
var scannerWrites = 0
var trackedState = false
var trackedDevice = {
  get scannerEnabled() { return trackedState },
  set scannerEnabled(v) { scannerWrites++; trackedState = v }
}
opened = true
scannerDevice = null
wifiDevice = trackedDevice
setScannerEnabled(false)
assertEqual(scannerWrites, 0, 'network skips redundant scannerEnabled=false write')
setScannerEnabled(true)
setScannerEnabled(true)
assertEqual(scannerWrites, 1, 'network skips redundant scannerEnabled=true write')

// A deferred release on a closed panel must not disable the shared scanner
// while another monitor's network panel is open; when no peer is open, it
// releases the scanner.
const peerHelper = panelSource.match(/function otherPanelOpen\(\) \{[\s\S]*?\n {2}\}/)
const releaseHelper = panelSource.match(/function releaseScanner\(\) \{[\s\S]*?\n {2}\}/)
assert(peerHelper && releaseHelper, 'network has peer-aware scanner release helpers')
const peerTest = new Function(
  'trackedDevice',
  'scannerHelper',
  'peerHelper',
  'releaseHelper',
  `
  var moduleName = 'omarchy.network'
  var opened = false
  var wifiDevice = trackedDevice
  var scannerDevice = trackedDevice
  var root = {}
  var peerPanel = { opened: true }
  var bar = { moduleWidgets: () => [root, peerPanel] }
  eval(scannerHelper + '\\n' + peerHelper + '\\n' + releaseHelper)
  releaseScanner()
  const peerKept = trackedDevice.scannerEnabled === true && scannerDevice === null
  peerPanel.opened = false
  scannerDevice = trackedDevice
  releaseScanner()
  const soloReleased = trackedDevice.scannerEnabled === false && scannerDevice === null
  return { peerKept, soloReleased }
  `
)(trackedDevice, scannerHelper[0], peerHelper[0], releaseHelper[0])
assert(peerTest.peerKept, 'deferred release on a closed panel does not stop a peer panel scan')
assert(peerTest.soloReleased, 'deferred release stops the scanner when no peer panel is open')

assertDeepEqual(
  network.parseNetworkStatus('wifi\tCafe WiFi\t78\t5200\n'),
  { kind: 'wifi', label: 'Cafe WiFi', signalStrength: 78, frequency: '5200' },
  'network parses bar status'
)
assertEqual(network.connectionIcon('wifi', 80), network.wifiIconFor(80), 'network maps wifi icon from signal')

// NetworkManager's two dBm-to-strength formulas (scan results, and the
// connected access point's station refresh) must not change the bars for the
// same link, and a strong -50 dBm link shows full bars either way.
const scanStrength = dbm => Math.round(100 - (Math.abs(Math.min(Math.max(dbm, -100), -40) + 40) * 100) / 60)
const stationStrength = dbm => Math.min(Math.max(dbm, -90), -20) + 120
for (const dbm of [-44, -50, -56, -66, -70, -74, -82, -88]) {
  assertEqual(network.wifiIconFor(stationStrength(dbm)), network.wifiIconFor(scanStrength(dbm)), `network shows the same bars for ${dbm} dBm from either NetworkManager formula`)
}
assertEqual(network.wifiIconFor(stationStrength(-50)), network.wifiIconFor(100), 'network shows full bars for a -50 dBm link')

// OWE transition mode: between scans NetworkManager files the in-use access
// point under the hidden "_owetm_" SSID and drops the active profile from the
// device's AvailableConnections, so Quickshell lists no connected network. The
// bar trusts the device's own state and reads the in-use AP's strength instead
// of flickering to disconnected.
assertEqual(network.connectedSignalStrength(0.8, 40), 80, 'network prefers the connected network strength')
assertEqual(network.connectedSignalStrength(0, 67), 67, 'network falls back to the in-use access point strength')
assertEqual(network.connectedSignalStrength(0, -1), 0, 'network reports no strength when the in-use access point is unknown')
assertEqual(network.parseActiveApSignal(' :82\n*:67\n :50\n'), 67, 'network parses the in-use access point strength from nmcli')
assertEqual(network.parseActiveApSignal(' :82\n'), -1, 'network reports no in-use access point when none is marked')
assertEqual(network.parseActiveApSignal(''), -1, 'network tolerates empty nmcli output')
assertEqual(network.formatHeaderSpeed('1000'), '1gbit', 'network formats gigabit speed')
assertEqual(network.formatHeaderSpeed('2500'), '2.5gbit', 'network formats fractional gigabit speed')
assertEqual(network.formatHeaderFreq('2462'), '2.4ghz', 'network formats 2.4GHz wifi band')
assertEqual(network.formatHeaderFreq('5200'), '5ghz', 'network formats 5GHz wifi band')
assertEqual(network.formatHeaderFreq('6455.0'), '6ghz', 'network formats 6GHz wifi band')
assertEqual(network.formatHeaderFreq('18300'), '18.3ghz', 'network falls back to exact GHz for unknown bands')
assertEqual(network.headerDetail({ type: 'ethernet', speed: '100' }), '100mbit', 'network header uses ethernet speed')

assertDeepEqual(
  network.parseKeyValue('iface\twlan0\nrx_bytes\t100\ntx_bytes\t50\n'),
  { iface: 'wlan0', rx_bytes: '100', tx_bytes: '50' },
  'network parses detail key values'
)
assertEqual(network.decodeIwSsid('Cafe\\xe2\\x80\\x99'), 'Cafe’', 'network decodes UTF-8 SSID bytes')
assertEqual(network.decodeIwSsid('Smile \\xf0\\x9f\\x98\\x80'), 'Smile 😀', 'network decodes emoji SSID bytes')
assertEqual(network.decodeIwSsid('\\x20Cafe\\x20'), ' Cafe ', 'network preserves edge spaces in SSIDs')
assertEqual(network.decodeIwSsid('slash\\x5cname'), 'slash\\name', 'network decodes SSID backslashes once')
assertEqual(network.decodeIwSsid('invalid\\xff'), 'invalid\\xff', 'network preserves invalid UTF-8 escapes')
assertEqual(network.decodeIwSsid('already 😀'), 'already 😀', 'network safely preserves unexpected non-BMP input')
assertDeepEqual(
  network.parseKeyValue('ssid\tline\\x0abreak\\x09tab\\x00nul\nsignal_dbm\t-40\n'),
  { ssid: 'line\\x0abreak\\x09tab\\x00nul', signal_dbm: '-40' },
  'network leaves control-byte escapes safe for single-line display'
)
assertDeepEqual(
  network.throughputState({ prevIface: '', prevSampleTime: 0 }, { iface: 'wlan0', rx_bytes: '100', tx_bytes: '50' }, 10),
  { prevIface: 'wlan0', prevRxBytes: 100, prevTxBytes: 50, prevSampleTime: 10, downloadRate: 0, uploadRate: 0 },
  'network seeds throughput state on first sample'
)
assertDeepEqual(
  network.throughputState({ prevIface: 'wlan0', prevRxBytes: 100, prevTxBytes: 50, prevSampleTime: 10 }, { iface: 'wlan0', rx_bytes: '300', tx_bytes: '90' }, 12),
  { prevIface: 'wlan0', prevRxBytes: 300, prevTxBytes: 90, prevSampleTime: 12, downloadRate: 100, uploadRate: 20 },
  'network computes throughput deltas'
)

let ping = network.pingLatencyState(
  { pingIface: '', routerPingSamples: [], internetPingSamples: [] },
  { iface: 'wlan0', router_ping_ms: '2.0', internet_ping_ms: '20.0' },
  4
)
assertDeepEqual(
  ping,
  { pingIface: 'wlan0', routerPingSamples: [2], internetPingSamples: [20], routerPingLatency: 2, internetPingLatency: 20, internetPingPacketLoss: 0 },
  'network seeds ping latency samples'
)

ping = network.pingLatencyState(ping, { iface: 'wlan0', router_ping_ms: '4.0', internet_ping_ms: '' }, 4)
assertDeepEqual(
  ping,
  { pingIface: 'wlan0', routerPingSamples: [2, 4], internetPingSamples: [20, null], routerPingLatency: 3, internetPingLatency: 20, internetPingPacketLoss: 50 },
  'network averages recent successful ping samples'
)

assertDeepEqual(
  network.pingLatencyState(ping, { iface: 'eth0', router_ping_ms: '1.5', internet_ping_ms: '10.0' }, 4),
  { pingIface: 'eth0', routerPingSamples: [1.5], internetPingSamples: [10], routerPingLatency: 1.5, internetPingLatency: 10, internetPingPacketLoss: 0 },
  'network resets ping samples when interface changes'
)

assertDeepEqual(
  network.pingLatencyState(ping, { iface: 'wlan0', internet_ping_ms: '22.0' }, 4),
  { pingIface: 'wlan0', routerPingSamples: [], internetPingSamples: [20, null, 22], routerPingLatency: -1, internetPingLatency: 21, internetPingPacketLoss: 33 },
  'network clears ping samples when a target is unavailable'
)

assertEqual(network.formatBytes(1536), '1.5 KB', 'network formats bytes')
assertEqual(network.formatRate(1536), '1.5 KB/s', 'network formats rates')
assertEqual(network.formatPingLatency('2.54'), '2.5 ms', 'network formats low ping with precision')
assertEqual(network.formatPingLatency('25.4'), '25 ms', 'network formats ping')
assertEqual(network.formatPingLatency(''), 'Timeout', 'network formats missing ping as timeout')
assertEqual(network.formatPingLatency(-1, false), '--', 'network holds the ping row before the first sample')
assertEqual(network.formatPingLatency('25.4', true), '25 ms', 'network formats ping once samples exist')
assertEqual(network.formatPingLatency('', true), 'Timeout', 'network still reports a timeout among real samples')
assertEqual(network.formatPacketLoss(2), '2%', 'network formats packet loss')
assertEqual(network.formatPacketLoss(0), '0%', 'network formats zero packet loss')
assertEqual(network.formatPacketLoss(0, false), '--', 'network holds the packet loss row before the first sample')
assertEqual(network.formatPacketLoss(0, true), '0%', 'network reports zero loss once samples exist')
assertEqual(network.internetPingReadable([], 'full'), false, 'network hides ping before the first sample')
assertEqual(network.internetPingReadable([null, null], 'full'), true, 'network still reports lost probes on a working connection')
assertEqual(network.internetPingReadable([null, 12], 'full'), true, 'network shows ping once a probe comes back')
assertEqual(network.internetPingReadable([12], 'portal'), false, 'network hides ping behind a captive portal')
assertEqual(network.internetPingReadable([12], 'limited'), false, 'network hides ping on a limited connection')
assertEqual(network.internetPingReadable([12], 'none'), false, 'network hides ping when offline')
assertEqual(network.internetPingReadable([12], 'unknown'), true, 'network shows ping when connectivity checks are off')

const rows = network.sortWifiRows([
  { ssid: 'Open', connected: false, known: false, signal: 95 },
  { ssid: 'Known', connected: false, known: true, signal: 10 },
  { ssid: 'Connected', connected: true, known: true, signal: 20 }
])
assertDeepEqual(rows.map(row => row.ssid), ['Connected', 'Known', 'Open'], 'network sorts wifi rows by connection and known state')
assertDeepEqual(
  network.sortWifiRows([
    { ssid: 'Fresh', connected: false, known: false, signal: 99 },
    { ssid: 'Weak', connected: false, known: false, signal: 90 },
    { ssid: 'Strong', connected: false, known: false, signal: 10 },
    { ssid: 'Known', connected: false, known: true, signal: 5 }
  ], [
    { ssid: 'Known', connected: false, known: true, signal: 5 },
    { ssid: 'Strong', connected: false, known: false, signal: 80 },
    { ssid: 'Gone', connected: false, known: false, signal: 70 },
    { ssid: 'Weak', connected: false, known: false, signal: 30 }
  ]).map(row => row.ssid + ':' + row.signal),
  ['Known:5', 'Strong:80', 'Weak:30', 'Fresh:99'],
  'network holds the wifi rows on screen in place, with their signal, while a passphrase prompt is open'
)
assertDeepEqual(
  network.sortWifiRows([
    { ssid: 'hasOwnProperty', connected: false, known: false, signal: 10 },
    { ssid: 'Other', connected: false, known: false, signal: 90 }
  ], [
    { ssid: 'hasOwnProperty', connected: false, known: false, signal: 50 }
  ]).map(row => row.ssid),
  ['hasOwnProperty', 'Other'],
  'network holds wifi rows whatever their SSID, even one named like an Object method'
)
assertEqual(network.wifiSectionTitle(rows, 0), 'KNOWN NETWORKS', 'network labels known wifi section')
assertEqual(network.wifiSectionTitle(rows, 2), 'OTHER NETWORKS', 'network labels other wifi section')

const wifiRow = network.wifiRow({ connected: true, known: true, name: 'Home', signalStrength: 0.8, security: 1 })
assertDeepEqual(
  wifiRow,
  { connected: true, known: true, ssid: 'Home', signal: 80, security: 1 },
  'network projects wifi rows with primitives so delegates never hold the live WifiNetwork object'
)
assertDeepEqual(
  Object.keys(wifiRow).sort(),
  ['connected', 'known', 'security', 'signal', 'ssid'],
  'network wifi rows project exactly the primitive fields, so each delegate stores no live QObject'
)

const security = {
  Wpa3SuiteB192: 0,
  Sae: 1,
  Wpa2Eap: 2,
  Wpa2Psk: 3,
  WpaEap: 4,
  WpaPsk: 5,
  StaticWep: 6,
  DynamicWep: 7,
  Leap: 8,
  Owe: 9,
  Open: 10,
  Unknown: 11
}
for (const name of ['Wpa3SuiteB192', 'Sae', 'Wpa2Eap', 'Wpa2Psk', 'WpaEap', 'WpaPsk', 'StaticWep', 'DynamicWep', 'Leap', 'Unknown']) {
  assertEqual(network.requiresCredentials(security[name], security.Open, security.Owe), true, 'network asks for ' + name + ' credentials')
}
assertEqual(network.requiresCredentials(security.Owe, security.Open, security.Owe), false, 'network does not ask for OWE credentials')
assertEqual(network.requiresCredentials(security.Open, security.Open, security.Owe), false, 'network does not ask for open-network credentials')

const reasons = { NoSecrets: 1, WifiAuthTimeout: 2, WifiNetworkLost: 3, WifiClientDisconnected: 4, WifiClientFailed: 5 }
assertEqual(network.networkFailureReason(reasons.NoSecrets, true, reasons), 'Passphrase required', 'network maps missing credential failures')
assertEqual(network.networkFailureReason(reasons.WifiAuthTimeout, true, reasons), 'Wrong password', 'network maps credentialed auth timeouts')
assertEqual(network.networkFailureReason(reasons.NoSecrets, false, reasons), 'Failed to connect', 'network gives passwordless missing-secret failures generic copy')
assertEqual(network.networkFailureReason(reasons.WifiAuthTimeout, false, reasons), 'Failed to connect', 'network gives passwordless auth timeouts generic copy')
assertEqual(network.networkFailureReason(99, true, reasons), 'Failed to connect', 'network maps unknown failures')

assertEqual(network.canForgetNetwork({ known: true, connected: false, security: security.Owe }), true, 'network can forget known disconnected OWE networks')
assertEqual(network.canForgetNetwork({ known: true, connected: false, security: security.Open }), true, 'network can forget known disconnected open networks')
assertEqual(network.canForgetNetwork({ known: false, connected: false, security: security.Owe }), false, 'network cannot forget unknown networks')
assertEqual(network.canForgetNetwork({ known: true, connected: true, security: security.Owe }), false, 'network cannot forget the connected network')

assertEqual(network.shouldRepromptPassphrase(reasons.NoSecrets, true, reasons), true, 'network reprompts when required credentials are missing')
assertEqual(network.shouldRepromptPassphrase(reasons.NoSecrets, false, reasons), false, 'network does not ask a passwordless network for missing secrets')
assertEqual(network.shouldRepromptPassphrase(reasons.WifiAuthTimeout, true, reasons), true, 'network reprompts a credentialed network after a wrong password')
assertEqual(network.shouldRepromptPassphrase(reasons.WifiAuthTimeout, false, reasons), false, 'network does not reprompt an open network on auth timeout')
assertEqual(network.shouldRepromptPassphrase(reasons.WifiClientFailed, true, reasons), false, 'network does not reprompt on generic connection failures')

assertEqual(network.bandLabel('2.4'), '2.4ghz', 'network labels the 2.4GHz band')
assertEqual(network.bandLabel('6'), '6ghz', 'network labels the 6GHz band')
assertEqual(network.bandLabel('auto'), 'Auto', 'network labels the automatic band choice')

assertEqual(network.bandSectionTitle('auto', '2.4'), 'WI-FI BAND: 2.4GHZ', 'network names the live band in the header under automatic')
assertEqual(network.bandSectionTitle('auto', ''), 'WI-FI BAND', 'network omits an unknown band from the header')
assertEqual(network.bandSectionTitle('5', '5'), 'WI-FI BAND', 'network drops the header band once the pills are showing')
assertEqual(network.bandSectionTitle('5', '2.4'), 'WI-FI BAND', 'network keeps a plain header while a pin is settling')

assertDeepEqual(
  network.parseBandStatus('band\t5\navailable\t2.4 5 6\nselected\tauto\n'),
  { band: '5', selected: 'auto', available: ['2.4', '5', '6'] },
  'network parses band status'
)
assertDeepEqual(
  network.parseBandStatus(''),
  { band: '', selected: 'auto', available: [] },
  'network parses empty band status without a wifi connection'
)

assertEqual(network.headerDetail({ type: 'wifi', freq: '5745' }), '', 'network keeps wifi band state out of the hero')
assertEqual(network.headerDetail({ type: 'ethernet', speed: '100' }), '100mbit', 'network keeps ethernet speed in the hero')
JS

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/nmcli"
cat >"$tmpdir/bin/rfkill" <<'SH'
#!/bin/bash
if [[ $* == *"--output HARD"* ]]; then
  [[ $LC_ALL == "C" ]] || exit 2
  printf '%s\n' "$HARD_BLOCKS"
fi
SH
chmod +x "$tmpdir/bin/"*
PATH="$tmpdir/bin:$PATH" HARD_BLOCKS=unblocked "$ROOT/bin/omarchy-restart-wifi" >"$tmpdir/output" 2>&1 ||
  fail "Wi-Fi restart accepts radios without a hard block" "$(cat "$tmpdir/output")"
status=0
PATH="$tmpdir/bin:$PATH" HARD_BLOCKS=$'unblocked\nblocked' "$ROOT/bin/omarchy-restart-wifi" >"$tmpdir/output" 2>&1 || status=$?
(( status == 1 )) && grep -q "still hardware-blocked" "$tmpdir/output" ||
  fail "Wi-Fi restart reports a remaining hardware block" "status=$status: $(cat "$tmpdir/output")"
pass "Wi-Fi restart distinguishes unblocked and hardware-blocked radios"

# CLI tests for `omarchy-network-wifi` and `omarchy-network-ethernet`.
cli_tmp=$(mktemp -d)
trap 'rm -rf "$tmpdir" "$cli_tmp"' EXIT

mkdir -p "$cli_tmp/bin" "$cli_tmp/sys/eth0" "$cli_tmp/sys/eth1"
printf '1\n' >"$cli_tmp/sys/eth0/carrier"
printf '2500\n' >"$cli_tmp/sys/eth0/speed"
printf 'full\n' >"$cli_tmp/sys/eth0/duplex"
printf '0\n' >"$cli_tmp/sys/eth1/carrier"
printf '%s\n' '-1' >"$cli_tmp/sys/eth1/speed"
printf 'unknown\n' >"$cli_tmp/sys/eth1/duplex"

NET_STATE_DIR="$cli_tmp/state"
mkdir -p "$NET_STATE_DIR"
printf 'enabled\n' >"$NET_STATE_DIR/radio"
printf 'connected\n' >"$NET_STATE_DIR/wifi_state"
printf 'Quattro\n' >"$NET_STATE_DIR/wifi_conn"
printf 'auto\n' >"$NET_STATE_DIR/eth0_method"
printf '10.0.0.10/24\n' >"$NET_STATE_DIR/eth0_ip"
printf '10.0.0.1\n' >"$NET_STATE_DIR/eth0_gw"
printf '1.1.1.1\n' >"$NET_STATE_DIR/eth0_dns"
printf 'connected\n' >"$NET_STATE_DIR/eth0_state"
: >"$NET_STATE_DIR/nmcli.log"
: >"$NET_STATE_DIR/nmcli_stdin.log"

cat >"$cli_tmp/bin/nmcli" <<'PY'
#!/usr/bin/python3
import os
import sys

state = os.environ["TEST_STATE_DIR"]
args = sys.argv[1:]

with open(os.path.join(state, "nmcli.log"), "a", encoding="utf-8") as log:
    log.write(" ".join(args) + "\n")

if os.environ.get("TEST_NM_DOWN") == "1":
    sys.stderr.write("Error: NetworkManager is not running.\n")
    raise SystemExit(8)

def read_s(name, default=""):
    try:
        return open(os.path.join(state, name), encoding="utf-8").read().strip()
    except OSError:
        return default

def write_s(name, value):
    with open(os.path.join(state, name), "w", encoding="utf-8") as fh:
        fh.write(value + "\n")

escape_off = False
stripped = []
i = 0
while i < len(args):
    a = args[i]
    if a in ("-t", "--terse", "--show-secrets"):
        i += 1
    elif a in ("-e", "--escape"):
        if i + 1 < len(args) and args[i + 1] == "no":
            escape_off = True
        i += 2
    elif a in ("-f", "-g", "--get-values", "--wait"):
        i += 2
    else:
        stripped.append(a)
        i += 1

if stripped[:2] == ["radio", "wifi"]:
    if len(stripped) == 2:
        print(read_s("radio", "enabled"))
        raise SystemExit(0)
    if stripped[2] in ("on", "off"):
        write_s("radio", "enabled" if stripped[2] == "on" else "disabled")
        if stripped[2] == "off":
            write_s("wifi_state", "unavailable")
            write_s("wifi_conn", "--")
        else:
            write_s("wifi_state", "disconnected")
        raise SystemExit(0)

if stripped[:2] == ["device", "status"]:
    wifi_state = read_s("wifi_state", "connected")
    wifi_conn = read_s("wifi_conn", "Quattro")
    eth0_state = read_s("eth0_state", "connected")
    eth0_conn = "Wired Office" if eth0_state == "connected" else "--"
    if os.environ.get("TEST_NO_WIFI") != "1":
        if "-g" in args:
            print(f"wlan0:wifi:{wifi_state}")
            if os.environ.get("TEST_DUAL_WIFI") == "1":
                print("wlan1:wifi:connected:LabNet")
        else:
            print(f"wlan0:wifi:{wifi_state}:{wifi_conn}")
            if os.environ.get("TEST_DUAL_WIFI") == "1":
                print("wlan1:wifi:connected:LabNet")
    if os.environ.get("TEST_NO_ETH") != "1":
        if "-g" not in args:
            print(f"eth0:ethernet:{eth0_state}:{eth0_conn}")
            print("eth1:ethernet:disconnected:--")
            print("veth1234:ethernet:unmanaged:--")
    raise SystemExit(0)

if stripped[:2] == ["device", "show"] and len(stripped) >= 3:
    dev = stripped[2]
    if "--get-values" in args or "-g" in args:
        idx = args.index("--get-values") if "--get-values" in args else args.index("-g")
        field = args[idx + 1]
        if field == "GENERAL.CON-UUID":
            print("11111111-1111-1111-1111-111111111111" if dev == "wlan0" else "22222222-2222-2222-2222-222222222222")
            raise SystemExit(0)
        if field == "GENERAL.CONNECTION":
            print(read_s("wifi_conn", "Quattro"))
            raise SystemExit(0)
    def fmt_mac(m):
        return m if escape_off else m.replace(":", r"\:")
    if dev == "wlan0":
        print(f"GENERAL.HWADDR:{fmt_mac('AA:BB:CC:DD:EE:FF')}")
        print("GENERAL.CON-UUID:11111111-1111-1111-1111-111111111111")
        print("IP4.ADDRESS[1]:192.168.1.45/24")
        print("IP4.GATEWAY:192.168.1.1")
        print("IP4.DNS[1]:192.168.1.1")
    elif dev == "wlan1":
        print(f"GENERAL.HWADDR:{fmt_mac('AA:BB:CC:DD:EE:01')}")
        print("GENERAL.CON-UUID:55555555-5555-5555-5555-555555555555")
        print("IP4.ADDRESS[1]:192.168.2.20/24")
        print("IP4.GATEWAY:192.168.2.1")
        print("IP4.DNS[1]:192.168.2.1")
    elif dev == "eth0":
        print(f"GENERAL.HWADDR:{fmt_mac('10:20:30:40:50:60')}")
        print("GENERAL.CON-UUID:22222222-2222-2222-2222-222222222222")
        print(f"IP4.ADDRESS[1]:{read_s('eth0_ip', '10.0.0.10/24')}")
        print(f"IP4.GATEWAY:{read_s('eth0_gw', '10.0.0.1')}")
        for n, dns in enumerate(read_s("eth0_dns", "1.1.1.1").split(), 1):
            print(f"IP4.DNS[{n}]:{dns}")
        print("WIRED-PROPERTIES.CARRIER:on")
    elif dev == "eth1":
        print(f"GENERAL.HWADDR:{fmt_mac('10:20:30:40:50:61')}")
        print("GENERAL.CON-UUID:--")
        print("WIRED-PROPERTIES.CARRIER:off")
    raise SystemExit(0)

if stripped[:3] in (["device", "wifi", "list"], ["dev", "wifi", "list"]):
    if "-f" in args:
        fields = args[args.index("-f") + 1]
    elif "-g" in args:
        fields = args[args.index("-g") + 1]
    else:
        fields = ""
    ifname = args[args.index("ifname") + 1] if "ifname" in args else "wlan0"
    if fields == "IN-USE,SIGNAL":
        print("*:74" if ifname == "wlan0" else "*:61")
        print(" :90")
    elif fields == "FREQ,SSID":
        if ifname == "wlan1":
            print("2437 MHz:LabNet")
        else:
            print("5200 MHz:Quattro")
            print("6135 MHz:Quattro")
    elif fields == "SSID,SECURITY,FREQ":
        print("Quattro:WPA2 WPA3:6135 MHz")
        print("Quattro:WPA2 WPA3:5200 MHz")
        print(r"Cafe\:2\\4:WPA2:2437 MHz")
        print("OpenNet:--:2412 MHz")
        print("SixOnly:WPA3:6455 MHz")
        print("MixedPin:WPA3:6135 MHz")
        print("MixedPin:WPA2:5200 MHz")
        print("-dash-net:WPA2:5180 MHz")
    else:
        print("*:Quattro:74:WPA2 WPA3:6135 MHz")
        print(" :Quattro:95:WPA2 WPA3:5200 MHz")
        print(r" :Cafe\:2\\4:65:WPA2:2437 MHz")
        print(" :OpenNet:80:--:2412 MHz")
        print(" :SixOnly:55:WPA3:6455 MHz")
        print(" :-dash-net:40:WPA2:5180 MHz")
    raise SystemExit(0)

if stripped[:2] == ["device", "disconnect"] and len(stripped) >= 3:
    if stripped[2] == "wlan0":
        write_s("wifi_state", "disconnected")
        write_s("wifi_conn", "--")
    elif stripped[2] == "eth0":
        write_s("eth0_state", "disconnected")
    raise SystemExit(0)

if stripped[:2] == ["device", "connect"] and len(stripped) >= 3:
    if stripped[2] == "eth0":
        write_s("eth0_state", "connected")
    raise SystemExit(0)

if stripped[:3] == ["device", "wifi", "connect"]:
    write_s("wifi_state", "connected")
    write_s("wifi_conn", stripped[3])
    raise SystemExit(0)

if stripped[:2] == ["connection", "show"]:
    if "--get-values" in args or "-g" in args:
        idx = args.index("--get-values") if "--get-values" in args else args.index("-g")
        field = args[idx + 1]
        uid = stripped[-1]
        if field == "802-11-wireless.ssid,connection.interface-name":
            mapping = {
                "11111111-1111-1111-1111-111111111111": ("Quattro", "wlan0"),
                "33333333-3333-3333-3333-333333333333": ("Cafe:2\\4", ""),
                "66666666-6666-6666-6666-666666666666": ("SixOnly", ""),
                "77777777-7777-7777-7777-777777777777": ("MixedPin", ""),
                "88888888-8888-8888-8888-888888888888": ("Quattro", "wlan1"),
                "99999999-9999-9999-9999-999999999999": ("Office-5G", ""),
            }
            ssid_val, iface_val = mapping.get(uid, ("", ""))
            print(ssid_val)
            print(iface_val)
            raise SystemExit(0)
        if field == "802-11-wireless-security.key-mgmt,802-11-wireless.band":
            print("wpa-psk")
            print("a" if uid == "77777777-7777-7777-7777-777777777777" else "")
            raise SystemExit(0)
        if field == "802-11-wireless-security.key-mgmt":
            print("wpa-psk")
            raise SystemExit(0)
        if field == "802-11-wireless.band":
            if uid == "55555555-5555-5555-5555-555555555555":
                print("bg")
            else:
                print(read_s("band_pin", ""))
            raise SystemExit(0)
        if field == "ipv4.method,connection.interface-name":
            if uid == "22222222-2222-2222-2222-222222222222":
                print(read_s("eth0_method", "auto"))
                print("eth0")
            else:
                print("auto")
                print("")
            raise SystemExit(0)
        if "802-11-wireless-security.psk" in field:
            print("wpa-psk")
            print("super-secret-pass")
            print("")
            raise SystemExit(0)
    print("Quattro:11111111-1111-1111-1111-111111111111:802-11-wireless:wlan0:yes")
    print(r"Cafe\:2\\4:33333333-3333-3333-3333-333333333333:802-11-wireless:--:yes")
    if os.environ.get("TEST_SAVED_SIXONLY") == "1":
        print("SixOnly:66666666-6666-6666-6666-666666666666:802-11-wireless:--:yes")
    if os.environ.get("TEST_SAVED_MIXEDPIN") == "1":
        print("MixedPin:77777777-7777-7777-7777-777777777777:802-11-wireless:--:yes")
    if os.environ.get("TEST_DUAL_WIFI") == "1":
        print("Quattro-wlan1:88888888-8888-8888-8888-888888888888:802-11-wireless:--:yes")
    if os.environ.get("TEST_OFFICE_CONFLICT") == "1":
        print("Office:99999999-9999-9999-9999-999999999999:802-11-wireless:--:yes")
    print("Wired Office:22222222-2222-2222-2222-222222222222:802-3-ethernet:eth0:yes")
    print("Quattro:44444444-4444-4444-4444-444444444444:802-3-ethernet:--:no")
    raise SystemExit(0)

if stripped[:2] == ["connection", "edit"]:
    data = sys.stdin.read()
    with open(os.path.join(state, "nmcli_stdin.log"), "a", encoding="utf-8") as fh:
        fh.write(data)
    # Real nmcli asks for interactive confirmation ("Do you still want to save?
    # (yes/no) [yes]") when saving after `set connection.autoconnect yes`, so a
    # non-interactive script ending in `save\nquit` fails with exit 1.
    lines = [ln.strip() for ln in data.splitlines() if ln.strip()]
    if "set connection.autoconnect yes" in lines and "save" in lines:
        save_idx = lines.index("save")
        answer = lines[save_idx + 1] if save_idx + 1 < len(lines) else ""
        if answer.lower() not in ("yes", "y"):
            sys.stderr.write("Saving the connection with 'autoconnect=yes' requires confirmation\n")
            raise SystemExit(1)
    raise SystemExit(0)

if stripped[:2] == ["connection", "add"]:
    raise SystemExit(0)

if stripped[:2] == ["connection", "modify"]:
    if "ipv4.method" in args:
        write_s("eth0_method", args[args.index("ipv4.method") + 1])
    if "ipv4.addresses" in args:
        addr = args[args.index("ipv4.addresses") + 1]
        if addr:
            write_s("eth0_ip", addr)
    if "ipv4.gateway" in args:
        gw = args[args.index("ipv4.gateway") + 1]
        if gw:
            write_s("eth0_gw", gw)
    if "ipv4.dns" in args:
        write_s("eth0_dns", args[args.index("ipv4.dns") + 1])
    if "802-11-wireless.band" in args:
        write_s("band_pin", args[args.index("802-11-wireless.band") + 1])
    raise SystemExit(0)

if stripped[:2] == ["connection", "up"]:
    if os.environ.get("TEST_SLEEP_UP"):
        import time
        time.sleep(float(os.environ["TEST_SLEEP_UP"]))
    if os.environ.get("TEST_FAIL_UP") == "1":
        sys.stderr.write("Error: Connection activation failed: Secrets were required\n")
        raise SystemExit(4)
    raise SystemExit(0)

if stripped[:2] == ["connection", "down"]:
    raise SystemExit(0)

if stripped[:2] == ["connection", "delete"]:
    raise SystemExit(0)

raise SystemExit(0)
PY

cat >"$cli_tmp/bin/iw" <<'SH'
#!/bin/bash
if [[ $1 == "dev" && $3 == "link" ]]; then
  if [[ $2 == "wlan1" ]]; then
    cat <<'EOF'
Connected to aa:bb:cc:dd:ee:01 (on wlan1)
	SSID: LabNet
	freq: 2437
	signal: -62 dBm
	tx bitrate: 144.4 MBit/s
EOF
  else
    cat <<'EOF'
Connected to aa:bb:cc:dd:ee:ff (on wlan0)
	SSID: Caf\xc3\xa9
	freq: 6135
	signal: -46 dBm
	tx bitrate: 1441.3 MBit/s
EOF
  fi
fi
SH

cat >"$cli_tmp/bin/ip" <<'SH'
#!/bin/bash
if [[ $1 == "-j" && $2 == "route" && $3 == "get" ]]; then
  printf '[{"dst":"1.1.1.1","gateway":"10.0.0.1","dev":"eth0"}]\n'
fi
SH

chmod +x "$cli_tmp/bin/nmcli" "$cli_tmp/bin/iw" "$cli_tmp/bin/ip"

wifi_cli() {
  PATH="$cli_tmp/bin:$PATH" TEST_STATE_DIR="$NET_STATE_DIR" "$ROOT/bin/omarchy-network-wifi" "$@"
}

eth_cli() {
  PATH="$cli_tmp/bin:$PATH" TEST_STATE_DIR="$NET_STATE_DIR" OMARCHY_NET_CLASS_PATH="$cli_tmp/sys" \
    "$ROOT/bin/omarchy-network-ethernet" "$@"
}

# 1. Wi-Fi status (unescaped MAC, decoded UTF-8 SSID, UUID, band, IPv4)
out=$(wifi_cli status --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["radio"] == "on" and d["connected"] is True and d["device"] == "wlan0", d
assert d["ssid"] == "Café" and d["uuid"] == "11111111-1111-1111-1111-111111111111", d
assert d["mac"] == "AA:BB:CC:DD:EE:FF", d
assert d["signal"] == 74 and d["signal_dbm"] == -46 and d["band"] == "6", d
assert d["ip"] == "192.168.1.45" and d["prefix"] == 24 and d["gateway"] == "192.168.1.1", d
PY
pass "wifi CLI status --json reports unescaped MAC, decoded UTF-8 SSID, UUID, band, and IPv4"

# 2. Multi-adapter Wi-Fi status reads band details from the requested interface
out=$(TEST_DUAL_WIFI=1 wifi_cli status wlan1 --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["device"] == "wlan1" and d["ssid"] == "LabNet", d
assert d["band"] == "2.4" and d["band_selected"] == "2.4" and d["band_available"] == ["2.4"], d
assert d["mac"] == "AA:BB:CC:DD:EE:01", d
PY
pass "wifi CLI status <interface> reads band info from the requested adapter"

# 3. NetworkManager read failure exits non-zero instead of returning empty state
status=0
TEST_NM_DOWN=1 wifi_cli status --json >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "wifi status should fail when NetworkManager is down" "got $status"
status=0
TEST_NM_DOWN=1 eth_cli status --json >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "ethernet status should fail when NetworkManager is down" "got $status"
pass "wifi and ethernet CLIs surface NetworkManager read failures"

# 4. Wi-Fi list deduplication, colon/backslash unescaping, sorting, scan, --known
out=$(wifi_cli list --json)
python3 - "$out" <<'PY'
import json, sys
rows = json.loads(sys.argv[1])
assert [r["ssid"] for r in rows[:3]] == ["Quattro", "Cafe:2\\4", "OpenNet"], rows
assert rows[0]["connected"] is True and rows[0]["signal"] == 95 and rows[0]["bands"] == ["5", "6"], rows[0]
assert rows[1]["known"] is True and rows[2]["security"] == "open", rows
PY
wifi_cli scan --json >/dev/null
grep -q -- "--rescan yes" "$NET_STATE_DIR/nmcli.log" || fail "wifi scan triggers a rescan"
out=$(wifi_cli list --known --json)
python3 - "$out" <<'PY'
import json, sys
assert {p["ssid"] for p in json.loads(sys.argv[1])} == {"Quattro", "Cafe:2\\4"}
PY
pass "wifi CLI list/scan deduplicates bands, unescapes SSIDs, and lists known profiles"

# 5. Wi-Fi PSK connect: secret stays off argv, WPA3 selects sae, upgrades saved wpa-psk -> sae
: >"$NET_STATE_DIR/nmcli.log"
: >"$NET_STATE_DIR/nmcli_stdin.log"
printf 'top-secret-psk\n' | wifi_cli connect SixOnly --password-stdin --json >/dev/null
grep -q "top-secret-psk" "$NET_STATE_DIR/nmcli.log" && fail "wifi PSK secret leaked into nmcli argv"
grep -q "connection.autoconnect no" "$NET_STATE_DIR/nmcli.log" || fail "new PSK profile must disable autoconnect until secret is saved"
grep -q "wifi-sec.key-mgmt sae" "$NET_STATE_DIR/nmcli.log" || fail "WPA3-only SSID should use sae"
grep -q "set wifi-sec.psk top-secret-psk" "$NET_STATE_DIR/nmcli_stdin.log" || fail "PSK written via stdin"
grep -q "set connection.autoconnect yes" "$NET_STATE_DIR/nmcli_stdin.log" && fail "autoconnect must not be set inside nmcli connection edit (triggers interactive save prompt)"
grep -q "connection modify uuid .* connection.autoconnect yes" "$NET_STATE_DIR/nmcli.log" || fail "autoconnect must be enabled via connection modify after connection up"

: >"$NET_STATE_DIR/nmcli.log"
status=0
printf 'short\n' | wifi_cli connect SixOnly --password-stdin >/dev/null 2>&1 || status=$?
(( status == 2 )) || fail "PSK shorter than 8 chars should fail with exit 2" "got $status"
grep -q "connection add" "$NET_STATE_DIR/nmcli.log" && fail "invalid PSK must fail before adding a profile"

: >"$NET_STATE_DIR/nmcli.log"
TEST_DUAL_WIFI=1 wifi_cli connect Quattro --interface wlan1 --json >/dev/null
grep -q "connection up uuid 88888888-8888-8888-8888-888888888888 ifname wlan1" "$NET_STATE_DIR/nmcli.log" ||
  fail "connect --interface wlan1 must select wlan1's compatible profile, not wlan0's" "$(cat "$NET_STATE_DIR/nmcli.log")"

: >"$NET_STATE_DIR/nmcli.log"
printf 'upgraded-psk\n' | TEST_SAVED_SIXONLY=1 wifi_cli connect SixOnly --password-stdin --json >/dev/null
grep -q "connection modify uuid 66666666-6666-6666-6666-666666666666 wifi-sec.key-mgmt sae" "$NET_STATE_DIR/nmcli.log" ||
  fail "saved WPA2 profile should upgrade key-mgmt to sae for WPA3-only AP" "$(cat "$NET_STATE_DIR/nmcli.log")"

: >"$NET_STATE_DIR/nmcli.log"
printf 'pinned-psk\n' | TEST_SAVED_MIXEDPIN=1 wifi_cli connect MixedPin --password-stdin --json >/dev/null
grep -q "wifi-sec.key-mgmt sae" "$NET_STATE_DIR/nmcli.log" &&
  fail "5 GHz-pinned WPA2 profile must not switch to sae due to 6 GHz WPA3 AP" "$(cat "$NET_STATE_DIR/nmcli.log")"

: >"$NET_STATE_DIR/nmcli.log"
status=0
printf 'wrong-psk-value\n' | TEST_SAVED_SIXONLY=1 TEST_FAIL_UP=1 wifi_cli connect SixOnly --password-stdin >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "failed saved-profile PSK update should exit 1" "got $status"
grep -q "connection modify uuid 66666666-6666-6666-6666-666666666666 wifi-sec.key-mgmt wpa-psk" "$NET_STATE_DIR/nmcli.log" ||
  fail "failed saved-profile security change should roll back key-mgmt" "$(cat "$NET_STATE_DIR/nmcli.log")"
pass "wifi CLI connect keeps PSK off argv, respects pinned band security, and rolls back failed upgrades"

: >"$NET_STATE_DIR/nmcli.log"
printf 'dash-secret\n' | wifi_cli connect --password-stdin -- -dash-net >/dev/null
grep -q "ssid -dash-net" "$NET_STATE_DIR/nmcli.log" || fail "wifi connect handles leading-dash SSID after --"
pass "wifi CLI connect supports SSIDs starting with a dash after --"

# 6. Wi-Fi enterprise connect: succeeds without interactive edit save prompt, rolls back on failure
: >"$NET_STATE_DIR/nmcli.log"
: >"$NET_STATE_DIR/nmcli_stdin.log"
printf 'corp-secret\n' | wifi_cli connect CorpWiFi --identity alice --password-stdin --json >/dev/null
grep -q "corp-secret" "$NET_STATE_DIR/nmcli.log" && fail "enterprise secret leaked into nmcli argv"
grep -q "set 802-1x.password corp-secret" "$NET_STATE_DIR/nmcli_stdin.log" || fail "enterprise secret written via stdin"
grep -q "set connection.autoconnect yes" "$NET_STATE_DIR/nmcli_stdin.log" && fail "enterprise autoconnect must not be set inside nmcli connection edit"
grep -q "connection modify uuid .* connection.autoconnect yes" "$NET_STATE_DIR/nmcli.log" || fail "enterprise autoconnect must be enabled via connection modify after connection up"

: >"$NET_STATE_DIR/nmcli.log"
: >"$NET_STATE_DIR/nmcli_stdin.log"
status=0
printf 'corp-secret\n' | TEST_FAIL_UP=1 wifi_cli connect CorpWiFi --identity alice --password-stdin >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "enterprise connect failure should exit 1" "got $status"
grep -q "corp-secret" "$NET_STATE_DIR/nmcli.log" && fail "enterprise secret leaked into nmcli argv"
grep -q "set 802-1x.password corp-secret" "$NET_STATE_DIR/nmcli_stdin.log" || fail "enterprise secret written via stdin"
grep -q "connection modify uuid .* connection.autoconnect yes" "$NET_STATE_DIR/nmcli.log" && fail "failed enterprise profile must not enable autoconnect"
grep -q "connection delete uuid" "$NET_STATE_DIR/nmcli.log" || fail "failed enterprise profile should be rolled back"

: >"$NET_STATE_DIR/nmcli.log"
PATH="$cli_tmp/bin:$PATH" TEST_STATE_DIR="$NET_STATE_DIR" TEST_SLEEP_UP=10 \
  "$ROOT/bin/omarchy-network-wifi" connect SixOnly --password-stdin <<<"top-secret-psk" >/dev/null 2>&1 &
wifi_pid=$!
for _ in $(seq 1 40); do
  grep -q "connection up uuid" "$NET_STATE_DIR/nmcli.log" && break
  sleep 0.05
done
kill -TERM "$wifi_pid" 2>/dev/null || true
wait "$wifi_pid" 2>/dev/null || true
grep -q "connection down uuid" "$NET_STATE_DIR/nmcli.log" || fail "SIGTERM must cancel in-progress NM activation" "$(cat "$NET_STATE_DIR/nmcli.log")"
grep -q "connection delete uuid" "$NET_STATE_DIR/nmcli.log" || fail "SIGTERM must delete newly created profile" "$(cat "$NET_STATE_DIR/nmcli.log")"
pass "wifi CLI enterprise connect and SIGTERM cancellation cancel activation and roll back profiles"

# 7. Disconnect stops in-progress connecting attempts on both Wi-Fi and Ethernet
printf 'connecting (need authentication)\n' >"$NET_STATE_DIR/wifi_state"
: >"$NET_STATE_DIR/nmcli.log"
wifi_cli disconnect wlan0 --json >/dev/null
grep -q "device disconnect wlan0" "$NET_STATE_DIR/nmcli.log" || fail "wifi disconnect should stop in-progress connection attempts"
printf 'connected\n' >"$NET_STATE_DIR/wifi_state"

printf 'connecting (getting IP configuration)\n' >"$NET_STATE_DIR/eth0_state"
: >"$NET_STATE_DIR/nmcli.log"
eth_cli disconnect eth0 --json >/dev/null
grep -q "device disconnect eth0" "$NET_STATE_DIR/nmcli.log" || fail "ethernet disconnect should stop in-progress connection attempts"
printf 'connected\n' >"$NET_STATE_DIR/eth0_state"
pass "wifi and ethernet disconnect stop in-progress connection attempts"

# 8. Wi-Fi forget, password, band, radio toggle
: >"$NET_STATE_DIR/nmcli.log"
status=0
TEST_OFFICE_CONFLICT=1 wifi_cli forget --ssid Office >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "forget --ssid Office must not match a profile named Office with SSID Office-5G" "got $status"
grep -q "connection delete" "$NET_STATE_DIR/nmcli.log" && fail "forget --ssid must not delete unrelated profile"

status=0
wifi_cli band invalid >/dev/null 2>&1 || status=$?
(( status == 2 )) || fail "invalid wifi band should fail with exit 2" "got $status"

: >"$NET_STATE_DIR/nmcli.log"
out=$(wifi_cli forget Quattro --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert len(d["forgotten"]) == 1 and d["forgotten"][0]["uuid"] == "11111111-1111-1111-1111-111111111111", d
PY
grep -q "44444444-4444-4444-4444-444444444444" "$NET_STATE_DIR/nmcli.log" && fail "wifi forget touched an Ethernet profile"

out=$(wifi_cli password --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["password"] == "super-secret-pass"
PY
out=$(wifi_cli band --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["current"] == "6"
PY
out=$(wifi_cli toggle --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["radio"] == "off"
PY
out=$(wifi_cli on --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["radio"] == "on"
PY
pass "wifi CLI forget, password, band, and radio toggle work cleanly"

# 9. Ethernet status, static/dhcp, validation, profile isolation across adapters, forget
out=$(eth_cli status --json)
python3 - "$out" <<'PY'
import json, sys
e0, e1 = json.loads(sys.argv[1])["interfaces"]
assert e0["device"] == "eth0" and e0["mac"] == "10:20:30:40:50:60" and e0["speed_mbps"] == 2500 and e0["default_route"] is True, e0
assert e1["device"] == "eth1" and e1["carrier"] is False, e1
PY
pass "ethernet CLI status --json reports unescaped MAC, carrier, link speed, and default route"

: >"$NET_STATE_DIR/nmcli.log"
status=0
eth_cli static 192.168.50.10/24 --gateway 192.168.50.1 eth1 >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "ethernet static on eth1 without its own profile should fail" "got $status"
grep -q "connection modify" "$NET_STATE_DIR/nmcli.log" &&
  fail "ethernet static on eth1 must not modify eth0's saved profile" "$(cat "$NET_STATE_DIR/nmcli.log")"
pass "ethernet CLI refuses to overwrite another adapter's profile"

: >"$NET_STATE_DIR/nmcli.log"
out=$(eth_cli static 192.168.50.10/24 --gateway 192.168.50.1 --dns 1.1.1.1,9.9.9.9 eth0 --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["method"] == "manual" and d["address"] == "192.168.50.10/24" and d["dns"] == ["1.1.1.1", "9.9.9.9"], d
PY
for bad in \
  "192.168.50.10 --gateway 192.168.50.1" \
  "192.168.50.0/24 --gateway 192.168.50.1" \
  "192.168.50.255/24 --gateway 192.168.50.1" \
  "999.1.1.1/24 --gateway 192.168.50.1" \
  "192.168.50.10/24 --gateway not-an-ip" \
  "192.168.50.10/24 --gateway 192.168.50.1 --dns bad-dns"; do
  status=0
  # shellcheck disable=SC2086
  eth_cli static $bad >/dev/null 2>&1 || status=$?
  (( status == 2 )) || fail "ethernet static should reject invalid input ($bad) with exit 2" "got $status"
done
: >"$NET_STATE_DIR/nmcli.log"
out=$(eth_cli dhcp eth0 --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["method"] == "auto"
PY
grep -q "ipv4.dns" "$NET_STATE_DIR/nmcli.log" && fail "ethernet dhcp must preserve DNS provider settings"
: >"$NET_STATE_DIR/nmcli.log"
out=$(eth_cli forget Quattro --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert len(d["forgotten"]) == 1 and d["forgotten"][0]["uuid"] == "44444444-4444-4444-4444-444444444444", d
PY
grep -q "11111111-1111-1111-1111-111111111111" "$NET_STATE_DIR/nmcli.log" && fail "ethernet forget touched a Wi-Fi profile"
pass "ethernet CLI static, validation, dhcp, and forget work cleanly"
