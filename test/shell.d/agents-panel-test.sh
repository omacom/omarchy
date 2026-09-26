#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.selectProvider\(root\.providerIndex \+ 1\)/.test(panelSource), 'agents middle click still advances the subscription')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')

assert(/function recordUpdatedAtMs\(record\)/.test(mainSource), 'display model parses record updatedAtMs')
assert(/updatedAt:\s*String\(record\.updatedAt \|\| ""\)/.test(mainSource), 'displayProvider copies record.updatedAt')
assert(/updatedAtMs:\s*updatedAtMs/.test(mainSource), 'displayProvider exposes updatedAtMs on the display object')
assert(/syncUpdatedAt:\s*aggregateData && aggregateData\.updatedAt/.test(mainSource), 'displayProvider still exposes syncUpdatedAt')

assert(/readonly property int staleAfterMs:/.test(panelSource), 'panel defines a stale threshold from refreshIntervalSec')
assert(/function providerIsStale\(p\)/.test(panelSource), 'panel has a stale UI path for aged usage records')
assert(/function staleUpdatedText\(p\)/.test(panelSource), 'panel formats an Updated … ago line for stale records')
assert(/Updated " \+ formatDuration\(age\) \+ " ago"/.test(panelSource), 'stale caption uses Updated … ago wording')
assert(/opacity:\s*root\.providerIsStale\(root\.provider\) \? 0\.65 : 1\.0/.test(panelSource), 'stale providers dim the hero')
assert(/root\.staleUpdatedText\(root\.provider\)/.test(panelSource), 'panel renders the staleUpdatedText caption')
JS
