const fs = require('fs'), vm = require('vm'), assert = require('assert')
const source = fs.readFileSync(process.argv[2], 'utf8')
function extract(name) {
  const start = source.indexOf('  function ' + name + '(')
  assert(start >= 0, name)
  let depth = 0, opened = false
  for (let i = start; i < source.length; i++) {
  if (source[i] === '{') { depth++; opened = true }
  if (source[i] === '}' && --depth === 0 && opened) return source.slice(start, i + 1)
  }
  throw Error('unclosed function')
}
let now = 20000, jobs = []
const context = {Date: {now: () => now}, lastUpdateStartedMs: 0, pendingUpdateKind: '', updateProcess: {running: false}, updateCommand: (kind, ids) => {jobs.push(kind); return [kind]}, root: null}
context.root = context
vm.createContext(context)
for (const name of ['runUpdate','refresh','refreshAll','refreshLimits']) vm.runInContext(extract(name), context)
context.refreshLimits(); assert.deepEqual(jobs, ['limits'])
context.refreshLimits(); assert.equal(context.pendingUpdateKind, '')
context.updateProcess.running = false
now += 14999; context.refreshLimits(); assert.equal(jobs.length, 1)
now++; context.refreshLimits(); assert.deepEqual(jobs, ['limits','limits'])
context.updateProcess.running = false
context.refresh(); assert.deepEqual(jobs, ['limits','limits','force'])
context.refresh(); assert.equal(context.pendingUpdateKind, 'force')
console.log('ok - reopen reuses running/recent refresh; expiry and explicit forced refresh remain effective')
