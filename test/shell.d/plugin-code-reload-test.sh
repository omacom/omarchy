#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

shell_qml="$ROOT/shell/shell.qml"

qml_matches() {
  local file=$1
  local pattern=$2

  tr '\n\r\t' '   ' < "$file" | grep -Eq "$pattern"
}

# QML caches compiled components by URL and Qt 6 has no
# Qt.clearComponentCache, so rebuilding a changed plugin in place keeps its
# old code. A local plugin change must come back through a soft Quickshell
# reload, which waits while the session is locked.
qml_matches "$shell_qml" 'id: *localPluginReloadTimer[^}]*onTriggered: *shell\.reloadChangedPlugins\(\)' ||
  fail "local plugin changes go through reloadChangedPlugins"
qml_matches "$shell_qml" 'function reloadChangedPlugins\(\) *\{ *if *\( *AuthServiceStore\.isLocked\( *"omarchy\.lock" *\) *\)' ||
  fail "plugin code reloads read the lock state from the private authentication store"
if qml_matches "$shell_qml" 'Qt\.clearComponentCache\(\)'; then
  fail "shell does not rely on Qt.clearComponentCache, which Qt 6 does not provide"
fi
pass "changed plugins reload through a soft Quickshell reload"

# Behavior: run the real reloadChangedPlugins() against the real
# AuthServiceStore, covering a locked attempt and the later unlocked one.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const store = {}
vm.createContext(store)
vm.runInContext(
  fs.readFileSync(path.join(root, 'shell/services/AuthServiceStore.js'), 'utf8'),
  store
)

const source = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const match = source.match(/\n  function reloadChangedPlugins\(\) \{[\s\S]*?\n  \}\n/)
if (!match) fail('reloadChangedPlugins() can be extracted from shell.qml')

const reloads = []
const timer = { interval: 150, restarts: 0, restart() { this.restarts++ } }
const context = {
  AuthServiceStore: store,
  localPluginReloadTimer: timer,
  Quickshell: { reload(hard) { reloads.push(hard) } },
}
vm.createContext(context)
vm.runInContext(match[0], context)

const lock = { locked: true, destroy() {} }
store.put('omarchy.lock', lock)
context.reloadChangedPlugins()
assert(
  reloads.length === 0 && timer.restarts === 1 && timer.interval === 2000,
  'a locked session defers the reload and schedules another attempt',
  JSON.stringify({ reloads, restarts: timer.restarts, interval: timer.interval })
)

lock.locked = false
context.reloadChangedPlugins()
assert(
  reloads.length === 1 && reloads[0] === false && timer.restarts === 1,
  'the next attempt after unlocking performs one soft reload',
  JSON.stringify({ reloads, restarts: timer.restarts })
)

store.destroy('omarchy.lock')
context.reloadChangedPlugins()
assert(reloads.length === 2, 'without a lock service the change reloads immediately')

store.put('omarchy.lock', { locked: true, destroy() {} })
assert(
  store.isLocked('omarchy.lock') === true && store.isLocked('missing.service') === false,
  'the lock check returns a boolean, never the service'
)
JS
