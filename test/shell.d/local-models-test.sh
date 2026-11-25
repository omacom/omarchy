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
state.handingOff = ['model-a', 'model-b']
parse('{"models":{"model-a":{"recipe":"model-a","unit":"installing","install":{"phase":"downloading","done_bytes":5,"total_bytes":10}}}}')
assertDeepEqual(state.handingOff, ['model-b'], 'handing off clears once status.json lists the model')
JS

# The tailnet survey can be rewritten under the agents panel; models whose host is
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

// A failed setup's line is the reason's first line, not the noise above it
// or the remedy below it.
const errorMessage = new Function(main.match(/function errorMessage\([^]*?\n  \}/)[0] + '\nreturn errorMessage')()
assertEqual(errorMessage("Installing podman crun\nerror: failed retrieving file\nError: Couldn't install podman crun\nCheck your connection\n"),
  "Couldn't install podman crun", 'a failed setup shows the first line of its reason')
assertEqual(errorMessage('Traceback (most recent call last):\n  ...\n'), '', 'a setup that gave no reason leaves the line to say it failed')
JS

# The agents panel has no terminal for sudo: a detached setup missing its packages
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

# Sharing needs the SSH server other machines pair over: the agents panel's share
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

# A setup from the agents panel has its line before status.json lists it: starting,
# then installing Podman once the command says so, and a failure stays with
# its reason, while a dismissed password dialog just brings the offer back.
# One chosen while another starts waits its turn instead of being dropped.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
const names = ['setUp', 'startSetup', 'unqueueSetup', 'setupLine', 'finishSetup', 'setupRows', 'errorMessage']
const scope = { I18n: { t: key => key }, setupProcess: {} }
for (const name of names)
  scope[name] = new Function('scope', 'with (scope) { return ' + source.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))[0] + ' }')(scope)
const start = id => {
  Object.assign(scope, { settingUp: null, setupFailure: null, setupQueue: [], handingOff: [], setupOutput: '' })
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
assertDeepEqual(scope.handingOff, ['m'], 'and stays marked as handing off until status.json reloads with it')

start('m')
scope.finishSetup(126)
assertDeepEqual(scope.handingOff, [], 'a dismissed password dialog is not marked as handing off')

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

# A coding model set up here announces itself once it has loaded, and only then:
# starting one already set up is quiet, and one left stopped isn't ready.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/local-models/Models.qml', 'utf8')
const ready = []
const scope = { installingModels: {}, notifyModelReady: model => ready.push(model.recipe) }
scope.noteReadyModels = new Function('scope', 'with (scope) { return ' + source.match(/function noteReadyModels\([^]*?\n  \}/)[0] + ' }')(scope)
const model = (recipe, unit, sub_state, kind = 'text') => ({ [recipe]: { recipe, unit, sub_state, kind } })
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
scope.noteReadyModels(model('pic', 'installing', undefined, 'image'))
scope.noteReadyModels(model('pic', 'active', 'running', 'image'))
assertDeepEqual(ready, ['m'], 'an image model is not announced as ready to code')
JS

# A setup the agents panel started finishes in the background, so the service has the
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
