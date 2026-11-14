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

assertEqual(power.healthVerdict('95%', (key, english) => 'translated ' + key), 'translated power.healthGreat', 'power translates the health verdict through tr')
assertEqual(power.healthHint('75%', (key, english) => 'translated ' + key), 'translated power.healthPlanReplacement', 'power translates the health hint through tr')

const panelSource = require('fs').readFileSync(root + '/shell/plugins/panels/power/Panel.qml', 'utf8')
const scrollFunction = panelSource.match(/^  function ensureProfileVisible\(\) \{[\s\S]*?^  \}/m)
assert(scrollFunction, 'power exposes profile visibility handling for the loaded panel')

function profileScroll(options = {}) {
  const flick = {
    contentY: 0,
    contentHeight: 600,
    height: 200,
    contentItem: {},
    ...options
  }
  const context = {
    cursorActive: options.cursorActive !== false,
    panel: { loadedContent: options.loaded === false ? null : {
      scrollArea: { contentItem: flick },
      profileRow: { height: options.rowHeight || 60, mapToItem: () => ({ y: options.top ?? 520 }) }
    } },
    Style: { space: value => value }
  }
  require('vm').runInNewContext(scrollFunction[0] + '\nensureProfileVisible()', context)
  return flick.contentY
}

assertEqual(profileScroll(), 386, 'power scrolls an offscreen profile into view')
assertEqual(profileScroll({ top: 540 }), 400, 'power stops scrolling at the end of the content')
assertEqual(profileScroll({ top: 100, contentY: 300 }), 94, 'power brings a profile above the viewport back into view')
assertEqual(profileScroll({ top: 120, contentY: 100 }), 100, 'power leaves a fully visible profile in place')
assertEqual(profileScroll({ top: 100, contentHeight: 200 }), 0, 'power leaves fitting content at the top')
assertEqual(profileScroll({ cursorActive: false }), 0, 'power keeps mouse scrolling independent of keyboard selection')
assertEqual(profileScroll({ loaded: false }), 0, 'power handles profile selection before the content loads')
JS
