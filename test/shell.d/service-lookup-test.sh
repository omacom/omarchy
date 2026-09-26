#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

function qmlFunction(file, name) {
  const source = fs.readFileSync(path.join(root, file), 'utf8')
  const match = source.match(new RegExp(`^  function ${name}\\([^]*?^  }`, 'm'))
  if (!match) throw new Error(`Missing ${name} in ${file}`)
  return match[0]
}

const context = vm.createContext({})
context.Util = vm.runInContext(`({
  ${qmlFunction('shell/Commons/Util.qml', 'canonicalWidgetId')},
  ${qmlFunction('shell/Commons/Util.qml', 'isPlainObject')}
})`.replace(/function (\w+)\(/g, '$1('), context)
const registry = vm.runInContext(`({
  installedPlugins: {},
  enabledIds: [],
  isEnabled(id) { return this.enabledIds.includes(id) },
  ${qmlFunction('shell/services/PluginRegistry.qml', 'resolveEnabledId')}
})`.replace(/function (\w+)\(/g, '$1('), context)
// QML object properties are in the method's lexical scope.
context.installedPlugins = registry.installedPlugins
context.isEnabled = registry.isEnabled.bind(registry)
context.shell = {pluginRegistry: registry}
vm.runInContext(qmlFunction('shell/shell.qml', 'serviceFor'), context)
vm.runInContext(qmlFunction('shell/shell.qml', 'firstPartyServiceFor'), context)

for (const name of ['idle', 'nightlight', 'notifications', 'media']) {
  const id = `omarchy.${name}`
  const cloneId = `tester.${name}`
  const original = {name: id}
  const clone = {name: cloneId}
  registry.installedPlugins[id] = {}
  registry.installedPlugins[cloneId] = {omarchy: {clonedFrom: id}}
  registry.enabledIds = [id]
  context._services = {[id]: original}
  assertEqual(context.firstPartyServiceFor(id), original, `${name}: inactive clone does not replace original`)

  registry.enabledIds = [cloneId]
  context._services = {[cloneId]: clone}
  assertEqual(context.firstPartyServiceFor(id), clone, `${name}: built-in lookup reaches enabled clone`)
  assertEqual(context.serviceFor(cloneId), clone, `${name}: concrete lookup reaches clone`)
  context._services[id] = original
  assertEqual(context.serviceFor(id), clone, `${name}: clone wins while original still exists`)
  delete context._services[cloneId]
  assertEqual(context.serviceFor(id), original, `${name}: original instance remains a compatibility fallback`)

  registry.enabledIds = [id]
  assertEqual(context.firstPartyServiceFor(id), original, `${name}: restoring original restores lookup`)
  context.shell.pluginRegistry = null
  assertEqual(context.serviceFor(id), original, `${name}: direct lookup works without registry`)
  context.shell.pluginRegistry = registry
  context._services = {}
  assertEqual(context.firstPartyServiceFor(id), null, `${name}: missing instance returns null`)
}
JS
