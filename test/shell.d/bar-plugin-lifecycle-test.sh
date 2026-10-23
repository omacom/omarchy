#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const fs = require('fs'), vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
const owner = {}, unrelated = {}, destroyed = []
const apis = {'plugin@wide': {pluginId: 'plugin', destroy() { destroyed.push('wide') }},
              'plugin@square': {pluginId: 'plugin', destroy() { destroyed.push('square') }},
              'other@wide': {pluginId: 'other', destroy() { destroyed.push('other') }}}
const state = {pluginBarApis: apis, activePopout: null, clickTargets: [], pluginObjectOwners: new Map(),
               publicLayoutConfig() { return {} },
               requestPopout(item) { state.activePopout = item },
               releasePopout(item) { if (state.activePopout === item) state.activePopout = null },
               unregisterClickTarget(item) { state.clickTargets = state.clickTargets.filter(x => x !== item) }}
const context = vm.createContext({...state, root: state})
for (const name of ['pluginObjectRecord','markPluginObject','unmarkPluginObject','pluginOwnsBarObject','pluginClickTargets','syncPluginBarApiObjects','syncPluginBarApisFor','requestPluginPopout','releasePluginPopout','releasePluginObjects']) {
  const fn = source.match(new RegExp('  function '+name+'\\([^]*?\\n  }'))
  assert(fn, name+' exists')
  vm.runInContext(fn[0], context)
  state[name] = context[name]
}
state.requestPluginPopout('plugin', owner)
assert(apis['plugin@wide'].activePopout === owner && apis['plugin@square'].activePopout === owner, 'all screen APIs update before a plugin reads its opened popout')
state.releasePluginPopout('plugin', owner)
assert(apis['plugin@wide'].activePopout === null && apis['plugin@square'].activePopout === null && state.activePopout === null, 'opening and closing in one turn releases ownership synchronously')
state.markPluginObject('plugin', owner, 'clickTarget')
state.markPluginObject('other', unrelated, 'clickTarget')
state.clickTargets = [owner, unrelated]
const teardown = source.match(/  Component\.onDestruction: \{([^]*?)\n  }/)
assert(teardown, 'bar teardown exists')
vm.runInContext(teardown[1], context)
assertDeepEqual(destroyed.sort(), ['other','square','wide'], 'teardown destroys every API across screens')
assert(state.clickTargets.length === 0 && state.pluginObjectOwners.size === 0, 'teardown releases all plugin click targets and ownership records')
JS
