#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
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
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, false), 'power does not read a rate from before the charger arrived as a threshold')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true), 'power detects threshold by stalled charging once the rate is fresh')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, false), 'power detects threshold by pending charge state before the rate is fresh')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, false),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states),
  'power shows charging icon while the charge rate is not fresh yet'
)
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 0 }, false, states, undefined, false), 'Charging', 'power labels charging while the charge rate is not fresh yet')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states), 'Fully charged', 'power labels full battery')
assertEqual(power.localizeReading('13.1W'), '13.1W', 'power keeps battery readings in English digits by default')
assertEqual(power.localizeReading('75-80%', function(v, d) { return '<' + v + '>' }), '<75>-<80>%', 'power localizes every number in a battery reading')
assertEqual(power.localizeReading('13.10W', function(v, d) { return v.toFixed(d).replace('.', ',') }), '13,10W', 'power keeps a reading\'s decimals when localizing')
assertEqual(power.localizeReading(undefined), '', 'power reads a missing battery field as empty')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, true, states), 'On battery', 'power labels battery mode')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'On battery', 'power trusts discharging state over a stale onBattery flag')
assert(power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, false, states).length > 0, 'power maps battery icons')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, false, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states),
  'power shows the discharging icon while the battery is discharging on AC'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, true, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states),
  'power shows the charging icon while the battery state is charging'
)
assert(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, true, states) !==
    power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states),
  'power charging icon differs from the discharging icon at the same level'
)
assertEqual(
  power.modeLabel({ isPresent: true, percentage: 0.4, state: states.Charging }, true, states),
  'Charging',
  'power labels charging from device state when onBattery is still true'
)
assertEqual(
  power.modeLabel({ isPresent: true, percentage: 1, state: states.Charging }, false, states),
  'Fully charged',
  'power keeps a full battery labeled fully charged while it reports charging'
)

JS

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(root + '/shell/plugins/panels/power/Panel.qml', 'utf8')
const Model = requireFromRoot('shell/plugins/panels/power/Model.js')
const Numbers = requireFromRoot('shell/Commons/Numbers.js')
const strings = JSON.parse(fs.readFileSync(root + '/default/i18n/en/shell.json', 'utf8'))
const states = { Unknown: 0, Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4, PendingDischarge: 5 }

// Evaluate the real bindings with synthetic UPower inputs; this checks
// presentation wiring, not Qt rendering or signal delivery.
function binding(name) {
  const match = source.match(new RegExp('^  readonly property \\w+ ' + name + ': (\\{[\\s\\S]*?^  \\}|\\[[\\s\\S]*?^  \\]|[^\\n]+)', 'm'))
  if (!match) fail('power panel declares the ' + name + ' binding')
  return match[1].startsWith('{') ? '(function() ' + match[1] + ')()' : match[1]
}

const panel = {
  Model,
  Commons: { I18n: {
    t: (key, fallback) => strings[key] || fallback || key,
    formatNumber: (value, decimals) => Numbers.format(value, decimals, ".", "0")
  } },
  Style: { reduceMotion: false },
  chargeRateFresh: true,
  UPowerDeviceState: states,
  UPower: { displayDevice: null, onBattery: false },
  batteryInfo: { time: '2:00', rate: '8 W', threshold: '80%' },
  phraseIndex: 0,
  opened: true
}
panel.root = panel
const context = vm.createContext(panel)
const evaluate = expression => vm.runInContext(expression, context)
for (const name of ['upowerStates', 'batteryIcon', 'modeLabel', 'reading']) {
  const match = source.match(new RegExp('^  function ' + name + '\\(([^)]*)\\) (\\{[\\s\\S]*?^  \\})', 'm'))
  if (!match) fail('power panel declares ' + name)
  panel[name] = evaluate('(function(' + match[1] + ') ' + match[2] + ')')
}
for (const name of ['batteryPresent', 'fullyCharged', 'discharging', 'chargeThresholdActive', 'batteryFull', 'batteryFlowIdle', 'batteryFraction', 'charging', 'chargingPhrases', 'onBatteryPhrases', 'activePhrases', 'rotatingPhrases', 'heroStatusText']) {
  const expression = binding(name)
  Object.defineProperty(panel, name, { get: () => evaluate(expression) })
}
const stats = [...source.matchAll(/InfoPair \{\s+label: ([^\n]+)\n\s+value: ([^\n]+)\n\s+\}/g)]
assertEqual(stats.length, 2, 'power panel exposes both dynamic battery info rows')
const hero = source.match(/id: heroStatus\s+textFormat:[^\n]+\s+text: ([^\n]+)/)
const pulse = source.match(/SequentialAnimation on opacity \{\s+running: ([^\n]+)/)
if (!hero || !pulse) fail('power panel exposes the hero text and charging pulse bindings')

function display(state, onBattery, extra = {}) {
  panel.UPower.onBattery = onBattery
  panel.UPower.displayDevice = { isPresent: true, percentage: 0.5, changeRate: 1, timeToFull: 120, state, ...extra }
  return {
    charging: panel.charging,
    discharging: panel.discharging,
    hero: evaluate(hero[1]),
    timeLabel: evaluate(stats[0][1]),
    timeValue: evaluate(stats[0][2]),
    rateLabel: evaluate(stats[1][1]),
    rateValue: evaluate(stats[1][2]),
    pulse: evaluate(pulse[1])
  }
}

const draining = {
  charging: false, discharging: true, hero: panel.onBatteryPhrases[0].toUpperCase(),
  timeLabel: 'Time left', timeValue: '2:00', rateLabel: 'Discharging', rateValue: '8 W', pulse: false
}
assertDeepEqual(display(states.Discharging, false), draining, 'discharging on AC drives the on-battery hero, time and rate labels, and no pulse')
const drainingIcon = panel.batteryIcon()
assertEqual(panel.modeLabel(), 'On battery', 'discharging on AC keeps the mode label on battery')
assertDeepEqual(display(states.Discharging, true), draining, 'ordinary discharging has the same panel presentation')
assertEqual(panel.batteryIcon(), drainingIcon, 'discharging on AC has the ordinary discharging icon')

const charging = {
  charging: true, discharging: false, hero: panel.chargingPhrases[0].toUpperCase(),
  timeLabel: 'Time to full', timeValue: '2:00', rateLabel: 'Charging', rateValue: '8 W', pulse: true
}
assertDeepEqual(display(states.Charging, true), charging, 'charging with a stale onBattery flag drives the charging hero, labels, and pulse')
const chargingIcon = panel.batteryIcon()
assertEqual(panel.modeLabel(), 'Charging', 'charging with a stale daemon flag keeps the charging mode label')
assert(chargingIcon !== drainingIcon, 'charging and discharging use different icons at the same percentage')
assertDeepEqual(display(states.Charging, false), charging, 'ordinary charging has the same panel presentation')
assertEqual(panel.batteryIcon(), chargingIcon, 'charging with a stale daemon flag has the ordinary charging icon')

for (const state of [states.Unknown, states.PendingCharge, states.PendingDischarge]) {
  assertDeepEqual(display(state, true), draining, 'state ' + state + ' falls back to onBattery throughout the panel')
}
assertDeepEqual(display(states.FullyCharged, false, { percentage: 1 }), {
  charging: false, discharging: false, hero: 'FULLY CHARGED',
  timeLabel: 'Time to full', timeValue: '-', rateLabel: 'Charging', rateValue: '-', pulse: false
}, 'fully charged presentation stays idle without a pulse')
assertDeepEqual(display(states.PendingCharge, false), {
  charging: false, discharging: false, hero: 'THRESHOLD',
  timeLabel: 'Charge limit', timeValue: '80%', rateLabel: 'Battery state', rateValue: 'Holding', pulse: false
}, 'charge-threshold presentation keeps its holding labels and no pulse')
panel.chargeRateFresh = false
assertDeepEqual(display(states.Charging, false, { changeRate: 0, timeToFull: 0 }), charging, 'a stale zero rate keeps the charging presentation while the rate settles')
assertEqual(panel.batteryIcon(), chargingIcon, 'the charging icon receives the rate freshness guard')
assertEqual(panel.modeLabel(), 'Charging', 'the mode label receives the rate freshness guard')
panel.chargeRateFresh = true
assertEqual(display(states.Charging, false, { changeRate: 0, timeToFull: 0 }).hero, 'THRESHOLD', 'a settled zero rate still identifies a held charge')
display(states.Discharging, true, { isPresent: false })
assert(!panel.batteryPresent && !panel.charging && !panel.discharging, 'an absent battery activates neither flow state')
assertEqual(panel.heroStatusText, '', 'an absent battery has no flow hero text')
JS
