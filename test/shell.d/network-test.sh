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
assert(/tooltipText: Model\.isMetered\(root\.hotspotMetered\) \? Commons\.I18n\.t\("network\.unlimitData"\) : Commons\.I18n\.t\("network\.limitData"\)/.test(panelSource), 'network offers to lift the limit on a metered network and to set one otherwise')
assert(/tooltipText: root\.hotspotLink \? Commons\.I18n\.t\("network\.runSpeedTestMobileData"\) : Commons\.I18n\.t\("network\.runSpeedTest"\)/.test(panelSource), 'network warns that a speed test over a phone hotspot uses mobile data')
assert(/autoLimitedConnection !== scan\.connection/.test(panelSource), 'network limits a profile on its own only once')
const hotspotProcBlock = panelSource.match(/id: hotspotScanProc[\s\S]*?\n {2}\}/)
assert(hotspotProcBlock && /onStreamFinished: if \(hotspotScanProc\.request === root\.hotspotRequest\) root\.updateHotspots\(text\)/.test(hotspotProcBlock[0]), 'network drops a hotspot read that a newer request superseded')
assert(hotspotProcBlock && /onExited: if \(request !== root\.hotspotRequest\) Qt\.callLater\(root\.scanHotspots\)/.test(hotspotProcBlock[0]), 'network reruns a hotspot read requested while one was running')
const connectionKeyHandler = panelSource.match(/onConnectionKeyChanged: \{[\s\S]*?\n {2}\}/)
assert(connectionKeyHandler && /hotspotConnection = ""/.test(connectionKeyHandler[0]), 'network forgets the old profile before the data limit can act on a new link')
// The metered script against an nmcli stub: $STUB_METERED is the profile's
// own setting and $STUB_DEVICE_UUID the profile the interface runs now.
{
  const os = require('os')
  const { spawnSync } = require('child_process')
  const stubDir = fs.mkdtempSync(os.tmpdir() + '/network-metered-')
  fs.writeFileSync(stubDir + '/nmcli', '#!/bin/bash\necho "$*" >>"$STUB_LOG"\ncase "$*" in\n  "-g connection.metered connection show uuid "*) echo "$STUB_METERED" ;;\n  "-g GENERAL.CON-UUID device show "*) echo "$STUB_DEVICE_UUID" ;;\nesac\n', { mode: 0o755 })
  const runMetered = (args, env) => {
    const log = stubDir + '/log'
    fs.writeFileSync(log, '')
    const result = spawnSync('bash', ['-c', network.meteredScript, 'omarchy-network-metered', ...args], { env: Object.assign({}, process.env, { PATH: stubDir + ':' + process.env.PATH, STUB_LOG: log }, env) })
    return { status: result.status, calls: fs.readFileSync(log, 'utf8') }
  }
  let run = runMetered(['phone-uuid', 'yes', 'wlan0', ''], { STUB_METERED: 'unknown', STUB_DEVICE_UUID: 'phone-uuid' })
  assert(/connection modify uuid phone-uuid connection\.metered yes/.test(run.calls) && /device reapply wlan0/.test(run.calls), 'network saves the data limit and reapplies it to the link running the profile')
  run = runMetered(['phone-uuid', 'yes', 'wlan0', ''], { STUB_METERED: 'unknown', STUB_DEVICE_UUID: 'home-uuid' })
  assert(/connection modify uuid phone-uuid/.test(run.calls) && !/device reapply/.test(run.calls) && run.status === 0, 'network saves but does not reapply when the interface now runs another profile')
  run = runMetered(['phone-uuid', 'yes', 'wlan0', '1'], { STUB_METERED: 'no', STUB_DEVICE_UUID: 'phone-uuid' })
  assert(!/connection modify/.test(run.calls), 'network leaves a profile with its own setting alone when limiting on its own')
  fs.rmSync(stubDir, { recursive: true, force: true })
}

const setMeteredFn = panelSource.match(/function setMetered\([\s\S]*?\n {2}\}/)
const meteredExited = panelSource.match(/id: meteredProc\s+onExited: \{([\s\S]*?)\n {4}\}/)
assert(setMeteredFn && meteredExited, 'network has a queued data limit write path')
if (setMeteredFn && meteredExited) {
  let wifiDevice = { name: 'wlan0' }
  let pendingMetered = null
  const meteredProc = { running: true, command: [] }
  const Model = network
  const root = {}
  eval(setMeteredFn[0])
  root.setMetered = setMetered
  Object.defineProperty(root, 'pendingMetered', { get: () => pendingMetered, set: value => { pendingMetered = value } })
  root.scanHotspots = () => {}
  setMetered('phone-uuid', 'yes', false)
  wifiDevice = { name: 'wlan1' }
  meteredProc.running = false
  new Function('root', 'Qt', meteredExited[1])(root, { callLater: fn => fn() })
  assertEqual(meteredProc.command[4], 'phone-uuid', 'network runs the queued data limit write once the running one exits')
  assertEqual(meteredProc.command[6], 'wlan0', 'network reapplies a queued data limit to the adapter it was asked for')
}
assert(/else if \(headerIndex === dataHeaderIndex\) toggleDataLimit\(\)/.test(panelSource), 'network reaches the data limit action from the keyboard')

assertEqual(network.connectionIcon('wifi', 80, 'full', true), network.hotspotIcon, 'network draws the chain for a hotspot link')
assertEqual(network.connectionIcon('wifi', 80, 'portal', true), '󰤩', 'network keeps the alert glyph for a hotspot behind a captive portal')
assertEqual(network.connectionIcon('wifi', 80, 'limited', true), '󰤩', 'network keeps the alert glyph for a limited hotspot')
assertEqual(network.connectionIcon('ethernet', -1, 'full', true), '󰈀', 'network ignores the hotspot flag on ethernet')
assert(/iw dev "\$1" scan dump -u/.test(network.hotspotScanScript), 'network reads the cached scan, with unknown vendor elements, instead of starting one')
assert(/if \(isConnected && net\.hotspot\) return Commons\.I18n\.t\("network\.mobileHotspot"\)/.test(panelSource), 'network labels a connected hotspot row')
assert(/row\.isHotspot \? Model\.hotspotIcon : "󰌾"/.test(panelSource), 'network draws the chain in the lock slot of a hotspot row')

// Hotspot status parsing and helpers (omarchy-hotspot status output).
assertDeepEqual(
  network.parseHotspotStatus('ap_capable\t1\nap_bands\t2.4,5\nactive\t1\nssid\tMy Net\nclients\t[{"mac":"aa:bb:cc","signal":-42}]\n'),
  { ap_capable: '1', ap_bands: '2.4,5', active: '1', ssid: 'My Net', clients: '[{"mac":"aa:bb:cc","signal":-42}]' },
  'network parses hotspot status key/values'
)
assertDeepEqual(network.parseHotspotStatus(''), {}, 'network parses empty hotspot status')
assertDeepEqual(network.hotspotBands({ ap_bands: '2.4,5' }), ['2.4', '5'], 'network lists hotspot ap bands')
assertDeepEqual(network.hotspotBands({ ap_bands: '2.4' }), ['2.4'], 'network keeps a single hotspot band')
assertDeepEqual(network.hotspotBands({}), [], 'network reports no hotspot bands when unknown')
assertEqual(network.hotspotDefaultBand({ ap_bands: '2.4,5', band: '5' }), '5', 'network prefers the profile band when supported')
assertEqual(network.hotspotDefaultBand({ ap_bands: '2.4,5', band: '6' }), '2.4', 'network falls back to 2.4 when the profile band is unsupported')
assertEqual(network.hotspotDefaultBand({ ap_bands: '5' }), '5', 'network uses the only available hotspot band')
assertEqual(network.hotspotDefaultBand({}), '', 'network returns no hotspot band when none exist')
assertDeepEqual(
  network.hotspotClients({ clients: '[{"mac":"aa:bb:cc","signal":-42}]' }),
  [{ mac: 'aa:bb:cc', signal: -42 }],
  'network parses hotspot clients'
)
assertDeepEqual(network.hotspotClients({ clients: 'garbage' }), [], 'network ignores malformed hotspot clients')
assertEqual(network.hotspotClientLabel({ mac: 'aa:bb:cc', signal: -42 }), 'AA:BB:CC · -42 dBm', 'network labels a hotspot client with signal')
const persianDigits = n => String(n).replace(/[0-9]/g, d => String.fromCharCode(0x06f0 + Number(d)))
assertEqual(network.hotspotClientLabel({ mac: 'aa:bb:cc', signal: -42 }, persianDigits), 'AA:BB:CC · -۴۲ dBm', 'network writes a hotspot client signal in the language digits')
assertEqual(network.hotspotClientLabel({ mac: 'aa:bb:cc' }), 'AA:BB:CC', 'network labels a hotspot client without signal')
assertEqual(network.hotspotClientLabel({}), '', 'network labels an empty hotspot client')
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
const ipcHandler = panelSource.match(/ShellIpc \{[\s\S]*?target: "omarchy\.network"([\s\S]*?)\n  \}/)
assert(ipcHandler, 'the network panel has an IPC handler')
for (const method of menuNetworkCalls) {
  const wrapper = ipcHandler && ipcHandler[1].match(new RegExp('function ' + method + '\\([^)]*\\) \\{[^\\n]*\\}'))
  assert(wrapper, 'the network panel answers the menu call ' + method)
  if (!wrapper) continue
  const calls = []
  const root = new Proxy({}, { get: (_, name) => (...args) => calls.push(name) })
  new Function('root', wrapper[0] + '\nreturn ' + method)(root)()
  assertEqual(calls.join(','), method, 'the menu call ' + method + ' reaches the panel method of that name')
}

const updateHotspotSource = panelSource.match(/function updateHotspot\(raw, exitCode, errorOutput\) \{[\s\S]*?\n {2}\}/)
assert(updateHotspotSource, 'network accepts a hotspot process result')
if (updateHotspotSource) {
  let hotspot = {}
  let hotspotLoaded = false
  let hotspotEditedFields = {}
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

  // A field the user typed in while the first status was still running
  // stays; the fields they didn't touch still load what the profile holds.
  hotspotEditedFields = { ssid: true }
  hotspotSsid = 'Typed Name'
  hotspotPassword = 'stalepassword'
  hotspotBand = '2.4'
  updateHotspot('ap_capable\t1\nap_bands\t2.4,5\nactive\t0\nconfigured\t1\nssid\tSaved Hotspot\npassword\tsavedpassword\nband\t5\n', 0, '')
  assert(hotspotLoaded && hotspotSsid === 'Typed Name', 'a late first status keeps the field the user already edited')
  assert(hotspotPassword === 'savedpassword' && hotspotBand === '5', 'a late first status still loads the fields the user did not touch')
  hotspotLoaded = false
  hotspotEditedFields = {}
  hotspotSsid = ''
  hotspotPassword = ''
  hotspotBand = ''

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

JS
