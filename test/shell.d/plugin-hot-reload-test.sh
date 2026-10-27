#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
function loadModule(file) {
  const context = vm.createContext({})
  vm.runInContext(fs.readFileSync(root + '/shell/services/' + file, 'utf8'), context)
  return context
}
const reload = loadModule('PluginReload.js')
const auth = loadModule('AuthServiceStore.js')
for (const file of ['entry.qml', 'Helper.QML', 'util.js', 'module.mjs', 'qmldir', 'nested/qmldir'])
  assert(reload.sourceChangedForPath(file), file + ' refreshes compiled plugin sources')
for (const file of ['manifest.json', '__pycache__/worker.pyc', 'photo.png', 'notes.qml.bak'])
  assert(!reload.sourceChangedForPath(file), file + ' uses the registry-only reload')
let engineReloads = 0
let registryReloads = 0
const engine = () => engineReloads++
const registry = () => registryReloads++
const lock = { locked: true }
auth.put('omarchy.lock', lock)
let pending = reload.flush(true, auth.hasActiveLock(), engine, registry)
assert(pending && engineReloads === 0 && registryReloads === 0, 'source edits stay queued while locked')
pending = reload.flush(pending, auth.hasActiveLock(), engine, registry)
assert(pending && engineReloads === 0, 'retries preserve the lock and queued edit')
lock.locked = false
pending = reload.flush(pending, auth.hasActiveLock(), engine, registry)
assert(!pending && engineReloads === 1 && registryReloads === 0, 'unlock consumes the queued engine reload once')
reload.flush(false, auth.hasActiveLock(), engine, registry)
assert(engineReloads === 1 && registryReloads === 1, 'non-source edits only rescan plugins')
// Configured authentication clones are private too and can own the lock.
auth.put('my.lock', { locked: true })
assert(reload.flush(true, auth.hasActiveLock(), engine, registry), 'a private lock clone also defers reload')
assert(engineReloads === 1, 'no engine reload occurs while any private lock is held')
JS
