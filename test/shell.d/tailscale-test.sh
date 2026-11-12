#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const tailscale = requireFromRoot('shell/plugins/panels/tailscale/Model.js')
const serviceSource = fs.readFileSync(root + '/shell/plugins/panels/tailscale/Service.qml', 'utf8')


// Execute the real QML helper bodies, with only their environment stubbed.
const vm = require('vm')
// Translate through the English catalog, as the shell does by default.
const english = JSON.parse(fs.readFileSync(root + '/default/i18n/en/shell.json', 'utf8'))
const I18n = { t: key => english[key] }
const context = { I18n, elideStatus: text => String(text || '').trim(), actionStatusTimer: { stop() {}, restart() {} } }
for (const name of ['timedCommand', 'showActionError']) {
  const body = serviceSource.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))
  assert(body, 'tailscale defines ' + name)
  vm.runInNewContext(body[0], context)
}
assertDeepEqual(Array.from(context.timedCommand(['tailscale', 'down'])), ['timeout', '--foreground', '--kill-after=2s', '20s', 'tailscale', 'down'], 'tailscale finite commands have a deadline and forced-termination grace period')
for (const code of [124, 137]) {
  let stopped = false
  context.actionStatusTimer = { stop() { stopped = true }, restart() { throw new Error('timeout must remain visible') } }
  context.showActionError(code, '', 'fallback')
  assert(context.actionStatus.includes('timed out') && stopped, 'tailscale preserves timeout feedback for exit ' + code)
}
let errorTimerRestarted = false
context.actionStatusTimer = { stop() {}, restart() { errorTimerRestarted = true } }
context.showActionError(1, 'daemon unavailable', 'fallback')
assertEqual(context.lastError, 'daemon unavailable', 'tailscale preserves ordinary command errors')
assert(errorTimerRestarted, 'ordinary errors still start the transient-message timer')
context.showActionError(1, '', 'fallback')
assertEqual(context.lastError, 'fallback', 'tailscale supplies a fallback for empty command errors')
for (const process of ['actionProcess', 'loginProcess', 'switchProcess', 'exitNodeProcess']) {
  let refreshed = false
  Object.assign(context, {
    root: context, _desired: 1, _loginInProgress: true, _loginUrlOpened: false, _loginTimedOut: false,
    switchingAccountId: 'pending', settingExitNodeId: 'pending',
    actionStdout: {}, actionStderr: {}, switchStdout: {}, switchStderr: {}, exitNodeStdout: {}, exitNodeStderr: {},
    loginTimeoutTimer: { stop() {} }, connectTimeoutTimer: { stop() {} },
    delayedRefresh: { restart() { refreshed = true } }
  })
  const section = serviceSource.slice(serviceSource.indexOf('id: ' + process))
  const handler = section.match(/onExited: (function\(exitCode\) \{[^]*?\n    \})/)[1]
  vm.runInNewContext('(' + handler + ')(124)', context)
  assert(refreshed && context.actionStatus.includes('timed out'), process + ' refreshes status and reports timeout')
  if (process === 'actionProcess' || process === 'loginProcess') assertEqual(context._desired, -1, process + ' drops optimistic state')
  if (process === 'loginProcess') assert(!context._loginInProgress, 'login timeout clears the pending login')
  if (process === 'switchProcess') assertEqual(context.switchingAccountId, '', 'account timeout clears pending selection')
  if (process === 'exitNodeProcess') assertEqual(context.settingExitNodeId, '', 'exit-node timeout clears pending selection')
}

let openedLoginUrl = ''
let browserOpens = 0
let statusRefreshes = 0
const timer = () => ({ running: false, restart() { this.running = true }, stop() { this.running = false } })
const loginTransition = {
  I18n, Model: tailscale, installed: true, _desired: 1, _loginInProgress: false,
  _loginUrlOpened: false, _loginTimedOut: false, _preLoginAuthUrl: '',
  loginProcess: { running: true, command: [] }, mullvadRegions: [], selectedAccountId: '',
  actionProcess: { running: false }, switchProcess: { running: false }, exitNodeProcess: { running: false },
  actionStatusTimer: timer(), connectTimeoutTimer: timer(), loginTimeoutTimer: timer(),
  stateWatchRefreshTimer: { restart() { statusRefreshes++ } }, timedCommand: context.timedCommand,
  exitNodeTarget: () => 'test-peer', authUrlOpened() {},
  _statusFullPeers: false, publishPeers() {}, publishTailnetExitNodes() {}, syncExitNodes() {},
  Quickshell: { execDetached(args) { openedLoginUrl = args[1]; browserOpens++ } }
}
loginTransition.root = loginTransition
for (const name of ['parseStatus', 'loginOrUp', 'openAuthUrl', 'down', 'runAction', 'handleStateWatchData', 'switchAccount', 'setExitNode', 'handleLoginOutput']) {
  const body = serviceSource.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))[0]
  vm.runInNewContext(body, loginTransition)
}
const expiredAfterResume = JSON.stringify({ BackendState: 'NeedsLogin', AuthURL: '' })
loginTransition.parseStatus(expiredAfterResume)
assertEqual(loginTransition._desired, 1, 'expired-key transition waits for the in-flight resume request')
assert(!loginTransition._loginInProgress, 'expired-key transition does not overlap CLI requests')
loginTransition.loginProcess.running = false
loginTransition.parseStatus(expiredAfterResume)
assert(loginTransition._loginInProgress && loginTransition.loginProcess.running, 'resume automatically continues into login when the key is expired')
assertDeepEqual(Array.from(loginTransition.loginProcess.command), Array.from(context.timedCommand(tailscale.loginPlan(true, '').command)), 'expired-key resume requests interactive login exactly as a login click would')
assertEqual(loginTransition._desired, -1, 'expired-key continuation consumes the pending connection intent')
for (const desired of [-1, 0]) {
  loginTransition._desired = desired
  loginTransition._loginInProgress = false
  loginTransition.loginProcess = { running: false, command: [] }
  loginTransition.parseStatus(expiredAfterResume)
  assert(!loginTransition.loginProcess.running, 'passive or cancelled expired-key status never starts login: ' + desired)
}
loginTransition._desired = 1
loginTransition.parseStatus(JSON.stringify({ BackendState: 'NeedsLogin', AuthURL: 'https://login.tailscale.com/a/test' }))
assertEqual(openedLoginUrl, 'https://login.tailscale.com/a/test', 'expired-key resume opens an already available login URL without another click')
openedLoginUrl = ''
loginTransition.parseStatus(JSON.stringify({ BackendState: 'Running' }))
assertEqual(loginTransition.statusText, 'Connected', 'background login completion still updates connection state')
assertEqual(openedLoginUrl, '', 'background login completion does not launch another browser')

for (const retry of [() => loginTransition.loginOrUp(), () => loginTransition.runAction(['tailscale', 'down']), () => loginTransition.switchAccount('other'), () => loginTransition.setExitNode({ id: 'peer' })]) {
  loginTransition.lastError = loginTransition.actionStatus = 'old timeout'
  loginTransition.actionStatusTimer.restart()
  retry()
  assertEqual(loginTransition.lastError, '', 'retry clears the previous error')
  assertEqual(loginTransition.actionStatus, '', 'retry clears the previous timeout message')
  assert(!loginTransition.actionStatusTimer.running, 'retry stops the previous message timer')
}
for (const process of ['loginProcess', 'actionProcess', 'switchProcess', 'exitNodeProcess']) {
  assertEqual(loginTransition[process].command[0], 'timeout', 'tailscale bounds ' + process)
}
loginTransition.loginProcess.running = false
loginTransition._desired = -1
loginTransition.parseStatus(expiredAfterResume)
loginTransition.loginOrUp()
loginTransition.loginProcess.running = false // POST has returned; URL is still pending.
const deadline = serviceSource.slice(serviceSource.indexOf('id: loginTimeoutTimer')).match(/onTriggered: (\{[^]*?\n    \})/)[1]
vm.runInNewContext('(function() ' + deadline + ')()', loginTransition)
assert(!loginTransition._loginInProgress && loginTransition._loginTimedOut, 'login-link deadline ends the pending intent')
assertEqual(statusRefreshes, 1, 'login-link deadline requests fresh status even when the watcher is unavailable')
const lateUrl = 'https://login.tailscale.com/a/late'
const opensBeforeTimeout = browserOpens
loginTransition.handleStateWatchData(JSON.stringify({ BrowseToURL: lateUrl }))
loginTransition.parseStatus(JSON.stringify({ BackendState: 'NeedsLogin', AuthURL: lateUrl }))
assertEqual(browserOpens, opensBeforeTimeout, 'neither a late notification nor status response opens a browser after timeout')
loginTransition.loginOrUp()
assertEqual(openedLoginUrl, lateUrl, 'manual retry opens the URL cached by the status refresh')
assertEqual(browserOpens, opensBeforeTimeout + 1, 'manual retry opens the browser once')
loginTransition.openAuthUrl(lateUrl)
assertEqual(browserOpens, opensBeforeTimeout + 1, 'duplicate authentication URL cannot open another browser')

loginTransition.parseStatus(expiredAfterResume)
loginTransition.loginOrUp()
loginTransition.loginProcess.running = false
loginTransition.actionProcess.running = false
assert(loginTransition._loginInProgress && loginTransition.loginTimeoutTimer.running, 'login wait is active before disconnect')
loginTransition.down()
assert(!loginTransition._loginInProgress && !loginTransition.loginTimeoutTimer.running, 'disconnect cancels login intent and its deadline')
const opensBeforeDisconnect = browserOpens
loginTransition.handleStateWatchData(JSON.stringify({ BrowseToURL: lateUrl }))
loginTransition.parseStatus(JSON.stringify({ BackendState: 'NeedsLogin', AuthURL: lateUrl }))
vm.runInNewContext('(function() ' + deadline + ')()', loginTransition)
assertEqual(browserOpens, opensBeforeDisconnect, 'late URL after disconnect cannot launch the browser')
assertEqual(loginTransition.actionStatus, '', 'cancelled login cannot later show a login timeout')

// Toggles from the keyboard, bar and IPC follow the busy switch.
vm.runInNewContext(serviceSource.match(/  function toggleTailscale\([^]*?\n  \}/)[0], loginTransition)
const realDown = loginTransition.down
const realLoginOrUp = loginTransition.loginOrUp
let toggles = 0
loginTransition.down = loginTransition.loginOrUp = () => { toggles++ }
loginTransition.active = true
for (const [connecting, waitingForLogin] of [[true, false], [false, true]]) {
  Object.assign(loginTransition, { connecting, waitingForLogin })
  loginTransition.toggleTailscale()
}
assertEqual(toggles, 0, 'keyboard, bar and IPC toggles are ignored while connecting or waiting for a login link')
Object.assign(loginTransition, { connecting: false, waitingForLogin: false })
loginTransition.toggleTailscale()
assertEqual(toggles, 1, 'toggles work again once the connection settles')
Object.assign(loginTransition, { down: realDown, loginOrUp: realLoginOrUp })

// A disconnect supersedes a resume request that is still in flight.
const loginExit = serviceSource.slice(serviceSource.indexOf('id: loginProcess')).match(/onExited: (function\(exitCode\) \{[^]*?\n    \})/)[1]
Object.assign(loginTransition, {
  needsLogin: false, _loginTimedOut: false, _loginSuperseded: false, lastError: '', actionStatus: '',
  loginProcess: { running: false, command: [] }, actionProcess: { running: false },
  delayedRefresh: { restart() {} }, showActionError() { loginTransition.lastError = 'login error' }
})
loginTransition.loginOrUp()
assert(loginTransition.loginProcess.running && loginTransition._desired === 1, 'resume request is in flight')
loginTransition.down()
vm.runInNewContext('(' + loginExit + ')(124)', loginTransition)
assertEqual(loginTransition._desired, 0, 'a superseded resume request cannot undo the requested off state')
assertEqual(loginTransition.lastError, '', 'a superseded resume request reports no error')
assert(!loginTransition._loginSuperseded, 'the superseded marker clears when the request exits')

// The resume response is the full prefs object, ControlURL included, and
// `tailscale debug localapi` narrates the request on stderr.
let reportedOutput = null
Object.assign(loginTransition, {
  _desired: 1, _loginInProgress: false, _loginUrlOpened: false, _loginOutput: '', _loginError: '',
  showActionError(exitCode, output) { reportedOutput = output }
})
const opensBeforeResponse = browserOpens
for (const line of ['{', '  "ControlURL": "https://controlplane.tailscale.com",', '  "WantRunning": true', '}']) loginTransition.handleLoginOutput(line, false)
loginTransition.handleLoginOutput('# doing request PATCH /localapi/v0/prefs', true)
vm.runInNewContext('(' + loginExit + ')(0)', loginTransition)
assertEqual(browserOpens, opensBeforeResponse, 'a URL in the command output never opens the browser')
loginTransition.handleLoginOutput('# doing request POST /localapi/v0/login-interactive', true)
loginTransition.handleLoginOutput('# Response status 403 Forbidden', true)
loginTransition.handleLoginOutput('access denied', true)
vm.runInNewContext('(' + loginExit + ')(1)', loginTransition)
assertEqual(reportedOutput.trim(), 'access denied', 'login errors leave out the LocalAPI request commentary')

// A key that expired while stopped: after the resume PATCH, tailscaled
// reports Running from its cached netmap for about a second, then NeedsLogin.
// The transient Running settles _desired, but the same click must still log in.
const connectDeadline = serviceSource.slice(serviceSource.indexOf('id: connectTimeoutTimer')).match(/onTriggered: (\{[^]*?\n    \})/)[1]
function resumeFromStopped() {
  Object.assign(loginTransition, {
    needsLogin: false, authUrl: '', _desired: -1, _loginInProgress: false, _loginUrlOpened: false,
    _loginTimedOut: false, _loginSuperseded: false, _resumePending: false, running: false,
    loginProcess: { running: false, command: [] }, actionProcess: { running: false }
  })
  loginTransition.loginOrUp()
  assertDeepEqual(Array.from(loginTransition.loginProcess.command), Array.from(context.timedCommand(tailscale.loginPlan(false, '').command)), 'turning on from Stopped sends the resume request')
  loginTransition.loginProcess.running = false // the PATCH returns at once
  loginTransition.parseStatus(JSON.stringify({ BackendState: 'Running' }))
  assertEqual(loginTransition._desired, -1, 'a transient Running settles the optimistic on state')
}
resumeFromStopped()
loginTransition.parseStatus(expiredAfterResume)
assert(loginTransition._loginInProgress && loginTransition.loginProcess.running, 'resume continues into login when NeedsLogin follows a transient Running')
assertDeepEqual(Array.from(loginTransition.loginProcess.command), Array.from(context.timedCommand(tailscale.loginPlan(true, '').command)), 'the continuation requests interactive login')
assert(!loginTransition._resumePending, 'starting the login consumes the resume intent')

resumeFromStopped()
loginTransition.down()
loginTransition.actionProcess.running = false
loginTransition.parseStatus(expiredAfterResume)
assert(!loginTransition._loginInProgress && !loginTransition.loginProcess.running, 'a disconnect after a transient Running cancels the resume intent')

resumeFromStopped()
vm.runInNewContext('(function() ' + connectDeadline + ')()', loginTransition)
loginTransition.parseStatus(expiredAfterResume)
assert(!loginTransition._loginInProgress && !loginTransition.loginProcess.running, 'a key expiring after the connect deadline does not start a login on its own')

// A background refresh with the panel closed runs the status client alone.
const polling = { installed: true, peersWanted: false, accounts: [], _lastAccountsRefreshMs: 0, pollWatchdog: { running: false, start() { this.running = true } } }
vm.runInNewContext(serviceSource.match(/  function refreshStatusAndAccounts\([^]*?\n  \}/)[0], polling)
function pollClients(peersWanted, forceAccounts, fullPeers) {
  const launched = []
  Object.assign(polling, {
    peersWanted,
    startStatusRefresh() { launched.push('status'); return true },
    mullvadExitNodesProcess: { running: false, set command(c) { launched.push('exit-node') } },
    accountsProcess: { running: false, set command(c) { launched.push('accounts') } }
  })
  polling.refreshStatusAndAccounts(forceAccounts, fullPeers)
  return launched
}
assertDeepEqual(pollClients(false, false, false), ['status'], 'a background refresh with the panel closed runs only the status client')
assertDeepEqual(pollClients(true, false, false), ['status', 'exit-node', 'accounts'], 'the open panel refreshes exit nodes and accounts')
assertDeepEqual(pollClients(false, false, true), ['status', 'exit-node', 'accounts'], 'opening the panel fetches exit nodes and accounts before its binding settles')

// Health notifications arrive every few seconds and do not change the panel.
const refreshesBefore = statusRefreshes
loginTransition.handleStateWatchData(JSON.stringify({ Version: '1.102.3', Health: {} }))
assertEqual(statusRefreshes, refreshesBefore, 'health-only IPN notifications do not query status')
for (const field of ['State', 'Prefs', 'LoginFinished']) loginTransition.handleStateWatchData(JSON.stringify({ [field]: field === 'State' ? 6 : {} }))
assertEqual(statusRefreshes, refreshesBefore + 3, 'state, preference and login notifications refresh status')

// The IPN bus must not carry the node's private key (NotifyNoPrivateKeys = 16).
const watch = { installed: true, _stateWatchBackoffMs: 2000, stateWatchProcess: { running: false, command: [] } }
for (const name of ['startStateWatch', 'scheduleStateWatchRestart']) {
  vm.runInNewContext(serviceSource.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))[0], watch)
}
watch.startStateWatch()
const watchPath = watch.stateWatchProcess.command[watch.stateWatchProcess.command.length - 1]
const watchMask = Number(new URL(watchPath, 'http://local-tailscaled').searchParams.get('mask'))
assert(watch.stateWatchProcess.running && (watchMask & 16) && (watchMask & 2), 'tailscale watches the IPN bus from its initial state without private keys')

// Restarts back off while tailscaled is unreachable, and reset once it answers.
const restartDelays = []
watch.stateWatchRestartTimer = { interval: 0, restart() { restartDelays.push(this.interval) } }
for (let i = 0; i < 7; i++) watch.scheduleStateWatchRestart()
assertDeepEqual(restartDelays, [2000, 4000, 8000, 16000, 32000, 60000, 60000], 'tailscale backs off IPN watcher restarts from two seconds to a minute')
loginTransition._stateWatchBackoffMs = 60000
loginTransition.handleStateWatchData('Failed to connect to local Tailscale daemon')
assertEqual(loginTransition._stateWatchBackoffMs, 60000, 'an error line does not reset the IPN watcher backoff')
loginTransition.handleStateWatchData(JSON.stringify({ Version: '1.102.3' }))
assertEqual(loginTransition._stateWatchBackoffMs, 2000, 'a parsed notification resets the IPN watcher backoff')

// With the panel closed nothing polls, so the watcher exiting is the only sign tailscaled stopped.
const watchExit = serviceSource.slice(serviceSource.indexOf('id: stateWatchProcess')).match(/onExited: (function\(exitCode\) \{[^]*?\n    \})/)[1]
let watchExitRefreshes = 0
const watchExitContext = { root: { scheduleStateWatchRestart() {} }, stateWatchRefreshTimer: { restart() { watchExitRefreshes++ } } }
vm.runInNewContext('(' + watchExit + ')(1)', watchExitContext)
assertEqual(watchExitRefreshes, 1, 'the IPN watcher exiting refreshes status')

assertDeepEqual(
  tailscale.filterIPv4(['100.64.0.1', 'fd7a:115c:a1e0::1', '192.168.1.2']),
  ['100.64.0.1'],
  'tailscale keeps only Tailscale IPv4 addresses'
)
assertDeepEqual(
  tailscale.filterIPv6(['100.64.0.1', 'fd7a:115c:a1e0::1', 'fe80::1']),
  ['fd7a:115c:a1e0::1'],
  'tailscale keeps only Tailscale IPv6 addresses'
)

assertEqual(tailscale.cleanDnsName('work.tailnet.ts.net.'), 'work.tailnet.ts.net', 'tailscale strips trailing DNS dot')
assertEqual(tailscale.displayHostName('localhost', 'work.tailnet.ts.net.'), 'work', 'tailscale falls back from localhost to short DNS name')

const status = tailscale.parseStatus(JSON.stringify({
  BackendState: 'Running',
  AuthURL: '',
  TailscaleIPs: ['100.74.97.73', 'fd7a:115c:a1e0::ff32:6149'],
  Self: {
    HostName: 'dhh-fd',
    DNSName: 'dhh-fd.tail32f559.ts.net.',
    TailscaleIPs: ['100.74.97.73'],
    UserID: 1001,
    CapMap: { 'https://tailscale.com/cap/file-sharing': null }
  },
  Peer: {
    onlineB: {
      HostName: 'zed',
      DNSName: 'zed.tail32f559.ts.net.',
      TailscaleIPs: ['100.1.1.2'],
      Online: true,
      OS: 'linux',
      ExitNodeOption: true,
      ExitNode: true,
      UserID: 1002,
      TaildropTarget: 5
    },
    offline: {
      HostName: 'offline',
      DNSName: 'offline.tail32f559.ts.net.',
      TailscaleIPs: ['100.1.1.3'],
      Online: false,
      OS: 'linux'
    },
    offlineExit: {
      HostName: 'mbu-ser9',
      DNSName: 'mbu-ser9.tail32f559.ts.net.',
      TailscaleIPs: ['100.125.28.77', 'fd7a:115c:a1e0::1037:1c4d'],
      Online: false,
      OS: 'linux',
      ExitNodeOption: true,
      ExitNode: false
    },
    onlineA: {
      HostName: 'alpha',
      DNSName: 'alpha.tail32f559.ts.net.',
      TailscaleIPs: ['100.1.1.1', 'fd7a:115c:a1e0::1901:334b'],
      Online: true,
      OS: 'macos',
      UserID: 1001,
      TaildropTarget: 1
    },
    mullvadExit: {
      HostName: 'al-tia-wg-003',
      DNSName: 'al-tia-wg-003.mullvad.ts.net.',
      TailscaleIPs: ['100.95.87.11'],
      Online: true,
      OS: 'linux',
      ExitNodeOption: true,
      ExitNode: false
    }
  }
}))

assert(status.ok && status.running, 'tailscale parses running status')
assertEqual(status.selfIp, '100.74.97.73', 'tailscale parses self IP')
assertDeepEqual(status.peers.map(peer => peer.HostName), ['alpha', 'zed'], 'tailscale filters offline and Mullvad peers and sorts online peers')
assertDeepEqual(status.peers[0].TailscaleIPv6, ['fd7a:115c:a1e0::1901:334b'], 'tailscale preserves peer IPv6 addresses for copy menu')
assert(status.peers[1].ExitNodeOption && status.peers[1].ExitNode, 'tailscale preserves exit node flags')
assertDeepEqual(status.exitNodes.map(peer => peer.HostName), ['zed'], 'tailscale lists only online tailnet exit nodes')
assert(tailscale.isMullvadPeer({ HostName: 'al-tia-wg-003', DNSName: 'al-tia-wg-003.mullvad.ts.net.' }), 'tailscale detects Mullvad status peers')

assert(status.fileSharing, 'tailscale reads Taildrop capability from the status capability map')
assertEqual(status.selfUserId, '1001', 'tailscale records the owning user of this machine')
assertDeepEqual(status.peers.map(peer => peer.UserID), ['1001', '1002'], 'tailscale records the owning user of each peer')
assert(
  tailscale.hasFileSharing({ Capabilities: ['https://tailscale.com/cap/file-sharing'] }),
  'tailscale reads Taildrop capability from the legacy capability list'
)
assert(!tailscale.hasFileSharing({ CapMap: { funnel: null } }), 'tailscale reports no Taildrop without the capability')
assertDeepEqual(status.peers.map(peer => peer.TaildropTarget), [1, 5], 'tailscale records how Tailscale grades each Taildrop target')
assert(tailscale.isTaildropTarget({ TaildropTarget: 1, UserID: '1001' }, '2002'), 'tailscale trusts an available Taildrop target')
assert(!tailscale.isTaildropTarget({ TaildropTarget: 7, UserID: '1001' }, '1001'), 'tailscale skips peers Tailscale rules out')
assert(tailscale.isTaildropTarget({ UserID: '1001' }, '1001'), 'tailscale falls back to same-owner peers without a grade')
assert(!tailscale.isTaildropTarget({ UserID: '1002' }, '1001'), 'tailscale skips other owners without a grade')

const mullvadNodes = tailscale.parseExitNodeList(`
 IP                  HOSTNAME                         COUNTRY            CITY                   STATUS
 100.65.216.13       au-adl-wg-301.mullvad.ts.net     Australia          Any                    -
 100.65.216.13       au-adl-wg-301.mullvad.ts.net     Australia          Adelaide               -
 100.70.240.117      au-bne-wg-301.mullvad.ts.net     Australia          Brisbane               -
 100.66.11.119       dk-cph-wg-001.mullvad.ts.net     Denmark            Copenhagen             -
 100.101.10.10       us-chi-wg-001.mullvad.ts.net     United States      Chicago                -
 100.102.10.10       us-nyc-wg-001.mullvad.ts.net     United States      New York               -
 100.1.2.3           office.tailnet.ts.net             Denmark            Office                 -

# To use an exit node, use tailscale set --exit-node=
`)

assertDeepEqual(
  mullvadNodes.map(node => node.DisplayName),
  ['Adelaide, Australia', 'Brisbane, Australia', 'Copenhagen, Denmark', 'Chicago, United States', 'New York, United States'],
  'tailscale parses Mullvad exit nodes and skips duplicate country rows'
)
assertEqual(mullvadNodes[2].DNSName, 'dk-cph-wg-001.mullvad.ts.net', 'tailscale preserves Mullvad hostname as exit node target')
assertDeepEqual(mullvadNodes[2].TailscaleIPs, ['100.66.11.119'], 'tailscale preserves Mullvad exit node IP')
assert(mullvadNodes.every(node => node.Mullvad === true && node.ExitNodeOption === true), 'tailscale marks Mullvad rows as exit nodes')

const mullvadRegions = tailscale.mullvadRegionOptions(mullvadNodes)
assertDeepEqual(
  mullvadRegions.map(node => node.DisplayName),
  ['Adelaide, Australia', 'Brisbane, Australia', 'Copenhagen, Denmark', 'Chicago, United States', 'New York, United States'],
  'tailscale groups Mullvad exit nodes by unique city region'
)
assertDeepEqual(
  mullvadRegions.filter(node => node.Country === 'United States').map(node => node.City),
  ['Chicago', 'New York'],
  'tailscale keeps multiple Mullvad cities within a country'
)
assertEqual(mullvadRegions[0].DNSName, 'au-adl-wg-301.mullvad.ts.net', 'tailscale uses a concrete city endpoint for grouped regions')
assertEqual(mullvadRegions[2].DNSName, 'dk-cph-wg-001.mullvad.ts.net', 'tailscale preserves first available city endpoint')

const stopped = tailscale.parseStatus(JSON.stringify({
  BackendState: 'Stopped',
  Peer: {
    online: {
      HostName: 'alpha',
      DNSName: 'alpha.tail32f559.ts.net.',
      TailscaleIPs: ['100.1.1.1'],
      Online: true,
      OS: 'macos'
    }
  }
}))

assert(stopped.ok && !stopped.running, 'tailscale parses stopped status')

const loginRequired = tailscale.parseStatus(JSON.stringify({
  BackendState: 'NeedsLogin',
  AuthURL: 'https://login.tailscale.com/a/explicit',
  ControlURL: 'https://controlplane.tailscale.com',
  Peer: {}
}))
assertEqual(loginRequired.authUrl, 'https://login.tailscale.com/a/explicit', 'tailscale reads the explicit daemon authorization URL')

const controlUrlOnly = tailscale.parseStatus(JSON.stringify({
  BackendState: 'NeedsLogin',
  ControlURL: 'https://controlplane.tailscale.com',
  Peer: {}
}))
assertEqual(controlUrlOnly.authUrl, '', 'tailscale does not treat ControlURL as an authorization URL')

const accounts = tailscale.parseAccounts(JSON.stringify([
  {
    id: 'db1b',
    nickname: 'Home',
    tailnet: 'dhh.github',
    account: 'dhh@github',
    selected: true
  },
  {
    id: '1785',
    nickname: 'Work',
    tailnet: '37signals.com',
    account: 'david@37signals.com',
    selected: false
  }
]))

assertEqual(accounts.accounts.length, 2, 'tailscale parses multiple connections')
assertEqual(accounts.selectedAccountId, 'db1b', 'tailscale records selected connection id')
assertEqual(accounts.selectedAccountLabel, 'Home', 'tailscale labels connections by nickname')
assertDeepEqual(
  accounts.accounts.map(account => account.nickname),
  ['Home', 'Work'],
  'tailscale preserves connection nicknames'
)
assertEqual(
  tailscale.accountLabel({ nickname: '', tailnet: 'tailnet.example', account: 'user@example', id: 'abcd' }),
  'tailnet.example',
  'tailscale labels connections by tailnet when nickname is missing'
)

const existingAuthPlan = tailscale.loginPlan(true, 'https://login.tailscale.com/a/existing')
const interactiveLoginPlan = tailscale.loginPlan(true, '')
const resumePlan = tailscale.loginPlan(false, 'https://login.tailscale.com/a/stale')

assertDeepEqual(
  existingAuthPlan,
  { authUrl: 'https://login.tailscale.com/a/existing', command: [] },
  'tailscale reuses the daemon authorization URL without replacing node identity'
)
assertDeepEqual(
  interactiveLoginPlan,
  { authUrl: '', command: ['tailscale', 'debug', 'localapi', 'POST', '/localapi/v0/login-interactive'] },
  'tailscale requests interactive login through LocalAPI when the daemon has not supplied a URL'
)
assertDeepEqual(
  resumePlan,
  { authUrl: '', command: ['tailscale', 'debug', 'localapi', 'PATCH', '/localapi/v0/prefs', '{"WantRunning":true,"WantRunningSet":true}'] },
  'tailscale resumes through LocalAPI while ignoring stale authorization URLs'
)
assertDeepEqual(
  JSON.parse(resumePlan.command[5]),
  { WantRunning: true, WantRunningSet: true },
  'tailscale masks and enables the persisted running preference'
)
assert(
  [existingAuthPlan, interactiveLoginPlan, resumePlan].every(plan => plan.command.join(' ') !== 'tailscale up'),
  'tailscale login plans never invoke tailscale up'
)

assertDeepEqual(tailscale.parseStatus('{'), { ok: false, unavailable: true, message: 'Status error', error: 'Failed to parse tailscale status' }, 'tailscale reports invalid status JSON')
assertDeepEqual(tailscale.parseAccounts('{'), { accounts: [], selectedAccountId: '', selectedAccountLabel: '' }, 'tailscale handles invalid account JSON')
JS
