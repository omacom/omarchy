#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/panels/rollcall/Model.js')

const prompt = model.parseLine('::prompt:: speakers.left Listen for a tone from the left speaker')
assert(prompt.kind === 'prompt' && prompt.key === 'speakers.left' && prompt.text === 'Listen for a tone from the left speaker', 'a prompt line carries its key and English text')
const question = model.parseLine('::verify:: speakers.clean Did both sides sound clean?')
assert(question.kind === 'verify' && question.key === 'speakers.clean', 'a verify line carries its question key')
assert(model.parseLine('::progress:: 0.5').value === 0.5, 'progress is read as a fraction')
assert(model.parseLine('::progress:: 7').value === 1, 'progress is clamped to one')
assert(model.parseLine('::progress:: soon').kind === 'log', 'unreadable progress is only log')
assert(model.parseLine('::image:: /run/user/1000/omarchy-rollcall/camera.png').path === '/run/user/1000/omarchy-rollcall/camera.png', 'an image line names its file')
assert(model.parseLine('2 in PipeWire (HDA-Intel)').kind === 'log', 'an unprefixed line is log')
const keyless = model.parseLine('::prompt:: <b>plug</b> it in')
assert(keyless.key === '' && keyless.text === '<b>plug</b> it in', 'a prompt without a key keeps all its text as English')

const dir = '/run/user/1000/omarchy-rollcall'
assert(model.imageAllowed(dir + '/camera.png', dir), 'a frame in the roll call directory is shown')
assert(!model.imageAllowed('/home/someone/secret.png', dir), 'a frame anywhere else is not')
assert(!model.imageAllowed(dir + '/../../etc/x.png', dir), 'a path climbing out is not')
assert(!model.imageAllowed(dir + '/camera.svg', dir), 'only raster frames are shown')
assert(!model.imageAllowed(dir + '/camera.png', ''), 'nothing is shown without a runtime directory')

assert(model.resultForExit(0) === 'pass' && model.resultForExit(1) === 'fail' && model.resultForExit(77) === 'skip' && model.resultForExit(4) === 'verify', 'exit codes map to results')
assert(model.resultForExit(139) === 'error', 'a crash is an error, never a pass')

const list = model.parseList(JSON.stringify([
  { id: 'speakers', title: 'Speakers', kind: 'verify', needs: '', applicable: true, reason: '', result: null },
  { id: 'lid', title: 'Lid', kind: 'interact', needs: '', applicable: false, reason: 'not a laptop', result: null },
  { id: 'Bad Id; rm', title: 'x', kind: 'verify', applicable: true },
  { id: 'keyboard', kind: 'panel', applicable: true, result: 'pass' },
  { id: 'odd', kind: 'telepathy', applicable: 'yes' }
]))
assert(list.length === 4, 'malformed ids are dropped')
assert(list[1].applicable === false && list[1].reason === 'not a laptop', 'applicability and its reason are kept')
assert(list[2].kind === 'panel' && list[2].result === 'pass', 'panel kind and a stored result are kept')
assert(list[3].kind === 'interact' && list[3].applicable === false, 'an unknown kind falls back and only true is applicable')
assert(model.parseList('not json').length === 0, 'unreadable output lists nothing')

const report = model.parseReport(JSON.stringify({ checks: [
  { id: 'wifi', result: 'pass', detail: 'connected (iwlwifi)' },
  { id: 'firmware', result: 'fail', detail: 'missing: iwlwifi-x.ucode' },
  { id: 'lid', result: 'skip', detail: 'not a laptop' }
] }))
assert(report.counts.pass === 1 && report.counts.fail === 1 && report.counts.skip === 1, 'the automated report is counted')
assert(report.failed.length === 1 && report.failed[0].id === 'firmware', 'failures are listed')
assert(model.parseReport('{}') === null, 'a report without checks is unreadable')

assert(model.titleText(undefined, 'volume-keys', 'Volume keys') === 'Volume keys', 'without a translator a title falls back to the one the test gave')
assert(model.promptText(undefined, 'nothing.known', 'Plug it in') === 'Plug it in', 'an unknown prompt key shows the English the test printed')
const t = (key, english) => key === 'rollcall.title.volumeKeys' ? 'Lydstyrketaster' : english
assert(model.titleText(t, 'volume-keys', 'Volume keys') === 'Lydstyrketaster', 'a translated title wins')
assert(model.titleText(t, 'unknown-test', 'Unknown') === 'Unknown', 'a test the panel does not know shows its own title')
assert(model.needsText(t, 'telepathy') === '', 'an unknown need is not shown')
JS
