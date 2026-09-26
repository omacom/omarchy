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
assert(/never substitute all-time\/cycle modelUsage/.test(panelSource), 'agents panel refuses all-time modelUsage for Day/Week/Month')
assert(/todayFieldsAreCurrent\(p\)/.test(panelSource), 'agents panel only mints a Today row when today* fields are current')
assert(/providers\[i\]\.chipName \|\| providers\[i\]\.providerName/.test(panelSource), 'agents panel uses short chip names when many harnesses are present')
JS

run_node_test <<'JS'
const fs = require('fs')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')

assert(/function aggregateProviders\(list\)/.test(mainSource), 'agents display synthesizes an All tab from every harness')
assert(/providerId: "all"/.test(mainSource), 'agents All tab uses a stable virtual provider id')
assert(/function chipNameFor\(id, name\)/.test(mainSource), 'agents display shortens Antigravity to AGY on the chip row')
assert(/if \(id === "antigravity"\) return "AGY"/.test(mainSource), 'agents display labels Antigravity as AGY')
assert(/if \(id === "cursor"\) return "Cursor"/.test(mainSource), 'agents display labels Cursor on the chip row')
assert(/if \(id === "opencode"\) return "OpenCode"/.test(mainSource), 'agents display labels OpenCode on the chip row')
assert(/if \(id === "devin"\) return "Devin"/.test(mainSource), 'agents display labels Devin on the chip row')
assert(/function todayFieldsAreCurrent\(record\)/.test(mainSource), 'agents display ignores leftover today* fields from stale usage files')
assert(/command = \["omarchy-agent-usage-update"\]/.test(mainSource), 'agents display still regenerates records through the stock updater')
JS
