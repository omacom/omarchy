#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if [[ -z ${OMARCHY_TEST_WARD_HOST:-} ]]; then
  pass "set OMARCHY_TEST_WARD_HOST to test temporary Ward review checkouts"
  exit 0
fi

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const {spawnSync} = require('child_process')
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-plugin-staging-'))
const home = path.join(temp, 'home')
const plugins = path.join(home, '.config/omarchy/plugins')
const source = path.join(temp, 'source')
const stubs = path.join(temp, 'stubs')
fs.mkdirSync(source)
fs.mkdirSync(stubs)
fs.writeFileSync(path.join(stubs, 'omarchy-shell'), '#!/bin/bash\nif [[ $* == *listPlugins* ]]; then echo "[]"; else echo ok; fi\n', {mode: 0o755})
const env = {...process.env, HOME: home, XDG_CONFIG_HOME: path.join(home, '.config'), XDG_STATE_HOME: path.join(home, 'state'),
  OMARCHY_PATH: root, OMARCHY_WARD_STORE: path.join(temp, 'ward'), OMARCHY_WARD_HOST: process.env.OMARCHY_TEST_WARD_HOST,
  GIT_CONFIG_GLOBAL: '/dev/null', PATH: `${stubs}:${root}/bin:/usr/bin`}
function run(name, args, success = true) {
  const result = spawnSync(name, args, {env, encoding: 'utf8', timeout: 15000})
  assertEqual(result.status === 0, success, `${name} ${args[0]}: ${success ? 'succeeds' : 'refuses invalid operation'}${(result.status === 0) === success ? '' : ': ' + result.stderr}`)
  return result.stdout
}
function add() { return JSON.parse(run('omarchy-plugin-add', [source, '--stage', '--json'])) }
function review(stage) { return JSON.parse(run('omarchy-plugin-stage', ['review', stage])) }
function records() { return JSON.parse(run('omarchy-plugin-installation', ['list'])) }
try {
  fs.writeFileSync(path.join(source, 'manifest.json'), JSON.stringify({schemaVersion: 1, id: 'test.staged', name: 'Staged', version: '1',
    kinds: ['bar-widget'], entryPoints: {barWidget: 'Widget.qml'}, sandbox: {version: 1, requests: {}}}))
  fs.writeFileSync(path.join(source, 'Widget.qml'), 'import QtQuick\nItem {}\n')
  run('git', ['-C', source, 'init', '-q', '--template='])
  run('git', ['-C', source, 'add', '.'])
  run('git', ['-C', source, '-c', 'commit.gpgsign=false', '-c', 'user.name=Test', '-c', 'user.email=test@example.com', 'commit', '-qm', 'fixture'])
  const first = add()
  const firstReview = review(first.stage)
  const second = add()
  const secondReview = review(second.stage)
  assert(first.stage !== second.stage, 'retrying an abandoned review uses a different temporary checkout')
  assertEqual(firstReview.revision, secondReview.revision, 'the same source has the same native revision in independent staging directories')
  assert(!fs.existsSync(path.join(plugins, 'test.staged')) && records().length === 0, 'cloning and reviewing do not install or record provenance')
  assert(!fs.existsSync(env.OMARCHY_WARD_STORE), 'staged review creates no persistent security store, identity or snapshot')
  assertEqual(JSON.parse(fs.readFileSync(path.join(plugins, second.stage, 'record.json'))).installed, false, 'staging keeps host metadata outside plugin content')
  assertEqual(run('omarchy-plugin-list', ['--json']).includes('"approved":true'), false, 'reviewing never grants access')
  run('omarchy-plugin-stage', ['discard', first.stage])
  assert(!fs.existsSync(path.join(plugins, first.stage)) && fs.existsSync(path.join(plugins, second.stage)), 'discard removes only its own attempt')
  for (const token of ['..', '.add.12345678/..', 'test.staged', plugins]) run('omarchy-plugin-stage', ['discard', token], false)
  const linked = path.join(plugins, '.add.symlink1')
  fs.symlinkSync(source, linked)
  run('omarchy-plugin-stage', ['discard', '.add.symlink1'], false)
  assert(fs.existsSync(path.join(source, 'manifest.json')), 'discard refuses a symlink instead of deleting its target')
  const third = add()
  const thirdReview = review(third.stage)
  fs.appendFileSync(path.join(plugins, third.stage, 'checkout/Widget.qml'), '// changed after review\n')
  run('omarchy-plugin-stage', ['publish', third.stage, thirdReview.revision], false)
  assert(!fs.existsSync(path.join(plugins, 'test.staged')) && records().length === 0, 'changed staged bytes cannot be published with the previous approval revision')
  assert(!fs.existsSync(env.OMARCHY_WARD_STORE), 'failed revision validation still leaves no persistent review history')
  const published = JSON.parse(run('omarchy-plugin-stage', ['publish', second.stage, secondReview.revision]))
  assert(published.installed && fs.existsSync(path.join(plugins, 'test.staged/manifest.json')), 'explicit publication moves the vetted checkout into its installed location')
  assert(!fs.existsSync(path.join(plugins, second.stage)), 'successful publication removes its temporary wrapper')
  assertEqual(records()[0].source, source, 'publication retains original source provenance rather than the temporary path')
  assertEqual(run('omarchy-plugin-list', ['--json']).includes('"approved":true'), false, 'publication alone does not approve or enable')
  const marker = path.join(plugins, 'test.staged/preserve-me')
  fs.writeFileSync(marker, 'installed data')
  const changed = review(third.stage)
  run('omarchy-plugin-stage', ['publish', third.stage, changed.revision], false)
  assertEqual(fs.readFileSync(marker, 'utf8'), 'installed data', 'a competing staged attempt cannot replace an existing installation')
  run('omarchy-plugin-stage', ['discard', third.stage])
  assert(fs.existsSync(marker), 'discarding another attempt cannot remove the installed plugin')
} finally { fs.rmSync(temp, {recursive: true, force: true}) }
JS
