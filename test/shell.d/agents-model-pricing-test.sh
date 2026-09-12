#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
process.env.TZ = 'Europe/Berlin'
const pricing = requireFromRoot('shell/plugins/agents/ApiCost.js')

const overrides = pricing.parseOverrides(JSON.stringify({ models: {
  'model-a': { input: 1, output: 2, cacheRead: 0.1, cacheWrite: 1 },
  'model-b': { input: 3, output: 4, cacheRead: 0.2, cacheWrite: 2 },
  'model-c': { input: 5, output: 6, cacheRead: 0.3, cacheWrite: 3 },
  'model-d': { input: 7, output: 8, cacheRead: 0.4, cacheWrite: 4 }
}}))

function bucket(model, tokens, total) {
  return {
    rawModel: model, source: 'codex-native', sourceId: 'fixture', tariff: {},
    tokens, totalTokens: total, issues: []
  }
}
function zeros(field, value) {
  return {
    inputTokens: field === 'inputTokens' ? value : 0,
    outputTokens: field === 'outputTokens' ? value : 0,
    cacheReadInputTokens: field === 'cacheReadInputTokens' ? value : 0,
    cacheCreationInputTokens: field === 'cacheCreationInputTokens' ? value : 0
  }
}

const usage = {
  schemaVersion: 1, unit: 'tokens', fromDate: '2026-08-31', throughDate: '2026-09-30',
  complete: true, issues: [], unallocatedTokens: 0,
  days: [
    { date: '2026-08-31', buckets: [bucket('model-a', zeros('inputTokens', 9000000), 9000000)] },
    { date: '2026-09-01', buckets: [bucket('model-d', zeros('cacheCreationInputTokens', 1000000), 1000000)] },
    { date: '2026-09-23', buckets: [bucket('model-c', zeros('cacheReadInputTokens', 1000000), null)] },
    { date: '2026-09-24', buckets: [bucket('model-b', zeros('outputTokens', 1000000), 1000000)] },
    { date: '2026-09-30', buckets: [
      bucket('model-a', zeros('inputTokens', 1000000), 1000000),
      bucket('unpriced-fixture-model', zeros('inputTokens', 500), 500)
    ] }
  ]
}

const now = new Date('2026-09-30T12:00:00+02:00').getTime()
const result = pricing.buildModelWindowPresentation('codex', usage, now, overrides, true)
assertEqual(result.available, true, 'valid native daily usage enables the 30-day model presentation')
assertEqual(result.models.length, 4, 'model presentation shows only the four heaviest 30-day models')
assert(!result.models.some(row => row.id === 'unpriced-fixture-model'),
  'an unpriced fifth model can be hidden by the top-four display cut')
assertDeepEqual(result.missingPriceModels, ['unpriced-fixture-model'],
  'presentation exposes existing unpriced model ids for the visible limitation note')
assert(result.models.every(row => row.cost.status === 'complete'),
  'an unknown hidden model does not mark unrelated priced model rows partial')

const today = result.summaries[0]
const seven = result.summaries[1]
const thirty = result.summaries[2]
assertEqual(today.tokens, 1000500, 'today includes all model buckets, including an unpriced model')
assertEqual(seven.tokens, 2000500, 'seven-day boundary includes the sixth prior local date')
assertEqual(thirty.tokens, 4000500, '30-day total includes all five models, not only the visible top four')
assert(Math.abs(today.cost.total - 1) < 1e-12 && Math.abs(seven.cost.total - 5) < 1e-12
  && Math.abs(thirty.cost.total - 9.3) < 1e-12,
  'window arithmetic remains unrounded until presentation')
assertEqual(today.cost.status + '/' + seven.cost.status + '/' + thirty.cost.status,
  'partial/partial/partial', 'an unpriced model makes each containing window an explicit subtotal')
assert(!today.value.includes('*') && today.tooltip.includes('Priced-token coverage: 99% priced')
  && today.tooltip.includes('1.0M of 1.0M assigned tokens')
  && today.tooltip.includes('No exact tariff for unpriced-fixture-model'),
  'partial compact values disclose priced-token coverage and the missing exact tariff')
assert(result.models.some(row => row.id === 'model-c'
  && row.tokens === 1000000
  && row.tokenCoverage.join(' ').includes('Total token count is unavailable')),
  'independently measured categories remain visible while null total metadata stays disclosed')

const moved = pricing.buildModelWindowPresentation('codex', usage,
  new Date('2026-10-01T12:00:00+02:00').getTime(), overrides, true)
assertEqual(moved.summaries[0].tokens, 0, 'today summary rolls over without requiring new usage')
assertEqual(moved.summaries[2].tokens, 3000500, '30-day local window drops the expired boundary day')
assertEqual(pricing.buildModelWindowPresentation('gemini', usage, now, overrides, true).models.length, 0,
  'the new local pricing presentation does not alter other providers')
assertEqual(pricing.buildModelWindowPresentation('codex', null, now, overrides, true).available, false,
  'missing native daily usage requests the existing token-model fallback')
assertEqual(pricing.buildModelWindowPresentation('codex', usage, now, overrides, false).available, false,
  'sync-incompatible native cost scope requests the existing token-model fallback')
const emptyUsage = {
  schemaVersion: 1, unit: 'tokens', fromDate: '2026-09-01', throughDate: '2026-09-30',
  complete: true, issues: [], unallocatedTokens: 0, days: []
}
const emptyResult = pricing.buildModelWindowPresentation('codex', emptyUsage, now, overrides, true)
assertEqual(emptyResult.available + '/' + emptyResult.models.length, 'true/0',
  'a legitimate empty native 30-day view stays empty instead of falling back to all-time data')

function qmlSequence(values) {
  const sequence = { length: values.length }
  values.forEach((value, index) => { sequence[index] = value })
  return sequence
}
const qmlBoundaryTooltip = pricing.dailyTooltipDetails({ cost: {
  status: 'partial', total: 1,
  components: { input: 1, output: 0, cacheRead: 0, cacheWrite: 0 },
  rates: qmlSequence([pricing.resolveRate('codex', 'model-a', overrides)]),
  assumptions: qmlSequence(['fixture assumption']),
  missing: qmlSequence(['fixture missing coverage']),
  uncertainties: qmlSequence(['fixture uncertainty']),
  warnings: qmlSequence(['fixture override warning'])
}})
assert(qmlBoundaryTooltip.includes('model-a') && qmlBoundaryTooltip.includes('fixture assumption')
  && qmlBoundaryTooltip.includes('fixture missing coverage')
  && qmlBoundaryTooltip.includes('fixture uncertainty')
  && qmlBoundaryTooltip.includes('fixture override warning'),
  'QML-style indexable sequences retain every tooltip detail group')

for (const malformedTariff of [[], 'invalid', 7]) {
  const malformedBucket = bucket('model-a', zeros('inputTokens', 10), 10)
  malformedBucket.tariff = malformedTariff
  const malformedUsage = { schemaVersion: 1, unit: 'tokens', fromDate: '2026-09-01', throughDate: '2026-09-30',
    complete: true, issues: [], unallocatedTokens: 0,
    days: [{ date: '2026-09-30', buckets: [malformedBucket] }] }
  const malformedDay = pricing.buildDailyRows('codex', malformedUsage, [], now, overrides, true)[6]
  const malformedModel = pricing.buildModelWindowPresentation('codex', malformedUsage, now, overrides, true)
  assertEqual(malformedDay.cost.status + '/' + malformedModel.models[0].cost.status
    + '/' + malformedModel.summaries[0].cost.status, 'unknown/unknown/unknown',
    'malformed non-object tariff metadata stays unknown through daily and model/window presentation')
}

let tokenReads = 0
const countedTokens = {}
for (const name of ['inputTokens', 'outputTokens', 'cacheReadInputTokens', 'cacheCreationInputTokens'])
  Object.defineProperty(countedTokens, name, { enumerable: true, get() { tokenReads++; return 1 } })
const countedUsage = { schemaVersion: 1, unit: 'tokens', fromDate: '2026-09-01', throughDate: '2026-09-30',
  complete: true, issues: [], unallocatedTokens: 0,
  days: [{ date: '2026-09-30', buckets: [bucket('model-a', countedTokens, 4)] }] }
pricing.buildModelWindowPresentation('codex', countedUsage, now, overrides, true)
assertEqual(tokenReads, 4, 'model/window aggregation prices each bucket once instead of once per destination')

let rateReads = 0
const countedRates = {}
for (const name of ['input', 'output', 'cacheRead', 'cacheWrite'])
  Object.defineProperty(countedRates, name, { enumerable: true, get() { rateReads++; return 1 } })
const countedOverrides = { schemaVersion: 1, aliases: {}, errors: [], models: {
  'model-a': { rates: countedRates, assumptions: [] }
} }
const repeatedUsage = { schemaVersion: 1, unit: 'tokens', fromDate: '2026-09-01', throughDate: '2026-09-30',
  complete: true, issues: [], unallocatedTokens: 0,
  days: [{ date: '2026-09-30', buckets: Array.from({ length: 20 }, () =>
    bucket('model-a', zeros('inputTokens', 1), 1)) }] }
pricing.buildModelWindowPresentation('codex', repeatedUsage, now, countedOverrides, true)
assertEqual(rateReads, 4, 'one formatter pass resolves each distinct model tariff once')

let modelReads = 0
const repeatedBuckets = Array.from({ length: 20 }, () => {
  const item = bucket('model-a', zeros('inputTokens', 1), 1)
  Object.defineProperty(item, 'rawModel', { enumerable: true, get() { modelReads++; return 'model-a' } })
  return item
})
pricing.buildModelWindowPresentation('codex', { ...repeatedUsage,
  days: [{ date: '2026-09-30', buckets: repeatedBuckets }] }, now, countedOverrides, true)
assertEqual(modelReads, 20, 'equivalent pricing buckets are compacted before model/window evaluation')

const rawIdentityUsage = { ...repeatedUsage, days: [{ date: '2026-09-30', buckets: [
  bucket('Unknown-X', zeros('inputTokens', 1), 1),
  bucket(' unknown-x ', zeros('inputTokens', 1), 1)
] }] }
const rawIdentity = pricing.buildModelWindowPresentation('codex', rawIdentityUsage, now, {}, true)
assert(rawIdentity.models[0].cost.missing.includes('No exact tariff for Unknown-X')
  && rawIdentity.models[0].cost.missing.includes('No exact tariff for  unknown-x '),
  'compaction preserves distinct raw model IDs in missing-price details')

let mergedSourceReads = 0
function sameKeyBucket(sourceId, input, write) {
  const item = { rawModel: 'claude-opus-5', source: 'claude-native', issues: [], totalTokens: input + write,
    tariff: { cache_duration: '1h', cache_creation: {
      ephemeral_5m_input_tokens: 0, ephemeral_1h_input_tokens: write } },
    tokens: { inputTokens: input, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: write } }
  if (sourceId === null) Object.defineProperty(item, 'sourceId',
    { enumerable: true, get() { mergedSourceReads++; return 'must-not-be-read' } })
  else item.sourceId = sourceId
  return item
}
function sameFastBucket(sourceId, input) {
  const item = { rawModel: 'claude-sonnet-5', source: 'claude-native', issues: [], totalTokens: input,
    tariff: { fast_mode: true },
    tokens: { inputTokens: input, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0 } }
  if (sourceId === null) Object.defineProperty(item, 'sourceId',
    { enumerable: true, get() { mergedSourceReads++; return 'must-not-be-read' } })
  else item.sourceId = sourceId
  return item
}
const mixedBuckets = [
  sameKeyBucket('first', 1, 10),
  { rawModel: 'claude-opus-5', source: 'claude-native', sourceId: 'bypass', issues: [], totalTokens: 7,
    tariff: 'invalid', tokens: { inputTokens: 7, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0 } },
  sameKeyBucket(null, 2, 20),
  sameFastBucket('zero', 0),
  sameFastBucket(null, 4)
]
const mixedUsage = { ...repeatedUsage, days: [{ date: '2026-09-30', buckets: mixedBuckets }] }
const mixedDay = pricing.buildDailyRows('claude', mixedUsage, [], now, {}, true)[6]
const mixedResult = pricing.buildModelWindowPresentation('claude', mixedUsage, now, {}, true)
const opus = mixedResult.models.find(row => row.id === 'claude-opus-5')
const fast = mixedResult.models.find(row => row.id === 'claude-sonnet-5')
assertEqual(mergedSourceReads, 0,
  'non-adjacent same-key and zero/positive same-tariff buckets actually merge')
assertEqual(mixedDay.tokens + '/' + mixedResult.summaries[0].tokens, '44/44',
  'merged and bypassed buckets preserve daily and window token scope')
assert(Math.abs(mixedDay.cost.total - 0.000315) < 1e-14
  && Math.abs(opus.cost.total - 0.000315) < 1e-14
  && mixedDay.cost.status === 'partial' && opus.cost.status === 'partial'
  && fast.cost.status === 'unknown' && fast.cost.total === 0,
  'valid 1h splits retain their independent subtotal while unsupported positive usage stays unknown')
assert(mixedResult.summaries[0].tooltip.includes('Priced-token coverage: 75% priced')
  && mixedResult.summaries[0].cost.assumptions.some(reason => reason.includes('metadata is invalid')),
  'merged presentation retains per-bucket priced coverage and malformed metadata disclosure')

const displayInput = JSON.stringify({
  id: 'claude', stats: { duplicateHistory: ['unused'] },
  dailyUsage: mixedUsage, recentDays: [{ date: '2026-09-30', tokens: 44 }]
})
const displayRecord = pricing.parseDisplayRecord(displayInput)
assertEqual(displayRecord.dailyUsage.days[0].buckets.length, 3,
  'background display parsing compacts equivalent buckets before QML transfer')
assertEqual(displayRecord.stats, undefined, 'unused legacy scan cache is not transferred to QML')
assertDeepEqual(pricing.buildDailyRows('claude', displayRecord.dailyUsage, [], now, {}, true)[6], mixedDay,
  'background parsing preserves all daily values, coverage and tooltip details')
assertDeepEqual(pricing.buildModelWindowPresentation('claude', displayRecord.dailyUsage, now, {}, true), mixedResult,
  'background parsing preserves every model and window presentation')
assertEqual(JSON.parse(displayInput).dailyUsage.days[0].buckets.length, 5,
  'display compaction leaves the original serialized usage unchanged')
assertDeepEqual(displayRecord.recentDays, [{ date: '2026-09-30', tokens: 44 }],
  'display parsing preserves legacy token totals')
assertEqual(pricing.parseDisplayRecord('[]'), null, 'array-shaped usage records are rejected')
assertDeepEqual(pricing.parseDisplayRecord('{"id":"codex","dailyUsage":{"schemaVersion":99}}').dailyUsage,
  {schemaVersion:99}, 'unknown usage versions retain their unavailable-data semantics')
JS
