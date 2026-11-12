#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const clone = {id: 'tester.apps', kinds: ['menu'], omarchy: {clonedFrom: 'omarchy.apps'}}
const calls = []
let dockEnabled = true
const dock = {pinnedKeys: ['foot'], setPinned: (...args) => calls.push(args)}
const host = {
  pluginRegistry: {installedPlugins: {'tester.apps': clone}, isEnabled: () => true},
  manifestHasKind: (manifest, kind) => !!manifest && manifest.kinds.includes(kind),
  firstPartyServiceFor: () => dockEnabled ? dock : null
}
const context = {
  shell: host,
  Util: {isPlainObject: value => !!value && typeof value === 'object' && !Array.isArray(value)},
  _pluginFirstPartyServiceApis: {},
  Qt: {binding: get => ({get})},
  pluginAppsDockApiComponent: {createObject(parent, properties) {
    assertEqual(parent, null, 'dock capability has no host parent')
    return new Proxy({...properties}, {set(target, key, value) {
      if (value && typeof value.get === 'function') Object.defineProperty(target, key, {get: value.get, configurable: true})
      else target[key] = value
      return true
    }})
  }}
}
for (const name of ['isAppsClone', 'pluginAppsDockFor', 'pluginShellCapabilityProfile', 'pluginApiActive']) {
  const match = source.match(new RegExp('  function ' + name + String.raw`\([^]*?\n  \}`))
  assert(!!match, name + ' exists')
  vm.runInNewContext(match[0] + '\nthis.fn = ' + name, context)
  host[name] = context.fn
}
assert(!host.isAppsClone({kinds: ['menu']}), 'ordinary menus do not gain Apps dock access')
const api = host.pluginAppsDockFor('tester.apps', 'tester.apps')
assert(api.available && api !== dock, 'Apps clone receives a separate dock capability')
assert(host.pluginApiActive(api, host.pluginRegistry.installedPlugins), 'dock capability retains its owner during cache cleanup')
api._invoke('setPinned', ['foot', true])
assertEqual(calls.length, 1, 'dock capability forwards permitted pin operations')
api._invoke('destroy', [])
assertEqual(calls.length, 1, 'dock capability rejects arbitrary dock methods')
const pins = api.pinnedKeys
pins.push('other')
assertEqual(dock.pinnedKeys.length, 1, 'dock pin snapshots cannot mutate host state')
dockEnabled = false
assert(!api.available, 'dock capability becomes unavailable when dock is disabled')
api._invoke('setPinned', ['foot', false])
assertEqual(calls.length, 1, 'disabled dock rejects stale capability calls')
dockEnabled = true
assert(api.available, 'dock capability recovers when dock is enabled again')
const oldProfile = host.pluginShellCapabilityProfile(clone, true, false)
host.pluginRegistry.installedPlugins['tester.apps'] = {id: 'tester.apps', kinds: ['menu']}
assert(!api.available, 'removing Apps clone metadata revokes an existing dock capability')
api._invoke('setPinned', ['foot', false])
assertEqual(calls.length, 1, 'retained capability cannot act after clone scope is revoked')
assert(oldProfile !== host.pluginShellCapabilityProfile(host.pluginRegistry.installedPlugins['tester.apps'], true, false), 'changing Apps clone scope changes its cached capability profile')
JS

require_quickshell "apps overlay test"
run_qml_fixture apps "app grid searches and launches with the dock disabled, enabled or cloned" Ui Commons services
