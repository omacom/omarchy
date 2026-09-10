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
  && today.tooltip.includes('1.0M of 1.0M assigned local tokens')
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
JS
