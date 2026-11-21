#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A rewrite may briefly leave an incomplete file; lifecycle state must survive it.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
const units = JSON.parse(source.match(/readonly property var units: (\[[^\]]*\])/)[1])
const state = { localModel: {}, units, noteReadyModels: () => {}, noteLaunchableModels: () => {}, noteSharedModels: () => {} }
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
const main = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
const localOffer = new Function(main.match(/function localOffer\([^]*?\n  \}/)[0] + '\nreturn localOffer')()
const panelSource = fs.readFileSync(root + '/shell/plugins/local-models/Panel.qml', 'utf8')
const shownLines = new Function(panelSource.match(/function shownLines\([^]*?\n  \}/)[0] + '\nreturn shownLines')()
const recipes = [{ id: 'qwen', available: true }, { id: 'nemotron', best: true, available: true }]
assertEqual(localOffer(recipes, {}).id, 'nemotron', 'a machine without local models is offered the best recipe')
assertEqual(localOffer(recipes, { qwen: { unit: 'inactive' } }), null, 'a machine with a local model gets no offer')
assertEqual(localOffer([{ id: 'nemotron', best: true, available: false }], {}), null, 'a best recipe that does not fit is not offered')
const offer = { id: 'local:nemotron', offer: {} }
assertDeepEqual(shownLines([offer, { id: 'net:box/m', model: { host: 'box' } }], ['local:nemotron', 'net:box/m']), [], 'a hidden offer or tailnet model stays hidden')
assertDeepEqual(shownLines([{ id: 'local:nemotron', model: { recipe: 'nemotron' } }], ['local:nemotron']).length, 1, 'but a model set up from a hidden offer shows')
JS

# The tailnet survey can be rewritten under the panel; models whose host is
# away keep their lines, and only a well-formed survey replaces the last one.
run_node_test <<'JS'
const fs = require('fs')
const main = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
const state = { networkModels: {}, units: JSON.parse(main.match(/readonly property var units: (\[[^\]]*\])/)[1]) }
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

const panel = fs.readFileSync(root + '/shell/plugins/local-models/Panel.qml', 'utf8')
const localActionsWith = new Function('engine', panel.match(/function localActions\([^]*?\n  \}/)[0] + '\nreturn localActions')
const localActions = (model, canShare) => localActionsWith({ canShare: !!canShare })(model)
assertDeepEqual(localActions({ recipe: 'm', unit: 'active' }, true), ['share', 'toggle', 'launch'], 'a running local model can be shared, stopped and launched')
assertDeepEqual(localActions({ recipe: 'm', unit: 'active' }, false), ['toggle', 'launch'], 'without Tailscale set up, sharing is not offered')
assertDeepEqual(localActions({ recipe: 'm', unit: 'active', shared: true }, false), ['share', 'toggle', 'launch'], 'a running shared model can always stop sharing')
assertDeepEqual(localActions({ recipe: 'm', unit: 'inactive', shared: true }, true), ['toggle'], 'a stopped shared model does not say it is shared')
assertDeepEqual(localActions({ recipe: 'm', unit: 'inactive' }, true), ['toggle'], 'a local model that has not been started is not offered for sharing')
assertDeepEqual(localActions({ recipe: 'm', unit: 'installing' }, true), [], 'a model being set up offers nothing yet')
const stale = { image: true, weights: false, settings: false }
assertDeepEqual(localActions({ recipe: 'm', unit: 'inactive', update: stale }, true), ['update', 'toggle'], 'a stopped model the catalog has moved on from offers its update')
assertDeepEqual(localActions({ recipe: 'm', unit: 'active', update: stale }, true), ['update', 'share', 'toggle', 'launch'], 'a running model offers its update before its other actions')
assertDeepEqual(localActions({ recipe: 'm', unit: 'activating', update: stale }, true), ['toggle'], 'a model that is loading does not offer its update')
assertDeepEqual(localActions({ recipe: 'm', unit: 'inactive', update: stale, updating: true }, true), ['toggle'], 'a model being updated does not offer its update again')
assertDeepEqual(localActions({ host: 'box', recipe: 'm', unit: 'active', paired: true, offline: '', update: stale }), ['disconnect', 'launch'], 'another machine\'s model is never updated from here')
const updateTip = new Function('Commons', panel.match(/function updateTip\([^]*?\n  \}/)[0] + '\nreturn updateTip')({ I18n: { t: (key) => ({ arg: (value) => key + ' ' + value, toString: () => key }), formatNumber: (value, decimals) => value.toFixed(decimals) } })
assertEqual(String(updateTip({ update: Object.assign({ download_bytes: 601000000 }, stale) })), 'localModels.updateDownloadGb 0.6', 'an update says how much it downloads')
assertEqual(String(updateTip({ update: Object.assign({ download_bytes: 42000000 }, stale) })), 'localModels.updateDownloadMb 42', 'a small update is sized in megabytes')
assertEqual(String(updateTip({ update: Object.assign({ download_bytes: null }, stale) })), 'localModels.update', 'an update not sized yet, or with nothing to fetch, names no size')
assertDeepEqual(localActions({ host: 'box', recipe: 'm', unit: 'active', paired: true, offline: '' }), ['disconnect', 'launch'], 'a paired network model launches or disconnects, never stops its host\'s model')
assertDeepEqual(localActions({ host: 'box', recipe: 'm', unit: 'inactive', paired: true, offline: '' }), [], 'a paired network model that is not running offers nothing, not even disconnecting')
assertDeepEqual(localActions({ host: 'box', recipe: 'm', unit: 'active', paired: false, offline: '' }), ['pair'], 'an unpaired network model offers pairing only')
assertDeepEqual(localActions({ host: 'away', recipe: 'm', unit: 'inactive', paired: true, offline: 'offline' }), [], 'an offline network model offers nothing until its host is back')

// A model paired from the panel that is still starting on its host has no
// terminal yet: the cursor waits for one rather than giving up.
const modelId = new Function(panel.match(/function modelId\([^]*?\n  \}/)[0] + '\nreturn modelId')()
// Opening an error's logs dismisses it: the engine forgets a model's failure after printing it, and a failed pairing, which lives in the panel, is forgotten there.
const showLocalLogs = new Function('Util', 'engine', 'root', 'pairFailure', 'modelId', panel.match(/function showLocalLogs\([^]*?\n  \}/)[0] + '\nreturn showLocalLogs')
const logRuns = [], dismissedPairs = []
const logsOf = (failure) => showLocalLogs({ shellQuote: (text) => "'" + text + "'", execArgv: (argv) => logRuns.push(argv[1]) }, { dismissPairFailure: (id) => dismissedPairs.push(id) }, { close() {} }, () => failure, modelId)
logsOf(null)({ recipe: 'm', unit: 'failed', error: 'Stopped unexpectedly' })
assertEqual(logRuns[0], "omarchy-models logs 'm'; logs=$?; omarchy-models dismiss 'm' >/dev/null 2>&1; (exit $logs)", 'a model\'s logs print its failure before it is dismissed, and keep their own status')
assertDeepEqual(dismissedPairs, [], 'a model\'s failure is the engine\'s to forget')
logsOf({ output: 'refused' })({ host: 'box', recipe: 'm', unit: 'inactive' })
assertDeepEqual(dismissedPairs, ['box/m'], 'a failed pairing is forgotten once its output has been opened')
// An image model's launch opens Fantasi on it, here or on a paired host; a text model's starts an agent.
const makesInFantasi = new Function(panel.match(/function makesInFantasi\([^]*?\n  \}/)[0] + '\nreturn makesInFantasi')()
const runLocalAction = new Function('Util', 'modelId', 'root', 'makesInFantasi', panel.match(/function runLocalAction\([^]*?\n  \}/)[0] + '\nreturn runLocalAction')
const launched = []
const launch = runLocalAction({ execArgv: argv => launched.push(argv), shellQuote: value => `'${value}'` }, modelId, { close() {} }, makesInFantasi)
launch({ recipe: 'pic', kind: 'image', unit: 'active' }, 'launch')
launch({ host: 'box', recipe: 'pic', kind: 'image', unit: 'active', paired: true, offline: '' }, 'launch')
launch({ recipe: 'clip', kind: 'video', unit: 'active' }, 'launch')
launch({ recipe: 'song', kind: 'music', unit: 'active' }, 'launch')
launch({ recipe: 'm', unit: 'active' }, 'launch')
assertDeepEqual(launched, [
  ['uwsm-app', '--', 'fantasi', 'open', '--model', 'pic'],
  ['uwsm-app', '--', 'fantasi', 'open', '--model', 'box/pic'],
  ['uwsm-app', '--', 'fantasi', 'open', '--model', 'clip'],
  ['uwsm-app', '--', 'fantasi', 'open', '--model', 'song'],
  ['omarchy-agent', '--local-model', 'm']
], 'an image, video or music model opens Fantasi on itself, a paired host\'s too, and a text model starts an agent')
assertDeepEqual(localActions({ host: 'box', recipe: 'pic', kind: 'image', unit: 'active', paired: true, offline: '' }), ['disconnect', 'launch'], 'a paired host\'s image model can be opened in Fantasi')
const landing = { landAfterPair: 'box/m', engine: { pairingId: '', pairFailures: {}, canShare: false }, root: { opened: true }, lines: [], localActions, modelId, pointed: null }
landing.pointAt = (kind, index) => { landing.pointed = [kind, index] }
const landOnPaired = new Function('scope', 'with (scope) { ' + panel.match(/function landOnPaired\([^]*?\n  \}/)[0] + '\nreturn landOnPaired }')(landing)
landing.lines = [{ model: { host: 'box', recipe: 'm', unit: 'activating', paired: true, offline: '' } }]
landOnPaired()
assert(landing.pointed === null && landing.landAfterPair === 'box/m', 'a paired model still starting keeps the cursor waiting for its terminal')
landing.lines = [{ model: { host: 'box', recipe: 'm', unit: 'active', paired: true, offline: '' } }]
landOnPaired()
assertDeepEqual(landing.pointed, ['modelLaunch', 0], 'the cursor lands on its terminal once it runs')
assertEqual(landing.landAfterPair, '', 'and stops waiting')

// A running network model shows what it is and how fast its host runs it,
// not that host's memory.
const i18n = { t: key => ({ text: key, arg(value) { this.text += '(' + value + ')'; return this }, toString() { return this.text } }), formatNumber: value => String(value) }
const remoteStats = new Function('Commons', ['contextFact', 'remoteStats'].map(name => panel.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]).join('\n') + '\nreturn remoteStats')({ I18n: i18n })
assertEqual(remoteStats({ architecture: 'moe', decode_tok_s: 41.6, prefill_tok_s: 812.2, ctx: 262144 }),
  'localModels.speedFact(42) · localModels.contextFact(256)', 'a network model lists its output speed and context, never prefill')
assertEqual(remoteStats({ architecture: 'dense', decode_tok_s: null, prefill_tok_s: null, ctx: 0 }), '', 'unmeasured speeds and an unknown context are left out, and the architecture never shows')
assertEqual(remoteStats({}), '', 'a host that reports nothing gives no stats line')
JS

# The panel has no terminal for sudo: a detached setup missing its packages
# installs them through polkit first, and otherwise starts at once.
wrapper_dir=$(mktemp -d)
trap 'rm -rf "$wrapper_dir"' EXIT
for stub in omarchy-hw-nvidia omarchy-pkg-add omarchy-local-ai omarchy-models-launchers omarchy-launch-floating-terminal-with-presentation; do
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
  PATH="$wrapper_dir:$PATH" "$ROOT/bin/omarchy-models" "$@" >/dev/null || printf 'exit %s\n' "$?" >>"$wrapper_dir/calls"
  cat "$wrapper_dir/calls"
}
echo 0 >"$wrapper_dir/pkexec-status"
calls=$(run_wrapper 0 use --detach nemotron-3.5-bolt-tensorfold)
[[ $calls == $'pkexec /usr/bin/pacman -S --noconfirm --needed -- podman crun\nomarchy-local-ai use --detach nemotron-3.5-bolt-tensorfold\nomarchy-models-launchers ' ]] || fail "a detached setup missing its packages installs them through polkit first" "$calls"
pass "a detached setup missing its packages installs them through polkit first"
echo 126 >"$wrapper_dir/pkexec-status"
calls=$(run_wrapper 0 use --detach nemotron-3.5-bolt-tensorfold)
[[ $calls == $'pkexec /usr/bin/pacman -S --noconfirm --needed -- podman crun\nexit 126' ]] || fail "a dismissed password dialog stops the setup as cancelled" "$calls"
pass "a dismissed password dialog stops the setup as cancelled"
calls=$(run_wrapper 1 use --detach nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-local-ai use --detach nemotron-3.5-bolt-tensorfold\nomarchy-models-launchers ' ]] || fail "a detached setup with its packages starts without a terminal" "$calls"
pass "a detached setup with its packages starts without a terminal"
calls=$(run_wrapper 1 use nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-pkg-add podman crun\nomarchy-local-ai use nemotron-3.5-bolt-tensorfold\nomarchy-models-launchers ' ]] || fail "a setup in a terminal installs its packages there" "$calls"
pass "a setup in a terminal installs its packages there"

# A model set up gets a launcher of its own and one removed loses it, so the
# launchers are brought up to date after either; the other commands leave them.
calls=$(run_wrapper 1 remove nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-local-ai remove nemotron-3.5-bolt-tensorfold\nomarchy-models-launchers ' ]] || fail "removing a model brings the launchers up to date" "$calls"
calls=$(run_wrapper 1 stop nemotron-3.5-bolt-tensorfold)
[[ $calls == "omarchy-local-ai stop nemotron-3.5-bolt-tensorfold" ]] || fail "stopping a model leaves the launchers alone" "$calls"
printf '#!/bin/bash\nexit 7\n' >"$wrapper_dir/omarchy-local-ai"
calls=$(run_wrapper 1 remove nemotron-3.5-bolt-tensorfold)
[[ $calls == $'omarchy-models-launchers \nexit 7' ]] || fail "a removal that fails still reports its own exit status" "$calls"
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
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
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
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
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
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
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

# A start that runs past its last duration must keep moving, never fill up.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/local-models/Panel.qml', 'utf8')
const progress = new Function(source.match(/function phaseProgress\([^]*?\n  \}/)[0] + '\nreturn phaseProgress')()
assertEqual(progress(10, 10), 0.9, 'a start reaches 90% at the time the last one took')
assert(progress(20, 10) > progress(15, 10) && progress(15, 10) > 0.9, 'a start that runs long keeps creeping')
assert(progress(1000, 10) < 0.99, 'the bar never fills before the model is ready')
JS

# The free memory the bar shows is the engine's own measure of room to load
# a model into: what the kernel can hand over, plus the GPU driver's pool.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
const parseMeminfo = new Function(source.match(/function parseMeminfo\([^]*?\n  \}/)[0] + '\nreturn parseMeminfo')()
const gib = 1024 * 1024
assertDeepEqual(parseMeminfo(`MemTotal:       ${64 * gib} kB\nMemFree:         ${2 * gib} kB\nMemAvailable:   ${20 * gib} kB\n`), { total: 64, free: 20 }, 'free memory is what is available')
assertDeepEqual(parseMeminfo(`MemTotal:       ${128 * gib} kB\nMemAvailable:   ${40 * gib} kB\nGPUReclaim:      ${8 * gib} kB\n`), { total: 128, free: 48 }, 'pages a GPU driver keeps pooled count as free, as they do when a model starts')
for (const raw of ['', 'MemTotal: 0 kB\nMemAvailable: 0 kB\n', `MemTotal: ${gib} kB\n`])
  assertEqual(parseMeminfo(raw), null, 'a reading without both totals changes nothing: ' + JSON.stringify(raw))
JS

# An update's bar runs from the press to the end in one direction: its turn,
# its download, then the old model stopping and the new one loading.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/local-models/Panel.qml', 'utf8')
const fns = ['phaseProgress', 'expectedLoadSeconds', 'expectedStopSeconds', 'updateProgress'].map(name => source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]).join('\n')
const updateProgress = new Function(fns + '\nreturn updateProgress')()
const now = 100000
const waiting = updateProgress({ updating: true, unit: 'active', update_progress: { phase: 'waiting' } }, now - 5000, now)
const half = updateProgress({ updating: true, unit: 'active', update_progress: { phase: 'downloading', done_bytes: 5, total_bytes: 10 } }, now - 5000, now)
const fetched = updateProgress({ updating: true, unit: 'active', update_progress: { phase: 'downloading', done_bytes: 10, total_bytes: 10 } }, now - 5000, now)
const stopping = updateProgress({ updating: true, unit: 'deactivating', since_ms: now - 1000, expected_stop_seconds: 2 }, now - 5000, now)
const loading = updateProgress({ updating: true, unit: 'activating', since_ms: now - 30000, expected_load_seconds: 60 }, now - 5000, now)
assert(waiting > 0 && waiting < 0.05, 'an update waiting its turn shows at once, and only a little', waiting)
assert(half > waiting && half < fetched, 'its download fills the bar by bytes', [half, fetched])
assert(fetched <= stopping && stopping < loading && loading < 1, 'the reload of a model that ran follows the download, never running back', [fetched, stopping, loading])
const blind = updateProgress({ updating: true, unit: 'active' }, now - 60000, now)
assert(blind > 0 && blind < 0.7, 'an engine that reports no download still moves the bar', blind)
JS

# The panel is offered only on a machine that can run a model itself, not on
# one whose tailnet merely shares some.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
const canRunModels = new Function(source.match(/function canRunModels\([^]*?\n  \}/)[0] + '\nreturn canRunModels')()
assertEqual(canRunModels([{ id: 'big', available: false }], {}, { state: 'none' }), false, 'a machine no recipe fits gets no panel, whatever the tailnet shares')
assertEqual(canRunModels([{ id: 'big', available: false }, { id: 'small', available: true }], {}, null), true, 'a machine one recipe fits gets the panel')
JS

# Lines keep the order they were dragged into, including places saved for lines hidden now.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
const functions = ['orderedLines', 'saveOrder'].map(name => source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0]).join('\n')
let lineOrder = ['local:b', 'net:box/m', 'hidden']
let lines = [{id: 'local:a'}, {id: 'local:b'}, {id: 'net:box/m'}]
let saved = ''
const orderFile = {setText: text => { saved = text }}
eval(functions)
lines = orderedLines(lines)
assertDeepEqual(lines.map(l => l.id), ['local:b', 'net:box/m', 'local:a'], 'saved order holds, and a line it does not name goes last')
saveOrder(['local:a', 'local:b', 'net:box/m'])
assertDeepEqual(JSON.parse(saved), ['local:a', 'local:b', 'net:box/m', 'hidden'], 'saving the order of the lines shown keeps the place of one hidden now')
JS
