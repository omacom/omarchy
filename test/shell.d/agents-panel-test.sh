#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

const signInFunctions = ['supportsSignIn', 'signedOut', 'needsSignIn', 'usageNote'].map(name => {
  const match = panelSource.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))
  return match ? match[0] : ''
}).join('\n')
const signIn = new Function('addProviders', 'helpDisplayText', 'statusDisplayText', signInFunctions + '\nreturn {needsSignIn, signedOut, usageNote}')(
  [{providerId: 'claude'}, {providerId: 'codex'}, {providerId: 'grok'}], text => text, status => status
)
for (const id of ['claude', 'codex', 'grok']) {
  assert(signIn.needsSignIn({providerId: id, usageStatusText: 'Sign-in expired'}), id + ' keeps its sign-in link')
  assertEqual(signIn.usageNote({providerId: id, usageStatusText: 'Sign-in expired'}), '', id + ' offers its sign-in link instead of a note')
}
assert(signIn.needsSignIn({usageStatusText: 'Sign-in expired'}), 'account rows keep their sign-in link')
for (const status of ['Sign-in expired', 'Waiting for auth']) {
  assert(!signIn.needsSignIn({providerId: 'agy', usageStatusText: status}), 'an agent the panel cannot sign in gets no link for ' + status)
  assert(signIn.signedOut({providerId: 'agy', usageStatusText: status}), 'an agent the panel cannot sign in still counts as signed out for ' + status)
  assertEqual(signIn.usageNote({providerId: 'agy', usageStatusText: status}), status, 'an agent the panel cannot sign in still notes ' + status)
}
assertEqual(signIn.usageNote({providerId: 'grok', usageStatusText: 'Limits paused', authHelpText: 'Start Grok to refresh it.'}),
  'Start Grok to refresh it.', 'paused limits stay on show with a note saying how to refresh them')
assertEqual(signIn.usageNote({providerId: 'grok', usageStatusText: ''}), '', 'current limits carry no note')
assertEqual(signIn.usageNote({providerId: 'grok', usageStatusText: '', limitsStale: true, authHelpText: "Couldn't reach Grok's usage endpoint."}),
  "Couldn't reach Grok's usage endpoint.", 'a failed refresh that kept its limits still says why')
assertEqual(signIn.usageNote({usageStatusText: '', stale: true, authHelpText: 'Endpoint returned 500.'}),
  'Endpoint returned 500.', 'an account whose refresh failed still says why')

// Node covers timestamp guards and tooltip composition; custom date formats
// need Qt. Adapt its date overload to Intl for these non-formatting checks.
const Qt = { locale: code => code }
class LocaleDate extends Date {
  toLocaleString(locale) {
    return super.toLocaleString(locale, { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' })
  }
}
const catalog = JSON.parse(fs.readFileSync(root + '/default/i18n/en/shell.json', 'utf8'))
const translated = value => ({
  arg(arg) { return translated(value.replace(/%\d/, String(arg))) },
  toString() { return value }
})
const Commons = { I18n: {
  formatLocale: 'en-US', formatNumber: String,
  t: key => translated(catalog[key])
} }
const helpers = ['formatResetAt', 'formatDuration', 'windowDisplayTitle', 'scopedAllowanceText'].map(name =>
  panelSource.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]).join('\n')
const tooltipRoot = new Function('Qt', 'Date', 'Commons', helpers + '\nreturn {formatResetAt, formatDuration, windowDisplayTitle, scopedAllowanceText}')(
  Qt, LocaleDate, Commons)
for (const value of ['', undefined, null, false, 0, 'not-a-date', '<b>invalid</b>'])
  assertEqual(tooltipRoot.formatResetAt(value), '', 'no invented reset date for ' + value)
const resetAt = '2030-01-02T15:04:05Z'
const compact = { window: { title: 'Weekly', percent: 0.42, resetAt }, resetMs: 7200000, scoped: [], stale: false }
const tooltipBody = panelSource.slice(panelSource.indexOf('component CompactLimit:')).match(/text: \{([^]*?)\n      \}/)[1]
const tooltip = new Function('compact', 'root', 'Commons', tooltipBody).bind(null, compact, tooltipRoot, Commons)
const exact = tooltipRoot.formatResetAt(resetAt)
assertEqual(tooltip(), 'Weekly: 42% used · resets in 2h 0m\nResets at ' + exact, 'limit tooltip keeps the countdown and adds the exact reset')
compact.window.resetAt = 'bad-date'
assertEqual(tooltip(), 'Weekly: 42% used · resets in 2h 0m', 'invalid reset dates add no tooltip line')
compact.window.resetAt = resetAt
compact.stale = true
compact.fetchedAt = 0
compact.scoped = [{ title: '<b>Fable</b>', percent: 0.1 }]
assertEqual(tooltip(), 'Weekly: 42% used · resets in 2h 0m\nResets at ' + exact + '\nLast updated time unavailable\n<b>Fable</b>: 10% of its weekly allowance',
  'exact resets preserve stale and scoped notes as plain text')

// Local history alone feeds the summary; a section needs a subscription to show.
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const subscribed = new Function(mainSource.match(/function providerHasSubscription\([^]*?\n  \}/)[0] + '\nreturn providerHasSubscription')()
const historyOnly = { limits: [], accounts: [], balance: null, tierLabel: '', totalPrompts: 1 }
assertEqual(subscribed(historyOnly), false, 'an agent with only local history gets no section')
assertEqual(subscribed({ ...historyOnly, tierLabel: 'X Premium+' }), true, 'a plan earns a section before its limits arrive')
assertEqual(subscribed({ ...historyOnly, limits: [{ label: 'Weekly', percent: 0.04 }] }), true, 'kept limits earn a section')
assertEqual(subscribed({ ...historyOnly, spend: { amount: 1.25, days: [] } }), true, 'spend alone earns a section')

// A reworded collector line would silently fall back to English, so every
// fixed help line the collectors cache must still be one the panel maps.
for (const name of ['claude', 'codex', 'grok', 'fireworks']) {
  const collector = fs.readFileSync(root + '/bin/omarchy-agent-usage-' + name, 'utf8')
  const help = collector.match(/^AUTH_HELP = "([^"]+)"$/m)
  assert(help && panelSource.includes('case ' + JSON.stringify(help[1]) + ':'), name + ' auth help is translated in the panel')
}
JS

# Node cannot render Qt date patterns, but must pass the catalog's pattern
# and the selected formatting locale through unchanged, including fallback.
run_node_test <<'JS'
const fs = require('fs')
const panel = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const i18n = fs.readFileSync(root + '/shell/Commons/I18n.qml', 'utf8')
const english = JSON.parse(fs.readFileSync(root + '/default/i18n/en/shell.json', 'utf8'))
const state = { englishStrings: english, languageStrings: {} }
const merge = new Function('root', i18n.match(/readonly property var strings: \{([^]*?)\n  \}/)[1])
const translate = new Function('root', i18n.match(/function t\([^]*?\n  \}/)[0] + '\nreturn t')(state)
const Commons = { I18n: { formatLocale: 'en-US', t: translate } }
const Qt = { locale: code => ({ code }) }
class CapturedDate extends Date {
  toLocaleString(locale, pattern) { return { locale: locale.code, pattern } }
}
const format = new Function('Date', 'Qt', 'Commons', panel.match(/function formatResetAt\([^]*?\n  \}/)[0] + '\nreturn formatResetAt')(CapturedDate, Qt, Commons)
const resetAt = '2030-01-02T15:04:05Z'
state.strings = merge(state)
assertDeepEqual(format(resetAt), { locale: 'en-US', pattern: 'ddd d MMM, HH:mm' }, 'English keeps the compact reset pattern without seconds, year or zone')
Commons.I18n.formatLocale = 'ja-JP'
state.languageStrings = { 'agents.resetDateFormat': 'M/d (ddd) HH:mm' }
state.strings = merge(state)
assertDeepEqual(format(resetAt), { locale: 'ja-JP', pattern: 'M/d (ddd) HH:mm' }, 'reset dates consume the translated pattern and selected formatting locale')
state.languageStrings = {}
state.strings = merge(state)
assertDeepEqual(format(resetAt), { locale: 'ja-JP', pattern: 'ddd d MMM, HH:mm' }, 'a missing translated reset pattern falls back to English, retaining the selected locale')
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

# The saved order keeps agents where they were put, including ones hidden now.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const functions = ['orderedProviders', 'moveProvider'].map(name => source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]).join('\n')
let providerOrder = ['codex', 'kimi', 'claude', 'hidden']
let panelProviders = [{providerId: 'claude'}, {providerId: 'codex'}, {providerId: 'kimi'}, {providerId: 'grok'}]
let saved = ''
const orderFile = {setText: text => { saved = text }}
eval(functions)
panelProviders = orderedProviders(panelProviders)
assertDeepEqual(panelProviders.map(p => p.providerId), ['codex', 'kimi', 'claude', 'grok'], 'saved order keeps its agents in place and puts new ones last')
moveProvider('grok', 0)
assertDeepEqual(JSON.parse(saved), ['grok', 'codex', 'kimi', 'claude', 'hidden'], 'moving an agent saves the order and retains hidden ids')
JS

# Exercise the panel's drag lifecycle with Elsewhen's real variable-height math.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const Reorder = {}
vm.runInNewContext(fs.readFileSync(root + '/shell/plugins/panels/elsewhen/Model.js', 'utf8').replace(/^\.pragma.*$/mg, ''), Reorder)
const state = {
  dragIndex: 0, dragTarget: 0, dragOffset: 0, dragPressY: 100,
  rowPitches: [80, 140, 60], providers: [{providerId: 'codex'}, {providerId: 'kimi'}, {providerId: 'claude'}],
  dragProviderId: 'codex', dragProviders: [], settling: false
}
let writes = []
const dropAnimation = {stop() {}, restart() {}}
const usage = {moveProvider: (id, to) => writes.push([id, to])}
const Style = {duration: () => 0}
const Qt = {callLater() {}}
for (const name of ['dragProviderOver', 'resetProviderDrag', 'finishProviderDrag', 'settleProviderDrag']) {
  const fn = source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]
  state[name] = new Function('Reorder', 'dropAnimation', 'usage', 'Style', 'Qt', 'with (this) { return (' + fn + ').apply(this, arguments[5]) }')
    .bind(state, Reorder, dropAnimation, usage, Style, Qt)
  const bound = state[name]
  state[name] = (...args) => bound(args)
}
state.dragProviderOver(290)
assertEqual(state.dragTarget, 2, 'mixed heights determine the downward target')
assertDeepEqual([0, 1, 2].map(i => Reorder.rowShift(i, 0, 2, state.dragOffset, 80)), [190, -80, -80], 'passed sections shift up by the dragged pitch')
state.settleProviderDrag(false)
assertDeepEqual(writes, [['codex', 2]], 'reduced motion still commits the drop')
assertEqual(state.dragIndex, -1, 'commit clears translations')
Object.assign(state, {dragIndex: 2, dragTarget: 0, dragProviderId: 'claude', dragOffset: -200, settling: false})
assertEqual(Reorder.dropOffset(2, 0, 60, state.rowPitches), -220, 'upward drop sums the passed pitches')
assertDeepEqual([0, 1, 2].map(i => Reorder.rowShift(i, 2, 0, -200, 60)), [60, 60, -200], 'passed sections shift down by the dragged pitch')
state.settleProviderDrag(true)
assertEqual(writes.length, 1, 'cancel saves no order')
assertDeepEqual([0, 1, 2].map(i => Reorder.rowShift(i, state.dragIndex, state.dragTarget, state.dragOffset, 60)), [0, 0, 0], 'cancel clears every offset')
JS

