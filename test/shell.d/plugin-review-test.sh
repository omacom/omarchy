#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if [[ -z ${OMARCHY_TEST_WARD_HOST:-} ]]; then
  pass "set OMARCHY_TEST_WARD_HOST to a built runtime for plugin command integration"
  exit 0
fi

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const { spawnSync } = require('child_process')
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-plugin-review-test-'))
const home = path.join(temp, 'home')
const source = path.join(temp, 'source')
const stubs = path.join(temp, 'stubs')
const store = path.join(temp, 'state')
const installed = path.join(home, '.config/omarchy/plugins/acme.review')
for (const directory of [home, source, stubs]) fs.mkdirSync(directory)
const env = {
  ...process.env, HOME: home, OMARCHY_PATH: root,
  XDG_STATE_HOME: path.join(home, '.local/state'),
  OMARCHY_WARD_HOST: process.env.OMARCHY_TEST_WARD_HOST,
  OMARCHY_WARD_STORE: store, PATH: `${stubs}:${root}/bin:${process.env.PATH}`
}
function run(command, args, success = true) {
  const result = spawnSync(command, args, { env, encoding: 'utf8', timeout: 10000 })
  if (success && result.status !== 0) throw new Error(`${command}: ${result.stderr}\n${result.stdout}`)
  if (!success && result.status === 0) throw new Error(`${command} unexpectedly succeeded`)
  return result.stdout
}
try {
  const shellSource = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
  function method(name, closing) {
    const start = shellSource.indexOf(`function ${name}(`)
    return shellSource.slice(start, shellSource.indexOf(closing, start) + closing.length).replace(/: string/g, '')
  }
  const scope = {
    Util: { canonicalWidgetId: id => id, isPlainObject: value => value && typeof value === 'object' && !Array.isArray(value) },
    shellConfig: { plugins: [{ id: 'acme.review', sandbox: true, old: true }, { id: 'other', untouched: true }], bar: { layout: { right: [{ id: 'acme.review', type: 'command', exec: 'untouched' }] } } },
    sandboxedPlugins: { status: () => ({ state: 'running' }) },
    persistShellConfig: config => { scope.shellConfig = config }
  }
  scope.shell = scope
  const vm = require('vm')
  vm.createContext(scope)
  vm.runInContext(method('saveSandboxSettings', '\n    }'), scope)
  for (const value of ['[]', 'null', '{"sandbox":false}', '{"sandboxPresentation":{"overlayMode":"pointer"}}', '{"id":"other"}', '{"__proto__":{}}', '{"constructor":{}}', '{"prototype":{}}']) {
    assertEqual(scope.saveSandboxSettings('acme.review', value), 'invalid settings', 'host rejects structural or non-object settings: ' + value)
  }
  assertEqual(scope.saveSandboxSettings('other', '{}'), 'plugin is not active', 'host rejects entries without the sandbox marker')
  assertEqual(scope.saveSandboxSettings('acme.review', '{"width":80}'), 'ok', 'active plugin can save its own settings')
  assertDeepEqual(scope.shellConfig.plugins, [{ id: 'acme.review', sandbox: true, old: true, width: 80 }, { id: 'other', untouched: true }], 'host preserves unrelated settings, identity, sandbox marker and other entries')
  assertEqual(scope.saveSandboxSettings('acme.review', '{"type":"command","exec":"malicious"}'), 'ok', 'worker strings remain inert settings in its own sandbox entry')
  assertDeepEqual(scope.shellConfig.bar.layout.right, [{ id: 'acme.review', type: 'command', exec: 'untouched' }], 'sandbox settings cannot change a same-id legacy bar command or QML entry')
  scope.shellConfig.bar.layout.left = [scope.shellConfig.plugins.shift()]
  assertEqual(scope.saveSandboxSettings('acme.review', '{"type":"qml","path":"/plugin/Widget.qml"}'), 'ok', 'native bar entries retain arbitrary own settings as data')
  vm.runInContext(method('renderingBarConfig', '\n  }'), scope)
  const rendered = scope.renderingBarConfig(scope.shellConfig.bar)
  assertDeepEqual(rendered.layout.left, [{id: 'acme.review', sandbox: true}], 'neither first-party nor replacement bars receive native settings as dispatch fields')
  assertDeepEqual(rendered.layout.right, [{id: 'acme.review', type: 'command', exec: 'untouched'}], 'sanitizing native slots preserves unrelated user-authored custom commands')
  assertEqual(scope.shellConfig.bar.layout.left[0].type, 'qml', 'rendering projection never mutates canonical worker settings')
  scope.sandboxedPlugins.status = () => ({ state: 'disabled' })
  assertEqual(scope.saveSandboxSettings('acme.review', '{}'), 'plugin is not active', 'host rejects a save after deactivation')

  fs.writeFileSync(path.join(stubs, 'omarchy-shell'), '#!/bin/bash\nif [[ $* == "shell listPlugins" ]]; then echo "[]"; else echo "ok"; fi\n', { mode: 0o755 })
  fs.writeFileSync(path.join(source, 'manifest.json'), JSON.stringify({
    schemaVersion: 1, id: 'acme.review', name: 'Review fixture', version: '1', kinds: ['panel'],
    entryPoints: { panel: 'worker.qml' },
    sandbox: { version: 1, entryPoint: 'worker.qml', requests: { network: true, notifications: true, desktopGeometry: true, settings: {read: ['width'], write: ['width']}, filesystem: [{name: 'notes', path: source, target: 'directory', access: 'read'}] } }
  }))
  fs.writeFileSync(path.join(source, 'worker.qml'), 'import Quickshell\nShellRoot {}\n')
  run('git', ['-C', source, 'init', '-q'])
  run('git', ['-C', source, 'add', '.'])
  run('git', ['-C', source, '-c', 'user.name=Test', '-c', 'user.email=test@example.com', 'commit', '-qm', 'Fixture'])
  run('omarchy-plugin-add', [source, '--yes'])
  assert(fs.existsSync(path.join(installed, '.git')), 'existing plugin add owns the sandbox Git checkout')
  const installedRuntime = env.OMARCHY_WARD_HOST
  env.OMARCHY_WARD_HOST = path.join(temp, 'missing-runtime')
  run('omarchy-plugin-disable', ['acme.review'])
  assert(fs.existsSync(installed) && !fs.existsSync(store), 'stock-machine disable retains the checkout without creating native state')
  run('omarchy-plugin-remove', ['acme.review', '--yes'])
  assert(!fs.existsSync(installed) && !fs.existsSync(store), 'stock-machine remove works before any native store exists')
  run('omarchy-plugin-add', [source, '--yes'])
  env.OMARCHY_WARD_HOST = installedRuntime
  run('omarchy-plugin-disable', ['acme.review'])
  assert(!fs.existsSync(store), 'disabling a never-reviewed plugin creates no store')
  run('omarchy-plugin-review', ['acme.review', '--ui'])
  assert(!fs.existsSync(store), 'opening the reviewer does not import or approve before its own command runs')
  const review = JSON.parse(run('omarchy-plugin-review', ['acme.review', '--json']))
  for (const command of ['review', 'approve']) {
    const source = fs.readFileSync(path.join(root, `bin/omarchy-plugin-${command}`), 'utf8')
    assert(source.includes('omarchy-shell -q shell rescanPlugins'), `${command} refreshes the live isolation identity snapshot`)
  }
  assertEqual(review.id, 'acme.review', 'review selects the installed catalog identity')
  assertEqual(review.requests.network, true, 'review shows requested network access')
  assert(!fs.existsSync(path.join(store, 'acme.review.json')), 'review creates no approval')
  run('omarchy-plugin-disable', ['acme.review'])
  assert(!fs.existsSync(path.join(store, 'acme.review.json')), 'disabling a reviewed plugin creates no approval')
  assert(run('omarchy-plugin-review', ['acme.review']).includes('Reviewing permissions does not start the plugin'), 'human review explains the snapshot boundary')
  assert(run('omarchy-plugin-review', ['acme.review']).includes('Read window and screen layout; no titles, contents or window control'), 'human review discloses the requested desktop observation')
  run('omarchy-plugin-approve', ['acme.review', '--revision', review.revision], false)
  for (const access of ['--read', '--write']) {
    for (const folder of [store, path.join(store, 'secrets'), temp, home]) {
      run('omarchy-plugin-approve', ['acme.review', '--revision', review.revision, access, `notes=${folder}`, '--yes'], false)
      assert(!fs.existsSync(path.join(store, 'acme.review.json')), `${access} authority selection cannot create an approval: ${folder}`)
    }
  }
  run('omarchy-plugin-approve', ['acme.review', '--revision', review.revision, '--read', 'notes', '--allow-notifications', '--allow-desktop-geometry', '--read-setting', 'width', '--write-setting', 'width', '--yes'])
  let record = JSON.parse(fs.readFileSync(path.join(store, 'acme.review.json')))
  assertEqual(record.grants.network, false, 'approval does not infer requested network access')
  assertEqual(record.grants.notifications, true, 'approval records the selected notification grant')
  assertEqual(record.grants.desktopGeometry, true, 'approval records explicitly selected geometry access')
  assertDeepEqual(record.grants.settings, {read: ['width'], write: ['width']},  'approval records only explicitly selected own-settings access')
  assertEqual(record.grants.filesystem.notes.path, source, 'approval records the selected folder')
  assertEqual(record.activeUnit, null, 'approval does not start a plugin')
  let listed = JSON.parse(run('omarchy-plugin-list', ['--json'])).find(row => row.id === 'acme.review')
  assertEqual(listed.approved, true, 'plugin list exposes exact-revision approval')
  assertEqual(listed.enabled, false, 'plugin list does not confuse approval with activation')
  const manifestPath = path.join(installed, 'manifest.json')
  const originalManifest = fs.readFileSync(manifestPath, 'utf8')
  const downgraded = JSON.parse(originalManifest)
  delete downgraded.sandbox
  fs.writeFileSync(manifestPath, JSON.stringify(downgraded))
  // Exercise native identity independently of the install marker. No native
  // activation or config marker has ever existed in this fixture.
  fs.rmSync(path.join(home, '.local/state/omarchy/plugin-isolation/acme.review'), {recursive: true})
  listed = JSON.parse(run('omarchy-plugin-list', ['--json'])).find(row => row.id === 'acme.review')
  assertEqual(listed.sandboxed, true, 'approved before first enable remains isolated after sandbox declaration removal')
  assertEqual(listed.approved, true, 'classification uses host identity, not the changed manifest')
  fs.writeFileSync(manifestPath, '{')
  listed = JSON.parse(run('omarchy-plugin-list', ['--json'])).find(row => row.id === 'acme.review')
  assertEqual(listed.approved, true, 'malformed checkout remains manageable')
  const runtime = env.OMARCHY_WARD_HOST
  env.OMARCHY_WARD_HOST = path.join(temp, 'missing-runtime')
  listed = JSON.parse(run('omarchy-plugin-list', ['--json'])).find(row => row.id === 'acme.review')
  assertEqual(listed.sandboxed, true, 'isolation discovery needs no runtime binary')
  assertEqual(listed.approved, null, 'unavailable approval is unknown, not silently disabled')
  assert(listed.error.includes('unavailable'), 'runtime failure is reported in the catalog')
  run('omarchy-plugin-disable', ['acme.review'], false)
  run('omarchy-plugin-remove', ['acme.review', '--yes'], false)
  assert(fs.existsSync(installed) && fs.existsSync(path.join(store, 'acme.review.json')), 'missing runtime cannot erase existing approval or checkout')
  run('omarchy-plugin-enable', ['acme.review'], false)
  env.OMARCHY_WARD_HOST = runtime
  fs.writeFileSync(manifestPath, originalManifest)
  assert(run('omarchy-plugin-list', []).includes('approved'), 'human list distinguishes approved from enabled')
  const isolationStub = path.join(stubs, 'omarchy-plugin-isolation')
  fs.writeFileSync(isolationStub, '#!/bin/bash\nexit 126\n', {mode:0o755})
  const unavailable = spawnSync('omarchy-plugin-list', [], {env, encoding:'utf8'})
  assert(unavailable.status !== 0 && unavailable.stderr.includes('isolation/provenance state is unavailable'), 'list explains isolation-helper failure and remains fail-closed')
  fs.unlinkSync(isolationStub)
  fs.writeFileSync(path.join(stubs, 'omarchy-shell'), '#!/bin/bash\necho \'[{"id":"acme.review","enabled":true}]\'\n', {mode:0o755})
  fs.renameSync(installed, path.join(temp, 'checkout.saved'))
  listed = JSON.parse(run('omarchy-plugin-list', ['--json'])).find(row => row.id === 'acme.review')
  assert(listed.enabled && listed.error, 'missing checkout preserves independently observed running state and its error')
  assert(run('omarchy-plugin-list', []).includes('running/error'), 'human list displays a running worker even with a checkout error')
  fs.renameSync(path.join(temp, 'checkout.saved'), installed)
  fs.writeFileSync(path.join(stubs, 'omarchy-shell'), '#!/bin/bash\nif [[ $* == *listPlugins* ]]; then echo "[]"; else echo ok; fi\n', {mode:0o755})
  fs.appendFileSync(path.join(source, 'worker.qml'), '// New revision\n')
  run('git', ['-C', source, 'add', '.'])
  run('git', ['-C', source, '-c', 'user.name=Test', '-c', 'user.email=test@example.com', 'commit', '-qm', 'Update fixture'])
  assert(run('omarchy-plugin-update', ['acme.review', '--yes']).includes('grants are unchanged'), 'existing update explains re-review')
  const updated = JSON.parse(run('omarchy-plugin-review', ['acme.review', '--json']))
  assert(updated.revision !== review.revision, 'changed checkout receives a different review digest')
  record = JSON.parse(fs.readFileSync(path.join(store, 'acme.review.json')))
  assertEqual(record.revision, review.revision, 'reviewing an update preserves the old approval')
  run('omarchy-plugin-disable', ['acme.review'])
  record = JSON.parse(fs.readFileSync(path.join(store, 'acme.review.json')))
  assertEqual(record.enabled, false, 'existing plugin disable revokes sandbox admission')
  run('omarchy-plugin-approve', ['acme.review', '--revision', updated.revision, '--yes'])
  record = JSON.parse(fs.readFileSync(path.join(store, 'acme.review.json')))
  assertEqual(record.revision, updated.revision, 'explicit reapproval selects the updated snapshot')
  assertEqual(record.grants.notifications, false, 'reapproval does not silently carry old grants forward')
  assertEqual(record.grants.desktopGeometry, false, 'reapproval does not retain geometry access implicitly')
  assertDeepEqual(record.grants.settings, {read: [], write: []},  'reapproval does not retain own-settings access implicitly')
  fs.writeFileSync(path.join(stubs, 'omarchy-shell'), '#!/bin/bash\nif [[ $1 == "-q" ]]; then exit 0; else exit 1; fi\n', { mode: 0o755 })
  listed = JSON.parse(run('omarchy-plugin-list', ['--json'])).find(row => row.id === 'acme.review')
  assertEqual(listed.approved, true, 'approval remains visible when the shell is offline')
  const state = path.join(env.XDG_STATE_HOME, 'omarchy')
  const data = path.join(state, 'plugins/acme.review')
  const otherData = path.join(state, 'plugins/acme.other')
  fs.mkdirSync(data, {recursive:true})
  fs.mkdirSync(otherData, {recursive:true})
  fs.writeFileSync(path.join(data, 'save.json'), 'saved plugin data')
  fs.writeFileSync(path.join(otherData, 'keep'), 'other plugin data')
  fs.symlinkSync(source, path.join(data, 'external-files'))
  run('omarchy-plugin-disable', ['acme.review'])
  assert(fs.existsSync(installed) && fs.existsSync(path.join(data, 'save.json')), 'disable keeps the checkout and saved private data')
  assert(fs.existsSync(path.join(store, 'acme.review.json')) && fs.existsSync(path.join(store, 'revisions', updated.revision)), 'disable keeps the security record and reviewed snapshots')
  const removalManifest = fs.readFileSync(path.join(installed, 'manifest.json'))
  fs.writeFileSync(path.join(installed, 'manifest.json'), 'not-json')
  listed = JSON.parse(run('omarchy-plugin-list', ['--json'])).find(row => row.id === 'acme.review')
  assertEqual(listed.installed, true, 'damaged existing checkout stays available for management')
  fs.writeFileSync(path.join(installed, 'manifest.json'), removalManifest)
  const shellConfig = path.join(home, '.config/omarchy/shell.json')
  fs.writeFileSync(shellConfig, JSON.stringify({version:1, unrelated:'keep', plugins:[{id:'acme.review', sandbox:true, secretSetting:'remove'}, {id:'acme.other', setting:'keep'}], bar:{layout:{left:['acme.review'], center:[], right:[{id:'acme.review', setting:1}, {id:'acme.other'}]}}, disabledPlugins:['acme.review', 'acme.other']}))
  assert(run('omarchy-plugin-remove', ['acme.review', '--yes']).includes('installation records removed'), 'full sandbox removal works when the shell is offline')
  const remainingConfig = JSON.parse(fs.readFileSync(shellConfig))
  assert(!JSON.stringify(remainingConfig).includes('acme.review'), 'full removal clears offline config placements and inline settings')
  assertEqual(remainingConfig.plugins[0].setting, 'keep', 'full removal preserves other plugin settings')
  assertEqual(remainingConfig.unrelated, 'keep', 'full removal preserves unrelated desktop configuration')
  assert(!fs.existsSync(installed) && !fs.existsSync(data), 'remove deletes the checkout and saved private data')
  for (const suffix of ['json', 'pending', 'lock']) assert(!fs.existsSync(path.join(store, `acme.review.${suffix}`)), `remove deletes native ${suffix} state`)
  assert(!fs.existsSync(path.join(store, 'identities/acme.review')), 'remove forgets native identity')
  assert(!fs.existsSync(path.join(store, 'revisions', review.revision)) && !fs.existsSync(path.join(store, 'revisions', updated.revision)), 'remove purges all reviewed revisions')
  for (const directory of ['plugin-isolation', 'plugin-installations']) assert(!fs.existsSync(path.join(state, directory, 'acme.review')), `remove deletes ${directory} record`)
  assert(fs.existsSync(path.join(otherData, 'keep')) && fs.existsSync(path.join(source, 'manifest.json')), 'removal does not follow saved-data links or delete other plugins or original sources')
  fs.writeFileSync(path.join(stubs, 'omarchy-shell'), '#!/bin/bash\necho \'[{"id":"acme.review","installed":true,"enabled":false}]\'\n', {mode:0o755})
  assert(!JSON.parse(run('omarchy-plugin-list', ['--json'])).some(row => row.id === 'acme.review'), 'stale shell discovery cannot resurrect a fully removed plugin')
  fs.writeFileSync(path.join(stubs, 'omarchy-shell'), '#!/bin/bash\nif [[ $* == *listPlugins* ]]; then echo "[]"; else echo ok; fi\n', {mode:0o755})
  const freshManifest = JSON.parse(fs.readFileSync(path.join(source, 'manifest.json')))
  delete freshManifest.sandbox
  fs.writeFileSync(path.join(source, 'manifest.json'), JSON.stringify(freshManifest))
  run('git', ['-C', source, 'add', '.'])
  run('git', ['-C', source, '-c', 'commit.gpgsign=false', '-c', 'user.name=Test', '-c', 'user.email=test@example.com', 'commit', '-qm', 'fresh unsandboxed installation'])
  run('omarchy-plugin-add', [source, '--yolo', '--yes'])
  listed = JSON.parse(run('omarchy-plugin-list', ['--json'])).find(row => row.id === 'acme.review')
  assertEqual(listed.executionMode, 'yolo', 'explicit full removal permits a fresh execution-mode decision without old identity or grants')
  run('omarchy-plugin-disable', ['acme.review'])
  run('omarchy-plugin-remove', ['acme.review', '--yes'])
} finally {
  fs.rmSync(temp, { recursive: true, force: true })
}
JS
