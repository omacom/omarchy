#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

// Lift the helpers out of Panel.qml as written, so the checks run the QML's
// own ranking rather than a copy of it.
function qmlFunction(name) {
  const start = panelSource.indexOf(`  function ${name}(`)
  if (start < 0) fail(`Panel.qml defines ${name}`)
  let depth = 0
  for (let i = panelSource.indexOf('{', start); i < panelSource.length; i++) {
    if (panelSource[i] === '{') depth++
    else if (panelSource[i] === '}' && --depth === 0) return panelSource.slice(start, i + 1)
  }
  fail(`Panel.qml closes ${name}`)
}

const names = ['clamp', 'windowIsLong', 'windowSpanMs', 'windowTitle', 'limitWindow', 'limitWindows',
  'formatDuration', 'currencyPrefix', 'formatMoney', 'radarWindow', 'radarRow', 'radarRanking']
const radar = new Function(names.map(qmlFunction).join('\n') + '\nreturn { radarRanking }')()

const hour = 3600 * 1000
const now = Date.parse('2026-09-29T12:00:00Z')
const at = ms => new Date(now + ms).toISOString()
const limit = (label, percent, resetIn, title) => ({ label, percent, resetsAt: at(resetIn), ...(title ? { title } : {}) })

const rows = radar.radarRanking([
  { providerId: 'claude', providerName: 'Claude', limits: [
    limit('Session (5-hour)', 0.95, 2 * hour),
    limit('Weekly (7-day)', 0.11, 150 * hour),
    limit('Fable Weekly', 0.0, 150 * hour, 'Fable Weekly')] },
  { providerId: 'codex', providerName: 'Codex', limits: [limit('Weekly (7-day)', 0.40, 94 * hour)] },
  { providerId: 'cursor', providerName: 'Cursor', limits: [limit('Other Models', 1.0, 286 * hour, 'Other Models')] },
  { providerId: 'antigravity', providerName: 'Antigravity', limits: [
    limit('Gemini Weekly', 0.25, 40 * hour, 'Gemini Weekly'),
    limit('Gemini Session', 0.0, 3 * hour, 'Gemini Session'),
    limit('Cursor-like pool', 0.60, 40 * hour, 'Claude / GPT Weekly')] },
  { providerId: 'fireworks', providerName: 'Fireworks', balance: { funded: 20, remaining: 5, currency: 'USD' } },
  { providerId: 'local', providerName: 'Local', limits: [] },
], now)

assertDeepEqual(rows.map(r => r.providerId), ['claude', 'antigravity', 'codex', 'fireworks', 'cursor'],
  'radar ranks by weekly headroom, prepaid by credit left, spent last, no-limit agents out')
assertEqual(rows[0].label, '89% left', 'radar reads the weekly window, not the session burst')
assertEqual(rows[0].when, 'Resets in 6d 6h', 'radar says when the weekly window resets')
assertEqual(rows[0].window, '', 'radar keeps the plain weekly unnamed')
assertEqual(rows[3].label, '$5.00 left', 'radar shows prepaid credit in money')
assertEqual(rows[4].label, 'spent', 'radar marks a spent allowance')
assertEqual(rows[4].when, 'Back in 11d 22h', 'radar says when a spent allowance comes back')
assertEqual(rows[4].window, 'Other Models', 'radar names a model-scoped pool when it is the only one')
assertEqual(rows[1].label, '75% left', 'radar reads a split allowance by its roomiest pool, never its session')
assertEqual(rows[1].window, 'Gemini', 'radar names the pool without the word weekly')
assert(rows[4].alarming && !rows[2].alarming, 'radar flags only nearly spent allowances')

const cursor = radar.radarRanking([
  { providerId: 'cursor', providerName: 'Cursor', limits: [
    limit('Cursor Models', 0.31, 286 * hour, 'Cursor Models'),
    limit('Other Models', 1.0, 286 * hour, 'Other Models')] },
  { providerId: 'codex', providerName: 'Codex', limits: [limit('Weekly (7-day)', 0.40, 94 * hour)] },
], now)
assertEqual(cursor[0].window, 'Cursor Models', 'one spent model family does not mark the whole agent spent')

const spent = radar.radarRanking([
  { providerId: 'a', providerName: 'A', limits: [limit('Weekly (7-day)', 1.0, 48 * hour)] },
  { providerId: 'b', providerName: 'B', limits: [limit('Weekly (7-day)', 1.0, 5 * hour)] },
], now)
assertDeepEqual(spent.map(r => r.providerId), ['b', 'a'], 'radar lists spent allowances by the soonest to come back')

assert(/readonly property bool radarAvailable: radarRows\.length > 1/.test(panelSource), 'radar only appears with two or more agents to compare')
assert(/readonly property var shown: showRadar \? null : provider/.test(panelSource), 'radar hides the per-agent sections while it is up')
assert(/readonly property var headline: bindingWindow\(provider\)/.test(panelSource), 'bar alarm still follows the selected agent while the radar is up')
JS
