#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(root + '/shell/plugins/panels/power/Panel.qml', 'utf8')
const Model = requireFromRoot('shell/plugins/panels/power/Model.js')
const states = { Unknown: 0, Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4, PendingDischarge: 5 }

// Evaluate the JavaScript bindings read from the real QML. Getters keep their
// dependencies live, so a broken state-to-hero or state-to-label connection
// fails here even when the old source fragments are still present. This checks
// binding behavior with synthetic UPower inputs, not Qt rendering or signals.
function binding(name) {
  const match = source.match(new RegExp('^  readonly property \\w+ ' + name + ': (\\{[\\s\\S]*?^  \\}|\\[[\\s\\S]*?^  \\]|[^\\n]+)', 'm'))
  if (!match) fail('power panel declares the ' + name + ' binding')
  return match[1].startsWith('{') ? '(function() ' + match[1] + ')()' : match[1]
}

const panel = {
  Model,
  UPowerDeviceState: states,
  UPower: { displayDevice: null, onBattery: false },
  batteryInfo: { time: '2:00', rate: '8 W', threshold: '80%' },
  phraseIndex: 0,
  opened: true
}
panel.root = panel
const context = vm.createContext(panel)
const evaluate = expression => vm.runInContext(expression, context)
for (const name of ['upowerStates', 'batteryIcon', 'modeLabel']) {
  const match = source.match(new RegExp('^  function ' + name + '\\(\\) (\\{[\\s\\S]*?^  \\})', 'm'))
  if (!match) fail('power panel declares ' + name)
  panel[name] = () => evaluate('(function() ' + match[1] + ')()')
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
display(states.Discharging, true, { isPresent: false })
assert(!panel.batteryPresent && !panel.charging && !panel.discharging, 'an absent battery activates neither flow state')
assertEqual(panel.heroStatusText, '', 'an absent battery has no flow hero text')
JS
