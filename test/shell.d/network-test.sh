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
JS

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const childProcess = require('child_process')
const vm = require('vm')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panel = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-enterprise-trust-'))

try {
  const cert = path.join(scratch, 'private CA.pem')
  fs.writeFileSync(cert, 'fixture CA')
  fs.writeFileSync(path.join(scratch, 'uuidgen'), '#!/bin/bash\nprintf "fixture-uuid\\n"\n', {mode: 0o755})
  fs.writeFileSync(path.join(scratch, 'nmcli'), `#!/bin/bash
count=0
[[ ! -f $TEST_NM_LOG.count ]] || read -r count <"$TEST_NM_LOG.count"
(( count += 1 ))
printf '%s\\n' "$count" >"$TEST_NM_LOG.count"
printf '%s\\0' "$@" >"$TEST_NM_LOG.$count"
if [[ $2 == "$TEST_NM_HANG" ]]; then
  [[ $TEST_NM_IGNORE_TERM != 1 ]] || trap '' TERM
  printf '%s\\n' "$BASHPID" >"$TEST_NM_LOG.pids"
  sleep 30 &
  printf '%s\\n' "$!" >>"$TEST_NM_LOG.pids"
  wait
fi
if [[ $2 == "edit" ]]; then cat >"$TEST_NM_LOG.stdin"; fi
[[ $2 != "$TEST_NM_FAIL" ]]
`, {mode: 0o755})

  const password = 'literal $() \\" secret'
  function connect(caCert, serverName, failAction, locale) {
    return runCommand(['bash', '-c', network.enterpriseConnectScript, 'nmcli-eap',
      'Enterprise WiFi', 'person@example.org', caCert, serverName], {failAction, locale})
  }

  function runCommand(argv, {failAction, hangAction, ignoreTerm, locale}) {
    const log = path.join(scratch, 'nmcli-log')
    for (const name of fs.readdirSync(scratch)) {
      if (name.startsWith('nmcli-log')) fs.unlinkSync(path.join(scratch, name))
    }
    // Shorten the deadline while preserving the panel's command and the real supervisor.
    const command = argv.map(arg => hangAction && arg === network.enterpriseConnectScript
      ? arg.replace('--kill-after=1s 150s', '--kill-after=0.1s 0.1s') : arg)
    const result = childProcess.spawnSync(command.shift(), command, {
      input: password + '\n', encoding: 'utf8', timeout: 2000,
      env: {...process.env, ...(locale ? {LC_ALL: locale} : {}), PATH: scratch + ':' + process.env.PATH,
        TEST_NM_LOG: log, TEST_NM_FAIL: failAction || '',
        TEST_NM_HANG: hangAction || '', TEST_NM_IGNORE_TERM: ignoreTerm ? '1' : '0'}
    })
    // Rejected trust exits before the password is read, so writing it can race into EPIPE.
    if (result.error && result.error.code === 'EPIPE') delete result.error
    const count = fs.existsSync(log + '.count') ? Number(fs.readFileSync(log + '.count', 'utf8')) : 0
    const calls = []
    for (let i = 1; i <= count; i++) calls.push(fs.readFileSync(log + '.' + i, 'utf8').split('\0').slice(0, -1))
    const stdin = fs.existsSync(log + '.stdin') ? fs.readFileSync(log + '.stdin', 'utf8') : ''
    const pids = fs.existsSync(log + '.pids') ? fs.readFileSync(log + '.pids', 'utf8').trim().split('\n') : []
    return {result, calls, stdin, pids}
  }

  for (const [caCert, serverName] of [
    ['', ''], ['', 'radius.example.org'], [cert, ''],
    ['relative.pem', 'radius.example.org'], [scratch, 'radius.example.org'],
    [cert + '.missing', 'radius.example.org'],
    [cert, '*.example.org'], [cert, 'radius.example.org;evil.example.org'],
    [cert, 'radius.example.org\nevil.example.org'], [cert, 'radius..example.org'],
    [cert, '-radius.example.org'], [cert, 'radius-.example.org'],
    [cert, 'r'.repeat(64) + '.example.org'], [cert, 'râdius.example.org']
  ]) {
    const attempt = connect(caCert, serverName)
    assert(attempt.result.status !== 0 && !attempt.result.error && attempt.calls.length === 0,
      'enterprise refuses invalid trust before any NetworkManager call: ' + JSON.stringify([caCert, serverName]))
  }

  const installedLocales = childProcess.spawnSync('locale', ['-a'], {encoding: 'utf8'})
  assertEqual(installedLocales.status, 0, 'enterprise locale coverage can enumerate installed locales')
  const locales = ['C', ...installedLocales.stdout.trim().split('\n').filter(locale => /utf.?8$/i.test(locale))]
  const unicodeCert = path.join(scratch, 'réseau CA.pem')
  fs.writeFileSync(unicodeCert, 'fixture CA')
  for (const locale of locales) {
    for (const serverName of ['râdius.example.org', 'RÁDIUS.example.org', 'radius.exämple.org']) {
      assert(!network.enterpriseTrustValid(cert, serverName), 'enterprise UI rejects non-ASCII server ' + serverName)
      const attempt = connect(cert, serverName, '', locale)
      assert(!attempt.result.error && attempt.result.status === 65 && attempt.calls.length === 0,
        'enterprise boundary rejects non-ASCII server before NetworkManager in ' + locale + ': ' + serverName)
    }
    for (const serverName of ['RADIUS.example.org', 'xn--radius-9za.example.org']) {
      const attempt = connect(unicodeCert, serverName, '', locale)
      assert(!attempt.result.error && attempt.result.status === 0,
        'enterprise accepts ASCII server and Unicode CA path in ' + locale + ': ' + serverName)
      const add = attempt.calls[0]
      assertEqual(add[add.indexOf('802-1x.ca-cert') + 1], unicodeCert, 'enterprise preserves Unicode CA path in ' + locale)
      assertEqual(attempt.stdin, 'set 802-1x.password ' + password + '\nsave\nquit\n', 'enterprise preserves literal password in ' + locale)
    }
  }

  const good = connect(cert, 'radius.example.org')
  assertEqual(connect(cert + '.missing', 'radius.example.org').result.status, 64, 'enterprise distinguishes unreadable CA input from connection failures')
  assertEqual(connect(cert, '*.example.org').result.status, 65, 'enterprise distinguishes invalid server input from connection failures')
  assertEqual(good.result.status, 0, 'enterprise accepts administrator-provided private CA and exact server')
  assertDeepEqual(good.calls.map(call => call[1]), ['add', 'edit', 'up'], 'enterprise creates, writes credentials, then activates')
  const add = good.calls[0]
  for (const [name, value] of [
    ['ssid', 'Enterprise WiFi'], ['802-1x.identity', 'person@example.org'],
    ['802-1x.auth-timeout', '0'],
    ['802-1x.ca-cert', cert], ['802-1x.domain-match', 'radius.example.org'],
    ['802-1x.system-ca-certs', 'no'], ['802-1x.eap', 'peap'], ['802-1x.phase2-auth', 'mschapv2']
  ]) assertEqual(add[add.indexOf(name) + 1], value, 'enterprise profile sets ' + name)
  assert(!good.calls.some(call => call.some(arg => arg.includes(password))), 'enterprise password never enters a subprocess argument')
  assertEqual(good.stdin, 'set 802-1x.password ' + password + '\nsave\nquit\n', 'enterprise password reaches the editor literally through stdin')

  for (const action of ['add', 'edit', 'up']) {
    const failed = connect(cert, 'radius.example.org', action)
    assert(failed.result.status !== 0 && failed.calls.at(-1)[1] === 'delete', 'enterprise cleans up a failed ' + action)
    if (action !== 'up') assert(!failed.calls.some(call => call[1] === 'up'), 'enterprise never activates after failed ' + action)
  }

  for (const serverName of ['radius.example.org', 'RADIUS.example.org', 'radius', 'xn--radius-9za.example.org']) {
    assert(network.enterpriseTrustValid(cert, serverName), 'enterprise UI accepts exact administrator server ' + serverName)
  }
  for (const serverName of ['', '*.example.org', 'radius.example.org;evil.example.org', 'radius.example.org\n', 'a'.repeat(254)]) {
    assert(!network.enterpriseTrustValid(cert, serverName), 'enterprise UI rejects invalid server ' + JSON.stringify(serverName))
  }
  assert(!network.enterpriseTrustValid('', 'radius.example.org'), 'enterprise UI requires a CA certificate path')

  // Exercise the production caller as well as the subprocess boundary.
  const Model = network
  var cancelSignals = 0
  const enterpriseConnect = {running: false, secret: '', command: [], cancelling: false, signal: function(signal) { assertEqual(signal, 15, 'enterprise cancellation signals its supervisor'); cancelSignals++ }}
  var enterpriseRetry = null
  var actionCount = 0
  var actionRevision = 0
  var actionKind = ''
  var failureSsid = ''
  var failureReason = ''
  function runNetworkAction(kind, ssidNetwork, callback) { if (actionKind !== '') return; actionKind = kind; actionCount++; actionRevision++; callback({name: ssidNetwork}) }
  function networkForSsid(ssid) { return ssid }
  const caller = panel.match(/function connectEnterprise\([^)]*\) \{[\s\S]*?\n {2}\}/)
  assert(caller, 'enterprise has a production connection caller')
  eval(caller[0])
  connectEnterprise('Enterprise WiFi', 'person@example.org', password, '', '')
  assertEqual(actionCount, 0, 'enterprise caller cannot start without trust settings')
  connectEnterprise('Enterprise WiFi', 'person@example.org', password, cert, 'radius.example.org')
  assertEqual(actionCount, 1, 'enterprise caller starts with valid trust settings')
  assertDeepEqual(enterpriseConnect.command.slice(-4), ['Enterprise WiFi', 'person@example.org', cert, 'radius.example.org'], 'enterprise caller passes explicit trust settings to the process')
  assert(!enterpriseConnect.command.includes(password), 'enterprise caller keeps the password out of argv')
  for (const [action, ignoreTerm] of [['add', false], ['edit', false], ['up', false], ['up', true]]) {
    const stalled = runCommand(enterpriseConnect.command, {hangAction: action, ignoreTerm})
    assert(!stalled.result.error && (stalled.result.status === 124 || stalled.result.status === 137),
      'enterprise deadline ends a stalled ' + action + (ignoreTerm ? ' even when TERM is ignored' : '')
        + ' ' + JSON.stringify({status: stalled.result.status, signal: stalled.result.signal, error: stalled.result.error && stalled.result.error.code}))
    assertEqual(stalled.pids.length, 2, 'stalled enterprise fixture started nmcli and its child')
    assert(stalled.calls.at(-1)[1] === 'delete' && stalled.calls.at(-1)[3] === 'fixture-uuid',
      'enterprise supervisor cleans its own profile after stalled ' + action + (ignoreTerm ? ' and forced KILL' : ''))
    for (const pid of stalled.pids) {
      const stat = '/proc/' + pid + '/stat'
      assert(!fs.existsSync(stat) || fs.readFileSync(stat, 'utf8').split(') ')[1].startsWith('Z'),
        'enterprise deadline leaves no running nmcli descendant ' + pid)
    }
  }

  const firstCommand = enterpriseConnect.command.slice()
  const firstRevision = enterpriseConnect.actionRevision
  connectEnterprise('Enterprise WiFi', 'retry@example.org', 'new password', cert, 'radius.example.org')
  assertEqual(actionCount, 1, 'enterprise does not reuse a still-running process for a retry')
  assertDeepEqual(enterpriseConnect.command, firstCommand, 'enterprise retains the running process command')
  assertEqual(enterpriseConnect.actionRevision, firstRevision, 'enterprise retains the running attempt revision')
  assertEqual(enterpriseRetry, null, 'a busy enterprise action does not queue an overlapping retry')
  actionKind = '' // The panel's informational timeout has expired.
  connectEnterprise('Enterprise WiFi', 'retry@example.org', 'new password', cert, 'radius.example.org')
  assertEqual(cancelSignals, 1, 'retry cancels a stale attempt instead of remaining blocked')
  assertEqual(enterpriseRetry.identity, 'retry@example.org', 'enterprise queues the retry until old cleanup exits')
  assertEqual(actionCount, 1, 'queued retry does not reuse the live Process')
  connectEnterprise('Enterprise WiFi', 'latest@example.org', 'latest password', cert, 'radius.example.org')
  assertEqual(cancelSignals, 1, 'additional retry requests do not interrupt cancellation cleanup')
  assertEqual(enterpriseRetry.identity, 'latest@example.org', 'enterprise retains the latest requested retry')

  const exitHandler = panel.match(/onExited: function\(exitCode, exitStatus\) \{([\s\S]*?)\n {4}\}/)
  assert(exitHandler, 'enterprise has an exit handler')
  const english = JSON.parse(fs.readFileSync(root + '/default/i18n/en/shell.json', 'utf8'))
  const Commons = {I18n: {t: function(key) { return english[key] }}}
  const onExited = new Function('Commons', 'return function(exitCode, exitStatus, root, actionRevision, ssid, actionTimeout, secret, cancelling, Qt) {' + exitHandler[1] + '\n}')(Commons)
  var stopped = 0
  const timer = {stop: function() { stopped++ }}
  const retry = {actionRevision: firstRevision + 1, actionKind: 'connect', actionSsid: 'Enterprise WiFi', failureSsid: '', failureReason: '', enterpriseRetry: null}
  const beforeLateExit = JSON.stringify(retry)
  onExited(1, 0, retry, firstRevision, 'Enterprise WiFi', timer, '')
  assertEqual(JSON.stringify(retry), beforeLateExit, 'enterprise late exit cannot clear a newer same-SSID attempt')
  assertEqual(stopped, 0, 'enterprise late exit cannot stop the newer attempt timer')

  onExited(64, 0, retry, retry.actionRevision, 'Enterprise WiFi', timer, '')
  assertEqual(retry.failureReason, 'CA certificate must be a readable file', 'enterprise displays the specific CA path error')
  assertEqual(retry.actionKind, '', 'enterprise current failure clears its own busy state')
  assertEqual(stopped, 1, 'enterprise current failure stops its own timer')
  retry.actionKind = 'connect'
  retry.actionSsid = 'Enterprise WiFi'
  onExited(124, 0, retry, retry.actionRevision, 'Enterprise WiFi', timer, '')
  assertEqual(retry.failureReason, 'Timed out connecting', 'enterprise deadline reports a timeout instead of invalid credentials')
  assertEqual(retry.actionKind, '', 'enterprise timeout clears its own busy state for retry')

  const clearHelper = panel.match(/function clearNetworkAction\([^)]*\) \{[\s\S]*?\n {2}\}/)
  assert(clearHelper, 'network has a production completion helper')
  let refreshCount = 0
  const lateSuccess = vm.createContext({actionRevision: firstRevision, actionKind: '', actionSsid: '', failureSsid: 'Enterprise WiFi',
    failureReason: 'Timed out connecting', passwordSsid: 'Enterprise WiFi', enterpriseRetry: null,
    actionTimeout: timer, refresh() { refreshCount++ }})
  vm.runInContext(clearHelper[0], lateSuccess)
  onExited(0, 0, lateSuccess, firstRevision, 'Enterprise WiFi', timer, '')
  assertEqual(lateSuccess.failureReason, '', 'late enterprise success removes its informational timeout error')
  assertEqual(lateSuccess.passwordSsid, '', 'late enterprise success closes its password prompt')
  assertEqual(refreshCount, 1, 'late enterprise success refreshes connection details')
  lateSuccess.failureSsid = 'Enterprise WiFi'
  lateSuccess.failureReason = 'Timed out connecting'
  lateSuccess.passwordSsid = 'Other WiFi'
  onExited(0, 0, lateSuccess, firstRevision, 'Enterprise WiFi', timer, '')
  assertEqual(lateSuccess.passwordSsid, 'Other WiFi', 'late enterprise success preserves another network credentials prompt')
  assertEqual(lateSuccess.failureReason, '', 'late enterprise success still removes its own timeout while another prompt is open')
  lateSuccess.actionRevision++
  lateSuccess.failureSsid = 'Enterprise WiFi'
  lateSuccess.failureReason = 'Newer action failed'
  lateSuccess.passwordSsid = 'Enterprise WiFi'
  const beforeOldSuccess = JSON.stringify(lateSuccess)
  onExited(0, 0, lateSuccess, firstRevision, 'Enterprise WiFi', timer, '')
  assertEqual(JSON.stringify(lateSuccess), beforeOldSuccess, 'old enterprise success preserves a newer action failure and prompt')

  const deferred = []
  const queued = {actionRevision: firstRevision, actionKind: '', actionSsid: '', enterpriseRetry,
    connectEnterprise: function() { connectEnterprise(...arguments) }}
  onExited(124, 0, queued, firstRevision, 'Enterprise WiFi', timer, '', true, {callLater: fn => deferred.push(fn)})
  assertEqual(queued.enterpriseRetry, null, 'old exit releases its queued retry payload')
  assertEqual(actionCount, 1, 'retry waits until after the old exit callback completes')
  enterpriseConnect.running = false
  deferred[0]()
  assertEqual(actionCount, 2, 'enterprise automatically starts the queued retry after cleanup exits')
  assertEqual(enterpriseConnect.command.at(-3), 'latest@example.org', 'enterprise starts the latest queued identity')
  assert(enterpriseConnect.actionRevision > firstRevision, 'enterprise retry records a new attempt revision')

  for (const laterKind of ['disconnect', '']) {
    var resumed = 0
    const callbacks = []
    const superseded = {actionRevision: firstRevision, actionKind: '', actionSsid: '',
      enterpriseRetry: {ssid: 'Enterprise WiFi', actionRevision: firstRevision},
      connectEnterprise: function() { resumed++ }}
    onExited(124, 0, superseded, firstRevision, 'Enterprise WiFi', timer, '', true, {callLater: fn => callbacks.push(fn)})
    superseded.actionRevision++
    superseded.actionKind = laterKind
    callbacks[0]()
    assertEqual(resumed, 0, 'queued enterprise retry cannot override a later action that is ' + (laterKind ? 'busy' : 'finished'))
  }

  const actionHelper = panel.match(/function runNetworkAction\([^)]*\) \{[\s\S]*?\n {2}\}/)
  assert(actionHelper, 'network has a production action helper')
  const actionContext = vm.createContext({root: {kind: 'disconnected'}, checkActionCompletion() {}, actionKind: '', actionRevision: 0,
    actionSsid: '', failureSsid: '', failureReason: '', enterpriseRetry: {ssid: 'Old request'}, actionTimeout: {restart: function() {}}})
  vm.runInContext(actionHelper[0], actionContext)
  actionContext.runNetworkAction('connect', {name: 'Enterprise WiFi'}, function() {})
  assertEqual(actionContext.actionRevision, 1, 'production action helper advances the attempt revision')
  assertEqual(actionContext.enterpriseRetry, null, 'an accepted network action discards the queued enterprise request')
  actionContext.enterpriseRetry = {ssid: 'Pending request'}
  actionContext.runNetworkAction('connect', {name: 'Enterprise WiFi'}, function() {})
  assertEqual(actionContext.actionRevision, 1, 'production action helper does not advance a rejected busy attempt')
  assertEqual(actionContext.enterpriseRetry.ssid, 'Pending request', 'a rejected action does not discard an existing enterprise request')
  actionContext.actionKind = ''
  actionContext.runNetworkAction('connect', {name: 'Enterprise WiFi'}, function() {})
  assertEqual(actionContext.actionRevision, 2, 'production action helper advances a later same-SSID retry')
  assertEqual(actionContext.enterpriseRetry, null, 'a later accepted action retires the old enterprise retry')

  const clearContext = vm.createContext({actionKind: 'connect', actionSsid: 'Enterprise WiFi', passwordSsid: 'Other WiFi',
    failureSsid: '', failureReason: '', actionTimeout: {stop: function() {}}, refresh: function() {}})
  vm.runInContext(clearHelper[0], clearContext)
  clearContext.clearNetworkAction()
  assertEqual(clearContext.passwordSsid, 'Other WiFi', 'network completion preserves another credentials prompt')
  clearContext.actionKind = 'connect'
  clearContext.actionSsid = 'Enterprise WiFi'
  clearContext.passwordSsid = 'Enterprise WiFi'
  clearContext.clearNetworkAction()
  assertEqual(clearContext.passwordSsid, '', 'network completion closes its own credentials prompt')
} finally {
  fs.rmSync(scratch, {recursive: true, force: true})
}
JS
