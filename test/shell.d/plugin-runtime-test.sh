#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const vm = require('vm')
const {spawnSync} = require('child_process')
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-plugin-runtime-test-'))
const store = path.join(temp, 'state')
const env = {...process.env, OMARCHY_PATH: root, OMARCHY_WARD_HOST: path.join(temp, 'missing-runtime'), OMARCHY_WARD_STORE: store}
const call = value => spawnSync('/bin/bash', ['-c', 'printf "%s" "$1" | "$2"', 'ward-runtime-test', JSON.stringify(value), path.join(root, 'bin/omarchy-ward-runtime')], {env, encoding: 'utf8', timeout: 5000})
try {
  for (const operation of ['revoke', 'remove']) {
    const result = call({operation, id: 'test.stock'})
    assertEqual(result.status, 0, `${operation} can acknowledge absence before a native store exists`)
    assertEqual(result.stdout.trim(), 'null', `${operation} retains the native management response shape`)
  }
  for (const request of [
    {operation:'approve', id:'test.stock'}, {operation:'remove', id:'../escape'},
    {operation:'remove', id:'test.stock', extra:true}, {operation:'remove', id:17},
    {operation:'remove', id:'a'.repeat(97)},
  ]) assert(call(request).status !== 0, 'absent runtime does not accept malformed or authority-creating request: ' + JSON.stringify(request))
  assert(!fs.existsSync(store), 'absence acknowledgements do not initialize native state')
  fs.symlinkSync(path.join(temp, 'missing-target'), store)
  assert(call({operation:'remove', id:'test.stock'}).status !== 0, 'dangling store symlink is not proof of an absent store')
  fs.unlinkSync(store)
  fs.mkdirSync(store, {mode:0o700})
  assert(call({operation:'remove', id:'test.stock'}).status !== 0, 'even an empty existing store requires the native runtime')
  fs.writeFileSync(path.join(store, 'test.stock.json'), 'possible approval')
  assert(call({operation:'revoke', id:'test.stock'}).status !== 0, 'existing approval cannot be bypassed by removing the runtime')
  assertEqual(fs.readFileSync(path.join(store, 'test.stock.json'), 'utf8'), 'possible approval', 'failed fallback preserves existing state')

  const registrySource = fs.readFileSync(path.join(root, 'shell/services/PluginRegistry.qml'), 'utf8')
  const functions = text => [...text.matchAll(/^  function \w+\([^\n]*\) \{[\s\S]*?^  \}/gm)].map(match => match[0]).join('\n')
  const registry = vm.createContext({scanning:true, rescanPending:false})
  vm.runInContext(functions(registrySource), registry)
  registry.rescan()
  assert(registry.rescanPending, 'identity refresh arriving during a scan is queued instead of discarded')

  const shellSource = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
  const start = shellSource.indexOf('    function listPlugins(')
  const end = shellSource.indexOf('\n    }', start) + '\n    }'.length
  const host = vm.createContext({shell:{pluginRegistry:{installedPlugins:{}}, sandboxedPlugins:{
    instances:{'test.running':{}, 'test.failed':{}},
    status: id => ({state:id === 'test.running' ? 'running' : 'error', error:''})
  }}})
  vm.runInContext(shellSource.slice(start, end).replace(/: string/g, ''), host)
  const rows = JSON.parse(host.listPlugins())
  assertEqual(rows.length, 2, 'host inventory includes native instances missing from the checkout registry')
  assert(rows.find(row => row.id === 'test.running').enabled, 'live session reports running independently of the checkout')
  assert(!rows.find(row => row.id === 'test.failed').enabled, 'an existing failed instance is not reported running')
} finally {
  fs.rmSync(temp, {recursive:true, force:true})
}
JS
