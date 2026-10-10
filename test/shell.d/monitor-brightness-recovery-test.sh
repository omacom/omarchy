#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Drive the real QML callbacks with fake processes and a callLater queue.
# This exercises completion ordering without accessing hardware or a session.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/panels/monitor/BrightnessController.qml'), 'utf8')
const model = requireFromRoot('shell/plugins/panels/monitor/Model.js')
function controller() {
  const queue = []
  const state = vm.createContext({
    helperDirectory: '/fixture/', targetName: 'DP-1', identity: 'Monitor', hardwareIdentity: 'old',
    active: true, suspended: false, available: true, value: 30, status: 'available',
    revision: 1, pendingValue: -1, error: '', failures: 0,
    reader: {running: false, requestRevision: -1, received: false},
    writer: {running: true, requestRevision: 1, received: false},
    debounce: {running: false, stop() { this.running = false }},
    writeError: {text: ''}, Model: model,
    Qt: {callLater(fn) { if (!queue.includes(fn)) queue.push(fn) }}
  })
  state.root = state
  Object.defineProperties(state, {
    busy: {get() { return state.writer.running || state.debounce.running || state.pendingValue >= 0 }},
    requestRevision: {get() { return state.writer.requestRevision }},
    received: {get() { return state.writer.received }}
  })
  for (const name of ['command', 'invalidate', 'read', 'flush', 'accept']) {
    const match = source.match(new RegExp('^  function ' + name + '\\([^\\n]*\\) \\{[\\s\\S]*?^  \\}', 'm'))
    if (!match) fail('brightness callback is present: ' + name)
    vm.runInContext(match[0], state)
  }
  const writer = source.slice(source.indexOf('    id: writer'))
  const exit = writer.match(/onExited: function\(code\) \{([\s\S]*?)^    \}/m)
  const stdout = writer.match(/onStreamFinished: ([^\n]+)/)
  vm.runInContext('function writerExited(code) {' + exit[1] + '}\n'
    + 'function writerOutput(text) {' + stdout[1] + '}', state)
  return {
    state,
    drain() { while (queue.length) queue.shift()() },
    exit(code = 0) { state.writer.running = false; state.writerExited(code); this.drain() }
  }
}

const changed = controller()
changed.state.hardwareIdentity = 'new'
changed.state.invalidate()
changed.drain()
assertEqual(changed.state.reader.running, false, 'identity refresh waits for the in-flight writer')
changed.state.writerOutput(JSON.stringify({name: 'DP-1', description: 'Monitor', identity: 'old', status: 'available', brightness: 70}))
assertEqual(changed.state.available, false, 'obsolete writer output cannot restore old brightness')
changed.exit()
assertEqual(changed.state.reader.running, true, 'writer completion immediately retries an interrupted identity read')
assertEqual(changed.state.reader.command.at(-1), 'new', 'recovery reads the new hardware identity')

const queued = controller()
queued.state.revision++
queued.state.pendingValue = 80
queued.exit()
assertEqual(queued.state.writer.running, true, 'a newer slider value takes priority over a metadata read')
assertDeepEqual(queued.state.writer.command.slice(-2), ['--value', '80'], 'queued write keeps the latest slider value')
assertEqual(queued.state.reader.running, false, 'queued write does not start a competing reader')

for (const field of ['active', 'suspended']) {
  const deferred = controller()
  deferred.state.invalidate()
  deferred.drain()
  deferred.state[field] = field === 'suspended'
  deferred.exit()
  assertEqual(deferred.state.reader.running, false, 'completion respects ' + field + ' before recovery')
  deferred.state[field] = field === 'active'
  deferred.state.read()
  assertEqual(deferred.state.reader.running, true, 'recovery can resume after changing ' + field)
}

const failed = controller()
failed.exit(1)
assertEqual(failed.state.status, 'io_error', 'current-revision write failure remains an error')
assertEqual(failed.state.reader.running, false, 'write failures do not create an immediate retry loop')
JS
