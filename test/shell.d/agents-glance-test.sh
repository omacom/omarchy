#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/agents/GlanceModel.js')
const now = Date.parse('2026-09-06T12:00:00Z')
const fresh = {updatedAt: new Date(now).toISOString()}
const limit = (percent, reset = now + 3600000) => ({percent, label: 'Session', resetsAt: new Date(reset).toISOString()})
const read = p => model.summary({...fresh, ...p}, now, 1800000)
assertEqual(read({limits:[limit(0.2), limit(0.95)]}).fraction, 0.95, 'fullest window determines the ring')
assert(read({limits:[limit(0.95)]}).alarming, 'fresh nearly exhausted allowance is alarming')
assert(read({limits:[limit(0)]}).known, 'zero usage is a valid reading')
for (const value of [null, '', '0.8', NaN, Infinity, -1, 2])
  assert(!read({limits:[limit(value)]}).known, 'malformed percentage is not a fabricated reading: ' + value)
assert(!read({limits:[limit(0.9)], usageStatusText:'Sign-in expired'}).known, 'auth error takes precedence over previous limits')
const expired = read({limits:[limit(0.99, now)]})
assert(expired.stale && !expired.alarming && expired.fraction === 0.99, 'expired window keeps last reading without claiming reset')
assert(expired.detail.includes('awaiting refresh'), 'expired window explains pending refresh')
assert(read({limits:[limit(0.2)], updatedAt:'bad'}).stale, 'missing timestamp cannot masquerade as live data')
assert(read({limits:[limit(0.2)], updatedAt:new Date(now - 1800001).toISOString()}).stale, 'old record is stale')
const balance = read({balance:{funded:20, remaining:1, currency:'USD', estimated:true}})
assert(balance.alarming && balance.detail.includes('estimated') && balance.detail.includes('remaining'), 'prepaid balance preserves its units and estimate label')
assert(!read({balance:{funded:0, remaining:1}}).known, 'balance without funding does not invent a percentage')
const sessions = [{providerId:'claude', state:'working'}, {providerId:'claude', state:'waiting'}]
assertEqual(model.activity(sessions), 'waiting', 'attention takes priority over working')
assertEqual(model.sessionsFor(sessions, 'codex', now, now).length, 0, 'states stay with their provider')
assertEqual(model.sessionsFor(sessions, 'claude', now, now - 15001).length, 0, 'stopped scanner cannot leave a working indicator forever')
assertEqual(model.activity([]), 'unknown', 'no session evidence means unknown')
JS

PYTHONDONTWRITEBYTECODE=1 python3 "$ROOT/test/shell.d/fixtures/agents-sessions-test.py" "$ROOT"
