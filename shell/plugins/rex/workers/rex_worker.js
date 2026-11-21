// Rex worker for V8's regex engine, through Node.js. Same protocol as
// rex_worker.py: one JSON request per line on stdin, replies one per line on
// stdout. JavaScript strings are UTF-16 already, and the d flag reports
// where every group matched.

const readline = require('readline')

const SLICE_MS = 50
const texts = new Map()
let current = 0

function send(reply) {
  process.stdout.write(JSON.stringify(reply) + '\n')
}

function names(re, m) {
  const out = {}
  if (!m || !m.groups) return out
  // Group numbers for names come from the order the names appear in the
  // pattern's own source.
  const source = re.source
  let index = 0
  const pattern = /\\.|\[(?:\\.|[^\]\\])*\]|\((\?<([A-Za-z_$][\w$]*)>|(?!\?))/g
  let t
  while ((t = pattern.exec(source)) !== null) {
    if (t[1] === undefined) continue
    index++
    if (t[2] && !(t[2] in out)) out[t[2]] = index
  }
  return out
}

async function run(request, text) {
  const id = request.id
  const allowed = 'imsuvy'
  let flags = 'gd'
  for (const f of request.flags || []) if (allowed.includes(f) && !flags.includes(f)) flags += f
  if (flags.includes('u') && flags.includes('v')) flags = flags.replace('u', '')
  let re
  try {
    re = new RegExp(request.pattern, flags)
  } catch (e) {
    send({ id, ok: false, done: true, error: e.message.replace(/^Invalid regular expression: /, ''), matches: [], stride: 2 })
    return
  }
  const limit = request.limit || 100000
  const all = request.all !== false
  const started = performance.now()
  let slice = started
  let out = []
  let count = 0
  let stride = null
  let first = null
  for (;;) {
    const m = re.exec(text)
    if (m === null) break
    if (stride === null) { stride = m.length * 2; first = m }
    for (const pair of m.indices) {
      if (pair) out.push(pair[0], pair[1])
      else out.push(-1, -1)
    }
    count++
    if (count >= limit || !all) break
    if (m[0].length === 0) {
      const code = text.charCodeAt(re.lastIndex)
      re.lastIndex += (re.unicode || re.unicodeSets) && code >= 0xd800 && code <= 0xdbff ? 2 : 1
    }
    if (performance.now() - slice > SLICE_MS) {
      send({ id, ok: true, done: false, matches: out, stride, elapsed: performance.now() - started })
      out = []
      // Let a newer request in before carrying on.
      await new Promise(resolve => setImmediate(resolve))
      if (current !== id && !request.keep) return
      slice = performance.now()
    }
  }
  if (stride === null) {
    // No match: the group count comes from matching the pattern or nothing.
    const probe = new RegExp('(?:' + request.pattern + ')|', flags.replace('g', '').replace('y', ''))
    stride = probe.exec('').length * 2
  }
  send({ id, ok: true, done: true, matches: out, stride, elapsed: performance.now() - started, names: names(re, first) })
}

const lines = readline.createInterface({ input: process.stdin })
lines.on('line', line => {
  let request
  try { request = JSON.parse(line) } catch { return }
  if (request.op === 'info') {
    send({ id: request.id, ok: true, done: true, versions: { node: 'Node ' + process.version + ', V8 ' + process.versions.v8 } })
    return
  }
  if ('textPath' in request) {
    // A file opened in Rex is read here rather than sent over the pipe.
    request.text = require('fs').readFileSync(request.textPath, 'utf8')
  }
  if ('text' in request) {
    texts.clear()
    texts.set(request.textId, request.text)
  }
  if (!texts.has(request.textId)) {
    send({ id: request.id, ok: false, done: true, error: 'missing-text', matches: [], stride: 2 })
    return
  }
  current = request.id
  run(request, texts.get(request.textId)).catch(e => send({ id: request.id, ok: false, done: true, error: String(e.message || e), matches: [], stride: 2 }))
})
