// Execute the production QML scheduling bodies with a controlled clock and
// process lifecycle. This is a scheduling contract test, not a live UI test.
const assert = require('node:assert/strict')
const fs = require('node:fs')
const vm = require('node:vm')
const path = require('node:path')
const text = fs.readFileSync(path.join(process.argv[2], 'shell/plugins/agents/Main.qml'), 'utf8')
function block(source, start) {
  const open = source.indexOf('{', start)
  let depth = 0, quote = null, escaped = false, comment = false
  for (let i = open; i < source.length; i++) {
    const c = source[i]
    if (comment) { if (c === '\n') comment = false; continue }
    if (quote) {
      if (escaped) escaped = false
      else if (c === '\\') escaped = true
      else if (c === quote) quote = null
      continue
    }
    if (c === '/' && source[i + 1] === '/') { comment = true; i++; continue }
    if (c === '"' || c === "'" || c === '`') { quote = c; continue }
    if (c === '{') depth++
    if (c === '}' && --depth === 0) return source.slice(open + 1, i)
  }
  throw Error('Unclosed production block')
}
function object(id) {
  const index = text.indexOf('id: ' + id + '\n')
  assert.notEqual(index, -1, 'missing production object ' + id)
  const start = text.lastIndexOf('{', index)
  return block(text, start)
}
const poll = object('remotePoll')
assert.match(poll, /interval:\s*60000\b/)
assert.match(poll, /triggeredOnStart:\s*true/)
assert.match(poll, /repeat:\s*true/)
const starts = [], later = []
function fakeProcess(name) {
  let running = false
  return { command: [], get running() { return running }, set running(value) {
    if (value && !running) starts.push(name)
    running = value
  } }
}
let now = 100000000
const root = { remoteMachines: [], selectedMachineId: 'all', remoteRefreshPending: false,
  remoteForcePending: false, machineError: '', machineCommandFinished() {} }
const remoteRefresh = fakeProcess('background'), machineCommand = fakeProcess('manual')
const context = vm.createContext({ root, remoteRefresh, machineCommand,
  remoteRecord: { reload() {} }, Qt: { callLater(fn) { later.push(fn) } }, Date: class extends Date {
    static now() { return now }
  } })
for (const name of ['remoteRefreshDue', 'scheduleRemoteRefresh', 'refreshMachines', 'manageMachine']) {
  const match = new RegExp('function ' + name + '\\(([^)]*)\\)').exec(text)
  assert.ok(match, 'missing scheduling function ' + name)
  root[name] = vm.runInContext('(function(' + match[1] + ') {' + block(text, match.index) + '})', context)
}
const trigger = vm.runInContext('(function(){' + block(poll, poll.indexOf('onTriggered:')) + '})', context)
const background = object('remoteRefresh'), manual = object('machineCommand')
const backgroundExit = vm.runInContext('(function(){' + block(background, background.indexOf('onExited:')) + '})', context)
const manualExit = vm.runInContext('(function(code){' + block(manual, manual.indexOf('onExited:')) + '})', context)
function finishBackground() { remoteRefresh.running = false; backgroundExit(); while (later.length) later.shift()() }
function finishManual() { machineCommand.running = false; manualExit(0); while (later.length) later.shift()() }
// Startup without configured machines must not fork a process every minute.
trigger(); assert.equal(starts.length, 0)
root.remoteMachines = [{id:'one'}]
trigger(); assert.deepEqual(starts, ['background'])
root.remoteMachines = [{id:'one', attemptedAt: now / 1000}]
finishBackground()
now += 3599000; trigger(); assert.equal(starts.length, 1)
now += 1000; trigger(); assert.equal(starts.length, 2)
// A manual refresh during background work is queued, not lost to the lock.
root.refreshMachines(); assert.equal(machineCommand.running, false)
root.remoteMachines[0].attemptedAt = now / 1000
finishBackground()
assert.equal(machineCommand.running, true)
assert.deepEqual(Array.from(machineCommand.command), ['omarchy-agent-machine', 'refresh', '--force'])
root.remoteMachines[0].attemptedAt = 0
trigger(); assert.equal(remoteRefresh.running, false, 'background must wait for the manual command')
root.remoteMachines[0].attemptedAt = now / 1000
finishManual(); finishBackground()
// The continuation timestamp is independent of the hourly normal refresh.
root.remoteMachines[0].attemptedAt = now / 1000
root.remoteMachines[0].nextAttemptAt = now / 1000 + 60
const before = starts.length
now += 59000; trigger(); assert.equal(starts.length, before)
now += 1000; trigger(); assert.equal(starts.length, before + 1)
root.remoteMachines[0].nextAttemptAt = now / 1000 + 300
finishBackground(); trigger(); assert.equal(starts.length, before + 1)
// Selection is not a scheduling input or a property-change fetch handler.
assert.doesNotMatch(text, /onSelectedMachineIdChanged\s*:/)
for (const selected of ['all', 'local', 'one', 'all']) root.selectedMachineId = selected
assert.equal(starts.length, before + 1)
assert.doesNotMatch(block(text, text.indexOf('function remoteRefreshDue(')), /selectedMachineId/)
console.log('ok - production scheduling: startup, hourly, bounded continuation, queued manual refresh and selection isolation')
