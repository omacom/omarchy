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
    { title: 'Session', percent: 0.78, resetAt: '', spanMs: 18000000, history: [] },
    { title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetAt: '', spanMs: 604800000, history: [] }
  ],
  'agents panel titles a limit off the collector when it states one'
)

assertDeepEqual(
  limitWindows({ limits: [{ label: 'Weekly (7-day)', percent: 0.12, resetsAt: '' }] }),
  [{ title: 'Weekly', percent: 0.12, resetAt: '', spanMs: 604800000, history: [] }],
  'agents panel still reads a window out of a label that carries no title'
)

const resetAt = new Date(panelRoot.nowMs + 1000).toISOString()
const measured = { limits: [{ label: 'Session (5-hour)', percent: 0.78, resetsAt: resetAt }] }
assertEqual(limitWindows(measured)[0].percent, 0.78, 'usage remains until the reset time')
panelRoot.nowMs += 1000
assertDeepEqual(limitWindows(measured), [{ title: 'Session', percent: 0, resetAt: '', spanMs: 18000000, history: [] }], 'usage resets at the deadline while the panel stays open')
assertEqual(measured.limits[0].percent, 0.78, 'display reset leaves the measured record intact')

// A model's weekly allowance is a row of its own, paced on the weekly clock.
assertDeepEqual(
  limitWindows({ limits: [{ label: 'Fable Weekly', title: 'Fable Weekly', percent: 0.09, resetsAt: '' }] }),
  [{ title: 'Fable Weekly', percent: 0.09, resetAt: '', spanMs: 604800000, history: [] }],
  'agents panel gives a model-scoped window the span of the window it runs on'
)
// A scoped session's label carries no length; it borrows the session's.
assertDeepEqual(
  limitWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.5, resetsAt: '' },
    { label: 'Fable Session', title: 'Fable Session', percent: 0.2, resetsAt: '' },
    { label: 'Opus Monthly', title: 'Opus Monthly', percent: 0.1, resetsAt: '' }
  ] }).map(w => [w.title, w.spanMs]),
  [['Session', 18000000], ['Fable Session', 18000000], ['Opus Monthly', 0]],
  'a model-scoped session paces on the session clock, and a monthly one still draws no pace'
)

// Pace weighs what is left against the share of the window still ahead; the
// projection carries the rate so far to the reset and stays quiet where it
// would only guess.
const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v))
eval(source.slice(source.indexOf('function resetMsFor'), source.indexOf('function formatDuration')).replaceAll('root.nowMs', 'panelRoot.nowMs'))
eval(source.slice(source.indexOf('function windowLeft'), source.indexOf('// Within the on-pace band')).replaceAll('root.nowMs', 'panelRoot.nowMs'))
const hour = 3600 * 1000
const weekly = (percent, hoursLeft) => ({ percent, resetAt: new Date(panelRoot.nowMs + hoursLeft * hour).toISOString(), spanMs: 168 * hour })

const heavy = paceFor(weekly(0.4, 128))
assertEqual(heavy.state, 'ahead', 'less left than the share of the window ahead is ahead of pace')
assertEqual(Math.round(heavy.evenLeft * 100), 76, 'the pace tick sits at the share of the window still ahead')
assertEqual(Math.round(-heavy.leftAtReset * 100), 68, 'an allowance that runs dry says how much more the rate needs')
assertEqual(Math.round(heavy.runsOutMs / hour), 60, 'an allowance that runs dry says when')
assertEqual(paceFor(weekly(0.27, 128)).state, 'on', 'within five points of the clock is on pace')
const light = paceFor(weekly(0.1, 128))
assertEqual(light.state, 'under', 'more left than the clock is under pace')
assertEqual(Math.round(light.leftAtReset * 100), 58, 'the projection says what is still left at the reset')
assertEqual(light.runsOutMs, -1, 'an allowance that outlasts its window never runs out')
assertEqual(paceFor(weekly(0.03, 167)).projected, false, 'the first 5% of a window projects nothing')
assertEqual(paceFor({ ...weekly(0.4, 128), spanMs: 60 * 1000 }), null, 'a span shorter than the time to reset is a misread label')
const session = { limits: [{ label: 'Session (5-hour)', percent: 0.5, resetsAt: new Date(panelRoot.nowMs + 2.5 * hour).toISOString() }] }
assertEqual(paceFor(limitWindows(session)[0]).evenLeft, 0.5, 'the window length comes from the collector label')
const monthly = { limits: [{ label: 'Monthly', percent: 0.15, resetsAt: new Date(panelRoot.nowMs + 26 * 24 * hour).toISOString() }] }
assertEqual(paceFor(limitWindows(monthly)[0]), null, 'a monthly window of unknown length draws no pace')

// Samples on the window put the projection on the recent burn rate: about the
// last fifth of the window, an hour of a session or a day of a week.
eval(source.slice(source.indexOf('function paceUrgent'), source.indexOf('function paceGlyph')))
const minute = 60 * 1000
const sampled = (percent, hoursLeft, spanHours, samples) => ({
  percent, resetAt: new Date(panelRoot.nowMs + hoursLeft * hour).toISOString(), spanMs: spanHours * hour,
  history: samples.map(([minutesAgo, p]) => [panelRoot.nowMs - minutesAgo * minute, p])
})
const future = new Date(panelRoot.nowMs + hour).toISOString()
assertDeepEqual(limitWindows({ limits: [{ label: 'Session (5-hour)', percent: 0.1, resetsAt: future, history: [[1, 0.1]] }] })[0].history,
  [[1, 0.1]], 'a window keeps the samples its record carries')
// A session whose window opened on the hour but whose first prompt came 45
// minutes later: 22% gone in those 45 minutes, not in the 90 since the hour.
const lateStart = sampled(0.22, 3.5, 5, [[45, 0], [30, 0.08], [15, 0.15], [0, 0.22]])
assertEqual(paceFor({ ...lateStart, history: [] }).runsOutMs, -1, 'the average over the whole window sees a session that lasts')
const late = paceFor(lateStart)
assertEqual(late.rateSpanMs, 45 * minute, 'samples younger than the lookback use all they cover')
assertEqual(Math.round(late.runsOutMs / minute), 160, 'the recent rate says when the session runs dry')
assertEqual(Math.round(-late.leftAtReset * 100), 25, 'and how much more allowance it would need')
assert(paceUrgent(late), 'a recent rate that runs dry is urgent even under pace by the clock')
assert(!paceUrgent(paceFor(weekly(0.24, 128))), 'an average that runs dry on pace is still only rounding')
const idle = paceFor(sampled(0.22, 3, 5, [[90, 0.02], [60, 0.2], [45, 0.22], [0, 0.22]]))
assertEqual(idle.rateSpanMs, hour, 'the rate looks back an hour of a session')
assertEqual(Math.round(idle.leftAtReset * 100), 72, 'a burst that stopped no longer drains the projection')
assertEqual(paceFor(sampled(0.22, 3.5, 5, [[5, 0.21], [0, 0.22]])).rateSpanMs, 0, 'a few minutes of samples leave the average in place')
const behind = paceFor(sampled(0.22, 3.5, 5, [[70, 0], [10, 0.22]]))
assertEqual(Math.round(behind.runsOutMs / minute), 203, 'the rate holds from its newest sample, not from now')
assertEqual(paceFor(sampled(0.42, 64, 168, [[23 * 60, 0.3], [0, 0.42]])).rateSpanMs, 0, 'a week needs a whole day of samples')
// 11% gone over an evening and a night of work, well under pace for the week:
// carried over the nights to the reset, that rate would run dry before it.
const evening = paceFor(sampled(0.52, 53, 168, [[11 * 60 + 22, 0.41], [0, 0.52]]))
assertEqual(evening.state, 'under', 'the evening ends under pace by the clock')
assertEqual(evening.rateSpanMs, 0, 'an evening of samples leaves the week on its average')
assertEqual(Math.round(evening.leftAtReset * 100), 24, 'which still leaves headroom at the reset')
const week = paceFor(sampled(0.42, 64, 168, [[36 * 60, 0.25], [24 * 60, 0.3], [0, 0.42]]))
assertEqual(week.rateSpanMs, 24 * hour, 'the rate looks back a day of a week')
assertEqual(Math.round(week.leftAtReset * 100), 26, 'the projection carries the last day to the reset')
JS

# A rewrite may briefly leave an incomplete file; lifecycle state must survive it.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const state = { localModel: {} }
const parse = new Function('root', source.match(/function parseLocalModel\([^]*?\n  \}/)[0] + '\nreturn parseLocalModel')(state)
const running = { models: { 'model-a': { recipe: 'model-a', unit: 'active', endpoint: 'http://127.0.0.1:11435/v1' }, 'model-b': { recipe: 'model-b', unit: 'activating' } }, ram_total_gib: 125.1 }
parse(JSON.stringify(running))
assertDeepEqual(state.localModel, running, 'lifecycle state loads without any usage record')
for (const raw of ['{', 'null', '[]', '{}', '{"models":[]}', '{"models":{"model-a":{"recipe":false,"unit":"active"}}}', '{"models":{"model-a":{"recipe":"model-a","unit":"unknown"}}}']) {
  parse(raw)
  assertDeepEqual(state.localModel, running, 'invalid lifecycle state keeps the last good value: ' + raw)
}
parse('{"models":{"model-a":{"recipe":"model-a","unit":"failed","result":"exit-code"}}}')
assertEqual(state.localModel.models['model-a'].result, 'exit-code', 'a server failure replaces the running state')
parse('{"models":{}}')
assertDeepEqual(state.localModel.models, {}, 'an empty models map clears the local lines')
JS

# Hosted and local rows share ordering, including positions saved while hidden.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const functions = ['orderedProviders', 'moveProvider'].map(name => source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]).join('\n')
let providerOrder = ['codex', 'local:a', 'claude', 'hidden']
let panelProviders = [{providerId: 'claude'}, {providerId: 'codex'}, {providerId: 'local:a'}, {providerId: 'local:b'}]
let saved = ''
const orderFile = {setText: text => { saved = text }}
eval(functions)
panelProviders = orderedProviders(panelProviders)
assertDeepEqual(panelProviders.map(p => p.providerId), ['codex', 'local:a', 'claude', 'local:b'], 'saved order interleaves local models and puts new models last')
moveProvider('local:b', 0)
assertDeepEqual(JSON.parse(saved), ['local:b', 'codex', 'local:a', 'claude', 'hidden'], 'moving a local model saves the shared order and retains hidden ids')
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
  rowPitches: [80, 140, 60], providers: [{providerId: 'codex'}, {providerId: 'local:a'}, {providerId: 'claude'}],
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

# A start that runs past its last duration must keep moving, never fill up.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const progress = new Function(source.match(/function phaseProgress\([^]*?\n  \}/)[0] + '\nreturn phaseProgress')()
assertEqual(progress(10, 10), 0.9, 'a start reaches 90% at the time the last one took')
assert(progress(20, 10) > progress(15, 10) && progress(15, 10) > 0.9, 'a start that runs long keeps creeping')
assert(progress(1000, 10) < 0.99, 'the bar never fills before the model is ready')
JS
