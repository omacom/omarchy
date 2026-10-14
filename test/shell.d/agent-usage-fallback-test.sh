#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A usage update replaces each record with an atomic mv. When inotify cannot
# rearm on the new inode (watch quota, ENOSPC), the record's FileView goes
# quiet, so the panel reloads every record once the update process exits
# (#9974). Run the real QML functions in a VM to check both halves: the exit
# reloads every agent, and a reload of an unchanged file leaves the record be.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

function extract(source, signature, file) {
  const start = source.indexOf(`  ${signature}`)
  assert(start >= 0, `found ${signature} in ${file}`)
  const end = source.indexOf('\n  }', start)
  assert(end > start, `found the end of ${signature} in ${file}`)
  return source.slice(start, end + '\n  }'.length)
}

const main = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const agent = fs.readFileSync(root + '/shell/plugins/agents/Agent.qml', 'utf8')

const updateStart = main.indexOf('    id: updateProcess')
const exited = main.slice(main.indexOf('    onExited: {', updateStart), main.indexOf('\n    }', updateStart))
assert(exited.includes('root.reloadRecords()'), 'the update process reloads every record when it exits')

const panel = { agents: [] }
vm.createContext(panel)
vm.runInContext(extract(main, 'function reloadRecords() {', 'Main.qml'), panel)
const reloaded = []
panel.agents = [{ reload: () => reloaded.push('claude') }, null, { reload: () => reloaded.push('codex') }]
panel.reloadRecords()
assertDeepEqual(reloaded, ['claude', 'codex'], 'reloadRecords reloads each agent record')

assert(agent.includes('function reload() { agentFile.reload() }'), 'an agent reloads through its FileView')
const record = { record: null, parsedText: '', path: 'codex.json', console: { warn() {} } }
record.root = record
vm.createContext(record)
vm.runInContext(extract(agent, 'function clear() {', 'Agent.qml') + '\n' + extract(agent, 'function parse(content) {', 'Agent.qml'), record)

record.parse('{"id":"codex","todayPrompts":1}')
const first = record.record
assertEqual(first.todayPrompts, 1, 'a record is parsed from its file')
record.parse('{"id":"codex","todayPrompts":1}')
assert(record.record === first, 'reloading an unchanged file keeps the same record')
record.parse('{"id":"codex","todayPrompts":2}')
assertEqual(record.record.todayPrompts, 2, 'a changed file replaces the record')
record.parse('not json')
assertEqual(record.record, null, 'a bad file clears the record')
record.parse('{"id":"codex","todayPrompts":2}')
assertEqual(record.record.todayPrompts, 2, 'the record comes back once the file is good again')
JS
