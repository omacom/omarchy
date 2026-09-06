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
assert(/property string period: "week"/.test(panelSource), 'agents panel defaults the token filter to the last week')
assert(/root\.period = "total"/.test(panelSource), 'agents panel can switch the token filter to all-time')
assert(/providers\[i\]\.chipName \|\| providers\[i\]\.providerName/.test(panelSource), 'agents panel uses short chip names when many harnesses are present')
JS

run_node_test <<'JS'
const fs = require('fs')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')

assert(/function aggregateProviders\(list\)/.test(mainSource), 'agents display synthesizes an All tab from every harness')
assert(/providerId: "all"/.test(mainSource), 'agents All tab uses a stable virtual provider id')
assert(/function chipNameFor\(id, name\)/.test(mainSource), 'agents display shortens Antigravity to AGY on the chip row')
assert(/if \(id === "antigravity"\) return "AGY"/.test(mainSource), 'agents display labels Antigravity as AGY')
assert(/command = \["omarchy-agent-usage-update"\]/.test(mainSource), 'agents display still regenerates records through the stock updater')
JS
