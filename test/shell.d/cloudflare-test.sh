#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const cloudflare = requireFromRoot('shell/plugins/panels/cloudflare/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/cloudflare/Panel.qml', 'utf8')

for (const method of ['open', 'close', 'toggle', 'refresh', 'login', 'status']) {
  assert(new RegExp(`function ${method}\\(\\)`).test(panelSource), `cloudflare exposes ${method} over IPC`)
}

// whoami

const signedOut = cloudflare.parseWhoami('{\n  "authenticated": false,\n  "error": "Not logged in"\n}')
assertEqual(signedOut.authenticated, false, 'cloudflare reads a signed-out whoami')
assertEqual(signedOut.message, 'Not logged in', 'cloudflare surfaces the whoami error as status')

const colored = '{\n  \u001b[36m"authenticated"\u001b[39m: \u001b[35mfalse\u001b[39m\n}'
assertEqual(cloudflare.parseWhoami(colored).ok, true, 'cloudflare strips color escapes before parsing')

const signedIn = cloudflare.parseWhoami(JSON.stringify({
  authenticated: true,
  authSource: 'OAuth token from /home/me/.config/cloudflare/config/default.json',
  tokenValid: true,
  email: 'me@example.com',
  accounts: [
    { id: 'bbb', name: 'Work', type: 'standard' },
    { id: 'aaa', name: 'Personal', type: 'standard' },
    { name: 'No id' }
  ]
}))
assertEqual(signedIn.authenticated, true, 'cloudflare reads a signed-in whoami')
assertEqual(signedIn.email, 'me@example.com', 'cloudflare keeps the login email')
assertDeepEqual(
  signedIn.accounts,
  [{ id: 'aaa', name: 'Personal' }, { id: 'bbb', name: 'Work' }],
  'cloudflare sorts accounts by name and drops ones without an id'
)

assertEqual(cloudflare.parseWhoami(JSON.stringify({ authenticated: true, tokenValid: false })).message, 'Token rejected', 'cloudflare flags a token the API rejected')
assertEqual(cloudflare.parseWhoami('not json').ok, false, 'cloudflare reports unparseable whoami output')
assertEqual(cloudflare.parseWhoami('').authenticated, false, 'cloudflare treats empty whoami output as signed out')

// zones

const zonesJson = JSON.stringify([
  { id: 'z2', name: 'example.org', status: 'active', paused: false, plan: { name: 'Free Website' }, account: { id: 'aaa' } },
  { id: 'z1', name: 'example.com', status: 'pending', paused: false, plan: { name: 'Pro Website' }, account: { id: 'aaa' } },
  { id: 'z3', name: 'other.dev', status: 'active', paused: false, plan: { name: 'Free Website' }, account: { id: 'bbb' } }
])
const zones = cloudflare.parseZones(zonesJson, 'aaa')
assertEqual(zones.ok, true, 'cloudflare parses zones list')
assertDeepEqual(zones.zones.map(zone => zone.name), ['example.com', 'example.org'], 'cloudflare keeps the selected account zones, sorted by name')
assertEqual(cloudflare.parseZones(zonesJson, '').zones.length, 3, 'cloudflare keeps every zone without an account filter')
assertEqual(cloudflare.parseZones('nope', 'aaa').ok, false, 'cloudflare reports unparseable zones output')

assertEqual(cloudflare.zoneDetail(zones.zones[1]), 'Free', 'cloudflare shows a healthy zone by its plan')
assertEqual(cloudflare.zoneProblem(zones.zones[1]), '', 'cloudflare finds no problem with an active zone')
assertEqual(cloudflare.zoneDetail(zones.zones[0]), 'Pending', 'cloudflare shows a zone that is not active by its status')
assertEqual(cloudflare.zoneProblem({ status: 'active', paused: true }), 'Paused', 'cloudflare flags a paused zone')

// workers

const workers = cloudflare.parseWorkers(JSON.stringify([
  { id: 'w1', name: 'old', deployed_on: '2026-07-27T18:06:48Z', subdomain: { enabled: false, url: 'https://old.me.workers.dev' } },
  { id: 'w2', name: 'fresh', deployed_on: '2026-09-20T12:52:31Z', subdomain: { enabled: true, url: 'https://fresh.me.workers.dev' } },
  { id: 'w3', deployed_on: '2026-09-21T00:00:00Z' }
]))
assertEqual(workers.ok, true, 'cloudflare parses workers list')
assertDeepEqual(workers.workers.map(worker => worker.name), ['fresh', 'old'], 'cloudflare sorts Workers newest deploy first and drops unnamed ones')
assertEqual(workers.workers[0].url, 'https://fresh.me.workers.dev', 'cloudflare keeps an enabled workers.dev URL')
assertEqual(workers.workers[1].url, '', 'cloudflare drops a disabled workers.dev URL')

// worker metrics

const usageBody = JSON.parse(cloudflare.usageQuery('api-gateway', 1000, 2000))
assertEqual(usageBody.parameters.filters[0].value, 'api-gateway', 'cloudflare scopes metrics to the Worker')
assertEqual(usageBody.granularity, undefined, 'cloudflare leaves metrics granularity to the API')
assertEqual(usageBody.dry, true, 'cloudflare does not save its metrics queries')
const errorsBody = JSON.parse(cloudflare.errorsQuery('api-gateway', 1000, 2000))
assert(errorsBody.parameters.filters.some(f => f.key === '$workers.outcome' && f.value === 'canceled' && f.operation === 'neq'), 'cloudflare does not count canceled requests as errors')

const metrics = cloudflare.parseMetrics(JSON.stringify({
  calculations: [
    { alias: 'invocations', aggregates: [{ value: 4730 }], series: [{ time: 't1', data: [{ value: 3 }] }, { time: 't2', data: [] }, { time: 't3', data: [{ value: 9 }] }] },
    { alias: 'cpu', aggregates: [{ value: 9 }], series: [] }
  ],
  compare: [
    { alias: 'invocations', aggregates: [{ value: 7426 }] },
    { alias: 'cpu', aggregates: [{ value: 8 }] }
  ]
}))
assertEqual(metrics.ok, true, 'cloudflare parses a metrics response')
assertDeepEqual(metrics.metrics.invocations.series, [3, 0, 9], 'cloudflare draws empty metric buckets as zero')
assertEqual(metrics.metrics.invocations.previous, 7426, 'cloudflare reads the previous period')
assertEqual(cloudflare.parseMetrics('{"success":false}').ok, false, 'cloudflare reports a metrics response without calculations')

assertEqual(cloudflare.formatCount(4730), '4.73k', 'cloudflare formats thousands like the dashboard')
assertEqual(cloudflare.formatCount(12400), '12.4k', 'cloudflare formats tens of thousands')
assertEqual(cloudflare.formatCount(0), '0', 'cloudflare formats zero')
assertEqual(cloudflare.formatCount(null), '–', 'cloudflare shows a dash for a missing count')
assertEqual(cloudflare.formatMs(9), '9 ms', 'cloudflare formats CPU time')
assertEqual(cloudflare.formatChange(4730, 7426), '↘ 36%', 'cloudflare formats a drop against the previous period')
assertEqual(cloudflare.formatChange(9, 8), '↗ 13%', 'cloudflare formats a rise against the previous period')
assertEqual(cloudflare.formatChange(5, 0), '', 'cloudflare hides the change without an earlier value')

// worker versions and deployments

const versions = cloudflare.parseVersions(JSON.stringify([
  { id: 'aaaa1111-0000', source: 'wrangler', author_email: 'dev@example.com', created_on: '2026-09-17T00:00:00Z', annotations: { 'workers/message': 'Older', 'workers/tag': '9f8e7d6c5b4a3a2b' } },
  { id: 'bbbb2222-0000', source: 'wrangler', author_email: 'dev@example.com', created_on: '2026-09-20T00:00:00Z', annotations: { 'workers/message': 'Add rate limiting', 'workers/tag': '1a2b3c4d5e6f7a8b' } },
  { id: 'cccc3333-0000', source: 'dash', created_on: '2026-08-01T00:00:00Z', annotations: {} }
]), 2)
assertDeepEqual(versions.versions.map(v => v.shortId), ['bbbb2222', 'aaaa1111'], 'cloudflare lists the newest versions first, up to the limit')
assertDeepEqual(
  [versions.versions[0].message, versions.versions[0].tag, versions.versions[0].source, versions.versions[0].author],
  ['Add rate limiting', '1a2b3c4d', 'Wrangler', 'dev'],
  'cloudflare keeps the version message, short tag, source, and author'
)
assertEqual(cloudflare.sourceLabel('dash'), 'Dashboard', 'cloudflare names dashboard uploads')

const deployments = cloudflare.parseDeployments(JSON.stringify({ deployments: [
  { created_on: '2026-09-10T00:00:00Z', source: 'wrangler', versions: [{ version_id: 'old', percentage: 100 }] },
  { created_on: '2026-09-20T00:00:00Z', source: 'wrangler', versions: [{ version_id: 'bbbb2222-0000', percentage: 100 }] }
] }))
assertDeepEqual(Object.keys(deployments.live), ['bbbb2222-0000'], 'cloudflare marks the newest deployment\'s versions as live')
assertEqual(deployments.source, 'Wrangler', 'cloudflare reads how the Worker was deployed')
assertEqual(cloudflare.rolloutText(deployments.live), '', 'cloudflare says nothing about a single live version')
assertEqual(cloudflare.rolloutText({ a: 10, b: 90 }), 'Split 90/10', 'cloudflare shows a gradual rollout split')

const logsOff = cloudflare.parseWorkers(JSON.stringify([{ name: 'quiet', observability: { enabled: false } }]))
assertEqual(logsOff.workers[0].logsEnabled, false, 'cloudflare knows when a Worker has no logs to chart')

// formatting and links

const now = Date.parse('2026-09-24T12:00:00Z')
assertEqual(cloudflare.relativeTime('2026-09-24T11:59:30Z', now), 'just now', 'cloudflare formats seconds as just now')
assertEqual(cloudflare.relativeTime('2026-09-24T10:00:00Z', now), '2h ago', 'cloudflare formats hours ago')
assertEqual(cloudflare.relativeTime('2026-09-20T12:00:00Z', now), '4d ago', 'cloudflare formats days ago')
assertEqual(cloudflare.relativeTime('2026-07-24T12:00:00Z', now), '2mo ago', 'cloudflare formats months ago')
assertEqual(cloudflare.relativeTime('', now), '', 'cloudflare hides a missing time')

assertEqual(cloudflare.accountDashboardUrl(''), 'https://dash.cloudflare.com', 'cloudflare links the dashboard home without an account')
assertEqual(cloudflare.zoneDashboardUrl('aaa', { name: 'example.com' }), 'https://dash.cloudflare.com/aaa/example.com', 'cloudflare links a zone dashboard')
assertEqual(cloudflare.workerDashboardUrl('aaa', { name: 'fresh' }), 'https://dash.cloudflare.com/aaa/workers/services/view/fresh/production', 'cloudflare links a Worker dashboard')
JS
