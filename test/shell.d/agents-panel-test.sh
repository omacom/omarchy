#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.selectProvider\(root\.providerIndex \+ 1\)/.test(panelSource), 'agents middle click still advances the subscription')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')

const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
assert(/icon:\s*String\(record\.icon\s*\|\|\s*""\)/.test(mainSource), 'Main displayProvider preserves custom icon field')
assert(/iconLight:\s*String\(record\.iconLight\s*\|\|\s*""\)/.test(mainSource), 'Main displayProvider preserves custom iconLight field')
assert(/if\s*\(p\.icon\)/.test(panelSource), 'Panel iconCandidatesForProvider checks record icon')
assert(/agentAssetsDir/.test(panelSource), 'Panel iconCandidatesForProvider checks user config agent assets directory')
JS
