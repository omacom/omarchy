#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const agentSource = fs.readFileSync(root + '/shell/plugins/agents/Agent.qml', 'utf8')
const pricingSource = fs.readFileSync(root + '/shell/plugins/agents/Pricing.qml', 'utf8')
const toolTipSource = fs.readFileSync(root + '/shell/Ui/PanelToolTip.qml', 'utf8')

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.selectProvider\(root\.providerIndex \+ 1\)/.test(panelSource), 'agents middle click still advances the subscription')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')
assert(/import "ApiCost\.js" as ApiCost/.test(pricingSource), 'agents QML consumes the public pricing module tested by Node')
assert(/watchChanges: true/.test(pricingSource) && /onFileChanged: reload\(\)/.test(pricingSource),
  'agents pricing source watches edits to an existing override file')
assert(/property bool active: false/.test(pricingSource)
  && /running: root\.active && !root\.overrideAvailable/.test(pricingSource)
  && /repeat: true/.test(pricingSource)
  && !/running: true/.test(pricingSource),
  'agents pricing source limits absent-file retry polling to an active panel')
assert(/onActiveChanged: if \(active\) overrideFile\.reload\(\)/.test(pricingSource)
  && /onLoaded:[\s\S]*root\.overrideAvailable = true[\s\S]*root\.applyOverrides\(text\(\)\)/.test(pricingSource)
  && /onLoadFailed:[\s\S]*root\.overrideAvailable = false[\s\S]*root\.applyOverrides\(""\)/.test(pricingSource),
  'agents pricing source refreshes on activation and tracks file load or removal')
assert(/property bool pricingActive: false/.test(mainSource)
  && /Pricing \{ id: pricingTable; active: root\.pricingActive \}/.test(mainSource)
  && /pricingActive: root\.opened/.test(panelSource),
  'agents panel passes only its open lifecycle to pricing fallback refresh')
assert(/readonly property var dailyUsage: record && record\.dailyUsage/.test(agentSource)
  && /displayProvider\(record, agent\.dailyUsage\)/.test(mainSource),
  'agents daily usage flows through Agent and Main to the panel provider')
assert(/costScopeCompatible: !synced/.test(mainSource),
  'agents do not pair synchronized legacy tokens with local-only costs')
assert(/usage\.pricing\.dailyRows\(provider, nowMs\)/.test(panelSource)
  && /usage\.pricing\.dailyHeading\(root\.provider, usageSection\.days\)/.test(panelSource)
  && /dayRow\.day\.value/.test(panelSource),
  'agents panel renders shared compact pricing rows and their availability-aware heading')
assert(/function modelWindowPresentation\(provider, nowMs\)/.test(pricingSource)
  && /cachedModelWindowPresentation\(presentationCache, provider, nowMs, overrides, rev\)/.test(pricingSource)
  && /cachedDailyRows\(presentationCache, provider, nowMs, overrides, rev\)/.test(pricingSource)
  && /usage\.pricing\.modelWindowPresentation\(provider, nowMs\)/.test(panelSource)
  && /model: root\.modelSummaries/.test(panelSource),
  'priced model and window rows use the same reload-aware public pricing object')
assert(/function providerSupportsPricing\(value\)/.test(panelSource)
  && /value\.providerId === "codex" \|\| value\.providerId === "claude" \|\| value\.providerId === "kimi"/.test(panelSource)
  && /readonly property var days: root\.providerSupportsPricing\(root\.provider\)/.test(panelSource),
  'Claude, Codex, and Kimi share the pricing-backed day, model, heading, and limitation gates')
assert(/TOKENS \/ KNOWN API COST EST\. BY MODEL \(30 DAYS\)/.test(panelSource)
  && /Costs exclude usage with missing prices or token details\./.test(panelSource)
  && !/known API-cost subtotal/.test(panelSource),
  'Codex cost sections explain incomplete known costs without a star legend')
assert(/var text = label \+ " · " \+ usage\.formatTokenCount/.test(panelSource)
  && /Number\(provider\.todaySessions[\s\S]*text \+= "\\n" \+ usage\.pricing\.dailyTooltipDetails\(day\)/.test(panelSource)
  && !/return pricedText/.test(panelSource),
  'agents pricing appends details below the existing dated tooltip and shared today suffix')
assertEqual((panelSource.match(/Number\(provider\.todayPrompts/g) || []).length, 1,
  'agents day tooltip keeps the shared prompt and session suffix in one place')
assert(/property real maximumWidth:/.test(toolTipSource)
  && /implicitWidth: Math\.min\(contentItem\.implicitWidth, maximumWidth\)/.test(toolTipSource)
  && /wrapMode: Text\.Wrap\b/.test(toolTipSource)
  && !/wrapMode: Text\.WrapAnywhere/.test(toolTipSource),
  'panel tooltip structure exposes a width cap and prefers word boundaries with long-token fallback')
JS
