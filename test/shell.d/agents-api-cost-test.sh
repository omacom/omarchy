#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const pricing = {}
vm.createContext(pricing)
vm.runInContext(fs.readFileSync(root + '/shell/plugins/agents/ApiCost.js', 'utf8'), pricing)

function tokens(input, cacheRead, cacheWrite, output) {
  return { inputTokens: input, cacheReadInputTokens: cacheRead, cacheCreationInputTokens: cacheWrite, outputTokens: output }
}

const supportedModels = {
  codex: [
    'gpt-6-astra', 'gpt-5.6-sol', 'gpt-5.6-terra', 'gpt-5.6-luna',
    'gpt-5.5-pro', 'gpt-5.5', 'gpt-5.4-pro', 'gpt-5.4-mini',
    'gpt-5.4-nano', 'gpt-5.4', 'gpt-5.3-codex', 'gpt-5.2-codex',
    'gpt-5.1-codex-mini', 'gpt-5.1-codex-max', 'gpt-5-codex',
    'gpt-5-mini', 'gpt-5-nano', 'gpt-5', 'chat-latest',
    'codex-mini-latest'
  ],
  claude: [
    'claude-mythos-4-7', 'claude-opus-4-5', 'claude-opus-4-1',
    'claude-opus-3', 'claude-sonnet-4-6', 'claude-3-7-sonnet',
    'claude-haiku-4-5', 'claude-3-5-haiku', 'claude-3-haiku'
  ],
  fireworks: [
    'kimi-k2p6-turbo', 'kimi-k2p6', 'kimi-k2p5', 'deepseek-v4-pro',
    'deepseek-v3', 'glm-5p1-fast', 'glm-5p1', 'glm-5', 'glm-4p7',
    'minimax-m2p7', 'minimax-m2p5', 'qwen3-vl-30b', 'gpt-oss-120b',
    'gpt-oss-20b'
  ]
}

for (const provider in supportedModels)
  for (const model of supportedModels[provider])
    assert(pricing.ratesFor(provider, model) !== null,
      'API cost has a rate for ' + provider + ' model ' + model)

assert(pricing.cost('codex', 'gpt-6-astra', tokens(1e6, 1e6, 1e6, 1e6)) === 73.5,
  'API cost prices every OpenAI token category')
assert(pricing.cost('codex', 'gpt-5.3-codex-20260801', tokens(1e6, 0, 0, 1e6)) === 15.75,
  'API cost recognizes dated OpenAI model snapshots')
assert(pricing.cost('codex', 'gpt-5.4-mini-2026-03-17', tokens(1e6, 0, 0, 1e6)) === 5.25,
  'API cost keeps OpenAI mini models out of the flagship family')
assert(pricing.cost('codex', 'gpt-5.5-pro', tokens(1e6, 1e6, 0, 1e6)) === 240,
  'API cost does not apply a cache discount to OpenAI Pro models')
assert(pricing.cost('claude', 'claude-sonnet-4-6-20260217', tokens(1e6, 1e6, 1e6, 1e6)) === 22.05,
  'API cost recognizes Claude families and prompt caching')
assert(Math.abs(pricing.cost('fireworks', 'accounts/fireworks/models/kimi-k2p6', tokens(1e6, 1e6, 0, 1e6)) - 5.11) < 1e-9,
  'API cost recognizes qualified Fireworks model ids')
assert(pricing.cost('fireworks', 'custom-lora', tokens(1e6, 0, 0, 0)) === null,
  'API cost leaves custom deployments unpriced')
assert(pricing.cost('codex', 'codex-auto-review', tokens(1e6, 0, 0, 0)) === null,
  'API cost leaves internal services unpriced')

const summary = pricing.summary('claude', {
  'claude-opus-4-6': tokens(1e6, 0, 0, 0),
  'private-model': tokens(1e6, 0, 0, 0)
})
assert(summary.total === 5 && summary.priced === 1 && summary.unknown[0] === 'private-model',
  'API cost totals known models and reports unknown models')
JS
