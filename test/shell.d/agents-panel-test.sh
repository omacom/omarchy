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
assert(/readonly property bool showDailyUsage: setting\("showDailyUsage", false\) === true/.test(panelSource), 'agents panel defaults daily usage display to off')
assert(/readonly property bool showLimitPercentage: setting\("showLimitPercentage", false\) === true/.test(panelSource), 'agents panel defaults limit percentage display to off')
assert(/readonly property bool showLimitRemaining: setting\("showLimitRemaining", false\) === true/.test(panelSource), 'agents panel defaults limit wording to used')
assert(/function setDisplaySetting\(name, value\)/.test(panelSource), 'agents panel has a shared display setting persistence path')
assert(/root\.bar\.shell\.updateEntryInline\(root\.moduleName, next\)/.test(panelSource), 'agents panel persists display settings inline')
assert(/root\.setDisplaySetting\("showDailyUsage", !root\.showDailyUsage\)/.test(panelSource), 'agents daily usage toggle persists its setting')
assert(/root\.setDisplaySetting\("showLimitPercentage", !root\.showLimitPercentage\)/.test(panelSource), 'agents limit percentage toggle persists its setting')
assert(/root\.setDisplaySetting\("showLimitRemaining", !root\.showLimitRemaining\)/.test(panelSource), 'agents used or left toggle persists its setting')
assert(/text: root\.statusBarText/.test(panelSource), 'agents bar button uses the composed status text')
assert(/slotSize: root\.statusBarWidth/.test(panelSource), 'agents bar button sizes itself for status text')
assert(/Today " \+ usage\.formatTokenCount/.test(panelSource), 'agents status text includes formatted daily usage')
assert(/usage\.formatTokenCount\(Number\(root\.provider\.todayTotalTokens \|\| 0\)\) \+ " tokens"/.test(panelSource), 'agents status text labels daily usage as tokens')
assert(/Math\.round\(displayed \* 100\) \+ \(root\.showLimitRemaining \? "% left" : "% used"\)/.test(panelSource), 'agents status text follows the used or left mode')
assert(/label: "Show daily usage"/.test(panelSource) && /onClicked: root\.toggleDailyUsage\(\)/.test(panelSource), 'agents panel exposes a daily usage toggle')
assert(/label: "Show limit percentage"/.test(panelSource) && /onClicked: root\.toggleLimitPercentage\(\)/.test(panelSource), 'agents panel exposes a limit percentage toggle')
assert(/label: "Show remaining"/.test(panelSource) && /onClicked: root\.toggleLimitRemaining\(\)/.test(panelSource), 'agents panel exposes a used or left toggle')

const manifest = JSON.parse(fs.readFileSync(root + '/shell/plugins/agents/manifest.json', 'utf8'))
const defaults = manifest.barWidget.defaults
for (const key of ['showDailyUsage', 'showLimitPercentage', 'showLimitRemaining'])
  assert(defaults[key] === false, `agents manifest defaults ${key} to off`)
const providers = defaults.providers
for (const key of ['claude', 'codex', 'fireworks'])
  assert(providers[key] && providers[key].enabled === true, `agents manifest keeps ${key} enabled by default`)
for (const key of ['showDailyUsage', 'showLimitPercentage', 'showLimitRemaining']) {
  const setting = manifest.barWidget.schema.find(entry => entry.key === key)
  assert(setting && setting.type === 'boolean', `agents manifest declares ${key} as boolean`)
}
JS
