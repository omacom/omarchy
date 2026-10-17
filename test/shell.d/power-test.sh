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

// Several packs.
const pack = (nativePath, fields) => Object.assign({ ready: true, isPresent: true, isLaptopBattery: true, nativePath, energyCapacity: 20, energy: 10, changeRate: 0 }, fields)
const display = { isPresent: true, percentage: 0.49, state: states.Charging }
const metadata = power.parsePackMetadata(power.parseKeyValue('pack.0.path\tBAT0\npack.0.voltage\t0\npack.0.thresholdStart\t75\npack.0.thresholdEnd\t80\npack.1.path\tBAT1\npack.1.cycles\t27\npack.1.thresholdStart\t75\npack.1.thresholdEnd\t80\n'))
assertEqual(metadata.BAT1.cycles, '27', 'power keys pack metadata by device name')

const packs = power.laptopDevices([
  pack('/sys/class/power_supply/BAT1', { energyCapacity: 50 }),
  pack('hidpp_battery_0', { isLaptopBattery: false }),
  pack('BAT2', { energyCapacity: 0 }),
  pack('BAT0')
])
assertDeepEqual(packs.map(power.deviceName), ['BAT0', 'BAT1'], 'power lists laptop packs in name order, without a mouse or an empty bay')

assertEqual(power.combinedBattery(packs, display, {}), display, 'power uses the display device while every pack holds charge')
const dead = power.laptopDevices([pack('BAT0', { energy: 0 }), pack('BAT1', { energyCapacity: 50, energy: 49.5, percentage: 0.99, state: states.Charging })])
assertEqual(power.combinedBattery(dead, display, metadata).percentage, 0.99, 'power leaves a dead pack out of the headline')
assertEqual(power.combinedBattery(dead, display, { BAT0: { voltage: '10.9' } }), display, 'power keeps a drained pack that still shows a voltage')

const atLimit = (nativePath, percentage, state) => pack(nativePath, { percentage, state })
assert(power.chargeThresholdActiveForPacks([pack('BAT0', { energy: 0, percentage: 0, state: states.PendingCharge }), atLimit('BAT1', 0.79, states.PendingCharge)], false, states, metadata), 'power lets a dead pack not stop the others holding')
const limits = { BAT0: { thresholdStart: '75', thresholdEnd: '80' }, BAT1: { thresholdStart: '75', thresholdEnd: '80' } }
assert(power.chargeThresholdActiveForPacks([atLimit('BAT0', 0.77, states.PendingCharge), atLimit('BAT1', 0.79, states.PendingCharge)], false, states, limits), 'power holds when every pack is at its limit')
assert(!power.chargeThresholdActiveForPacks([atLimit('BAT0', 0.6, states.PendingCharge), pack('BAT1', { percentage: 0.5, state: states.Charging, changeRate: 20 })], false, states, limits), 'power does not hold while a pack waits for its turn')
assert(!power.chargeThresholdActiveForPacks([atLimit('BAT0', 0.77, states.PendingCharge), atLimit('BAT1', 0.79, states.PendingCharge)], true, states, limits), 'power does not hold on battery')
assert(power.chargeThresholdActiveForPacks([atLimit('BAT0', 0.8, states.Charging), atLimit('BAT1', 1, states.FullyCharged)], false, states, limits), 'power holds with one pack at its limit and the other full')

assertEqual(power.packSummary(atLimit('BAT0', 0.77, states.PendingCharge), false, states, limits.BAT0), '77% · Holding', 'power labels a pack at its limit')
assertEqual(power.packSummary(atLimit('BAT0', 0.05, states.PendingCharge), false, states, limits.BAT0), '5% · Waiting to charge', 'power labels a pack waiting to charge')
assertEqual(power.packSummary(pack('BAT0', { energy: 0, percentage: 0 }), false, states, {}), '0% · Not holding charge', 'power labels a dead pack')
assertEqual(power.formatThreshold(limits.BAT0), '75-80%', 'power formats a pack limit')

const charging = { isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0 }
assertEqual(power.batteryIcon(charging, false, states, true), power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states), 'power shows the plain icon when the packs are holding')
assertEqual(power.modeLabel(charging, false, states, undefined, false), 'Charging', 'power takes the packs\' limit check over the display device')
assertEqual(power.packSummary(atLimit('BAT0', 0.77, states.PendingCharge), false, states, limits.BAT0, (key, english) => key, (v) => '<' + v + '>'), '<77>% · power.holding', 'power translates and localizes a pack summary')
assert(/readonly property var device: multiBattery\s*\? Model\.combinedBattery\([^\n]*\)\s*: UPower\.displayDevice/.test(panelSource), 'power keeps the display device for a single battery')

assert(/if \(b === Qt\.RightButton\) root\.togglePercentage\(\)/.test(panelSource), 'power right click toggles the bar percentage')
assert(/Object\.assign\([^\n]+showPercentage: !root\.showPercentage[^\n]+\)[\s\S]*updateEntryInline/.test(panelSource), 'power persists the bar percentage setting')
// BarIconButton lays its label out before the icon; bar-icon-geometry-test.sh checks the order.
assert(/text: root\.batteryIcon\(\)\n\s*labelText: root\.showPercentage && !vertical \? Commons\.I18n\.formatNumber\(Math\.round\(root\.batteryFraction \* 100\)\) \+ "%" : ""/.test(panelSource), 'power shows the percentage as the bar button label beside the battery icon')
assert(/openPanelIndicatorWidth:.*showPercentage.*button\.glyphPaintedWidth : 0/.test(panelSource), 'power spans the open-panel mark across the painted percentage block')
assert(/IpcHandler[\s\S]*?function togglePercentage\(\) \{ root\.togglePercentage\(\) \}/.test(panelSource), 'power exposes togglePercentage over IPC')
assert(/manageIpc: false/.test(panelSource), 'power owns its IPC handler so it can extend the target methods')
JS
