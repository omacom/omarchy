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
const hour = 3600 * 1000
const day = 24 * hour
const week = 7 * day

assertDeepEqual(
  limitWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.78, resetsAt: '' },
    { label: 'Opus 5 (1M context) Weekly', title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetsAt: '' }
  ] }),
  [
    { title: 'Session', percent: 0.78, resetAt: '', spanMs: 5 * hour },
    { title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetAt: '', spanMs: week }
  ],
  'agents panel titles a limit off the collector when it states one'
)

assertDeepEqual(
  limitWindows({ limits: [{ label: 'Weekly (7-day)', percent: 0.12, resetsAt: '' }] }),
  [{ title: 'Weekly', percent: 0.12, resetAt: '', spanMs: week }],
  'agents panel still reads a window out of a label that carries no title'
)

const resetAt = new Date(panelRoot.nowMs + 1000).toISOString()
const measured = { limits: [{ label: 'Session (5-hour)', percent: 0.78, resetsAt: resetAt }] }
assertEqual(limitWindows(measured)[0].percent, 0.78, 'usage remains until the reset time')
panelRoot.nowMs += 1000
assertDeepEqual(limitWindows(measured), [{ title: 'Session', percent: 0, resetAt: '', spanMs: 5 * hour }], 'usage resets at the deadline while the panel stays open')
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
    { title: 'Session', percent: 0.94, resetAt: '', spanMs: 5 * hour, scoped: [] },
    { title: 'Weekly', percent: 0.25, resetAt: 'w', spanMs: week, scoped: [{ title: 'Fable', percent: 0.09, resetAt: 'w' }] },
    { title: 'Opus Monthly', percent: 0.5, resetAt: '', spanMs: 30 * day, scoped: [] }
  ],
  'agents panel shows a model-scoped window under the window it runs on'
)
JS

# Pace is where even use would have the meter by now. Over it, the window runs
# out before its reset, and the tooltip names when; under it, the window lasts.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const english = JSON.parse(fs.readFileSync(root + '/default/i18n/en/shell.json', 'utf8'))
const panelRoot = { nowMs: Date.UTC(2026, 9, 29, 9, 0) }
const Commons = { I18n: { t: key => english[key], formatNumber: String, formatLocale: 'en_US' } }
const Qt = { locale: () => ({ toString: (date, format) => format + ' ' + date.toISOString() }) }
const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v))
// Qt's String.arg fills the lowest-numbered placeholder left.
String.prototype.arg = function(value) {
  const numbers = [...this.matchAll(/%(\d)/g)].map(match => Number(match[1]))
  return numbers.length ? this.split('%' + Math.min(...numbers)).join(String(value)) : String(this)
}
const formatDuration = ms => Math.round(ms / 3600000) + 'h'
const start = source.indexOf('function windowIsLong')
const end = source.indexOf('// The window that decides')
eval(source.slice(start, end).replaceAll('root.nowMs', 'panelRoot.nowMs'))

const hour = 3600 * 1000
const week = 7 * 24 * hour
const weekly = (percent, left) => limitWindows({ limits: [
  { label: 'Weekly (7-day)', percent, resetsAt: new Date(panelRoot.nowMs + left).toISOString() }
] })[0]

const behind = weekly(0.31, week * 0.74)
assertEqual(Math.round(paceFor(behind) * 100), 26, 'pace is the share of the window already gone')
const ahead = paceText(behind)
assert(ahead.startsWith('5% over pace · runs out ddd HH:mm '), 'over pace names the run-out day and time', ahead)
const elapsed = week * 0.26
const out = panelRoot.nowMs + 0.69 * elapsed / 0.31
assert(ahead.includes(new Date(out).toISOString()), 'the run-out time carries the average burn forward to 100%', ahead)
assert(ahead.endsWith(', ' + Math.round((panelRoot.nowMs + week * 0.74 - out) / hour) + 'h before reset'), 'over pace says how long before the reset', ahead)
assertEqual(paceText(weekly(0.20, week * 0.74)), '6% under pace · lasts until reset', 'under pace lasts until the reset')
assertEqual(paceText(weekly(0.27, week * 0.74)), 'On pace', 'a couple of points either way is on pace')
assertEqual(paceText(weekly(0.10, week * 0.99)), '9% over pace', 'too early in the window to name a time')
assertEqual(paceText(weekly(1, week * 0.5)), '', 'a spent window has no pace to keep')
assertEqual(paceFor(weekly(0.31, 0)), -1, 'a window past its reset has no pace')
const spend = limitWindows({ limits: [
  { label: 'Spend limit', title: 'Spend limit', percent: 0.4, resetsAt: new Date(panelRoot.nowMs + hour).toISOString() }
] })[0]
assertEqual(paceFor(spend), -1, 'a limit with no clock gets no pace')
assertEqual(paceText(spend), '', 'a limit with no clock gets no pace line')

// A monthly allowance is a billing period ending at its reset: February's is
// 28 days, so halfway through it the notch sits at half, not at 14 / 30.
panelRoot.nowMs = Date.UTC(2026, 1, 15)
const monthly = (resetsAt, title) => limitWindows({ limits: [{ label: 'Monthly allowance', title, percent: 0.5, resetsAt }] })[0]
assertEqual(monthly('2026-03-01T00:00:00Z').spanMs, 28 * 24 * hour, 'a monthly window runs back to the same day a month earlier')
assertEqual(monthly('2026-08-01T00:00:00Z').spanMs, 31 * 24 * hour, 'a monthly window counts the days of the month it covers')
assertEqual(monthly('2026-03-31T00:00:00Z').spanMs, 31 * 24 * hour, 'a reset day the earlier month lacks starts on its last day')
assertEqual(monthly('2026-08-01T00:00:00Z', 'Pro Monthly').spanMs, 31 * 24 * hour, 'a model-scoped monthly window runs on the same month')
assertEqual(paceFor(monthly('2026-03-01T00:00:00Z')), 0.5, 'halfway through February is half the monthly window')
JS
