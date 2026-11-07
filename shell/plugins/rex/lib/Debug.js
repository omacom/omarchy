.pragma library

// Reading the PCRE2 debugger's steps. A step, as the worker reports it:
// [attemptStart, position, patternStart, patternLength, flags, g1s, g1e, ...]
// with offsets in UTF-16 units; flags bit 1 marks a new match attempt, bit 2
// a backtrack since the step before.

var STARTMATCH = 1
var BACKTRACK = 2

function quote(text, start, end) {
  var s = text.substring(start, end)
  if (s.length > 24) s = s.substr(0, 23) + "…"
  return JSON.stringify(s)
}

// One line saying what the engine is about to do.
function describe(step, pattern, text) {
  var item = step[3] > 0 ? pattern.substr(step[2], step[3]) : ""
  var where = "at " + step[1]
  var what
  if (step[3] === 0) what = step[2] >= pattern.length ? "End of the pattern: a match" : "End of a group or alternative"
  else what = "Try " + item + " " + where + (step[1] < text.length ? ", facing " + quote(text, step[1], step[1] + 1) : ", at the end of the text")
  var notes = []
  if (step[4] & STARTMATCH) notes.push("new attempt from " + step[0])
  if (step[4] & BACKTRACK) notes.push("after backtracking")
  return notes.length ? what + " (" + notes.join(", ") + ")" : what
}

// How many times each item of the pattern was tried, busiest first:
// [{ start, length, count, backtracks }]. The busiest items are where a slow
// pattern spends its time.
function hotspots(steps) {
  var byItem = {}
  for (var i = 0; i < steps.length; i++) {
    var s = steps[i]
    if (s[3] === 0) continue
    var key = s[2] + ":" + s[3]
    var entry = byItem[key]
    if (!entry) entry = byItem[key] = { start: s[2], length: s[3], count: 0, backtracks: 0 }
    entry.count++
    if (s[4] & BACKTRACK) entry.backtracks++
  }
  var out = []
  for (var k in byItem) out.push(byItem[k])
  out.sort(function(a, b) { return b.count - a.count || a.start - b.start })
  return out
}

function summary(reply, steps) {
  var n = steps.length
  var stepText = n === 1 ? "1 step" : n + " steps"
  if (reply.stopped) return "Stopped after " + stepText + ": PCRE2 would keep going. This pattern backtracks heavily on this text."
  if (reply.limit) return "PCRE2 gave up after " + stepText + ": " + reply.limit
  if (reply.match) return "A match at " + reply.match[0] + "–" + reply.match[1] + " after " + stepText
  return "No match, after " + stepText
}

// Attempts: the index of each step that starts a new attempt.
function attempts(steps) {
  var out = []
  for (var i = 0; i < steps.length; i++) if (i === 0 || (steps[i][4] & STARTMATCH)) out.push(i)
  return out
}

if (typeof module !== "undefined") module.exports = { describe: describe, hotspots: hotspots, summary: summary, attempts: attempts, STARTMATCH: STARTMATCH, BACKTRACK: BACKTRACK }
