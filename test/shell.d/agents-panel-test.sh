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

# A usage-credit window carries the money behind its percentage. It shows as
# a row with the money in its tooltip, but nothing that answers "what stops
# the next prompt" counts it: running credits down returns the account to its
# rate limit windows rather than stopping anything.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const catalog = root + '/default/i18n/en/shell.json'
const english = JSON.parse(fs.readFileSync(catalog, 'utf8'))
const panelRoot = { nowMs: Date.now() }
// QML's String.arg fills the lowest-numbered %N left.
String.prototype.arg = function (value) {
  const holes = (this.match(/%\d/g) || []).sort()
  return holes.length ? this.replace(holes[0], String(value)) : String(this)
}
const Commons = { I18n: {
  t: (key) => english[key],
  formatNumber: (value, decimals) => Number(value).toFixed(decimals || 0)
} }
const start = source.indexOf('function windowIsLong')
const summary = '// ' + '-'.repeat(64) + ' summary'
const end = source.indexOf(summary)
assert(start > 0 && end > start,
  'agents panel exposes its window and money helpers')
eval(source.slice(start, end).replaceAll('root.nowMs', 'panelRoot.nowMs'))

const money = { used: 458.2, limit: 500, currency: 'EUR' }
const credits = {
  label: 'Usage credits', title: 'Usage credits', percent: 0.92,
  resetsAt: '', spend: money
}
const windowOf = (entry) => limitWindows({ limits: [entry] })[0]

assertDeepEqual(windowOf(credits),
  { title: 'Usage credits', percent: 0.92, resetAt: '', spend: money },
  'agents panel carries a credit allowance through to its window')
const refund = { ...money, used: -5 }
assertDeepEqual(windowOf({ ...credits, percent: 0, spend: refund }).spend,
  refund, 'agents panel keeps the signed money of a refund')

// Amounts it cannot read say nothing rather than "$0.00 / $0.00".
for (const spend of [null, {}, { used: 10 }, { used: 10, limit: 0 }]) {
  assertEqual(windowOf({ ...credits, spend }).spend, undefined,
    'agents panel drops an allowance it cannot read: ' + JSON.stringify(spend))
}

// Last month's money says nothing about a month that has started.
const lastMonth = new Date(panelRoot.nowMs - 1000).toISOString()
assertEqual(windowOf({ ...credits, resetsAt: lastMonth }).spend, undefined,
  'agents panel drops the money of a credit window that has reset')

for (const [spend, expected, name] of [
  [money, '€458.20 / €500.00 spent', 'money spent of the cap'],
  [refund, '-€5.00 / €500.00 spent', 'a refund as a signed amount'],
  [null, '', 'nothing for a rate limit window'],
]) {
  assertEqual(spendDetailText(spend), expected, 'agents panel writes ' + name)
}

assertEqual(windowDisplayTitle('Usage credits'),
  english['agents.windowUsageCredits'],
  'agents panel translates the credit window title')

const weekly = { label: 'Weekly (7-day)', percent: 0.11, resetsAt: '' }
assertEqual(bindingWindow({ limits: [weekly, credits] }).title, 'Weekly',
  'agents panel binds the bar to a rate limit window, not the credit window')
assertEqual(bindingWindow({ limits: [credits] }), null,
  'agents panel binds the bar to nothing when only credits are known')
JS

# The faster limit checks catch an account crossing its switch threshold. A
# credit allowance never switches an account, so it does not start them.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const start = source.indexOf('readonly property bool nearLimit: {')
const end = source.indexOf('\n  }\n', start)
assert(start > 0 && end > start, 'agents main exposes its near-limit check')
const body = source.slice(source.indexOf('{', start) + 1, end)
const nearLimit = (limits) => new Function('agents', 'dataRevision', body)(
  [{ record: { accounts: [{}, {}], limits } }], 0)

// The checks start 15 points under the default 95% threshold: at 80%.
for (const [limits, expected, name] of [
  [[{ percent: 0.79 }], false, 'a session under 80%'],
  [[{ percent: 0.8 }], true, 'a session at 80%'],
  [[{ percent: 0.1 }, { percent: 0.99, spend: { used: 495, limit: 500 } }],
    false, 'a full credit allowance'],
]) {
  assertEqual(nearLimit(limits), expected, 'near-limit check: ' + name)
}
JS
