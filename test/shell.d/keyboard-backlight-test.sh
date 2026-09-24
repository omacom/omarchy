#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const kb = requireFromRoot('shell/plugins/services/keyboard-backlight/KeyboardBacklightModel.js')
const cfg = kb.config({ settleSeconds: 5, brightClearMinutes: 10, manualOffMaxHours: 8 })
const s = 1000
const min = 60 * s
const hour = 60 * min

assertEqual(kb.parseLux('=== Has ambient light sensor (value: 2.000000, unit: lux)'), 2, 'parses the first reading')
assertEqual(kb.parseLux('    Light changed: 80.000004 (lux)'), 80.000004, 'parses a change')
assertEqual(kb.parseLux('    Light changed: 12.000000 (vendor-specific)'), null, 'ignores non-lux units')
assertEqual(kb.parseLux('+++ iio-sensor-proxy appeared'), null, 'ignores other lines')

assertDeepEqual(kb.config({}), kb.config({ onBelowLux: 10, offAboveLux: 50 }), 'defaults the thresholds')
assertEqual(kb.config({ onBelowLux: 20, offAboveLux: 5 }).offAboveLux, 100, 'keeps off above on')
assertEqual(kb.config({ settleSeconds: 'x' }).settleMs, 5000, 'ignores invalid settle time')

// Settle: a reading has to hold before anything changes, which filters spikes
let state = kb.initialState(0, 2, 0)
let r = kb.evaluate(state, 1, 0, cfg)
assertEqual(r.set, null, 'waits for a dark reading to settle')
assertEqual(r.nextCheckMs, 5 * s, 'checks again once the reading has settled')
r = kb.evaluate(r.state, 6556, 1 * s, cfg)
r = kb.evaluate(r.state, 1, 2 * s, cfg)
assertEqual(r.set, null, 'a spike restarts the settle time')
r = kb.evaluate(r.state, 1, 7 * s, cfg)
assertEqual(r.set, 2, 'turns on in the dark at the maximum level')
state = r.state

// Dead band: between the thresholds nothing changes
r = kb.evaluate(state, 30, 20 * s, cfg)
r = kb.evaluate(r.state, 30, 30 * s, cfg)
assertEqual(r.set, null, 'leaves the backlight alone between thresholds')
assertEqual(r.nextCheckMs, -1, 'schedules nothing when settled')

// Manual off in the dark is held through a short bright spell
state = kb.observeBrightness(state, 0, 40 * s)
assertEqual(state.held, true, 'holds a manual off made while on')
r = kb.evaluate(state, 70, 41 * s, cfg)
r = kb.evaluate(r.state, 70, 46 * s, cfg)
assertEqual(r.set, 0, 'turns off in bright light')
r = kb.evaluate(r.state, 1, 2 * min, cfg)
r = kb.evaluate(r.state, 1, 2 * min + 5 * s, cfg)
assertEqual(r.set, null, 'keeps a manual off after a short bright spell')
assertEqual(r.state.held, true, 'reports the hold')
assertEqual(r.nextCheckMs, 8 * hour + 40 * s - (2 * min + 5 * s), 'checks again when the hold expires')

// A sustained bright spell clears the hold
r = kb.evaluate(r.state, 70, 3 * min, cfg)
r = kb.evaluate(r.state, 70, 3 * min + 5 * s, cfg)
r = kb.evaluate(r.state, 1, 14 * min, cfg)
r = kb.evaluate(r.state, 1, 14 * min + 5 * s, cfg)
assertEqual(r.set, 2, 'turns on again after the room was bright for a while')
state = r.state

// A manual level is remembered; turning it back on clears a hold
state = kb.observeBrightness(state, 1, 15 * min)
assertEqual(state.level, 1, 'remembers a manual level')
state = kb.observeBrightness(state, 0, 16 * min)
state = kb.observeBrightness(state, 1, 17 * min)
assertEqual(state.manualOffSince, 0, 'turning it back on clears the hold')
r = kb.evaluate(state, 70, 18 * min, cfg)
r = kb.evaluate(r.state, 70, 18 * min + 5 * s, cfg)
r = kb.evaluate(r.state, 1, 30 * min, cfg)
r = kb.evaluate(r.state, 1, 30 * min + 5 * s, cfg)
assertEqual(r.set, 1, 'turns on at the remembered level')
state = r.state

// A hold expires while still dark
state = kb.observeBrightness(state, 0, 1 * hour)
r = kb.evaluate(state, 1, 5 * hour, cfg)
assertEqual(r.set, null, 'still holds before the maximum age')
r = kb.evaluate(r.state, 1, 9 * hour, cfg)
assertEqual(r.set, 1, 'turns back on once the hold expires in the dark')

// A hold survives a restart
state = kb.initialState(0, 2, 10 * hour)
r = kb.evaluate(state, 1, 11 * hour, cfg)
r = kb.evaluate(r.state, 1, 11 * hour + 5 * s, cfg)
assertEqual(r.set, null, 'keeps a saved manual off after a restart')
state = kb.initialState(0, 2, 1 * hour)
r = kb.evaluate(state, 1, 11 * hour, cfg)
r = kb.evaluate(r.state, 1, 11 * hour + 5 * s, cfg)
assertEqual(r.set, 2, 'drops an expired saved manual off')

// Our own changes are not mistaken for manual ones
state = kb.initialState(0, 2, 0)
r = kb.evaluate(state, 1, 0, cfg)
r = kb.evaluate(r.state, 1, 5 * s, cfg)
assertEqual(kb.observeBrightness(r.state, 2, 6 * s), r.state, 'ignores the level it set itself')
JS
