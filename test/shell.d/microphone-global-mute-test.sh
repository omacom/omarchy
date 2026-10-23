#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const widget = fs.readFileSync(path.join(root, 'shell/plugins/bar/widgets/Microphone.qml'), 'utf8')
function body(text, name) {
  const start = text.indexOf('function ' + name + '(')
  if (start < 0) throw new Error('Missing function ' + name)
  let brace = text.indexOf('{', start), depth = 1, i = brace + 1
  for (; depth; i++) { if (text[i] === '{') depth++; if (text[i] === '}') depth-- }
  return text.slice(brace + 1, i - 1)
}
const microphones = ['default', 'discord', 'virtual'].map(name => ({name, mute: false, audio: {muted: false}}))
const calls = []
const context = {source: microphones[0], viaWpctl: false, MicrophoneMute: {toggle: () => calls.push('global')}}
vm.runInNewContext('(function(){' + body(widget, 'toggleMute') + '})()', context)
assertDeepEqual(calls, ['global'], 'bar microphone click delegates to the global microphone controller')
const model = requireFromRoot('shell/Commons/MicrophoneMuteModel.js')
const sources = model.parseSources(JSON.stringify([
  ...microphones.map((s, i) => ({...s, index: i, monitor_of_sink: null})),
  {index: 9, name: 'speaker.monitor', mute: false, monitor_source: 'speaker'},
  {index: 10, name: 'legacy.monitor', mute: false, monitor_of_sink: 7}
]))
assertDeepEqual(sources.map(s => s.name), ['default', 'discord', 'virtual'], 'all physical and virtual inputs are included; output monitors are excluded')
assert(!model.allMuted(sources), 'live inputs do not show global mute')
sources[0].muted = true
assert(!model.allMuted(sources), 'muting only the default input does not show global mute')
for (const s of sources) s.muted = true
assert(model.allMuted(sources), 'global mute requires every input to be muted')
assert(!model.allMuted([]), 'no inputs is not a confirmed global mute')
assertEqual(model.parseSources('invalid'), null, 'invalid server state is unknown rather than muted')
assertEqual(model.parseSources('[{"name":"mic"}]'), null, 'missing mute state is not accepted as confirmation')
JS

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const model = requireFromRoot('shell/Commons/MicrophoneMuteModel.js')
const qml = fs.readFileSync(path.join(root, 'shell/Commons/MicrophoneMute.qml'), 'utf8')
const functions = qml.slice(qml.indexOf('  function refresh()'), qml.indexOf('\n  Process {'))

function controller(initial, denied) {
  const scheduled = [], writes = []
  let server = initial.map(s => ({...s}))
  const reader = {running: false}
  const writer = {running: false, command: []}
  const monitor = {sourceEventsRunning: true}
  const ctx = {reader, writer, UntypedInput: monitor, Model: model,
    Qt: {callLater: fn => scheduled.push(fn)}, console: {warn: () => {}},
    sources: [], snapshotKnown: false, writing: false, queue: [],
    toggleRequested: false, readAgain: false, targetMuted: false}
  ctx.root = ctx
  Object.defineProperty(ctx, 'busy', {get: () => ctx.writing})
  Object.defineProperty(ctx, 'known', {get: () => ctx.snapshotKnown && monitor.sourceEventsRunning})
  Object.defineProperty(ctx, 'muted', {get: () => ctx.known && model.allMuted(ctx.sources)})
  vm.createContext(ctx)
  vm.runInContext(functions, ctx)
  const flush = () => { while (scheduled.length) scheduled.shift()() }
  function completeRead(code = 0, snapshot = server) {
    assert(reader.running, 'the controller requested a source snapshot')
    reader.running = false
    ctx.finishRead(code, JSON.stringify(snapshot.map(s => ({name:s.name, mute:s.muted, monitor_source:''}))))
    flush()
  }
  function completeWrite() {
    assert(writer.running, 'the controller started a serialized mute write')
    const args = Array.from(writer.command)
    writes.push(args)
    const source = server.find(s => s.name === args[2])
    const failed = args[2] === denied
    if (source && !failed) source.muted = args[3] === '1'
    writer.running = false
    ctx.finishWrite(failed ? 1 : 0)
    // A new write must wait until the Process's exit signal has returned.
    assert(!writer.running, 'the next process starts after the exit handler returns')
    flush()
  }
  return {ctx, reader, writer, monitor, writes, completeRead, completeWrite,
    server: () => server, addSource: source => server.push(source)}
}

const initial = [{name:'default',muted:true}, {name:'discord',muted:false}, {name:'virtual',muted:false}]
const c = controller(initial)
c.ctx.toggle()
assert(c.reader.running && c.ctx.toggleRequested, 'a click reads current sources before writing')
c.ctx.toggle()
assertEqual(c.writes.length, 0, 'a second click during the read does not race the first')
c.completeRead()
assert(c.ctx.busy && !c.ctx.muted, 'real read completion starts the queue without displaying success')
for (let i = 0; i < 3; i++) c.completeWrite()
assertDeepEqual(c.writes, initial.map(s => ['pactl','set-source-mute',s.name,'1']), 'the real read-to-write transition mutes every input exactly once')
assert(c.reader.running && !c.ctx.muted, 'writes alone never assert global mute')
c.completeRead()
assert(c.ctx.muted, 'only the confirming snapshot asserts global mute')
c.ctx.toggle(); c.completeRead()
for (let i = 0; i < 3; i++) c.completeWrite()
c.completeRead()
assert(c.server().every(s => !s.muted) && !c.ctx.muted, 'a second click explicitly unmutes every input')

const failed = controller(initial, 'discord')
failed.ctx.toggle(); failed.completeRead()
for (let i = 0; i < 3; i++) failed.completeWrite()
failed.completeRead()
assert(!failed.ctx.muted, 'a denied input cannot produce a globally muted icon')
assertEqual(failed.writes.length, 3, 'a failed write does not prevent the other inputs being muted')

const hotplug = controller(initial)
hotplug.ctx.toggle()
const stale = hotplug.server().map(s => ({...s}))
hotplug.addSource({name:'new-microphone',muted:false})
hotplug.ctx.refresh() // source event while the reader is in flight
hotplug.completeRead(0, stale)
assertEqual(hotplug.writes.length, 0, 'a stale snapshot cannot choose the mute targets')
assert(hotplug.reader.running, 'a device event during a read requests a newer snapshot')
hotplug.completeRead()
for (let i = 0; i < 4; i++) hotplug.completeWrite()
hotplug.completeRead()
assert(hotplug.ctx.muted && hotplug.server().every(s => s.muted), 'the click includes a microphone connected during its first read')

const disconnected = controller(initial.map(s => ({...s,muted:true})))
disconnected.monitor.sourceEventsRunning = false
disconnected.ctx.refresh(); disconnected.completeRead()
assert(!disconnected.ctx.known && !disconnected.ctx.muted, 'a successful one-shot read cannot assert global mute without a running subscription')
disconnected.monitor.sourceEventsRunning = true
disconnected.ctx.refresh(); disconnected.completeRead()
assert(disconnected.ctx.muted, 'a fresh snapshot with monitoring restored can confirm global mute')
disconnected.ctx.refresh(); disconnected.completeRead(1)
assert(!disconnected.ctx.known && !disconnected.ctx.muted, 'a failed source query clears the success indicator')
JS
