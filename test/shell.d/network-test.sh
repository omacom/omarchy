#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')
const hotspotSource = fs.readFileSync(root + '/bin/omarchy-hotspot', 'utf8')

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

// Hotspot status parsing and helpers (omarchy-hotspot status output).
assertDeepEqual(
  network.parseHotspotStatus('ap_capable\t1\nap_bands\t2.4,5\nactive\t1\nssid\tMy Net\nclients\t[{"mac":"aa:bb:cc","signal":-42,"address":"10.42.0.5","hostname":"pixel-8"}]\n'),
  { ap_capable: '1', ap_bands: '2.4,5', active: '1', ssid: 'My Net', clients: '[{"mac":"aa:bb:cc","signal":-42,"address":"10.42.0.5","hostname":"pixel-8"}]' },
  'network parses hotspot status key/values'
)
assertDeepEqual(network.parseHotspotStatus(''), {}, 'network parses empty hotspot status')
assertDeepEqual(network.hotspotBands({ ap_bands: '2.4,5' }), ['2.4', '5'], 'network lists hotspot ap bands')
assertDeepEqual(network.hotspotBands({ ap_bands: '2.4' }), ['2.4'], 'network keeps a single hotspot band')
assertDeepEqual(network.hotspotBands({}), [], 'network reports no hotspot bands when unknown')
assertEqual(network.hotspotDefaultBand({ ap_bands: '2.4,5', band: '5' }), '5', 'network prefers the profile band when supported')
assertEqual(network.hotspotDefaultBand({ ap_bands: '2.4,5', band: '6' }), '2.4', 'network falls back to 2.4 when the profile band is unsupported')
assertEqual(network.hotspotDefaultBand({ ap_bands: '5' }), '5', 'network uses the only available hotspot band')

assertDeepEqual(network.hotspotSaveDataChoices, ['auto', 'always', 'never'], 'network offers auto, always and never for hotspot data saving')
assertEqual(network.hotspotSaveData({ save_data: 'always' }), 'always', 'network reads the saved hotspot data choice')
assertEqual(network.hotspotSaveData({ save_data: 'bogus' }), 'auto', 'network falls back to auto for an unknown data choice')
assertEqual(network.hotspotSaveData({}), 'auto', 'network treats a status without a data choice as auto')
assertEqual(network.hotspotSaveDataLabel('never'), 'Never', 'network labels the hotspot data choices')
assert(/only when this computer's connection is metered/.test(network.hotspotSaveDataTooltip('auto', false, 'auto')), 'network explains what auto follows')
assert(!/next start/.test(network.hotspotSaveDataTooltip('always', true, 'always')), 'network does not defer the choice the running hotspot already uses')
assert(/\(from the next start\)$/.test(network.hotspotSaveDataTooltip('never', true, 'always')), 'network says a new choice waits for the next start while on air')
assert(!/next start/.test(network.hotspotSaveDataTooltip('never', false, 'always')), 'network does not defer a choice while the hotspot is off')
assert(/"start", hotspotSsid\.trim\(\), hotspotBand, hotspotLimitArgument, "--save-data=" \+ hotspotSaveData, "--security=" \+ hotspotSecurity\]/.test(panelSource), 'network starts the hotspot with the data and security choices')
assert(/"apply", hotspotSsid\.trim\(\), hotspotBand, hotspotLimitArgument, "--save-data=" \+ hotspotSaveData, "--security=" \+ hotspotSecurity\]/.test(panelSource), 'network saves the data and security choices with the credentials')
assertDeepEqual(network.hotspotSecurityChoices, ['wpa2', 'mixed', 'wpa3'], 'network offers wpa2, mixed and wpa3 hotspot security')
assertEqual(network.hotspotSecurity({ security: 'wpa3' }), 'wpa3', 'network reads the saved hotspot security')
assertEqual(network.hotspotSecurity({ security: 'wep' }), 'mixed', 'network falls back to mixed for an unknown security')
assertEqual(network.hotspotSecurity({}), 'mixed', 'network treats a status without security as mixed')
assertEqual(network.hotspotSecurityLabel('mixed'), 'WPA2/WPA3', 'network labels the mixed security choice')
assert(/older devices can't join/.test(network.hotspotSecurityTooltip('wpa3', false, 'mixed')), 'network warns that WPA3 only shuts out older devices')
assert(!/next start/.test(network.hotspotSecurityTooltip('mixed', true, 'mixed')), 'network does not defer the security the running hotspot already uses')
assert(/\(from the next start\)$/.test(network.hotspotSecurityTooltip('wpa2', true, 'mixed')), 'network says a new security waits for the next start while on air')
assertEqual(network.hotspotDefaultBand({}), '', 'network returns no hotspot band when none exist')
assertDeepEqual(
  network.hotspotClients({ clients: '[{"mac":"aa:bb:cc","signal":-42,"address":"10.42.0.5","hostname":"pixel-8"}]' }),
  [{ mac: 'aa:bb:cc', signal: -42, address: '10.42.0.5', hostname: 'pixel-8' }],
  'network parses hotspot clients'
)
assertDeepEqual(network.hotspotClients({ clients: 'garbage' }), [], 'network ignores malformed hotspot clients')
assertEqual(network.hotspotClientLabel({ mac: 'aa:bb:cc', signal: -42 }), 'AA:BB:CC · -42 dBm', 'network labels a hotspot client with signal')
assertEqual(network.hotspotClientLabel({ mac: 'aa:bb:cc' }), 'AA:BB:CC', 'network labels a hotspot client without signal')
assertEqual(network.hotspotClientLabel({}), '', 'network labels an empty hotspot client')
assertEqual(network.hotspotClientLabel({ mac: 'aa:bb:cc', signal: -42, address: '10.42.0.5', hostname: 'pixel-8' }), 'pixel-8 \u00b7 AA:BB:CC \u00b7 -42 dBm', 'network leads a named client with its name')
assertEqual(network.hotspotClientLabel({ mac: 'aa:bb:cc', signal: -42, address: '10.42.0.5' }), '10.42.0.5 \u00b7 AA:BB:CC \u00b7 -42 dBm', 'network falls back to the address when a client has no name')
assertEqual(network.hotspotClientLabel({ mac: 'aa:bb:cc', signal: -42, hostname: 'pixel-8' }), 'pixel-8 \u00b7 AA:BB:CC \u00b7 -42 dBm', 'network keeps the MAC when a client has no address')
assertEqual(network.hotspotMaxClients({ max_clients: '4' }), '4', 'network reads the participant limit off the status')
assertEqual(network.hotspotMaxClients({ max_clients: '' }), '', 'network reads an absent participant limit as unlimited')
assertEqual(network.hotspotMaxClients({ max_clients: '0' }), '', 'network refuses a zero participant limit')
assertEqual(network.hotspotMaxClients({ max_clients: '254' }), '', 'network refuses a participant limit outside a /24')
assertEqual(network.hotspotMaxClients({ max_clients: 'four' }), '', 'network refuses a non-numeric participant limit')
assertEqual(network.hotspotMaxClients({}), '', 'network reads a status without a limit as unlimited')
assertEqual(network.hotspotLimitLabel(''), 'Unlimited', 'network labels the unlimited choice')
assertEqual(network.hotspotLimitLabel('8'), '8 devices', 'network labels a bounded choice')
assertEqual(network.hotspotAtCapacity({ max_clients: '4', client_count: '4' }), true, 'network reports a full hotspot at the limit')
assertEqual(network.hotspotAtCapacity({ max_clients: '4', client_count: '3' }), false, 'network reports room left below the limit')
assertEqual(network.hotspotAtCapacity({ max_clients: '', client_count: '9' }), false, 'network never calls an unlimited hotspot full')
assertEqual(network.hotspotAtCapacity({ max_clients: '4' }), false, 'network does not call a hotspot full without a client count')
assertEqual(network.hotspotCredentialsError('', 'abcdefgh'), 'Enter a hotspot name', 'network requires a hotspot ssid')
assertEqual(network.hotspotCredentialsError('  ', 'abcdefgh'), 'Enter a hotspot name', 'network treats a blank hotspot ssid as missing')
assertEqual(network.hotspotCredentialsError('Home', 'short'), 'Password needs 8+ characters', 'network rejects a short hotspot password')
assertEqual(network.hotspotCredentialsError('Home', 'a'.repeat(64)), "Password can't exceed 63 characters", 'network rejects a hotspot password over 63 characters')
assertEqual(network.hotspotCredentialsError('Home', 'abcdefgh'), '', 'network accepts an 8-character hotspot password')
assertEqual(network.hotspotCredentialsError('Home', 'a'.repeat(63)), '', 'network accepts a 63-character hotspot password')

// The hotspot section in the panel: dynamic AP bands drive the selector, the
// whole wifi list hides while the AP owns the radio, and the command runs by
// its first-party name so the script can be exercised from the CLI too.
// Panel code extracted below reads its messages from the English catalog,
// with String.prototype.arg filling %1 as QML's does.
if (!String.prototype.arg) String.prototype.arg = function(value) { return this.replace('%1', value) }
const englishShell = JSON.parse(fs.readFileSync(root + '/default/i18n/en/shell.json', 'utf8'))
const englishCommons = { I18n: { t: key => englishShell[key] } }
// A one-line readonly binding from the panel, as a function of the names it
// reads, so its logic runs here rather than being matched as text.
function panelBinding(name) {
  const match = panelSource.match(new RegExp('readonly property \\w+ ' + name + ': ([^\\n]+)'))
  if (!match) fail('network has the ' + name + ' binding')
  return scope => new Function(...Object.keys(scope), 'return (' + match[1] + ')')(...Object.values(scope))
}
const hotspotMessage = panelBinding('hotspotMessage')
assertEqual(hotspotMessage({ hotspotError: 'start failed', hotspotStatusError: 'status failed' }), 'start failed', 'network shows an action error ahead of a status error')
assertEqual(hotspotMessage({ hotspotError: '', hotspotStatusError: 'status failed' }), 'status failed', 'network falls back to the status error')
const hotspotFocusMax = panelBinding('hotspotFocusMax')
assert(hotspotFocusMax({ hotspotActive: true }) > hotspotFocusMax({ hotspotActive: false }), 'network adds the QR button to the keyboard cycle only while the AP is on')

// The Wi-Fi list hides only for the radio hosting the AP: with one adapter
// the list is the AP's own radio, with two the upstream adapter keeps its
// networks. Runs the panel's own binding and syncWifiNetworks.
const hotspotRadioTaken = panelBinding('hotspotRadioTaken')
const syncWifiSource = panelSource.match(/function syncWifiNetworks\(\) \{[\s\S]*?\n {2}\}/)
assert(syncWifiSource, 'network has a wifi list sync')
if (syncWifiSource) {
  // The panel state the function reads and writes, as one scope.
  const listFor = (hotspotIface, adapter) => {
    const wifiDevice = { name: adapter }
    const state = {
      wifiNetworks: [],
      wifiStationAvailable: false,
      scanning: true,
      wifiDevice,
      wifiNetworkObjects: [{ name: 'Upstream' }],
      hotspotSsids: [],
      activeHotspot: false,
      hotspotRadioTaken: hotspotRadioTaken({ hotspotActive: true, hotspot: { iface: hotspotIface }, wifiDevice }),
      checkActionCompletion: () => {},
      Model: { wifiRow: network => ({ name: network.name }), sortWifiRows: rows => rows, isHotspotSsid: () => false },
    }
    new Function('state', 'with (state) {\n' + syncWifiSource[0] + '\nsyncWifiNetworks()\n}')(state)
    return state.wifiNetworks
  }
  assertEqual(listFor('wlan0', 'wlan0').length, 0, 'network hides the wifi list on the one adapter hosting the hotspot')
  assertEqual(listFor('wlan1', 'wlan0').length, 1, 'network keeps the upstream adapter listing networks while a second adapter hosts')
  assertEqual(hotspotRadioTaken({ hotspotActive: false, hotspot: { iface: 'wlan0' }, wifiDevice: { name: 'wlan0' } }), false, 'network keeps the wifi list while the hotspot is off')
}

// Every panel method the menu calls over IPC exists on the panel's handler.
const menuSource = fs.readFileSync(root + '/default/omarchy/omarchy-menu.jsonc', 'utf8')
const menuNetworkCalls = [...menuSource.matchAll(/shell call omarchy\.network (\w+)/g)].map(m => m[1])
assert(menuNetworkCalls.length > 0, 'the menu calls the network panel')
for (const method of menuNetworkCalls) {
  assert(new RegExp('function ' + method + '\\(\\) \\{ root\\.' + method + '\\(\\) \\}').test(panelSource), 'the network panel answers the menu call ' + method)
}

const updateHotspotSource = panelSource.match(/function updateHotspot\(raw, exitCode, errorOutput\) \{[\s\S]*?\n {2}\}/)
assert(updateHotspotSource, 'network accepts a hotspot process result')
if (updateHotspotSource) {
  let hotspot = {}
  let hotspotLoaded = false
  let hotspotBands = []
  let hotspotSsid = ''
  let hotspotPassword = ''
  let hotspotBand = ''
  let hotspotStatusError = ''
  const Model = network
  const Commons = englishCommons
  let syncs = 0
  function syncWifiNetworks() { syncs++ }
  eval(updateHotspotSource[0])

  updateHotspot('ap_capable\t1\nap_bands\t2.4,5\nactive\t0\nconfigured\t1\nssid\tSaved Hotspot\npassword\tsavedpassword\nband\t5\n', 0, '')
  assert(hotspot.ssid === 'Saved Hotspot' && hotspotLoaded && hotspotSsid === 'Saved Hotspot' && hotspotPassword === 'savedpassword' && hotspotBand === '5', 'network loads saved hotspot state only from successful output')
  let lastGood = hotspot
  const lastSsid = hotspotSsid
  const lastPassword = hotspotPassword
  const lastBand = hotspotBand
  syncs = 0
  updateHotspot('active\t1\nclient_count\t0\nclients\t[]\n', 0, '')
  assertEqual(syncs, 1, 'network re-syncs the wifi list when the hotspot comes on air')
  assert(hotspot.active === '1' && hotspot.client_count === '0' && hotspot.ssid === undefined, 'network replaces stale fields from a successful hotspot status')
  lastGood = hotspot
  updateHotspot('', 1, 'status probe\nfailed')
  assert(hotspot === lastGood && hotspotSsid === lastSsid && hotspotPassword === lastPassword && hotspotBand === lastBand, 'network preserves hotspot state after failed status')
  assertEqual(hotspotStatusError, 'Hotspot status failed: status probe failed', 'network surfaces collapsed hotspot status stderr')
  updateHotspot('  \n', 0, '')
  assert(hotspot === lastGood && hotspotSsid === lastSsid, 'network preserves hotspot state after empty status')
  assertEqual(hotspotStatusError, 'Hotspot status returned no data', 'network reports empty hotspot status')
}

const hotspotActionFailureSource = panelSource.match(/function hotspotActionFailure\(kind, reason\) \{[\s\S]*?\n {2}\}/)
assert(hotspotActionFailureSource, 'network has one place that words a failed hotspot action')
if (hotspotActionFailureSource) {
  const Commons = englishCommons
  eval(hotspotActionFailureSource[0])
  assertEqual(hotspotActionFailure('stop'), 'Failed to stop hotspot', 'network words a failed stop before its reason arrives')
  assertEqual(hotspotActionFailure('apply', 'no dnsmasq'), 'Failed to apply hotspot: no dnsmasq', 'network carries the command reason for a failed apply')
  assertEqual(hotspotActionFailure('start', ''), 'Failed to start hotspot (run `omarchy hotspot diagnose` for details)', 'network points a silent start failure at diagnose')
  assertEqual(hotspotActionFailure('', 'busy'), 'Failed to start hotspot: busy', 'network treats an unnamed action as a start')
}

const resetHotspotErrorsSource = panelSource.match(/function resetHotspotErrors\(\) \{[\s\S]*?\n {2}\}/)
assert(resetHotspotErrorsSource, 'network has a stale hotspot error reset path')
if (resetHotspotErrorsSource) {
  let hotspotError = 'old action error'
  let hotspotStatusError = 'old status error'
  eval(resetHotspotErrorsSource[0])
  resetHotspotErrors()
  assert(hotspotError === '' && hotspotStatusError === '', 'network clears action and status errors when the panel reopens')
}

const completeHotspotStatusSource = panelSource.match(/function completeHotspotStatus\(run, raw, exitCode, errorOutput\) \{[\s\S]*?\n {2}\}/)
assert(completeHotspotStatusSource, 'network has one hotspot status completion path')
if (completeHotspotStatusSource) {
  let hotspotStatusGeneration = 7
  let hotspotRefreshPending = false
  let appliedResults = 0
  let refreshes = 0
  function updateHotspot() { appliedResults += 1 }
  function refreshHotspot() {
    refreshes += 1
    hotspotRefreshPending = false
  }
  eval(completeHotspotStatusSource[0])

  completeHotspotStatus(6, 'stale output', 0, '')
  assert(appliedResults === 0 && refreshes === 0, 'network drops a status result from an obsolete process generation')
  hotspotRefreshPending = true
  completeHotspotStatus(7, 'pre-action output', 0, '')
  assert(appliedResults === 0 && refreshes === 1 && hotspotRefreshPending === false, 'network refetches instead of publishing pre-action status')
  completeHotspotStatus(7, 'current output', 0, '')
  assert(appliedResults === 1 && refreshes === 1, 'network applies the current status result after the pending refetch')
}


const refreshHotspotSource = panelSource.match(/function refreshHotspot\(discardRunning\) \{[\s\S]*?\n {2}\}/)
assert(refreshHotspotSource, 'network has a hotspot status poller')
if (refreshHotspotSource) {
  let hotspotProc = { running: true, command: null, runGeneration: 0 }
  let hotspotRefreshPending = false
  let hotspotStatusGeneration = 3
  const hotspotCommand = 'omarchy-hotspot'
  eval(refreshHotspotSource[0])
  refreshHotspot()
  assert(hotspotRefreshPending === false, 'a poll during a running status lets that run publish')
  refreshHotspot(true)
  assert(hotspotRefreshPending === true, 'a refresh after an action discards the in-flight pre-action status')
  hotspotProc.running = false
  refreshHotspot()
  assert(hotspotProc.running && hotspotProc.command.join(' ') === 'omarchy-hotspot status' && hotspotProc.runGeneration === hotspotStatusGeneration && hotspotStatusGeneration === 4, 'network stamps each hotspot status run with a new generation')

  // The poll runs the panel's own onTriggered, which must not ask to discard.
  const pollTrigger = panelSource.match(/id: hotspotPoll[\s\S]*?onTriggered: ([^\n]+)/)
  assert(pollTrigger, 'network polls hotspot status while open')
  if (pollTrigger) {
    const args = []
    new Function('root', pollTrigger[1])({ refreshHotspot: (...a) => args.push(a) })
    assert(args.length === 1 && !args[0][0], 'the periodic poll never discards a running status')
  }
}

const hotspotStatusOnExited = panelSource.match(/onExited: function\(exitCode\) \{\n {6}const run = hotspotProc\.runGeneration[\s\S]*?\n {4}\}/)
assert(hotspotStatusOnExited, 'network captures the hotspot status run before deferring it')
if (hotspotStatusOnExited) {
  let hotspotProc = { running: false, runGeneration: 4 }
  const hotspotStatusOut = { text: 'ap_capable\t1\n' }
  const hotspotStatusErr = { text: '' }
  const deferred = []
  const Qt = { callLater: function(fn) { deferred.push(fn) } }
  const completions = []
  const root = { completeHotspotStatus: function(run, raw, exitCode, errorOutput) { completions.push([run, raw, exitCode, errorOutput]) } }
  const onExited = eval('(' + hotspotStatusOnExited[0].replace(/^onExited: /, '') + ')')

  onExited(0)
  assert(completions.length === 0 && deferred.length === 1, 'network defers hotspot status completion instead of publishing inside onExited')

  hotspotProc.running = true
  hotspotProc.runGeneration = 12
  hotspotStatusOut.text = 'newer output'
  hotspotStatusErr.text = 'newer stderr'
  deferred.forEach(fn => fn())

  assertEqual(completions.length, 1, 'network completes exactly one deferred hotspot status run')
  assertEqual(completions[0][0], 4, 'network reports the generation the exited run was launched for, not the live counter')
  assertEqual(completions[0][1], 'ap_capable\t1\n', 'network reports the output captured when the run exited')
  assertEqual(completions[0][2], 0, 'network reports the exit code captured when the run exited')
  assertEqual(completions[0][3], '', 'network reports stderr captured when the run exited')
}

assert(/command = \[hotspotCommand, "alias-set", hotspotAliasMac\]/.test(panelSource), 'network saves a client alias by MAC only')
assert(/command = \[hotspotCommand, "alias-remove", hotspotAliasMac\]/.test(panelSource), 'network removes a client alias by MAC only')
assert(/hotspotAliasProc\.secret = label/.test(panelSource), 'network sends the alias text over stdin, not argv')
assert(/onClicked: root\.beginHotspotAlias\(clientRow\.modelData\)/.test(panelSource), 'network opens the alias editor from a client row')
assert(/hotspotAliasDraft = String\(\(client \|\| \{\}\)\.alias \|\| ""\)/.test(panelSource), 'network seeds the editor with the current alias')
assert(/id: hotspotAliasProc/.test(panelSource) && /root\.refreshHotspot\(\)/.test(panelSource), 'network refreshes the client list after an alias write')
assert(/required property var modelData[\s\S]*?HotspotBandPill/.test(panelSource), 'network declares the injected repeater property on the band pills')
assert(/readonly property string hotspotLimitArgument: hotspotMaxClients === "" \? "unlimited" : hotspotMaxClients/.test(panelSource), 'network always passes an explicit participant limit')
assert(/hotspotMaxClients = Model\.hotspotMaxClients\(next\)/.test(panelSource), 'network seeds the participant limit from the profile once')
assert(/"start", hotspotSsid\.trim\(\), hotspotBand, hotspotLimitArgument/.test(panelSource), 'hotspot start applies the chosen participant limit')
assert(/"apply", hotspotSsid\.trim\(\), hotspotBand, hotspotLimitArgument/.test(panelSource), 'hotspot apply applies the chosen participant limit')
assert(/component HotspotLimitPill: Button/.test(panelSource), 'network renders the participant limit as a pill')
assert(/delegate: HotspotSaveDataPill \{\n\s*required property var modelData\n\s*choice: modelData/.test(panelSource), 'network declares the injected repeater property on the save-data pills')
assert(/delegate: HotspotSecurityPill \{\n\s*required property var modelData\n\s*choice: modelData/.test(panelSource), 'network declares the injected repeater property on the security pills')
assert(/apply_args\+=\("--save-data=\$save_data"\)/.test(hotspotSource), 'hotspot start forwards the data choice to apply')
assert(/apply_args\+=\("--security=\$security"\)/.test(hotspotSource), 'hotspot start forwards the security choice to apply')
JS
