#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const copy = value => JSON.parse(JSON.stringify(value))
const source = fs.readFileSync(path.join(root, 'shell/services/SandboxedPluginActivation.qml'), 'utf8')
const registrySource = fs.readFileSync(path.join(root, 'shell/services/PluginRegistry.qml'), 'utf8')
const functions = text => [...text.matchAll(/^  function \w+\([^\n]*\) \{[\s\S]*?^  \}/gm)].map(match => match[0]).join('\n')
const Util = {isPlainObject: value => !!value && typeof value === 'object' && !Array.isArray(value), canonicalWidgetId: String}

function fixture(initial) {
  const registry = vm.createContext({Util, installedPlugins: {}})
  vm.runInContext(functions(registrySource), registry)
  registry.isSandboxed = () => true
  registry.findRelativeBarLocation = (config, id, section) => registry.findBarLocation(config, id, section)
  for (const id of ['test.one', 'test.two']) registry.installedPlugins[id] = {
    id, kinds: ['bar-widget'], entryPoints: {barWidget: 'Widget.qml'}, sandbox: {version: 1}
  }
  registry.installedPlugins['test.panel'] = {id: 'test.panel', entryPoints: {panel: 'worker.qml'}, sandbox: {entryPoint: 'worker.qml'}}
  const manager = {
    instances: {}, errors: {}, stops: [], starts: 0,
    enable(id) {
      delete this.errors[id]
      if (!this.instances[id] || this.instances[id].state === 'error') {
        this.starts++
        this.instances[id] = {state: 'starting', error: ''}
      }
      return this.instances[id].state === 'running' ? 'ok' : 'starting'
    },
    disable(id) { delete this.instances[id]; delete this.errors[id]; this.stops.push(id) },
    fail(id, error) { this.disable(id); this.errors[id] = error },
    status(id) { return this.instances[id] || {state: this.errors[id] ? 'error' : 'disabled', error: this.errors[id] || ''} }
  }
  const writes = []
  const context = vm.createContext({Util, registry, manager, pending: {}, Qt: {callLater() {}},
    config: copy(initial || {version: 1, bar: {layout: {left: [{id: 'anchor'}], center: [], right: []}}, plugins: []}),
    writeConfig(config) { writes.push(copy(config)); context.config = copy(config) }
  })
  vm.runInContext(functions(source), context)
  return {context, manager, registry, writes}
}

{
  const {context: c, manager, writes} = fixture()
  const original = copy(c.config)
  assertEqual(c.enable('test.one', {section: 'right'}), 'starting', 'native enable remains pending')
  assertEqual(writes.length, 0, 'pending activation never writes saved intent')
  assertDeepEqual(c.config, original, 'pending activation leaves canonical config untouched')
  assertEqual(c.preview(c.config, c.pending).bar.layout.right[0].id, 'test.one', 'pending widget has a presentation-only slot')
  manager.instances['test.one'].state = 'error'
  manager.instances['test.one'].error = 'worker could not start'
  c.settle()
  assertEqual(writes.length, 0, 'failed startup does not need a config rollback write')
  assertDeepEqual(c.preview(c.config, c.pending), original, 'failed startup removes provisional placement')
  assertEqual(manager.status('test.one').error, 'worker could not start', 'failed startup retains actionable diagnostics after stopping')
  assertEqual(manager.stops.length, 1, 'failed startup stops its native instance')
}
{
  const {context: c, manager, writes} = fixture()
  c.enable('test.one', {section: 'right'})
  c.enable('test.two', {section: 'center'})
  c.config.bar.transparent = true
  c.config.plugins.push({id: 'unrelated', setting: 42})
  manager.instances['test.one'].state = 'running'
  c.settle()
  assertEqual(writes.length, 1, 'successful startup commits once')
  assertEqual(c.config.bar.layout.right[0].id, 'test.one', 'successful startup saves its own placement')
  assertEqual(c.config.bar.layout.center.length, 0, 'committing one startup cannot save another pending slot')
  assertEqual(c.config.bar.transparent, true, 'concurrent bar settings survive commit')
  assertEqual(c.config.plugins[0].setting, 42, 'unrelated plugin settings survive commit')
  manager.instances['test.two'].state = 'error'
  manager.instances['test.two'].error = 'second worker failed'
  c.settle()
  assertEqual(writes.length, 1, 'second failure cannot undo the first successful commit')
  assertEqual(c.config.bar.layout.right[0].id, 'test.one', 'first committed placement survives second failure')
}
{
  const initial = {version: 1, bar: {layout: {left: [{id: 'test.one', sandbox: true, volume: 0.5}], center: [], right: []}}, plugins: []}
  const {context: c, manager, writes} = fixture(initial)
  c.enable('test.one', {section: 'right'})
  assertEqual(c.preview(c.config, c.pending).bar.layout.right[0].volume, 0.5, 'provisional move retains original settings')
  manager.instances['test.one'].state = 'error'
  manager.instances['test.one'].error = 'failed graphics'
  c.settle()
  assertDeepEqual(c.config, initial, 'failed retry preserves previously saved enable and placement intent')
  assertEqual(writes.length, 0, 'failed retry never overwrites the prior saved configuration')
  c.enable('test.one', {section: 'right'})
  manager.instances['test.one'].state = 'running'
  c.settle()
  assertEqual(c.config.bar.layout.left.length, 0, 'successful retry removes the previous location')
  assertEqual(c.config.bar.layout.right[0].volume, 0.5, 'successful retry preserves prior inline settings')
}
{
  const {context: c, manager, writes} = fixture()
  c.enable('test.one', {section: 'right'})
  const stale = manager.instances['test.one']
  c.disable('test.one')
  stale.state = 'running'
  c.settle()
  assertEqual(writes.length, 0, 'late completion after cancellation cannot save enable intent')
  c.enable('test.one', {section: 'center'})
  manager.instances['test.one'] = {state: 'running', error: ''}
  c.settle()
  assertEqual(writes.length, 0, 'replaced native instance cannot complete an older request')
  assertEqual(Object.keys(c.pending).length, 0, 'stale requests are discarded')
}
{
  const {context: c, manager, writes} = fixture()
  assert(c.enable('test.one', {after: 'missing'}).includes('could not find'), 'invalid placement is rejected before native startup')
  assertEqual(manager.starts, 0, 'invalid placement never launches a worker')
  c.enable('test.one', {after: 'anchor'})
  c.config.bar.layout.left = []
  manager.instances['test.one'].state = 'running'
  c.settle()
  assertEqual(writes.length, 0, 'removed relative target cancels a pending commit')
  assert(manager.status('test.one').error.includes('could not find'), 'lost relative target has actionable diagnostics')
  c.enable('test.panel', {})
  assertEqual(c.config.plugins.length, 0, 'custom worker also defers saved enable intent')
  manager.instances['test.panel'].state = 'running'
  c.settle()
  assertEqual(c.config.plugins[0].id, 'test.panel', 'custom worker commits on actual readiness')
}
{
  const {context: c, manager, writes} = fixture()
  c.enable('test.one', {})
  c.config.bar.layout.right.push({id: 'test.one', sandbox: true, volume: 0.9})
  manager.instances['test.one'].state = 'running'
  c.settle()
  assertEqual(writes.length, 0, 'a conflicting explicit config edit wins over pending startup')
  assertEqual(c.config.bar.layout.right[0].volume, 0.9, 'conflicting config is preserved intact')
  assert(manager.status('test.one').error.includes('configuration changed'), 'conflicting config cancellation is reported')
}
{
  const {context: c, manager, writes} = fixture()
  c.enable('test.one', {section: 'right'})
  manager.instances['test.one'].state = 'running'
  assertEqual(c.status('test.one').state, 'starting', 'CLI readiness waits for the pending config commit')
  assertEqual(c.enable('test.one', {section: 'left'}), 'ok', 'a repeated enable can commit an already-ready session')
  c.settle()
  assertEqual(Object.keys(c.pending).length, 0, 'repeated ready enable retires the older pending request')
  assertEqual(manager.status('test.one').state, 'running', 'old pending completion cannot stop a newer successful enable')
  assertEqual(writes.length, 1, 'repeated ready enable commits only once')
  assertEqual(c.config.bar.layout.left[1].id, 'test.one', 'the newest explicit placement wins')
}
const shell = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
assert(shell.includes('return shell.sandboxActivation.enable(id, placement)'), 'production IPC uses the tested activation owner')
assert(shell.includes('config: shell.shellConfig') && shell.includes('writeConfig: next => shell.persistShellConfig(next)'), 'canonical config writes remain owned by the shell')
const session = fs.readFileSync(path.join(root, 'shell/services/native/SandboxedPluginSession.qml'), 'utf8')
{
  const {context: c, manager, writes} = fixture()
  c.enable('test.one', {section: 'right'})
  const first = copy(c.pending['test.one'])
  assert(c.enable('test.one', {section: 'left'}).includes('already starting'), 'competing placement is rejected while startup is pending')
  assert(c.enable('test.one', {section: 'right'}).includes('already starting'), 'duplicate pending enable has an explicit busy result')
  assertDeepEqual(c.pending['test.one'], first, 'rejected enable cannot replace pending placement or ownership')
  assertEqual(manager.starts, 1, 'duplicate startup does not start another controller')
  manager.instances['test.one'].state = 'running'
  c.settle()
  assertEqual(writes.length, 1, 'original startup commits once')
  assertEqual(c.config.bar.layout.right[0].id, 'test.one', 'first accepted placement wins')
}
{
  const expression = session.match(/readonly property string state: (.*)/)[1]
  const state = (ready, startupComplete, presented, error = '') => vm.runInNewContext(expression,
    {error, session: {ready}, startupComplete, screenRows: presented.map(value => ({surface: {presented: value}}))})
  assertEqual(state(true, false, []), 'starting', 'zero-output readiness cannot complete first startup')
  assertEqual(state(true, false, [false]), 'starting', 'an attached but unpresented output cannot complete startup')
  assertEqual(state(true, false, [true]), 'running', 'first presented content completes startup')
  assertEqual(state(true, true, []), 'running', 'output loss preserves an already-started logical service')
  assertEqual(state(false, true, []), 'starting', 'past presentation does not invent native readiness')
  assertEqual(state(true, true, [true], 'failed'), 'error', 'errors always override presentation state')
}
assert(session.includes('running: !root.startupComplete && root.state === "starting"'), 'startup deadline cannot kill an already-started session on output changes')
assert(session.includes('Ward plugin startup timed out before presenting content'), 'never-presenting startup has a bounded error state')
JS
