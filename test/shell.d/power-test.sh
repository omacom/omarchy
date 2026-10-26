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
assertDeepEqual(power.parseChargeLimit('limit\ton\nend\t80\n'), { on: true, end: 80, available: true }, 'power reads an 80% charge limit that is on')
assertEqual(power.parseChargeLimit('limit\toff\nend\t100\n').available, false, 'power offers no choice when the limit already is a full charge')
assertEqual(power.parseChargeLimit('').available, false, 'power offers no choice for a battery without a charge limit')

const limitOn = { available: true, on: true }
const profiles = ['power-saver', 'balanced', 'performance']
const atProfiles = { section: 'profiles', chargeIndex: 1, profileIndex: 1 }
assertDeepEqual(power.moveCursor(atProfiles, 0, -1, limitOn, profiles), { section: 'chargeLimit', chargeIndex: 0, profileIndex: 1 }, 'power moves up to the charge limit, onto the value in force')
assertDeepEqual(power.moveCursor({ section: 'chargeLimit', chargeIndex: 0, profileIndex: 1 }, 1, 0, limitOn, profiles), { section: 'chargeLimit', chargeIndex: 1, profileIndex: 1 }, 'power walks the charge limit values sideways')
assertDeepEqual(power.moveCursor({ section: 'chargeLimit', chargeIndex: 1, profileIndex: 1 }, 0, 1, limitOn, profiles), { section: 'profiles', chargeIndex: 1, profileIndex: 1 }, 'power moves down back to the profiles')
assertDeepEqual(power.moveCursor(atProfiles, 0, 1, { available: false }, profiles), { section: 'profiles', chargeIndex: 1, profileIndex: 2 }, 'power walks the profiles with Down when there is no charge limit')
assertDeepEqual(power.moveCursor({ section: 'chargeLimit', chargeIndex: 0, profileIndex: 1 }, -1, 0, { available: false }, profiles), { section: 'profiles', chargeIndex: 0, profileIndex: 0 }, 'power leaves a charge limit row that went away')

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
