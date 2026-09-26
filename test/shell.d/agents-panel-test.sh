#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const manifest = JSON.parse(fs.readFileSync(root + '/shell/plugins/agents/manifest.json', 'utf8'))

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.selectProvider\(root\.providerIndex \+ 1\)/.test(panelSource), 'agents middle click still advances the subscription')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')

function panelFunction(name, args) {
  const body = panelSource.match(new RegExp('function ' + name + '\\([^)]*\\) \\{([^}]+)\\}'))?.[1]
  assert(body, 'agents define ' + name)
  return new Function(...args, body)
}

const remainingPercent = panelFunction('remainingPercent', ['w'])
assertEqual(remainingPercent({ percent: 0.61 }), 39, 'limit alert uses allowance remaining')
assertEqual(remainingPercent({ percent: 1.2 }), 0, 'remaining allowance clamps at zero')

const nowMs = Date.parse('2026-09-24T12:00:00Z')
const updatedAgeMs = panelFunction('updatedAgeMs', ['p', 'nowMs'])
const age = p => updatedAgeMs(p, nowMs)
const isStale = panelFunction('isStale', ['p', 'updatedAgeMs', 'usage'])
assertEqual(isStale({ updatedAt: '2026-09-24T11:45:00Z' }, age, { refreshIntervalSec: 900 }), false, 'recent usage remains fresh')
assertEqual(isStale({ updatedAt: '2026-09-24T11:29:00Z' }, age, { refreshIntervalSec: 900 }), true, 'old usage is marked stale')
assertEqual(isStale({}, age, { refreshIntervalSec: 900 }), true, 'missing update time is marked stale')
assertEqual(manifest.barWidget.defaults.lowRemainingPercent, 10, 'alert threshold has a default')
JS
