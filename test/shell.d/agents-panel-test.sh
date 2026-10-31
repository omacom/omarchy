#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

const signInFunctions = ['supportsSignIn', 'needsSignIn', 'usageNote'].map(name => {
  const match = panelSource.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))
  return match ? match[0] : ''
}).join('\n')
const signIn = new Function('addProviders', 'helpDisplayText', 'statusDisplayText', signInFunctions + '\nreturn {needsSignIn, usageNote}')(
  [{providerId: 'claude'}, {providerId: 'codex'}, {providerId: 'grok'}], text => text, status => status
)
for (const id of ['claude', 'codex', 'grok']) {
  assert(signIn.needsSignIn({providerId: id, usageStatusText: 'Sign-in expired'}), id + ' keeps its sign-in link')
  assertEqual(signIn.usageNote({providerId: id, usageStatusText: 'Sign-in expired'}), '', id + ' offers its sign-in link instead of a note')
}
assert(signIn.needsSignIn({usageStatusText: 'Sign-in expired'}), 'account rows keep their sign-in link')
for (const status of ['Sign-in expired', 'Waiting for auth']) {
  assert(!signIn.needsSignIn({providerId: 'agy', usageStatusText: status}), 'an agent the panel cannot sign in gets no link for ' + status)
  assertEqual(signIn.usageNote({providerId: 'agy', usageStatusText: status}), status, 'an agent the panel cannot sign in still notes ' + status)
}
assertEqual(signIn.usageNote({providerId: 'grok', usageStatusText: 'Limits paused', authHelpText: 'Start Grok to refresh it.'}),
  'Start Grok to refresh it.', 'paused limits stay on show with a note saying how to refresh them')
assertEqual(signIn.usageNote({providerId: 'grok', usageStatusText: ''}), '', 'current limits carry no note')
assertEqual(signIn.usageNote({providerId: 'grok', usageStatusText: '', limitsStale: true, authHelpText: "Couldn't reach Grok's usage endpoint."}),
  "Couldn't reach Grok's usage endpoint.", 'a failed refresh that kept its limits still says why')
assertEqual(signIn.usageNote({usageStatusText: '', stale: true, authHelpText: 'Endpoint returned 500.'}),
  'Endpoint returned 500.', 'an account whose refresh failed still says why')

// Local history alone feeds the summary; a section needs a subscription to show.
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const subscribed = new Function(mainSource.match(/function providerHasSubscription\([^]*?\n  \}/)[0] + '\nreturn providerHasSubscription')()
const historyOnly = { limits: [], accounts: [], balance: null, tierLabel: '', totalPrompts: 1 }
assertEqual(subscribed(historyOnly), false, 'an agent with only local history gets no section')
assertEqual(subscribed({ ...historyOnly, tierLabel: 'X Premium+' }), true, 'a plan earns a section before its limits arrive')
assertEqual(subscribed({ ...historyOnly, limits: [{ label: 'Weekly', percent: 0.04 }] }), true, 'kept limits earn a section')

// Account-wide stats merge by widest value across synced devices, but a
// record whose today is this machine's own (todayScope) adds today up.
const aggregateSource = ['numberValue', 'dateString', 'recentDateStrings', 'safeDeviceId', 'emptyTokenBucket',
  'combineNumber', 'combineObjectNumbers', 'snapshotWrittenOn', 'aggregateSnapshots'].map(name =>
  mainSource.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]).join('\n')
const aggregate = new Function(aggregateSource + '\nreturn {aggregateSnapshots, recentDateStrings}')()
const dates = aggregate.recentDateStrings()
const today = dates[dates.length - 1]
const yesterday = dates[dates.length - 2]
function accountSnapshot(deviceId, todayTokens, extra) {
  return { deviceId, providers: { openrouter: Object.assign({
    scope: 'account', todayTotalTokens: todayTokens, todayTokensByModel: { m: todayTokens },
    recentDays: [{ date: yesterday, messageCount: 500 }, { date: today, messageCount: todayTokens }],
    modelUsage: { m: { inputTokens: 1000, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0 } }
  }, extra) } }
}
const byDay = provider => Object.fromEntries(provider.recentDays.map(day => [day.date, day.messageCount]))
const local = aggregate.aggregateSnapshots([
  accountSnapshot('a', 100, { todayScope: 'device' }), accountSnapshot('b', 200, { todayScope: 'device' })
]).providers.openrouter
assertEqual(local.todayTotalTokens, 300, 'a device-scoped today adds up across synced machines')
assertEqual(local.todayTokensByModel.m, 300, 'and so does its per-model split')
assertEqual(byDay(local)[today], 300, 'and so does today in the week')
assertEqual(byDay(local)[yesterday], 500, 'while the account history before it still merges by widest value')
assertEqual(local.modelUsage.m.inputTokens, 1000, 'as do the account totals')
const account = aggregate.aggregateSnapshots([accountSnapshot('a', 100), accountSnapshot('b', 200)]).providers.openrouter
assertEqual(account.todayTotalTokens, 200, 'a record without todayScope keeps merging today by widest value')
// A machine that last synced yesterday still calls yesterday "today" in its
// undated fields; only its dated history counts.
// Noon on the previous calendar day is yesterday whatever the clocks do;
// 24 hours back is still today on a 25-hour day when daylight saving ends.
const writtenYesterday = new Date()
writtenYesterday.setHours(12, 0, 0, 0)
writtenYesterday.setDate(writtenYesterday.getDate() - 1)
const stale = accountSnapshot('c', 400, { todayScope: 'device' })
stale.updatedAt = writtenYesterday.toISOString()
stale.providers.openrouter.recentDays = [{ date: yesterday, messageCount: 400 }]
const withStale = aggregate.aggregateSnapshots([
  accountSnapshot('a', 100, { todayScope: 'device' }), accountSnapshot('b', 200, { todayScope: 'device' }), stale
]).providers.openrouter
assertEqual(withStale.todayTotalTokens, 300, "a snapshot written yesterday adds nothing to today")
assertEqual(withStale.todayTokensByModel.m, 300, 'nor to its per-model split')
assertEqual(byDay(withStale)[yesterday], 500, 'while its dated history still merges')
assertEqual(withStale.deviceCount, 3, 'and the machine still counts as synced')

// A reworded collector line would silently fall back to English, so every
// fixed help line the collectors cache must still be one the panel maps.
for (const name of ['claude', 'codex', 'grok', 'fireworks']) {
  const collector = fs.readFileSync(root + '/bin/omarchy-agent-usage-' + name, 'utf8')
  const help = collector.match(/^AUTH_HELP = "([^"]+)"$/m)
  assert(help && panelSource.includes('case ' + JSON.stringify(help[1]) + ':'), name + ' auth help is translated in the panel')
}
JS

# The panel reads a window out of a label, and that guess cannot survive a
# model name — "Opus 5 (1M context)" parses as a one-minute window. A collector
# that states the title outright is taken at its word.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const panelRoot = { nowMs: Date.now() }
const start = source.indexOf('function windowIsLong')
const end = source.indexOf('// The window that decides')
assert(start > 0 && end > start, 'agents panel exposes its limit-window helpers')
eval(source.slice(start, end).replaceAll('root.nowMs', 'panelRoot.nowMs'))

assertDeepEqual(
  limitWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.78, resetsAt: '' },
    { label: 'Opus 5 (1M context) Weekly', title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetsAt: '' }
  ] }),
  [
    { title: 'Session', percent: 0.78, resetAt: '' },
    { title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetAt: '' }
  ],
  'agents panel titles a limit off the collector when it states one'
)

assertDeepEqual(
  limitWindows({ limits: [{ label: 'Weekly (7-day)', percent: 0.12, resetsAt: '' }] }),
  [{ title: 'Weekly', percent: 0.12, resetAt: '' }],
  'agents panel still reads a window out of a label that carries no title'
)

const resetAt = new Date(panelRoot.nowMs + 1000).toISOString()
const measured = { limits: [{ label: 'Session (5-hour)', percent: 0.78, resetsAt: resetAt }] }
assertEqual(limitWindows(measured)[0].percent, 0.78, 'usage remains until the reset time')
panelRoot.nowMs += 1000
assertDeepEqual(limitWindows(measured), [{ title: 'Session', percent: 0, resetAt: '' }], 'usage resets at the deadline while the panel stays open')
assertEqual(measured.limits[0].percent, 0.78, 'display reset leaves the measured record intact')

// A model's weekly allowance rides under the Weekly row; one whose window has
// no row of its own keeps a row.
assertDeepEqual(
  displayWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.94, resetsAt: '' },
    { label: 'Weekly (7-day)', percent: 0.25, resetsAt: 'w' },
    { label: 'Fable Weekly', title: 'Fable Weekly', percent: 0.09, resetsAt: 'w' },
    { label: 'Opus Monthly', title: 'Opus Monthly', percent: 0.5, resetsAt: '' }
  ] }),
  [
    { title: 'Session', percent: 0.94, resetAt: '', scoped: [] },
    { title: 'Weekly', percent: 0.25, resetAt: 'w', scoped: [{ title: 'Fable', percent: 0.09, resetAt: 'w' }] },
    { title: 'Opus Monthly', percent: 0.5, resetAt: '', scoped: [] }
  ],
  'agents panel shows a model-scoped window under the window it runs on'
)
JS
