#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const tailscale = requireFromRoot('shell/plugins/panels/tailscale/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/tailscale/Panel.qml', 'utf8')
const serviceSource = fs.readFileSync(root + '/shell/plugins/panels/tailscale/Service.qml', 'utf8')

assert(/function toggleTailscale\(\): string \{ tailscale\.toggleTailscale\(\); return "ok" \}/.test(panelSource), 'tailscale exposes the connection toggle over IPC')
assert(serviceSource.includes('readonly property bool connecting: _desired === 1 && !running && !needsLogin'), 'tailscale exposes its optimistic connection state')
assert(/Quickshell\.execDetached\(\["omarchy-launch-browser", url\]\)[\s\S]*?authUrlOpened\(\)\s+actionStatus = ""\s+lastError = ""\s+_desired = -1/.test(serviceSource), 'tailscale closes the panel before dropping optimistic state after opening the authentication browser')
assert(panelSource.includes('function onAuthUrlOpened() { root.close() }'), 'tailscale closes its panel when handing login to the browser')
assert(!panelSource.includes('onLoginCompleted') && !serviceSource.includes('loginCompleted') && !serviceSource.includes('_reopenAfterLogin'), 'background login completion cannot reopen the panel and steal keyboard focus')
assert(panelSource.includes('showPeers: tailscale.running') && panelSource.includes('showExitNodes: tailscale.running'), 'tailscale reveals connection details only after status confirms it is running')
assert(panelSource.includes('opacity: tailscale.connecting ? 0.55 : 1.0'), 'tailscale dims the switch while connecting')
assert(!/visible:.*tailscale\.active/.test(panelSource), 'tailscale never expands machine sections for an optimistic connection')
assert(panelSource.includes('height: Math.max(implicitHeight, statusMeasure.implicitHeight)') && panelSource.includes('text: "M\\nM"'), 'tailscale reserves two status lines to avoid resizing between login progress and timeout')
assert(panelSource.includes('visible: text !== ""') && panelSource.includes('tailscale.needsLogin ? "Sign in to connect this device." : ""'), 'tailscale reserves status space for a login prompt or feedback, not ordinary disconnects')
assert(panelSource.includes('busy: tailscale.busy || tailscale.connecting || tailscale.waitingForLogin'), 'tailscale disables repeated switch clicks while waiting for a login URL')
assert(serviceSource.includes('if (!installed || loginProcess.running || _loginInProgress) return'), 'tailscale also guards repeated login requests from IPC and keyboard')
assert(/id: loginTimeoutTimer\s+interval: 25000/.test(serviceSource), 'tailscale bounds login URL waiting to 25 seconds')
assert(serviceSource.includes('if (!root._loginInProgress) root.actionStatus = ""'), 'tailscale keeps login progress after the LocalAPI request returns')
assert(/if \(root\._loginTimedOut\) \{\s+delayedRefresh\.restart\(\)\s+return/.test(serviceSource), 'tailscale preserves the timeout message when the terminated request exits')
// mask 18 = NotifyInitialState (2) | NotifyNoPrivateKeys (16): the stream must not carry the node's private key.
assert(serviceSource.includes('stateWatchProcess.command = ["tailscale", "debug", "localapi", "GET", "/localapi/v0/watch-ipn-bus?mask=18"]'), 'tailscale watches the IPN notification bus without private keys')
assert(/function scheduleStateWatchRestart\(\) \{\s+if \(!installed\) return\s+stateWatchRestartTimer\.interval = _stateWatchBackoffMs\s+_stateWatchBackoffMs = Math\.min\(_stateWatchBackoffMs \* 2, 60000\)\s+stateWatchRestartTimer\.restart\(\)/.test(serviceSource), 'tailscale backs off IPN watcher restarts up to a minute')
assert(serviceSource.includes('property int _stateWatchBackoffMs: 2000'), 'tailscale starts the IPN watcher backoff at two seconds')
assert(/var notification = JSON\.parse\(text\)[\s\S]*?if \(!notification \|\| typeof notification !== "object" \|\| Array\.isArray\(notification\)\) return\s+_stateWatchBackoffMs = 2000/.test(serviceSource), 'tailscale resets the IPN watcher backoff only once a notification object parses')
assert(/id: stateWatchProcess[\s\S]*?onExited: function\(exitCode\) \{\s+root\.scheduleStateWatchRestart\(\)/.test(serviceSource), 'tailscale restarts the IPN watcher after an unexpected exit')
assert(/id: connectTimeoutTimer\s+interval: 20000\s+repeat: false\s+onTriggered: \{\s+if \(root\._desired !== 1 \|\| root\.running\) return\s+root\._desired = -1[\s\S]*?stateWatchRefreshTimer\.restart\(\)\s+\}/.test(serviceSource), 'tailscale drops the optimistic on state when the backend does not connect in time and re-checks status')
assert(/function handleLoginOutput\(data, isError\) \{[\s\S]*?if \(\/\^\\s\*#\/\.test\(text\)\) return/.test(serviceSource), 'tailscale drops LocalAPI request commentary from login errors')
assert(serviceSource.includes('root.showActionError(exitCode, combined, "Could not start Tailscale")'), 'tailscale falls back to a fixed message when the login command prints nothing')
assert(serviceSource.includes('notification.BrowseToURL') && serviceSource.includes('openAuthUrl(browseUrl)'), 'tailscale opens authorization URLs from IPN BrowseToURL notifications')
assert(!serviceSource.includes('.match(/https?:\\/\\/'), 'tailscale does not extract arbitrary URLs from command output')

// Execute the real QML helper bodies, with only their environment stubbed.
const vm = require('vm')
const context = { elideStatus: text => String(text || '').trim(), actionStatusTimer: { stop() {}, restart() {} } }
for (const name of ['timedCommand', 'showActionError']) {
  const body = serviceSource.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))
  assert(body, 'tailscale defines ' + name)
  vm.runInNewContext(body[0], context)
}
assertDeepEqual(Array.from(context.timedCommand(['tailscale', 'down'])), ['timeout', '--foreground', '--kill-after=2s', '20s', 'tailscale', 'down'], 'tailscale finite commands have a deadline and forced-termination grace period')
for (const command of ['loginProcess.command = timedCommand(plan.command)', 'actionProcess.command = timedCommand(command)', 'switchProcess.command = timedCommand(["tailscale", "switch", accountId])', 'exitNodeProcess.command = timedCommand(["tailscale", "set", "--exit-node=" + target])']) {
  assert(serviceSource.includes(command), 'tailscale bounds ' + command.split('.')[0])
}
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
assert(serviceSource.includes('operatorProcess.command = ["pkexec", "tailscale", "set", "--operator=" + userName]'), 'tailscale leaves interactive authorization outside the command deadline')

let openedLoginUrl = ''
let browserOpens = 0
let statusRefreshes = 0
const timer = () => ({ running: false, restart() { this.running = true }, stop() { this.running = false } })
const loginTransition = {
  Model: tailscale, installed: true, _desired: 1, _loginInProgress: false,
  _loginUrlOpened: false, _loginTimedOut: false, _preLoginAuthUrl: '',
  loginProcess: { running: true, command: [] }, mullvadRegions: [], selectedAccountId: '',
  actionProcess: { running: false }, switchProcess: { running: false }, exitNodeProcess: { running: false },
  actionStatusTimer: timer(), connectTimeoutTimer: timer(), loginTimeoutTimer: timer(),
  stateWatchRefreshTimer: { restart() { statusRefreshes++ } }, timedCommand: context.timedCommand,
  exitNodeTarget: () => 'test-peer', authUrlOpened() {},
  Quickshell: { execDetached(args) { openedLoginUrl = args[1]; browserOpens++ } }
}
loginTransition.root = loginTransition
for (const name of ['parseStatus', 'loginOrUp', 'openAuthUrl', 'down', 'runAction', 'handleStateWatchData', 'switchAccount', 'setExitNode']) {
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
