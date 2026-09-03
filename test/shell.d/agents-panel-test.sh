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

// A record that outlives the refresh cadence is stale: the collector behind
// it stopped writing. Two refresh intervals leave room for a single missed
// run without crying wolf.
assert(/2 \* usage\.refreshIntervalSec \* 1000/.test(panelSource), 'agents panel flags records older than two refresh intervals')
assert(/function formatAge\(/.test(panelSource), 'agents panel formats the stale-record age')
assert(/detail: root\.staleText/.test(panelSource), 'agents panel shows the stale marker in the hero detail pill')
assert(/detailAlarming: root\.stale/.test(panelSource), 'agents panel paints the stale marker as an alarm')
assert(/updatedAtMs: Number\(new Date\(String\(record\.updatedAt/.test(mainSource), 'agents panel carries the record timestamp for staleness')
JS
