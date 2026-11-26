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
const signIn = new Function('signInProviders', 'helpDisplayText', 'statusDisplayText', signInFunctions + '\nreturn {needsSignIn, signedOut, usageNote}')(
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

# The saved order keeps agents where they were put, including ones hidden now.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const functions = ['accountLines', 'lineId', 'orderedProviders', 'moveProvider'].map(name => source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]).join('\n')
let providerOrder = ['codex', 'kimi', 'claude', 'hidden']
let panelProviders = [{providerId: 'claude'}, {providerId: 'codex'}, {providerId: 'kimi'}, {providerId: 'grok'}]
let saved = ''
const orderFile = {setText: text => { saved = text }}
eval(functions)
const split = accountLines([{
  providerId: 'claude', accountName: 'main@example.com',
  accounts: [{id: 'main', email: 'main@example.com', plan: 'Max 20x'}, {id: 'side', email: '', plan: 'Pro'}]
}])
assertDeepEqual(split.map(p => p.accountName), ['main@example.com', ''], 'each split account line carries only its own email')
panelProviders = orderedProviders(panelProviders)
assertDeepEqual(panelProviders.map(p => p.providerId), ['codex', 'kimi', 'claude', 'grok'], 'saved order keeps its agents in place and puts new ones last')
moveProvider('grok', 0)
assertDeepEqual(JSON.parse(saved), ['grok', 'codex', 'kimi', 'claude', 'hidden'], 'moving an agent saves the order and retains hidden ids')


// Each account is a line of its own: its lines take the place saved for the
// agent until one is moved, and then that line moves alone.
providerOrder = ['codex', 'claude']
panelProviders = orderedProviders([{providerId: 'claude', lineId: 'claude/main'}, {providerId: 'claude', lineId: 'claude/work'}, {providerId: 'codex'}])
assertDeepEqual(panelProviders.map(lineId), ['codex', 'claude/main', 'claude/work'], 'account lines keep the place saved for their agent')
moveProvider('claude/work', 0)
assertDeepEqual(JSON.parse(saved).slice(0, 3), ['claude/work', 'codex', 'claude/main'], 'an account line moves on its own')
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


# Local coding models: a line for each set up here in any state, or set up
# from the panel, and each a paired, online machine runs; never a media model.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const fn = name => source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]
const build = new Function(fn('buildLocalModelLines') + '\nreturn buildLocalModelLines')()
const targets = (models, setups, network) => build(models, setups, network, []).map(line => line.localModel.target)
assertDeepEqual(targets({
  q: { recipe: 'q', kind: 'text', unit: 'inactive' },
  f: { recipe: 'f', kind: 'text', unit: 'failed' },
  pic: { recipe: 'pic', kind: 'image', unit: 'active' }
}, [{ recipe: 'n', kind: 'text', unit: 'installing' }, { recipe: 'q', kind: 'text', unit: 'installing' }], {
  'box/d': { recipe: 'd', host: 'box', kind: 'text', unit: 'active', paired: true, offline: '' },
  'box/s': { recipe: 's', host: 'box', kind: 'text', unit: 'inactive', paired: true, offline: '' },
  'box/u': { recipe: 'u', host: 'box', kind: 'text', unit: 'active', paired: false, offline: '' },
  'away/a': { recipe: 'a', host: 'away', kind: 'text', unit: 'active', paired: true, offline: 'offline' }
}), ['q', 'f', 'n', 'box/d'], 'every coding model here and each setup gets a line, a paired machine\'s only while it runs there')

const builtWithBest = build(
  { n: { recipe: 'n', kind: 'text', unit: 'inactive' }, q: { recipe: 'q', kind: 'text', unit: 'inactive' } },
  [],
  { 'box/n': { recipe: 'n', host: 'box', kind: 'text', unit: 'active', paired: true, offline: '' } },
  [{ id: 'n', best: true }, { id: 'q', best: false }]
)
assertDeepEqual(builtWithBest.map(line => [line.localModel.target, line.localModel.best]),
  [['n', true], ['q', false], ['box/n', false]],
  'local model lines carry best from this machine\'s catalog and never for a network model')

const offerRecommended = new Function(fn('offerRecommended') + '\nreturn offerRecommended')()
assertEqual(offerRecommended({ host: '', best: true }, 2), true, 'the best model gets the recommended pill when multiple local models are offered')
assertEqual(offerRecommended({ host: '', best: true }, 1), false, 'a single offered local model gets no recommended pill')
assertEqual(offerRecommended({ host: '', best: false }, 2), false, 'a non-best model gets no recommended pill')
assertEqual(offerRecommended({ host: 'spark', best: true }, 2), false, 'a network model never gets the recommended pill')
assertEqual(offerRecommended({ host: '', best: true, link: { state: 'available' } }, 2), false, 'a cabled Spark link offer never gets the recommended pill')

const sortLocalOffers = new Function(fn('sortLocalOffers') + '\nreturn sortLocalOffers')()
assertDeepEqual(
  sortLocalOffers([
    { target: 'qwen', best: false },
    { target: 'other', best: false },
    { target: 'nemotron', best: true }
  ]).map(o => o.target),
  ['nemotron', 'qwen', 'other'],
  'the recommended model sorts at the top even when another model is already installed'
)

const localMeter = new Function('Commons', 'nowMs', 'downloadRate', fn('phaseProgress') + fn('expectedLoadSeconds') + fn('expectedStopSeconds') + fn('localMeter') + '\nreturn localMeter')(
  { I18n: { t: key => key } },
  10000,
  rate => rate > 0 ? Math.round(rate / 1e6) + ' MB/s' : ''
)
assertDeepEqual(
  localMeter({ unit: 'installing', install: { phase: 'downloading', done_bytes: 20e9, total_bytes: 40e9, rate_bytes_s: 84e6 } }, false),
  { title: '', value: 0.5, rate: '84 MB/s', downloading: true },
  'a downloading model shows a titleless progress bar with speed and marks downloading'
)
assertEqual(
  localMeter({ unit: 'installing', install: { phase: 'dependencies' } }, false).downloading,
  undefined,
  'dependency installation keeps its titled meter'
)

const localActions = new Function(fn('localActions') + '\nreturn localActions')()
assertDeepEqual(localActions({ recipe: 'm', unit: 'active' }, true), ['share', 'toggle'], 'a running model can be shared and stopped')
assertDeepEqual(localActions({ recipe: 'm', unit: 'active' }, false), ['toggle'], 'without Tailscale set up, sharing is not offered')
assertDeepEqual(localActions({ recipe: 'm', unit: 'active', shared: true }, false), ['share', 'toggle'], 'a running shared model can always stop sharing')
assertDeepEqual(localActions({ recipe: 'm', unit: 'inactive', shared: true }, true), ['toggle'], 'a stopped model is not offered for sharing')
assertDeepEqual(localActions({ recipe: 'm', unit: 'installing' }, true), [], 'a model being set up offers nothing yet')
const stale = { image: true, weights: false, settings: false }
assertDeepEqual(localActions({ recipe: 'm', unit: 'active', update: stale }, true), ['update', 'share', 'toggle'], 'a model the catalog has moved on from offers its update')
assertDeepEqual(localActions({ recipe: 'm', unit: 'activating', update: stale }, true), ['toggle'], 'a model that is loading does not offer its update')
assertDeepEqual(localActions({ recipe: 'm', unit: 'inactive', update: stale, updating: true }, true), ['toggle'], 'a model being updated does not offer its update again')

const updateTip = new Function('Commons', fn('updateTip') + '\nreturn updateTip')({ I18n: { t: (key) => ({ arg: (value) => key + ' ' + value, toString: () => key }), formatNumber: (value, decimals) => value.toFixed(decimals) } })
assertEqual(String(updateTip({ update: Object.assign({ download_bytes: 601000000 }, stale) })), 'localModels.updateDownloadGb 0.6', 'an update says how much it downloads')
assertEqual(String(updateTip({ update: Object.assign({ download_bytes: 42000000 }, stale) })), 'localModels.updateDownloadMb 42', 'a small update is sized in megabytes')
assertEqual(String(updateTip({ update: Object.assign({ download_bytes: null }, stale) })), 'localModels.update', 'an update not sized yet names no size')

// Opening a failure's logs dismisses it once printed; a setup that failed
// before its download has only what it printed.
const showLocalLogs = new Function('Util', 'root', fn('showLocalLogs') + '\nreturn showLocalLogs')
const runs = []
const logs = showLocalLogs({ shellQuote: text => "'" + text + "'", execArgv: argv => runs.push(argv[1]) }, { close() {} })
logs({ recipe: 'm', unit: 'failed', error: 'Stopped unexpectedly' })
logs({ recipe: 'n', unit: 'installing', panelSetup: true, output: 'refused' })
assertDeepEqual(runs, ["omarchy-models logs 'm'; logs=$?; omarchy-models dismiss 'm' >/dev/null 2>&1; (exit $logs)", "printf %s 'refused'; false"],
  'a model\'s logs print its failure before it is dismissed, and a failed setup prints what it said')

// A start that runs long keeps creeping, and an update's bar runs one way:
// its turn, its download, then the old model stopping and the new one loading.
const progress = new Function(['phaseProgress', 'expectedLoadSeconds', 'expectedStopSeconds', 'updateProgress'].map(fn).join('\n') + '\nreturn { phaseProgress, updateProgress }')()
assertEqual(progress.phaseProgress(10, 10), 0.9, 'a start reaches 90% at the time the last one took')
assert(progress.phaseProgress(20, 10) > progress.phaseProgress(15, 10) && progress.phaseProgress(1000, 10) < 0.99, 'a start that runs long keeps creeping, never filling')
const now = 100000
const update = model => progress.updateProgress(Object.assign({ updating: true }, model), now - 5000, now)
const waiting = update({ unit: 'active', update_progress: { phase: 'waiting' } })
const half = update({ unit: 'active', update_progress: { phase: 'downloading', done_bytes: 5, total_bytes: 10 } })
const fetched = update({ unit: 'active', update_progress: { phase: 'downloading', done_bytes: 10, total_bytes: 10 } })
const stopping = update({ unit: 'deactivating', since_ms: now - 1000, expected_stop_seconds: 2 })
const loading = update({ unit: 'activating', since_ms: now - 30000, expected_load_seconds: 60 })
assert(waiting > 0 && waiting < half && half < fetched && fetched <= stopping && stopping < loading && loading < 1, 'an update fills one way through its phases', [waiting, half, fetched, stopping, loading])

// A model the memory free can't start is held back: one set up when the
// engine says so, a recipe when it needs more than is free.
const short = new Function('settingUpLocal', 'localModelsService', fn('localSettingUp') + fn('memoryShort') + '\nreturn memoryShort')('', { memoryFreeGib: 18 })
assertDeepEqual(short('q', 42, { unit: 'inactive', fits: false }), { needs: 42, free: 18 }, 'a stopped model the engine says won\'t fit is short')
assertEqual(short('q', 42, { unit: 'inactive', fits: true }), null, 'a stopped model the engine says fits can start')
assertEqual(short('q', 42, { unit: 'active', fits: false }), null, 'a running model is never short')
assertDeepEqual(short('r', 42, null), { needs: 42, free: 18 }, 'a recipe needing more than is free can\'t be set up')
assertEqual(short('r', 8, null), null, 'a recipe that fits can be set up')
assertEqual(short('r', 42, { unit: 'installing' }), null, 'one already being set up goes on')

// Up and Down land on a line's last stop, so a model that isn't running
// yet ends on Play, which Enter starts, rather than its mark.
const lineStop = (launches, actions) => new Function('providers', 'launches', 'localLineActions', fn('lineStop') + '\nreturn lineStop')([{}], () => launches, () => actions)(0)
assertEqual(lineStop(true, ['share', 'toggle']), 'providerLaunch', 'a running model lands on its terminal button')
assertEqual(lineStop(false, ['update', 'toggle']), 'localToggle', 'a stopped model lands on its play button')
assertEqual(lineStop(false, []), 'provider', 'a line with nothing to press lands on its mark')

// A coding model set up on this machine always gets a line on the panel,
// even when set up from the CLI and absent from local-models.json; paired
// machine models still wait to be added (unless pinned as the local default).
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const localModelAddedFn = mainSource.match(/function localModelAdded\([^]*?\n  \}/)[0]
const isAdded = (addedLocalModels, defaultAgent, localDefaultTarget) =>
  new Function('addedLocalModels', 'defaultAgent', 'localDefaultTarget', localModelAddedFn + '\nreturn localModelAdded')(
    addedLocalModels, defaultAgent, localDefaultTarget
  )
assertEqual(isAdded([], 'agy', '')({ localModel: { target: 'inkling-2-mini-tensorfold', host: '' } }), true,
  'a local model set up on this machine appears on the panel even when not in local-models.json')
assertEqual(isAdded([], 'agy', '')({ localModel: { target: 'spark/deepseek', host: 'spark' } }), false,
  'a paired machine model stays off the panel until added')
assertEqual(isAdded(['spark/deepseek'], 'agy', '')({ localModel: { target: 'spark/deepseek', host: 'spark' } }), true,
  'an added paired machine model appears on the panel')
assertEqual(isAdded([], 'local', 'spark/deepseek')({ localModel: { target: 'spark/deepseek', host: 'spark' } }), true,
  'the default paired machine model stays on the panel')

// A model being set up or handing off to status.json isn't dropped from the
// panel's added list even before status.json reloads with it.
const findRemoved = new Function(fn('findRemovedLocalModels') + '\nreturn findRemovedLocalModels')()
const uninst = [{ id: 'm', installed: false }, { id: 'n', installed: false }, { id: 'gone', installed: false }]
assertDeepEqual(
  findRemoved(['m', 'n', 'gone', 'spark/d'], {}, [], uninst, 'm', ['n']),
  ['gone'],
  'setups in progress or handing off stay added until status.json lists them, while uninstalled models drop'
)

// Adding a running network model returns to the panel index instead of
// closing the panel and launching a terminal.
const added = []
const execs = []
let closed = false, cancelled = false, focused = false, selectedDefault = ''
const chooseModel = new Function(
  'ownModelOffers', 'offerMeter', 'localModelState', 'localRunning', 'usage', 'selectLocalDefault',
  'settingUpLocal', 'pairingLocal', 'addStage', 'cancelAdd', 'root', 'Util',
  fn('chooseOwnModel') + '\nreturn chooseOwnModel'
)(
  [{ target: 'spark/deepseek', host: 'spark' }],
  () => null,
  () => null,
  () => true,
  { addedLocalModels: [], defaultAgent: 'codex', addLocalModel: t => added.push(t) },
  t => { selectedDefault = t },
  '', '', 'pick',
  () => { cancelled = true },
  { close: () => { closed = true }, focusKeys: () => { focused = true } },
  { execArgv: argv => execs.push(argv) }
)
chooseModel(0)
assertDeepEqual(added, ['spark/deepseek'], 'choosing a network model adds it to the panel')
assertEqual(cancelled, true, 'choosing a network model returns to the panel index')
assertEqual(closed, false, 'choosing a network model keeps the panel open')
assertDeepEqual(execs, [], 'choosing a network model does not launch a terminal')
assertEqual(selectedDefault, '', 'choosing a network model leaves an existing default agent alone')

// Pasting a sign-in code hides the field and switches to checking for both
// Claude and Gemini; a later re-prompt brings the field back.
const writes = []
let refocused = 0
const pasteState = {
  addProcess: { running: true, write: s => writes.push(s) },
  addNeedsPaste: true,
  addPasteHint: '',
  addKeyEntry: false,
  addCheckingCode: false,
  addStatus: '',
  addCode: '',
  addUrl: '',
  addDownloading: false,
  addPhase: 'signin',
  addFetched: false,
  addHeldStatus: '',
  addResult: '',
  addStage: 'running',
  addProvider: 'claude',
  addProviderEntry: null,
  addFetchTimer: { stop() {}, restart() {} },
  beginSignIn(s) { this.addStatus = s; this.addPhase = 'signin' },
  reopenSignIn() {},
  setProviderShown() {},
  usage: { refreshLimits() {}, enabledProviders: [{}] },
  checkProcess: { running: false },
  root: { focusKeys() { refocused++ } }
}
const submitPaste = new Function('with (this) { ' + fn('submitPaste') + '\nreturn submitPaste }').call(pasteState)
const handleAddLine = new Function('with (this) { ' + fn('handleAddLine') + '\nreturn handleAddLine }').call(pasteState)
submitPaste('secret-code')
assertDeepEqual(writes, ['secret-code\n'], 'submitting a code sends it to the login process')
assertEqual(pasteState.addNeedsPaste, false, 'submitting a Claude code hides the paste field like Gemini and API keys')
assertEqual(pasteState.addCheckingCode, true, 'submitting a code enters the checking state')
assertEqual(refocused, 1, 'submitting a code returns keyboard focus to the panel')
handleAddLine('Paste code here:')
assertEqual(pasteState.addNeedsPaste, true, 'a re-prompt brings the paste field back')
assertEqual(pasteState.addCheckingCode, false, 'a re-prompt leaves the checking state')

// On a blank-slate machine, starting a local model download keeps AddView up
// and must not also render a duplicate ProviderSection underneath it. Already-
// installed models stay on the index across loading, stopping, failure, and
// removal, as do added paired tailnet models.
const propExpr = name => {
  const m = source.match(new RegExp('readonly property bool ' + name + ': ([^\\n]+(?:\\n(?:    [^\\n]+|  \\}\\)))*)'))
  assert(m, 'agents panel defines ' + name)
  return m[1]
}
const addViewVisibleExpr = source.match(/AddView \{[\s\S]*?visible: ([^\n]+)/)[1]
const sectionsModelExpr = source.match(/id: providerSections[\s\S]*?model: ([^\n]+)/)[1]
const evalPanelState = new Function(
  'addStage', 'usage', 'anySignedIn', 'localModels', 'localModelLines', 'localModelState', 'settingUpLocal', 'providers',
  fn('localSettingUp') + '\n' +
  'const hasIndexLocalModel = ' + propExpr('hasIndexLocalModel') + '\n' +
  'const blankSlate = ' + propExpr('blankSlate') + '\n' +
  'const indexShown = ' + propExpr('indexShown') + '\n' +
  'const root = { addStage, blankSlate, indexShown, providers }\n' +
  'return { blankSlate, addVisible: (' + addViewVisibleExpr + '), sections: (' + sectionsModelExpr + ') }'
)
const evalPanelView = ({ addStage = '', enabledProviders = [], anySignedIn = false, localModels = {}, localModelLines = [], settingUpLocal = '', added = [], providers = [] }) => {
  const usage = {
    enabledProviders,
    localModelAdded: line => line.localModel.host === '' || added.includes(line.localModel.target)
  }
  const localModelState = local => local && local.host === '' ? (localModels[local.target] || null) : null
  return evalPanelState(addStage, usage, anySignedIn, localModels, localModelLines, localModelState, settingUpLocal, providers)
}
const inklingLine = { providerId: 'local', localModel: { target: 'inkling', host: '' } }
const downloadingView = evalPanelView({
  localModels: { inkling: { kind: 'text', unit: 'installing' } },
  localModelLines: [inklingLine],
  settingUpLocal: 'inkling',
  providers: [inklingLine]
})
assertEqual(downloadingView.blankSlate, true, 'downloading a first local model stays on the blank-slate picker')
assertEqual(downloadingView.addVisible, true, 'downloading a first local model keeps AddView visible')
assertDeepEqual(downloadingView.sections, [], 'downloading a first local model does not duplicate it in providerSections')

const firstLoadView = evalPanelView({
  localModels: { inkling: { kind: 'text', unit: 'activating' } },
  localModelLines: [inklingLine],
  settingUpLocal: 'inkling',
  providers: [inklingLine]
})
assertEqual(firstLoadView.blankSlate, true, 'first-time loading started from the picker stays on the blank-slate picker')
assertDeepEqual(firstLoadView.sections, [], 'first-time loading started from the picker does not duplicate in providerSections')

for (const [label, model] of [
  ['running', { kind: 'text', unit: 'active', sub_state: 'running' }],
  ['loading from index', { kind: 'text', unit: 'activating' }],
  ['stopping', { kind: 'text', unit: 'deactivating' }],
  ['stopped', { kind: 'text', unit: 'inactive' }],
  ['failed', { kind: 'text', unit: 'failed', error: 'Stopped unexpectedly' }],
  ['removing', { kind: 'text', unit: 'removing' }]
]) {
  const view = evalPanelView({
    localModels: { inkling: model },
    localModelLines: [inklingLine],
    providers: [inklingLine]
  })
  assertEqual(view.blankSlate, false, 'an installed model (' + label + ') stays on the panel index')
  assertEqual(view.addVisible, false, 'an installed model (' + label + ') hides AddView')
  assertDeepEqual(view.sections, [inklingLine], 'an installed model (' + label + ') keeps its section')
}

const pairedLine = { providerId: 'local', localModel: { target: 'spark/qwen', host: 'spark' } }
const pairedView = evalPanelView({
  localModelLines: [pairedLine],
  added: ['spark/qwen'],
  providers: [pairedLine]
})
assertEqual(pairedView.blankSlate, false, 'an added paired tailnet model leaves the blank-slate picker')
assertDeepEqual(pairedView.sections, [pairedLine], 'an added paired tailnet model shows in providerSections')
JS
