#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const nodeAssert = require('node:assert/strict')
const source = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const names = [
  'safeDeviceId', 'parseSyncScanOutput', 'cloneValue', 'numberValue', 'plainMap', 'dateString',
  'recentDateStrings', 'emptyTokenBucket', 'combineNumber', 'combineObjectNumbers',
  'combineTokenBucket', 'aggregateSnapshots', 'providerSnapshot', 'localSnapshot',
  'syncedStatsFor', 'providerEnabled', 'providerHasData', 'balanceValue', 'displayProvider'
]
const functions = names.map(name => {
  const start = source.indexOf(`  function ${name}(`)
  assert(start >= 0, `found ${name} in Main.qml`)
  const end = source.indexOf('\n  }', start)
  assert(end > start, `found top-level end of ${name}`)
  return source.slice(start, end + '\n  }'.length)
}).join('\n')
const propertyStart = source.indexOf('  property var enabledProviders: {')
const propertyEnd = source.indexOf('\n  }', propertyStart)
assert(propertyStart >= 0 && propertyEnd > propertyStart, 'found enabledProviders in Main.qml')
const enabled = source.slice(propertyStart, propertyEnd + '\n  }'.length).replace('property var enabledProviders:', 'function enabledProviders()')
const context = {
  Quickshell: { env: () => 'device' },
  agents: [], settings: { providers: {} }, dataRevision: 0, syncRevision: 0,
  aggregateData: null, syncEffectiveDeviceId: 'local', syncConfigured: () => true
}
vm.createContext(context)
vm.runInContext(functions + '\n' + enabled, context)

const [date] = context.recentDateStrings().slice(-1)
const parsed = JSON.parse(JSON.stringify({
  deviceId: 'one', providers: {
    constructor: { providerName: 'Constructor', todayPrompts: 2, todayTokensByModel: { toString: 3 },
      activeDates: ['constructor'], modelUsage: { toString: { inputTokens: 5, outputTokens: 2 } },
      recentDays: [{ date, messageCount: 4 }] },
    toString: { totalPrompts: 7 },
    hasOwnProperty: { totalSessions: 2 }
  }
}))
// JSON parsing gives this spelling its own data key, including after a round trip.
const collision = JSON.parse('{"deviceId":"two","providers":{"__proto__":{"totalPrompts":3}}}')
const prototypeBefore = vm.runInContext('Object.getOwnPropertyDescriptors(Object.prototype)', context)
const merged = context.aggregateSnapshots([parsed, collision])
const prototypeAfter = vm.runInContext('Object.getOwnPropertyDescriptors(Object.prototype)', context)
nodeAssert.deepStrictEqual(prototypeAfter, prototypeBefore)
pass('VM Object.prototype descriptors remain unchanged after collision names')
assertEqual(Object.getPrototypeOf(merged.providers), null, 'provider map has no inherited entries')
assertDeepEqual(Object.keys(merged.providers).sort(), ['__proto__', 'constructor', 'hasOwnProperty', 'toString'].sort(), 'all collision names remain own providers')
assertEqual(merged.providers.constructor.todayPrompts, 2, 'constructor provider retains its own count')
assertEqual(merged.providers.__proto__.totalPrompts, 3, '__proto__ provider retains its own count')
assertEqual(merged.providers.constructor.todayTokensByModel.toString, 3, 'model name matching inherited key is isolated')
assertEqual(merged.providers.constructor.modelUsage.toString.inputTokens, 5, 'usage name matching inherited key is isolated')
assertEqual(merged.providers.constructor.recentDays.at(-1).messageCount, 4, 'recent day count remains intact')
assertEqual(merged.providers.constructor.activeDays, 1, 'active date union counts own date')
assertEqual(JSON.parse(JSON.stringify(merged)).providers.__proto__.totalPrompts, 3, 'collision provider survives JSON round trip')

const malformed = [null, [], 3, {}, { providers: [] }, { providers: null },
  { deviceId: {}, providers: { invalid: [], nil: null, number: 4,
    valid: { providerName: {}, scope: {}, todayPrompts: {}, todaySessions: '6',
      todayTokensByModel: [], modelUsage: { bad: [], good: { inputTokens: {}, outputTokens: '4', extraTokens: 42 } },
      activeDates: [null, {}, 'toString'], recentDays: [null, {}, { date: {}, messageCount: 9 }, { date, messageCount: '2' }] }
  } }
]
let malformedResult
try { malformedResult = context.aggregateSnapshots(malformed) }
catch (error) { fail('malformed snapshot shapes do not throw', error.stack) }
assertDeepEqual(Object.keys(malformedResult.providers), ['valid'], 'invalid provider records are skipped')
assertEqual(malformedResult.providers.valid.todayPrompts, 0, 'object numeric value is ignored')
assertEqual(malformedResult.providers.valid.todaySessions, 6, 'numeric string is accepted')
assertEqual(malformedResult.providers.valid.modelUsage.good.inputTokens, 0, 'object bucket value is ignored')
assertEqual(malformedResult.providers.valid.modelUsage.good.outputTokens, 4, 'valid bucket field is kept')
assertDeepEqual(Object.keys(malformedResult.providers.valid.modelUsage.good),
  ['inputTokens', 'outputTokens', 'cacheReadInputTokens', 'cacheCreationInputTokens'], 'bucket keeps only four known fields')
assertEqual(malformedResult.providers.valid.activeDays, 1, 'only string active dates count')
assertEqual(malformedResult.providers.valid.recentDays.at(-1).messageCount, 2, 'only string recent dates count')
assertEqual(malformedResult.providers.valid.providerName, '', 'non-string provider name is ignored')

const ordinary = context.aggregateSnapshots([
  { deviceId: 'a', providers: { alpha: { todayPrompts: 2, totalPrompts: 10, activeDates: ['2026-01-01', '2026-01-02'],
    todayTokensByModel: { opus: 3 }, modelUsage: { opus: { inputTokens: 4 } } },
    billing: { scope: 'account', todayPrompts: 3, totalPrompts: 8, todayTokensByModel: { opus: 4 }, modelUsage: { opus: { inputTokens: 10 } } } } },
  { deviceId: 'b', providers: { alpha: { todayPrompts: 5, totalPrompts: 20, activeDates: ['2026-01-02', '2026-01-03'],
    todayTokensByModel: { opus: 7 }, modelUsage: { opus: { inputTokens: 6 } } },
    billing: { scope: 'account', todayPrompts: 2, totalPrompts: 12, todayTokensByModel: { opus: 7 }, modelUsage: { opus: { inputTokens: 8 } } } } }
])
assertEqual(ordinary.deviceCount, 2, 'ordinary merge counts two devices')
assertEqual(ordinary.providers.alpha.todayPrompts, 7, 'device counts add')
assertEqual(ordinary.providers.alpha.totalPrompts, 30, 'device totals add')
assertEqual(ordinary.providers.alpha.activeDays, 3, 'active dates form a union')
assertEqual(ordinary.providers.alpha.todayTokensByModel.opus, 10, 'device model tokens add')
assertEqual(ordinary.providers.alpha.modelUsage.opus.inputTokens, 10, 'device usage tokens add')
assertEqual(ordinary.providers.billing.todayPrompts, 3, 'account count takes maximum')
assertEqual(ordinary.providers.billing.totalPrompts, 12, 'account total takes maximum')
assertEqual(ordinary.providers.billing.todayTokensByModel.opus, 7, 'account model tokens take maximum')
assertEqual(ordinary.providers.billing.modelUsage.opus.inputTokens, 10, 'account usage tokens take maximum')
assertEqual(ordinary.providers.alpha.hasPromptStats, true, 'old snapshots retain prompt stats default')

context.parseSyncScanOutput('===invalid.json===\n{"providers":[]}\n=== EOM ===\n===valid.json===\n' +
  JSON.stringify({ deviceId: 'scan', providers: { alpha: { totalPrompts: 9 } } }) + '\n=== EOM ===')
assertEqual(context.aggregateData.providers.alpha.totalPrompts, 9, 'scan skips invalid JSON shapes and keeps later snapshots')

context.agents = [{ record: { id: 'constructor', name: 'Local', todayPrompts: 1 } }]
const local = context.localSnapshot()
assertEqual(Object.getPrototypeOf(local.providers), null, 'local snapshot uses isolated provider map')
assertEqual(local.providers.constructor.todayPrompts, 1, 'local collision provider is retained')
context.aggregateData = merged
assertDeepEqual(Array.from(context.enabledProviders(), p => p.providerId).sort(),
  ['__proto__', 'constructor', 'hasOwnProperty', 'toString'].sort(), 'enabled providers enumerate own synced keys and local key once')
assertEqual(context.syncedStatsFor('valueOf'), null, 'lookup does not return inherited provider')
JS

if [[ ${OMARCHY_AGENTS_QML_TEST:-} == 1 ]]; then
  require_compositor "agents snapshot QML fixture"
  require_command quickshell
  stage=$(mktemp -d)
  trap 'rm -rf -- "$stage"' EXIT
  cp "$SHELL_TEST_DIR/fixtures/agents-snapshot-maps/shell.qml" "$stage/shell.qml"
  mkdir -p "$stage/home"
  node - "$ROOT/shell/plugins/agents/Main.qml" "$stage/Helpers.qml" <<'JS'
const fs = require('fs')
const [input, output] = process.argv.slice(2)
const source = fs.readFileSync(input, 'utf8')
const names = ['safeDeviceId', 'cloneValue', 'numberValue', 'plainMap', 'dateString', 'recentDateStrings',
  'emptyTokenBucket', 'combineNumber', 'combineObjectNumbers', 'combineTokenBucket',
  'aggregateSnapshots', 'providerSnapshot', 'localSnapshot']
const functions = names.map(name => {
  const start = source.indexOf(`  function ${name}(`)
  const end = source.indexOf('\n  }', start)
  if (start < 0 || end < 0) throw new Error(`missing Main.qml function ${name}`)
  return source.slice(start, end + '\n  }'.length)
})
fs.writeFileSync(output, [
  'import QtQuick', 'import Quickshell', 'QtObject {',
  '  property var agents: []', '  property string syncEffectiveDeviceId: "local"',
  '  function providerEnabled(id) { return true }', ...functions, '}', ''
].join('\n'))
JS
  output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" OMARCHY_AGENTS_TEST_PATH="$stage" timeout 15 quickshell -p "$stage" --no-color 2>&1) || fail "agents snapshot QML fixture exits cleanly" "$output"
  [[ $output == *"RESULT pass"* ]] || fail "agents snapshot QML assertions pass" "$output"
  if [[ $output == *"RESULT fail"* ]] || [[ $output == *"Error:"* ]]; then
    fail "agents snapshot QML fixture has no errors" "$output"
  fi
  pass "agents snapshot helpers run in Qt"
fi
