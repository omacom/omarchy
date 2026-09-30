// Drives the agents panel's pace logic out of Panel.qml, with no QML runtime
// involved. Two kinds of thing are extracted and run:
//
//   1. the top-level window helpers (windowSpanMs, limitWindow, ...) — brace-
//      matched out of the file and evaluated in one scope, because they call
//      each other;
//   2. LimitRow's own property bindings (elapsed, paceCaption and the three
//      they depend on) — defined as real getters on one stand-in for
//      `limitRow`, so `paceCaption` reads the shipped `paceDelta`, which reads
//      the shipped `elapsed`, rather than a copy of them. A sign error or a
//      change to the unknown-state convention therefore fails here instead of
//      shipping.
//
//   node scripts/agents-pace-harness.js <path-to-Panel.qml>
//
// Exits non-zero on the first failed expectation.

const fs = require('fs')
const file = process.argv[2]

if (!file) {
  console.error('usage: node agents-pace-harness.js <Panel.qml>')
  process.exit(2)
}

const source = fs.readFileSync(file, 'utf8')

// Brace-match a named top-level function, string-aware so a brace inside a QML
// string or a line comment cannot end it early.
function extractFunction(name) {
  const start = source.indexOf('function ' + name + '(')
  if (start < 0) return null
  let quote = null
  let depth = 0
  for (let i = source.indexOf('{', start); i < source.length; i++) {
    const c = source[i]
    if (quote) {
      if (c === '\\') i++
      else if (c === quote) quote = null
      continue
    }
    if (c === '"' || c === "'" || c === '`') { quote = c; continue }
    if (c === '/' && source[i + 1] === '/') { i = source.indexOf('\n', i); if (i < 0) return null; continue }
    if (c === '{') depth++
    else if (c === '}') { depth--; if (depth === 0) return source.slice(start, i + 1) }
  }
  return null
}

// The same, for a `readonly property <type> <name>: { ... }` binding inside a
// named inline component. The opening brace has to be on the declaration's own
// line: a single-line binding such as `paceKnown: limitRow.elapsed >= 0` has no
// brace at all, and searching on for one would run into the next binding's
// block and return that body's source instead.
function extractBinding(component, name) {
  const from = source.indexOf('component ' + component)
  if (from < 0) return null
  const marker = 'readonly property '
  let at = from
  for (;;) {
    at = source.indexOf(marker, at)
    if (at < 0) return null
    const end = source.indexOf('\n', at)
    const declaration = source.slice(at, end)
    if (declaration.includes(' ' + name + ':')) {
      if (!declaration.includes('{')) return ' ' + declaration.slice(declaration.indexOf(name + ':') + name.length + 1).trim()
      const open = source.indexOf('{', at)
      let depth = 0
      for (let i = open; i < source.length; i++) {
        if (source[i] === '{') depth++
        else if (source[i] === '}') { depth--; if (depth === 0) return source.slice(open + 1, i) }
      }
      return null
    }
    at = end === -1 ? source.length : end
  }
}

const nowMs = Date.parse('2026-09-30T14:30:00Z')
const root = {
  nowMs,
  clamp: (v, lo, hi) => Math.max(lo, Math.min(hi, v)),
  resetMsFor(w) {
    if (!w || w.resetAt === '') return -1
    const ms = new Date(w.resetAt).getTime()
    return isFinite(ms) ? ms - nowMs : -1
  }
}

const names = ['clamp', 'windowIsLong', 'windowSpanMs', 'windowTitle', 'limitWindow', 'limitWindows']
// One eval, not one per function: windowSpanMs() calls windowIsLong() and
// limitWindow() calls windowSpanMs(), so they have to share a scope exactly as
// they do inside the QML object.
const bodies = names.map(extractFunction).filter(Boolean)
if (!bodies.length) {
  console.log('no limit-window helpers in this revision — nothing to drive')
  process.exit(0)
}
const available = Object.assign(
  {},
  new Function('root', bodies.join('\n') + '\nreturn { ' + names.join(', ') + ' };')(root)
)

let failed = false
function check(description, condition, detail) {
  if (condition) { console.log('ok - ' + description); return }
  failed = true
  console.error('not ok - ' + description)
  if (detail !== undefined) console.error(String(detail))
}

const iso = ms => new Date(nowMs + ms).toISOString()
const HOUR = 3600 * 1000
const DAY = 24 * HOUR

// A cycle has to be stated outright, and a context size is not a cycle even
// though it sits where a duration would: "Opus 5 (1M context) Session" is a
// five-hour session whose "1M" would otherwise parse as one minute — and "1m"
// is indistinguishable from it once lowercased, so the word "context" is the
// only tell. Two things must keep working around that: a collector labelling a
// window in bare minutes ("Rolling (30m)", including durations past an hour),
// and a collector stating a real cycle alongside a context size.
for (const [label, spanMs] of [
  ['Rolling (5h)', 5 * HOUR],
  ['5h window', 5 * HOUR],
  ['5 hours', 5 * HOUR],
  ['Session', 0],
  ['Weekly (7-day)', 7 * DAY],
  ['Monthly', 30 * DAY],
  ['30m window', 30 * 60 * 1000],
  ['Rolling (30m)', 30 * 60 * 1000],
  ['30m', 30 * 60 * 1000],
  ['30 minutes', 30 * 60 * 1000],
  ['30 min', 30 * 60 * 1000],
  ['45m window', 45 * 60 * 1000],
  ['90m window', 90 * 60 * 1000],
  ['120m window', 120 * 60 * 1000],
  ['Opus 5 (1M context) Session', 0],
  ['Opus 5 (1m context) Session', 0],
  ['Opus 5 (2M context) Session', 0],
  ['GPT 5.4 (1M context)', 0],
  ['Opus 5 (200K context) Session', 0],
  ['Opus 5 (1M context) 30m window', 30 * 60 * 1000],
  ['Opus 5 (1M context) Weekly', 7 * DAY],
  ['Opus 5 (1M context) 5h window', 5 * HOUR]
]) {
  check(
    'windowSpanMs reads ' + label,
    available.windowSpanMs(label) === spanMs,
    available.windowSpanMs(label) + ' != ' + spanMs
  )
}

// A collector-stated title still wins over the label, and the span still comes
// from the label: the two are read from different places on purpose.
const titled = available.limitWindows({ limits: [
  { label: 'Session (5-hour)', percent: 0.78, resetsAt: '' },
  { label: 'Opus 5 (1M context) Weekly', title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetsAt: '' }
] })
check('a collector-stated title is taken as it stands', titled[0].title === 'Session', JSON.stringify(titled[0]))
check('a 5-hour label keeps its span', titled[0].spanMs === 5 * HOUR, titled[0].spanMs)
check('a model-scoped weekly row keeps its span', titled[1].spanMs === 7 * DAY, titled[1].spanMs)

// Now LimitRow's own bindings. The five bodies are compiled together, in file
// order, with the QML property declaration turned into a plain assignment and
// the `limitRow.` qualifier dropped: the shipped expressions then read each
// other's computed values directly, so paceCaption is driven by the shipped
// paceDelta, which is driven by the shipped elapsed.
const limitRow = { window: null }
const bindingSpecs = ['real elapsed', 'bool paceKnown', 'real paceDelta', 'bool paceAhead', 'string paceCaption']
const bindingNames = bindingSpecs.map(spec => spec.split(' ').pop())
const bindingBodies = bindingNames.map(name => extractBinding('LimitRow', name))

let computeRow = null
if (bindingBodies.every(Boolean)) {
  // A block binding already ends in `return`; a single-line one is just an
  // expression, so it has to be returned from the wrapper or the wrapper
  // yields undefined and every property that reads it sees nothing.
  const wrap = body => (/^\s*return\b/m.test(body) ? body : 'return (' + body + ')')
  const program = bindingBodies
    .map((body, i) => 'var ' + bindingNames[i] + ' = (function(){' + wrap(body) + '})();')
    .join('\n')
    .replace(/limitRow\.(elapsed|paceKnown|paceDelta|paceAhead|paceCaption)\b/g, '$1')
  computeRow = new Function('root', 'limitRow', program + '\nreturn { ' + bindingNames.join(', ') + ' };').bind(null, root, limitRow)
}

if (!computeRow) {
  console.log('this revision keeps no pace bindings on LimitRow — pace logic absent by construction')
  process.exit(failed ? 1 : 0)
}

function row(label, percent, remainingMs, title) {
  limitRow.window = available.limitWindow(label, percent, iso(remainingMs), title)
  const computed = computeRow(root, limitRow)
  return { elapsed: computed.elapsed, caption: computed.paceCaption }
}

// resetsAt carries the time LEFT in the window: a 5h window 47 minutes from
// its reset is 84% elapsed, not 16%.
const rolling = row('Rolling (5h)', 0.02, 47 * 60 * 1000, '')
check('a 5h window with 47m left is ~84% elapsed', rolling.elapsed > 0.83 && rolling.elapsed < 0.85, rolling.elapsed)
check('a window behind the clock says so', rolling.caption === '82% behind', rolling.caption)

const weekly = row('Weekly (7-day)', 0.25, (4 * 24 + 10) * HOUR, '')
check('a 7d window with 4d10h left is ~37% elapsed', Math.abs(weekly.elapsed - 0.369) < 0.01, weekly.elapsed)
check('the weekly row says it is behind', weekly.caption === '12% behind', weekly.caption)

const ahead = row('Rolling (5h)', 0.99, 5 * HOUR - 20 * 60 * 1000, '')
check('a window ahead of the clock says so', ahead.caption === '92% ahead', ahead.caption)

const level = row('Rolling (5h)', Math.round(0.837 * 100) / 100, 47 * 60 * 1000, '')
check('a level window reads as on pace', level.caption === 'on pace', level.caption)

const unspanned = row('Opus 5 (1M context) Session', 0.4, 60 * 60 * 1000, '')
check('a window of unknown length has no elapsed position', unspanned.elapsed === -1, unspanned.elapsed)
check('a window of unknown length says nothing', unspanned.caption === '', JSON.stringify(unspanned.caption))

const spent = row('Rolling (5h)', 0.02, -60 * 1000, '')
check('an already-reset window has no elapsed position', spent.elapsed === -1, spent.elapsed)

const started = row('Rolling (5h)', 0.02, 5 * HOUR + 60 * 1000, '')
check('a window that has not started clamps to zero elapsed', started.elapsed === 0, started.elapsed)

process.exit(failed ? 1 : 0)
