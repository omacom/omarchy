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
assertEqual(tailscale.displayHostName('old-hostname', 'renamed-machine.tailnet.ts.net.'), 'renamed-machine', 'tailscale prefers renamed machine DNS name')
assertEqual(tailscale.displayHostName('workstation', ''), 'workstation', 'tailscale falls back to OS hostname without a DNS name')

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
assertDeepEqual(status.peers.map(peer => peer.HostName), ['alpha', 'zed', 'mbu-ser9', 'offline'], 'tailscale lists offline peers after online ones, each group alphabetical, and skips Mullvad')
assertDeepEqual(status.peers.map(peer => peer.Online), [true, true, false, false], 'tailscale records which peers are online')
assertDeepEqual(status.peers[0].TailscaleIPv6, ['fd7a:115c:a1e0::1901:334b'], 'tailscale preserves peer IPv6 addresses for copy menu')
assert(status.peers[1].ExitNodeOption && status.peers[1].ExitNode, 'tailscale preserves exit node flags')
assertDeepEqual(status.exitNodes.map(peer => peer.HostName), ['zed'], 'tailscale lists only online tailnet exit nodes')
assert(tailscale.isMullvadPeer({ HostName: 'al-tia-wg-003', DNSName: 'al-tia-wg-003.mullvad.ts.net.' }), 'tailscale detects Mullvad status peers')

assert(status.fileSharing, 'tailscale reads Taildrop capability from the status capability map')
assertEqual(status.selfUserId, '1001', 'tailscale records the owning user of this machine')
assertDeepEqual(status.peers.map(peer => peer.UserID), ['1001', '1002', '', ''], 'tailscale records the owning user of each peer')
assert(
  tailscale.hasFileSharing({ Capabilities: ['https://tailscale.com/cap/file-sharing'] }),
  'tailscale reads Taildrop capability from the legacy capability list'
)
assert(!tailscale.hasFileSharing({ CapMap: { funnel: null } }), 'tailscale reports no Taildrop without the capability')
assertDeepEqual(status.peers.map(peer => peer.TaildropTarget), [1, 5, 0, 0], 'tailscale records how Tailscale grades each Taildrop target')
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

assertDeepEqual(tailscale.parseStatus('{'), { ok: false, unavailable: true, message: 'Status error', error: 'Failed to parse tailscale status' }, 'tailscale reports invalid status JSON')
assertDeepEqual(tailscale.parseAccounts('{'), { accounts: [], selectedAccountId: '', selectedAccountLabel: '' }, 'tailscale handles invalid account JSON')

// Regression: OS hostnames differ from the admin-console machine names.
for (const [host, dns, expected] of [
  ['iPhone 17 Pro Max', 'iris.tailnet.ts.net.', 'iris'],
  ['Atlas', 'atlas.tailnet.ts.net', 'atlas'],
  ['localhost', 'work.tailnet.ts.net.', 'work'],
  ['', 'renamed.tailnet.ts.net.', 'renamed'],
  ['workstation', '', 'workstation'],
  ['workstation', undefined, 'workstation'],
  ['', '', 'Unknown'],
  [undefined, undefined, 'Unknown']
]) {
  assertEqual(tailscale.displayHostName(host, dns), expected, `machine name fallback: ${host} / ${dns}`)
}
const renamed = tailscale.parseStatus(JSON.stringify({
  BackendState: 'Running',
  Self: { HostName: 'old-self', DNSName: 'new-self.tailnet.ts.net.' },
  Peer: {
    a: { HostName: 'AAA', DNSName: 'zulu.tailnet.ts.net.', Online: true, ExitNodeOption: true },
    b: { HostName: 'ZZZ', DNSName: 'alpha.tailnet.ts.net.', Online: true, ExitNodeOption: true },
    c: { HostName: 'sleeping', DNSName: 'aardvark.tailnet.ts.net.', Online: false, ExitNodeOption: true },
    d: { HostName: 'unknown-status', DNSName: 'unknown.tailnet.ts.net.' },
    e: { HostName: 'provider', DNSName: 'provider.mullvad.ts.net.', Online: false }
  }
}))
assertEqual(renamed.selfName, 'new-self', 'header uses the registered machine name')
assertDeepEqual(renamed.peers.map(p => p.DisplayName), ['alpha', 'zulu', 'aardvark', 'unknown'], 'peers sort by registered name with offline peers last')
assertDeepEqual(renamed.exitNodes.map(p => p.DisplayName), ['alpha', 'zulu'], 'exit nodes use registered names and exclude offline machines')
assertEqual(renamed.peers[0].DNSName, 'alpha.tailnet.ts.net', 'full DNS address remains available for copying and actions')
for (const option of [undefined, false, null, 'true', 1]) {
  assertDeepEqual(tailscale.visiblePeers(renamed.peers, option).map(p => p.DisplayName), ['alpha', 'zulu'], `offline visibility requires explicit boolean true: ${option}`)
}
assertDeepEqual(tailscale.visiblePeers(renamed.peers, true).map(p => p.DisplayName), ['alpha', 'zulu', 'aardvark', 'unknown'], 'opt-in includes offline and unknown-status peers but not Mullvad')
assertDeepEqual(tailscale.visiblePeers(renamed.peers, false).map(p => p.DisplayName), ['alpha', 'zulu'], 'turning the setting off re-filters the same snapshot')
assertEqual(renamed.peers.length, 4, 'filtering does not mutate cached peers')
assertDeepEqual(tailscale.visiblePeers([], true), [], 'empty tailnets remain empty')
assertDeepEqual(tailscale.visiblePeers(renamed.peers.slice(2), false), [], 'offline-only tailnets are empty by default')

JS

# The panel checks below need a live compositor; the model checks above run headlessly.
require_compositor "Tailscale peer settings runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/tailscale" "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$SHELL_TEST_DIR/fixtures/tailscale-peers/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/tailscale/"{Model.js,TailscaleIcon.qml} "$stage/tailscale/"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
const source = root + '/shell/plugins/panels/tailscale/'
let panel = fs.readFileSync(source + 'Panel.qml', 'utf8')
// The panel's content is built lazily, so its private IDs are exposed from
// the content root and mirrored on the panel once the test builds it.
panel = panel.replace('      id: keyCatcher\n', '      id: keyCatcher\n      property alias testOfflineSwitch: offlineSwitch\n')
panel = panel.replace('  id: root', `  id: root
  property alias testService: tailscale
  function testEnsureContent() { return panel.ensureContent() }
  readonly property Item testOfflineSwitch: panel.loadedContent ? panel.loadedContent.testOfflineSwitch : null
  readonly property Item testKeys: panel.loadedContent`)
fs.writeFileSync(stage + '/tailscale/Panel.qml', panel)
// Disable automatic polling in the disposable fixture. Tests feed status into
// the real parser; no daemon, account, routing or file-transfer command runs.
let service = fs.readFileSync(source + 'Service.qml', 'utf8')
service = service.replaceAll('running: true', 'running: false')
fs.writeFileSync(stage + '/tailscale/Service.qml', service)
JS
cat > "$stage/bin/wl-copy" <<'COPY'
#!/bin/bash
value=$(cat)
printf '%s\n' "$value" >> "$TAILSCALE_TEST_COPY_LOG"
COPY
cat > "$stage/bin/omarchy-tailscale-send" <<'SEND'
#!/bin/bash
printf '%s\n' "$@" >> "$TAILSCALE_TEST_SEND_LOG"
SEND
chmod +x "$stage/bin/"*
output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  TAILSCALE_TEST_COPY_LOG="$stage/copy.log" TAILSCALE_TEST_SEND_LOG="$stage/send.log" \
  timeout 20 quickshell -p "$stage" --no-color 2>&1) || fail "Tailscale peer fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "Tailscale peer runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "Tailscale peer fixture has no QML errors" "$output"
fi
[[ ! -e $stage/send.log ]] || fail "offline send never launches a transfer"
for expected in laptop laptop.tailnet.ts.net 100.64.0.3; do
  rg -qxF "$expected" "$stage/copy.log" || fail "offline copy includes $expected"
done
pass "Tailscale settings, keyboard focus, offline copy, transfer guards and stale-state clearing work in QML"
