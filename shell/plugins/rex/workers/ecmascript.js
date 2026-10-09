// WorkerScript that runs patterns on Qt's own JavaScript engine, off the UI
// thread. Long searches are cut into slices: after each slice the worker
// posts what it found and waits for the host to ask for more, so a newer
// request can take over between slices.
//
// Requests:  { op: "match", id, source, plan, groups, flags, text, all, limit }
//            source and plan come from lib/Indices.js
//            { op: "continue", id }
// Replies:   { id, ok, done, matches, stride, error, elapsed }
// matches is flat: stride numbers per match, [start, end] for the whole
// match and then for every group, -1 for a group that did not take part.

var SLICE_MS = 40

var job = null

function compile(request) {
  var flags = "g"
  var allowed = "imuy"
  for (var i = 0; i < request.flags.length; i++) {
    if (allowed.indexOf(request.flags[i]) >= 0 && flags.indexOf(request.flags[i]) < 0) flags += request.flags[i]
  }
  return new RegExp(request.source, flags)
}

function step(current) {
  var started = Date.now()
  var re = current.re
  var text = current.text
  var out = []
  while (current.count < current.limit) {
    var m = re.exec(text)
    if (m === null) { current.finished = true; break }
    locate(m, current.plan, current.groups, out)
    current.count++
    if (m[0].length === 0) re.lastIndex = advance(text, re.lastIndex, current.unicode)
    if (!current.all) { current.finished = true; break }
    if (Date.now() - started > SLICE_MS) break
  }
  if (current.count >= current.limit) current.finished = true
  current.elapsed += Date.now() - started
  return out
}

// Group positions from the rewritten pattern's extra captures; see
// lib/Indices.js, whose locate() this mirrors (a WorkerScript cannot import
// a QML library).
function locate(m, plan, groups, out) {
  out.push(m.index, m.index + m[0].length)
  for (var g = 1; g <= groups; g++) {
    var p = plan[g - 1]
    var value = p ? m[p.index] : undefined
    if (value === undefined) { out.push(-1, -1); continue }
    var start = m.index
    for (var t = 0; t < p.terms.length; t++) {
      var piece = m[p.terms[t][0]]
      start += (piece === undefined ? 0 : piece.length) * p.terms[t][1]
    }
    out.push(start, start + value.length)
  }
}

function advance(text, index, unicode) {
  if (unicode && index < text.length) {
    var c = text.charCodeAt(index)
    if (c >= 0xd800 && c <= 0xdbff) return index + 2
  }
  return index + 1
}

function run(current) {
  var matches = step(current)
  WorkerScript.sendMessage({
    id: current.id,
    ok: true,
    done: current.finished,
    matches: matches,
    stride: current.stride,
    count: current.count,
    progress: current.finished ? 1 : current.re.lastIndex / Math.max(1, current.text.length),
    elapsed: current.elapsed,
  })
  if (current.finished) job = null
}

WorkerScript.onMessage = function(request) {
  if (request.op === "continue") {
    if (job && job.id === request.id) run(job)
    return
  }
  job = null
  var re
  try {
    re = compile(request)
  } catch (e) {
    WorkerScript.sendMessage({ id: request.id, ok: false, done: true, error: String(e.message || e), matches: [], stride: 2, count: 0, elapsed: 0 })
    return
  }
  job = {
    id: request.id,
    re: re,
    text: request.text,
    all: request.all !== false,
    limit: request.limit || 100000,
    stride: (request.groups + 1) * 2,
    groups: request.groups,
    plan: request.plan,
    unicode: request.flags.indexOf("u") >= 0,
    count: 0,
    finished: false,
    elapsed: 0,
  }
  run(job)
}
