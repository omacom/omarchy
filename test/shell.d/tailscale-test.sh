#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const tailscale = requireFromRoot('shell/plugins/panels/tailscale/Model.js')

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
assertEqual(
  tailscale.accountLabel({ nickname: 'dhh@github', tailnet: 'Omacom', account: 'dhh@github', id: 'dd30' }),
  'Omacom',
  'tailscale labels connections by tailnet when nickname mirrors the account'
)

assertDeepEqual(
  tailscale.loginPlan(true, 'https://login.tailscale.com/a/existing'),
  { authUrl: 'https://login.tailscale.com/a/existing', command: [] },
  'tailscale reuses the daemon authorization URL without replacing node identity'
)
assertDeepEqual(
  tailscale.loginPlan(true, ''),
  { authUrl: '', command: ['tailscale', 'up'] },
  'tailscale requests a login URL when the daemon has not supplied one'
)
assertDeepEqual(
  tailscale.loginPlan(false, 'https://login.tailscale.com/a/stale'),
  { authUrl: '', command: ['tailscale', 'up'] },
  'tailscale ignores stale authorization URLs outside the login state'
)

assertDeepEqual(
  tailscale.renamePlan('dd11', 'dd11', 'Home'),
  { command: ['bash', '-c', 'tailscale set --nickname=Home'] },
  'tailscale renames the selected connection in place'
)
assertDeepEqual(
  tailscale.renamePlan('dd30', 'dd11', 'Home'),
  { command: ['bash', '-c', "r=0; s=0; tailscale switch dd30 || r=$?; if (( r == 0 )); then tailscale set --nickname=Home || r=$?; fi; tailscale switch dd11 || s=$?; (( r == 0 )) && r=$s; exit $r"] },
  'tailscale renames another connection by switching there and back'
)
assertEqual(
  tailscale.renamePlan('dd30', 'dd11', "Dave's tailnet").command[2],
  "r=0; s=0; tailscale switch dd30 || r=$?; if (( r == 0 )); then tailscale set --nickname='Dave'\\''s tailnet' || r=$?; fi; tailscale switch dd11 || s=$?; (( r == 0 )) && r=$s; exit $r",
  'tailscale quotes nicknames that need shell escaping'
)
assertEqual(tailscale.renamePlan('dd11', 'dd11', '  '), null, 'tailscale refuses empty rename nicknames')
assertEqual(tailscale.renamePlan('', 'dd11', 'Home'), null, 'tailscale refuses renames without a profile id')
assertEqual(tailscale.renamePlan('dd30', '', 'Home'), null, 'tailscale refuses off-profile renames with no selected profile to return to')

// Run the generated scripts against a stubbed tailscale binary to prove the
// status contract: the first failure wins, restoration always runs.
const spawnSync = require('child_process').spawnSync
const stubFs = require('fs'), stubOs = require('os'), stubPath = require('path')
const stubDir = stubFs.mkdtempSync(stubPath.join(stubOs.tmpdir(), 'ts-stub-'))
stubFs.writeFileSync(stubPath.join(stubDir, 'tailscale'), [
  '#!/bin/bash',
  'echo "$1 $2" >> "$TS_LOG"',
  'case "$1 $2" in',
  '  "set --nickname=Fail") exit 23;;',
  '  "switch lost") exit 9;;',
  '  "switch backfail") exit 9;;',
  '  *) exit 0;;',
  'esac',
  ''
].join('\n'))
stubFs.chmodSync(stubPath.join(stubDir, 'tailscale'), 0o755)
const stubEnv = Object.assign({}, process.env, {
  PATH: stubDir + stubPath.delimiter + process.env.PATH,
  TS_LOG: stubPath.join(stubDir, 'calls.log')
})
function runPlan(plan) {
  stubFs.rmSync(stubEnv.TS_LOG, { force: true })
  const status = spawnSync(plan.command[0], plan.command.slice(1), { env: stubEnv, encoding: 'utf8' }).status
  return { status, calls: stubFs.readFileSync(stubEnv.TS_LOG, 'utf8') }
}
assertEqual(runPlan(tailscale.renamePlan('dd30', 'dd11', 'Good')).status, 0, 'tailscale rename script succeeds end to end')
assertEqual(runPlan(tailscale.renamePlan('dd30', 'dd11', 'Fail')).status, 23, 'rename failure survives a successful switch-back')
const lostRun = runPlan(tailscale.renamePlan('lost', 'dd11', 'Good'))
assertEqual(lostRun.status, 9, 'initial switch failure survives')
assert(lostRun.calls.includes('switch dd11'), 'switch-back still runs after a failed first switch')
const backfailRun = runPlan(tailscale.renamePlan('dd30', 'backfail', 'Good'))
assertEqual(backfailRun.status, 9, 'switch-back failure is reported when nothing else failed')
assert(backfailRun.calls.includes('switch backfail'), 'restoration attempt is the failed switch-back itself')
assertEqual(runPlan(tailscale.renamePlan('dd11', 'dd11', 'Fail')).status, 23, 'in-place rename failure is reported')

assertDeepEqual(tailscale.parseStatus('{'), { ok: false, unavailable: true, message: 'Status error', error: 'Failed to parse tailscale status' }, 'tailscale reports invalid status JSON')
assertDeepEqual(tailscale.parseAccounts('{'), { accounts: [], selectedAccountId: '', selectedAccountLabel: '' }, 'tailscale handles invalid account JSON')

const fs = require('fs')
const vm = require('vm')

// Verify Mullvad region search accepts typing "j" and "k" while Down/Up still move selection.
const panelQml = fs.readFileSync(path.join(root, 'shell/plugins/panels/tailscale/Panel.qml'), 'utf8')
const mullvadKeyBody = panelQml.match(/id: mullvadSearch[\s\S]*?Keys\.onPressed: function\(event\) \{([\s\S]*?)\n                  \}/)[1]
const keyCtx = {
  moves: [],
  activated: 0,
  mullvadPickerOpen: true,
  Qt: { Key_Down: 1, Key_Up: 2, Key_Return: 3, Key_Enter: 4, Key_Escape: 5 },
  keyCatcher: { forceActiveFocus() {} },
  moveMullvadRegionCursor(d) { this.moves.push(d) },
  activateMullvadRegionCursor() { this.activated += 1 }
}
keyCtx.root = keyCtx
vm.runInNewContext(`function press(event) {${mullvadKeyBody}}`, keyCtx)

for (const ch of ['j', 'k']) {
  const ev = { key: 0, text: ch, accepted: false }
  keyCtx.press(ev)
  assert(!ev.accepted, `mullvad search lets "${ch}" reach the text field`)
}
assertDeepEqual(keyCtx.moves, [], 'typing j/k in mullvad search does not move region cursor')
const downEv = { key: 1, text: '', accepted: false }
keyCtx.press(downEv)
assert(downEv.accepted && keyCtx.moves[0] === 1, 'mullvad search still navigates regions with Down arrow')

// Verify clicking a peer row moves the cursor and opens the copy menu, and
// the shared copy popup is modal so outside clicks dismiss without reopening it.
const peerClickBody = panelQml.match(/component PeerRow:[\s\S]*?MouseArea \{[\s\S]*?onClicked: \{([\s\S]*?)\n      \}/)[1]
const peerCtx = {
  cursor: null,
  opened: 0,
  root: { setPeerCursor(i) { peerCtx.cursor = i } },
  peerRow: { rowIndex: 2, openCopyMenu() { peerCtx.opened += 1 } }
}
vm.runInNewContext(`function click() {${peerClickBody}}`, peerCtx)
peerCtx.click()
assertEqual(peerCtx.cursor, 2, 'clicking a peer row moves the peer cursor to that row')
assertEqual(peerCtx.opened, 1, 'clicking a peer row opens the copy menu')
const copyPopupBlock = panelQml.match(/id: sharedCopyPopup[\s\S]*?closePolicy:/)[0]
assert(/\bmodal:\s*true\b/.test(copyPopupBlock), 'sharedCopyPopup is modal so outside clicks do not pass through to peer rows')

// Verify closed background polls skip Mullvad exit-node and account list subprocesses,
// and authorizeTailscaleOperator rejects malformed usernames.
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/panels/tailscale/Service.qml'), 'utf8')
const refreshFn = serviceQml.match(/function refreshStatusAndAccounts\(forceAccounts, fullPeers\) \{[\s\S]*?\n  \}/)[0]
const authFn = serviceQml.match(/function authorizeTailscaleOperator\(\) \{[\s\S]*?\n  \}/)[0]

function makeServiceCtx(overrides) {
  const ctx = Object.assign({
    installed: true,
    peersWanted: false,
    accounts: [],
    _statusOutput: '', _statusError: '', refreshing: false,
    _statusFullPeers: false, _pendingFullPeers: false,
    _mullvadExitNodesOutput: '', _mullvadExitNodesError: '',
    _accountsOutput: '', _accountsError: '', _lastAccountsRefreshMs: 0,
    _operatorOutput: '', _operatorError: '', actionStatus: '',
    userName: 'dhh',
    I18n: { t: k => k },
    statusProcess: { running: false, command: [] },
    mullvadExitNodesProcess: { running: false, command: [] },
    accountsProcess: { running: false, command: [] },
    operatorProcess: { running: false, command: [] },
    pollWatchdog: { running: false, start() { this.running = true } }
  }, overrides)
  vm.runInNewContext(`${refreshFn}\n${authFn}`, ctx)
  return ctx
}

const idleCtx = makeServiceCtx({ peersWanted: false })
idleCtx.refreshStatusAndAccounts(false, false)
assert(idleCtx.statusProcess.running && idleCtx.statusProcess.command.includes('--peers=false'), 'idle tailscale poll runs light status')
assert(!idleCtx.mullvadExitNodesProcess.running, 'idle tailscale poll skips exit-node list while panel is closed')
assert(!idleCtx.accountsProcess.running, 'idle tailscale poll skips account list while panel is closed')

const openCtx = makeServiceCtx({ peersWanted: true })
openCtx.refreshStatusAndAccounts(false, false)
assert(openCtx.statusProcess.running && !openCtx.statusProcess.command.includes('--peers=false'), 'open tailscale panel polls full peers')
assert(openCtx.mullvadExitNodesProcess.running, 'open tailscale panel fetches Mullvad exit nodes')
assert(openCtx.accountsProcess.running, 'open tailscale panel fetches account list')

const badUserCtx = makeServiceCtx({ userName: '--evil=1' })
badUserCtx.authorizeTailscaleOperator()
assert(!badUserCtx.operatorProcess.running, 'tailscale operator auth rejects malformed username')
const goodUserCtx = makeServiceCtx({ userName: 'alice_1' })
goodUserCtx.authorizeTailscaleOperator()
assertDeepEqual(goodUserCtx.operatorProcess.command, ['pkexec', 'tailscale', 'set', '--operator=alice_1'], 'tailscale operator auth accepts valid username')
JS
