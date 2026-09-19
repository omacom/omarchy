// Standard API rates in USD per million tokens. The panel estimates from the
// token categories in the collector contract; batch, priority, regional,
// tool, and dedicated-deployment charges are not inferable from aggregates.
// Verified 2026-09-07 against the providers' published pricing pages.

// Rates are [input, cache read, 5-minute/default cache write, output].
var providerRates = {
  codex: [
    [/^gpt-6-astra(?:-|$)/, [10, 1, 12.5, 50]],
    [/^gpt-5\.6-sol(?:-|$)/, [4, 0.4, 5, 20]],
    [/^gpt-5\.6-terra(?:-|$)/, [2, 0.2, 2.5, 12]],
    [/^gpt-5\.6-luna(?:-|$)/, [0.2, 0.02, 0.25, 1.2]],
    [/^gpt-5\.5-pro(?:-|$)/, [30, 30, 30, 180]],
    [/^gpt-5\.5(?:-|$)/, [5, 0.5, 6.25, 30]],
    [/^gpt-5\.4-pro(?:-|$)/, [30, 30, 30, 180]],
    [/^gpt-5\.4-mini(?:-|$)/, [0.75, 0.075, 0.9375, 4.5]],
    [/^gpt-5\.4-nano(?:-|$)/, [0.2, 0.02, 0.25, 1.25]],
    [/^gpt-5\.4(?:-|$)/, [2.5, 0.25, 3.125, 15]],
    [/^gpt-5\.3-codex(?:-|$)/, [1.75, 0.175, 2.1875, 14]],
    [/^gpt-5\.2-codex(?:-|$)/, [1.75, 0.175, 2.1875, 14]],
    [/^gpt-5\.1-codex-mini(?:-|$)/, [0.25, 0.025, 0.3125, 2]],
    [/^gpt-5\.1-codex(?:-max)?(?:-|$)/, [1.25, 0.125, 1.5625, 10]],
    [/^gpt-5-codex(?:-|$)/, [1.25, 0.125, 1.5625, 10]],
    [/^gpt-5-mini(?:-|$)/, [0.25, 0.025, 0.3125, 2]],
    [/^gpt-5-nano(?:-|$)/, [0.05, 0.005, 0.0625, 0.4]],
    [/^gpt-5(?:-chat-latest|-[0-9]{4}-[0-9]{2}-[0-9]{2}|$)/, [1.25, 0.125, 1.5625, 10]],
    [/^chat-latest$/, [5, 0.5, 6.25, 30]],
    [/^codex-mini-latest$/, [1.5, 0.375, 1.875, 6]]
  ],
  claude: [
    [/^claude-(?:mythos|opus)-(?:4-7|4-6)(?:-|$)/, [5, 0.5, 6.25, 25]],
    [/^claude-opus-4-5(?:-|$)/, [5, 0.5, 6.25, 25]],
    [/^claude-opus-(?:4-1|4)(?:-|$)/, [15, 1.5, 18.75, 75]],
    [/^claude-opus-3(?:-|$)/, [15, 1.5, 18.75, 75]],
    [/^claude-sonnet-(?:4-6|4-5|4)(?:-|$)/, [3, 0.3, 3.75, 15]],
    [/^claude-(?:3-7|3-5)-sonnet(?:-|$)/, [3, 0.3, 3.75, 15]],
    [/^claude-haiku-4-5(?:-|$)/, [1, 0.1, 1.25, 5]],
    [/^claude-3-5-haiku(?:-|$)/, [0.8, 0.08, 1, 4]],
    [/^claude-3-haiku(?:-|$)/, [0.25, 0.03, 0.3125, 1.25]]
  ],
  fireworks: [
    [/kimi-k2p6-turbo|kimi-k2\.6-turbo/, [2, 0.3, 0, 8]],
    [/kimi-k2p6|kimi-k2\.6/, [0.95, 0.16, 0, 4]],
    [/kimi-k2p5|kimi-k2\.5/, [0.6, 0.1, 0, 3]],
    [/deepseek-v4.*pro/, [1.74, 0.145, 0, 3.48]],
    [/deepseek-v3/, [0.56, 0.28, 0, 1.68]],
    [/glm-?5p1-fast|glm-?5\.1-fast/, [2.8, 0.52, 0, 8.8]],
    [/glm-?5p1|glm-?5\.1/, [1.4, 0.26, 0, 4.4]],
    [/glm-?5(?:-|$)/, [1, 0.2, 0, 3.2]],
    [/glm-?4p7|glm-?4\.7/, [0.6, 0.3, 0, 2.2]],
    [/minimax-m?2p7|minimax-m?2\.7/, [0.3, 0.06, 0, 1.2]],
    [/minimax-m?2p5|minimax-m?2\.5/, [0.3, 0.03, 0, 1.2]],
    [/qwen3.*vl.*30b/, [0.15, 0.075, 0, 0.6]],
    [/gpt-oss-120b/, [0.15, 0.015, 0, 0.6]],
    [/gpt-oss-20b/, [0.07, 0.035, 0, 0.3]]
  ]
}

function ratesFor(providerId, modelId) {
  var entries = providerRates[String(providerId || "")] || []
  var id = String(modelId || "").toLowerCase()
  for (var i = 0; i < entries.length; i++)
    if (entries[i][0].test(id)) return entries[i][1]
  return null
}

function cost(providerId, modelId, bucket) {
  var rate = ratesFor(providerId, modelId)
  if (!rate) return null
  var fields = ["inputTokens", "cacheReadInputTokens", "cacheCreationInputTokens", "outputTokens"]
  var total = 0
  for (var i = 0; i < fields.length; i++) {
    var tokens = Number(bucket[fields[i]] || 0)
    if (!isFinite(tokens) || tokens < 0) return null
    if (tokens > 0 && rate[i] === 0) return null
    total += tokens * rate[i] / 1000000
  }
  return total
}

function summary(providerId, buckets) {
  var total = 0
  var unknown = []
  var priced = 0
  for (var id in buckets) {
    var value = cost(providerId, id, buckets[id])
    if (value === null) unknown.push(id)
    else {
      total += value
      priced++
    }
  }
  return { total: total, unknown: unknown, priced: priced }
}
