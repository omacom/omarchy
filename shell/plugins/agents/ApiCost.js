// Public pricing and presentation helpers shared by QML and the headless tests.
// These figures are estimated API-equivalent USD costs, never subscription bills.

var MAX_RATE_PER_MILLION = 100000
var TOKEN_FIELDS = [
  ["inputTokens", "input", "Input"],
  ["outputTokens", "output", "Output"],
  ["cacheReadInputTokens", "cacheRead", "Cache read"],
  ["cacheCreationInputTokens", "cacheWrite", "Cache write"]
]
var NON_COST_BUCKET_ISSUES = {
  "event-identity-unverified": true
}
var PRICED_SOURCES = {
  codex: { "codex-native": true, "pi": true, "omp": true, "opencode": true },
  claude: { "claude-native": true, "pi": true, "omp": true, "opencode": true },
  kimi: { "kimi-native": true }
}

var OPENAI_PRICING_SOURCE = {
  name: "OpenAI API pricing",
  url: "https://developers.openai.com/api/docs/pricing.md",
  retrievedAt: "2026-09-09T19:53:48Z",
  priceAsOf: "2026-09-09",
  sha256: "244b537c06fb94e4d7214ba7f076f2bd18cace4ad165d30ad5da77cbaaad36c6"
}

var ASTRA_SOURCE = {
  name: "OpenAI GPT-6 Astra model pricing",
  url: "https://developers.openai.com/api/docs/models/gpt-6-astra.md",
  retrievedAt: "2026-09-09T19:53:49Z",
  priceAsOf: "2026-09-09",
  sha256: "593f63fcc87cced8695f56b828fcb5fe5a77adb59ab51ac57a5639cd9abd826f"
}

var ANTHROPIC_PRICING_SOURCE = {
  name: "Claude Platform pricing",
  url: "https://platform.claude.com/docs/en/about-claude/pricing",
  retrievedAt: "2026-09-10T20:27:21Z",
  priceAsOf: "2026-09-10",
  sha256: "6f077b5dfa21aec36b69f97dd2cd7d9d35c94ecd037104a9af585c619fc7fdf8"
}

function publishedRate(input, output, cacheRead, cacheWrite, source) {
  return {
    rates: { input: input, output: output, cacheRead: cacheRead, cacheWrite: cacheWrite },
    currency: "USD",
    denominator: 1000000,
    tariff: "standard-short-context",
    source: source || OPENAI_PRICING_SOURCE
  }
}

function publishedClaudeRate(input, output, cacheRead, cacheWrite5m, cacheWrite1h) {
  var entry = publishedRate(input, output, cacheRead, cacheWrite5m, ANTHROPIC_PRICING_SOURCE)
  entry.rates.cacheWrite1h = cacheWrite1h
  return entry
}

// Exact published IDs only. A null rate means the provider published no value;
// it is deliberately distinct from a legitimate numeric zero.
var BUNDLED_CODEX_MODELS = {
  "gpt-6-astra": publishedRate(10, 50, 1, 12.5, ASTRA_SOURCE),
  "gpt-5.6-sol": publishedRate(4, 20, 0.4, 5),
  "gpt-5.6-terra": publishedRate(2, 12, 0.2, 2.5),
  "gpt-5.6-luna": publishedRate(0.2, 1.2, 0.02, 0.25),
  "gpt-5.5": publishedRate(5, 30, 0.5, null),
  "gpt-5.5-pro": publishedRate(30, 180, null, null),
  "gpt-5.4": publishedRate(2.5, 15, 0.25, null),
  "gpt-5.4-mini": publishedRate(0.75, 4.5, 0.075, null),
  "gpt-5.4-nano": publishedRate(0.2, 1.25, 0.02, null),
  "gpt-5.4-pro": publishedRate(30, 180, null, null),
  "gpt-5.3-codex": publishedRate(1.75, 14, 0.175, null),
  "gpt-5.2": publishedRate(1.75, 14, 0.175, null),
  "gpt-5.2-pro": publishedRate(21, 168, null, null),
  "gpt-5.1": publishedRate(1.25, 10, 0.125, null),
  "gpt-5": publishedRate(1.25, 10, 0.125, null),
  "gpt-5-mini": publishedRate(0.25, 2, 0.025, null),
  "gpt-5-nano": publishedRate(0.05, 0.4, 0.005, null),
  "gpt-5-pro": publishedRate(15, 120, null, null),
  "chat-latest": publishedRate(5, 30, 0.5, null)
}

var BUNDLED_CODEX_ALIASES = {
  // User-authorized estimate, 2026-09-10; not a proven current billing alias.
  // Basis: https://alignment.openai.com/auto-review/ (2026-04-30).
  "codex-auto-review": "gpt-5.4",
  "gpt-5.6": "gpt-5.6-sol",
  "gpt-daybreak-blue-latest": "gpt-5.6-sol"
}

var BUNDLED_CLAUDE_MODELS = {
  "claude-opus-5": publishedClaudeRate(5, 25, 0.5, 6.25, 10),
  "claude-opus-4-6": publishedClaudeRate(5, 25, 0.5, 6.25, 10),
  "claude-opus-4-7": publishedClaudeRate(5, 25, 0.5, 6.25, 10),
  "claude-opus-4-8": publishedClaudeRate(5, 25, 0.5, 6.25, 10),
  "claude-sonnet-5": publishedClaudeRate(2, 10, 0.2, 2.5, 4),
  "claude-sonnet-4-6": publishedClaudeRate(3, 15, 0.3, 3.75, 6),
  "claude-sonnet-4-5-20250929": publishedClaudeRate(3, 15, 0.3, 3.75, 6),
  "claude-haiku-4-5-20251001": publishedClaudeRate(1, 5, 0.1, 1.25, 2)
}

var BUNDLED_CLAUDE_ALIASES = {
  "claude-sonnet-4-5": "claude-sonnet-4-5-20250929"
}

var BUNDLED_CATALOG = {
  schemaVersion: 1,
  currency: "USD",
  denominator: 1000000,
  unit: "tokens",
  bundledAt: "2026-09-09",
  providers: {
    codex: {
      source: OPENAI_PRICING_SOURCE,
      models: BUNDLED_CODEX_MODELS,
      aliases: BUNDLED_CODEX_ALIASES
    },
    claude: {
      source: ANTHROPIC_PRICING_SOURCE,
      models: BUNDLED_CLAUDE_MODELS,
      aliases: BUNDLED_CLAUDE_ALIASES
    }
  }
}

function clone(value) {
  return JSON.parse(JSON.stringify(value))
}

function isPlainObject(value) {
  return !!value && typeof value === "object" && !Array.isArray(value)
}

function exactId(value) {
  return String(value || "").trim().toLowerCase()
}

function validRateNumber(value) {
  return typeof value === "number" && isFinite(value) && value >= 0 && value <= MAX_RATE_PER_MILLION
}

function bundledCatalog() {
  return clone(BUNDLED_CATALOG)
}

function emptyOverrides(errors) {
  return { schemaVersion: 1, models: {}, aliases: {}, errors: errors || [] }
}

function parseOverrides(content) {
  if (isPlainObject(content) && content.schemaVersion === 1 && isPlainObject(content.models)
      && isPlainObject(content.aliases) && Array.isArray(content.errors)) return content

  var parsed
  try {
    parsed = typeof content === "string" && content.trim() !== "" ? JSON.parse(content) : {}
  } catch (error) {
    return emptyOverrides(["Override file is not valid JSON"])
  }
  if (!isPlainObject(parsed)) return emptyOverrides(["Override root must be an object"])

  var result = emptyOverrides()
  var models = isPlainObject(parsed.models) ? parsed.models : {}
  for (var rawId in models) {
    if (!Object.prototype.hasOwnProperty.call(models, rawId)) continue
    var id = exactId(rawId)
    var entry = models[rawId]
    if (id === "" || !isPlainObject(entry) || !validRateNumber(entry.input)
        || !validRateNumber(entry.output)) {
      result.errors.push("Invalid manual tariff for " + String(rawId))
      continue
    }
    if (Object.prototype.hasOwnProperty.call(entry, "cacheRead") && !validRateNumber(entry.cacheRead)
        || Object.prototype.hasOwnProperty.call(entry, "cacheWrite") && !validRateNumber(entry.cacheWrite)) {
      result.errors.push("Invalid manual cache tariff for " + String(rawId))
      continue
    }
    var assumptions = []
    var cacheRead = entry.cacheRead
    var cacheWrite = entry.cacheWrite
    if (!Object.prototype.hasOwnProperty.call(entry, "cacheRead")) {
      cacheRead = Number((entry.input * 0.1).toFixed(12))
      assumptions.push("Cache read uses the documented manual default: 0.1× input")
    }
    if (!Object.prototype.hasOwnProperty.call(entry, "cacheWrite")) {
      cacheWrite = entry.input
      assumptions.push("Cache write uses the documented manual default: 1× input")
    }
    result.models[id] = {
      rates: { input: entry.input, output: entry.output, cacheRead: cacheRead, cacheWrite: cacheWrite },
      assumptions: assumptions
    }
  }

  var aliases = isPlainObject(parsed.aliases) ? parsed.aliases : {}
  for (var rawAlias in aliases) {
    if (!Object.prototype.hasOwnProperty.call(aliases, rawAlias)) continue
    var alias = exactId(rawAlias)
    var target = typeof aliases[rawAlias] === "string" ? exactId(aliases[rawAlias]) : ""
    if (alias === "" || target === "" || alias === target) {
      result.errors.push("Invalid manual alias for " + String(rawAlias))
      continue
    }
    result.aliases[alias] = target
  }
  return result
}

function manualRate(id, overrides) {
  var entry = overrides && overrides.models ? overrides.models[id] : null
  if (!entry || !entry.rates) return null
  return {
    modelId: id,
    rates: clone(entry.rates),
    currency: "USD",
    denominator: 1000000,
    tariff: "manual-standard",
    origin: "user-override",
    priceAsOf: "user configured",
    source: { name: "pricing.json", url: "", priceAsOf: "user configured" },
    assumptions: clone(entry.assumptions || [])
  }
}

function bundledRate(providerId, id) {
  var provider = BUNDLED_CATALOG.providers[providerId]
  var entry = provider && provider.models ? provider.models[id] : null
  if (!entry) return null
  return {
    modelId: id,
    rates: clone(entry.rates),
    currency: entry.currency,
    denominator: entry.denominator,
    tariff: entry.tariff,
    origin: "bundled-fallback",
    priceAsOf: entry.source.priceAsOf,
    source: clone(entry.source),
    assumptions: [providerId === "claude"
      ? "Standard short-context tariff estimate"
      : "Standard short-context tariff estimate; request-level input size is not retained in daily aggregation"]
  }
}

function rateAt(providerId, id, overrides) {
  return manualRate(id, overrides) || bundledRate(providerId, id)
}

function resolveRate(providerId, modelId, rawOverrides) {
  var provider = exactId(providerId)
  var id = exactId(modelId)
  if (provider === "" || id === "") return null
  var overrides = parseOverrides(rawOverrides || "")

  var directManual = manualRate(id, overrides)
  if (directManual) return directManual
  // Kimi has no proven historical alias mapping or bundled price.
  if (provider === "kimi") return null

  var manualTarget = overrides.aliases[id]
  if (manualTarget) {
    var manualAliased = rateAt(provider, manualTarget, overrides)
    if (manualAliased) {
      manualAliased.alias = id
      manualAliased.aliasOrigin = "user-override"
      return manualAliased
    }
  }

  var directBundled = bundledRate(provider, id)
  if (directBundled) return directBundled

  var providerCatalog = BUNDLED_CATALOG.providers[provider]
  var bundledTarget = providerCatalog && providerCatalog.aliases ? providerCatalog.aliases[id] : ""
  if (bundledTarget) {
    var bundledAliased = bundledRate(provider, bundledTarget)
    if (bundledAliased) {
      bundledAliased.alias = id
      bundledAliased.aliasOrigin = "documented-provider-alias"
      if (id === "codex-auto-review") {
        bundledAliased.aliasOrigin = "user-authorized-estimate"
        bundledAliased.assumptions.push("Provisional GPT-5.4 mapping chosen 2026-09-10 from OpenAI's 2026-04-30 Auto-review article; not proof of the current underlying or billed model")
      }
      return bundledAliased
    }
  }
  return null
}

function resolvedRate(providerId, modelId, rawOverrides, cache) {
  if (!cache) return resolveRate(providerId, modelId, rawOverrides)
  var key = exactId(modelId)
  if (Object.prototype.hasOwnProperty.call(cache, key)) return cache[key]
  cache[key] = resolveRate(providerId, modelId, rawOverrides)
  return cache[key]
}

function uniquePush(values, value) {
  if (value !== "" && values.indexOf(value) < 0) values.push(value)
}

// JSON arrays can cross a QML delegate boundary as indexable QQmlList-style
// sequences for which Array.isArray() is false. Copy only finite sequences so
// tooltip detail is not silently discarded at that boundary.
function sequenceValues(value) {
  if (Array.isArray(value)) return value
  if (value === null || value === undefined || typeof value === "string") return []
  var length = Number(value.length)
  if (!isFinite(length) || length < 0 || Math.floor(length) !== length) return []
  var result = []
  for (var i = 0; i < length; i++) result.push(value[i])
  return result
}

function tokenNumber(value) {
  return typeof value === "number" && isFinite(value) && value >= 0 && Math.floor(value) === value ? value : null
}

function affectedTariffComponents(providerId, bucket) {
  var affected = []
  var assumptions = []
  if (bucket && bucket.tariff !== undefined && bucket.tariff !== null && !isPlainObject(bucket.tariff)) {
    return {
      affected: ["input", "output", "cacheRead", "cacheWrite"],
      assumptions: ["Recorded tariff metadata is invalid"]
    }
  }
  var tariff = isPlainObject(bucket && bucket.tariff) ? bucket.tariff : {}
  // Present non-string values are invalid evidence, not an absent standard tier.
  var invalidTier = (tariff.service_tier !== undefined && tariff.service_tier !== null
      && typeof tariff.service_tier !== "string")
    || (tariff.speed !== undefined && tariff.speed !== null && typeof tariff.speed !== "string")
  if (invalidTier) {
    affected = ["input", "output", "cacheRead", "cacheWrite"]
    assumptions.push("Recorded service_tier or speed metadata is invalid")
  }
  var serviceTier = exactId(tariff.service_tier)
  var speed = exactId(tariff.speed)
  var inferenceGeo = exactId(tariff.inference_geo)

  if (serviceTier !== "" && serviceTier !== "default" && serviceTier !== "standard") {
    affected = ["input", "output", "cacheRead", "cacheWrite"]
    assumptions.push("Observed service_tier=" + serviceTier + " has no validated applicable bundled tariff")
  }
  if (speed !== "" && speed !== "standard") {
    affected = ["input", "output", "cacheRead", "cacheWrite"]
    assumptions.push("Observed speed=" + speed + " has no validated applicable bundled tariff")
  }
  if (tariff.fast_mode !== undefined && tariff.fast_mode !== null && tariff.fast_mode !== false) {
    affected = ["input", "output", "cacheRead", "cacheWrite"]
    assumptions.push("Observed fast_mode has no validated applicable bundled tariff")
  }
  if (tariff.inference_geo !== undefined && tariff.inference_geo !== null) {
    if (exactId(providerId) === "claude" && tariff.inference_geo === "not_available") {
      assumptions.push("Recorded inference geography is unavailable; the standard tariff estimate does not claim global routing")
    } else if (typeof tariff.inference_geo !== "string" || inferenceGeo !== "global") {
      affected = ["input", "output", "cacheRead", "cacheWrite"]
      assumptions.push("Observed inference_geo=" + inferenceGeo + " has no validated applicable bundled tariff")
    }
  }
  var cacheDuration = exactId(tariff.cache_duration)
  if (tariff.cache_duration !== undefined && tariff.cache_duration !== null
      && (typeof tariff.cache_duration !== "string" || cacheDuration !== "")
      && !(exactId(providerId) === "claude" && ["5m", "1h", "mixed-5m-1h"].indexOf(cacheDuration) >= 0)) {
    uniquePush(affected, "cacheWrite")
    assumptions.push("Observed cache_duration=" + String(tariff.cache_duration) + " has no validated cache-write tariff")
  }
  return { affected: affected, assumptions: assumptions }
}

// Shared Claude tariff metadata for native and future verified extra-source adapters.
// The four public token categories remain unchanged; this only allocates cache writes.
function claudeCacheWrite(bucket, rate) {
  var tariff = isPlainObject(bucket.tariff) ? bucket.tariff : {}
  var total = tokenNumber(bucket.tokens && bucket.tokens.cacheCreationInputTokens)
  var duration = exactId(tariff.cache_duration)
  if (tariff.cache_duration !== undefined && tariff.cache_duration !== null
      && (typeof tariff.cache_duration !== "string"
        || ["5m", "1h", "mixed-5m-1h"].indexOf(duration) < 0))
    return { cost: null, note: "Recorded cache duration has no validated cache-write tariff" }
  var five = total
  var hour = 0
  if (Object.prototype.hasOwnProperty.call(tariff, "cache_creation")) {
    var split = tariff.cache_creation
    five = tokenNumber(split && split.ephemeral_5m_input_tokens)
    hour = tokenNumber(split && split.ephemeral_1h_input_tokens)
    if (!isPlainObject(split) || five === null || hour === null || total === null
        || five + hour !== total || (duration === "5m" && hour > 0)
        || (duration === "1h" && five > 0))
      return { cost: null, note: "Cache creation duration split is invalid or does not reconcile with cache-write tokens" }
  } else if (duration === "1h") {
    five = 0
    hour = total
  } else if (duration === "mixed-5m-1h") {
    return { cost: null, note: "Mixed cache duration requires a reconciled numeric split" }
  }
  if (total === null) return { cost: null, note: "Cache-write total is unverified" }
  if (total === 0) return { cost: 0, note: "" }
  if (rate.origin === "user-override") {
    return { cost: validRateNumber(rate.rates.cacheWrite) ? total * rate.rates.cacheWrite / rate.denominator : null,
      note: "User-configured cache-write rate is assumed applicable to the observed cache duration; no bundled duration rate overrides it" }
  }
  if ((five > 0 && !validRateNumber(rate.rates.cacheWrite))
      || (hour > 0 && !validRateNumber(rate.rates.cacheWrite1h)))
    return { cost: null, note: "Applicable cache-duration rate is not published" }
  var note = duration === "" && !Object.prototype.hasOwnProperty.call(tariff, "cache_creation")
    ? "Absent cache-duration metadata assumes 5-minute cache writes"
    : five > 0 && hour > 0
      ? "Cache writes use an observed mixed 5-minute/1-hour duration split"
      : hour > 0
        ? "Cache writes use the observed 1-hour duration"
        : "Cache writes use the observed 5-minute duration"
  return { cost: ((five ? five * rate.rates.cacheWrite : 0)
      + (hour ? hour * rate.rates.cacheWrite1h : 0)) / rate.denominator,
    note: note }
}

function priceBucket(providerId, bucket, rawOverrides, rateCache) {
  var result = {
    status: "unknown",
    total: 0,
    components: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    missing: [],
    uncertainties: [],
    assumptions: [],
    rate: null,
    pricedTokens: 0
  }
  if (!isPlainObject(bucket)) {
    result.missing.push("Usage bucket is invalid")
    return result
  }
  var bucketIssues = Array.isArray(bucket.issues) ? bucket.issues : []
  for (var issueIndex = 0; issueIndex < bucketIssues.length; issueIndex++) {
    var issue = String(bucketIssues[issueIndex])
    if (NON_COST_BUCKET_ISSUES[issue] === true) uniquePush(result.uncertainties, issue)
    else uniquePush(result.missing, "Usage coverage: " + issue)
  }
  var providerSources = PRICED_SOURCES[exactId(providerId)] || {}
  if (providerSources[String(bucket.source || "")] !== true) {
    result.missing.push("Usage source " + String(bucket.source || "unknown") + " has no verified pricing contract")
    return result
  }

  var rate = resolvedRate(providerId, bucket.rawModel, rawOverrides, rateCache)
  if (!rate) {
    result.missing.push("No exact tariff for " + String(bucket.rawModel || "unknown model"))
    return result
  }
  result.rate = rate
  result.assumptions = clone(rate.assumptions || [])

  var tariffState = affectedTariffComponents(providerId, bucket)
  for (var ta = 0; ta < tariffState.assumptions.length; ta++)
    uniquePush(result.assumptions, tariffState.assumptions[ta])

  var tokens = isPlainObject(bucket.tokens) ? bucket.tokens : {}
  var cacheWrite = exactId(providerId) === "claude" ? claudeCacheWrite(bucket, rate) : null
  if (cacheWrite) {
    uniquePush(result.assumptions, cacheWrite.note)
    if (cacheWrite.cost === null) uniquePush(tariffState.affected, "cacheWrite")
  }
  var knownPositive = 0
  var unknownPositive = 0
  var anyPositive = false
  for (var i = 0; i < TOKEN_FIELDS.length; i++) {
    var tokenField = TOKEN_FIELDS[i][0]
    var rateField = TOKEN_FIELDS[i][1]
    var label = TOKEN_FIELDS[i][2]
    var count = tokenNumber(tokens[tokenField])
    if (count === null) {
      result.missing.push(label + " token count is unverified")
      unknownPositive++
      continue
    }
    if (count === 0) continue
    anyPositive = true
    var componentRate = rate.rates[rateField]
    if (tariffState.affected.indexOf(rateField) >= 0) {
      result.missing.push(label + " cost has an unsupported observed tariff")
      unknownPositive++
      continue
    }
    if (!validRateNumber(componentRate)) {
      result.missing.push(label + " price is not published")
      unknownPositive++
      continue
    }
    var componentCost = cacheWrite && rateField === "cacheWrite"
      ? cacheWrite.cost : count * componentRate / rate.denominator
    if (!isFinite(componentCost) || componentCost < 0) {
      result.missing.push(label + " cost could not be calculated")
      unknownPositive++
      continue
    }
    result.components[rateField] += componentCost
    result.total += componentCost
    result.pricedTokens += count
    knownPositive++
  }

  if (!anyPositive && unknownPositive === 0 && result.missing.length === 0) result.status = "complete"
  else if (knownPositive === 0 && unknownPositive > 0) result.status = "unknown"
  else if (unknownPositive > 0 || result.missing.length > 0) result.status = "partial"
  else result.status = "complete"
  return result
}

function formatTokenCount(value) {
  var n = tokenNumber(value)
  if (n === null) return "0"
  if (n >= 1e9) return (n / 1e9).toFixed(1) + "B"
  if (n >= 1e6) return (n / 1e6).toFixed(1) + "M"
  if (n >= 1e3) return (n / 1e3).toFixed(1) + "K"
  return String(n)
}

function formatCost(value) {
  var amount = typeof value === "number" && isFinite(value) && value >= 0 ? value : 0
  if (amount === 0) return "$0.00"
  if (amount < 0.01) return "$" + amount.toFixed(4)
  if (amount < 1000) return "$" + amount.toFixed(2)
  return "$" + amount.toFixed(0)
}

function formatRate(value) {
  return validRateNumber(value) ? "$" + String(value) : "—"
}

function formatCombined(tokens, cost, pricingEnabled) {
  var tokenText = formatTokenCount(tokens)
  if (pricingEnabled !== true) return tokenText
  if (!cost || cost.status === "unknown") return tokenText + "/—"
  return tokenText + "/" + formatCost(cost.total)
}

function dailyHeading(providerId, rows) {
  if (exactId(providerId) !== "codex" && exactId(providerId) !== "claude" && exactId(providerId) !== "kimi") return "TOKENS BY DAY"
  var values = Array.isArray(rows) ? rows : []
  for (var i = 0; i < values.length; i++) {
    var cost = values[i] && values[i].cost
    if (cost && (cost.status === "complete" || cost.status === "partial"))
      return "TOKENS / KNOWN API COST EST. (USD)"
  }
  return "TOKENS / API COST UNAVAILABLE"
}

function localDateString(value) {
  var date = value instanceof Date ? value : new Date(value)
  if (isNaN(date.getTime())) return ""
  return date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, "0")
    + "-" + String(date.getDate()).padStart(2, "0")
}

function recentDateStrings(nowMs, count) {
  var now = new Date(nowMs)
  if (isNaN(now.getTime())) now = new Date()
  var length = Math.max(0, Math.floor(Number(count) || 0))
  var dates = []
  for (var offset = length - 1; offset >= 0; offset--) {
    var date = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    date.setDate(date.getDate() - offset)
    dates.push(localDateString(date))
  }
  return dates
}

function legacyDayMap(recentDays) {
  var result = {}
  var days = Array.isArray(recentDays) ? recentDays : []
  for (var i = 0; i < days.length; i++) {
    var date = String(days[i] && days[i].date || "")
    var total = tokenNumber(days[i] && days[i].messageCount)
    if (date !== "" && total !== null) result[date] = total
  }
  return result
}

function validDailyUsage(value) {
  return isPlainObject(value) && value.schemaVersion === 1 && value.unit === "tokens"
    && Array.isArray(value.days) && typeof value.fromDate === "string" && typeof value.throughDate === "string"
}

function hasLocalizedCoverageIssue(providerId, dailyUsage) {
  var days = Array.isArray(dailyUsage && dailyUsage.days) ? dailyUsage.days : []
  for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
    var buckets = Array.isArray(days[dayIndex] && days[dayIndex].buckets) ? days[dayIndex].buckets : []
    for (var bucketIndex = 0; bucketIndex < buckets.length; bucketIndex++) {
      var bucket = buckets[bucketIndex]
      var sources = PRICED_SOURCES[exactId(providerId)] || {}
      if (!isPlainObject(bucket) || sources[String(bucket.source || "")] !== true) return true
      if (Array.isArray(bucket.issues) && bucket.issues.length > 0) return true
      if (bucket.rawModel === null || tokenNumber(bucket.totalTokens) === null) return true
      var tokens = isPlainObject(bucket.tokens) ? bucket.tokens : {}
      for (var tokenIndex = 0; tokenIndex < TOKEN_FIELDS.length; tokenIndex++)
        if (tokenNumber(tokens[TOKEN_FIELDS[tokenIndex][0]]) === null) return true
    }
  }
  return false
}

function globalCoverageMessages(providerId, dailyUsage) {
  var messages = []
  var issues = Array.isArray(dailyUsage && dailyUsage.issues) ? dailyUsage.issues : []
  for (var issueIndex = 0; issueIndex < issues.length; issueIndex++)
    uniquePush(messages, "Daily coverage: " + String(issues[issueIndex]))
  var unallocated = tokenNumber(dailyUsage && dailyUsage.unallocatedTokens)
  if (unallocated !== null && unallocated > 0)
    uniquePush(messages, formatTokenCount(unallocated) + " tokens cannot be assigned to a day")
  if (dailyUsage && dailyUsage.complete !== true && messages.length === 0
      && !hasLocalizedCoverageIssue(providerId, dailyUsage))
    uniquePush(messages, "Daily usage coverage is incomplete for an unreported scope")
  return messages
}

function mergeBucketCost(target, priced) {
  target.total += priced.total
  for (var component in target.components) target.components[component] += priced.components[component]
  for (var i = 0; i < priced.missing.length; i++) uniquePush(target.missing, priced.missing[i])
  for (var uncertaintyIndex = 0; uncertaintyIndex < priced.uncertainties.length; uncertaintyIndex++)
    uniquePush(target.uncertainties, priced.uncertainties[uncertaintyIndex])
  for (var j = 0; j < priced.assumptions.length; j++) uniquePush(target.assumptions, priced.assumptions[j])
  if (priced.rate) {
    var key = priced.rate.modelId + "|" + priced.rate.origin + "|" + priced.rate.priceAsOf
    if (!target.rateKeys[key]) {
      target.rateKeys[key] = true
      target.rates.push(priced.rate)
    }
  }
  target.pricedTokens += priced.pricedTokens || 0
  if (priced.status !== "complete") target.incompleteBuckets++
}

function dayCost(providerId, buckets, rawOverrides, dailyUsage, displayedTokens, rateCache) {
  var result = {
    status: "unknown", total: 0,
    components: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    missing: [], uncertainties: [], assumptions: [], rates: [], rateKeys: {}, pricedTokens: 0, incompleteBuckets: 0
  }
  buckets = compactPricingBuckets(buckets)
  var bucketTotal = 0
  var bucketTotalsKnown = true
  for (var i = 0; i < buckets.length; i++) {
    mergeBucketCost(result, priceBucket(providerId, buckets[i], rawOverrides, rateCache))
    var measured = tokenNumber(buckets[i] && buckets[i].totalTokens)
    if (measured === null) bucketTotalsKnown = false
    else bucketTotal += measured
  }

  var globalMessages = globalCoverageMessages(providerId, dailyUsage)
  for (var messageIndex = 0; messageIndex < globalMessages.length; messageIndex++)
    uniquePush(result.missing, globalMessages[messageIndex])

  var scopeMismatch = displayedTokens !== null && bucketTotalsKnown && bucketTotal !== displayedTokens
  if (scopeMismatch)
    uniquePush(result.missing, "Displayed token total does not match daily pricing coverage")

  if (scopeMismatch && result.pricedTokens === 0) result.status = "unknown"
  else if (scopeMismatch) result.status = "partial"
  else if (result.missing.length > 0 && result.pricedTokens === 0) result.status = "unknown"
  else if (result.missing.length > 0) result.status = "partial"
  else if (buckets.length === 0) result.status = "complete"
  else if (result.pricedTokens === 0 && result.incompleteBuckets > 0) result.status = "unknown"
  else if (result.incompleteBuckets > 0) result.status = "partial"
  else result.status = "complete"
  delete result.rateKeys
  delete result.pricedTokens
  delete result.incompleteBuckets
  return result
}

function buildDailyRows(providerId, dailyUsage, recentDays, nowMs, rawOverrides, scopeCompatible) {
  var provider = exactId(providerId)
  var pricedProvider = provider === "codex" || provider === "claude" || provider === "kimi"
  var dates = recentDateStrings(nowMs, 7)
  var legacy = legacyDayMap(recentDays)
  var overrides = parseOverrides(rawOverrides || "")
  var daily = validDailyUsage(dailyUsage) && scopeCompatible !== false ? dailyUsage : null
  var dailyByDate = {}
  var rateCache = {}
  if (daily) {
    for (var dayIndex = 0; dayIndex < daily.days.length; dayIndex++) {
      var item = daily.days[dayIndex]
      if (isPlainObject(item) && typeof item.date === "string" && Array.isArray(item.buckets)) dailyByDate[item.date] = item
    }
  }

  var rows = []
  for (var i = 0; i < dates.length; i++) {
    var date = dates[i]
    var day = dailyByDate[date]
    var hasLegacyTokens = Object.prototype.hasOwnProperty.call(legacy, date)
    var tokens = hasLegacyTokens ? legacy[date] : 0
    var cost = { status: "unknown", total: 0, components: {}, missing: [], uncertainties: [], assumptions: [], rates: [] }
    if (day) {
      var bucketTokens = 0
      for (var bucketIndex = 0; bucketIndex < day.buckets.length; bucketIndex++) {
        var measured = tokenNumber(day.buckets[bucketIndex] && day.buckets[bucketIndex].totalTokens)
        if (measured !== null) bucketTokens += measured
      }
      if (!hasLegacyTokens) tokens = bucketTokens
      cost = dayCost(provider, day.buckets, overrides, daily, hasLegacyTokens ? tokens : null, rateCache)
    } else if (pricedProvider) {
      if (scopeCompatible === false) cost.missing.push("Synchronized or legacy-only totals have no matching daily pricing coverage")
      else cost.missing.push("No versioned daily usage coverage for " + date)
    }
    cost.warnings = clone(overrides.errors || [])
    rows.push({
      date: date,
      messageCount: tokens,
      tokens: tokens,
      cost: cost,
      pricingEnabled: pricedProvider,
      value: formatCombined(tokens, cost, pricedProvider)
    })
  }
  return rows
}

function rateDetail(rate) {
  if (!rate) return ""
  var rates = rate.rates || {}
  return rate.modelId + " · " + String(rate.tariff || "tariff") + " · "
    + String(rate.origin || "unknown origin").replace(/-/g, " ") + " · price as of " + String(rate.priceAsOf || "unknown")
    + "\nRates per 1M: input " + formatRate(rates.input)
    + " · output " + formatRate(rates.output)
    + " · cache read " + formatRate(rates.cacheRead)
    + " · cache write" + (validRateNumber(rates.cacheWrite1h) ? " 5m" : "") + " " + formatRate(rates.cacheWrite)
    + (validRateNumber(rates.cacheWrite1h) ? " · cache write 1h " + formatRate(rates.cacheWrite1h) : "")
    + "\nSource: " + String(rate.source && rate.source.name || "unknown")
    + (rate.source && rate.source.url ? " · " + rate.source.url : "")
}

function dailyTooltipDetails(row) {
  if (!row) return ""
  var cost = row.cost || { status: "unknown", components: {}, missing: [], uncertainties: [], assumptions: [], rates: [] }
  var components = cost.components || {}
  var lines = ["API-equivalent estimate in USD · not a subscription bill"]
  if (cost.status === "unknown") {
    lines.push("Cost: unknown")
  } else {
    lines.push("Input " + formatCost(components.input || 0)
      + " · Output " + formatCost(components.output || 0)
      + " · Cache read " + formatCost(components.cacheRead || 0)
      + " · Cache write " + formatCost(components.cacheWrite || 0))
  }
  var rates = sequenceValues(cost.rates)
  for (var i = 0; i < rates.length; i++) lines.push(rateDetail(rates[i]))
  var assumptions = sequenceValues(cost.assumptions)
  if (assumptions.length > 0) lines.push("Assumptions: " + assumptions.join("; "))
  var missing = sequenceValues(cost.missing)
  if (missing.length > 0) lines.push("Missing coverage: " + missing.join("; "))
  var uncertainties = sequenceValues(cost.uncertainties)
  if (uncertainties.length > 0) lines.push("Usage uncertainty: " + uncertainties.join("; "))
  var warnings = sequenceValues(cost.warnings)
  if (warnings.length > 0) lines.push("Override warnings: " + warnings.join("; "))
  return lines.join("\n")
}

function dailyTooltip(row) {
  if (!row) return ""
  var details = dailyTooltipDetails(row)
  var summary = String(row.date || "") + " · " + formatTokenCount(row.tokens) + " tokens"
  return details ? summary + "\n" + details : summary
}

function presentationAggregate() {
  return {
    tokens: 0, tokenCoverage: [],
    cost: {
      status: "complete", total: 0,
      components: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      missing: [], uncertainties: [], assumptions: [], rates: [], rateKeys: {},
      pricedTokens: 0, incompleteBuckets: 0
    }
  }
}

function measuredBucketTokens(bucket) {
  var total = tokenNumber(bucket && bucket.totalTokens)
  if (total !== null) return { total: total, note: "" }
  var tokens = isPlainObject(bucket && bucket.tokens) ? bucket.tokens : {}
  var measured = 0
  var missing = []
  for (var i = 0; i < TOKEN_FIELDS.length; i++) {
    var value = tokenNumber(tokens[TOKEN_FIELDS[i][0]])
    if (value === null) missing.push(TOKEN_FIELDS[i][2])
    else measured += value
  }
  return {
    total: measured,
    note: "Total token count is unavailable; model/window tokens use measured categories"
      + (missing.length > 0 ? " (missing " + missing.join(", ") + ")" : "")
  }
}

// Request provenance stays in the record. Presentation arithmetic is linear,
// so buckets with the same pricing decision can be summed before tariff work.
function compactPricingBuckets(rawBuckets) {
  var buckets = Array.isArray(rawBuckets) ? rawBuckets : []
  var result = []
  var groups = {}
  var tariffKeys = ["service_tier", "speed", "fast_mode", "cache_duration", "inference_geo"]
  for (var index = 0; index < buckets.length; index++) {
    var bucket = buckets[index]
    var tokens = isPlainObject(bucket && bucket.tokens) ? bucket.tokens : null
    var rawTariff = bucket ? bucket.tariff : undefined
    var tariff = isPlainObject(rawTariff) ? rawTariff : {}
    var issues = Array.isArray(bucket && bucket.issues) ? bucket.issues : null
    var model = bucket && bucket.rawModel
    if (!tokens || !issues || !(model === null || typeof model === "string")
        || (rawTariff !== undefined && rawTariff !== null && !isPlainObject(rawTariff))) {
      result.push(bucket)
      continue
    }
    var safe = true
    var values = {}
    var known = []
    for (var fieldIndex = 0; fieldIndex < TOKEN_FIELDS.length; fieldIndex++) {
      var field = TOKEN_FIELDS[fieldIndex][0]
      var rawValue = tokens[field]
      var value = tokenNumber(rawValue)
      if (value === null && rawValue !== null && rawValue !== undefined) safe = false
      values[field] = value
      known.push(value !== null)
    }
    var total = tokenNumber(bucket.totalTokens)
    if (total === null && bucket.totalTokens !== null && bucket.totalTokens !== undefined) safe = false
    var issueValues = []
    for (var issueIndex = 0; issueIndex < issues.length; issueIndex++) {
      if (typeof issues[issueIndex] !== "string") safe = false
      issueValues.push(String(issues[issueIndex]))
    }
    for (var tariffName in tariff) {
      if (tariffKeys.indexOf(tariffName) < 0 && tariffName !== "cache_creation") safe = false
    }
    var tariffValues = []
    var compactTariff = {}
    for (var tariffIndex = 0; tariffIndex < tariffKeys.length; tariffIndex++) {
      var name = tariffKeys[tariffIndex]
      var present = Object.prototype.hasOwnProperty.call(tariff, name)
      var tariffValue = tariff[name]
      if (present && tariffValue !== null && typeof tariffValue !== "string"
          && typeof tariffValue !== "boolean" && typeof tariffValue !== "number") safe = false
      tariffValues.push([present, tariffValue])
      if (present) compactTariff[name] = tariffValue
    }
    var splitClass = "none"
    if (Object.prototype.hasOwnProperty.call(tariff, "cache_creation")) {
      var split = tariff.cache_creation
      var five = tokenNumber(split && split.ephemeral_5m_input_tokens)
      var hour = tokenNumber(split && split.ephemeral_1h_input_tokens)
      var duration = exactId(tariff.cache_duration)
      if (!isPlainObject(split) || five === null || hour === null
          || values.cacheCreationInputTokens === null
          || five + hour !== values.cacheCreationInputTokens
          || (duration === "5m" && hour > 0) || (duration === "1h" && five > 0)) {
        safe = false
      } else {
        splitClass = (five > 0 ? "5" : "0") + (hour > 0 ? "1" : "0")
        compactTariff.cache_creation = {
          ephemeral_5m_input_tokens: five,
          ephemeral_1h_input_tokens: hour
        }
      }
    }
    if (!safe) {
      result.push(bucket)
      continue
    }
    var key = JSON.stringify([model, String(bucket.source || ""), issueValues,
      known, total !== null, tariffValues, splitClass])
    var group = groups[key]
    if (!group) {
      group = { rawModel: model, source: String(bucket.source || ""), sourceId: String(bucket.sourceId || ""),
        tariff: compactTariff, totalTokens: total, tokens: values, issues: issueValues }
      groups[key] = group
      result.push(group)
      continue
    }
    if (total !== null) group.totalTokens += total
    for (var mergeIndex = 0; mergeIndex < TOKEN_FIELDS.length; mergeIndex++) {
      var mergeField = TOKEN_FIELDS[mergeIndex][0]
      if (values[mergeField] !== null) group.tokens[mergeField] += values[mergeField]
    }
    if (splitClass !== "none") {
      group.tariff.cache_creation.ephemeral_5m_input_tokens += compactTariff.cache_creation.ephemeral_5m_input_tokens
      group.tariff.cache_creation.ephemeral_1h_input_tokens += compactTariff.cache_creation.ephemeral_1h_input_tokens
    }
  }
  return result
}

function addPresentationBucket(target, measured, priced) {
  target.tokens += measured.total
  if (measured.note !== "") uniquePush(target.tokenCoverage, measured.note)
  mergeBucketCost(target.cost, priced)
}

function finishPresentation(target, extraMissing) {
  var cost = target.cost
  var additions = Array.isArray(extraMissing) ? extraMissing : []
  for (var i = 0; i < additions.length; i++) uniquePush(cost.missing, additions[i])
  if (cost.missing.length > 0 && cost.pricedTokens === 0) cost.status = "unknown"
  else if (cost.missing.length > 0) cost.status = "partial"
  else if (cost.pricedTokens === 0 && cost.incompleteBuckets > 0) cost.status = "unknown"
  else if (cost.incompleteBuckets > 0) cost.status = "partial"
  else cost.status = "complete"
  delete cost.rateKeys
  delete cost.incompleteBuckets
  target.value = formatCombined(target.tokens, cost, true)
  return target
}

function presentationTooltip(row) {
  if (!row) return ""
  var cost = row.cost || {}
  var lines = [formatTokenCount(row.tokens) + " local tokens · API-equivalent estimate in USD"]
  if (cost.status === "unknown") lines.push("Cost: unknown")
  else lines.push((cost.status === "partial" ? "Known subtotal: " : "Cost: ") + formatCost(cost.total))
  var priced = tokenNumber(cost.pricedTokens)
  if (priced !== null) {
    var denominator = tokenNumber(row.tokens)
    var coverage = denominator !== null && denominator > 0
      ? Math.floor(Math.min(100, priced * 100 / denominator)) + "% priced · "
      : ""
    lines.push("Priced-token coverage: " + coverage + formatTokenCount(priced)
      + " of " + formatTokenCount(row.tokens) + " assigned local tokens")
  }
  var tokenCoverage = sequenceValues(row.tokenCoverage)
  if (tokenCoverage.length > 0) lines.push("Token coverage: " + tokenCoverage.join("; "))
  var rates = sequenceValues(cost.rates)
  for (var i = 0; i < rates.length; i++) lines.push(rateDetail(rates[i]))
  if (cost.assumptions && cost.assumptions.length > 0) lines.push("Assumptions: " + cost.assumptions.join("; "))
  if (cost.missing && cost.missing.length > 0) lines.push("Missing coverage: " + cost.missing.join("; "))
  if (cost.uncertainties && cost.uncertainties.length > 0)
    lines.push("Usage uncertainty: " + cost.uncertainties.join("; "))
  return lines.join("\n")
}

function buildModelWindowPresentation(providerId, dailyUsage, nowMs, rawOverrides, scopeCompatible) {
  var provider = exactId(providerId)
  if ((provider !== "codex" && provider !== "claude" && provider !== "kimi") || !validDailyUsage(dailyUsage) || scopeCompatible === false)
    return { available: false, models: [], summaries: [] }
  var overrides = parseOverrides(rawOverrides || "")
  var dates30 = recentDateStrings(nowMs, 30)
  var inThirty = {}
  var inSeven = {}
  for (var i = 0; i < dates30.length; i++) {
    inThirty[dates30[i]] = true
    if (i >= dates30.length - 7) inSeven[dates30[i]] = true
  }
  var today = dates30[dates30.length - 1]
  var modelMap = {}
  var windows = {
    today: presentationAggregate(),
    seven: presentationAggregate(),
    thirty: presentationAggregate()
  }
  var rateCache = {}
  var days = dailyUsage.days || []
  for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
    var day = days[dayIndex] || {}
    if (inThirty[String(day.date || "")] !== true) continue
    var buckets = compactPricingBuckets(day.buckets)
    for (var bucketIndex = 0; bucketIndex < buckets.length; bucketIndex++) {
      var bucket = buckets[bucketIndex]
      var measured = measuredBucketTokens(bucket)
      var priced = priceBucket(provider, bucket, overrides, rateCache)
      var id = exactId(bucket && bucket.rawModel)
      var key = id === "" ? "(unknown model)" : id
      if (!modelMap[key]) {
        modelMap[key] = presentationAggregate()
        modelMap[key].id = key
      }
      addPresentationBucket(modelMap[key], measured, priced)
      addPresentationBucket(windows.thirty, measured, priced)
      if (inSeven[day.date] === true) addPresentationBucket(windows.seven, measured, priced)
      if (day.date === today) addPresentationBucket(windows.today, measured, priced)
    }
  }
  var models = []
  for (var modelId in modelMap) {
    var model = finishPresentation(modelMap[modelId], [])
    model.tooltip = presentationTooltip(model)
    models.push(model)
  }
  models.sort(function(a, b) {
    if (b.tokens !== a.tokens) return b.tokens - a.tokens
    return a.id < b.id ? -1 : (a.id > b.id ? 1 : 0)
  })
  var missingPriceModels = []
  for (var missingIndex = 0; missingIndex < models.length; missingIndex++) {
    if (!resolvedRate(provider, models[missingIndex].id, overrides, rateCache))
      missingPriceModels.push(models[missingIndex].id)
  }
  var globalMissing = globalCoverageMessages(provider, dailyUsage)
  var summaries = [
    { key: "today", label: "Today", aggregate: windows.today },
    { key: "seven", label: "7 days", aggregate: windows.seven },
    { key: "thirty", label: "30 days", aggregate: windows.thirty }
  ]
  for (var summaryIndex = 0; summaryIndex < summaries.length; summaryIndex++) {
    var summary = summaries[summaryIndex]
    finishPresentation(summary.aggregate, globalMissing)
    summary.tokens = summary.aggregate.tokens
    summary.cost = summary.aggregate.cost
    summary.value = summary.aggregate.value
    summary.tokenCoverage = summary.aggregate.tokenCoverage
    summary.tooltip = presentationTooltip(summary)
    delete summary.aggregate
  }
  return {
    available: true,
    models: models.slice(0, 4),
    summaries: summaries,
    modelCount: models.length,
    missingPriceModels: missingPriceModels
  }
}

function createPresentationCache() {
  return { daily: {}, models: {} }
}

function cachedPresentation(cache, kind, provider, nowMs, overrides, revision) {
  if (!cache || !provider) return kind === "daily" ? [] : { available: false, models: [], summaries: [] }
  var id = exactId(provider.providerId)
  var store = cache[kind] || (cache[kind] = {})
  var stamp = localDateString(nowMs) + "|" + String(revision)
  var entry = store[id]
  if (entry && entry.dailyUsage === provider.dailyUsage && entry.recentDays === provider.recentDays
      && entry.costScopeCompatible === provider.costScopeCompatible && entry.stamp === stamp) return entry.value
  var value = kind === "daily"
    ? buildDailyRows(id, provider.dailyUsage, provider.recentDays, nowMs, overrides, provider.costScopeCompatible)
    : buildModelWindowPresentation(id, provider.dailyUsage, nowMs, overrides, provider.costScopeCompatible)
  store[id] = { dailyUsage: provider.dailyUsage, recentDays: provider.recentDays,
    costScopeCompatible: provider.costScopeCompatible, stamp: stamp, value: value }
  return value
}

function cachedDailyRows(cache, provider, nowMs, overrides, revision) {
  return cachedPresentation(cache, "daily", provider, nowMs, overrides, revision)
}

function cachedModelWindowPresentation(cache, provider, nowMs, overrides, revision) {
  return cachedPresentation(cache, "models", provider, nowMs, overrides, revision)
}

// The original record stays on disk. Only its equivalent compact presentation
// crosses into QML, so parsing request histories never blocks the GUI thread.
function parseDisplayRecord(content) {
  var record = JSON.parse(String(content || ""))
  if (!isPlainObject(record)) return null
  // A legacy helper can embed its full scan cache here. Main reads the flat
  // display fields; this duplicate history must not cross the GUI boundary.
  delete record.stats
  if (validDailyUsage(record.dailyUsage)) {
    var days = record.dailyUsage.days
    for (var i = 0; i < days.length; i++) {
      if (isPlainObject(days[i]) && Array.isArray(days[i].buckets))
        days[i].buckets = compactPricingBuckets(days[i].buckets)
    }
  }
  return record
}

if (typeof WorkerScript !== "undefined" && typeof WorkerScript.sendMessage === "function") {
  WorkerScript.onMessage = function(message) {
    var record = null
    try { record = parseDisplayRecord(message.chunks.join("")) } catch (error) {}
    WorkerScript.sendMessage({ generation: message.generation, record: record })
  }
}

if (typeof module !== "undefined") module.exports = {
  parseDisplayRecord: parseDisplayRecord,
  bundledCatalog: bundledCatalog,
  parseOverrides: parseOverrides,
  resolveRate: resolveRate,
  priceBucket: priceBucket,
  formatTokenCount: formatTokenCount,
  formatCost: formatCost,
  formatRate: formatRate,
  formatCombined: formatCombined,
  dailyHeading: dailyHeading,
  localDateString: localDateString,
  recentDateStrings: recentDateStrings,
  buildDailyRows: buildDailyRows,
  createPresentationCache: createPresentationCache,
  cachedDailyRows: cachedDailyRows,
  cachedModelWindowPresentation: cachedModelWindowPresentation,
  dailyTooltipDetails: dailyTooltipDetails,
  dailyTooltip: dailyTooltip,
  buildModelWindowPresentation: buildModelWindowPresentation,
  presentationTooltip: presentationTooltip
}
