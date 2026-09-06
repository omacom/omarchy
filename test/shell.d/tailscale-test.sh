#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const tailscale = requireFromRoot('shell/plugins/panels/tailscale/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/tailscale/Panel.qml', 'utf8')

assert(/function toggleTailscale\(\): string \{ tailscale\.toggleTailscale\(\); return "ok" \}/.test(panelSource), 'tailscale exposes the connection toggle over IPC')

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

const withServices = tailscale.parseStatus(JSON.stringify({
  BackendState: 'Running',
  CurrentTailnet: { MagicDNSSuffix: 'tail32f559.ts.net' },
  Self: {
    HostName: 'dhh-fd',
    DNSName: 'dhh-fd.tail32f559.ts.net.',
    TailscaleIPs: ['100.74.97.73'],
    Online: true,
    PrimaryRoutes: ['100.90.0.1/32'],
    CapMap: {
      'services/web': [
        { Name: 'svc:docs', Ports: ['tcp:443'], Addrs: ['100.90.0.1'] },
        { Name: 'svc:metrics', Ports: ['tcp:9090'], Addrs: ['100.90.0.2'] },
        { Name: 'svc:not a label', Ports: ['tcp:443'], Addrs: ['100.90.0.3'] }
      ],
      'services/extra': [
        { Name: 'svc:wiki', Ports: ['tcp:80', 'tcp:443'], Addrs: ['fd7a:115c:a1e0::9'] },
        { Name: 'svc:chat', Ports: ['tcp:443'], Addrs: ['100.90.0.7'] }
      ],
      'https://tailscale.com/cap/file-sharing': null
    }
  },
  Peer: {
    attic: {
      HostName: 'attic',
      DNSName: 'attic.tail32f559.ts.net.',
      TailscaleIPs: ['100.1.1.9'],
      Online: false,
      OS: 'linux',
      PrimaryRoutes: ['fd7a:115c:a1e0::9/128', '100.90.0.7/32']
    },
    shed: {
      HostName: 'shed',
      DNSName: 'shed.tail32f559.ts.net.',
      TailscaleIPs: ['100.1.1.10'],
      Online: true,
      OS: 'linux',
      PrimaryRoutes: ['100.90.0.7/32']
    }
  }
}))

assertDeepEqual(
  withServices.services.map(service => service.Name),
  ['chat', 'docs', 'wiki'],
  'tailscale lists HTTPS services and skips ports it cannot open'
)
assertEqual(withServices.services[1].Url, 'https://docs.tail32f559.ts.net/', 'tailscale builds service URLs from the MagicDNS suffix')
assertEqual(withServices.services[1].HostName, 'dhh-fd', 'tailscale credits this machine when it carries the service route')
assertEqual(withServices.services[0].HostName, 'shed', 'tailscale prefers an online peer over an offline one carrying the same service')
assertEqual(withServices.services[2].HostName, 'attic', 'tailscale still names an offline carrier so you know which machine to wake')
assert(!withServices.services[2].HostOnline, 'tailscale reports an offline service carrier as offline')

assertDeepEqual(
  tailscale.parseServices({ Self: { CapMap: { 'services/web': [{ Name: 'svc:docs', Ports: ['tcp:443'] }] } } }),
  [],
  'tailscale advertises no services without a MagicDNS suffix to address them by'
)
assertDeepEqual(
  tailscale.parseServices({
    CurrentTailnet: { MagicDNSSuffix: 'tail32f559.ts.net', MagicDNSEnabled: false },
    Self: { CapMap: { 'services/web': [{ Name: 'svc:docs', Ports: ['tcp:443'] }] } }
  }),
  [],
  'tailscale lists no services when MagicDNS cannot resolve their names'
)
assertDeepEqual(
  tailscale.parseServices({
    CurrentTailnet: { MagicDNSSuffix: 'tail32f559.ts.net' },
    Self: { CapMap: { 'services/web': [{ Name: 'svc:constructor', Ports: ['tcp:443'] }] } }
  }).map(service => service.Name),
  ['constructor'],
  'tailscale keeps a service whose name collides with an object member'
)

const probeCommand = tailscale.serviceProbeCommand([
  { Url: 'https://docs.tail32f559.ts.net/' },
  { Url: 'https://wiki.tail32f559.ts.net/' }
])

assert(probeCommand.indexOf('--noproxy') !== -1 && probeCommand.indexOf('--disable') !== -1, 'tailscale probes services without proxies or ~/.curlrc')
assert(probeCommand.indexOf('--proto') !== -1 && probeCommand.indexOf('=https') !== -1, 'tailscale probes services over HTTPS only')
assert(probeCommand.indexOf('--location') === -1, 'tailscale does not follow redirects out of the tailnet while probing')
assertEqual(
  probeCommand.filter(argument => argument === '--output').length,
  2,
  'tailscale gives every probed URL its own output sink so bodies stay out of the report'
)
assertDeepEqual(tailscale.serviceProbeCommand([]), [], 'tailscale runs no probe without services')

const probes = tailscale.parseProbeResults(
  'https://docs.tail32f559.ts.net/\t200\t0.014866\n' +
  'https://wiki.tail32f559.ts.net/\t401\t1.5\n' +
  'https://chat.tail32f559.ts.net/\t000\t0.001\n' +
  'truncated line without fields\n'
)

assertEqual(probes['https://docs.tail32f559.ts.net/'].latencyMs, 15, 'tailscale reports probe latency in whole milliseconds')
assert(probes['https://wiki.tail32f559.ts.net/'].reachable, 'tailscale counts an authenticated service as reachable')
assert(!probes['https://chat.tail32f559.ts.net/'].reachable, 'tailscale counts a service that never answered as unreachable')
assertEqual(Object.keys(probes).length, 3, 'tailscale ignores probe output it cannot parse')

const rows = tailscale.serviceRows(withServices.services, probes)

assertDeepEqual(rows.map(row => row.Reachable), [false, true, true], 'tailscale joins probe results onto the service rows')
assertEqual(rows[1].Code, 200, 'tailscale keeps the probe status code for the row')
assertEqual(tailscale.reachableServiceCount(rows), 2, 'tailscale counts the reachable services')
assert(!tailscale.serviceRows(withServices.services, {})[0].Probed, 'tailscale marks services as unprobed until the first probe lands')

assert(/function services\(\): string/.test(panelSource), 'tailscale exposes the service summary over IPC')
assert(/text: "SERVICES"/.test(panelSource), 'tailscale panel renders a services section')

assertDeepEqual(tailscale.parseStatus('{'), { ok: false, unavailable: true, message: 'Status error', error: 'Failed to parse tailscale status' }, 'tailscale reports invalid status JSON')
assertDeepEqual(tailscale.parseAccounts('{'), { accounts: [], selectedAccountId: '', selectedAccountLabel: '' }, 'tailscale handles invalid account JSON')
JS
