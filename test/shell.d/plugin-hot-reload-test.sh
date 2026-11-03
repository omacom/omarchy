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
// Replay watcher events through shell.qml's rule: every event restarts the
// timer with quietInterval(), and the timer flushes once it runs out.
function engineReloadsFor(events) {
  let pending = false, deadline = null, reloads = 0
  const fire = () => { pending = reload.flush(pending, false, () => reloads++, () => {}); deadline = null }
  for (const [at, file] of events) {
    if (deadline !== null && at >= deadline) fire()
    if (reload.sourceChangedForPath(file)) pending = true
    deadline = at + reload.quietInterval(pending)
  }
  if (deadline !== null) fire()
  return reloads
}
// `omarchy plugin update` fast-forwards, validates, and resets when validation
// fails; a slow validation must not reload the shell onto the rejected code.
assert(engineReloadsFor([[0, 'Overlay.qml'], [40, 'Model.js'], [240, 'Overlay.qml']]) === 1,
  'one plugin update reloads the engine once, across a failed-validation reset')
assert(engineReloadsFor([[0, 'Overlay.qml'], [2000, 'Overlay.qml']]) === 2, 'separate saves each reload the engine')
assert(reload.quietInterval(false) < reload.quietInterval(true), 'registry-only rescans keep the shorter wait')
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
