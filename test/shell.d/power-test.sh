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

assertEqual(power.parseThresholdEnd('80%'), 80, 'power reads a single charge threshold')
assertEqual(power.parseThresholdEnd('75-80%'), 80, 'power reads the end of a start-end threshold pair')
assert(Number.isNaN(power.parseThresholdEnd(undefined)), 'power reports no threshold when the battery exposes none')
assert(Number.isNaN(power.parseThresholdEnd('')), 'power reports no threshold for an empty reading')

assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, 80), 'power detects a limit the battery has reached')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Charging }, false, 80), 'power does not flag a limit the battery is still charging toward')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0.1, timeToFull: 120 }, false, NaN), 'power does not infer a limit from a stalled charge')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, NaN), 'power does not flag active charging as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, true, 80), 'power does not flag discharging as threshold')

// A cap lowered below a nearly full battery stops the charge without discharging
// the pack, so this is the ordinary state for days on mains.
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.99, state: states.FullyCharged }, false, 60), 'power reports a cap holding a nearly full battery')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.99, state: states.FullyCharged }, false, states, 60), 'Threshold', 'power labels a held battery as threshold')

// "Not charging" only means AC is present and the EC is not charging. A pack the
// EC has given up on is not a configured limit.
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0, state: states.PendingCharge }, false, 80), 'power does not report a limit for a battery nowhere near one')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0, state: states.PendingCharge }, false, 100), 'power treats a threshold of 100 as no limit')

// Hardware with no charge-control interface: Apple's SMC leaves the pack alone
// until it falls to roughly 93%, which arrives as fully-charged below 99%.
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.947, state: states.FullyCharged }, false, NaN), 'power does not invent a limit on hardware that has none')
assert(power.modeLabel({ isPresent: true, percentage: 0.947, state: states.FullyCharged }, false, states, NaN) !== 'Threshold', 'power does not label an SMC-held battery as threshold')

assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, 80),
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Discharging }, true, states, NaN),
  'power shows a non-charging icon while a limit is holding'
)
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

assert(/if \(b === Qt\.RightButton\) root\.togglePercentage\(\)/.test(panelSource), 'power right click toggles the bar percentage')
assert(/Object\.assign\([^\n]+showPercentage: !root\.showPercentage[^\n]+\)[\s\S]*updateEntryInline/.test(panelSource), 'power persists the bar percentage setting')
assert(/Math\.round\(root\.batteryFraction \* 100\) \+ "% " \+ root\.batteryIcon\(\)/.test(panelSource), 'power places the percentage before the battery icon')
assert(/openPanelIndicatorWidth:.*showPercentage.*button\.glyphPaintedWidth : 0/.test(panelSource), 'power spans the open-panel mark across the painted percentage block')
assert(/IpcHandler[\s\S]*?function togglePercentage\(\) \{ root\.togglePercentage\(\) \}/.test(panelSource), 'power exposes togglePercentage over IPC')
assert(/manageIpc: false/.test(panelSource), 'power owns its IPC handler so it can extend the target methods')
assert(/parseThresholdEnd\(root\.batteryInfo\.threshold\)/.test(panelSource), 'power reads the charge limit from the battery status output')
assert(/Model\.chargeThresholdActive\(device, root\.discharging, root\.chargeThresholdEnd\)/.test(panelSource), 'power decides the charge limit from the threshold rather than the charge level')
assert(/Component\.onCompleted: refreshBattery\(\)/.test(panelSource), 'power reads the battery before the panel is first opened so the bar icon has a limit')
JS
