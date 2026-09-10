#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
process.env.TZ = 'Europe/Berlin'
const pricing = requireFromRoot('shell/plugins/agents/ApiCost.js')

const catalog = pricing.bundledCatalog()
assertEqual(catalog.schemaVersion, 1, 'agents pricing exposes a versioned bundled catalog')
assertEqual(catalog.currency + '/' + catalog.denominator, 'USD/1000000', 'bundled rates declare USD per million tokens')

const astra = pricing.resolveRate('codex', 'gpt-6-astra', pricing.parseOverrides(''))
assertDeepEqual(astra.rates, {
  input: 10,
  output: 50,
  cacheRead: 1,
  cacheWrite: 12.5
}, 'Astra uses the independently recorded standard tariff')
assertEqual(astra.priceAsOf, '2026-09-09', 'Astra exposes its original price date')
assertEqual(astra.origin, 'bundled-fallback', 'bundled Astra tariff is visibly a fallback')
assertEqual(astra.source.url, 'https://developers.openai.com/api/docs/models/gpt-6-astra.md', 'Astra exposes its official original source')

assertEqual(pricing.resolveRate('codex', 'gpt-6-astra-preview', {}), null,
  'similar model prefixes do not inherit a bundled tariff')
assertEqual(pricing.resolveRate('codex', 'gpt-5.6', {}).modelId, 'gpt-5.6-sol',
  'only the documented exact Sol alias resolves automatically')

const claudeOpus = pricing.resolveRate('claude', 'claude-opus-5', {})
assertDeepEqual(claudeOpus.rates, { input: 5, output: 25, cacheRead: 0.5, cacheWrite: 6.25, cacheWrite1h: 10 },
  'Claude Opus 5 uses the independently recorded standard 5-minute-cache tariff')
assertEqual(claudeOpus.priceAsOf + '/' + claudeOpus.source.url,
  '2026-09-10/https://platform.claude.com/docs/en/about-claude/pricing',
  'Claude bundled pricing retains its primary provenance and price date')
assertDeepEqual(pricing.resolveRate('claude', 'claude-sonnet-5', {}).rates,
  { input: 2, output: 10, cacheRead: 0.2, cacheWrite: 2.5, cacheWrite1h: 4 },
  'Claude Sonnet 5 retains the confirmed standard price after the cancelled increase')
assertEqual(pricing.resolveRate('claude', 'claude-sonnet-4-5', {}).modelId,
  'claude-sonnet-4-5-20250929', 'the one documented Claude model alias resolves exactly')
assertEqual(pricing.resolveRate('claude', 'claude-opus-5-preview', {}), null,
  'unknown Claude suffixes do not inherit a nearby bundled tariff')

function claudeBucket(model, tokens, tariff, source) {
  return { rawModel: model, source: source || 'claude-native', sourceId: 'fixture', tariff: tariff || {},
    tokens, totalTokens: Object.values(tokens).filter(Number.isFinite).reduce((a, b) => a + b, 0), issues: [] }
}
const claudeKinds = { inputTokens: 1000000, outputTokens: 1000000,
  cacheReadInputTokens: 1000000, cacheCreationInputTokens: 1000000 }
assertEqual(pricing.priceBucket('claude', claudeBucket('claude-opus-5', claudeKinds, { cache_duration: '5m' }), {}).total,
  36.75, 'observed Claude 5-minute cache writes use the verified standard tariff')
assertEqual(pricing.priceBucket('claude', claudeBucket('claude-opus-5', claudeKinds, { cache_duration: '1h' }), {}).total,
  40.5, 'observed Claude 1-hour cache writes use the verified duration rate')
assertEqual(pricing.priceBucket(' Claude ', claudeBucket('claude-opus-5', claudeKinds, { cache_duration: '1h' }), {}).total,
  40.5, 'the Claude cache-duration helper uses the normalized exact provider ID')
assertEqual(pricing.priceBucket('claude', claudeBucket('claude-opus-5', claudeKinds, { inference_geo: 'global' }), {}).status,
  'complete', 'recorded global Claude inference keeps the standard tariff')
assertEqual(pricing.priceBucket('claude', claudeBucket('claude-opus-5', claudeKinds, { inference_geo: 'us' }), {}).status,
  'unknown', 'recorded non-global Claude inference is not silently standard-priced')
assertEqual(pricing.priceBucket('claude', claudeBucket('claude-opus-5', claudeKinds, {}, 'codex-native'), {}).status,
  'unknown', 'Claude never blanket-trusts a foreign provider source bucket')
const manualClaude = pricing.parseOverrides(JSON.stringify({ models: {
  'claude-opus-5': { input: 1, output: 2, cacheRead: 0, cacheWrite: 0 }
} }))
assertEqual(pricing.resolveRate('claude', 'claude-opus-5', manualClaude).rates.input, 1,
  'an exact manual Claude rate remains authoritative over the bundled catalog')
assertEqual(pricing.dailyHeading('claude', [{ cost: { status: 'complete' } }]),
  'TOKENS / KNOWN API COST EST. (USD)', 'Claude uses the shared known-cost heading')

const explicit = pricing.parseOverrides(JSON.stringify({
  models: { 'gpt-6-astra': { input: 1, output: 2, cacheRead: 0, cacheWrite: 0 } }
}))
const explicitRate = pricing.resolveRate('codex', 'gpt-6-astra', explicit)
assertDeepEqual(explicitRate.rates, { input: 1, output: 2, cacheRead: 0, cacheWrite: 0 },
  'explicit manual cache rates including zero take priority')
assertEqual(explicitRate.origin, 'user-override', 'manual rate reports its override origin')

const assumed = pricing.parseOverrides(JSON.stringify({
  models: { 'local-model': { input: 3, output: 9 } }
}))
const assumedRate = pricing.resolveRate('codex', 'local-model', assumed)
assertDeepEqual(assumedRate.rates, { input: 3, output: 9, cacheRead: 0.3, cacheWrite: 3 },
  'omitted manual cache rates use the documented compatibility assumptions')
assertEqual(assumedRate.assumptions.length, 2, 'manual cache assumptions remain disclosed')

const invalid = pricing.parseOverrides(JSON.stringify({
  models: { 'gpt-6-astra': { input: '1', output: 2 } },
  aliases: { 'my-codex': 'gpt-6-astra' }
}))
assertEqual(pricing.resolveRate('codex', 'gpt-6-astra', invalid).rates.input, 10,
  'an invalid manual rate does not displace the valid bundled fallback')
assertEqual(pricing.resolveRate('codex', 'my-codex', invalid).modelId, 'gpt-6-astra',
  'a valid exact manual alias has priority and resolves')

function bucket(model, tokens, tariff, issues) {
  return { rawModel: model, source: 'codex-native', sourceId: 'fixture', tariff: tariff || {},
    tokens, totalTokens: Object.values(tokens).filter(Number.isFinite).reduce((a, b) => a + b, 0),
    issues: issues || [] }
}

const allKinds = bucket('gpt-6-astra', {
  inputTokens: 1000000, outputTokens: 1000000,
  cacheReadInputTokens: 1000000, cacheCreationInputTokens: 1000000
})
const allKindsCost = pricing.priceBucket('codex', allKinds, {})
assertEqual(allKindsCost.total, 73.5, 'Astra prices four disjoint token categories without rounding')
assertDeepEqual(allKindsCost.components, { input: 10, output: 50, cacheRead: 1, cacheWrite: 12.5 },
  'Astra cost keeps the independently calculated component split')
assert(allKindsCost.assumptions.join(' ').includes('Standard short-context'),
  'missing request tariff metadata is disclosed as a standard estimate')

const guardian = pricing.resolveRate('codex', 'codex-auto-review', {})
assertEqual(guardian.modelId, 'gpt-5.4', 'guardian uses the explicitly provisional GPT-5.4 estimate')
assertDeepEqual(guardian.rates, { input: 2.5, output: 15, cacheRead: 0.25, cacheWrite: null },
  'guardian standard rates retain unknown cache-write pricing')
assertEqual(guardian.aliasOrigin, 'user-authorized-estimate', 'guardian alias is not labeled provider-proven')
assert(guardian.assumptions.join(' ').includes('2026-09-10')
  && guardian.assumptions.join(' ').includes('not proof'), 'guardian uncertainty is disclosed through existing assumptions')
const guardianBucket = bucket('codex-auto-review', {
  inputTokens: 1000000, outputTokens: 1000000, cacheReadInputTokens: 1000000, cacheCreationInputTokens: 0
})
assertEqual(pricing.priceBucket('codex', guardianBucket, {}).total, 17.75, 'guardian prices measured categories at GPT-5.4 standard rates')
assertEqual(guardianBucket.rawModel, 'codex-auto-review', 'pricing leaves recorded model identity untouched')
assertEqual(pricing.resolveRate('codex', 'codex-auto-review', pricing.parseOverrides(JSON.stringify({ models: {
  'codex-auto-review': { input: 7, output: 8, cacheRead: 0, cacheWrite: 0 }
} }))).rates.input, 7, 'direct manual guardian rates override the provisional pin')
assertEqual(pricing.resolveRate('codex', 'codex-auto-review', pricing.parseOverrides(JSON.stringify({
  aliases: { 'codex-auto-review': 'gpt-6-astra' }
}))).modelId, 'gpt-6-astra', 'manual guardian alias overrides the provisional pin')
assertEqual(pricing.priceBucket('codex', bucket('codex-auto-review', {
  inputTokens: 0, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 10
}), {}).status, 'unknown', 'unknown guardian cache-write tariff is not forced complete')

const special = bucket('gpt-5.6-sol', {
  inputTokens: 1000000, outputTokens: 1000000,
  cacheReadInputTokens: 0, cacheCreationInputTokens: 0
}, { service_tier: 'priority' })
assertEqual(pricing.priceBucket('codex', special, {}).status, 'unknown',
  'an observed unsupported processing tier is not silently standard-priced')
const cacheDuration = bucket('gpt-6-astra', {
  inputTokens: 1000000, outputTokens: 0,
  cacheReadInputTokens: 0, cacheCreationInputTokens: 1000000
}, { cache_duration: '24h' })
const cacheDurationCost = pricing.priceBucket('codex', cacheDuration, {})
assertEqual(cacheDurationCost.status + '/' + cacheDurationCost.total, 'partial/10',
  'an unpriced cache duration leaves only the affected cache-write component unknown')

const partial = bucket('gpt-6-astra', {
  inputTokens: null, outputTokens: 100000,
  cacheReadInputTokens: 0, cacheCreationInputTokens: 0
})
partial.totalTokens = 110000
const partialCost = pricing.priceBucket('codex', partial, {})
assertEqual(partialCost.total, 5, 'known components retain an independently calculated subtotal')
assertEqual(partialCost.status, 'partial', 'a missing token category marks the subtotal partial')

const zeroOverrides = pricing.parseOverrides('{"models":{"free-local":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0}}}')
const zeroCost = pricing.priceBucket('codex', bucket('free-local', {
  inputTokens: 12, outputTokens: 3, cacheReadInputTokens: 4, cacheCreationInputTokens: 5
}), zeroOverrides)
assertEqual(zeroCost.status + '/' + zeroCost.total, 'complete/0', 'a valid zero tariff remains numeric and complete')
assertEqual(pricing.priceBucket('codex', bucket('gpt-6-astra-preview', {
  inputTokens: 1, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0
}), {}).status, 'unknown', 'an unpriced model keeps its token usage but unknown cost')

assertEqual(pricing.formatTokenCount(2400000), '2.4M', 'daily values keep the established token abbreviation')
assertEqual(pricing.formatCombined(2400000, { status: 'complete', total: 8.2 }, true), '2.4M/$8.20',
  'complete daily cost uses the compact no-space separator')
assertEqual(pricing.formatCombined(2400000, { status: 'partial', total: 8.2 }, true), '2.4M/$8.20',
  'partial daily cost stays a known subtotal without an unexplained marker')
assertEqual(pricing.formatCombined(2400000, { status: 'unknown', total: 0 }, true), '2.4M/—',
  'fully unknown daily cost uses a dash rather than zero')
assertEqual(pricing.formatCombined(2400000, { status: 'unknown', total: 0 }, false), '2.4M',
  'providers outside the pricing scope retain token-only values')

const days = []
for (let day = 3; day <= 9; day++) days.push({ date: `2026-09-0${day}`, buckets: [] })
days[5].buckets.push(allKinds)
days[6].buckets.push(partial)
const dailyUsage = { schemaVersion: 1, unit: 'tokens', fromDate: '2026-08-11', throughDate: '2026-09-09',
  complete: false, issues: [], unallocatedTokens: 0, days }
const rows = pricing.buildDailyRows('codex', dailyUsage, [], new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)
assertEqual(rows.length, 7, 'pricing presentation preserves exactly seven daily rows')
assertEqual(rows[0].date + '/' + rows[6].date, '2026-09-03/2026-09-09',
  'daily rows retain oldest-to-newest local calendar order')
assertEqual(rows[5].value, '4.0M/$73.50', 'daily row aggregates its own models and token categories')
assertEqual(rows[6].value, '110.0K/$5.00', 'daily row presents partial category coverage without dropping tokens')

const moved = pricing.buildDailyRows('codex', dailyUsage, [], new Date('2026-09-10T12:00:00+02:00').getTime(), {}, true)
assertEqual(moved[6].date + '/' + moved[6].value, '2026-09-10/0/—',
  'calendar window moves after midnight even before new usage arrives')
assertDeepEqual(pricing.recentDateStrings(new Date('2026-03-30T12:00:00+02:00').getTime(), 3),
  ['2026-03-28', '2026-03-29', '2026-03-30'], 'local dates remain contiguous across the DST transition')

const legacyBucket = {
  rawModel: 'gpt-6-astra', source: 'legacy', sourceId: 'legacy-fixture', tariff: {}, totalTokens: 123,
  tokens: { inputTokens: null, outputTokens: null, cacheReadInputTokens: null, cacheCreationInputTokens: null },
  issues: ['source-not-covered']
}
const separatelyIncompleteUsage = {
  schemaVersion: 1, unit: 'tokens', fromDate: '2026-08-11', throughDate: '2026-09-09',
  complete: false, issues: [], unallocatedTokens: 0,
  days: [
    { date: '2026-09-08', buckets: [allKinds] },
    { date: '2026-09-09', buckets: [legacyBucket] }
  ]
}
const separatelyIncompleteRows = pricing.buildDailyRows('codex', separatelyIncompleteUsage, [],
  new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)
assertEqual(separatelyIncompleteRows[5].value, '4.0M/$73.50',
  'a complete day stays complete beside a different legacy-only day')
assertEqual(separatelyIncompleteRows[6].value, '123/—',
  'the localized legacy-only day still exposes its unknown price')

const identityUncertainUsage = {
  schemaVersion: 1, unit: 'tokens', fromDate: '2026-08-11', throughDate: '2026-09-09',
  complete: false, issues: [], unallocatedTokens: 0,
  days: [{ date: '2026-09-09', buckets: [bucket('gpt-6-astra', {
    inputTokens: 1000, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0
  }, {}, ['event-identity-unverified'])] }]
}
const identityUncertainRow = pricing.buildDailyRows('codex', identityUncertainUsage, [],
  new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)[6]
assertEqual(identityUncertainRow.value, '1.0K/$0.01',
  'accounting-identity uncertainty alone does not mislabel a fully priced amount as a subtotal')
assert(pricing.dailyTooltip(identityUncertainRow).includes('Usage uncertainty: event-identity-unverified'),
  'accounting-identity uncertainty remains visible without changing cost coverage')

const mixedDay = [{ date: '2026-09-09', buckets: [
  bucket('gpt-6-astra', { inputTokens: 500, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0 }),
  bucket('gpt-5.6-sol', { inputTokens: 1250, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0 })
] }]
const mixedUsage = { schemaVersion: 1, unit: 'tokens', fromDate: '2026-08-11', throughDate: '2026-09-09',
  complete: true, issues: [], unallocatedTokens: 0, days: mixedDay }
const mixedRow = pricing.buildDailyRows('codex', mixedUsage, [], new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)[6]
assertEqual(mixedRow.cost.total, 0.01, 'model changes aggregate unrounded costs before display rounding')

const replaced = pricing.parseOverrides('{"models":{"gpt-6-astra":{"input":1,"output":2,"cacheRead":0.1,"cacheWrite":1.25}}}')
const originalRow = pricing.buildDailyRows('codex', dailyUsage, [], new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)[5]
const replacedRow = pricing.buildDailyRows('codex', dailyUsage, [], new Date('2026-09-09T12:00:00+02:00').getTime(), replaced, true)[5]
assertEqual(originalRow.tokens, replacedRow.tokens, 'tariff changes never alter displayed token totals')
assertEqual(replacedRow.value, '4.0M/$4.35', 'a newly loaded valid override reprices the day without restart state')

const legacyRows = pricing.buildDailyRows('codex', null, [{ date: '2026-09-09', messageCount: 1234 }],
  new Date('2026-09-09T12:00:00+02:00').getTime(), {}, false)
assertEqual(legacyRows[6].value, '1.2K/—', 'synchronized or legacy-only tokens never receive a mismatched local cost')
assertEqual(pricing.dailyHeading('codex', legacyRows), 'TOKENS / API COST UNAVAILABLE',
  'all-unknown Codex cost scope has an honest heading without hiding token rows')
assertEqual(pricing.dailyHeading('codex', [{ cost: { status: 'complete', total: 0 } }]),
  'TOKENS / KNOWN API COST EST. (USD)', 'a known zero cost still keeps the USD estimate heading')
assertEqual(pricing.dailyHeading('codex', [{ cost: { status: 'partial', total: 0.25 } }]),
  'TOKENS / KNOWN API COST EST. (USD)', 'a known subtotal keeps the USD estimate heading')
assertEqual(pricing.dailyHeading('gemini', []), 'TOKENS BY DAY',
  'providers outside pricing scope retain their original daily heading')

const mismatchedRows = pricing.buildDailyRows('codex', dailyUsage,
  [{ date: '2026-09-08', messageCount: 5000000 }],
  new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)
assertEqual(mismatchedRows[5].value, '5.0M/$73.50',
  'the visible legacy day amount wins while a mismatched priced scope becomes partial')
assert(pricing.dailyTooltip(mismatchedRows[5]).includes('Displayed token total does not match daily pricing coverage'),
  'a priced-scope mismatch is explicit in the public tooltip')

const emptyMismatch = pricing.buildDailyRows('codex', dailyUsage,
  [{ date: '2026-09-03', messageCount: 1 }],
  new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)[0]
assertEqual(emptyMismatch.value, '1/—',
  'a scope mismatch without any priced tokens never becomes a known zero subtotal')

const details = pricing.dailyTooltip(rows[5])
const pricingOnlyDetails = pricing.dailyTooltipDetails(rows[5])
assertEqual(details, rows[5].date + ' · 4.0M tokens\n' + pricingOnlyDetails,
  'public pricing details compose below a consumer-owned day summary without duplication')
assert(pricingOnlyDetails.startsWith('API-equivalent estimate in USD'),
  'pricing-only tooltip details begin with comparison-cost context')
assert(details.includes('Input $10.00') && details.includes('Output $50.00')
  && details.includes('Cache read $1.00') && details.includes('Cache write $12.50'),
  'daily tooltip exposes all four component costs')
assert(details.includes('bundled fallback') && details.includes('2026-09-09')
  && details.includes('developers.openai.com/api/docs/models/gpt-6-astra.md'),
  'daily tooltip exposes effective source, original price date, and fallback origin')
assert(details.includes('API-equivalent estimate in USD') && details.includes('not a subscription bill'),
  'daily tooltip clearly explains the comparison-cost context')
assert(pricing.dailyTooltip(rows[6]).includes('Input token count is unverified'),
  'partial tooltip names missing coverage')
assert(details.includes('cache read $1') && details.includes('cache write $12.5'),
  'effective tariff details preserve exact whole and fractional rates')

for (const [model, expected] of [
  ['gpt-5.2', 'cache read $0.175'],
  ['gpt-5.4-mini', 'cache read $0.075'],
  ['gpt-5.1', 'cache read $0.125'],
  ['gpt-5-mini', 'cache read $0.025'],
  ['gpt-5-nano', 'cache read $0.005']
]) {
  const rate = pricing.resolveRate('codex', model, {})
  const tooltip = pricing.dailyTooltip({ date: '2026-09-09', tokens: 0, cost: {
    status: 'complete', total: 0,
    components: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    missing: [], uncertainties: [], assumptions: [], rates: [rate]
  } })
  assert(tooltip.includes(expected), model + ' tooltip preserves the exact effective cache-read tariff')
}
const exactZeroRate = pricing.resolveRate('codex', 'free-local', zeroOverrides)
const zeroRateTooltip = pricing.dailyTooltip({ date: '2026-09-09', tokens: 0, cost: {
  status: 'complete', total: 0,
  components: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
  missing: [], uncertainties: [], assumptions: [], rates: [exactZeroRate]
} })
assert(zeroRateTooltip.includes('input $0') && zeroRateTooltip.includes('cache read $0'),
  'effective zero tariffs remain exact numeric rates rather than unknown values')

const invalidCacheOverride = pricing.parseOverrides('{"models":{"gpt-6-astra":{"input":1,"output":2,"cacheRead":"0.1"}}}')
assertEqual(pricing.resolveRate('codex', 'gpt-6-astra', invalidCacheOverride).rates.input, 10,
  'an explicitly invalid manual cache field leaves the bundled fallback effective')

const corrected = bucket(null, {
  inputTokens: null, outputTokens: null, cacheReadInputTokens: null, cacheCreationInputTokens: null
}, {}, ['missing-model', 'cumulative-correction'])
corrected.totalTokens = 4200
const correctedUsage = { schemaVersion: 1, unit: 'tokens', fromDate: '2026-08-11', throughDate: '2026-09-09',
  complete: false, issues: [], unallocatedTokens: 0, days: [{ date: '2026-09-09', buckets: [corrected] }] }
const correctedRow = pricing.buildDailyRows('codex', correctedUsage, [], new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)[6]
assertEqual(correctedRow.value, '4.2K/—', 'missing model and cumulative correction preserve tokens without inventing cost')
assert(pricing.dailyTooltip(correctedRow).includes('cumulative-correction'),
  'cumulative correction remains visible in pricing coverage details')

const incompleteUsage = JSON.parse(JSON.stringify(dailyUsage))
incompleteUsage.complete = false
incompleteUsage.issues = ['native-read-error']
const incompleteRow = pricing.buildDailyRows('codex', incompleteUsage, [], new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)[5]
assertEqual(incompleteRow.value, '4.0M/$73.50', 'incomplete scan coverage preserves an otherwise known subtotal')
assert(pricing.dailyTooltip(incompleteRow).includes('native-read-error'),
  'scan-wide coverage failure is disclosed in the day tooltip')

const unsupportedUsage = JSON.parse(JSON.stringify(dailyUsage))
unsupportedUsage.schemaVersion = 2
const unsupportedRow = pricing.buildDailyRows('codex', unsupportedUsage, [{ date: '2026-09-09', messageCount: 99 }],
  new Date('2026-09-09T12:00:00+02:00').getTime(), {}, true)[6]
assertEqual(unsupportedRow.value, '99/—', 'unsupported daily schema never prices legacy compatibility fields')
JS
