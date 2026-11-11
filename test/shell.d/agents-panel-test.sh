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

# A spent limit that won't come back for weeks can be parked, so the bar icon
# stays free for the limits that can still be acted on, and the park lapses
# with the reset it was made for.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const fn = name => source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]
const panelRoot = { nowMs: Date.parse('2026-11-05T12:00:00Z') }
const usage = { parkedLimits: {} }
eval(['windowIsLong', 'windowSpanMs', 'windowTitle', 'limitWindow', 'limitWindows', 'scopedPart', 'displayWindows',
  'providerAccounts', 'isParked', 'parkKey', 'sameReset', 'canPark', 'alarmWindow', 'rowWindows', 'rowParkable', 'rowParked',
  'toggleParked'].map(fn).join('\n').replaceAll('root.nowMs', 'panelRoot.nowMs'))

const reset = '2026-12-01T01:00:00+01:00'
const copilot = { providerId: 'copilot', limits: [{ label: 'Monthly allowance', percent: 1, resetsAt: reset }] }
const [monthly] = limitWindows(copilot)
assert(canPark(copilot, monthly), 'a spent limit with a known reset can be parked')
assertEqual(alarmWindow(copilot).title, 'Monthly', 'a spent limit lights the bar until it is parked')

usage.parkedLimits = { copilot: { Monthly: reset } }
assert(isParked(copilot, monthly), 'the parked limit is recognized')
assertEqual(alarmWindow(copilot), null, 'a parked limit stops lighting the bar')

const codex = { providerId: 'codex', limits: [
  { label: 'Session (5-hour)', percent: 0.95, resetsAt: '2026-11-05T14:00:00Z' },
  { label: 'Weekly (7-day)', percent: 1, resetsAt: '2026-11-10T00:00:00Z' }
] }
usage.parkedLimits = { codex: { Weekly: '2026-11-10T00:00:00Z' } }
assertEqual(alarmWindow(codex).title, 'Session', "parking one window leaves the agent's other windows lighting the bar")

usage.parkedLimits = { copilot: { Monthly: '2026-12-01T00:10:00Z' } }
assert(isParked(copilot, monthly), 'a reset restated with a few minutes of drift stays parked')
usage.parkedLimits = { copilot: { Monthly: '2026-12-01T03:00:00Z' } }
assert(!isParked(copilot, monthly), 'a reset that moved brings the alarm back')

usage.parkedLimits = { copilot: { Monthly: reset } }
panelRoot.nowMs = Date.parse('2026-12-01T00:00:01Z')
const [rolledOver] = limitWindows(copilot)
assert(!isParked(copilot, rolledOver), 'a park lapses once its reset has passed')
assertDeepEqual(alarmWindow(copilot), { title: 'Monthly', percent: 0, resetAt: '' }, 'the rolled-over window counts again')
panelRoot.nowMs = Date.parse('2026-11-05T12:00:00Z')

const short = { providerId: 'codex', limits: [{ label: '30m window', percent: 0.95, resetsAt: '2026-11-05T12:30:00Z' }] }
usage.parkedLimits = { codex: { Session: '2026-11-05T12:00:00Z' } }
panelRoot.nowMs = Date.parse('2026-11-05T12:01:00Z')
assert(!isParked(short, limitWindows(short)[0]), 'a park on a short window does not carry into the next one')
assertEqual(alarmWindow(short).title, 'Session', 'the next short window lights the bar again')
panelRoot.nowMs = Date.parse('2026-11-05T12:00:00Z')

const nearly = { providerId: 'claude', limits: [{ label: 'Session (5-hour)', percent: 0.95, resetsAt: '2026-11-05T14:00:00Z' }] }
assert(!canPark(nearly, limitWindows(nearly)[0]), 'a limit short of full keeps its warning')
const noReset = { providerId: 'grok', limits: [{ label: 'Monthly', percent: 1, resetsAt: '' }] }
assert(!canPark(noReset, limitWindows(noReset)[0]), 'a limit with no known reset cannot be parked')
const accounts = { ...copilot, accounts: [{ id: 'a' }, { id: 'b' }] }
assert(!canPark(accounts, monthly), 'an agent with several accounts switches accounts instead')
usage.parkedLimits = { copilot: { Monthly: reset } }
assertEqual(alarmWindow(accounts).title, 'Monthly', 'a park made with one account no longer hides the limit once there are two')

const claude = { providerId: 'claude', limits: [
  { label: 'Weekly (7-day)', percent: 1, resetsAt: '2026-11-10T00:00:00Z' },
  { label: 'Fable Weekly', title: 'Fable Weekly', percent: 0.97, resetsAt: '2026-11-10T00:00:00Z' },
  { label: 'Opus Monthly', title: 'Opus Monthly', percent: 1, resetsAt: '2026-12-01T00:00:00Z' }
] }
usage.parkedLimits = { claude: { Weekly: '2026-11-10T00:00:00Z' } }
assertEqual(alarmWindow(claude).title, 'Opus Monthly', "a model's allowance on a parked row parks with it")
usage.parkedLimits = { claude: { Weekly: '2026-11-10T00:00:00Z', 'Opus Monthly': '2026-12-01T00:00:00Z' } }
assertEqual(alarmWindow(claude), null, 'a model allowance on its own row parks under its own title')

const fable = { providerId: 'claude', limits: [
  { label: 'Weekly (7-day)', percent: 0.6, resetsAt: '2026-11-10T00:00:00Z' },
  { label: 'Fable Weekly', title: 'Fable Weekly', percent: 1, resetsAt: '2026-11-10T00:00:00Z' }
] }
usage.parkedLimits = {}
const [weeklyRow] = displayWindows(fable)
assertDeepEqual(rowParkable(fable, weeklyRow).map(w => w.title), ['Fable Weekly'], 'a spent model on a row with room left can be parked')
usage.parkedLimits = { claude: { 'Fable Weekly': '2026-11-10T00:00:00Z' } }
assert(alarmWindow(fable).percent < 0.9, 'parking the spent model calms the bar')
fable.limits[0].percent = 0.95
assertEqual(alarmWindow(fable).title, 'Weekly', "the row's own window still lights the bar")
const unparked = []
usage.setLimitParked = (id, title, resetAt, parked) => unparked.push([title, parked])
toggleParked(fable, displayWindows(fable)[0])
assertDeepEqual(unparked, [['Fable Weekly', false]], "unparking the row ends the model's park")

const moved = { providerId: 'claude', limits: [
  { label: 'Weekly (7-day)', percent: 0.6, resetsAt: '2026-11-08T00:00:00Z' },
  { label: 'Fable Weekly', title: 'Fable Weekly', percent: 1, resetsAt: '2026-11-10T00:00:00Z' }
] }
usage.parkedLimits = { claude: { Weekly: '2026-11-10T00:00:00Z' } }
unparked.length = 0
toggleParked(moved, displayWindows(moved)[0])
assertDeepEqual(unparked, [['Weekly', false]], 'unparking a model removes the row park it inherited')
JS

# Parks are saved beside the usage records, and lapsed ones are dropped.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
let parkedLimits = { old: { Weekly: '2020-01-01T00:00:00Z' }, codex: { Weekly: '2999-01-01T00:00:00Z' } }
let saved = ''
const parkedFile = { setText: text => { saved = text } }
eval(source.match(/function setLimitParked\([^]*?\n  \}/)[0])
setLimitParked('copilot', 'Monthly', '2999-12-01T00:00:00Z', true)
assertDeepEqual(JSON.parse(saved), { codex: { Weekly: '2999-01-01T00:00:00Z' }, copilot: { Monthly: '2999-12-01T00:00:00Z' } }, 'parking saves the reset and drops lapsed parks')
setLimitParked('copilot', 'Monthly', '', false)
assertDeepEqual(parkedLimits, { codex: { Weekly: '2999-01-01T00:00:00Z' } }, 'unparking removes the agent once nothing of it is parked')

eval(source.match(/function endSharedParks\([^]*?\n  \}/)[0])
parkedLimits = { codex: { Weekly: '2999-01-01T00:00:00Z' }, copilot: { Monthly: '2999-12-01T00:00:00Z' } }
const agents = [{ record: { id: 'codex', accounts: [{ id: 'main' }, { id: 'work' }] } }, { record: { id: 'copilot' } }]
endSharedParks()
assertDeepEqual(JSON.parse(saved), { copilot: { Monthly: '2999-12-01T00:00:00Z' } }, "a second account ends the agent's parks")
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
# installs them in one first, and otherwise starts at once.
wrapper_dir=$(mktemp -d)
trap 'rm -rf "$wrapper_dir"' EXIT
for stub in omarchy-hw-nvidia omarchy-pkg-add omarchy-local-ai omarchy-launch-floating-terminal-with-presentation; do
  printf '#!/bin/bash\nprintf "%%s\\n" "%s $*" >>"%s/calls"\n' "$stub" "$wrapper_dir" >"$wrapper_dir/$stub"
done
printf '#!/bin/bash\nexit 1\n' >"$wrapper_dir/omarchy-hw-nvidia"
chmod +x "$wrapper_dir"/omarchy-*
run_wrapper() {
  rm -f "$wrapper_dir/calls"
  printf '#!/bin/bash\nexit %s\n' "$1" >"$wrapper_dir/omarchy-pkg-missing"
  chmod +x "$wrapper_dir/omarchy-pkg-missing"
  shift
  PATH="$wrapper_dir:$PATH" "$ROOT/bin/omarchy-agent-local" "$@"
  cat "$wrapper_dir/calls"
}
calls=$(run_wrapper 0 use --detach nemotron-3.5-bolt-tensorfold)
[[ $calls == "omarchy-launch-floating-terminal-with-presentation omarchy-pkg-add podman crun && omarchy-local-ai 'use' '--detach' 'nemotron-3.5-bolt-tensorfold'" ]] || fail "a detached setup missing its packages installs them in a terminal first" "$calls"
pass "a detached setup missing its packages installs them in a terminal first"
calls=$(run_wrapper 1 use --detach nemotron-3.5-bolt-tensorfold)
[[ $calls == "omarchy-local-ai use --detach nemotron-3.5-bolt-tensorfold" ]] || fail "a detached setup with its packages starts without a terminal" "$calls"
pass "a detached setup with its packages starts without a terminal"
calls=$(run_wrapper 1 use nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-pkg-add podman crun\nomarchy-local-ai use nemotron-3.5-bolt-tensorfold' ]] || fail "a setup in a terminal installs its packages there" "$calls"
pass "a setup in a terminal installs its packages there"

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
