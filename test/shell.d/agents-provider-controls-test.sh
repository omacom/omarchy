#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command node

# The real updater must leave a disabled provider's preseeded usage record and
# the cache its collector would rewrite completely untouched.
TEST_HOME=$(mktemp -d)
FAKE_OMARCHY=$(mktemp -d)
qml_imports=""
agents_restore_fixture=""
cleanup_agents_provider_test() {
  rm -rf "$TEST_HOME" "$FAKE_OMARCHY" ${qml_imports:+"$qml_imports"} ${agents_restore_fixture:+"$agents_restore_fixture"}
}
trap cleanup_agents_provider_test EXIT

mkdir -p "$FAKE_OMARCHY/bin" "$TEST_HOME/.local/state/omarchy/agents/usage" "$TEST_HOME/.cache/omarchy/agent-usage"
usage_dir="$TEST_HOME/.local/state/omarchy/agents/usage"
cache_dir="$TEST_HOME/.cache/omarchy/agent-usage"
printf '%s\n' '{"id":"kept","marker":"preseeded"}' >"$usage_dir/kept.json"
printf '%s\n' 'preseeded-cache' >"$cache_dir/kept.json"
preseeded_usage=$(sha256sum "$usage_dir/kept.json")
preseeded_cache=$(sha256sum "$cache_dir/kept.json")

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-kept" <<EOF
#!/bin/bash
printf '%s\n' 'collector-ran' >"$cache_dir/kept.json"
echo '{"id":"kept","marker":"replaced"}'
EOF

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-other" <<'EOF'
#!/bin/bash
echo '{"id":"other","name":"Other","totalPrompts":1}'
EOF

chmod +x "$FAKE_OMARCHY/bin/"omarchy-agent-usage-*

OMARCHY_PATH="$FAKE_OMARCHY" \
  XDG_STATE_HOME="$TEST_HOME/.local/state" \
  XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-update" --except kept ||
  fail "update can exclude a provider while another collector runs"
pass "update can exclude a provider while another collector runs"

[[ $(sha256sum "$usage_dir/kept.json") == "$preseeded_usage" ]] ||
  fail "update leaves a preseeded usage record for an excluded provider"
pass "update leaves a preseeded usage record for an excluded provider"

[[ $(sha256sum "$cache_dir/kept.json") == "$preseeded_cache" ]] ||
  fail "update leaves a preseeded collector cache for an excluded provider"
pass "update leaves a preseeded collector cache for an excluded provider"

[[ $(jq -r '.id' "$usage_dir/other.json") == "other" ]] ||
  fail "update still writes a provider that was not excluded"
pass "update still writes a provider that was not excluded"

OMARCHY_PATH="$FAKE_OMARCHY" \
  XDG_STATE_HOME="$TEST_HOME/.local/state" \
  XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-update" kept ||
  fail "the excluded provider's collector runs when it is requested"
pass "the excluded provider's collector runs when it is requested"

[[ $(jq -r '.marker' "$usage_dir/kept.json") == "replaced" && $(<"$cache_dir/kept.json") == "collector-ran" ]] ||
  fail "requesting that provider rewrites its usage record and cache"
pass "requesting that provider rewrites its usage record and cache"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

function scanBlock(source, openIndex) {
  let depth = 0
  let quote = ''
  let escaped = false
  let lineComment = false
  let blockComment = false
  for (let i = openIndex; i < source.length; i++) {
    const c = source[i]
    const n = source[i + 1]
    if (lineComment) {
      if (c === '\n') lineComment = false
      continue
    }
    if (blockComment) {
      if (c === '*' && n === '/') {
        blockComment = false
        i++
      }
      continue
    }
    if (quote) {
      if (escaped) {
        escaped = false
        continue
      }
      if (c === '\\') {
        escaped = true
        continue
      }
      if (c === quote) quote = ''
      continue
    }
    if (c === '/' && n === '/') {
      lineComment = true
      i++
      continue
    }
    if (c === '/' && n === '*') {
      blockComment = true
      i++
      continue
    }
    if (c === '"' || c === "'" || c === '`') {
      quote = c
      continue
    }
    if (c === '{') depth++
    if (c === '}' && --depth === 0) return { end: i, interior: source.slice(openIndex + 1, i) }
  }
  return null
}

function extractFunction(source, name) {
  const marker = `function ${name}(`
  const start = source.indexOf(marker)
  assert(start >= 0, `found function ${name}`)
  const open = source.indexOf('{', start)
  const block = scanBlock(source, open)
  if (!block) fail(`unbalanced function ${name}`)
  return source.slice(start, block.end + 1)
}

function extractProperty(source, name) {
  const match = new RegExp(`(?:readonly\\s+)?property\\s+[A-Za-z0-9_.]+\\s+${name}\\s*:`).exec(source)
  assert(match, `found property ${name}`)
  let i = match.index + match[0].length
  while (i < source.length && /\s/.test(source[i])) i++
  if (source[i] === '{') {
    const block = scanBlock(source, i)
    if (!block) fail(`unbalanced property ${name}`)
    return { kind: 'block', code: block.interior }
  }
  const end = source.indexOf('\n', i)
  return { kind: 'expr', code: source.slice(i, end === -1 ? source.length : end).trim() }
}

function extractHandler(source, name) {
  const marker = `${name}:`
  const start = source.indexOf(marker)
  assert(start >= 0, `found ${name}`)
  let i = start + marker.length
  while (i < source.length && /\s/.test(source[i])) i++
  assert(source[i] === '{', `${name} has a block body`)
  const block = scanBlock(source, i)
  if (!block) fail(`unbalanced ${name}`)
  return block.interior
}

function extractChildBinding(source, label, prop) {
  const at = source.indexOf(label)
  assert(at >= 0, `found ${label}`)
  const open = source.indexOf('{', at)
  const block = scanBlock(source, open)
  if (!block) fail(`unbalanced ${label}`)
  const match = new RegExp(`(?:^|\\n)\\s*${prop}\\s*:`).exec(block.interior)
  assert(match, `found ${prop} in ${label}`)
  let i = match.index + match[0].length
  while (i < block.interior.length && /\s/.test(block.interior[i])) i++
  const end = block.interior.indexOf('\n', i)
  return block.interior.slice(i, end === -1 ? block.interior.length : end).trim()
}

const utilSource = fs.readFileSync(root + '/shell/Commons/Util.qml', 'utf8')
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

assertEqual((panelSource.match(/trailingControl:/g) || []).length, 1, 'the agents panel has one trailingControl binding')
assert(mainSource.includes('injectProps assigns bar, moduleName, and'), 'startup comment names the synchronous bar, moduleName, and settings assignment')
assert(mainSource.includes('Qt.callLater assigns them'), 'startup comment names the Qt.callLater assignment')
assert(!mainSource.includes('a tick after'), 'startup comment does not invent a tick of delay')
assert(mainSource.includes('interval: root.nearLimit ? Math.min(180, root.refreshIntervalSec) * 1000 : root.refreshIntervalSec * 1000'), 'the near-limit refresh interval is unchanged')
assert(mainSource.includes('running: root.settingsReady || root.readyDeadlinePassed'), 'startup collection waits for settings, with the no-bar fallback')
assert(mainSource.includes('onTriggered: root.runUpdate(root.nearLimit ? "limits" : "normal")'), 'the near-limit timer still chooses limits or a normal refresh')

const writerSource = [
  extractFunction(utilSource, 'canonicalWidgetId'),
  extractFunction(utilSource, 'isPlainObject'),
  'var Util = { canonicalWidgetId: canonicalWidgetId, isPlainObject: isPlainObject }',
  extractFunction(shellSource, 'updateEntryInline'),
].join('\n')

function load(ctx, source) {
  if (!vm.isContext(ctx)) vm.createContext(ctx)
  vm.runInContext(source, ctx)
  return ctx
}

const saved = []
const writer = load({
  shellConfig: {
    bar: {
      layout: {
        left: ['omarchy.clock', 'omarchy.agents', { id: 'omarchy.weather', city: 'Oslo' }],
        center: [],
        right: [{ id: 'omarchy.agents', refreshIntervalSec: 30, providers: { claude: { enabled: true } } }],
      },
    },
    plugins: ['omarchy.agents'],
  },
  builtinShellConfig: {},
  persistShellConfig(copy) { saved.push(copy) },
}, writerSource)

const incoming = { id: 'ignored', refreshIntervalSec: 30, providers: { claude: { enabled: false, extra: 'kept' }, codex: { enabled: true } } }
assertEqual(writer.updateEntryInline('omarchy.agents', incoming), true, 'a string layout entry is promoted and written')
assertEqual(saved.length, 1, 'the writer persists once for that change')
const left = saved[0].bar.layout.left
const right = saved[0].bar.layout.right
assertEqual(left[0], 'omarchy.clock', 'an unrelated string entry stays a string in its place')
assertDeepEqual(left[1], { id: 'omarchy.agents', refreshIntervalSec: 30, providers: incoming.providers }, 'the matching string becomes an object with its id and settings')
assertDeepEqual(left[2], { id: 'omarchy.weather', city: 'Oslo' }, 'an unrelated object entry is left alone')
assertDeepEqual(right[0], left[1], 'an existing matching object in another section gets the same update')
assertEqual(saved[0].plugins[0], 'omarchy.agents', 'a plugin entry is left alone when the bar layout already matched')

writer.shellConfig = saved[0]
assertEqual(writer.updateEntryInline('omarchy.agents', incoming), false, 'writing the same object again changes nothing')
assertEqual(saved.length, 1, 'a no-op object update does not persist')

const pluginSaved = []
const pluginWriter = load({
  shellConfig: { bar: { layout: { left: ['omarchy.clock'], center: [], right: [] } }, plugins: ['omarchy.agents'] },
  builtinShellConfig: {},
  persistShellConfig(copy) { pluginSaved.push(copy) },
}, writerSource)
assertEqual(pluginWriter.updateEntryInline('omarchy.agents', { providers: { claude: { enabled: false } } }), true, 'a string plugin entry is promoted when the layout has no match')
assertDeepEqual(pluginSaved[0].plugins[0], { id: 'omarchy.agents', providers: { claude: { enabled: false } } }, 'the promoted plugin entry keeps its id and settings')
assertEqual(pluginSaved[0].bar.layout.left[0], 'omarchy.clock', 'promoting a plugin entry does not touch the bar')

const realQueueSource = [
  extractFunction(mainSource, 'updateRank'),
  extractFunction(mainSource, 'unionIds'),
  extractFunction(mainSource, 'enqueueUpdate'),
  extractFunction(mainSource, 'startPendingUpdate'),
  extractFunction(mainSource, 'updateCommand'),
  extractFunction(mainSource, 'runUpdate'),
  extractFunction(mainSource, 'refreshProviderIds'),
].join('\n')

function freshQueue() {
  const ctx = {
    settings: { providers: { fireworks: { enabled: false, note: 'leave' }, claude: { enabled: true } } },
    updateProcess: { running: false, command: [] },
    pendingUpdateKind: '',
    pendingAgentIds: [],
    pendingAllProviders: false,
    agents: [],
    agentIds: [],
    aggregateData: {},
    providerOrder: [],
    providerIds: [],
    syncConfigured() { return false },
  }
  ctx.root = ctx
  return load(ctx, realQueueSource)
}

function queueWhileBusy(ctx, calls) {
  ctx.updateProcess.running = true
  for (const call of calls) ctx.runUpdate(call[0], call[1])
}

function replay(ctx) {
  ctx.updateProcess.running = false
  ctx.startPendingUpdate()
  return ctx.updateProcess.command.slice()
}

const limitsThenEnables = freshQueue()
queueWhileBusy(limitsThenEnables, [['limits'], ['normal', ['claude']], ['normal', ['codex']]])
assertEqual(limitsThenEnables.pendingUpdateKind, 'normal', 'normal work outranks a queued limits-only run')
assertEqual(limitsThenEnables.pendingAllProviders, true, 'a queued refresh of every provider does not shrink to the enabled ids')
assertDeepEqual(replay(limitsThenEnables), ['omarchy-agent-usage-update', '--except', 'fireworks'], 'replaying that queue is a normal refresh that still excludes a disabled provider')

const unioned = freshQueue()
queueWhileBusy(unioned, [['normal', ['claude']], ['normal', ['codex']]])
assertEqual(unioned.pendingUpdateKind, 'normal', 'queued enables stay a normal refresh')
assertEqual(unioned.pendingAllProviders, false, 'queued enables stay targeted')
assertDeepEqual(unioned.pendingAgentIds, ['claude', 'codex'], 'enables requested while a collector is busy are unioned')
assertDeepEqual(replay(unioned), ['omarchy-agent-usage-update', '--except', 'fireworks', 'claude', 'codex'], 'the replay keeps those ids and the disabled-provider exclusion')

const alreadyFull = freshQueue()
queueWhileBusy(alreadyFull, [['normal'], ['normal', ['claude']]])
assertEqual(alreadyFull.pendingAllProviders, true, 'a targeted enable cannot shrink an already queued full refresh')
assertDeepEqual(alreadyFull.pendingAgentIds, [], 'the queued full refresh does not keep a narrower id list')

const forceWins = freshQueue()
queueWhileBusy(forceWins, [['normal', ['claude']], ['force']])
assertEqual(forceWins.pendingUpdateKind, 'force', 'a forced refresh outranks a queued normal refresh')
assertEqual(forceWins.pendingAllProviders, true, 'a forced refresh of every provider stays untargeted')
assertDeepEqual(replay(forceWins), ['omarchy-agent-usage-update', '--force', '--except', 'fireworks'], 'the replay keeps the force flag')

const forceStays = freshQueue()
queueWhileBusy(forceStays, [['force'], ['limits', ['claude']]])
assertEqual(forceStays.pendingUpdateKind, 'force', 'limits-only work does not outrank a queued forced refresh')
assertEqual(forceStays.pendingAllProviders, true, 'a targeted limits retry does not shrink a queued forced refresh')

const targetedUpgrade = freshQueue()
queueWhileBusy(targetedUpgrade, [['limits', ['claude']], ['normal', ['codex']]])
assertEqual(targetedUpgrade.pendingUpdateKind, 'normal', 'a targeted normal refresh outranks a targeted limits refresh')
assertDeepEqual(targetedUpgrade.pendingAgentIds, ['claude', 'codex'], 'upgrading the kind keeps the queued provider ids')
assertDeepEqual(replay(targetedUpgrade), ['omarchy-agent-usage-update', '--except', 'fireworks', 'claude', 'codex'], 'that replay is normal, targeted, and still excludes the disabled provider')

const idle = freshQueue()
idle.runUpdate('limits', ['claude'])
assertEqual(idle.pendingUpdateKind, '', 'a collector that is free runs immediately instead of queueing')
assertDeepEqual(idle.updateProcess.command, ['omarchy-agent-usage-update', '--limits-only', '--except', 'fireworks', 'claude'], 'an immediate limits run keeps its id and the disabled-provider exclusion')

const ordered = freshQueue()
ordered.providerOrder = ['codex', 'claude']
ordered.agents = [
  { record: { id: 'claude', name: 'Claude' } },
  { record: { id: 'codex', name: 'Codex' } },
]
ordered.settings = { providers: { grok: { enabled: false }, fireworks: { enabled: false, note: 'leave' } } }
ordered.refreshProviderIds()
const firstIds = ordered.providerIds
assertDeepEqual(firstIds, ['codex', 'claude', 'fireworks', 'grok'], 'provider switches follow the saved order, then unnamed ids')
ordered.refreshProviderIds()
assert(ordered.providerIds === firstIds, 'an unchanged provider id list keeps the same array')
ordered.providerOrder = ['grok', 'codex']
ordered.refreshProviderIds()
assertDeepEqual(ordered.providerIds, ['grok', 'codex', 'claude', 'fireworks'], 'a new saved order reassigns the switch list')

const panelFn = [
  'function shellQuote(value) { return "\'" + String(value || "") + "\'" }',
  'var Util = { shellQuote: shellQuote }',
  extractFunction(panelSource, 'setProviderEnabled'),
].join('\n')

function panelContext(settings, writer) {
  const calls = []
  const notes = []
  const ctx = {
    usage: { runUpdate(...args) { calls.push(args) } },
    calls,
    notes,
    root: {
      moduleName: 'omarchy.agents',
      settings,
      bar: {
        shell: { updateEntryInline: writer },
        run(command) { notes.push(command) },
      },
    },
  }
  ctx.root.root = ctx.root
  Object.defineProperty(ctx, 'settings', {
    get() { return ctx.root.settings },
    set(value) { ctx.root.settings = value },
  })
  // setProviderEnabled assigns root.settings and reads bare settings, root, usage, and Util.
  ctx.usage = ctx.usage
  load(ctx, panelFn)
  ctx.calls = calls
  ctx.notes = notes
  return ctx
}

const original = {
  refreshIntervalSec: 30,
  providers: {
    claude: { enabled: false, extra: 'preserved' },
    codex: { enabled: false, note: 'leave' },
  },
}
let writerCalls = 0
const enabled = panelContext(original, () => { writerCalls++; return true })
enabled.setProviderEnabled('claude', true)
assertEqual(writerCalls, 1, 'turning a provider on writes the merged settings')
assertEqual(enabled.root.settings.refreshIntervalSec, 30, 'unrelated widget settings stay on the entry')
assertEqual(enabled.root.settings.providers.claude.enabled, true, 'the re-enabled provider is on')
assertEqual(enabled.root.settings.providers.claude.extra, 'preserved', 'extra keys on that provider stay')
assertEqual(enabled.root.settings.providers.codex.enabled, false, 'another provider is left off')
assertEqual(enabled.root.settings.providers.codex.note, 'leave', 'another provider keeps its own settings')
assertDeepEqual(enabled.calls, [['normal', ['claude']]], 'a successful re-enable requests a normal refresh of that provider')

enabled.setProviderEnabled('codex', false)
assertEqual(writerCalls, 1, 'a no-op toggle does not write')
assertDeepEqual(enabled.calls, [['normal', ['claude']]], 'a no-op toggle does not collect')

const alreadyOn = panelContext({ providers: {} }, () => true)
alreadyOn.setProviderEnabled('claude', true)
assertDeepEqual(alreadyOn.calls, [], 'enabling a provider that is already on does not write or collect')

const refusedSettings = {
  refreshIntervalSec: 30,
  providers: { claude: { enabled: false, extra: 'preserved' }, codex: { enabled: true } },
}
const refused = panelContext(refusedSettings, () => false)
refused.setProviderEnabled('claude', true)
assert(refused.root.settings === refusedSettings, 'a refused write puts the previous settings back')
assertEqual(refused.root.settings.providers.claude.enabled, false, 'the refused toggle is rolled back')
assertEqual(refused.notes.length, 1, 'a refused write notifies')
assertDeepEqual(refused.calls, [], 'a refused write does not collect')

const missing = panelContext(refusedSettings, undefined)
missing.root.bar.shell.updateEntryInline = undefined
missing.setProviderEnabled('claude', true)
assert(missing.root.settings === refusedSettings, 'a missing writer puts the previous settings back')
assertDeepEqual(missing.calls, [], 'a missing writer does not collect')

const turnedOff = panelContext({
  providers: { claude: { enabled: true, extra: 'preserved' } },
}, () => true)
turnedOff.setProviderEnabled('claude', false)
assertEqual(turnedOff.root.settings.providers.claude.enabled, false, 'turning a provider off records that')
assertEqual(turnedOff.root.settings.providers.claude.extra, 'preserved', 'turning a provider off keeps its extra keys')
assertDeepEqual(turnedOff.calls, [], 'turning a provider off does not start a collector')

assert(panelSource.includes('visible: (root.addStage !== "" || root.blankSlate) && !root.settingsOpen'), 'the picker stays hidden while settings are open')
assert(panelSource.includes('onClicked: adding ? root.cancelAdd() : root.addAccount()'), 'the hero add control still adds, or goes back')
assert(panelSource.includes('visible: root.addStage === ""'), 'the launch control stays on the normal header')
assert(panelSource.includes('visible: root.addStage === "" || root.settingsOpen'), 'the providers control stays on the normal header and in settings')
assert(panelSource.includes('Qt.callLater(function() { if (picking) pointAt("choice", 0) })'), 'picking selects the first account once the rows exist')
assert(panelSource.includes('onCloseRequested: root.requestClose()'), 'escape still uses the panel close policy')

const addSource = [
  extractFunction(panelSource, 'pointAt'),
  extractFunction(panelSource, 'resetKeys'),
  extractFunction(panelSource, 'closeSettings'),
  extractFunction(panelSource, 'cancelAdd'),
  extractFunction(panelSource, 'addAccount'),
  extractFunction(panelSource, 'requestClose'),
].join('\n')

function bindExtracted(ctx, name, extracted) {
  const fn = extracted.kind === 'block'
    ? vm.runInContext(`(function() {\n${extracted.code}\n})`, ctx)
    : vm.runInContext(`(function() { return (${extracted.code}); })`, ctx)
  Object.defineProperty(ctx, name, {
    configurable: true,
    enumerable: true,
    get() { return fn() },
  })
}

function installAddAccessors(ctx) {
  let addStageValue = ''
  let settingsOpenValue = false
  vm.createContext(ctx)
  const onAddStageChanged = vm.runInContext(`(function() {\n${extractHandler(panelSource, 'onAddStageChanged')}\n})`, ctx)
  Object.defineProperty(ctx, 'addStage', {
    configurable: true,
    enumerable: true,
    get() { return addStageValue },
    set(value) {
      if (value === addStageValue) return
      addStageValue = value
      onAddStageChanged()
    },
  })
  Object.defineProperty(ctx, 'settingsOpen', {
    configurable: true,
    enumerable: true,
    get() { return settingsOpenValue },
    set(value) { settingsOpenValue = !!value },
  })
  bindExtracted(ctx, 'picking', extractProperty(panelSource, 'picking'))
  bindExtracted(ctx, 'addButtonShown', extractProperty(panelSource, 'addButtonShown'))
  bindExtracted(ctx, 'keyRows', extractProperty(panelSource, 'keyRows'))
  bindExtracted(ctx, 'keyTarget', extractProperty(panelSource, 'keyTarget'))
}

function flushLater(ctx) {
  const queued = ctx.later.splice(0, ctx.later.length)
  for (const fn of queued) fn()
}

function selection(ctx) {
  return ctx.keyTarget
}

const pickerVisible = vm.runInNewContext(
  `(function(root) { return (${extractChildBinding(panelSource, 'AddView {', 'visible')}); })`
)

function loadAddPanel(initial) {
  const later = []
  const ctx = {
    blankSlate: false,
    addChecks: { claude: 'signed-in' },
    checkProcess: { running: false },
    panelFlick: { contentY: 0 },
    addProviders: [
      { providerId: 'claude', providerName: 'Claude Code' },
      { providerId: 'codex', providerName: 'Codex' },
      { providerId: 'grok', providerName: 'Grok' },
    ],
    usage: { providerIds: ['claude', 'codex'] },
    providers: initial.providers || [{ providerId: 'claude' }],
    cursorActive: false,
    keyRow: 0,
    keyColumn: 0,
    addProcess: { running: false, signal(sig) { ctx.signaled = sig } },
    later,
    reveals: [],
    closed: false,
    focused: false,
    phraseStops: 0,
    starterPrompts: [],
    Qt: { callLater(fn) { later.push(fn) } },
    root: {},
  }
  ctx.phraseSwap = { stop() { ctx.phraseStops += 1 } }
  ctx.hero = { metaOpacity: 0 }
  ctx.providerAccounts = () => []
  ctx.needsSignIn = () => false
  ctx.root.revealSettingsRow = () => { ctx.reveals.push(ctx.keyRow) }
  ctx.root.focusKeys = () => { ctx.focused = true }
  ctx.root.close = () => { ctx.closed = true }
  installAddAccessors(ctx)
  ctx.settingsOpen = !!initial.settingsOpen
  load(ctx, addSource)
  if (initial.addStage) ctx.addStage = initial.addStage
  flushLater(ctx)
  ctx.cursorActive = initial.cursorActive ?? ctx.cursorActive
  ctx.keyRow = initial.keyRow ?? ctx.keyRow
  ctx.keyColumn = initial.keyColumn ?? ctx.keyColumn
  ctx.panelFlick.contentY = initial.contentY ?? 0
  ctx.later.length = 0
  ctx.reveals.length = 0
  ctx.closed = false
  ctx.focused = false
  return ctx
}

const fromSettings = loadAddPanel({ settingsOpen: true, contentY: 80, keyRow: 1, cursorActive: true })
assert(!pickerVisible(fromSettings), 'the picker is not exposed while settings are open')
fromSettings.addAccount()
flushLater(fromSettings)
assertEqual(fromSettings.settingsOpen, false, 'plus from settings leaves settings')
assertEqual(fromSettings.addStage, 'pick', 'plus from settings opens the picker')
assertEqual(fromSettings.panelFlick.contentY, 0, 'plus from settings scrolls back to the top')
assert(pickerVisible(fromSettings), 'plus from settings exposes the picker')
assertEqual(fromSettings.hero.metaOpacity, 1, 'plus from settings runs the add-stage handler')
assertEqual(fromSettings.phraseStops, 1, 'plus from settings stops the rotating phrase')
assertEqual(fromSettings.checkProcess.running, true, 'plus from settings checks which accounts can be added')
assertDeepEqual(fromSettings.addChecks, {}, 'plus from settings clears the previous account checks')
assertDeepEqual(selection(fromSettings), { kind: 'choice', index: 0 }, 'plus from settings selects the first account')
assertEqual(fromSettings.addButtonShown, true, 'the hero add control stays available from settings')
assertEqual(fromSettings.keyRows[0].length, 1, 'the picker header keeps the add control and drops launch and providers')
assertEqual(fromSettings.keyRows[0][0].kind, 'add', 'the picker header control is still the add button')
fromSettings.cancelAdd()
flushLater(fromSettings)
assertEqual(fromSettings.addStage, '', 'back from the picker returns to the limits')
assertEqual(fromSettings.settingsOpen, false, 'back from the picker does not reopen settings')
assertEqual(fromSettings.focused, true, 'back from the picker returns focus to the panel')

const escaped = loadAddPanel({ settingsOpen: true, contentY: 80 })
escaped.addAccount()
flushLater(escaped)
escaped.requestClose()
flushLater(escaped)
assertEqual(escaped.addStage, '', 'escape from the picker cancels adding')
assertEqual(escaped.settingsOpen, false, 'escape from the picker does not reopen settings')
assertEqual(escaped.closed, false, 'escape from the picker does not close the panel')

const settingsEscape = loadAddPanel({ settingsOpen: true, contentY: 30, providers: [{ providerId: 'claude' }] })
settingsEscape.requestClose()
flushLater(settingsEscape)
assertEqual(settingsEscape.settingsOpen, false, 'escape from provider switches returns to the dashboard')
assertEqual(settingsEscape.addStage, '', 'escape from provider switches does not start adding')
assertEqual(settingsEscape.closed, false, 'escape from provider switches does not close the panel')
assertEqual(settingsEscape.panelFlick.contentY, 0, 'escape from provider switches scrolls back to the top')

const noneLeft = loadAddPanel({ settingsOpen: true, providers: [] })
noneLeft.requestClose()
flushLater(noneLeft)
assertEqual(noneLeft.closed, true, 'escape closes the panel when every provider is off')
assertEqual(noneLeft.settingsOpen, true, 'that close is the panel close, not the dashboard return')
assertEqual(noneLeft.addStage, '', 'closing the all-off panel does not start adding')

const normalAdd = loadAddPanel({ settingsOpen: false, contentY: 40 })
normalAdd.addAccount()
flushLater(normalAdd)
assertEqual(normalAdd.settingsOpen, false, 'plus on the dashboard stays out of settings')
assertEqual(normalAdd.addStage, 'pick', 'plus on the dashboard opens the picker')
assertEqual(normalAdd.panelFlick.contentY, 40, 'plus on the dashboard does not jump the scroll')
assert(pickerVisible(normalAdd), 'plus on the dashboard exposes the picker')
assertDeepEqual(selection(normalAdd), { kind: 'choice', index: 0 }, 'plus on the dashboard selects the first account')

const signingIn = loadAddPanel({
  settingsOpen: true,
  addStage: 'running',
  contentY: 25,
  keyRow: 1,
  cursorActive: true,
})
signingIn.addChecks = { claude: 'keep' }
signingIn.checkProcess.running = true
signingIn.addAccount()
flushLater(signingIn)
assertEqual(signingIn.addStage, 'running', 'a sign-in in progress ignores another add')
assertEqual(signingIn.settingsOpen, true, 'a sign-in in progress does not leave its page')
assertEqual(signingIn.panelFlick.contentY, 25, 'a sign-in in progress does not jump the scroll')
assertEqual(signingIn.addChecks.claude, 'keep', 'a sign-in in progress keeps its checks')
assertEqual(signingIn.keyRow, 1, 'a sign-in in progress keeps the keyboard row')
assertEqual(signingIn.checkProcess.running, true, 'a sign-in in progress does not restart the account check')
JS

# The acceptance cleanup is what the VM runs. Exercise that function here, on
# absent and present trees, from a success call and from the failure trap.
agents_restore_fixture=$(mktemp -d)
(
  set -euo pipefail
  expected_home=$HOME
  export XDG_CONFIG_HOME="$agents_restore_fixture/config"
  export XDG_STATE_HOME="$agents_restore_fixture/state"
  export XDG_CACHE_HOME="$agents_restore_fixture/cache"
  export AGENTS_PROVIDER_COLLECTOR_WAIT=8
  # shellcheck disable=SC1091
  source "$ROOT/test/acceptance.d/agents-providers-test.sh"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"

  omarchy-shell() { printf '%s\n' "$*" >>"$agents_restore_fixture/hide.log"; }

  start_late_collector() {
    local bin="$agents_restore_fixture/bin"
    mkdir -p "$bin"
    cat >"$bin/omarchy-agent-usage-late" <<EOF
#!/bin/bash
sleep 0.7
mkdir -p "$agents_provider_usage_dir" "$agents_provider_cache_dir"
printf '%s\n' late-usage >"$agents_provider_usage_dir/late.json"
printf '%s\n' late-cache >"$agents_provider_cache_dir/late.json"
EOF
    chmod +x "$bin/omarchy-agent-usage-late"
    "$bin/omarchy-agent-usage-late" >/dev/null 2>&1 &
  }

  : >"$agents_restore_fixture/hide.log"
  prepare_agents_settings_restore
  [[ $agents_provider_shell_existed == 0 && $agents_provider_usage_existed == 0 && $agents_provider_cache_existed == 0 ]] ||
    fail "cleanup records settings, usage, and cache as absent"
  mkdir -p "$agents_provider_usage_dir" "$agents_provider_cache_dir" "$(dirname "$agents_provider_shell_json")"
  printf '%s\n' dirty-usage >"$agents_provider_usage_dir/dirty.json"
  printf '%s\n' dirty-cache >"$agents_provider_cache_dir/dirty.json"
  printf '%s\n' '{"dirty":true}' >"$agents_provider_shell_json"
  start_late_collector
  restore_agents_settings
  [[ ! -e $agents_provider_shell_json && ! -e $agents_provider_usage_dir && ! -e $agents_provider_cache_dir ]] ||
    fail "cleanup removes settings, usage, and cache that did not exist"
  sleep 0.9
  [[ ! -e $agents_provider_usage_dir && ! -e $agents_provider_cache_dir ]] ||
    fail "cleanup waits out a collector before removing absent directories"
  [[ $(grep -cx 'shell hide omarchy.agents' "$agents_restore_fixture/hide.log") == 1 ]] ||
    fail "cleanup hides the agents panel before restoring"
  pass "cleanup removes settings, usage, and cache after a successful run"

  mkdir -p "$agents_provider_usage_dir/nested" "$agents_provider_cache_dir" "$(dirname "$agents_provider_shell_json")"
  printf '%s\n' original-usage >"$agents_provider_usage_dir/nested/kept.json"
  printf '%s\n' original-cache >"$agents_provider_cache_dir/kept.json"
  printf '%s\n' '{"ok":true}' >"$agents_provider_shell_json"
  : >"$agents_restore_fixture/hide.log"
  rm -f "$agents_restore_fixture/failure-reason"
  if (
    set -euo pipefail
    prepare_agents_settings_restore
    trap restore_agents_settings EXIT
    if [[ $agents_provider_shell_existed != 1 || $agents_provider_usage_existed != 1 || $agents_provider_cache_existed != 1 ]]; then
      printf '%s\n' 'flags-wrong' >"$agents_restore_fixture/failure-reason"
      exit 1
    fi
    printf '%s\n' dirty-usage >"$agents_provider_usage_dir/nested/kept.json"
    printf '%s\n' extra-usage >"$agents_provider_usage_dir/extra.json"
    rm -f "$agents_provider_cache_dir/kept.json"
    printf '%s\n' extra-cache >"$agents_provider_cache_dir/extra.json"
    printf '%s\n' '{"dirty":true}' >"$agents_provider_shell_json"
    start_late_collector
    false
  ); then
    fail "the failure-path cleanup fixture exits non-zero"
  fi
  [[ ! -e $agents_restore_fixture/failure-reason ]] ||
    fail "cleanup records settings, usage, and cache as present"
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == original-usage && ! -e $agents_provider_usage_dir/extra.json ]] ||
    fail "cleanup after a failed run restores the usage directory"
  [[ $(<"$agents_provider_cache_dir/kept.json") == original-cache && ! -e $agents_provider_cache_dir/extra.json ]] ||
    fail "cleanup after a failed run restores the collector cache"
  [[ $(<"$agents_provider_shell_json") == '{"ok":true}' ]] ||
    fail "cleanup after a failed run restores shell settings"
  sleep 0.9
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == original-usage && ! -e $agents_provider_usage_dir/late.json ]] ||
    fail "cleanup waits out a collector before restoring usage"
  [[ $(<"$agents_provider_cache_dir/kept.json") == original-cache && ! -e $agents_provider_cache_dir/late.json ]] ||
    fail "cleanup waits out a collector before restoring the cache"
  [[ $(grep -cx 'shell hide omarchy.agents' "$agents_restore_fixture/hide.log") == 1 ]] ||
    fail "cleanup after a failed run hides the agents panel"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  pass "cleanup restores settings, usage, and cache after a failed run"
)

# Deadline expiry is a failed cleanup. The probe is the collector-liveness
# seam the real wait, prepare, and restore functions call. A bound long enough
# for two quiet polls must still fail while the probe says a collector is
# running, which an idle process table would not. Nothing here signals a peer.
rm -rf "$agents_restore_fixture"
agents_restore_fixture=$(mktemp -d)
(
  set -euo pipefail
  expected_home=$HOME
  export XDG_CONFIG_HOME="$agents_restore_fixture/config"
  export XDG_STATE_HOME="$agents_restore_fixture/state"
  export XDG_CACHE_HOME="$agents_restore_fixture/cache"
  # shellcheck disable=SC1091
  source "$ROOT/test/acceptance.d/agents-providers-test.sh"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"

  omarchy-shell() { printf '%s\n' "$*" >>"$agents_restore_fixture/hide.log"; }
  : >"$agents_restore_fixture/hide.log"

  cat >"$agents_restore_fixture/collector-probe" <<EOF
#!/bin/bash
[[ \$(<"$agents_restore_fixture/collector-state") == running ]]
EOF
  chmod +x "$agents_restore_fixture/collector-probe"
  export AGENTS_PROVIDER_COLLECTOR_PROBE="$agents_restore_fixture/collector-probe"
  printf '%s\n' running >"$agents_restore_fixture/collector-state"

  export AGENTS_PROVIDER_COLLECTOR_WAIT=0
  wait_err="$agents_restore_fixture/wait.err"
  wait_exit=0
  agents_provider_wait_for_collectors 2>"$wait_err" || wait_exit=$?
  [[ $wait_exit -ne 0 ]] ||
    fail "collector wait fails when the deadline expires while collectors are running"
  grep -q 'collectors still running' "$wait_err" ||
    fail "collector wait names the collectors that are still running" "$(cat "$wait_err")"
  pass "collector wait fails when its deadline expires while collectors are running"

  prep_err="$agents_restore_fixture/prepare.err"
  prep_exit=0
  prepare_agents_settings_restore 2>"$prep_err" || prep_exit=$?
  [[ $prep_exit -ne 0 ]] ||
    fail "busy setup refuses to capture while collectors are running"
  [[ ! -e $agents_provider_shell_json && ! -e $agents_provider_usage_dir && ! -e $agents_provider_cache_dir ]] ||
    fail "busy setup does not create settings, usage, or cache paths"
  [[ -z ${agents_provider_backup:-} ]] ||
    fail "busy setup does not keep a snapshot"
  [[ -z ${agents_provider_shell_existed:-} && -z ${agents_provider_usage_existed:-} && -z ${agents_provider_cache_existed:-} ]] ||
    fail "busy setup does not record existence flags"
  grep -q 'refusing to capture' "$prep_err" ||
    fail "busy setup reports that capture was refused" "$(cat "$prep_err")"

  mkdir -p "$agents_provider_usage_dir/nested" "$agents_provider_cache_dir" "$(dirname "$agents_provider_shell_json")"
  printf '%s\n' original-usage >"$agents_provider_usage_dir/nested/kept.json"
  printf '%s\n' original-cache >"$agents_provider_cache_dir/kept.json"
  printf '%s\n' '{"ok":true}' >"$agents_provider_shell_json"
  export AGENTS_PROVIDER_COLLECTOR_WAIT=3
  prep_exit=0
  prepare_agents_settings_restore 2>"$prep_err" || prep_exit=$?
  [[ $prep_exit -ne 0 ]] ||
    fail "busy setup refuses to capture over existing settings"
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == original-usage ]] ||
    fail "busy setup leaves an existing usage file unchanged"
  [[ $(<"$agents_provider_cache_dir/kept.json") == original-cache ]] ||
    fail "busy setup leaves an existing cache file unchanged"
  [[ $(<"$agents_provider_shell_json") == '{"ok":true}' ]] ||
    fail "busy setup leaves existing shell settings unchanged"
  [[ ! -e $agents_provider_usage_dir/extra.json && ! -e $agents_provider_cache_dir/extra.json ]] ||
    fail "busy setup does not add fixture files"
  [[ -z ${agents_provider_backup:-} ]] ||
    fail "busy setup does not keep a snapshot over existing settings"
  [[ -z ${agents_provider_shell_existed:-} && -z ${agents_provider_usage_existed:-} && -z ${agents_provider_cache_existed:-} ]] ||
    fail "busy setup does not record existence flags over existing settings"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  pass "busy setup refuses to capture while collectors are running"

  printf '%s\n' settled >"$agents_restore_fixture/collector-state"
  export AGENTS_PROVIDER_COLLECTOR_WAIT=3
  prepare_agents_settings_restore
  [[ $agents_provider_shell_existed == 1 && $agents_provider_usage_existed == 1 && $agents_provider_cache_existed == 1 ]] ||
    fail "settled setup records settings, usage, and cache as present"
  [[ -n ${agents_provider_backup:-} && -d $agents_provider_backup ]] ||
    fail "settled setup keeps a snapshot directory"
  [[ $(<"$agents_provider_backup/usage/nested/kept.json") == original-usage ]] ||
    fail "settled setup snapshots the original usage file"
  [[ $(<"$agents_provider_backup/cache/kept.json") == original-cache ]] ||
    fail "settled setup snapshots the original cache file"
  [[ $(<"$agents_provider_backup/shell.json") == '{"ok":true}' ]] ||
    fail "settled setup snapshots the original shell settings"
  backup=$agents_provider_backup
  shell_existed=$agents_provider_shell_existed
  usage_existed=$agents_provider_usage_existed
  cache_existed=$agents_provider_cache_existed

  printf '%s\n' dirty-usage >"$agents_provider_usage_dir/nested/kept.json"
  printf '%s\n' extra-usage >"$agents_provider_usage_dir/extra.json"
  printf '%s\n' dirty-cache >"$agents_provider_cache_dir/kept.json"
  printf '%s\n' '{"dirty":true}' >"$agents_provider_shell_json"
  printf '%s\n' running >"$agents_restore_fixture/collector-state"
  export AGENTS_PROVIDER_COLLECTOR_WAIT=3
  restore_err="$agents_restore_fixture/restore.err"
  restore_exit=0
  restore_agents_settings 2>"$restore_err" || restore_exit=$?
  [[ $restore_exit -ne 0 ]] ||
    fail "cleanup fails when collectors are still running at the deadline"
  [[ $agents_provider_backup == "$backup" && -d $backup ]] ||
    fail "timed out cleanup keeps the snapshot directory"
  [[ $agents_provider_shell_existed == "$shell_existed" && $agents_provider_usage_existed == "$usage_existed" && $agents_provider_cache_existed == "$cache_existed" ]] ||
    fail "timed out cleanup keeps the existence flags"
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == dirty-usage && $(<"$agents_provider_usage_dir/extra.json") == extra-usage ]] ||
    fail "timed out cleanup leaves the usage directory unchanged"
  [[ $(<"$agents_provider_cache_dir/kept.json") == dirty-cache ]] ||
    fail "timed out cleanup leaves the cache unchanged"
  [[ $(<"$agents_provider_shell_json") == '{"dirty":true}' ]] ||
    fail "timed out cleanup leaves shell settings unchanged"
  [[ $(<"$backup/usage/nested/kept.json") == original-usage && ! -e $backup/usage/extra.json ]] ||
    fail "timed out cleanup leaves the usage snapshot unchanged"
  [[ $(<"$backup/cache/kept.json") == original-cache ]] ||
    fail "timed out cleanup leaves the cache snapshot unchanged"
  [[ $(<"$backup/shell.json") == '{"ok":true}' ]] ||
    fail "timed out cleanup leaves the shell snapshot unchanged"
  grep -q 'snapshots in place' "$restore_err" ||
    fail "timed out cleanup reports that the snapshot was kept" "$(cat "$restore_err")"
  grep -q 'collectors still running' "$restore_err" ||
    fail "timed out cleanup reports that collectors are still running" "$(cat "$restore_err")"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  pass "timed out cleanup keeps the fixture and the snapshot for retry"

  printf '%s\n' settled >"$agents_restore_fixture/collector-state"
  export AGENTS_PROVIDER_COLLECTOR_WAIT=3
  restore_agents_settings
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == original-usage && ! -e $agents_provider_usage_dir/extra.json ]] ||
    fail "settled retry restores the original usage directory"
  [[ $(<"$agents_provider_cache_dir/kept.json") == original-cache ]] ||
    fail "settled retry restores the original cache"
  [[ $(<"$agents_provider_shell_json") == '{"ok":true}' ]] ||
    fail "settled retry restores the original shell settings"
  [[ -z ${agents_provider_backup:-} && ! -d $backup ]] ||
    fail "settled retry removes the snapshot backup"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  pass "settled retry restores the original files and removes the snapshot"
)

# A collector that starts inside the snapshot copy is still a writer. The copy
# seam runs the real cp, then starts one sleeper whose command is a collector.
# Cleanup must refuse while that sleeper is alive, keep the snapshot, and
# restore exactly once the sleeper has exited. A shell whose arguments only
# mention a collector is not one. Nothing here signals a peer or changes HOME.
rm -rf "$agents_restore_fixture"
agents_restore_fixture=$(mktemp -d)
(
  set -euo pipefail
  expected_home=$HOME
  export XDG_CONFIG_HOME="$agents_restore_fixture/config"
  export XDG_STATE_HOME="$agents_restore_fixture/state"
  export XDG_CACHE_HOME="$agents_restore_fixture/cache"
  unset AGENTS_PROVIDER_COLLECTOR_PROBE
  # shellcheck disable=SC1091
  source "$ROOT/test/acceptance.d/agents-providers-test.sh"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"

  writer_pid=""
  decoy_pid=""
  cleanup_controlled_collectors() {
    local pid
    for pid in "$writer_pid" "$decoy_pid"; do
      [[ -n $pid ]] || continue
      if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
      fi
    done
  }
  trap cleanup_controlled_collectors EXIT

  omarchy-shell() { printf '%s\n' "$*" >>"$agents_restore_fixture/hide.log"; }
  : >"$agents_restore_fixture/hide.log"

  mkdir -p "$(dirname "$(agents_provider_shell_json)")" \
    "$(agents_provider_usage_dir)/nested" \
    "$(agents_provider_cache_dir)"
  printf '%s\n' original-usage >"$(agents_provider_usage_dir)/nested/kept.json"
  printf '%s\n' original-cache >"$(agents_provider_cache_dir)/kept.json"
  printf '%s\n' '{"ok":true}' >"$(agents_provider_shell_json)"
  [[ $(agents_provider_usage_dir) == "$agents_restore_fixture"/* ]] ||
    fail "collector race cleanup keeps usage under the fixture"
  [[ $(agents_provider_cache_dir) == "$agents_restore_fixture"/* ]] ||
    fail "collector race cleanup keeps cache under the fixture"
  [[ $(agents_provider_shell_json) == "$agents_restore_fixture"/* ]] ||
    fail "collector race cleanup keeps shell settings under the fixture"

  bash -c 'sleep 30 # omarchy-agent-usage-mentioned-only' &
  decoy_pid=$!
  rc=0
  agents_provider_pid_is_collector "$decoy_pid" || rc=$?
  [[ $rc -eq 1 ]] ||
    fail "a command that only mentions a collector is not a collector"
  rc=0
  agents_provider_pid_is_collector "$BASHPID" || rc=$?
  [[ $rc -eq 1 ]] ||
    fail "the test script is not a collector"

  arm_writer=0
  cp() {
    command cp "$@"
    local status=$?
    ((status == 0)) || return "$status"
    if [[ ${arm_writer:-0} == 1 && -z ${writer_pid:-} ]]; then
      local bin="$agents_restore_fixture/bin"
      mkdir -p "$bin"
      cat >"$bin/omarchy-agent-usage-sleeper" <<EOF
#!/bin/bash
sleep 3
mkdir -p "$agents_provider_usage_dir" "$agents_provider_cache_dir"
printf '%s\n' sleeper-usage >"$agents_provider_usage_dir/sleeper.json"
printf '%s\n' sleeper-cache >"$agents_provider_cache_dir/sleeper.json"
EOF
      chmod +x "$bin/omarchy-agent-usage-sleeper"
      "$bin/omarchy-agent-usage-sleeper" >/dev/null 2>&1 &
      writer_pid=$!
    fi
    return 0
  }

  arm_writer=1
  export AGENTS_PROVIDER_COLLECTOR_WAIT=3
  prepare_agents_settings_restore
  arm_writer=0
  [[ -n $writer_pid ]] || fail "snapshot copy starts a collector"
  kill -0 "$writer_pid" || fail "the collector started during the snapshot copy is alive"
  rc=0
  agents_provider_pid_is_collector "$writer_pid" || rc=$?
  [[ $rc -eq 0 ]] || fail "the sleeper command is a collector"
  agents_provider_collectors_active || fail "a collector started during capture is still active"
  [[ $agents_provider_capture_complete == 1 ]] || fail "capture finishes after the copy seam"
  [[ $(<"$agents_provider_backup/usage/nested/kept.json") == original-usage ]] ||
    fail "the copy seam snapshots usage before the sleeper writes"
  [[ $(<"$agents_provider_backup/cache/kept.json") == original-cache ]] ||
    fail "the copy seam snapshots cache before the sleeper writes"
  [[ $(<"$agents_provider_backup/shell.json") == '{"ok":true}' ]] ||
    fail "the copy seam snapshots shell settings before the sleeper writes"
  backup=$agents_provider_backup

  printf '%s\n' dirty-usage >"$agents_provider_usage_dir/nested/kept.json"
  printf '%s\n' dirty-cache >"$agents_provider_cache_dir/kept.json"
  printf '%s\n' '{"dirty":true}' >"$agents_provider_shell_json"
  export AGENTS_PROVIDER_COLLECTOR_WAIT=1
  restore_err="$agents_restore_fixture/restore-race.err"
  restore_exit=0
  restore_agents_settings 2>"$restore_err" || restore_exit=$?
  [[ $restore_exit -ne 0 ]] ||
    fail "cleanup refuses while a collector started during capture is alive"
  kill -0 "$writer_pid" ||
    fail "cleanup returns before the collector started during capture exits"
  [[ $agents_provider_backup == "$backup" && -d $backup ]] ||
    fail "cleanup keeps the snapshot while that collector is alive"
  [[ $agents_provider_capture_complete == 1 ]] ||
    fail "cleanup keeps the completed capture while that collector is alive"
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == dirty-usage && ! -e $agents_provider_usage_dir/sleeper.json ]] ||
    fail "cleanup leaves usage unchanged while that collector is alive"
  [[ $(<"$agents_provider_cache_dir/kept.json") == dirty-cache && ! -e $agents_provider_cache_dir/sleeper.json ]] ||
    fail "cleanup leaves cache unchanged while that collector is alive"
  [[ $(<"$agents_provider_shell_json") == '{"dirty":true}' ]] ||
    fail "cleanup leaves shell settings unchanged while that collector is alive"
  [[ $(<"$backup/usage/nested/kept.json") == original-usage ]] ||
    fail "cleanup leaves the usage snapshot unchanged while that collector is alive"
  grep -q 'collectors still running' "$restore_err" ||
    fail "cleanup reports the collector that is still running" "$(cat "$restore_err")"
  grep -q 'snapshots in place' "$restore_err" ||
    fail "cleanup reports that the snapshot was kept" "$(cat "$restore_err")"

  wait "$writer_pid"
  writer_pid=""
  [[ $(<"$agents_provider_usage_dir/sleeper.json") == sleeper-usage ]] ||
    fail "the collector writes usage after the refused cleanup"
  [[ $(<"$agents_provider_cache_dir/sleeper.json") == sleeper-cache ]] ||
    fail "the collector writes cache after the refused cleanup"
  export AGENTS_PROVIDER_COLLECTOR_WAIT=3
  restore_agents_settings
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == original-usage && ! -e $agents_provider_usage_dir/sleeper.json ]] ||
    fail "cleanup restores usage exactly after the collector exits"
  [[ $(<"$agents_provider_cache_dir/kept.json") == original-cache && ! -e $agents_provider_cache_dir/sleeper.json ]] ||
    fail "cleanup restores cache exactly after the collector exits"
  [[ $(<"$agents_provider_shell_json") == '{"ok":true}' ]] ||
    fail "cleanup restores shell settings exactly after the collector exits"
  [[ -z ${agents_provider_backup:-} && ! -d $backup ]] ||
    fail "cleanup removes the snapshot after the collector exits"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  pass "cleanup waits out a collector that starts during the snapshot copy"
)

# cp failing inside a conditional call must not look like success. errexit is
# off for that call, so the helpers check each copy themselves. A failed
# restore keeps the live paths and the backup; the next call puts them back.
rm -rf "$agents_restore_fixture"
agents_restore_fixture=$(mktemp -d)
(
  set -euo pipefail
  expected_home=$HOME
  export XDG_CONFIG_HOME="$agents_restore_fixture/config"
  export XDG_STATE_HOME="$agents_restore_fixture/state"
  export XDG_CACHE_HOME="$agents_restore_fixture/cache"
  unset AGENTS_PROVIDER_COLLECTOR_PROBE
  export AGENTS_PROVIDER_COLLECTOR_WAIT=3
  # shellcheck disable=SC1091
  source "$ROOT/test/acceptance.d/agents-providers-test.sh"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  omarchy-shell() { printf '%s\n' "$*" >>"$agents_restore_fixture/hide.log"; }
  : >"$agents_restore_fixture/hide.log"

  mkdir -p "$(agents_provider_usage_dir)/nested" "$(agents_provider_cache_dir)" "$(dirname "$(agents_provider_shell_json)")"
  printf '%s\n' original-usage >"$(agents_provider_usage_dir)/nested/kept.json"
  printf '%s\n' original-cache >"$(agents_provider_cache_dir)/kept.json"
  printf '%s\n' '{"ok":true}' >"$(agents_provider_shell_json)"
  [[ $(agents_provider_shell_json) == "$agents_restore_fixture"/* ]] ||
    fail "restore failure cleanup keeps shell settings under the fixture"

  prepare_agents_settings_restore
  [[ $agents_provider_capture_complete == 1 ]] || fail "restore failure setup captures every tree"
  backup=$agents_provider_backup
  printf '%s\n' dirty-usage >"$agents_provider_usage_dir/nested/kept.json"
  printf '%s\n' extra-usage >"$agents_provider_usage_dir/extra.json"
  printf '%s\n' dirty-cache >"$agents_provider_cache_dir/kept.json"
  printf '%s\n' '{"dirty":true}' >"$agents_provider_shell_json"

  fail_cp=0
  cp() {
    if [[ ${fail_cp:-0} == 1 ]]; then
      command cp -a "$1" "/proc/agents-provider-cp-failure-$$" >/dev/null 2>&1
      return $?
    fi
    command cp "$@"
  }
  fail_cp=1
  restore_err="$agents_restore_fixture/restore-io.err"
  restore_exit=0
  restore_agents_settings 2>"$restore_err" || restore_exit=$?
  [[ $restore_exit -ne 0 ]] ||
    fail "cleanup reports a failing restore copy"
  [[ $agents_provider_backup == "$backup" && -d $backup ]] ||
    fail "a failing restore copy keeps the snapshot"
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == dirty-usage && $(<"$agents_provider_usage_dir/extra.json") == extra-usage ]] ||
    fail "a failing restore copy leaves usage unchanged"
  [[ $(<"$agents_provider_cache_dir/kept.json") == dirty-cache ]] ||
    fail "a failing restore copy leaves cache unchanged"
  [[ $(<"$agents_provider_shell_json") == '{"dirty":true}' ]] ||
    fail "a failing restore copy leaves shell settings unchanged"
  [[ $(<"$backup/usage/nested/kept.json") == original-usage && ! -e $backup/usage/extra.json ]] ||
    fail "a failing restore copy leaves the usage snapshot unchanged"
  [[ $(<"$backup/cache/kept.json") == original-cache ]] ||
    fail "a failing restore copy leaves the cache snapshot unchanged"
  [[ $(<"$backup/shell.json") == '{"ok":true}' ]] ||
    fail "a failing restore copy leaves the shell snapshot unchanged"
  grep -q 'restore failed' "$restore_err" ||
    fail "a failing restore copy reports the failure" "$(cat "$restore_err")"

  fail_cp=0
  restore_agents_settings
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == original-usage && ! -e $agents_provider_usage_dir/extra.json ]] ||
    fail "the restore retry puts the original usage directory back"
  [[ $(<"$agents_provider_cache_dir/kept.json") == original-cache ]] ||
    fail "the restore retry puts the original cache back"
  [[ $(<"$agents_provider_shell_json") == '{"ok":true}' ]] ||
    fail "the restore retry puts the original shell settings back"
  [[ -z ${agents_provider_backup:-} && ! -d $backup ]] ||
    fail "the restore retry removes the snapshot"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  pass "a failing restore copy keeps the snapshot for a successful retry"
)

# A capture copy that fails must not become a finished snapshot. The second
# tree is the one cp refuses, and a later restore must not delete it.
rm -rf "$agents_restore_fixture"
agents_restore_fixture=$(mktemp -d)
(
  set -euo pipefail
  expected_home=$HOME
  export XDG_CONFIG_HOME="$agents_restore_fixture/config"
  export XDG_STATE_HOME="$agents_restore_fixture/state"
  export XDG_CACHE_HOME="$agents_restore_fixture/cache"
  unset AGENTS_PROVIDER_COLLECTOR_PROBE
  export AGENTS_PROVIDER_COLLECTOR_WAIT=3
  # shellcheck disable=SC1091
  source "$ROOT/test/acceptance.d/agents-providers-test.sh"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"

  mkdir -p "$(agents_provider_usage_dir)/nested" "$(agents_provider_cache_dir)" "$(dirname "$(agents_provider_shell_json)")"
  printf '%s\n' original-usage >"$(agents_provider_usage_dir)/nested/kept.json"
  printf '%s\n' original-cache >"$(agents_provider_cache_dir)/kept.json"
  printf '%s\n' '{"ok":true}' >"$(agents_provider_shell_json)"
  [[ $(agents_provider_usage_dir) == "$agents_restore_fixture"/* ]] ||
    fail "capture failure cleanup keeps usage under the fixture"

  cp_n=0
  cp() {
    cp_n=$((cp_n + 1))
    if ((cp_n == 2)); then
      command cp -a "$1" "/proc/agents-provider-cp-failure-$$" >/dev/null 2>&1
      return $?
    fi
    command cp "$@"
  }
  prep_err="$agents_restore_fixture/capture.err"
  prep_exit=0
  prepare_agents_settings_restore 2>"$prep_err" || prep_exit=$?
  [[ $prep_exit -ne 0 ]] || fail "partial capture does not succeed"
  [[ ${agents_provider_capture_complete:-0} == 0 ]] || fail "partial capture stays incomplete"
  [[ -n ${agents_provider_backup:-} && -d $agents_provider_backup ]] ||
    fail "partial capture keeps the snapshot directory"
  [[ -e $agents_provider_backup/shell.json || -L $agents_provider_backup/shell.json ]] ||
    fail "partial capture keeps the snapshot copy that succeeded"
  [[ ! -e $agents_provider_backup/usage && ! -L $agents_provider_backup/usage ]] ||
    fail "partial capture does not invent the copy that failed"
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == original-usage ]] ||
    fail "partial capture leaves usage unchanged"
  [[ $(<"$agents_provider_cache_dir/kept.json") == original-cache ]] ||
    fail "partial capture leaves cache unchanged"
  [[ $(<"$agents_provider_shell_json") == '{"ok":true}' ]] ||
    fail "partial capture leaves shell settings unchanged"
  grep -q 'capture failed' "$prep_err" ||
    fail "partial capture reports the failure" "$(cat "$prep_err")"
  backup=$agents_provider_backup

  restore_err="$agents_restore_fixture/capture-restore.err"
  restore_exit=0
  restore_agents_settings 2>"$restore_err" || restore_exit=$?
  [[ $restore_exit -ne 0 ]] || fail "an incomplete snapshot is not restored"
  [[ $agents_provider_backup == "$backup" && -d $backup ]] ||
    fail "an incomplete snapshot is kept"
  [[ $(<"$agents_provider_usage_dir/nested/kept.json") == original-usage ]] ||
    fail "an incomplete snapshot does not delete usage"
  [[ $(<"$agents_provider_cache_dir/kept.json") == original-cache ]] ||
    fail "an incomplete snapshot does not delete cache"
  [[ $(<"$agents_provider_shell_json") == '{"ok":true}' ]] ||
    fail "an incomplete snapshot does not replace shell settings"
  grep -q 'incomplete' "$restore_err" ||
    fail "an incomplete snapshot reports why it was kept" "$(cat "$restore_err")"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  pass "partial capture does not restore from an incomplete snapshot"
)

# Detection errors are collectors still running. A probe status other than the
# settled answer, a probe that is not executable, and a process listing that
# fails all refuse the capture instead of treating the machine as quiet.
rm -rf "$agents_restore_fixture"
agents_restore_fixture=$(mktemp -d)
(
  set -euo pipefail
  expected_home=$HOME
  export XDG_CONFIG_HOME="$agents_restore_fixture/config"
  export XDG_STATE_HOME="$agents_restore_fixture/state"
  export XDG_CACHE_HOME="$agents_restore_fixture/cache"
  export AGENTS_PROVIDER_COLLECTOR_WAIT=0
  # shellcheck disable=SC1091
  source "$ROOT/test/acceptance.d/agents-providers-test.sh"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"

  printf '%s\n' '#!/bin/bash' 'exit 2' >"$agents_restore_fixture/probe-error"
  chmod +x "$agents_restore_fixture/probe-error"
  export AGENTS_PROVIDER_COLLECTOR_PROBE="$agents_restore_fixture/probe-error"
  wait_err="$agents_restore_fixture/probe-error.err"
  wait_exit=0
  agents_provider_wait_for_collectors 2>"$wait_err" || wait_exit=$?
  [[ $wait_exit -ne 0 ]] || fail "a probe error counts as collectors still running"
  grep -q 'collectors still running' "$wait_err" ||
    fail "a probe error names collectors still running" "$(cat "$wait_err")"

  export AGENTS_PROVIDER_COLLECTOR_PROBE="$agents_restore_fixture/missing-probe"
  prep_err="$agents_restore_fixture/missing-probe.err"
  prep_exit=0
  prepare_agents_settings_restore 2>"$prep_err" || prep_exit=$?
  [[ $prep_exit -ne 0 ]] || fail "a missing probe refuses capture"
  [[ -z ${agents_provider_backup:-} ]] || fail "a missing probe does not keep a snapshot"
  grep -q 'refusing to capture' "$prep_err" ||
    fail "a missing probe reports the refused capture" "$(cat "$prep_err")"

  unset AGENTS_PROVIDER_COLLECTOR_PROBE
  ps() { return 1; }
  prep_exit=0
  prepare_agents_settings_restore 2>"$prep_err" || prep_exit=$?
  [[ $prep_exit -ne 0 ]] || fail "a failed process listing refuses capture"
  [[ -z ${agents_provider_backup:-} ]] || fail "a failed process listing does not keep a snapshot"
  grep -q 'refusing to capture' "$prep_err" ||
    fail "a failed process listing reports the refused capture" "$(cat "$prep_err")"
  [[ $HOME == "$expected_home" ]] || fail "provider acceptance cleanup leaves HOME unchanged"
  pass "collector detection fails closed"
)

# Interpreter options must lead to the script operand. Option values, inline
# commands, stdin and later arguments are not a collector filename.
(
  source "$ROOT/test/acceptance.d/agents-providers-test.sh"
  check_collector_argv() {
    local expected=$1 status=0
    shift
    agents_provider_argv_is_collector "$@" || status=$?
    [[ $status == "$expected" ]] || fail "collector detection parses interpreter options" "expected $expected, got $status"
  }
  check_collector_argv 0 python3 -u "$ROOT/bin/omarchy-agent-usage-codex" --force
  check_collector_argv 0 python3 -W ignore -X utf8 -- "$ROOT/bin/omarchy-agent-usage-codex"
  check_collector_argv 0 python3 -uWignore -Xutf8 "$ROOT/bin/omarchy-agent-usage-codex"
  check_collector_argv 0 python3 --check-hash-based-pycs default "$ROOT/bin/omarchy-agent-usage-codex"
  check_collector_argv 0 bash -p -- "$ROOT/bin/omarchy-agent-usage-update"
  check_collector_argv 0 bash -euo pipefail -- "$ROOT/bin/omarchy-agent-usage-update"
  check_collector_argv 0 bash -eou pipefail -- "$ROOT/bin/omarchy-agent-usage-update"
  check_collector_argv 0 bash --noprofile --rcfile /tmp/ignored "$ROOT/bin/omarchy-agent-usage-update"
  check_collector_argv 0 dash -e -- "$ROOT/bin/omarchy-agent-usage-update"
  check_collector_argv 1 python3 -c 'print("omarchy-agent-usage")' omarchy-agent-usage-codex
  check_collector_argv 1 python3 -uc 'print("omarchy-agent-usage")' omarchy-agent-usage-codex
  check_collector_argv 1 python3 -m timeit omarchy-agent-usage-codex
  check_collector_argv 1 python3 - omarchy-agent-usage-codex
  check_collector_argv 1 bash -c 'sleep 1 # omarchy-agent-usage' omarchy-agent-usage-codex
  check_collector_argv 1 bash -s omarchy-agent-usage-codex
  check_collector_argv 1 bash --rcfile /tmp/omarchy-agent-usage-note /tmp/not-a-collector omarchy-agent-usage-codex
  check_collector_argv 1 python3 -W /tmp/omarchy-agent-usage-note /tmp/not-a-collector omarchy-agent-usage-codex
  check_collector_argv 1 python3 /tmp/not-a-collector omarchy-agent-usage-codex
  pass "collector detection finds script operands without matching later arguments"
)

# Run the actual Codex collector only in a filesystem/process/network fence.
# Its real cache lock holds a python3 -u writer alive while actual cleanup and
# read-error handling run. HOME retains its literal value; its files are hidden.
if ! command -v bwrap >/dev/null 2>&1; then
  skip "bwrap is not installed; isolated real Codex collector regression did not run"
elif ! bwrap --unshare-all --ro-bind / / /usr/bin/true >/dev/null 2>&1; then
  skip "isolated user namespaces are unavailable; real Codex collector regression did not run"
else
  rm -rf "$agents_restore_fixture"
  agents_restore_fixture=$(mktemp -d)
  cat >"$agents_restore_fixture/codex-options-test.py" <<'PY'
import fcntl
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import time

fixture = Path('/tmp/fixture')
expected_home = os.environ['HOME']
for name in ['config', 'state', 'cache', 'data', 'tmp']:
    (fixture / name).mkdir()
os.environ.update({
    'XDG_CONFIG_HOME': str(fixture / 'config'),
    'XDG_STATE_HOME': str(fixture / 'state'),
    'XDG_CACHE_HOME': str(fixture / 'cache'),
    'XDG_DATA_HOME': str(fixture / 'data'),
    'TMPDIR': str(fixture / 'tmp'),
})
loader = importlib.machinery.SourceFileLoader('codex_collector', '/mnt/bin/omarchy-agent-usage-codex')
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
cache_file, lock_file = collector.scan_cache_paths()
cache_file.write_text('{"marker":"original-cache"}\n')
(fixture / 'cache-file-name').write_text(cache_file.name)
gone = subprocess.Popen(['/usr/bin/true'])
gone.wait(timeout=5)
(fixture / 'gone-pid').write_text(str(gone.pid))
usage = fixture / 'state/omarchy/agents/usage'
usage.mkdir(parents=True)
(usage / 'kept.json').write_text('original-usage')
settings = fixture / 'config/omarchy/shell.json'
settings.parent.mkdir(parents=True)
settings.write_text('original-settings')

runner = fixture / 'restore-runner.sh'
runner.write_text('''#!/bin/bash
set -euo pipefail
source /mnt/test/acceptance.d/agents-providers-test.sh
AGENTS_PROVIDER_COLLECTOR_WAIT=5
prepare_agents_settings_restore
backup=$agents_provider_backup
touch /tmp/fixture/prepared
while [[ ! -e /tmp/fixture/started ]]; do sleep 0.02; done
writer_pid=$(</tmp/fixture/writer-pid)
agents_provider_pid_is_collector "$writer_pid"
printf dirty-settings >"$agents_provider_shell_json"
printf dirty-usage >"$agents_provider_usage_dir/kept.json"
AGENTS_PROVIDER_COLLECTOR_WAIT=1
status=0
restore_agents_settings || status=$?
[[ $status != 0 && $agents_provider_backup == "$backup" && -d $backup ]]
[[ $(<"$agents_provider_shell_json") == dirty-settings ]]
[[ $(<"$agents_provider_usage_dir/kept.json") == dirty-usage ]]
[[ $(<"$backup/shell.json") == original-settings ]]
[[ $(<"$backup/usage/kept.json") == original-usage ]]
kill -0 "$writer_pid"
touch /tmp/fixture/refused

# A failed liveness probe cannot make this actual, lock-blocked writer quiet.
kill() { return 2; }
status=0
agents_provider_pid_can_write "$writer_pid" || status=$?
[[ $status == 0 ]]
status=0
agents_provider_collectors_active || status=$?
[[ $status == 0 ]]
status=0
restore_agents_settings || status=$?
[[ $status != 0 && $agents_provider_backup == "$backup" && -d $backup ]]
[[ $(<"$agents_provider_shell_json") == dirty-settings ]]
[[ $(<"$agents_provider_usage_dir/kept.json") == dirty-usage ]]
[[ $(<"$backup/shell.json") == original-settings ]]
[[ $(<"$backup/usage/kept.json") == original-usage ]]
cache_name=$(</tmp/fixture/cache-file-name)
cmp -s "$agents_provider_cache_dir/$cache_name" "$backup/cache/$cache_name"
command kill -0 "$writer_pid"
gone_pid=$(</tmp/fixture/gone-pid)
[[ ! -d /proc/$gone_pid ]]
status=0
agents_provider_pid_can_write "$gone_pid" || status=$?
[[ $status == 1 ]]
unset -f kill
touch /tmp/fixture/liveness-error-refused

# Fault the actual /proc read dependency after opening a live, real pid.
# The checked read must reject even partial output rather than parsing it.
cat() {
  if [[ ${1:-} == /proc/*/cmdline ]]; then
    if [[ $read_fault == io ]]; then
      command cat /proc
      return $?
    fi
    printf 'partial-command'
    return 2
  fi
  command cat "$@"
}
python3() {
  command python3 -c '
import builtins
import sys
real_open = builtins.open
mode = sys.argv[1]
sys.argv = sys.argv[2:]
def faulty_open(path, *args, **kwargs):
    if str(path).startswith("/proc/") and str(path).endswith("/cmdline"):
        if mode == "io":
            return real_open("/proc", "rb")
        class PartialRead:
            def __enter__(self): return self
            def __exit__(self, *args): return False
            def read(self):
                real_open(path, *args, **kwargs).close()
                raise OSError("read failed after partial transfer")
        return PartialRead()
    return real_open(path, *args, **kwargs)
builtins.open = faulty_open
exec(compile(sys.stdin.read(), "actual-cmdline-helper", "exec"))
' "$read_fault" "$@"
}
for read_fault in partial io; do
  status=0
  agents_provider_pid_is_collector "$writer_pid" || status=$?
  [[ $status == 2 ]]
  status=0
  agents_provider_collectors_active || status=$?
  [[ $status == 0 ]]
  status=0
  restore_agents_settings || status=$?
  [[ $status != 0 && $agents_provider_backup == "$backup" && -d $backup ]]
  [[ $(<"$agents_provider_shell_json") == dirty-settings ]]
  [[ $(<"$agents_provider_usage_dir/kept.json") == dirty-usage ]]
done
unset -f cat python3
touch /tmp/fixture/read-error-refused
while [[ ! -e /tmp/fixture/finished ]]; do sleep 0.02; done
AGENTS_PROVIDER_COLLECTOR_WAIT=5
restore_agents_settings
[[ $(<"$agents_provider_shell_json") == original-settings ]]
[[ $(<"$agents_provider_usage_dir/kept.json") == original-usage ]]
[[ -z ${agents_provider_backup:-} && ! -d $backup ]]
''')

def wait_marker(name, process):
    deadline = time.monotonic() + 15
    while not (fixture / name).exists():
        if process.poll() is not None or time.monotonic() >= deadline:
            raise AssertionError('restore runner did not reach ' + name)
        time.sleep(0.02)

lock = lock_file.open('w')
fcntl.flock(lock, fcntl.LOCK_EX)
runner_process = subprocess.Popen(['/bin/bash', str(runner)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
writer = None
shell_writer = None
try:
    wait_marker('prepared', runner_process)
    writer = subprocess.Popen(['/usr/bin/python3', '-u', '-W', 'ignore', '-X', 'utf8', '--',
                               '/mnt/bin/omarchy-agent-usage-codex', '--force'],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    deadline = time.monotonic() + 5
    while 'lock' not in Path('/proc/' + str(writer.pid) + '/wchan').read_text():
        assert writer.poll() is None, 'real Codex collector exited before its cache lock'
        assert time.monotonic() < deadline, 'real Codex collector did not reach its cache lock'
        time.sleep(0.02)
    (fixture / 'writer-pid').write_text(str(writer.pid))
    (fixture / 'started').touch()
    wait_marker('refused', runner_process)
    assert writer.poll() is None, 'cleanup must refuse before the real collector exits'
    wait_marker('liveness-error-refused', runner_process)
    assert writer.poll() is None, 'liveness error must retain the live writer backup'
    assert cache_file.read_text() == '{"marker":"original-cache"}\n', 'liveness-error cleanup must leave the original cache intact'
    wait_marker('read-error-refused', runner_process)
    assert writer.poll() is None, 'read-error cleanup must retain the live writer backup'
    fcntl.flock(lock, fcntl.LOCK_UN)
    output, error = writer.communicate(timeout=10)
    assert writer.returncode == 0, error
    assert json.loads(output)['id'] == 'codex'
    assert cache_file.read_text() != '{"marker":"original-cache"}\n', 'real collector must write after the refused cleanup'
    (fixture / 'finished').touch()
    output, error = runner_process.communicate(timeout=10)
    assert runner_process.returncode == 0, error
    assert cache_file.read_text() == '{"marker":"original-cache"}\n', 'settled retry must restore the original cache'

    # Shell options and -- also precede a genuine script operand in /proc.
    shell_script = fixture / 'omarchy-agent-usage-shell-options'
    shell_script.write_text('while [[ ! -e /tmp/fixture/shell-release ]]; do sleep 0.02; done\n')
    shell_writer = subprocess.Popen(['/bin/bash', '-p', '-eou', 'pipefail', '--', str(shell_script)])
    time.sleep(0.05)
    subprocess.run(['/bin/bash', '-c', 'source /mnt/test/acceptance.d/agents-providers-test.sh; agents_provider_pid_is_collector "$1"',
                    'collector-pid-check', str(shell_writer.pid)], check=True)
    (fixture / 'shell-release').touch()
    shell_writer.wait(timeout=5)
    assert shell_writer.returncode == 0
finally:
    fcntl.flock(lock, fcntl.LOCK_UN)
    lock.close()
    for process in [writer, shell_writer, runner_process]:
        if process is not None and process.poll() is None:
            process.terminate()
            process.wait(timeout=5)

assert os.environ['HOME'] == expected_home
print('ok - unknown live-pid liveness failures preserve the backup and absent pids are quiet')
print('ok - real interpreter-option collectors are detected and settled retry restores the cache')
print('ok - actual proc read failures preserve the backup while a real collector is alive')
PY
  mkdir -p "$agents_restore_fixture/empty-home"
  bwrap --die-with-parent --unshare-all --ro-bind / / \
    --tmpfs /home --tmpfs /tmp --tmpfs /run --proc /proc --dev /dev \
    --ro-bind "$ROOT" /mnt --bind "$agents_restore_fixture" /tmp/fixture \
    --ro-bind "$agents_restore_fixture/empty-home" "$HOME" \
    --setenv PATH /usr/bin:/bin \
    --unsetenv CODEX_HOME --unsetenv AGENTS_PROVIDER_COLLECTOR_PROBE \
    --unsetenv BASH_ENV --unsetenv ENV --unsetenv NODE_OPTIONS \
    --unsetenv DISPLAY --unsetenv WAYLAND_DISPLAY --unsetenv DBUS_SESSION_BUS_ADDRESS \
    --unsetenv HYPRLAND_INSTANCE_SIGNATURE --unsetenv XDG_RUNTIME_DIR \
    --chdir /mnt /usr/bin/python3 /tmp/fixture/codex-options-test.py || \
    fail "isolated real collector option and proc read regressions"
fi

# Syntax only. qmllint can check Main.qml; on this Qt build it exits 255 with
# no diagnostic for Panel.qml, and it does that for the panel as it already
# stood. qmldom parses the panel without loading it. Installed Qt rendering
# is checked in the VM, not by launching Quickshell here.
qml_imports=$(mktemp -d)

if ! command -v qmllint >/dev/null 2>&1; then
  skip "qmllint is not installed; agents Main.qml lint did not run"
else
  mkdir -p "$qml_imports/qs"
  ln -s "$ROOT/shell/Commons" "$qml_imports/qs/Commons"
  ln -s "$ROOT/shell/Ui" "$qml_imports/qs/Ui"
  lint=$(qmllint -I "$qml_imports" "$ROOT/shell/plugins/agents/Main.qml" 2>&1) ||
    fail "agents Main.qml passes qmllint" "$lint"
  pass "agents Main.qml passes qmllint"
fi

qml_dom=""
if [[ -x /usr/lib/qt6/bin/qmldom ]]; then
  qml_dom=/usr/lib/qt6/bin/qmldom
elif command -v qmldom >/dev/null 2>&1; then
  qml_dom=$(command -v qmldom)
fi
if [[ -z $qml_dom ]]; then
  skip "qmldom is not installed; QML syntax parse did not run"
else
  ast_err=$(mktemp)
  for src in shell/plugins/agents/Main.qml shell/plugins/agents/Panel.qml shell/shell.qml; do
    if ! "$qml_dom" --dump-ast "$ROOT/$src" >/dev/null 2>"$ast_err"; then
      detail=$(cat "$ast_err")
      rm -f "$ast_err"
      fail "QML syntax parse of $src" "$detail"
    fi
    if [[ -s $ast_err ]]; then
      detail=$(cat "$ast_err")
      rm -f "$ast_err"
      fail "QML syntax parse of $src" "$detail"
    fi
  done
  rm -f "$ast_err"
  pass "agents QML and the shell settings writer parse"
fi

# A real normal updater can start after the initial quiet wait, including
# when restoring settings starts a refresh. Hold the real Codex cache flock
# at each copy/move boundary: refusal must keep the captured backup, and only
# a genuinely settled retry may remove it. No collector body is replaced.
if ! command -v bwrap >/dev/null 2>&1; then
  skip "bwrap is not installed; real updater restore interval regression did not run"
elif ! bwrap --unshare-all --ro-bind / / /usr/bin/true >/dev/null 2>&1; then
  skip "isolated namespaces are unavailable; real updater restore interval regression did not run"
else
  rm -rf "$agents_restore_fixture"
  agents_restore_fixture=$(mktemp -d)
  cat >"$agents_restore_fixture/restore-interval-test.py" <<'PY'
import fcntl
import hashlib
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import stat
import subprocess
import time

fixture = Path('/tmp/fixture')
expected_home = os.environ['HOME']

def snapshot(path):
    if not os.path.lexists(path):
        return None
    info = os.lstat(path)
    result = {'type': stat.S_IFMT(info.st_mode), 'mode': stat.S_IMODE(info.st_mode)}
    if stat.S_ISLNK(info.st_mode):
        result['target'] = os.readlink(path)
    elif stat.S_ISDIR(info.st_mode):
        result['entries'] = {name: snapshot(path / name) for name in sorted(os.listdir(path))}
    elif stat.S_ISREG(info.st_mode):
        result['sha256'] = hashlib.sha256(path.read_bytes()).hexdigest()
    else:
        raise AssertionError('unexpected fixture type')
    return result

def live_snapshot(case):
    return [snapshot(case / 'config/omarchy/shell.json'),
            snapshot(case / 'state/omarchy/agents/usage'),
            snapshot(case / 'cache/omarchy/agent-usage')]

def backup_snapshot(backup):
    return [snapshot(backup / 'shell.json'), snapshot(backup / 'usage'), snapshot(backup / 'cache')]

def wait_marker(case, name, process):
    deadline = time.monotonic() + 15
    while not (case / name).exists():
        if process.poll() is not None or time.monotonic() >= deadline:
            output, error = process.communicate(timeout=5)
            raise AssertionError('restore runner did not reach ' + name + '\n' + output + error)
        time.sleep(0.02)

def wait_real_cache_lock(process):
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        assert process.poll() is None, 'restore runner exited before the actual collector reached its lock'
        for entry in Path('/proc').iterdir():
            if not entry.name.isdecimal():
                continue
            try:
                argv = (entry / 'cmdline').read_bytes().split(b'\0')
                if not any(arg.endswith(b'/omarchy-agent-usage-codex') for arg in argv):
                    continue
                if 'lock' in (entry / 'wchan').read_text():
                    return int(entry.name)
            except FileNotFoundError:
                continue
        time.sleep(0.02)
    raise AssertionError('actual normal updater collector did not reach the real cache flock')

runner_source = '''#!/bin/bash
set -euo pipefail
source /mnt/test/acceptance.d/agents-providers-test.sh
unset AGENTS_PROVIDER_COLLECTOR_PROBE
AGENTS_PROVIDER_COLLECTOR_WAIT=3
omarchy-shell() { return 0; }
prepare_agents_settings_restore
backup=$agents_provider_backup
printf '%s\\n' "$backup" >"$CASE/backup-path"
printf '%s\\n' "$agents_provider_shell_existed $agents_provider_usage_existed $agents_provider_cache_existed $agents_provider_capture_complete" >"$CASE/captured-flags"
touch "$CASE/prepared"
while [[ ! -e $CASE/dirty-ready ]]; do sleep 0.02; done
arm_boundary=1
writer_pid=""
start_normal_updater() {
  [[ $arm_boundary == 1 && -z $writer_pid ]] || return 0
  # Coordination-loss protocol: keep every original actual copy/move trigger
  # and refusal assertion, but explicitly surrender this fixture's owned
  # lease so its real collector can reach the existing cache-flock milestone.
  # Production cleanup holds the lease; the appended cases verify that path.
  agents_provider_gate_release
  touch "$CASE/boundary-reached"
  while [[ ! -e $CASE/lock-ready ]]; do sleep 0.02; done
  /mnt/bin/omarchy-agent-usage-update >"$CASE/updater.out" 2>"$CASE/updater.err" &
  writer_pid=$!
  printf '%s\\n' "$writer_pid" >"$CASE/writer-pid"
  touch "$CASE/updater-started"
  while [[ ! -e $CASE/collector-blocked ]]; do sleep 0.02; done
}
cp() {
  command cp "$@"
  local status=$? snapshot=${@: -2:1}
  ((status == 0)) || return "$status"
  if [[ $BOUNDARY == stage-shell && $snapshot == "$backup/shell.json" ||
        $BOUNDARY == stage-usage && $snapshot == "$backup/usage" ||
        $BOUNDARY == stage-cache && $snapshot == "$backup/cache" ]]; then
    start_normal_updater
  fi
  return 0
}
mv() {
  command mv "$@"
  local status=$? dest=${@: -1}
  ((status == 0)) || return "$status"
  if [[ $BOUNDARY == commit-shell && $dest == "$agents_provider_shell_json" ||
        $BOUNDARY == commit-usage && $dest == "$agents_provider_usage_dir" ||
        $BOUNDARY == commit-cache && $dest == "$agents_provider_cache_dir" ]]; then
    start_normal_updater
  fi
  return 0
}
python3() {
  command python3 "$@"
  local status=$?
  ((status == 0)) || return "$status"
  if [[ $BOUNDARY == verified-cache && $# == 4 && ${4} == "$agents_provider_cache_dir" ]]; then
    start_normal_updater
    # This writer finishes between the first exact comparison and the quiet
    # observation. A quiet process table alone cannot prove the bytes match.
    wait "$writer_pid"
  fi
  return 0
}
status=0
restore_agents_settings || status=$?
arm_boundary=0
[[ -n $writer_pid ]] || { echo 'not ok - restore boundary starts the actual normal updater'; exit 1; }
[[ $status != 0 ]] || { echo 'not ok - restore refuses an actual updater started after its initial wait'; exit 1; }
if [[ $BOUNDARY == verified-cache ]]; then
  ! agents_provider_collectors_active
else
  command kill -0 "$writer_pid"
  agents_provider_collectors_active
fi
[[ $agents_provider_backup == "$backup" && -d $backup && $agents_provider_capture_complete == 1 ]]
printf '%s\\n' "$agents_provider_shell_existed $agents_provider_usage_existed $agents_provider_cache_existed $agents_provider_capture_complete" >"$CASE/refused-flags"
touch "$CASE/refused"
while [[ ! -e $CASE/release ]]; do sleep 0.02; done
wait "$writer_pid"
touch "$CASE/updater-finished"
while [[ ! -e $CASE/writer-checked ]]; do sleep 0.02; done
unset -f cp mv python3
AGENTS_PROVIDER_COLLECTOR_WAIT=3
restore_agents_settings
[[ -z ${agents_provider_backup:-} && ! -d $backup ]]
! agents_provider_collectors_active
touch "$CASE/restored"
'''

boundaries = ['stage-shell', 'stage-usage', 'stage-cache', 'commit-usage', 'commit-cache', 'commit-shell', 'verified-cache']
for number, boundary in enumerate(boundaries):
    case = fixture / boundary
    for name in ['config', 'state', 'cache', 'data', 'tmp', 'omarchy/bin']:
        (case / name).mkdir(parents=True)
    env = os.environ.copy()
    env.update({
        'XDG_CONFIG_HOME': str(case / 'config'), 'XDG_STATE_HOME': str(case / 'state'),
        'XDG_CACHE_HOME': str(case / 'cache'), 'XDG_DATA_HOME': str(case / 'data'),
        'TMPDIR': str(case / 'tmp'), 'OMARCHY_PATH': str(case / 'omarchy'),
        'CASE': str(case), 'BOUNDARY': boundary,
    })
    os.environ.update({key: env[key] for key in ['XDG_CONFIG_HOME', 'XDG_STATE_HOME', 'XDG_CACHE_HOME', 'XDG_DATA_HOME', 'TMPDIR']})
    loader = importlib.machinery.SourceFileLoader('codex_restore_' + str(number), '/mnt/bin/omarchy-agent-usage-codex')
    spec = importlib.util.spec_from_loader(loader.name, loader)
    collector = importlib.util.module_from_spec(spec)
    loader.exec_module(collector)
    cache_file, lock_file = collector.scan_cache_paths()
    cache_file.write_text('{"marker":"captured-cache"}\n')
    cache_file.chmod(0o600)
    lock_file.write_text('captured-lock\n')
    lock_file.chmod(0o600)
    usage = case / 'state/omarchy/agents/usage'
    usage.mkdir(parents=True)
    usage.chmod(0o750)
    (usage / 'codex.json').write_text('{"id":"codex","marker":"captured-usage"}\n')
    (usage / 'codex.json').chmod(0o600)
    (usage / 'nested').mkdir(mode=0o700)
    (usage / 'nested/kept').write_text('captured-nested')
    (usage / 'nested/kept').chmod(0o640)
    (usage / 'link').symlink_to('nested/kept')
    settings = case / 'config/omarchy/shell.json'
    settings.parent.mkdir(parents=True)
    settings.write_text('{"marker":"captured-settings"}\n')
    settings.chmod(0o640)
    (case / 'omarchy/bin/omarchy-agent-usage-codex').symlink_to('/mnt/bin/omarchy-agent-usage-codex')
    original = live_snapshot(case)
    runner = case / 'runner.sh'
    runner.write_text(runner_source)
    process = subprocess.Popen(['/bin/bash', str(runner)], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    lock = None
    try:
        wait_marker(case, 'prepared', process)
        backup = Path((case / 'backup-path').read_text().strip())
        assert backup_snapshot(backup) == original, 'fixture must capture exact original existence, types, bytes and modes'
        settings.write_text('dirty-settings')
        (usage / 'codex.json').write_text('dirty-usage')
        (usage / 'extra').write_text('dirty-extra')
        cache_file.write_text('{"marker":"dirty-cache"}\n')
        (case / 'dirty-ready').touch()
        wait_marker(case, 'boundary-reached', process)
        lock = lock_file.open('a')
        fcntl.flock(lock, fcntl.LOCK_EX)
        (case / 'lock-ready').touch()
        wait_marker(case, 'updater-started', process)
        collector_pid = wait_real_cache_lock(process)
        (case / 'collector-blocked').touch()
        if boundary == 'verified-cache':
            fcntl.flock(lock, fcntl.LOCK_UN)
            lock.close()
            lock = None
        wait_marker(case, 'refused', process)
        writer_pid = int((case / 'writer-pid').read_text())
        if boundary != 'verified-cache':
            os.kill(writer_pid, 0)
            os.kill(collector_pid, 0)
        assert backup_snapshot(backup) == original, 'busy restore must retain the complete original backup'
        assert (case / 'captured-flags').read_bytes() == (case / 'refused-flags').read_bytes(), 'busy restore must retain all existence and capture flags'
        if lock is not None:
            fcntl.flock(lock, fcntl.LOCK_UN)
            lock.close()
            lock = None
        (case / 'release').touch()
        wait_marker(case, 'updater-finished', process)
        assert json.loads((usage / 'codex.json').read_text())['id'] == 'codex', 'the actual updater must write its actual normal collector record'
        assert cache_file.read_text() not in ['{"marker":"dirty-cache"}\n', '{"marker":"captured-cache"}\n'], 'the actual normal collector must write its cache after refusal'
        assert backup_snapshot(backup) == original, 'the real collector must leave the retained snapshot unchanged'
        (case / 'writer-checked').touch()
        wait_marker(case, 'restored', process)
        output, error = process.communicate(timeout=5)
        assert process.returncode == 0, output + error
        assert live_snapshot(case) == original, 'settled retry must restore exact existence, types, bytes, modes, entries and symlinks'
        assert not backup.exists(), 'only proven settled exact restoration may delete the backup'
    finally:
        if lock is not None:
            fcntl.flock(lock, fcntl.LOCK_UN)
            lock.close()
        for name in ['lock-ready', 'collector-blocked', 'release', 'writer-checked']:
            (case / name).touch()
        if process.poll() is None:
            process.communicate(timeout=15)
    print('ok - actual normal updater started during ' + boundary + ' retains the snapshot until exact settled retry')

assert os.environ['HOME'] == expected_home
PY
  mkdir -p "$agents_restore_fixture/empty-home"
  bwrap --die-with-parent --unshare-all --ro-bind / / \
    --tmpfs /home --tmpfs /tmp --tmpfs /run --proc /proc --dev /dev \
    --ro-bind "$ROOT" /mnt --bind "$agents_restore_fixture" /tmp/fixture \
    --ro-bind "$agents_restore_fixture/empty-home" "$HOME" \
    --setenv PATH /usr/bin:/bin \
    --unsetenv CODEX_HOME --unsetenv AGENTS_PROVIDER_COLLECTOR_PROBE \
    --unsetenv BASH_ENV --unsetenv ENV --unsetenv NODE_OPTIONS \
    --unsetenv DISPLAY --unsetenv WAYLAND_DISPLAY --unsetenv DBUS_SESSION_BUS_ADDRESS \
    --unsetenv HYPRLAND_INSTANCE_SIGNATURE --unsetenv XDG_RUNTIME_DIR \
    --chdir /mnt /usr/bin/python3 /tmp/fixture/restore-interval-test.py || \
    fail "actual normal updater restore interval regressions"
fi

# Keep the seven committed restore-interval cases above unchanged. Reuse
# their actual updater/collector fixture and independent snapshots for a
# writer starting in the second final raw comparison, a writer finishing
# before the following process observation, and an unreadable observation.
if ! command -v bwrap >/dev/null 2>&1; then
  skip "bwrap is not installed; final restore observation regressions did not run"
elif ! bwrap --unshare-all --ro-bind / / /usr/bin/true >/dev/null 2>&1; then
  skip "isolated namespaces are unavailable; final restore observation regressions did not run"
else
  cat >"$agents_restore_fixture/final-observation-test.py" <<'PY'
from pathlib import Path

source = Path('/mnt/test/shell.d/agents-provider-controls-test.sh').read_text()
marker = 'cat >"$agents_restore_fixture/restore-interval-test.py" <<\'PY\'\n'
program = source.split(marker, 1)[1].split('\nPY\n', 1)[0]
old_wrapper = '''python3() {
  command python3 "$@"
  local status=$?
  ((status == 0)) || return "$status"
  if [[ $BOUNDARY == verified-cache && $# == 4 && ${4} == "$agents_provider_cache_dir" ]]; then
    start_normal_updater
    # This writer finishes between the first exact comparison and the quiet
    # observation. A quiet process table alone cannot prove the bytes match.
    wait "$writer_pid"
  fi
  return 0
}'''
new_wrapper = '''python3() {
  if [[ $BOUNDARY == final-fingerprint-error && ${2:-} == --fingerprint && $cache_comparisons == 2 ]]; then
    # The observation really fails to read a directory as bytes. Its status
    # must refuse cleanup, even though the genuine updater has finished.
    touch "$CASE/actual-fingerprint-read-error"
    command python3 -c 'open("/proc", "rb").read()'
    return $?
  fi
  if [[ $# == 4 && ${2} == 1 && ${4} == "$agents_provider_cache_dir" ]]; then
    cache_comparisons=$((cache_comparisons + 1))
    if [[ $BOUNDARY == final-compare-active && $cache_comparisons == 2 ]]; then
      start_normal_updater
    fi
  fi
  command python3 "$@"
  local status=$?
  ((status == 0)) || return "$status"
  if [[ $# == 4 && ${2} == 1 && ${4} == "$agents_provider_cache_dir" && $cache_comparisons == 2 &&
        ( $BOUNDARY == final-compare-finished || $BOUNDARY == final-fingerprint-error ) ]]; then
    start_normal_updater
    wait "$writer_pid"
    # A new verified lease lets the original finished-writer/fingerprint
    # observations execute after this fixture's deliberate coordination loss.
    agents_provider_gate_acquire
  fi
  return 0
}'''
assert program.count(old_wrapper) == 1
program = program.replace(old_wrapper, new_wrapper, 1)
program = program.replace('writer_pid=""\n', 'writer_pid=""\ncache_comparisons=0\n', 1)
old_boundaries = "boundaries = ['stage-shell', 'stage-usage', 'stage-cache', 'commit-usage', 'commit-cache', 'commit-shell', 'verified-cache']"
assert program.count(old_boundaries) == 1
program = program.replace(old_boundaries, "boundaries = ['final-compare-active', 'final-compare-finished', 'final-fingerprint-error']", 1)
program = program.replace("if boundary == 'verified-cache':", "if boundary in ['final-compare-finished', 'final-fingerprint-error']:")
program = program.replace("if boundary != 'verified-cache':", "if boundary not in ['final-compare-finished', 'final-fingerprint-error']:")
program = program.replace('[[ $BOUNDARY == verified-cache ]]', '[[ $BOUNDARY == final-compare-finished || $BOUNDARY == final-fingerprint-error ]]', 1)
# A normal Codex lock is empty. A marker here lets its pre-flock open alone
# change compared bytes, which would hide the actual final-comparison race.
assert "lock_file.write_text('captured-lock\\n')" in program
program = program.replace("lock_file.write_text('captured-lock\\n')", "lock_file.write_text('')", 1)
exec(compile(program, 'committed-final-observation-fixture', 'exec'))
PY
  bwrap --die-with-parent --unshare-all --ro-bind / / \
    --tmpfs /home --tmpfs /tmp --tmpfs /run --proc /proc --dev /dev \
    --ro-bind "$ROOT" /mnt --bind "$agents_restore_fixture" /tmp/fixture \
    --ro-bind "$agents_restore_fixture/empty-home" "$HOME" \
    --setenv PATH /usr/bin:/bin \
    --unsetenv CODEX_HOME --unsetenv AGENTS_PROVIDER_COLLECTOR_PROBE \
    --unsetenv BASH_ENV --unsetenv ENV --unsetenv NODE_OPTIONS \
    --unsetenv DISPLAY --unsetenv WAYLAND_DISPLAY --unsetenv DBUS_SESSION_BUS_ADDRESS \
    --unsetenv HYPRLAND_INSTANCE_SIGNATURE --unsetenv XDG_RUNTIME_DIR \
    --chdir /mnt /usr/bin/python3 /tmp/fixture/final-observation-test.py || \
    fail "actual normal updater final restore observation regressions"
fi

# Writers that start while cleanup actually holds its lease must wait on that
# exact kernel lock. This complements the coordination-loss/refusal cases
# above; those keep their original triggers and assertions instead of pretending
# an intentionally blocked writer can reach an inner cache lock or exit first.
if ! command -v bwrap >/dev/null 2>&1; then
  skip "bwrap is not installed; writer coordination regressions did not run"
elif ! bwrap --unshare-all --ro-bind / / /usr/bin/true >/dev/null 2>&1; then
  skip "isolated namespaces are unavailable; writer coordination regressions did not run"
else
  rm -rf "$agents_restore_fixture"
  agents_restore_fixture=$(mktemp -d)
  cat >"$agents_restore_fixture/writer-gate-test.py" <<'PY'
import fcntl
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import time

fixture = Path('/tmp/fixture')
expected_home = os.environ['HOME']
source = Path('/mnt/test/shell.d/agents-provider-controls-test.sh').read_text()
marker = 'cat >"$agents_restore_fixture/restore-interval-test.py" <<\'PY\'\n'
program = source.split(marker, 1)[1].split('\nPY\n', 1)[0]
# Reuse only the independently checked filesystem snapshots, not cleanup logic.
exec(compile(program.split('runner_source = ', 1)[0], 'public-snapshot-helpers', 'exec'))

def context(name, providers):
    case = fixture / name
    for part in ['config/omarchy', 'state/omarchy/agents/usage', 'cache/omarchy/agent-usage', 'data', 'tmp', 'omarchy/bin']:
        (case / part).mkdir(parents=True)
    for provider in providers:
        (case / ('omarchy/bin/omarchy-agent-usage-' + provider)).symlink_to('/mnt/bin/omarchy-agent-usage-' + provider)
    env = os.environ.copy()
    env.update({'XDG_CONFIG_HOME': str(case / 'config'), 'XDG_STATE_HOME': str(case / 'state'),
                'XDG_CACHE_HOME': str(case / 'cache'), 'XDG_DATA_HOME': str(case / 'data'),
                'TMPDIR': str(case / 'tmp'), 'OMARCHY_PATH': str(case / 'omarchy'), 'CASE': str(case),
                'OMARCHY_ACCEPTANCE_DIR': str(case / 'evidence')})
    return case, env

def gate_waiter(case, process):
    deadline = time.monotonic() + 5
    gate = case / 'state/omarchy/agents/.usage-restore.lock'
    identity = gate.stat()
    while time.monotonic() < deadline:
        assert process.poll() is None, 'runner exited before writer blocking was verified'
        for line in Path('/proc/locks').read_text().splitlines():
            fields = line.split()
            if len(fields) < 9 or fields[1:5] != ['->', 'FLOCK', 'ADVISORY', 'READ']:
                continue
            major, minor, inode = fields[6].split(':')
            if (os.makedev(int(major, 16), int(minor, 16)), int(inode)) == (identity.st_dev, identity.st_ino):
                return int(fields[5])
        time.sleep(0.02)
    raise AssertionError('real writer did not wait on the held exclusive gate inode')

def manifest_shape(node):
    if node is None:
        return None
    result = {key: node[key] for key in ['type', 'mode']}
    if 'sha256' in node:
        result['sha256'] = node['sha256']
    if 'target' in node:
        result['target_sha256'] = hashlib.sha256(os.fsencode(node['target'])).hexdigest()
    if 'entries' in node:
        result['entries'] = {hashlib.sha256(os.fsencode(name)).hexdigest(): manifest_shape(child)
                             for name, child in node['entries'].items()}
    return result

def checkpoint_manifest(case, backup, phase, expected):
    path = case / ('evidence/agents-provider-' + backup.name + '-' + phase + '.json')
    actual = json.loads(path.read_text())
    assert actual['capture_id'] == backup.name and actual['phase'] == phase
    assert actual['paths'] == dict(zip(['shell.json', 'usage', 'cache'], map(manifest_shape, expected)))
    gate = (case / 'state/omarchy/agents/.usage-restore.lock').stat()
    assert actual['exclusive_gate'] == {'device': gate.st_dev, 'inode': gate.st_ino}
    assert path.stat().st_mode & 0o777 == 0o600
    return actual

runner_source = r'''#!/bin/bash
set -euo pipefail
source /mnt/test/acceptance.d/agents-providers-test.sh
AGENTS_PROVIDER_COLLECTOR_WAIT=3
omarchy-shell() { return 0; }
writer_pid=""
prepare_agents_settings_restore
backup=$agents_provider_backup
printf '%s\n' "$backup" >"$CASE/backup-path"
printf '%s\n' "$agents_provider_shell_existed $agents_provider_usage_existed $agents_provider_cache_existed $agents_provider_capture_complete" >"$CASE/captured-flags"
touch "$CASE/prepared"
while [[ ! -e $CASE/dirty-ready ]]; do sleep 0.02; done
arm=1
cache_comparisons=0
start_gated_writer() {
  [[ $arm == 1 && -z $writer_pid ]] || return 0
  # A controlled child must not inherit cleanup's exclusive descriptor.
  # A real desktop refresh is launched by another process, not this fixture.
  (
    exec {agents_provider_gate_fd}>&-
    exec /mnt/bin/omarchy-agent-usage-update
  ) >"$CASE/updater.out" 2>"$CASE/updater.err" &
  writer_pid=$!
  printf '%s\n' "$writer_pid" >"$CASE/writer-pid"
  touch "$CASE/updater-started"
  while [[ ! -e $CASE/gate-checked ]]; do sleep 0.02; done
}
cp() {
  command cp "$@"
  local status=$? from=${@: -2:1}
  ((status == 0)) || return "$status"
  if [[ $BOUNDARY == stage-shell && $from == "$backup/shell.json" ||
        $BOUNDARY == stage-usage && $from == "$backup/usage" ||
        $BOUNDARY == stage-cache && $from == "$backup/cache" ]]; then start_gated_writer; fi
}
mv() {
  command mv "$@"
  local status=$? dest=${@: -1}
  ((status == 0)) || return "$status"
  if [[ $BOUNDARY == commit-shell && $dest == "$agents_provider_shell_json" ||
        $BOUNDARY == commit-usage && $dest == "$agents_provider_usage_dir" ||
        $BOUNDARY == commit-cache && $dest == "$agents_provider_cache_dir" ]]; then start_gated_writer; fi
}
python3() {
  if [[ $# == 4 && ${2:-} == 1 && ${4:-} == "$agents_provider_cache_dir" ]]; then
    cache_comparisons=$((cache_comparisons + 1))
    if [[ $BOUNDARY == final-compare && $cache_comparisons == 2 ]]; then start_gated_writer; fi
  fi
  command python3 "$@"
  local status=$?
  ((status == 0)) || return "$status"
  if [[ $BOUNDARY == final-fingerprint && ${2:-} == --fingerprint && $cache_comparisons == 2 ]]; then start_gated_writer; fi
  return 0
}
release_definition=$(declare -f agents_provider_gate_release)
eval "${release_definition/agents_provider_gate_release/agents_provider_gate_release_actual}"
agents_provider_gate_release() {
  # Fingerprint observation runs in command substitution; transfer its real PID.
  if [[ -z $writer_pid && -f $CASE/writer-pid ]]; then read -r writer_pid <"$CASE/writer-pid"; fi
  if [[ -n $writer_pid && -n ${agents_provider_gate_fd:-} ]]; then
    agents_provider_gate_held
    command cp -a "$agents_provider_shell_json" "$CASE/checkpoint-shell"
    command cp -a "$agents_provider_usage_dir" "$CASE/checkpoint-usage"
    command cp -a "$agents_provider_cache_dir" "$CASE/checkpoint-cache"
    [[ -z ${agents_provider_backup:-} && ! -d $backup ]]
    command kill -0 "$writer_pid"
    touch "$CASE/locked-checkpoint"
    while [[ ! -e $CASE/release-checked ]]; do sleep 0.02; done
  fi
  agents_provider_gate_release_actual
}
restore_agents_settings
arm=0
[[ -n $writer_pid && -z ${agents_provider_backup:-} && ! -d $backup ]]
if [[ $BOUNDARY == final-fingerprint ]]; then
  while command kill -0 "$writer_pid" 2>/dev/null && [[ $(sed -n 's/.*) \([A-Z]\).*/\1/p' "/proc/$writer_pid/stat" 2>/dev/null) != Z ]]; do sleep 0.02; done
else
  wait "$writer_pid"
fi
touch "$CASE/finished"
'''

for boundary in ['stage-shell', 'stage-usage', 'stage-cache', 'commit-usage', 'commit-cache', 'commit-shell', 'final-compare', 'final-fingerprint']:
    case, env = context(boundary, ['codex'])
    env['BOUNDARY'] = boundary
    subprocess.run(['/mnt/bin/omarchy-agent-usage-update'], env=env, check=True, capture_output=True, timeout=10)
    settings = case / 'config/omarchy/shell.json'
    settings.write_text('{"version":1,"marker":"captured"}\n')
    settings.chmod(0o640)
    usage = case / 'state/omarchy/agents/usage'
    usage.chmod(0o750)
    (usage / 'nested').mkdir(mode=0o700)
    (usage / 'nested/kept').write_text('captured')
    (usage / 'link').symlink_to('nested/kept')
    original = live_snapshot(case)
    runner = case / 'runner.sh'
    runner.write_text(runner_source)
    process = subprocess.Popen(['/bin/bash', str(runner)], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        wait_marker(case, 'prepared', process)
        backup = Path((case / 'backup-path').read_text().strip())
        assert backup_snapshot(backup) == original
        checkpoint_manifest(case, backup, 'captured', original)
        settings.write_text('dirty-settings')
        (usage / 'codex.json').write_text('dirty-usage')
        (usage / 'extra').write_text('dirty-extra')
        (case / 'dirty-ready').touch()
        wait_marker(case, 'updater-started', process)
        blocked = gate_waiter(case, process)
        os.kill(blocked, 0)
        (case / 'gate-checked').touch()
        wait_marker(case, 'locked-checkpoint', process)
        assert not backup.exists(), 'exact completion may remove backup while the exclusive lease still holds'
        checkpoint_manifest(case, backup, 'restored', original)
        checkpoint = [snapshot(case / 'checkpoint-shell'), snapshot(case / 'checkpoint-usage'), snapshot(case / 'checkpoint-cache')]
        assert checkpoint == original, 'every path is exact before lease release, including modes, entries and symlinks'
        assert live_snapshot(case) == original, 'real writer remains excluded from the live transaction'
        gate_waiter(case, process)
        (case / 'release-checked').touch()
        output, error = process.communicate(timeout=10)
        assert process.returncode == 0, output + error
        assert (case / 'finished').exists()
        final_record = json.loads((usage / 'codex.json').read_text())
        assert final_record['id'] == 'codex'
        assert snapshot(usage / 'codex.json') != original[1]['entries']['codex.json'], 'future normal usage publication is allowed after lease release'
        assert snapshot(case / 'cache/omarchy/agent-usage') == original[2], 'warm normal Codex cache hit publishes usage only'
    finally:
        for name in ['dirty-ready', 'gate-checked', 'release-checked']:
            (case / name).touch()
        if process.poll() is None:
            process.communicate(timeout=15)
    print('ok - actual warm normal updater is excluded during ' + boundary + ' until exact restored checkpoint and lease release')

# Direct CLI entrypoints participate too, before any protected cache mutation.
for provider in ['claude', 'codex', 'grok']:
    case, env = context('direct-' + provider, [provider])
    gate = case / 'state/omarchy/agents/.usage-restore.lock'
    lock = gate.open('a+')
    fcntl.flock(lock, fcntl.LOCK_EX)
    cache = case / 'cache/omarchy/agent-usage'
    (cache / 'sentinel').write_text('original-cache')
    original = snapshot(cache)
    process = subprocess.Popen(['/mnt/bin/omarchy-agent-usage-' + provider], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        blocked = gate_waiter(case, process)
        assert blocked == process.pid, 'direct actual collector itself is the kernel gate waiter'
        assert snapshot(cache) == original, 'direct collector does not mutate cache while excluded'
        probe = subprocess.run(['/usr/bin/python3', '/mnt/lib/omarchy_agent_usage_gate.py', '--blocked', str(process.pid), str(lock.fileno())], env=env, pass_fds=(lock.fileno(),), capture_output=True)
        assert probe.returncode == 0, 'actual shared observation proves the blocked PID on the held inode'
        fcntl.flock(lock, fcntl.LOCK_UN)
        output, error = process.communicate(timeout=10)
        assert process.returncode == 0, error
        assert json.loads(output)['id'] == provider
        assert snapshot(cache) != original, 'direct real collector writes only after exclusion is released'
    finally:
        fcntl.flock(lock, fcntl.LOCK_UN)
        lock.close()
        if process.poll() is None:
            process.communicate(timeout=15)
    print('ok - direct actual ' + provider + ' cache writer blocks on the same exclusive lease before mutations')

# The updater's outer shared descriptor and direct collectors' nested shared
# acquisitions must not deadlock normal parallel collection or lose exclusions.
case, env = context('nested-normal', ['claude', 'codex', 'grok'])
subprocess.run(['/mnt/bin/omarchy-agent-usage-update'], env=env, check=True, capture_output=True, timeout=15)
usage = case / 'state/omarchy/agents/usage'
assert {p.stem for p in usage.glob('*.json')} == {'claude', 'codex', 'grok'}
for provider in ['claude', 'codex', 'grok']:
    assert json.loads((usage / (provider + '.json')).read_text())['id'] == provider
codex_usage = (usage / 'codex.json').read_bytes()
codex_cache = {p.name: snapshot(p) for p in (case / 'cache/omarchy/agent-usage').glob('codex-*')}
subprocess.run(['/mnt/bin/omarchy-agent-usage-update', '--limits-only', '--except', 'codex'], env=env, check=True, capture_output=True, timeout=15)
assert (usage / 'codex.json').read_bytes() == codex_usage
assert {p.name: snapshot(p) for p in (case / 'cache/omarchy/agent-usage').glob('codex-*')} == codex_cache
print('ok - actual nested shared updater and all direct cache writers complete while exclusions preserve Codex bytes')

# Retain exact originals and flags through real gate/probe/evidence failures.
# These runners only inject actual filesystem failures or the documented
# unknown-status seam; the committed cleanup and collector bodies run unchanged.
def refusal_case(name, setup='', first='', clear='', expected_live='dirty', observe_writer=False, denied_writers=False):
    case, env = context(name, ['claude', 'codex', 'grok'])
    settings = case / 'config/omarchy/shell.json'
    settings.write_text('{"marker":"original"}\n')
    settings.chmod(0o640)
    usage = case / 'state/omarchy/agents/usage'
    usage.chmod(0o750)
    (usage / 'kept').write_text('original-usage')
    (usage / 'link').symlink_to('kept')
    (case / 'cache/omarchy/agent-usage/kept').write_text('original-cache')
    original = live_snapshot(case)
    fault = case / 'probe-fault.py'
    fault.write_text("import runpy\nfrom pathlib import Path\nread = Path.read_text\ndef fail(self, *args, **kwargs):\n if str(self) == '/proc/locks' or ('fdinfo' in str(self) and 'fdinfo' in __import__('sys').argv):\n  with open('/proc', 'rb') as stream: return stream.read()\n return read(self, *args, **kwargs)\nPath.read_text = fail\nrunpy.run_path('/mnt/lib/omarchy_agent_usage_gate.py', run_name='__main__')\n")
    # The fdinfo variant fails a real directory read in actual lease validation.
    fd_fault = case / 'fd-fault.py'
    fd_fault.write_text(fault.read_text().replace("('fdinfo' in str(self) and 'fdinfo' in __import__('sys').argv)", "'fdinfo' in str(self)"))
    runner = case / 'runner.sh'
    runner.write_text(r'''#!/bin/bash
set -euo pipefail
source /mnt/test/acceptance.d/agents-providers-test.sh
AGENTS_PROVIDER_COLLECTOR_WAIT=3
omarchy-shell() { return 0; }
prepare_agents_settings_restore
backup=$agents_provider_backup
printf '%s\n' "$backup" >"$CASE/backup-path"
printf '%s\n' "$agents_provider_shell_existed $agents_provider_usage_existed $agents_provider_cache_existed $agents_provider_capture_complete" >"$CASE/captured-flags"
touch "$CASE/prepared"
while [[ ! -e $CASE/dirty-ready ]]; do sleep 0.02; done
''' + setup + r'''
if restore_agents_settings; then echo 'fault was accepted' >&2; exit 99; fi
''' + first + r'''
[[ $agents_provider_backup == "$backup" && -d $backup && $agents_provider_capture_complete == 1 ]]
printf '%s\n' "$agents_provider_shell_existed $agents_provider_usage_existed $agents_provider_cache_existed $agents_provider_capture_complete" >"$CASE/refused-flags"
[[ -z ${agents_provider_gate_fd:-} ]]
touch "$CASE/refused"
while [[ ! -e $CASE/retry ]]; do sleep 0.02; done
''' + clear + r'''
source /mnt/test/acceptance.d/agents-providers-test.sh
unset AGENTS_PROVIDER_COLLECTOR_PROBE
restore_agents_settings
[[ -z $agents_provider_backup && ! -d $backup ]]
touch "$CASE/finished"
''')
    process = subprocess.Popen(['/bin/bash', str(runner)], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        wait_marker(case, 'prepared', process)
        backup = Path((case / 'backup-path').read_text().strip())
        checkpoint_manifest(case, backup, 'captured', original)
        settings.write_text('dirty-settings')
        (usage / 'kept').write_text('dirty-usage')
        (usage / 'extra').write_text('dirty-extra')
        (case / 'cache/omarchy/agent-usage/kept').write_text('dirty-cache')
        dirty = live_snapshot(case)
        (case / 'dirty-ready').touch()
        if observe_writer:
            wait_marker(case, 'updater-started', process)
            gate_waiter(case, process)
            (case / 'gate-checked').touch()
        wait_marker(case, 'refused', process)
        assert backup_snapshot(backup) == original
        assert (case / 'captured-flags').read_bytes() == (case / 'refused-flags').read_bytes()
        if expected_live is not None:
            assert live_snapshot(case) == (original if expected_live == 'original' else dirty)
        if denied_writers:
            unchanged = live_snapshot(case)
            for command in ['/mnt/bin/omarchy-agent-usage-update'] + ['/mnt/bin/omarchy-agent-usage-' + provider for provider in ['claude', 'codex', 'grok']]:
                result = subprocess.run([command], env=env, capture_output=True, timeout=5)
                assert result.returncode != 0, 'actual writer must refuse the unreadable stable gate'
                assert live_snapshot(case) == unchanged, 'shared acquisition failure happens before every protected mutation'
        (case / 'retry').touch()
        output, error = process.communicate(timeout=15)
        assert process.returncode == 0, output + error
        assert not backup.exists() and live_snapshot(case) == original
        checkpoint_manifest(case, backup, 'restored', original)
    finally:
        for marker in ['dirty-ready', 'gate-checked', 'retry']:
            (case / marker).touch()
        if process.poll() is None:
            process.communicate(timeout=15)
    return case

refusal_case('lost-exclusive-without-writer', setup=r'''
definition=$(declare -f agents_provider_gate_acquire)
eval "${definition/agents_provider_gate_acquire/agents_provider_gate_acquire_actual}"
agents_provider_gate_acquire() {
  agents_provider_gate_acquire_actual || return 1
  flock --unlock "$agents_provider_gate_fd"
  local status=0
  command python3 "$agents_provider_gate_helper" --held "$agents_provider_gate_fd" || status=$?
  [[ $status == 1 ]]
}
''')
print('ok - actual lost exclusive lease without any live writer refuses capture restore and retains exact backup for retry')

refusal_case('exclusive-observation-read-failure', setup='agents_provider_gate_helper="$CASE/fd-fault.py"')
print('ok - actual exclusive FD observation read error refuses and retains the backup without leaking the lease')

refusal_case('shared-and-exclusive-open-failure', setup='chmod 000 "$XDG_STATE_HOME/omarchy/agents/.usage-restore.lock"', clear='chmod 600 "$XDG_STATE_HOME/omarchy/agents/.usage-restore.lock"', denied_writers=True)
print('ok - actual shared and exclusive gate open failures refuse all normal writers and preserve backup until settled retry')

refusal_case('unknown-probe-under-exclusive', setup=r'''
printf '#!/bin/bash\nexit 2\n' >"$CASE/unknown-probe"
chmod +x "$CASE/unknown-probe"
AGENTS_PROVIDER_COLLECTOR_PROBE=$CASE/unknown-probe
''')
print('ok - unknown collector probe status under exclusive remains active and retains the backup')

refusal_case('blocked-writer-observation-error', setup=r'''
writer_pid=""
cp() {
  command cp "$@"
  local from=${@: -2:1}
  if [[ $from == "$backup/shell.json" && -z $writer_pid ]]; then
    ( exec {agents_provider_gate_fd}>&-; exec /mnt/bin/omarchy-agent-usage-codex ) >"$CASE/writer.out" 2>"$CASE/writer.err" &
    writer_pid=$!
    touch "$CASE/updater-started"
    while [[ ! -e $CASE/gate-checked ]]; do sleep 0.02; done
    agents_provider_gate_helper=$CASE/probe-fault.py
  fi
}
''', first='wait "$writer_pid"', expected_live=None, observe_writer=True)
print('ok - actual gate-blocked direct writer with unreadable kernel waiter evidence remains active and retains backup for settled retry')

refusal_case('requested-manifest-write-failure', setup=r'''
manifest_definition=$(declare -f agents_provider_manifest)
eval "${manifest_definition/agents_provider_manifest/agents_provider_manifest_actual}"
agents_provider_manifest() {
  if [[ $1 == restored ]]; then chmod 000 "$OMARCHY_ACCEPTANCE_DIR"; fi
  agents_provider_manifest_actual "$@"
}
''', clear='chmod 700 "$OMARCHY_ACCEPTANCE_DIR"', expected_live='original')
print('ok - requested restored checkpoint manifest I/O failure retains backup and exact restored paths until settled retry')

refusal_case('manifest-inside-protected-tree', setup='OMARCHY_ACCEPTANCE_DIR="$agents_provider_usage_dir/evidence"', clear='OMARCHY_ACCEPTANCE_DIR="$CASE/evidence"')
print('ok - acceptance evidence destination inside a replaced tree refuses without modifying dirty paths or original backup')

# An ungated unknown parent is not excluded merely because its only child is
# a gate waiter. The normal updater identity is required by the live probe.
case, env = context('unknown-parent-with-blocked-child', ['codex'])
gate = case / 'state/omarchy/agents/.usage-restore.lock'
with gate.open('a+') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    parent = case / 'omarchy-agent-usage-unknown'
    parent.write_text('#!/bin/bash\n/mnt/bin/omarchy-agent-usage-codex\n')
    process = subprocess.Popen(['/bin/bash', str(parent)], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    gate_waiter(case, process)
    probe = subprocess.run(['/usr/bin/python3', '/mnt/lib/omarchy_agent_usage_gate.py', '--blocked', str(process.pid), str(lock.fileno())], env=env, pass_fds=(lock.fileno(),), capture_output=True)
    assert probe.returncode == 1, 'unknown live parent is not a proven blocked normal updater'
    fcntl.flock(lock, fcntl.LOCK_UN)
    process.communicate(timeout=10)
    assert process.returncode == 0
print('ok - unknown ungated collector parent with a real blocked child stays active')

case, env = context('absent-paths-held-writer', ['codex'])
for path in [case / 'state/omarchy/agents/usage', case / 'cache/omarchy/agent-usage']:
    path.rmdir()
assert live_snapshot(case) == [None, None, None]
runner = case / 'runner.sh'
runner.write_text(r'''#!/bin/bash
set -euo pipefail
source /mnt/test/acceptance.d/agents-providers-test.sh
AGENTS_PROVIDER_COLLECTOR_WAIT=3
omarchy-shell() { return 0; }
prepare_agents_settings_restore
backup=$agents_provider_backup
printf '%s\n' "$backup" >"$CASE/backup-path"
touch "$CASE/prepared"
while [[ ! -e $CASE/dirty-ready ]]; do sleep 0.02; done
commit_definition=$(declare -f agents_provider_commit_restore)
eval "${commit_definition/agents_provider_commit_restore/agents_provider_commit_restore_actual}"
agents_provider_commit_restore() {
  agents_provider_commit_restore_actual "$@" || return 1
  if [[ $3 == "$agents_provider_shell_json" ]]; then
    ( exec {agents_provider_gate_fd}>&-; exec /mnt/bin/omarchy-agent-usage-update ) >"$CASE/writer.out" 2>"$CASE/writer.err" &
    writer_pid=$!
    touch "$CASE/updater-started"
    while [[ ! -e $CASE/gate-checked ]]; do sleep 0.02; done
  fi
}
release_definition=$(declare -f agents_provider_gate_release)
eval "${release_definition/agents_provider_gate_release/agents_provider_gate_release_actual}"
agents_provider_gate_release() {
  [[ -z $agents_provider_backup && ! -d $backup ]]
  agents_provider_gate_held
  touch "$CASE/locked-checkpoint"
  while [[ ! -e $CASE/release-checked ]]; do sleep 0.02; done
  agents_provider_gate_release_actual
}
restore_agents_settings
wait "$writer_pid"
''')
process = subprocess.Popen(['/bin/bash', str(runner)], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
try:
    wait_marker(case, 'prepared', process)
    backup = Path((case / 'backup-path').read_text().strip())
    checkpoint_manifest(case, backup, 'captured', [None, None, None])
    (case / 'config/omarchy/shell.json').write_text('dirty-settings')
    for path in [case / 'state/omarchy/agents/usage', case / 'cache/omarchy/agent-usage']:
        path.mkdir()
        (path / 'dirty').write_text('dirty')
    (case / 'dirty-ready').touch()
    wait_marker(case, 'updater-started', process)
    gate_waiter(case, process)
    (case / 'gate-checked').touch()
    wait_marker(case, 'locked-checkpoint', process)
    assert live_snapshot(case) == [None, None, None] and not backup.exists()
    checkpoint_manifest(case, backup, 'restored', [None, None, None])
    gate_waiter(case, process)
    (case / 'release-checked').touch()
    output, error = process.communicate(timeout=15)
    assert process.returncode == 0, output + error
    assert json.loads((case / 'state/omarchy/agents/usage/codex.json').read_text())['id'] == 'codex'
finally:
    for marker in ['dirty-ready', 'gate-checked', 'release-checked']:
        (case / marker).touch()
    if process.poll() is None:
        process.communicate(timeout=15)
print('ok - originally absent settings usage and cache stay absent through exact exclusive checkpoint while a real future updater waits')

case, env = context('capture-manifest-io-failure', ['codex'])
(case / 'config/omarchy/shell.json').write_text('{"marker":"original"}\n')
(case / 'state/omarchy/agents/usage/kept').write_text('original-usage')
(case / 'cache/omarchy/agent-usage/kept').write_text('original-cache')
(case / 'evidence').mkdir(mode=0o700)
(case / 'evidence').chmod(0o000)
original = live_snapshot(case)
runner = case / 'runner.sh'
runner.write_text(r'''#!/bin/bash
set -euo pipefail
source /mnt/test/acceptance.d/agents-providers-test.sh
AGENTS_PROVIDER_COLLECTOR_WAIT=3
omarchy-shell() { return 0; }
if prepare_agents_settings_restore; then exit 99; fi
backup=$agents_provider_backup
[[ -d $backup && $agents_provider_capture_complete == 1 && -z ${agents_provider_gate_fd:-} ]]
printf '%s\n' "$backup" >"$CASE/backup-path"
touch "$CASE/refused"
while [[ ! -e $CASE/retry ]]; do sleep 0.02; done
chmod 700 "$OMARCHY_ACCEPTANCE_DIR"
restore_agents_settings
[[ -z $agents_provider_backup && ! -d $backup ]]
''')
process = subprocess.Popen(['/bin/bash', str(runner)], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
try:
    wait_marker(case, 'refused', process)
    backup = Path((case / 'backup-path').read_text().strip())
    assert backup_snapshot(backup) == original and live_snapshot(case) == original
    (case / 'retry').touch()
    output, error = process.communicate(timeout=15)
    assert process.returncode == 0, output + error
    assert not backup.exists() and live_snapshot(case) == original
    checkpoint_manifest(case, backup, 'captured', original)
    checkpoint_manifest(case, backup, 'restored', original)
finally:
    (case / 'retry').touch()
    if process.poll() is None:
        process.communicate(timeout=15)
print('ok - requested capture manifest I/O failure preserves a complete original snapshot and retry emits exact evidence before deletion')

# Linux shared flock acquisition must admit the normal updater's nested shared
# children while an exclusive cleanup owner is already waiting on the inode.
case, env = context('nested-shared-with-exclusive-waiter', ['claude', 'codex', 'grok'])
gate = case / 'state/omarchy/agents/.usage-restore.lock'
with gate.open('a+') as shared:
    fcntl.flock(shared, fcntl.LOCK_SH)
    owner = subprocess.Popen(['/usr/bin/flock', '--exclusive', str(gate), '/usr/bin/cat'], env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    deadline = time.monotonic() + 3
    while True:
        assert owner.poll() is None
        lines = Path('/proc/locks').read_text().splitlines()
        if any(line.split()[1:6] == ['->', 'FLOCK', 'ADVISORY', 'WRITE', str(owner.pid)] for line in lines):
            break
        assert time.monotonic() < deadline, 'actual exclusive gate owner must already be waiting'
        time.sleep(0.02)
    result = subprocess.run(['/mnt/bin/omarchy-agent-usage-update'], env=env, capture_output=True, timeout=3)
    assert result.returncode == 0, result.stderr.decode()
    for provider in ['claude', 'codex', 'grok']:
        assert json.loads((case / ('state/omarchy/agents/usage/' + provider + '.json')).read_text())['id'] == provider
    assert owner.poll() is None, 'exclusive owner cannot pass the independently held shared lease'
    fcntl.flock(shared, fcntl.LOCK_UN)
    deadline = time.monotonic() + 3
    while True:
        lines = Path('/proc/locks').read_text().splitlines()
        if any(line.split()[1:5] == ['FLOCK', 'ADVISORY', 'WRITE', str(owner.pid)] for line in lines):
            break
        assert owner.poll() is None and time.monotonic() < deadline
        time.sleep(0.02)
    owner.communicate(timeout=5)
    assert owner.returncode == 0
print('ok - actual normal updater nested shared writers complete with a real exclusive gate waiter queued and exclusive acquires after release')
assert os.environ['HOME'] == expected_home
PY
  mkdir -p "$agents_restore_fixture/empty-home"
  bwrap --die-with-parent --unshare-all --ro-bind / / \
    --tmpfs /home --tmpfs /tmp --tmpfs /run --proc /proc --dev /dev \
    --ro-bind "$ROOT" /mnt --bind "$agents_restore_fixture" /tmp/fixture \
    --ro-bind "$agents_restore_fixture/empty-home" "$HOME" \
    --setenv PATH /usr/bin:/bin \
    --unsetenv CODEX_HOME --unsetenv AGENTS_PROVIDER_COLLECTOR_PROBE \
    --unsetenv BASH_ENV --unsetenv ENV --unsetenv NODE_OPTIONS \
    --unsetenv DISPLAY --unsetenv WAYLAND_DISPLAY --unsetenv DBUS_SESSION_BUS_ADDRESS \
    --unsetenv HYPRLAND_INSTANCE_SIGNATURE --unsetenv XDG_RUNTIME_DIR \
    --chdir /mnt /usr/bin/python3 /tmp/fixture/writer-gate-test.py || \
    fail "actual writer coordination regressions"
fi


# Native lease controls read the real FD and kernel lock table. They qualify
# this test filesystem only; installed Btrfs requires its own actual run.
if ! command -v bwrap >/dev/null 2>&1; then
  skip "bwrap is not installed; native kernel lock relationship controls did not run"
elif ! bwrap --unshare-all --ro-bind / / /usr/bin/true >/dev/null 2>&1; then
  skip "isolated namespaces are unavailable; native kernel lock relationship controls did not run"
else
  rm -rf "$agents_restore_fixture"
  agents_restore_fixture=$(mktemp -d)
  cat >"$agents_restore_fixture/kernel-lock-test.py" <<'PY'
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time

sys.path.insert(0, '/mnt/lib')
import omarchy_agent_usage_gate as gate
fixture = Path('/tmp/fixture')
expected_home = os.environ['HOME']

def context(name):
    case = fixture / name
    for part in ['config', 'state/omarchy/agents', 'cache', 'data']:
        (case / part).mkdir(parents=True)
    env = os.environ.copy()
    env.update({'XDG_CONFIG_HOME': str(case / 'config'), 'XDG_STATE_HOME': str(case / 'state'),
                'XDG_CACHE_HOME': str(case / 'cache'), 'XDG_DATA_HOME': str(case / 'data')})
    return case, env

def probe(mode, handle, env, pid=None):
    argv = ['/usr/bin/python3', '/mnt/lib/omarchy_agent_usage_gate.py', mode]
    if pid is not None:
        argv.append(str(pid))
    argv.append(str(handle.fileno()))
    return subprocess.run(argv, env=env, pass_fds=(handle.fileno(),), capture_output=True, timeout=5).returncode

def wait_kernel_read(process):
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        assert process.poll() is None, 'actual collector exited before native kernel READ wait'
        table = Path('/proc/locks').read_text()
        for line in table.splitlines():
            fields = line.split()
            if len(fields) == 9 and fields[1:6] == ['->', 'FLOCK', 'ADVISORY', 'READ', str(process.pid)]:
                return table
        time.sleep(0.02)
    raise AssertionError('actual direct collector did not reach its kernel gate READ wait')

case, env = context('held-root')
foreign_case, foreign_env = context('foreign-root')
os.environ.update({name: env[name] for name in ['XDG_CONFIG_HOME', 'XDG_STATE_HOME', 'XDG_CACHE_HOME', 'XDG_DATA_HOME']})
lock_path = case / 'state/omarchy/agents/.usage-restore.lock'
foreign_path = foreign_case / 'state/omarchy/agents/.usage-restore.lock'
with lock_path.open('a+') as handle, foreign_path.open('a+') as foreign:
    fcntl.flock(handle, fcntl.LOCK_EX)
    fcntl.flock(foreign, fcntl.LOCK_EX)
    descriptor = gate.descriptor_exclusive_lock(handle.fileno())
    assert descriptor[0] == (os.fstat(handle.fileno()).st_dev, os.fstat(handle.fileno()).st_ino)
    assert descriptor[0] == (lock_path.stat().st_dev, lock_path.stat().st_ino)
    assert descriptor[1][2] == descriptor[0][1]
    assert descriptor[2] == os.getpid() and descriptor[3] == gate.process_identity(os.getpid())
    assert gate.exclusive_held(handle.fileno()) and probe('--held', handle, env) == 0
    print('ok - actual held native FD binds filesystem object separately from kernel exclusive owner and lock identity')

    writer = subprocess.Popen(['/mnt/bin/omarchy-agent-usage-codex'], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    foreign_writer = subprocess.Popen(['/mnt/bin/omarchy-agent-usage-codex'], env=foreign_env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        wait_kernel_read(writer)
        table = wait_kernel_read(foreign_writer)
        waiters = gate.kernel_root_waiters(descriptor, table)
        assert writer.pid in waiters and foreign_writer.pid not in waiters
        assert gate.blocked_on_gate(writer.pid, handle.fileno()) and probe('--blocked', handle, env, writer.pid) == 0
        print('ok - actual direct source collector READ waiter belongs to the held owner root within one real kernel observation')

        assert not gate.blocked_on_gate(foreign_writer.pid, handle.fileno())
        assert probe('--blocked', handle, env, foreign_writer.pid) == 1
        foreign_fields = [line.split() for line in table.splitlines() if line.split()[1:6] == ['->', 'FLOCK', 'ADVISORY', 'READ', str(foreign_writer.pid)]]
        own_fields = [line.split() for line in table.splitlines() if line.split()[1:6] == ['->', 'FLOCK', 'ADVISORY', 'READ', str(writer.pid)]]
        assert len(foreign_fields) == len(own_fields) == 1 and foreign_fields[0][0] != own_fields[0][0]
        print('ok - actual foreign gate READ waiter is excluded from the original held root and never quiets that collector')

        fcntl.flock(handle, fcntl.LOCK_UN)
        output, error = writer.communicate(timeout=10)
        assert writer.returncode == 0 and json.loads(output)['id'] == 'codex', error
        assert not gate.exclusive_held(handle.fileno()) and probe('--held', handle, env) == 1
        assert probe('--blocked', handle, env, foreign_writer.pid) == 2
        print('ok - actual lost exclusive lease remains lost while a foreign exclusive root and real READ waiter remain alive')

        try:
            gate.kernel_root_waiters(descriptor, Path('/proc/locks').read_text())
        except ValueError:
            pass
        else:
            raise AssertionError('departed held root was accepted from a real later kernel table')
        print('ok - an actual departed root cannot be recovered from a foreign live kernel root using stale descriptor evidence')

        fcntl.flock(handle, fcntl.LOCK_SH)
        assert gate.descriptor_exclusive_lock(handle.fileno()) is None
        assert not gate.exclusive_held(handle.fileno()) and probe('--held', handle, env) == 1
        assert probe('--blocked', handle, env, foreign_writer.pid) == 2
        print('ok - an actual shared descriptor with a live foreign waiter never supplies exclusive cleanup evidence')
    finally:
        fcntl.flock(handle, fcntl.LOCK_UN)
        fcntl.flock(foreign, fcntl.LOCK_UN)
        for process in [writer, foreign_writer]:
            if process.poll() is None:
                process.communicate(timeout=15)
assert os.environ['HOME'] == expected_home
PY
  mkdir -p "$agents_restore_fixture/empty-home"
  bwrap --die-with-parent --unshare-all --ro-bind / / \
    --tmpfs /home --tmpfs /tmp --tmpfs /run --proc /proc --dev /dev \
    --ro-bind "$ROOT" /mnt --bind "$agents_restore_fixture" /tmp/fixture \
    --ro-bind "$agents_restore_fixture/empty-home" "$HOME" \
    --setenv PATH /usr/bin:/bin \
    --unsetenv CODEX_HOME --unsetenv AGENTS_PROVIDER_COLLECTOR_PROBE \
    --unsetenv BASH_ENV --unsetenv ENV --unsetenv NODE_OPTIONS \
    --unsetenv DISPLAY --unsetenv WAYLAND_DISPLAY --unsetenv DBUS_SESSION_BUS_ADDRESS \
    --unsetenv HYPRLAND_INSTANCE_SIGNATURE --unsetenv XDG_RUNTIME_DIR \
    --chdir /mnt /usr/bin/python3 /tmp/fixture/kernel-lock-test.py || \
    fail "native actual kernel lock relationship controls"
fi
