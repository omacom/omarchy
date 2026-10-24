#!/usr/bin/env node
// Run the agents panel's limit-row pace logic without a QML runtime.
//
//   node agents-pace-harness.js <path/to/Panel.qml>
//
// The panel's own code is what runs. The window helpers are brace-extracted and
// evaluated together, since they call one another, and CompactLimit's pace
// bindings — elapsed, paceKnown, paceDelta, paceCaption — are extracted and run
// as one program, so the caption is driven by the shipped paceDelta reading the
// shipped elapsed. A harness that re-implemented them would pass while the
// shipped bindings were wrong, which is the defect it exists to catch.
//
// Three extractor traps, each of which fakes a result rather than crashing:
//   * a single-line binding has no brace to match, so it is read to end of line —
//     and a multi-line expression body would be silently truncated, which is why
//     every binding here is either one line or a block;
//   * a block body already ends in `return`; an expression body does not, so the
//     wrapper has to add one or every reader sees `undefined`;
//   * the component reaches its own properties as `compact.<name>`, which the
//     compiled program has as locals.

const fs = require('fs')
const path = process.argv[2]
if (!path) {
  console.error('usage: agents-pace-harness.js <path/to/Panel.qml>')
  process.exit(2)
}
const source = fs.readFileSync(path, 'utf8')

const HELPERS = ['windowIsLong', 'windowSpanMs', 'windowTitle', 'limitWindow',
                 'limitWindows', 'displayWindows', 'scopedPart', 'resetMsFor', 'clamp']
const BINDINGS = ['elapsed', 'paceKnown', 'paceDelta', 'paceCaption']
const SELF = 'compact'

function extractBlock(from) {
  const start = from.indexOf('{')
  if (start < 0) return null
  let depth = 0
  let quote = null
  for (let i = start; i < from.length; i++) {
    const c = from[i]
    if (quote) {
      if (c === '\\') i++
      else if (c === quote) quote = null
      continue
    }
    if (c === '"' || c === "'") { quote = c; continue }
    if (c === '/' && from[i + 1] === '/') { i = from.indexOf('\n', i); if (i < 0) return null; continue }
    if (c === '{') depth++
    else if (c === '}') { depth--; if (depth === 0) return from.slice(start + 1, i) }
  }
  return null
}

function functionSource(name) {
  const at = source.indexOf('function ' + name + '(')
  if (at < 0) return null
  const open = source.indexOf('(', at)
  const close = source.indexOf(')', open)
  const body = extractBlock(source.slice(at))
  if (body === null) return null
  return { params: source.slice(open + 1, close), body }
}

function bindingBody(name) {
  const m = source.match(new RegExp('readonly property \\w+ ' + name + ':'))
  if (!m) return null
  const rest = source.slice(m.index + m[0].length).replace(/^\s*/, '')
  if (!rest.startsWith('{')) return { body: rest.split('\n')[0].trim(), block: false }
  const body = extractBlock(rest)
  return body === null ? null : { body, block: true }
}

const helperSources = HELPERS.map(functionSource)
const bindingBodies = BINDINGS.map(bindingBody)
for (let i = 0; i < HELPERS.length; i++)
  if (!helperSources[i]) { console.error('could not extract ' + HELPERS[i]); process.exit(1) }
for (let i = 0; i < BINDINGS.length; i++)
  if (!bindingBodies[i]) { console.error('could not extract binding ' + BINDINGS[i]); process.exit(1) }

const wrap = (body, block) => (block ? body : 'return (' + body + ')')
// The component reaches its own properties as `compact.<name>`, and the helpers
// as `root.<name>`; the compiled program has both as locals.
const strip = text => text
  .replace(new RegExp('\\b' + SELF + '\\.', 'g'), '')
  .replace(/\broot\./g, '')

const program = `
  var nowMs = 0
  function pace(window, fetchedAt) {
    var resetMs = resetMsFor(window)
    fetchedAt = fetchedAt || 0
    var ${BINDINGS.join(', ')}
    ${BINDINGS.map((name, i) =>
      name + ' = (function(){' + wrap(strip(bindingBodies[i].body), bindingBodies[i].block) + '})();').join('\n    ')}
    return { elapsed: elapsed, paceKnown: paceKnown, paceDelta: paceDelta, paceCaption: paceCaption, resetMs: resetMs }
  }
  return { pace: pace, setNow: function(v) { nowMs = v },
           windowSpanMs: windowSpanMs, windowTitle: windowTitle, limitWindows: limitWindows,
           displayWindows: displayWindows, resetMsFor: resetMsFor }
`

const build = new Function(
  helperSources.map((h, i) => 'function ' + HELPERS[i] + '(' + h.params + ') {' + strip(h.body) + '}').join('\n')
  + '\n' + program)
const panel = build()

let pass = 0
let fail = 0
function check(name, expected, actual) {
  const e = JSON.stringify(expected)
  const a = JSON.stringify(actual)
  if (e === a) { console.log('ok   - ' + name); pass++ }
  else { console.log('not ok - ' + name + '\n       expected: ' + e + '\n       actual:   ' + a); fail++ }
}

const HOUR = 3600 * 1000
const DAY = 24 * HOUR
const NOW = 1700000000000
panel.setNow(NOW)

// A window as the collector states it, run through the shipped limitWindow().
function window(label, percent, msLeft, title) {
  const resetAt = new Date(NOW + msLeft).toISOString()
  return panel.limitWindows({ limits: [{ label: label, percent: percent, resetsAt: resetAt, title: title }] })[0]
}
const paceOf = w => panel.pace(w)

// ---- the cycle a label names ----
for (const [label, span] of [
  ['Rolling (5h)', 5 * HOUR],
  ['5h window', 5 * HOUR],
  ['5 hours', 5 * HOUR],
  ['Weekly (7-day)', 7 * DAY],
  ['Monthly', 30 * DAY],
  ['Session', 0],
  ['30m window', 30 * 60 * 1000],
  ['Rolling (30m)', 30 * 60 * 1000],
  ['90m window', 90 * 60 * 1000],
  ['120m window', 120 * 60 * 1000],
  ['Opus 5 (1M context) Session', 0],
  ['Opus 5 (1m context) Session', 0],
  ['GPT 5.4 (1M context)', 0],
  ['Opus 5 (1M context) 30m window', 30 * 60 * 1000],
  ['Opus 5 (1M context) 5h window', 5 * HOUR],
  ['Opus 5 (1M context) Weekly', 7 * DAY]
]) {
  check('windowSpanMs reads ' + label, span, panel.windowSpanMs(label))
}

// ---- the elapsed fraction and the caption ----
let c = window('Rolling (5h)', 0.16, 47 * 60 * 1000)
check('a 5h window with 47m left is ~84% elapsed', 0.84, Math.round(paceOf(c).elapsed * 100) / 100)
check('and 68 points behind the clock reads as behind', '68% behind', paceOf(c).paceCaption)

c = window('Weekly (7-day)', 0.26, (4 * 24 + 10) * HOUR)
check('a 7d window with 4d10h left is ~37% elapsed', 0.37, Math.round(paceOf(c).elapsed * 100) / 100)
check('and 11 points behind reads as behind', '11% behind', paceOf(c).paceCaption)

// 90% used with two hours of a five-hour cycle left: 60% of the clock gone, so
// the fill is well past it.
c = window('Rolling (5h)', 0.9, 2 * HOUR)
check('a window ahead of the clock says so', '30% ahead', paceOf(c).paceCaption)

c = window('Rolling (5h)', 0.5, 2.5 * HOUR)
check('a level window reads as on pace', 'on pace', paceOf(c).paceCaption)

c = window('Session', 0.5, 30 * 60 * 1000)
check('a window of unknown length has no elapsed position', -1, paceOf(c).elapsed)
check('a window of unknown length says nothing', '', paceOf(c).paceCaption)

c = window('Opus 5 (1M context) Session', 0.5, 30 * 60 * 1000)
check('a model-scoped window is left unpaced', '', paceOf(c).paceCaption)

// A window whose reset has passed keeps no position: it is not 100% through, it
// is over, and the row shows a fresh window instead.
c = window('Rolling (5h)', 0.5, -60 * 1000)
check('an already-reset window has no elapsed position', -1, paceOf(c).elapsed)

// The elapsed fraction is clamped, so a reset further out than the cycle states
// cannot put the notch off the track.
c = window('Rolling (5h)', 0.5, 6 * HOUR)
check('a window before its cycle clamps to zero elapsed', 0, paceOf(c).elapsed)

// ---- a kept reading holds its position ----
// The percentage is frozen when a check fails, so the clock it is compared with
// has to be read at the same instant; otherwise the notch drifts while the fill
// stands still, and a stale row's pace reads as though it were being measured.
c = window('Rolling (5h)', 0.5, 2.5 * HOUR)
check('a fresh reading is on pace', 'on pace', paceOf(c).paceCaption)
const staleAt = NOW
panel.setNow(NOW + 45 * 60 * 1000)
check('a kept reading still reads the same an hour later', 'on pace', panel.pace(c, staleAt).paceCaption)
check('and its position is unchanged', 0.5, Math.round(panel.pace(c, staleAt).elapsed * 100) / 100)
check('while the countdown beside it does advance', 1.75 * HOUR, panel.pace(c, staleAt).resetMs)
panel.setNow(NOW)

// ---- the panel does not guess whether a window rolled ----
// A month is 28-31 days and its label says only "Monthly", so a 30-day assumption
// cannot tell a window that rolled from one that has just begun: a reading taken at
// the start of a 31-day month sits before the assumed start, and inferring a roll
// from that put the notch 17% into a month that had not moved. The collector
// declares a roll by stamping the record with it (bin/omarchy-agent-usage-grok);
// the panel reads the clock at whatever stamp it is given.
c = panel.limitWindows({ limits: [{ label: 'Monthly', percent: 0, resetsAt: new Date(NOW + 25 * DAY).toISOString() }] })[0]
check('a month read at its start sits at the start of its cycle', 0, panel.pace(c, NOW - 6 * DAY).elapsed)
check('and reads as on pace rather than behind', 'on pace', panel.pace(c, NOW - 6 * DAY).paceCaption)

// ---- the span survives the row-building ----
// displayWindows() attaches scoped allowances to their base row; it must not drop
// the cycle on the way through, or the meter loses its marker.
const built = panel.displayWindows({ limits: [
  { label: 'Rolling (5h)', percent: 0.4, resetsAt: new Date(NOW + 2 * HOUR).toISOString() },
  { label: 'Rolling (5h)', percent: 0.2, resetsAt: new Date(NOW + 2 * HOUR).toISOString(), title: 'Fable Session' }
] })
check('displayWindows keeps the cycle on the base row', 5 * HOUR, built[0].spanMs)
check('and attaches the scoped allowance to it', 1, built[0].scoped.length)
check('the scoped allowance keeps its own percent', 0.2, built[0].scoped[0].percent)

console.log('\n' + pass + ' passed, ' + fail + ' failed')
process.exit(fail === 0 ? 0 : 1)
