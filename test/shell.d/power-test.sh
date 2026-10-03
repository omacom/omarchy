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

assert(power.profileIcon('performance').length > 0, 'power maps profile icons')
assertEqual(power.batteryFraction({ isPresent: true, percentage: 1.5 }), 1, 'power clamps battery fraction')

assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states), 'power detects threshold by pending charge state')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0.1, timeToFull: 120 }, false, states), 'power detects threshold by stalled charging')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states), 'power does not flag active charging as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states), 'Fully charged', 'power labels full battery')
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

assertEqual(power.healthLevel('72%'), 72, 'power reads the health percentage out of its display string')
assertEqual(power.healthLevel(undefined), 0, 'power treats missing health as unknown rather than zero percent')
assertEqual(power.healthVerdict('95%'), 'Great', 'power calls a near-new pack great')
assertEqual(power.healthVerdict('103%'), 'Great', 'power handles a pack charging past its design capacity')
assertEqual(power.healthVerdict('90%'), 'Great', 'power keeps the practically-new boundary on the great side')
assertEqual(power.healthVerdict('89%'), 'Normal', 'power calls a lightly worn pack normal')
assertEqual(power.healthVerdict('80%'), 'Normal', 'power keeps the vendor service threshold on the normal side')
assertEqual(power.healthVerdict('79%'), 'Worn', 'power calls a pack below the service threshold worn')
assertEqual(power.healthVerdict('70%'), 'Worn', 'power keeps a third of the pack gone on the worn side')
assertEqual(power.healthVerdict('69%'), 'Bad', 'power calls a pack past a third of its capacity bad')
assertEqual(power.healthVerdict('41%'), 'Bad', 'power calls a badly degraded pack bad')
assertEqual(power.healthVerdict(undefined), '', 'power gives no verdict without a health figure')
assertEqual(power.healthHint('75%'), 'Worth planning a replacement', 'power tells a worn pack owner to plan ahead')
assertEqual(power.healthHint('50%'), 'Time to replace it', 'power tells a spent pack owner to act')
assertEqual(power.healthHint(undefined), '', 'power gives no hint without a health figure')

assert(/if \(b === Qt\.RightButton\) root\.togglePercentage\(\)/.test(panelSource), 'power right click toggles the bar percentage')
assert(/Object\.assign\([^\n]+showPercentage: !root\.showPercentage[^\n]+\)[\s\S]*updateEntryInline/.test(panelSource), 'power persists the bar percentage setting')
assert(/Math\.round\(root\.batteryFraction \* 100\) \+ "% " \+ root\.batteryIcon\(\)/.test(panelSource), 'power places the percentage before the battery icon')
assert(/openPanelIndicatorWidth:.*showPercentage.*button\.glyphPaintedWidth : 0/.test(panelSource), 'power spans the open-panel mark across the painted percentage block')
assert(/IpcHandler[\s\S]*?function togglePercentage\(\) \{ root\.togglePercentage\(\) \}/.test(panelSource), 'power exposes togglePercentage over IPC')
assert(/manageIpc: false/.test(panelSource), 'power owns its IPC handler so it can extend the target methods')

assert(/hasHealthInfo: !!\(batteryInfo\.design && batteryInfo\.health\)/.test(panelSource), 'power shows health rows only when both figures are present')
assert(/label: "Battery size"[\s\S]{0,200}root\.hasHealthInfo \? root\.batteryInfo\.design : root\.batteryInfo\.size/.test(panelSource), 'power labels the nameplate capacity as the battery size, falling back to what it holds')
assert(/label: "Current capacity"[\s\S]{0,120}root\.batteryInfo\.size/.test(panelSource), 'power shows what the pack charges to today beside its nameplate size')
assert(/text: "BATTERY HEALTH"/.test(panelSource), 'power gives battery health its own section')
assert(/label: "Charge cycles"[\s\S]{0,120}visible: !root\.hasHealthInfo/.test(panelSource), 'power keeps the cycle count in the stats grid when there is no health section to hold it')
JS
