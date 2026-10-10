#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/power/Panel.qml', 'utf8')
const states = { Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4, PendingDischarge: 5 }

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

assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, '80%'), 'power detects threshold by pending charge state')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingDischarge }, false, states, '80%'), 'power detects threshold by pending discharge state on AC')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: 0 }, false, states, '80%'), 'power detects threshold by non-charging state on AC')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0.1, timeToFull: 120 }, false, states, '80%'), 'power detects threshold by stalled charging')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, timeToFull: 120 }, false, states, '80%'), 'power does not treat missing rate as stalled charge threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states, '80%'), 'power does not flag active charging as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0, state: 0 }, false, states, '80%'), 'power does not flag empty battery on AC as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0, state: states.PendingDischarge }, false, states, '80%'), 'power does not flag empty pending discharge as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingDischarge }, false, states), 'power does not flag pending discharge as threshold without a limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: 0 }, false, states), 'power does not flag non-charging state as threshold without a limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: 0 }, false, states, '-'), 'power does not flag non-charging state as threshold with missing limit marker')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states), 'Fully charged', 'power labels full battery')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, true, states), 'On battery', 'power labels battery mode')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'Charging', 'power treats external power as newer than stale discharging state')
assert(power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, false, states).length > 0, 'power maps battery icons')
assertEqual(power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, '80%'), '󰂂⁺', 'power returns the stepped battery level with plus superscript at threshold')
assertEqual(power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.PendingDischarge }, false, states, '80%'), '󰂂⁺', 'power returns the stepped battery level with plus superscript at pending discharge threshold')
assertEqual(power.batteryIcon({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states), '󱟢', 'power returns the battery-check glyph when fully charged')
assertEqual(power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Discharging }, true, states, 'power-saver'), '󰂂󰌪', 'power returns the stepped battery level with leaf glyph in power-saver profile')
assertEqual(power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Discharging }, true, states, 'performance'), '󰂂󰓅', 'power returns the stepped battery level with speedometer glyph in performance profile')
assertEqual(power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Discharging }, true, states, 'Power-saver'), '󰂂󰌪', 'power matches power-saver profile case-insensitively')
assertEqual(power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Discharging }, true, states, 'Performance'), '󰂂󰓅', 'power matches performance profile case-insensitively')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Discharging }, true, states, 'balanced'),
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Discharging }, true, states),
  'power falls back to default battery icon in balanced profile'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Charging }, false, states, 'power-saver'),
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Charging }, false, states),
  'power prioritizes charging icon on AC over battery profile'
)
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
assert(/Math\.round\(root\.batteryFraction \* 100\) \+ "% " \+ root\.batteryIcon\(\)/.test(panelSource), 'power places the percentage before the battery icon')
assert(/openPanelIndicatorWidth:.*showPercentage.*button\.glyphPaintedWidth : 0/.test(panelSource), 'power spans the open-panel mark across the painted percentage block')
assert(/IpcHandler[\s\S]*?function togglePercentage\(\) \{ root\.togglePercentage\(\) \}/.test(panelSource), 'power exposes togglePercentage over IPC')
assert(/manageIpc: false/.test(panelSource), 'power owns its IPC handler so it can extend the target methods')
assert(/PendingDischarge: UPowerDeviceState\.PendingDischarge/.test(panelSource), 'power maps PendingDischarge UPower state')
assert(/Model\.batteryIcon\(device,\s*root\.discharging,\s*upowerStates\(\),\s*root\.activeProfile,\s*root\.batteryInfo\.threshold\)/.test(panelSource), 'power passes active profile and threshold to batteryIcon')
assert(/hasModifier:.*hasProfileModifier.*chargeThresholdActive/.test(panelSource), 'power includes charge threshold in modifier check')
assert(/Timer[\s\S]*?15000[\s\S]*?!root\.discharging && !batteryProc\.running/.test(panelSource), 'power polls battery status on AC while closed')
assertEqual((panelSource.match(/\{/g) || []).length, (panelSource.match(/\}/g) || []).length, 'power Panel.qml braces are balanced')
JS
