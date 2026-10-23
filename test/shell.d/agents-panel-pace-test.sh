#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The panel's limit-window functions are plain JavaScript; lift them out of
# Panel.qml and run them against fixed records.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

function lift(name) {
  const start = source.indexOf('  function ' + name + '(')
  assert(start >= 0, 'Panel.qml defines ' + name + '()')
  const end = source.indexOf('\n  }\n', start)
  return source.slice(start, end + 4)
}

const names = ['windowIsLong', 'windowSpanMs', 'windowTitle', 'limitWindow', 'limitWindows', 'subLimitWindows',
  'detailLines', 'explicitSpanMs', 'paceSpanMs', 'paceText', 'resetMsFor']
const H = 3600 * 1000
const nowMs = Date.parse('2026-01-10T00:00:00Z')
const panel = new Function('Commons', 'nowMs',
  'var root = { nowMs: nowMs }; root.resetMsFor = function(w) { return resetMsFor(w) };\n' +
  names.map(lift).join('\n') +
  '\nreturn { paceSpanMs: paceSpanMs, paceText: paceText, limitWindows: limitWindows }')(
  { I18n: { formatNumber: (v, d) => Number(v).toFixed(d) } }, nowMs)

const at = (ms) => new Date(nowMs + ms).toISOString()

assertEqual(panel.paceSpanMs({ label: 'Weekly (7-day)' }, 'claude'), 7 * 24 * H, 'a 7-day window is a week, not a day')
assertEqual(panel.paceSpanMs({ label: '7 days' }, 'kimi'), 7 * 24 * H, 'a "7 days" window is a week')
assertEqual(panel.paceSpanMs({ label: 'Daily' }, 'kimi'), 24 * H, 'a daily window is a day')
assertEqual(panel.paceSpanMs({ label: '24h window' }, 'codex'), 24 * H, 'a 24h window is a day')
assertEqual(panel.paceSpanMs({ label: 'Session (5-hour)' }, 'claude'), 5 * H, 'a 5-hour session is five hours')
assertEqual(panel.paceSpanMs({ label: 'Session' }, 'claude'), 5 * H, 'an unlabeled session falls back to five hours')
assertEqual(panel.paceSpanMs({ label: 'Included total', windowSeconds: 86400 * 30 }, 'cursor'), 30 * 24 * H, 'a stated window beats the label')
assertEqual(panel.paceSpanMs({ label: 'Opus' }, 'claude'), 0, 'an unknown window gives no span')

const weekly = panel.limitWindows({ providerId: 'claude', limits: [{ label: 'Weekly (7-day)', percent: 0.2, resetsAt: at(71 * H) }] })[0]
assertEqual(panel.paceText(weekly), 'φ 0.3', 'φ projects a weekly window over the whole week')

const parent = { label: 'Weekly', percent: 0.4, resetsAt: at(-H), subLimits: [
  { label: 'Build', percent: 0.5 },
  { label: 'Own reset', percent: 0.6, resetsAt: at(-2 * H) },
  { label: 'Live', percent: 0.7, resetsAt: at(3 * H) }
] }
const subs = panel.limitWindows({ providerId: 'grok', limits: [parent] })[0].subLimits
assertEqual(subs[0].percent, 0, "a sub-limit on its parent's clock empties when the parent resets")
assertEqual(subs[1].percent, 0, 'a sub-limit with its own past reset empties too')
assertEqual(subs[2].percent, 0.7, 'a sub-limit whose reset is ahead keeps its usage')
assert(subs.every((s) => s.hideReset === true), 'a sub-limit without its own window shows no countdown')

const timed = panel.limitWindows({ providerId: 'grok', limits: [{ label: 'Weekly', percent: 0.1, resetsAt: at(H),
  subLimits: [{ label: 'Own', percent: 0.3, resetsAt: at(2 * H), windowSeconds: 4 * 3600 }] }] })[0].subLimits[0]
assertEqual(timed.hideReset, false, 'a sub-limit with its own reset and window shows its countdown')
assertEqual(panel.paceText(timed), 'φ 0.6', 'a sub-limit with its own window gets its own φ')

assert(/fontSize: Style\.font\.caption\s+window: modelData\s+stale: block\.stale\s+fetchedAt: block\.fetchedAt/.test(source),
  'sub-limit rows say when their numbers are stale, like their parent row')
JS
