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

// A VPN locks the icon the bar already shows instead of adding another one:
// every strength keeps its own bars, a portal still wins, and Ethernet changes.
for (const strength of [0, 20, 45, 55, 90]) {
  assert(network.connectionIcon('wifi', strength, 'full', true) !== network.connectionIcon('wifi', strength, 'full', false), `network locks the ${strength}% wifi icon while a VPN is up`)
}
assertEqual(new Set([0, 20, 45, 55, 90].map((strength) => network.wifiIconFor(strength, true))).size, 5, 'network keeps the signal bars in the locked wifi icon')
assertEqual(network.connectionIcon('wifi', 90, 'portal', true), network.connectionIcon('wifi', 90, 'portal', false), 'network shows a captive portal over a VPN')
assert(network.connectionIcon('ethernet', -1, 'full', true) !== network.connectionIcon('ethernet', -1, 'full', false), 'network marks a VPN over ethernet')
assertEqual(network.connectionTooltip(false, false, ['Office', 'Home lab']), 'VPN: Office, Home lab', 'network names the active VPNs in the bar tooltip')
assertEqual(network.connectionTooltip(false, false, []), '', 'network has no bar tooltip without a VPN or restriction')
assertEqual(network.connectionTooltip(false, true, ['Office']), 'Limited internet access', 'network keeps the limited-access tooltip over a VPN')

const officeId = '1f0e2d3c-4b5a-4c6d-8e7f-0a1b2c3d4e5f'
const idleProfile = [{ id: officeId, provider: 'networkmanager', name: 'Office', type: 'vpn', state: '' }]
assertEqual(network.vpnPlacement('wifi', idleProfile), 'top', 'network lists VPNs up front once there is a connection to carry them')
assertEqual(network.vpnPlacement('ethernet', idleProfile), 'top', 'network lists VPNs up front over Ethernet')
assertEqual(network.vpnPlacement('disconnected', idleProfile), 'bottom', 'network keeps VPNs at the bottom, past the networks, without a connection')
assertEqual(network.vpnPlacement('wifi', []), '', 'network has no VPN section without VPNs')

const nm = requireFromRoot('shell/Commons/VpnNetworkManagerModel.js')
assertDeepEqual(
  nm.parseVpnConnections([
    'Home Wi-Fi:6a1c0c2e-5f0e-4d8a-9d55-3c1f7d1c1a01:802-11-wireless:activated',
    'Office\\: Paris:1f0e2d3c-4b5a-4c6d-8e7f-0a1b2c3d4e5f:vpn:activated',
    'lab\\\\wg:0e1d2c3b-4a59-4687-9a6b-5c4d3e2f1a0b:wireguard:',
    'Backup:9a8b7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d:vpn:activating',
    ''
  ].join('\n')),
  [
    { id: '1f0e2d3c-4b5a-4c6d-8e7f-0a1b2c3d4e5f', provider: 'networkmanager', name: 'Office: Paris', type: 'vpn', state: 'activated' },
    { id: '0e1d2c3b-4a59-4687-9a6b-5c4d3e2f1a0b', provider: 'networkmanager', name: 'lab\\wg', type: 'wireguard', state: '' },
    { id: '9a8b7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d', provider: 'networkmanager', name: 'Backup', type: 'vpn', state: 'activating' }
  ],
  'network vpn keeps VPN and WireGuard profiles and unescapes nmcli terse names'
)
assert(!nm.isUuid('x; rm -rf ~'), 'network vpn refuses a non-UUID before building the terminal command')
assert(nm.needsSecrets("Error: Connection activation failed: Secrets were required, but not provided"), 'network vpn recognizes a connect that needs a password')
assert(!nm.needsSecrets('Error: Connection activation failed: The VPN service stopped unexpectedly.'), 'network vpn reports other connect failures as failures')
assert(nm.hasDevice('Home:6a1c0c2e-5f0e-4d8a-9d55-3c1f7d1c1a01:802-11-wireless:activated\ntailscale0:ae57342c-b0a6-4b25-b6a3-514f9ec50438:tun:activated\n', 'tailscale0', 'tun'), 'network vpn notices tailscaled through its tun device')
assert(!nm.hasDevice('tun0:ae57342c-b0a6-4b25-b6a3-514f9ec50438:tun:activated\n', 'tailscale0', 'tun'), 'network vpn leaves other tun devices alone')

// What a profile signs in with, read from `nmcli -g vpn.service-type,vpn.data`.
const openvpnDetails = nm.parseVpnDetails('org.freedesktop.NetworkManager.openvpn\nca = /etc/vpn/ca.pem, connection-type = password, password-flags = 0, remote = 10.0.0.1\\:1197\\:udp4\\\\, 10.0.0.2\\:1197, username = alice\n')
assertEqual(openvpnDetails.serviceType, 'org.freedesktop.NetworkManager.openvpn', 'network vpn reads the VPN plugin')
assertEqual(openvpnDetails.data.remote, '10.0.0.1:1197:udp4, 10.0.0.2:1197', 'network vpn unescapes vpn.data values, commas included')
assertDeepEqual(nm.credentialPlan(openvpnDetails), { userKey: 'username', secretKey: 'password', username: 'alice', askFirst: false }, 'network vpn connects a profile that keeps its name and password without asking')
const notSaved = nm.parseVpnDetails('org.freedesktop.NetworkManager.openvpn\nconnection-type = password, password-flags = 2, username = alice\n')
assertEqual(nm.credentialPlan(notSaved).askFirst, true, 'network vpn asks first for a password that is never kept')
const noUser = nm.parseVpnDetails('org.freedesktop.NetworkManager.openvpn\nconnection-type = password-tls, password-flags = 1\n')
assertDeepEqual(nm.credentialPlan(noUser), { userKey: 'username', secretKey: 'password', username: '', askFirst: true }, 'network vpn asks for a user name a profile does not have yet')
assertEqual(nm.credentialPlan(nm.parseVpnDetails('org.freedesktop.NetworkManager.openvpn\nconnection-type = tls\n')), null, 'network vpn has no name and password to ask for a certificate profile')
assertEqual(nm.credentialPlan(nm.parseVpnDetails('org.freedesktop.NetworkManager.openconnect\ngateway = vpn.example.com\n')), null, 'network vpn leaves a plugin it does not know to the terminal')
assertDeepEqual(nm.credentialPlan(nm.parseVpnDetails('org.freedesktop.NetworkManager.vpnc\nIPSec gateway = vpn.example.com, Xauth password-flags = 2, Xauth username = bob\n')), { userKey: 'Xauth username', secretKey: 'Xauth password', username: 'bob', askFirst: true }, 'network vpn reads vpnc\'s own name and password keys')
assertEqual(nm.credentialPlan(nm.parseVpnDetails('org.freedesktop.NetworkManager.l2tp\npassword-flags = 4, user = carol\n')), null, 'network vpn asks nothing of a profile whose password is not required')
assertEqual(nm.vpnDataItem('username', 'a,b\\c'), 'username=a\\,b\\\\c', 'network vpn escapes a user name for vpn.data')
{
  // The connect script against an nmcli that only records what reached it:
  // the password must arrive in the passwd-file, never in any argv.
  const { execFileSync } = require('child_process')
  const os = require('os')
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'nm-vpn-'))
  fs.writeFileSync(path.join(dir, 'nmcli'), '#!/bin/bash\nprintf "%s\\n" "$*" >>"$NM_LOG"\nfor ((i = 1; i <= $#; i++)); do [[ ${!i} == passwd-file ]] && j=$((i + 1)) && cat "${!j}" >"$NM_SECRETS"; done\nexit 0\n', { mode: 0o755 })
  const env = { ...process.env, PATH: dir + ':' + process.env.PATH, NM_LOG: path.join(dir, 'argv'), NM_SECRETS: path.join(dir, 'secrets') }
  execFileSync('bash', ['-c', nm.connectScript, 'nmcli-vpn', officeId, 'password', nm.vpnDataItem('username', 'bob')], { env, input: 'hunter2 :x\n' })
  const argv = fs.readFileSync(env.NM_LOG, 'utf8')
  assert(!argv.includes('hunter2'), 'network vpn never puts the password in an nmcli argv')
  assert(argv.includes(`connection modify uuid ${officeId} +vpn.data username=bob`), 'network vpn saves a new user name to the profile')
  assertEqual(fs.readFileSync(env.NM_SECRETS, 'utf8'), 'vpn.secrets.password:hunter2 :x\n', 'network vpn hands the password to nmcli in its passwd-file')
  fs.rmSync(dir, { recursive: true, force: true })
}

const tailscale = requireFromRoot('shell/Commons/VpnTailscaleModel.js')
const tailscaleStatus = (state, peers) => JSON.stringify({ BackendState: state, Peer: peers || {} })
const exitPeer = { 'nodekey:1': { HostName: 'nyc-exit', DNSName: 'nyc-exit.tail1234.ts.net.', ExitNode: true }, 'nodekey:2': { HostName: 'laptop', ExitNode: false } }
assertDeepEqual(tailscale.parseStatus(tailscaleStatus('Running', exitPeer)), { id: 'tailscale', provider: 'tailscale', name: 'Tailscale', type: 'tailscale', state: 'activated', exitNode: 'nyc-exit', opens: 'omarchy.tailscale' }, 'network vpn reads a running Tailscale and its exit node, and opens its widget')
assertEqual(tailscale.parseStatus(tailscaleStatus('Stopped', exitPeer)).state, '', 'network vpn reads a stopped Tailscale as off')
assertEqual(tailscale.parseStatus(tailscaleStatus('NeedsLogin')).state, 'login', 'network vpn reads a Tailscale that needs signing in')
assertEqual(tailscale.parseStatus('failed to connect to local tailscaled'), null, 'network vpn shows no Tailscale when tailscaled does not answer')
assert(tailscale.isEvent('\t"State": 6,') && tailscale.isEvent('\t"Prefs": {'), 'network vpn rereads Tailscale on a state or preference change')
assert(!tailscale.isEvent('\t"State": null,') && !tailscale.isEvent('\t\t"State": 6,'), 'network vpn ignores Tailscale notifications without a state change')

const vpn = requireFromRoot('shell/Commons/NetworkVpnModel.js')
const mesh = tailscale.parseStatus(tailscaleStatus('Running'))
const routed = tailscale.parseStatus(tailscaleStatus('Running', exitPeer))
assertDeepEqual(vpn.mergeConnections([[{ id: 'b', name: 'Work' }], [{ id: 'a', name: 'Home' }], null]).map((c) => c.name), ['Home', 'Work'], 'network vpn lists every provider\'s VPNs in name order')
assertDeepEqual(vpn.activeVpnNames(nm.parseVpnConnections('A:9a8b7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d:vpn:activating\nB:1f0e2d3c-4b5a-4c6d-8e7f-0a1b2c3d4e5f:vpn:activated\n')), ['B'], 'network vpn counts a profile as up only once it is activated')
assertDeepEqual(vpn.activeVpnNames([mesh]), [], 'network vpn does not lock the icon for a Tailscale that only reaches the tailnet')
assertDeepEqual(vpn.activeVpnNames([routed]), ['Tailscale'], 'network vpn locks the icon while Tailscale routes through an exit node')
JS
