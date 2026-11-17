#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const limitReset = requireFromRoot('shell/plugins/agents/LimitResetModel.js')
const now = Date.parse('2026-09-18T12:00:00Z')
const enabled = () => true
const disabled = () => false
const record = (resetAt, label = 'weekly') => ({ id: 'codex', name: 'Codex', limits: resetAt ? [{ label, resetsAt: resetAt }] : [] })
const first = limitReset.schedule({}, [record('2026-09-18T12:10:00Z')], now, true, enabled)
assertEqual(Object.keys(first).length, 1, 'agents queue a future reset')

assertDeepEqual(limitReset.schedule(first, [], now, false, enabled), {}, 'disabled scheduling clears queued deadlines')

const transient = limitReset.schedule(first, [record()], now, true, enabled)
assertEqual(Object.keys(transient).length, 1, 'agents retain a reset across an empty transient fetch')

const disabledProvider = limitReset.schedule(first, [record('2026-09-18T12:10:00Z')], now, true, disabled)
assertEqual(Object.keys(disabledProvider).length, 1, 'agents retain a queued reset while its provider is disabled')
const suppressed = limitReset.announce(disabledProvider, Date.parse('2026-09-18T12:11:00Z'), true, disabled)
assertEqual(suppressed.notifications.length, 0, 'agents suppress a due reset for a disabled provider')
assertEqual(Object.keys(suppressed.pending).length, 0, 'agents remove a disabled provider reset at announce time')

const removed = limitReset.schedule(first, [], now, true, enabled)
assertDeepEqual(removed, {}, 'agents remove deadlines for absent records')
assertEqual(limitReset.announce(removed, Date.parse('2026-09-18T12:11:00Z'), true, enabled).notifications.length, 0,
  'removed providers never announce retained deadlines')
const removedDue = limitReset.schedule(first, [], Date.parse('2026-09-18T12:11:00Z'), true, enabled)
assertDeepEqual(removedDue, {}, 'record removal also clears already-due resets')
const sibling = { id: 'codex-team', name: 'Codex Team', limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:10:00Z' }] }
const sharedPrefix = limitReset.schedule(first, [record('2026-09-18T12:10:00Z'), sibling], now, true, enabled)
const siblingOnly = limitReset.schedule(sharedPrefix, [{ id: 'codex-team', limits: [] }], now, true, enabled)
assertEqual(Object.keys(siblingOnly).length, 1, 'removing a provider preserves a present ID sharing its prefix')
assertEqual(Object.values(siblingOnly)[0].providerName, 'Codex Team', 'prefix sibling retains its own deadline across empty limits')
assertDeepEqual(limitReset.schedule(first, [null, {}], now, true, enabled), {}, 'invalid records cannot preserve a removed provider')
assertDeepEqual(limitReset.schedule(first, [], now, true, disabled), {}, 'absent disabled providers are removed too')

const replaced = limitReset.schedule(first, [record('2026-09-18T12:20:00Z')], now, true, enabled)
assertEqual(Object.keys(replaced).length, 1, 'agents replace an obsolete deadline')
assertEqual(Object.values(replaced)[0].deadline, Date.parse('2026-09-18T12:20:00Z'), 'agents keep the replacement deadline')
const renamed = limitReset.schedule(replaced, [record('2026-09-18T12:30:00Z', 'monthly')], now, true, enabled)
assertEqual(Object.keys(renamed).length, 1, 'agents remove an old label when the provider response changes')
assertEqual(Object.values(renamed)[0].label, 'monthly', 'agents retain the authoritative replacement label')
const dueRefresh = limitReset.schedule(first, [record('2026-09-18T11:59:00Z')], Date.parse('2026-09-18T12:11:00Z'), true, enabled)
assertEqual(Object.keys(dueRefresh).length, 1, 'agents retain a due reset across a refresh before the timer')
const dueAndFuture = limitReset.schedule(first, [record('2026-09-18T12:20:00Z')], Date.parse('2026-09-18T12:11:00Z'), true, enabled)
assertEqual(Object.keys(dueAndFuture).length, 2, 'agents retain the due reset alongside a newly reported future reset')

const announced = limitReset.announce(first, Date.parse('2026-09-18T12:11:00Z'), true, enabled)
assertEqual(announced.notifications.length, 1, 'agents announce a passed reset')
assertEqual(Object.keys(announced.pending).length, 0, 'agents remove an announced reset')

const multiAccount = {
  id: 'codex', name: 'Codex',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:10:00Z' }],
  accounts: [
    { id: 'personal', accountId: 'subscription-personal', label: 'Personal', active: true, limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:10:00Z' }] },
    { id: 'work', accountId: 'subscription-work', label: 'Work', active: false, limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:20:00Z' }] }
  ]
}
const accountDeadlines = limitReset.schedule({}, [multiAccount], now, true, enabled)
assertEqual(Object.keys(accountDeadlines).length, 2, 'agents queue active and inactive account deadlines without duplicating top-level limits')
const unreadableFallback = limitReset.schedule({}, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'unreadable', fallbackAccountLabel: 'Configured home',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:30:00Z' }]
}], now, true, enabled)
assertEqual(Object.keys(unreadableFallback).length, 1, 'unreadable registries still schedule top-level limits when no account deadline is known')
assertDeepEqual(limitReset.announce(unreadableFallback, Date.parse('2026-09-18T12:31:00Z'), true, enabled).notifications.map(n => n.title),
  ['Codex (Configured home) limit reset'], 'unreadable fallback resets identify the configured home without guessing an account')
const translated = limitReset.announce(accountDeadlines, Date.parse('2026-09-18T12:21:00Z'), true, enabled,
  (key, english) => key === 'agents.accountLimitReset' ? '%2 / %1' : key === 'agents.limitWindowReset' ? 'Reset: %1' : english)
assertDeepEqual(translated.notifications.map(n => n.title).sort(), ['Personal / Codex', 'Work / Codex'],
  'reset notifications follow the display language placeholder order')
assert(translated.notifications.every(n => n.body.startsWith('Reset: ')), 'reset bodies use the display language')

const recoveredRegistry = limitReset.schedule(unreadableFallback, [multiAccount], now, true, enabled)
assertEqual(Object.keys(recoveredRegistry).length, 2, 'a readable account inventory replaces the unidentified fallback deadline')
assertDeepEqual(limitReset.announce(recoveredRegistry, Date.parse('2026-09-18T12:21:00Z'), true, enabled).notifications.map(n => n.title).sort(),
  ['Codex (Personal) limit reset', 'Codex (Work) limit reset'], 'registry recovery announces each account once without the fallback duplicate')
const expandedAccounts = limitReset.schedule(first, [multiAccount], now, true, enabled)
assertEqual(Object.keys(expandedAccounts).length, 2, 'adding a second account replaces the legacy provider deadline without duplicating it')
assertDeepEqual(limitReset.announce(expandedAccounts, Date.parse('2026-09-18T12:21:00Z'), true, enabled).notifications.map(n => n.title).sort(),
  ['Codex (Personal) limit reset', 'Codex (Work) limit reset'], 'account expansion announces only the account-specific deadlines')
const accountDue = limitReset.announce(accountDeadlines, Date.parse('2026-09-18T12:21:00Z'), true, enabled)
assertDeepEqual(accountDue.notifications.map(notification => notification.title).sort(),
  ['Codex (Personal) limit reset', 'Codex (Work) limit reset'], 'agents identify the account whose limit reset')

const afterAccountRemoval = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accounts: [multiAccount.accounts[0]], limits: multiAccount.limits
}], now, true, enabled)
assertEqual(Object.keys(afterAccountRemoval).length, 1, 'agents discard deadlines for accounts removed from an authoritative account list')
assertEqual(Object.values(afterAccountRemoval)[0].accountId, 'personal', 'agents preserve the remaining account deadline')
const transientAccount = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accounts: [
    { id: 'personal', accountId: 'subscription-personal', label: 'Personal', active: true, limits: [] },
    multiAccount.accounts[1]
  ]
}], now, true, enabled)
assertEqual(Object.keys(transientAccount).length, 2, 'agents retain an account deadline across a transient empty limits response')
const unreadableRegistry = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'unreadable',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:30:00Z' }]
}], now, true, enabled)
assertEqual(Object.keys(unreadableRegistry).length, 2, 'agents retain per-account deadlines when the registry is unreadable')
assertDeepEqual(limitReset.announce(unreadableRegistry, Date.parse('2026-09-18T12:21:00Z'), true, enabled).notifications.map(n => n.title).sort(),
  ['Codex (Personal) limit reset', 'Codex (Work) limit reset'], 'fallback active-account limits do not displace registered-account resets')
const missingRegistry = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'missing',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:30:00Z' }]
}], now, true, enabled)
assertEqual(Object.keys(missingRegistry).length, 2, 'agents preserve per-account deadlines when the registry is missing')
assertEqual(Object.keys(limitReset.schedule({}, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'missing', limits: multiAccount.limits
}], now, true, enabled)).length, 1, 'legacy installs without a registry still schedule top-level limits')
const singleAccountRegistry = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'available',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:30:00Z' }]
}], now, true, enabled)
assertEqual(Object.keys(singleAccountRegistry).length, 1, 'a readable single-account registry retires obsolete per-account deadlines')
assertEqual(Object.values(singleAccountRegistry)[0].deadline, Date.parse('2026-09-18T12:30:00Z'),
  'a readable single-account registry schedules its current top-level deadline')
const changedIdentity = limitReset.schedule(accountDeadlines, [{id: 'codex', name: 'Codex', accounts: [
  {id: 'personal', accountId: 'new-subscription', label: 'Personal', limits: []}, multiAccount.accounts[1]
]}], now, true, enabled)
assertEqual(Object.keys(changedIdentity).length, 1, 'a changed login with empty limits retires the old subscription deadline')
assertEqual(Object.values(changedIdentity)[0].accountId, 'work', 'a changed login preserves the other account deadline')
const signedOut = limitReset.schedule(accountDeadlines, [{id: 'codex', name: 'Codex', accounts: [
  {...multiAccount.accounts[0], accountId: ''}, multiAccount.accounts[1]
]}], now, true, enabled)
assertEqual(Object.keys(signedOut).length, 1, 'signing out retires the deadline even if stale limits remain in the record')
assertEqual(limitReset.announce(signedOut, Date.parse('2026-09-18T12:21:00Z'), true, enabled).notifications.length, 1,
  'a signed-out subscription never announces its stale reset')

const toggledOff = limitReset.announce(first, Date.parse('2026-09-18T12:11:00Z'), false)
assertEqual(toggledOff.notifications.length, 0, 'disabling reset notifications suppresses stale announcements')
assertEqual(Object.keys(toggledOff.pending).length, 0, 'disabling reset notifications clears stale pending state')
JS

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

# A rewrite may briefly leave an incomplete file; lifecycle state must survive it.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const state = { localModel: {}, noteReadyModels: () => {}, noteLaunchableModels: () => {} }
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
parse('{"models":{"model-a":{"recipe":"model-a","unit":"installing","install":{"phase":"downloading","done_bytes":5,"total_bytes":10}}}}')
assertEqual(state.localModel.models['model-a'].unit, 'installing', 'a setup in progress loads, so its download shows')
JS

# The recommended model is offered on the first page until a local model
# exists or the offer is hidden.
run_node_test <<'JS'
const fs = require('fs')
const main = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const localOffer = new Function(main.match(/function localOffer\([^]*?\n  \}/)[0] + '\nreturn localOffer')()
const recipes = [{ id: 'qwen', available: true }, { id: 'nemotron', best: true, available: true }]
const everyone = () => true
assertEqual(localOffer(recipes, {}, everyone).id, 'nemotron', 'a machine without local models is offered the best recipe')
assertEqual(localOffer(recipes, { qwen: { unit: 'inactive' } }, everyone), null, 'a machine with a local model gets no offer')
assertEqual(localOffer(recipes, {}, id => id !== 'local:nemotron'), null, 'a hidden offer stays hidden')
assertEqual(localOffer([{ id: 'nemotron', best: true, available: false }], {}, everyone), null, 'a best recipe that does not fit is not offered')
JS

# The tailnet survey can be rewritten under the panel; models whose host is
# away keep their lines, and only a well-formed survey replaces the last one.
run_node_test <<'JS'
const fs = require('fs')
const main = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const state = { networkModels: {} }
const parse = new Function('root', main.match(/function parseNetwork\([^]*?\n  \}/)[0] + '\nreturn parseNetwork')(state)
const survey = { models: {
  'box/big': { id: 'box/big', host: 'box', recipe: 'big', unit: 'active', paired: true, offline: '' },
  'away/small': { id: 'away/small', host: 'away', recipe: 'small', unit: 'inactive', paired: true, offline: 'offline', last_seen_ms: 5 },
} }
parse(JSON.stringify(survey))
assertDeepEqual(state.networkModels, survey.models, 'a survey loads its running and offline models')
for (const raw of ['{', 'null', '[]', '{"models":[]}', '{"models":{"box/big":{"id":"box/other","host":"box","recipe":"big","unit":"active"}}}', '{"models":{"box/big":{"id":"box/big","host":"box","recipe":"big","unit":"rebooting"}}}']) {
  parse(raw)
  assertDeepEqual(state.networkModels, survey.models, 'an invalid survey keeps the last good one: ' + raw)
}
const loaded = state.networkModels
parse(JSON.stringify({ models: { ...survey.models, 'box/big': { ...survey.models['box/big'], last_seen_ms: 99 } } }))
assert(state.networkModels === loaded, 'a survey that only moves last seen leaves the lines alone')
parse(JSON.stringify({ models: { 'away/small': survey.models['away/small'] } }))
assertDeepEqual(state.networkModels, { 'away/small': survey.models['away/small'] }, 'a model that stops being shared goes at the next survey')
parse(JSON.stringify(survey))
assertDeepEqual(state.networkModels, survey.models, 'a newly shared model appears at the next survey')
assertEqual(state.canShare, false, 'a survey without can_share does not offer sharing')
parse('{"models":{},"can_share":true}')
assertDeepEqual(state.networkModels, {}, 'an empty survey clears the network lines')
assertEqual(state.canShare, true, 'a survey that can share offers sharing')

const parseClients = new Function(main.match(/function parseClients\([^]*?\n  \}/)[0] + '\nreturn parseClients')()
assertDeepEqual(parseClients('{"models":{"m":2,"idle":0,"odd":"3","half":1.5}}'), { m: 2 }, 'only whole, positive machine counts are kept')
for (const raw of ['{', 'null', '[]', '{"models":[]}'])
  assertDeepEqual(parseClients(raw), {}, 'an unreadable count file counts nobody: ' + raw)

// A failed pairing's line is the reason's first line, not ssh's noise above
// it or the remedy below it.
const pairFailureMessage = new Function(main.match(/function pairFailureMessage\([^]*?\n  \}/)[0] + '\nreturn pairFailureMessage')()
assertEqual(pairFailureMessage("Pairing with box.tail.ts.net over SSH\nalice@box.tail.ts.net: Permission denied (publickey).\nError: box refused this machine's SSH keys\nStart the SSH agent that holds your key\n"),
  "box refused this machine's SSH keys", 'a failed pairing shows the first line of its reason')
assertEqual(pairFailureMessage('Traceback (most recent call last):\n  ...\n'), '', 'a pairing that gave no reason leaves the line to say it failed')

const panel = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const localActions = new Function(panel.match(/function localActions\([^]*?\n  \}/)[0] + '\nreturn localActions')()
assertDeepEqual(localActions({ recipe: 'm', unit: 'active' }, true), ['share', 'toggle', 'launch'], 'a running local model can be shared, stopped and launched')
assertDeepEqual(localActions({ recipe: 'm', unit: 'active' }, false), ['toggle', 'launch'], 'without Tailscale set up, sharing is not offered')
assertDeepEqual(localActions({ recipe: 'm', unit: 'active', shared: true }, false), ['share', 'toggle', 'launch'], 'a running shared model can always stop sharing')
assertDeepEqual(localActions({ recipe: 'm', unit: 'inactive', shared: true }, true), ['toggle'], 'a stopped shared model does not say it is shared')
assertDeepEqual(localActions({ recipe: 'm', unit: 'inactive' }, true), ['toggle'], 'a local model that has not been started is not offered for sharing')
assertDeepEqual(localActions({ recipe: 'm', unit: 'installing' }, true), [], 'a model being set up offers nothing yet')
assertDeepEqual(localActions({ host: 'box', recipe: 'm', unit: 'active', paired: true, offline: '' }), ['disconnect', 'launch'], 'a paired network model launches or disconnects, never stops its host\'s model')
assertDeepEqual(localActions({ host: 'box', recipe: 'm', unit: 'inactive', paired: true, offline: '' }), [], 'a paired network model that is not running offers nothing, not even disconnecting')
assertDeepEqual(localActions({ host: 'box', recipe: 'm', unit: 'active', paired: false, offline: '' }), ['pair'], 'an unpaired network model offers pairing only')
assertDeepEqual(localActions({ host: 'away', recipe: 'm', unit: 'inactive', paired: true, offline: 'offline' }), [], 'an offline network model offers nothing until its host is back')

// A model paired from the panel that is still starting on its host has no
// terminal yet: the cursor waits for one rather than giving up.
const modelId = new Function(panel.match(/function modelId\([^]*?\n  \}/)[0] + '\nreturn modelId')()
const landing = { landAfterPair: 'box/m', usage: { pairingId: '', pairFailures: {}, canShare: false }, root: { opened: true }, providers: [], localActions, modelId, pointed: null }
landing.pointAt = (kind, index) => { landing.pointed = [kind, index] }
const landOnPaired = new Function('scope', 'with (scope) { ' + panel.match(/function landOnPaired\([^]*?\n  \}/)[0] + '\nreturn landOnPaired }')(landing)
landing.providers = [{ localModel: { host: 'box', recipe: 'm', unit: 'activating', paired: true, offline: '' } }]
landOnPaired()
assert(landing.pointed === null && landing.landAfterPair === 'box/m', 'a paired model still starting keeps the cursor waiting for its terminal')
landing.providers = [{ localModel: { host: 'box', recipe: 'm', unit: 'active', paired: true, offline: '' } }]
landOnPaired()
assertDeepEqual(landing.pointed, ['modelLaunch', 0], 'the cursor lands on its terminal once it runs')
assertEqual(landing.landAfterPair, '', 'and stops waiting')

// A running network model shows what it is and how fast its host runs it,
// not that host's memory.
const i18n = { t: key => ({ text: key, arg(value) { this.text += '(' + value + ')'; return this }, toString() { return this.text } }), formatNumber: value => String(value) }
const remoteStats = new Function('Commons', panel.match(/function remoteStats\([^]*?\n  \}/)[0] + '\nreturn remoteStats')({ I18n: i18n })
assertEqual(remoteStats({ architecture: 'moe', decode_tok_s: 41.6, prefill_tok_s: 812.2, ctx: 262144 }),
  'agents.localSpeedFact(42) · agents.localContextFact(256)', 'a network model lists its output speed and context, never prefill')
assertEqual(remoteStats({ architecture: 'dense', decode_tok_s: null, prefill_tok_s: null, ctx: 0 }), '', 'unmeasured speeds and an unknown context are left out, and the architecture never shows')
assertEqual(remoteStats({}), '', 'a host that reports nothing gives no stats line')
JS

# The panel has no terminal for sudo: a detached setup missing its packages
# installs them through polkit first, and otherwise starts at once.
wrapper_dir=$(mktemp -d)
trap 'rm -rf "$wrapper_dir"' EXIT
for stub in omarchy-hw-nvidia omarchy-pkg-add omarchy-local-ai omarchy-agent-local-launchers omarchy-launch-floating-terminal-with-presentation; do
  printf '#!/bin/bash\nprintf "%%s\\n" "%s $*" >>"%s/calls"\n' "$stub" "$wrapper_dir" >"$wrapper_dir/$stub"
done
printf '#!/bin/bash\nexit 1\n' >"$wrapper_dir/omarchy-hw-nvidia"
# pkexec installs the packages unless its dialog is dismissed (126).
printf '#!/bin/bash\nprintf "%%s\\n" "pkexec $*" >>"%s/calls"\nstatus=$(cat "%s/pkexec-status")\n(( status == 0 )) && touch "%s/installed"\nexit $status\n' "$wrapper_dir" "$wrapper_dir" "$wrapper_dir" >"$wrapper_dir/pkexec"
chmod +x "$wrapper_dir"/omarchy-* "$wrapper_dir/pkexec"
run_wrapper() {
  rm -f "$wrapper_dir/calls" "$wrapper_dir/installed"
  printf '#!/bin/bash\n[[ -e "%s/installed" ]] && exit 1\nexit %s\n' "$wrapper_dir" "$1" >"$wrapper_dir/omarchy-pkg-missing"
  chmod +x "$wrapper_dir/omarchy-pkg-missing"
  shift
  PATH="$wrapper_dir:$PATH" "$ROOT/bin/omarchy-agent-local" "$@" >/dev/null || printf 'exit %s\n' "$?" >>"$wrapper_dir/calls"
  cat "$wrapper_dir/calls"
}
echo 0 >"$wrapper_dir/pkexec-status"
calls=$(run_wrapper 0 use --detach nemotron-3.5-bolt-tensorfold)
[[ $calls == $'pkexec /usr/bin/pacman -S --noconfirm --needed -- podman crun\nomarchy-local-ai use --detach nemotron-3.5-bolt-tensorfold\nomarchy-agent-local-launchers ' ]] || fail "a detached setup missing its packages installs them through polkit first" "$calls"
pass "a detached setup missing its packages installs them through polkit first"
echo 126 >"$wrapper_dir/pkexec-status"
calls=$(run_wrapper 0 use --detach nemotron-3.5-bolt-tensorfold)
[[ $calls == $'pkexec /usr/bin/pacman -S --noconfirm --needed -- podman crun\nexit 126' ]] || fail "a dismissed password dialog stops the setup as cancelled" "$calls"
pass "a dismissed password dialog stops the setup as cancelled"
calls=$(run_wrapper 1 use --detach nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-local-ai use --detach nemotron-3.5-bolt-tensorfold\nomarchy-agent-local-launchers ' ]] || fail "a detached setup with its packages starts without a terminal" "$calls"
pass "a detached setup with its packages starts without a terminal"
calls=$(run_wrapper 1 use nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-pkg-add podman crun\nomarchy-local-ai use nemotron-3.5-bolt-tensorfold\nomarchy-agent-local-launchers ' ]] || fail "a setup in a terminal installs its packages there" "$calls"
pass "a setup in a terminal installs its packages there"

# A model set up gets a launcher of its own and one removed loses it, so the
# launchers are brought up to date after either; the other commands leave them.
calls=$(run_wrapper 1 remove nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-local-ai remove nemotron-3.5-bolt-tensorfold\nomarchy-agent-local-launchers ' ]] || fail "removing a model brings the launchers up to date" "$calls"
calls=$(run_wrapper 1 stop nemotron-3.5-bolt-tensorfold)
[[ $calls == "omarchy-local-ai stop nemotron-3.5-bolt-tensorfold" ]] || fail "stopping a model leaves the launchers alone" "$calls"
printf '#!/bin/bash\nexit 7\n' >"$wrapper_dir/omarchy-local-ai"
calls=$(run_wrapper 1 remove nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-agent-local-launchers \nexit 7' ]] || fail "a removal that fails still reports its own exit status" "$calls"
printf '#!/bin/bash\nprintf "%%s\\n" "omarchy-local-ai $*" >>"%s/calls"\n' "$wrapper_dir" >"$wrapper_dir/omarchy-local-ai"
pass "setting up or removing a model brings its launcher up to date"

# Sharing needs the SSH server other machines pair over: the panel's Share
# sets it up in a terminal first, until it runs.
printf '#!/bin/bash\nexit %s\n' 3 >"$wrapper_dir/systemctl"
chmod +x "$wrapper_dir/systemctl"
calls=$(run_wrapper 1 share nemotron-3.5-bolt-tensorfold </dev/null)
[[ $calls == "omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-sshd && omarchy-local-ai 'share' 'nemotron-3.5-bolt-tensorfold'" ]] || fail "sharing without an SSH server sets one up in a terminal first" "$calls"
pass "sharing without an SSH server sets one up in a terminal first"
calls=$(run_wrapper 1 share nemotron-3.5-bolt-tensorfold --off </dev/null)
[[ $calls == "omarchy-local-ai share nemotron-3.5-bolt-tensorfold --off" ]] || fail "stopping a share never asks for an SSH server" "$calls"
pass "stopping a share never asks for an SSH server"
printf '#!/bin/bash\nexit 0\n' >"$wrapper_dir/systemctl"
calls=$(run_wrapper 1 share nemotron-3.5-bolt-tensorfold </dev/null)
[[ $calls == "omarchy-local-ai share nemotron-3.5-bolt-tensorfold" ]] || fail "sharing with the SSH server running shares at once" "$calls"
pass "sharing with the SSH server running shares at once"

# A setup from the panel has its line before status.json lists it: starting,
# then installing Podman once the command says so, and a failure stays with
# its reason, while a dismissed password dialog just brings the offer back.
# One chosen while another starts waits its turn instead of being dropped.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const names = ['setUp', 'startSetup', 'unqueueSetup', 'setupLine', 'finishSetup', 'setupRows', 'pairFailureMessage']
const scope = { I18n: { t: key => key }, setupProcess: {} }
for (const name of names)
  scope[name] = new Function('scope', 'with (scope) { return ' + source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0] + ' }')(scope)
const start = id => {
  Object.assign(scope, { settingUp: null, setupFailure: null, setupQueue: [], setupOutput: '' })
  scope.setUp({ id, name: id.toUpperCase(), vendor: 'v' })
}
const phases = () => scope.setupRows().map(row => row.recipe + ':' + row.install.phase)

start('m')
assertDeepEqual(phases(), ['m:starting'], 'a setup starts out as starting, never claiming an install it may not need')
scope.setupLine('Installing podman crun')
assertDeepEqual(phases(), ['m:dependencies'], 'it shows the install once the command announces it')
assertEqual(scope.finishSetup(126), null, 'a dismissed password dialog starts nothing')
assertDeepEqual(phases(), [], 'and leaves no line, so the offer comes back')

start('m')
scope.setupLine('Installing podman crun')
scope.setupLine("Error: Couldn't install podman crun")
scope.finishSetup(1)
const failed = scope.setupRows()[0]
assertEqual(failed.install.phase, 'failed', 'a failed install keeps its line')
assertEqual(failed.error, "Couldn't install podman crun", 'with the reason the command gave')

start('m')
assertEqual(scope.finishSetup(0), null, 'a setup handed to the background starts nothing more')
assertDeepEqual(phases(), [], 'and leaves its line to status.json')

start('m')
scope.setUp({ id: 'n' })
scope.setUp({ id: 'n' })
scope.setUp({ id: 'o' })
assertDeepEqual(phases(), ['m:starting', 'n:waiting', 'o:waiting'], 'setups chosen meanwhile wait their turn, once each')
scope.unqueueSetup('o')
assertDeepEqual(phases(), ['m:starting', 'n:waiting'], 'one waiting can be dropped')
assertEqual(scope.finishSetup(0).recipe, 'n', 'the next one starts once the first hands off')
scope.setUp({ id: 'o' })
scope.finishSetup(126)
assertDeepEqual(phases(), [], 'a declined password drops those waiting, which would stop there too')
JS

# A model set up here announces itself once it has loaded, and only then:
# starting one already set up is quiet, and one left stopped isn't ready.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const ready = []
const scope = { installingModels: {}, notifyModelReady: model => ready.push(model.recipe) }
scope.noteReadyModels = new Function('scope', 'with (scope) { return ' + source.match(/function noteReadyModels\([^]*?\n  \}/)[0] + ' }')(scope)
const model = (recipe, unit, sub_state) => ({ [recipe]: { recipe, unit, sub_state } })
scope.noteReadyModels(model('m', 'installing'))
scope.noteReadyModels(model('m', 'activating', 'start'))
assertDeepEqual(ready, [], 'a model still loading is not ready yet')
scope.noteReadyModels(model('m', 'active', 'running'))
assertDeepEqual(ready, ['m'], 'a model set up here is ready once it runs')
scope.noteReadyModels(model('m', 'inactive', 'dead'))
scope.noteReadyModels(model('m', 'active', 'running'))
assertDeepEqual(ready, ['m'], 'starting it again later says nothing')
scope.noteReadyModels(model('n', 'installing'))
scope.noteReadyModels(model('n', 'inactive', 'dead'))
scope.noteReadyModels(model('n', 'active', 'running'))
assertDeepEqual(ready, ['m'], 'one installed but left stopped is not announced when started by hand')
JS

# A setup the panel started finishes in the background, so the panel has the
# launchers redrawn when the models that can be opened change: one done
# installing, or one gone. A setup that finished while the shell wasn't
# watching is caught by the first reading; no models at startup syncs nothing.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
let syncs = 0
const fresh = () => {
  const scope = { launchableModels: '', syncLaunchers: () => syncs++ }
  scope.noteLaunchableModels = new Function('scope', 'with (scope) { return ' + source.match(/function noteLaunchableModels\([^]*?\n  \}/)[0] + ' }')(scope)
  return scope
}
const models = units => Object.fromEntries(Object.entries(units).map(([recipe, unit]) => [recipe, { recipe, unit }]))
fresh().noteLaunchableModels(models({}))
assertEqual(syncs, 0, 'a shell starting with no models has no launchers to sync')
const scope = fresh()
scope.noteLaunchableModels(models({ m: 'inactive' }))
assertEqual(syncs, 1, 'a model set up while the shell was away gets its launcher at startup')
syncs = 0
scope.noteLaunchableModels(models({ m: 'active' }))
scope.noteLaunchableModels(models({ m: 'active', n: 'installing' }))
assertEqual(syncs, 0, 'starting a model, or one still installing, changes no launcher')
scope.noteLaunchableModels(models({ m: 'active', n: 'activating' }))
assertEqual(syncs, 1, 'a model done installing gets its launcher')
scope.noteLaunchableModels(models({ m: 'removing', n: 'active' }))
assertEqual(syncs, 2, 'a model being removed loses its launcher')
scope.noteLaunchableModels(models({ n: 'active' }))
assertEqual(syncs, 2, 'and nothing more once it is gone')
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

require_command quickshell
require_command jq
test_tmp="$wrapper_dir/resets"
mkdir -p "$test_tmp/config" "$test_tmp/home" "$test_tmp/bin"
cp "$SHELL_TEST_DIR/fixtures/agents-reset/shell.qml" "$test_tmp/config/shell.qml"
ln -s "$ROOT/shell/plugins/agents" "$test_tmp/config/Agents"
ln -s "$ROOT/shell/Commons" "$test_tmp/config/Commons"
ln -s "$ROOT/shell/Ui" "$test_tmp/config/Ui"
cat >"$test_tmp/bin/omarchy-agent-usage-update" <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT
cat >"$test_tmp/bin/omarchy-notification-send" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFICATION_LOG"
SCRIPT
mkfifo "$test_tmp/sleep-events"
cat >"$test_tmp/bin/gdbus" <<'SCRIPT'
#!/bin/bash
if [[ $* == "monitor --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1" ]]; then
  exec cat "$SLEEP_EVENTS"
else
  exec /usr/bin/gdbus "$@"
fi
SCRIPT
export SLEEP_EVENTS="$test_tmp/sleep-events"
chmod +x "$test_tmp/bin"/*

# No desktop surfaces or provider requests: execute the real QML offscreen.
ulimit -c 0
HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config" \
  XDG_CACHE_HOME="$test_tmp/home/.cache" XDG_STATE_HOME="$test_tmp/home/.local/state" \
  OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
  PATH="$test_tmp/bin:$PATH" NOTIFICATION_LOG="$test_tmp/notifications" \
  env -u WAYLAND_DISPLAY -u DISPLAY -u QT_QPA_PLATFORMTHEME -u QT_STYLE_OVERRIDE timeout 15 quickshell -p "$test_tmp/config" --no-color >"$test_tmp/log" 2>&1 || {
    cat "$test_tmp/log" >&2
    fail "agent reset QML fixture loads and completes"
  }
result=$(sed -n 's/.*RESULT //p' "$test_tmp/log" | tail -n1)
jq -e '.ok == true' <<<"$result" >/dev/null || {
  cat "$test_tmp/log" >&2
  fail "agent reset QML ownership and settings checks pass"
}
for _ in {1..50}; do
  [[ -s $test_tmp/notifications ]] && break
  sleep 0.02
done
[[ $(wc -l <"$test_tmp/notifications") == "2" ]] || fail "two widgets deliver each of the two resets exactly once"
grep -F -- '--app-name Omarchy Agents' "$test_tmp/notifications" >/dev/null || fail "reset toast uses a DND-respecting app name"
pass "real QML shares one owner and delivers timed and overdue wake notifications once each"

# Exercise discovery and FileView transitions with real local usage records.
usage_dir="$test_tmp/home/.local/state/omarchy/agents/usage"
mkdir -p "$usage_dir"
reset_at=$(date -u -d '+1 hour' '+%Y-%m-%dT%H:%M:%SZ')
for provider in codex codex-team; do
  jq -n --arg id "$provider" --arg reset "$reset_at" \
    '{id: $id, name: $id, limits: [{label: "Session", resetsAt: $reset}]}' >"$usage_dir/$provider.json"
done
cp "$SHELL_TEST_DIR/fixtures/agents-reset/inventory.qml" "$test_tmp/config/shell.qml"
rm "$test_tmp/notifications"
HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config" \
  XDG_CACHE_HOME="$test_tmp/home/.cache" XDG_STATE_HOME="$test_tmp/home/.local/state" \
  OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
  PATH="$test_tmp/bin:$PATH" NOTIFICATION_LOG="$test_tmp/notifications" \
  env -u WAYLAND_DISPLAY -u DISPLAY -u QT_QPA_PLATFORMTHEME -u QT_STYLE_OVERRIDE timeout 15 quickshell -p "$test_tmp/config" --no-color >"$test_tmp/log" 2>&1 || {
    cat "$test_tmp/log" >&2
    fail "agent reset inventory fixture loads and completes"
  }
result=$(sed -n 's/.*RESULT //p' "$test_tmp/log" | tail -n1)
jq -e '.ok == true' <<<"$result" >/dev/null || {
  cat "$test_tmp/log" >&2
  fail "agent reset inventory lifecycle checks pass"
}
[[ ! -e $test_tmp/notifications ]] || fail "removed provider produces no reset notification at announce time"
pass "real QML prunes removed records while retaining unreadable, loading and empty-limit providers"
