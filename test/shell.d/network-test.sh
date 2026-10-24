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

// The right-edge forget target above is for known networks you are NOT on. The
// connected network gets inline Disconnect / Forget actions instead: clicking
// its row expands them rather than dropping the connection on the spot.
{
  const runPanel = (body, state) => new Function('state', 'with (state) {' + body + '}')(state)

  // Re-hide whenever the prompt changes or closes. Show/hide lives on the
  // panel root next to passwordText so a scan rebuild cannot snap it back.
  const passwordChanged = panelSource.match(/onPasswordSsidChanged: \{([\s\S]*?)\n {2}\}/)
  assert(passwordChanged, 'network reacts to the passphrase prompt opening and closing')
  for (const [description, passwordSsid] of [['closes', ''], ['moves to another network', 'Other']]) {
    const revealState = { showPassword: true, passwordSsid, opened: true, passwordText: 'secret', Qt: { callLater() {} }, panel: { loadedContent: null } }
    runPanel(passwordChanged[1], revealState)
    assertEqual(revealState.showPassword, false, 'network hides the password again when the prompt ' + description)
  }

  // Strings come from the catalog alone: an inline English fallback would
  // hide a missing key instead of failing the catalog check.
  assert(!/I18n\.t\(\s*\"network\.[A-Za-z0-9.]+\"\s*,/.test(panelSource), 'network looks every string up by key with no inline English fallback')

  const rowClick = panelSource.match(/id: rowMouse\b[\s\S]*?onClicked: \{([\s\S]*?)\n {6}\}/)
  assert(rowClick, 'network row has a click handler')
  const clickCalls = []
  const clickState = row => ({
    row,
    root: {
      cursorActive: false,
      focusSection: '',
      selectedIndex: -1,
      wifiActionFocused: true,
      toggleManage: ssid => clickCalls.push('toggle ' + ssid),
      openPasswordPrompt: ssid => clickCalls.push('prompt ' + ssid),
      connectDirectly: ssid => clickCalls.push('connect ' + ssid),
      disconnectRow: ssid => clickCalls.push('disconnect ' + ssid)
    }
  })
  runPanel(rowClick[1], clickState({ net: { ssid: 'Home' }, isConnected: true, index: 0, requiresCredentials: true, isKnown: true }))
  assertDeepEqual(clickCalls, ['toggle Home'], 'network row click on the connected network expands its actions')
  clickCalls.length = 0
  runPanel(rowClick[1], clickState({ net: { ssid: 'Cafe' }, isConnected: false, index: 1, requiresCredentials: true, isKnown: false }))
  assertDeepEqual(clickCalls, ['prompt Cafe'], 'network row click on an unknown credentialed network opens the passphrase prompt')
  clickCalls.length = 0
  runPanel(rowClick[1], clickState({ net: { ssid: 'Open' }, isConnected: false, index: 2, requiresCredentials: false, isKnown: true }))
  assertDeepEqual(clickCalls, ['connect Open'], 'network row click on a known network connects it')

  const closeFn = panelSource.match(/ {2}function close\(\) \{[\s\S]*?\n {2}\}/)
  assert(closeFn, 'network has close()')
  const closeState = { root: { controller: { hide() {} } }, cancelPasswordPrompt() {}, manageSsid: 'Home' }
  runPanel(closeFn[0] + '\nclose()', closeState)
  assertEqual(closeState.manageSsid, '', 'network collapses the actions when the panel closes')

  const openedChanged = panelSource.match(/onOpenedChanged: \{([\s\S]*?)\n {2}\}/)
  assert(openedChanged, 'network reacts to the panel opening and closing')
  const openedState = {
    manageSsid: 'Home',
    opened: true,
    refresh() {},
    selectedIndex: 3,
    wifiNetworks: [{}, {}],
    wifiActionFocused: true,
    focusSection: 'dns',
    hasCaptivePortal: false,
    dnsProviders: ['auto'],
    dnsProvider: 'auto',
    dnsIndex: 1,
    syncBandIndex() {},
    cursorActive: true
  }
  runPanel(openedChanged[1], openedState)
  assertEqual(openedState.manageSsid, '', 'network starts every open with the actions collapsed')

  const closeRequested = panelSource.match(/onCloseRequested: \{([\s\S]*?)\n {6}\}/)
  assert(closeRequested, 'network handles Esc from the key catcher')
  let closed = false
  const escState = { root: { manageSsid: 'Home', close() { closed = true } } }
  runPanel(closeRequested[1], escState)
  assertEqual(escState.root.manageSsid, '', 'network Esc collapses open actions before closing the panel')
  assert(!closed, 'network Esc does not close the panel while actions are open')
  runPanel(closeRequested[1], escState)
  assert(closed, 'network Esc closes the panel once actions are already collapsed')

  // Run the panel's own selection, activation and action logic against
  // stand-in state, the way the scanner helper is run above.
  const panelLogic = state => {
    const fn = name => {
      const found = panelSource.match(new RegExp(' {2}function ' + name + '\\([^)]*\\) \\{[\\s\\S]*?\\n {2}\\}'))
      assert(found, 'network has ' + name + '()')
      return found[0]
    }
    const binding = panelSource.match(/readonly property bool selectedManageOpen: \{([\s\S]*?)\n {2}\}/)
    assert(binding, 'network derives selectedManageOpen from the keyboard selection')
    Object.defineProperty(state, 'selectedManageOpen', {
      get: () => new Function('state', 'with (state) {' + binding[1] + '}')(state)
    })
    const names = ['toggleManage', 'canForgetNetwork', 'moveWifiCursor', 'selectWifiActionByDelta', 'activateSelected', 'runNetworkAction']
    new Function('state', 'with (state) {' + names.map(fn).join('\n') +
      '\nstate.fns = { toggleManage, moveWifiCursor, selectWifiActionByDelta, activateSelected, runNetworkAction } }')(state)
    return state.fns
  }
  const calls = []
  const newState = overrides => Object.assign({
    Model: network,
    busy: false,
    selectedIndex: 0,
    manageSsid: '',
    manageFocused: false,
    manageIndex: 0,
    wifiActionFocused: false,
    focusSection: 'wifi',
    selectByDelta: delta => calls.push('select ' + delta),
    wifiNetworks: [
      { ssid: 'Home', connected: true, known: true, signal: 80, security: security.Wpa2Psk },
      { ssid: 'Cafe', connected: false, known: true, signal: 50, security: security.Wpa2Psk }
    ],
    actionKind: '',
    actionSsid: '',
    failureSsid: '',
    failureReason: '',
    actionTimeout: { restart() {} },
    disconnectRow: ssid => calls.push('disconnect ' + ssid),
    forget: net => calls.push('forget ' + net.ssid),
    connectDirectly: ssid => calls.push('connect ' + ssid),
    openPasswordPrompt: ssid => calls.push('prompt ' + ssid),
    requiresCredentials: () => true
  }, overrides)

  // Enter on the connected row toggles its actions; it must not act by itself.
  let state = newState()
  let logic = panelLogic(state)
  logic.activateSelected()
  assertEqual(state.manageSsid, 'Home', 'network Enter on the connected row opens its actions')
  assertEqual(calls.length, 0, 'network Enter on the connected row neither disconnects nor forgets')
  assertEqual(state.selectedManageOpen, true, 'network recognises the open actions on the selected row')
  logic.activateSelected()
  assertEqual(state.manageSsid, '', 'network Enter on the connected row closes its actions again')
  logic.toggleManage('Home')
  logic.toggleManage('Cafe')
  assertEqual(state.manageSsid, 'Cafe', 'network opening another row switches the actions rather than stacking them')

  // l/h: from the row into the buttons, then between them, clamped to both.
  state = newState({ manageSsid: 'Home' })
  logic = panelLogic(state)
  logic.selectWifiActionByDelta(-1)
  assertEqual(state.manageFocused, false, 'network h on the row does not enter the actions')
  logic.selectWifiActionByDelta(1)
  assertEqual(state.manageFocused, true, 'network l on the row enters the actions')
  assertEqual(state.manageIndex, 0, 'network entering the actions lands on Disconnect, not the destructive Forget')
  logic.selectWifiActionByDelta(-1)
  assertEqual(state.manageIndex, 0, 'network cursor stops at the first action')
  logic.selectWifiActionByDelta(1)
  logic.selectWifiActionByDelta(1)
  assertEqual(state.manageIndex, 1, 'network cursor stops at the last action')
  assertEqual(state.manageFocused, true, 'network cursor stays inside the actions while moving between them')

  // Enter on a focused action runs exactly that action -- including Forget on
  // the connected network, which the row's right-edge target never offers.
  calls.length = 0
  state.manageIndex = 0
  logic.activateSelected()
  assertDeepEqual(calls, ['disconnect Home'], 'network Enter on Disconnect disconnects the connected network')
  calls.length = 0
  state.manageIndex = 1
  logic.activateSelected()
  assertDeepEqual(calls, ['forget Home'], 'network Enter on Forget forgets the connected network')
  calls.length = 0
  state.busy = true
  logic.activateSelected()
  assertEqual(calls.length, 0, 'network ignores an action while another one is running')
  assertEqual(state.selectedManageOpen, false, 'network drops the open actions while an action is running')

  // Up/down arrows: into the buttons, back out, on to the next row.
  calls.length = 0
  state = newState({ manageSsid: 'Home' })
  logic = panelLogic(state)
  logic.moveWifiCursor(1)
  assert(state.manageFocused && state.manageIndex === 0, 'network down arrow on the connected row steps into the actions')
  assertEqual(calls.length, 0, 'network stepping into the actions does not move the row cursor')
  logic.moveWifiCursor(-1)
  assertEqual(state.manageFocused, false, 'network up arrow on the actions steps back to the row')
  assertEqual(calls.length, 0, 'network stepping back to the row does not move to another row')
  logic.moveWifiCursor(1)
  logic.moveWifiCursor(1)
  assert(!state.manageFocused && calls.join() === 'select 1', 'network down arrow on the actions moves on to the next row')
  calls.length = 0
  state = newState({ manageSsid: 'Cafe', selectedIndex: 1, wifiNetworks: [
    { ssid: 'Cafe', connected: true, known: true, signal: 50, security: security.Wpa2Psk }
  ], manageFocused: true })
  state.selectedIndex = 0
  logic = panelLogic(state)
  logic.moveWifiCursor(1)
  assert(state.manageFocused && calls.length === 0, 'network down arrow on the last row stays on the actions instead of dropping out')
  state = newState()
  logic = panelLogic(state)
  logic.moveWifiCursor(1)
  assert(!state.manageFocused && calls.join() === 'select 1', 'network down arrow without open actions just moves to the next row')
  calls.length = 0
  logic.moveWifiCursor(-1)
  assertEqual(state.focusSection, 'dns', 'network up arrow on the top row still escapes to the DNS row')
  assertEqual(calls.length, 0, 'network up arrow on the top row does not wrap around the list')

  // The actions only exist for the connected row.
  state = newState()
  logic = panelLogic(state)
  logic.selectWifiActionByDelta(1)
  assertEqual(state.manageFocused, false, 'network l on a connected row with no open actions enters nothing')
  assertEqual(state.wifiActionFocused, false, 'network l on the connected row keeps its forget target hidden')
  state = newState({ manageSsid: 'Home', selectedIndex: 1 })
  logic = panelLogic(state)
  assertEqual(state.selectedManageOpen, false, 'network open actions do not follow the cursor to another row')
  logic.selectWifiActionByDelta(1)
  assertEqual(state.manageFocused, false, 'network l on another row does not enter the connected row actions')
  assertEqual(state.wifiActionFocused, true, 'network l on a known disconnected row still reaches its forget target')
  logic.activateSelected()
  assertDeepEqual(calls.slice(-1), ['forget Cafe'], 'network Enter on a known disconnected row still forgets it')
  state = newState({ manageSsid: 'Home', wifiNetworks: [{ ssid: 'Home', connected: false, known: true, signal: 80, security: security.Wpa2Psk }] })
  logic = panelLogic(state)
  assertEqual(state.selectedManageOpen, false, 'network closes the actions once the network is no longer connected')

  // Starting any action collapses the panel; a refused action leaves it alone.
  state = newState({ manageSsid: 'Home' })
  logic = panelLogic(state)
  let ran = false
  logic.runNetworkAction('forget', { name: 'Home' }, () => { ran = true })
  assert(ran && state.actionKind === 'forget' && state.actionSsid === 'Home', 'network runs the requested action')
  assertEqual(state.manageSsid, '', 'network collapses the actions as soon as an action starts')
  state = newState({ manageSsid: 'Home', actionKind: 'connect' })
  logic = panelLogic(state)
  ran = false
  logic.runNetworkAction('forget', { name: 'Home' }, () => { ran = true })
  assert(!ran && state.manageSsid === 'Home', 'network leaves the actions open when another action is already running')
}

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
