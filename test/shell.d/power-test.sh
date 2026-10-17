#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/power/Panel.qml', 'utf8')
const states = { Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4 }

assertEqual(power.selectProfileIndex(0, 1, ['balanced', 'performance']), 1, 'power advances profile selection')
assertEqual(power.selectProfileIndex(1, 1, ['balanced', 'performance']), 1, 'power clamps profile selection')

assertDeepEqual(power.parseKeyValue('time\t2:00\nenergy\t42\n'), { time: '2:00', energy: '42' }, 'power parses key-value output')
assertDeepEqual(
  power.parseProfiles('power-saver\t0\nbalanced\t1\nperformance\t0\n', 5),
  { profiles: ['power-saver', 'balanced', 'performance'], activeProfile: 'balanced', profileIndex: 2 },
  'power parses profile output and clamps selection'
)

assertDeepEqual(power.parseChargeLimit('on 80\n'), { supported: true, enabled: true, end: 80 }, 'power parses an enabled charge limit')
assertDeepEqual(power.parseChargeLimit('off 60'), { supported: true, enabled: false, end: 60 }, 'power parses a disabled charge limit')
assertDeepEqual(power.parseChargeLimit('on'), { supported: true, enabled: true, end: 0 }, 'power parses a charge limit without a percentage')
assertDeepEqual(power.parseChargeLimit('off 100'), { supported: true, enabled: false, end: 0 }, 'power ignores a stopping point of full charge')
assertDeepEqual(power.parseChargeLimit(''), { supported: false, enabled: false, end: 0 }, 'power hides the charge limit without a supported battery')
assertDeepEqual(power.chargeLimitOptions(80).map(o => [o.enabled, o.label]), [[true, 'Limit 80%'], [false, 'Full 100%']], 'power labels the charge limit with its percentage')
assertDeepEqual(power.chargeLimitOptions(0).map(o => [o.enabled, o.label]), [[true, 'Limit'], [false, 'Full']], 'power labels a charging-mode limit without a percentage')
assert(power.chargeLimitOptions(80).every(o => o.icon.length > 0), 'power maps charge limit icons')
assert(/\["omarchy-battery-charge-limit", enabled \? "on" : "off"\]/.test(panelSource), 'power changes the charge limit through the Omarchy command')
assert(/onExited: root\.refreshChargeLimit\(\)/.test(panelSource), 'power re-reads the charge limit after changing it')
assert(!/function refresh\(\) \{[^}]*chargeLimit/.test(panelSource), 'power keeps the charge limit off the periodic refresh')

assert(power.profileIcon('performance').length > 0, 'power maps profile icons')
assertEqual(power.batteryFraction({ isPresent: true, percentage: 1.5 }), 1, 'power clamps battery fraction')

assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states), 'power detects threshold by pending charge state')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0.1, timeToFull: 120 }, false, states), 'power detects threshold by stalled charging')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states), 'power does not flag active charging as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states), 'Fully charged', 'power labels full battery')
assertEqual(power.localizeReading('13.1W'), '13.1W', 'power keeps battery readings in English digits by default')
assertEqual(power.localizeReading('75-80%', function(v, d) { return '<' + v + '>' }), '<75>-<80>%', 'power localizes every number in a battery reading')
assertEqual(power.localizeReading('13.10W', function(v, d) { return v.toFixed(d).replace('.', ',') }), '13,10W', 'power keeps a reading\'s decimals when localizing')
assertEqual(power.localizeReading(undefined), '', 'power reads a missing battery field as empty')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, true, states), 'On battery', 'power labels battery mode')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'Charging', 'power treats external power as newer than stale discharging state')
assert(power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, false, states).length > 0, 'power maps battery icons')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, false, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states),
  'power shows charging icon when external power is present before battery state refreshes'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, true, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states),
  'power shows battery icon when unplugged before battery state refreshes'
)

assert(/if \(b === Qt\.RightButton\) root\.togglePercentage\(\)/.test(panelSource), 'power right click toggles the bar percentage')
assert(/Object\.assign\([^\n]+showPercentage: !root\.showPercentage[^\n]+\)[\s\S]*updateEntryInline/.test(panelSource), 'power persists the bar percentage setting')
// BarIconButton lays its label out before the icon; bar-icon-geometry-test.sh checks the order.
assert(/text: root\.batteryIcon\(\)\n\s*labelText: root\.showPercentage && !vertical \? Commons\.I18n\.formatNumber\(Math\.round\(root\.batteryFraction \* 100\)\) \+ "%" : ""/.test(panelSource), 'power shows the percentage as the bar button label beside the battery icon')
assert(/openPanelIndicatorWidth:.*showPercentage.*button\.glyphPaintedWidth : 0/.test(panelSource), 'power spans the open-panel mark across the painted percentage block')
assert(/IpcHandler[\s\S]*?function togglePercentage\(\) \{ root\.togglePercentage\(\) \}/.test(panelSource), 'power exposes togglePercentage over IPC')
assert(/manageIpc: false/.test(panelSource), 'power owns its IPC handler so it can extend the target methods')
JS
