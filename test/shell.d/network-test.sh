#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')

assert(/IpcHandler[\s\S]*?function toggleNetwork\(\) \{ root\.toggleNetwork\(\) \}/.test(panelSource), 'network exposes the Wi-Fi radio toggle over IPC')
assert(/manageIpc: false/.test(panelSource), 'network owns its IPC handler so it can extend the target methods')

// Opening from the bar must call open() and nothing else. open() runs
// refresh(true), which defers the PHY scan; a second bare refresh() defaults
// scanWifi to false, sets scannerEnabled synchronously, and stalls the open on
// NetworkManager's access-point flood.
const barPress = panelSource.match(/onPressed: function\(b\) \{[\s\S]*?\n {4}\}/)
assert(barPress, 'network bar button has an onPressed handler')
const barPressCode = barPress[0].replace(/\/\/.*$/gm, '')
assert(!/refresh\(/.test(barPressCode), 'network bar click opens the panel without a second refresh that would undo the deferred scan')

// A closed panel has no nearby-network list to fill. Quickshell's scanner
// re-arms RequestScan on its own timer, and every sweep takes the radio off
// the operating channel, so a scanner left enabled behind a closed panel keeps
// degrading the connection it is scanning from.
const refreshFn = panelSource.match(/function refresh\(scanWifi\)[\s\S]*?\n {2}\}/)
assert(refreshFn, 'network has a refresh() function')
assert(/if \(opened && wifiDevice\)/.test(refreshFn[0]), 'network only touches the scanner from refresh() while its panel is open')

// The 100ms deferral can outlive the panel: closing inside the window would
// otherwise re-enable scanning from a timer nobody is watching.
const scanRestart = panelSource.match(/id: scanRestart[\s\S]*?onTriggered: \{[\s\S]*?\n {4}\}/)
assert(scanRestart, 'network has the deferred scan restart timer')
assert(/root\.opened/.test(scanRestart[0]), 'network re-checks the panel before the deferred restart re-enables scanning')
assert(/scanRestart\.stop\(\)/.test(panelSource), 'network cancels a pending scan restart when the panel closes')

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

// Destruction is the case a guard-only fix misses: the widget dies with the
// panel still open, as a bar reload does, and nothing else would release it.
assert(
  /Component\.onDestruction[\s\S]{0,140}scannerDevice\.scannerEnabled = false/.test(panelSource),
  'network releases the scanner it owns when the widget is destroyed'
)
assert(!/wifiDevice\.scannerEnabled\s*=/.test(panelSource), 'network writes scanner state through its owned device reference rather than the moving wifiDevice reference')

// A row is a primitive snapshot that can outlive its WifiNetwork, and
// disconnect() falls back to the live connection when handed null, so row
// activation must go through the guarded disconnectRow().
assert(
  /function disconnectRow\(ssid\) \{\s*var network = networkForSsid\(ssid\)\s*if \(network\) disconnect\(network\)/.test(panelSource),
  'network guards row disconnects so a stale row cannot drop an unrelated connection'
)
assert(!/disconnect\(\s*(root\.)?networkForSsid\(/.test(panelSource), 'network never passes an unguarded networkForSsid() lookup to disconnect()')

assertDeepEqual(
  network.parseNetworkStatus('wifi\tCafe WiFi\t78\t5200\n'),
  { kind: 'wifi', label: 'Cafe WiFi', signalStrength: 78, frequency: '5200' },
  'network parses bar status'
)
assertEqual(network.connectionIcon('wifi', 80), network.wifiIconFor(80), 'network maps wifi icon from signal')

// OWE transition mode: between scans NetworkManager files the in-use access
// point under the hidden "_owetm_" SSID and drops the active profile from the
// device's AvailableConnections, so Quickshell lists no connected network. The
// bar trusts the device's own state and reads the in-use AP's strength instead
// of flickering to disconnected.
const kindBinding = panelSource.match(/readonly property string kind: \{[\s\S]*?\n {2}\}/)
assert(kindBinding, 'network has a kind binding')
assert(/if \(wifiDevice && wifiDevice\.connected\) return "wifi"/.test(kindBinding[0]), 'network keeps showing Wi-Fi while the device is connected but no network is listed as connected')
assert(
  kindBinding[0].indexOf('connectedWifiNetwork) return "wifi"') < kindBinding[0].indexOf('wifiDevice.connected) return "wifi"'),
  'network prefers the listed connected network before falling back to device state'
)
assertEqual(network.connectedSignalStrength(0.8, 40), 80, 'network prefers the connected network strength')
assertEqual(network.connectedSignalStrength(0, 67), 67, 'network falls back to the in-use access point strength')
assertEqual(network.connectedSignalStrength(0, -1), 0, 'network reports no strength when the in-use access point is unknown')
assertEqual(network.parseActiveApSignal(' :82\n*:67\n :50\n'), 67, 'network parses the in-use access point strength from nmcli')
assertEqual(network.parseActiveApSignal(' :82\n'), -1, 'network reports no in-use access point when none is marked')
assertEqual(network.parseActiveApSignal(''), -1, 'network tolerates empty nmcli output')
assert(/running: root\.needsActiveApSignal/.test(panelSource), 'network only polls the in-use access point while the connected network lacks a strength')
assert(/"--rescan", "no"/.test(panelSource), 'network reads the in-use access point without triggering a scan')
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

const rows = network.sortWifiRows([
  { ssid: 'Open', connected: false, known: false, signal: 95 },
  { ssid: 'Known', connected: false, known: true, signal: 10 },
  { ssid: 'Connected', connected: true, known: true, signal: 20 }
])
assertDeepEqual(rows.map(row => row.ssid), ['Connected', 'Known', 'Open'], 'network sorts wifi rows by connection and known state')
assertEqual(network.wifiSectionTitle(rows, 0), 'KNOWN NETWORKS', 'network labels known wifi section')
assertEqual(network.wifiSectionTitle(rows, 2), 'OTHER NETWORKS', 'network labels other wifi section')

const wifiRow = network.wifiRow({ connected: true, known: true, name: 'Home', signalStrength: 0.8, security: 1 })
assertDeepEqual(
  wifiRow,
  { connected: true, known: true, ssid: 'Home', signal: 80, security: 1, hotspot: false },
  'network projects wifi rows with primitives so delegates never hold the live WifiNetwork object'
)
assertEqual(network.wifiRow({ name: 'Phone' }, true).hotspot, true, 'network carries the hotspot flag on the primitive row')
assertDeepEqual(
  Object.keys(wifiRow).sort(),
  ['connected', 'hotspot', 'known', 'security', 'signal', 'ssid'],
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

assert(
  /Model\.requiresCredentials\(security, WifiSecurityType\.Open, WifiSecurityType\.Owe\)/.test(panelSource),
  'network wires the Quickshell OWE enum into credential detection'
)
assert(
  /if \(requiresCredentials\(net\.security\) && !net\.known\)/.test(panelSource),
  'network keyboard activation gates unknown-network prompts on credential requirements'
)
assert(
  /if \(row\.requiresCredentials && !row\.isKnown\)/.test(panelSource),
  'network row clicks gate unknown-network prompts on credential requirements'
)
assert(
  /shouldRepromptPassphrase\(reason, row\.requiresCredentials\)/.test(panelSource),
  'network failure reprompts use the row credential requirement'
)
assert(
  /networkFailureReason\(reason, requiresCredentials\(network\.security\)\)/.test(panelSource),
  'network failure copy uses the live network credential requirement'
)
assert(
  /readonly property bool canForget: root\.canForgetNetwork\(net\)/.test(panelSource),
  'network rows derive forget eligibility from the tested model helper'
)
const rightAction = panelSource.match(/Item \{\s*id: rightAction\b[\s\S]*?\n {6}\}/)
assert(rightAction, 'network has a right-edge action target')
assert(
  /visible: row\.requiresCredentials \|\| row\.canForget/.test(rightAction[0]),
  'network keeps a forget target for known passwordless networks'
)
const lockIndicator = panelSource.match(/Text \{\s*id: lockIndicator\b[\s\S]*?\n {8}\}/)
assert(lockIndicator, 'network has a lock/forget indicator')
assert(
  /visible: row\.requiresCredentials \|\| row\.forgetVisible/.test(lockIndicator[0]),
  'network hides the lock on passwordless networks until showing their forget action'
)
assert(
  /forgetVisible: canForget && \(!requiresCredentials \|\| forgetFocused \|\| rightMouse\.containsMouse\)/.test(panelSource),
  'network shows the forget action directly for known passwordless networks'
)

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
// Hotspot detection reads `iw dev <iface> scan dump -u`. The first BSS is a
// trimmed capture from a Redmi Note 13 hotspot: Xiaomi sends Apple's Personal
// Hotspot element, plus Interworking "Chargeable Public", which alone is not
// a hotspot signal.
const bss = (bssid, ssid, lines, associated) =>
  ['BSS ' + bssid + '(on wlo1)' + (associated ? ' -- associated' : ''), '\tfreq: 2412.0', '\tSSID: ' + ssid]
    .concat(lines.map(line => '\t' + line))
const scanDump = [].concat(
  bss('72:4a:77:ed:72:e1', 'Redmi Note 13', [
    'RSN:\t * Version: 1',
    '802.11u Interworking:',
    '\tNetwork Options: 0x2',
    '\t\tNetwork Type: 2 (Chargeable Public)',
    'Vendor specific: OUI 00:17:f2, data: 06 01 01 03 01 00 00'
  ], true),
  bss('aa:bb:cc:00:00:01', 'Apple TV', ['Vendor specific: OUI 00:17:f2, data: 0a 00 01 04 00 00 00']),
  bss('aa:bb:cc:00:00:02', 'Laptop Fixed', ['MS/WiFi 0x11, data: 02 00 00 00']),
  bss('aa:bb:cc:00:00:03', 'Laptop Variable', ['Vendor specific: OUI 00:50:f2, data: 11 04 00 00 00']),
  bss('aa:bb:cc:00:00:04', 'Office', ['MS/WiFi 0x11, data: 01 00 00 00']),
  bss('aa:bb:cc:00:00:05', 'Cafe', ['Vendor specific: OUI 00:10:18, data: 02 00 00 1c 00']),
  bss('aa:bb:cc:00:00:06', 'Airport', ['802.11u Interworking:', '\tNetwork Options: 0x2', '\t\tNetwork Type: 2 (Chargeable Public)']),
  bss('aa:bb:cc:00:00:07', 'Smile \\xf0\\x9f\\x98\\x80', ['Vendor specific: OUI 00:17:f2, data: 06 01 01'])
).join('\n') + '\n'

const scanned = network.parseIwScanDump(scanDump)
const hotspotBySsid = Object.fromEntries(scanned.map(entry => [entry.ssid, entry.hotspot]))
assertEqual(hotspotBySsid['Redmi Note 13'], true, 'network matches the Apple Personal Hotspot element (type 0x06)')
assertEqual(hotspotBySsid['Apple TV'], false, 'network ignores other Apple vendor elements')
assertEqual(hotspotBySsid['Laptop Fixed'], true, 'network matches a Microsoft Network Cost element with Fixed cost')
assertEqual(hotspotBySsid['Laptop Variable'], true, 'network matches a Microsoft Network Cost element with Variable cost')
assertEqual(hotspotBySsid['Office'], false, 'network ignores an Unrestricted Network Cost element')
assertEqual(hotspotBySsid['Cafe'], false, 'network ignores ordinary vendor elements')
assertEqual(hotspotBySsid['Airport'], false, 'network does not treat Chargeable Public interworking alone as a hotspot')
assertEqual(hotspotBySsid['Smile 😀'], true, 'network decodes escaped hotspot SSIDs')
assertEqual(scanned[0].bssid, '72:4a:77:ed:72:e1', 'network keeps the BSSID of each scanned BSS')
assertEqual(scanned[0].associated, true, 'network notes the associated BSS')
assertDeepEqual(network.parseIwScanDump(''), [], 'network treats an empty dump as no hotspots')

assertEqual(network.isMetered('yes (guessed)'), true, 'network treats a guessed metered link as metered')
assertEqual(network.isMetered('yes'), true, 'network treats an explicit metered link as metered')
assertEqual(network.isMetered('no (guessed)'), false, 'network treats an unmetered link as unmetered')
assertEqual(network.isMetered('unknown'), false, 'network treats unknown metering as unmetered')

const hotspotScan = network.parseHotspotScan('metered\tno (guessed)\n' + scanDump)
assertEqual(hotspotScan.active, true, 'network classifies the associated BSS on its own beacon')
assertEqual(hotspotScan.ssids['Redmi Note 13'], true, 'network lists hotspot SSIDs for the rows')
assertEqual(hotspotScan.ssids['Office'], undefined, 'network leaves ordinary SSIDs out of the hotspot list')
assertEqual(
  network.parseHotspotScan('metered\tyes (guessed)\n' + bss('aa:bb:cc:00:00:09', 'Pixel', [], true).join('\n')).active,
  true,
  'network treats an ANDROID_METERED link as a hotspot when its beacon says nothing'
)
assertEqual(
  network.parseHotspotScan('metered\tno (guessed)\n' + bss('aa:bb:cc:00:00:09', 'Home', [], true).join('\n')).active,
  false,
  'network leaves an ordinary associated link alone'
)
assertDeepEqual(
  network.parseHotspotScan(''),
  { metered: '', connection: '', limit: '', ssids: {}, active: false },
  'network falls back to ordinary Wi-Fi when the scan fails'
)

assertEqual(network.isHotspotSsid(hotspotScan.ssids, 'Redmi Note 13'), true, 'network finds a hotspot SSID')
assertEqual(network.isHotspotSsid({}, 'constructor'), false, 'network ignores inherited keys when looking up a hotspot SSID')
assertEqual(network.isHotspotSsid({}, 'toString'), false, 'network ignores Object.prototype methods as hotspot SSIDs')
assertEqual(network.isHotspotSsid(null, 'Home'), false, 'network treats a missing hotspot list as none')

const limitScan = network.parseHotspotScan('metered\tyes (guessed)\nconnection\tphone-uuid\nlimit\tunknown\n' + scanDump)
assertEqual(limitScan.connection, 'phone-uuid', 'network reads the active profile ahead of the scan')
assertEqual(limitScan.limit, 'unknown', 'network reads the profile metered setting ahead of the scan')
assertEqual(limitScan.ssids['Redmi Note 13'], true, 'network still parses the scan after the header')
assertEqual(network.shouldLimitHotspot(limitScan), true, 'network limits a hotspot whose profile has no metered setting')
assertEqual(network.shouldLimitHotspot(Object.assign({}, limitScan, { limit: 'no' })), false, 'network never overrides a profile set to unlimited')
assertEqual(network.shouldLimitHotspot(Object.assign({}, limitScan, { limit: 'yes' })), false, 'network leaves an already limited profile alone')
assertEqual(network.shouldLimitHotspot(Object.assign({}, limitScan, { active: false })), false, 'network does not limit an ordinary network')
assertEqual(network.shouldLimitHotspot(Object.assign({}, limitScan, { connection: '' })), false, 'network needs a profile to limit')
assert(/connection\.metered\)?[^;]*!= unknown/.test(network.meteredScript), 'network rechecks the profile before limiting it on its own')
assert(/nmcli device reapply "\$3"/.test(network.meteredScript), 'network reapplies the setting without reconnecting')
assertEqual(network.dataLimitTooltip('yes (guessed)'), "Don't limit this network", 'network offers to lift the limit on a metered hotspot')
assertEqual(network.dataLimitTooltip('no'), 'Limit data on this network', 'network offers to limit an unmetered hotspot')
assertEqual(network.speedTestTooltip(true), 'Run a speed test (uses mobile data)', 'network warns that a speed test uses hotspot data')
assertEqual(network.speedTestTooltip(false), 'Run a speed test', 'network keeps the plain speed test tooltip elsewhere')
assert(/autoLimitedConnection !== scan\.connection/.test(panelSource), 'network limits a profile on its own only once')
const hotspotProcBlock = panelSource.match(/id: hotspotProc[\s\S]*?\n {2}\}/)
assert(hotspotProcBlock && /onStreamFinished: if \(hotspotProc\.request === root\.hotspotRequest\) root\.updateHotspots\(text\)/.test(hotspotProcBlock[0]), 'network drops a hotspot read that a newer request superseded')
assert(hotspotProcBlock && /onExited: if \(request !== root\.hotspotRequest\) Qt\.callLater\(root\.scanHotspots\)/.test(hotspotProcBlock[0]), 'network reruns a hotspot read requested while one was running')
const connectionKeyHandler = panelSource.match(/onConnectionKeyChanged: \{[\s\S]*?\n {2}\}/)
assert(connectionKeyHandler && /hotspotConnection = ""/.test(connectionKeyHandler[0]), 'network forgets the old profile before the data limit can act on a new link')
const setMeteredFn = panelSource.match(/function setMetered\([\s\S]*?\n {2}\}/)
assert(setMeteredFn && /if \(meteredProc\.running\) \{\s*pendingMetered = /.test(setMeteredFn[0]), 'network queues a data limit write that arrives during another')
const meteredProcBlock = panelSource.match(/id: meteredProc[\s\S]*?\n {2}\}/)
assert(meteredProcBlock && /root\.setMetered\(next\.connection, next\.value, next\.onlyIfUnset\)/.test(meteredProcBlock[0]), 'network runs the queued data limit write once the running one exits')
assert(/else if \(headerIndex === dataHeaderIndex\) toggleDataLimit\(\)/.test(panelSource), 'network reaches the data limit action from the keyboard')

assertEqual(network.connectionIcon('wifi', 80, 'full', true), network.hotspotIcon, 'network draws the chain for a hotspot link')
assertEqual(network.connectionIcon('wifi', 80, 'portal', true), '󰤩', 'network keeps the alert glyph for a hotspot behind a captive portal')
assertEqual(network.connectionIcon('wifi', 80, 'limited', true), '󰤩', 'network keeps the alert glyph for a limited hotspot')
assertEqual(network.connectionIcon('ethernet', -1, 'full', true), '󰈀', 'network ignores the hotspot flag on ethernet')
assert(/iw dev "\$1" scan dump -u/.test(network.hotspotScanScript), 'network reads the cached scan, with unknown vendor elements, instead of starting one')
assert(/if \(isConnected && net\.hotspot\) return "Mobile hotspot"/.test(panelSource), 'network labels a connected hotspot row')
assert(/row\.isHotspot \? Model\.hotspotIcon : "󰌾"/.test(panelSource), 'network draws the chain in the lock slot of a hotspot row')
JS
