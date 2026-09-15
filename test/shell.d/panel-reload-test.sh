#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const rows = []
const removed = []
const hidden = []
const scope = vm.createContext({
  panelEntries: {
    get count() { return rows.length },
    get(i) { return rows[i] },
    append(row) { rows.push(row) },
    remove(i) { removed.push(rows.splice(i, 1)[0].pluginId) }
  },
  pluginRegistry: { installedPlugins: {} },
  desired: [],
  computePanelEntries() { return scope.desired.map(id => ({id})) },
  invokeIfLoaded(id) { hidden.push(id) },
  openPanelIds: {'test.panel':true, 'omarchy.plugins':true},
  pendingPayloads: {'test.panel':['stale'], 'omarchy.plugins':['keep']},
  panelLoaders: {}
})
scope.shell = scope
for (const name of ['syncPanelEntries', 'unloadPanels', 'retirePanel', 'unregisterPanelLoader']) {
  vm.runInContext(source.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))[0], scope)
}
scope.desired = ['omarchy.plugins', 'test.panel']
scope.syncPanelEntries()
const managerRow = rows[0]
scope.desired.push('test.new')
scope.syncPanelEntries()
assert(rows[0] === managerRow, 'discovering a plugin retains the existing panel row')
assertEqual(removed.length, 0, 'discovery does not remove existing panel delegates')
scope.pluginRegistry.installedPlugins = {
  'omarchy.plugins': {__isFirstParty:true},
  'test.panel': {__isFirstParty:false, keepLoaded:true},
  'test.new': {__isFirstParty:false}
}
scope.unloadPanels()
assertDeepEqual(rows.map(row => row.pluginId), ['omarchy.plugins'], 'rescan preserves built-in panels and unloads user code')
assertDeepEqual(hidden, ['test.new', 'test.panel'], 'third-party keepLoaded cannot prevent code invalidation')
assertDeepEqual(Object.keys(scope.openPanelIds), ['omarchy.plugins'], 'retirement clears only removed open state')
assertDeepEqual(Object.keys(scope.pendingPayloads), ['omarchy.plugins'], 'retirement drops stale payloads without losing built-in work')
scope.desired = []
scope.syncPanelEntries()
assertEqual(rows.length, 0, 'disabled or removed built-in panels are still retired')
const oldLoader = {}
const newLoader = {}
scope.panelLoaders = {'omarchy.plugins':newLoader}
scope.unregisterPanelLoader('omarchy.plugins', oldLoader)
assert(scope.panelLoaders['omarchy.plugins'] === newLoader, 'deferred old destruction cannot unregister its replacement')
scope.unregisterPanelLoader('omarchy.plugins', newLoader)
assertEqual(Object.keys(scope.panelLoaders).length, 0, 'matching loader destruction unregisters the panel')
JS
