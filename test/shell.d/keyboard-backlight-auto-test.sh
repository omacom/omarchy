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
assertEqual(kb.parseLux('=== Has ambient light sensor (value: 2,500000, unit: lux)'), 2.5, 'parses a comma decimal separator')
assertEqual(kb.parseLux('    Light changed: 77,000004 (lux)'), 77.000004, 'parses a comma decimal change')

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

// Dead band: with dimming off, nothing changes between the thresholds
const fixed = kb.config({ settleSeconds: 5, brightClearMinutes: 10, manualOffMaxHours: 8, dimming: false })
r = kb.evaluate(state, 30, 20 * s, fixed)
r = kb.evaluate(r.state, 30, 30 * s, fixed)
assertEqual(r.set, null, 'leaves the backlight alone between thresholds without dimming')
assertEqual(r.nextCheckMs, -1, 'schedules nothing when settled')

// Dimming: lit, it fades with the light between the thresholds, settling
// like a switch does, and never below the lowest lit step before turning off.
r = kb.evaluate(state, 30, 20 * s, cfg)
assertEqual(r.set, null, 'waits for a dimmer level to settle')
assertEqual(r.nextCheckMs, 5 * s, 'checks again once the dimmer level has settled')
r = kb.evaluate(r.state, 32, 25 * s, cfg)
assertEqual(r.set, 1, 'dims halfway between the thresholds')
r = kb.evaluate(r.state, 48, 30 * s, cfg)
r = kb.evaluate(r.state, 48, 35 * s, cfg)
assertEqual(r.set, null, 'stays at the lowest lit step just before turning off')
r = kb.evaluate(r.state, 5, 40 * s, cfg)
r = kb.evaluate(r.state, 5, 45 * s, cfg)
assertEqual(r.set, 2, 'brightens back to full in the dark')
assertEqual(r.nextCheckMs, -1, 'schedules nothing once at full')
let dimmed = r.state

// Many levels: small changes in the light aren't worth a write
const many = kb.evaluate(kb.evaluate(kb.initialState(0, 255, 0), 1, 0, cfg).state, 1, 5 * s, cfg)
assertEqual(many.set, 255, 'turns on at full on a keyboard with many levels')
r = kb.evaluate(many.state, 30, 10 * s, cfg)
r = kb.evaluate(r.state, 30, 15 * s, cfg)
assertEqual(r.set, 128, 'dims a keyboard with many levels smoothly')
r = kb.evaluate(r.state, 31, 20 * s, cfg)
r = kb.evaluate(r.state, 31, 25 * s, cfg)
assertEqual(r.set, null, 'skips a change too small to see')

// A level picked while lit stops the fading until the next switch
dimmed = kb.observeBrightness(dimmed, 1, 50 * s)
r = kb.evaluate(dimmed, 5, 55 * s, cfg)
r = kb.evaluate(r.state, 5, 60 * s, cfg)
assertEqual(r.set, null, 'leaves a level picked while lit alone')
r = kb.evaluate(r.state, 70, 61 * s, cfg)
r = kb.evaluate(r.state, 70, 66 * s, cfg)
r = kb.evaluate(r.state, 1, 70 * s, cfg)
r = kb.evaluate(r.state, 1, 75 * s, cfg)
assertEqual(r.set, 1, 'turns on at the picked level after the next switch')
r = kb.evaluate(r.state, 40, 80 * s, cfg)
r = kb.evaluate(r.state, 40, 85 * s, cfg)
assertEqual(r.state.dimHeld, false, 'fades again after the next switch')

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

// The keys changed the level while the shell was down: that's the user's
state = kb.initialState(0, 2, 0, 2, 1 * hour)
assertEqual(state.manualOffSince, 1 * hour, 'takes an off made while the shell was down as a manual off')
r = kb.evaluate(state, 1, 1 * hour, cfg)
r = kb.evaluate(r.state, 1, 1 * hour + 5 * s, cfg)
assertEqual(r.set, null, 'keeps an off made while the shell was down')
state = kb.initialState(1, 2, 0, 2, 1 * hour)
assertEqual(state.level, 1, 'remembers a level picked while the shell was down')
assertEqual(state.manualOffSince, 0, 'a level picked while the shell was down is not an off')
assertEqual(kb.initialState(0, 2, 0, 0, 1 * hour).manualOffSince, 0, 'an unchanged off is not a manual off')
assertEqual(kb.initialState(0, 2, 0, null, 1 * hour).manualOffSince, 0, 'no last level means nothing to compare')

// A bright period clears the hold when it ends, not at the next dark, so a
// restart in between doesn't bring the hold back
state = kb.initialState(2, 2, 0)
r = kb.evaluate(state, 1, 0, cfg)
r = kb.evaluate(r.state, 1, 5 * s, cfg)
state = kb.observeBrightness(r.state, 0, 10 * s)
r = kb.evaluate(state, 70, 1 * min, cfg)
r = kb.evaluate(r.state, 70, 1 * min + 5 * s, cfg)
assertEqual(r.nextCheckMs, 10 * min, 'checks again when the bright period clears the hold')
r = kb.evaluate(r.state, 70, 11 * min + 5 * s, cfg)
assertEqual(r.state.manualOffSince, 0, 'clears the hold once the room has been bright long enough')
assertEqual(r.nextCheckMs, -1, 'schedules nothing once the hold is cleared')

// Time blanked or under a closed lid isn't known to be bright, so it doesn't
// count toward clearing a hold. A short bright spell, a long blank, then a
// wake into the dark keeps the hold.
state = kb.initialState(2, 2, 0)
r = kb.evaluate(state, 1, 0, cfg)
r = kb.evaluate(r.state, 1, 5 * s, cfg)
state = kb.observeBrightness(r.state, 0, 10 * s)
r = kb.evaluate(state, 70, 1 * min, cfg)
r = kb.evaluate(r.state, 70, 1 * min + 5 * s, cfg)
state = kb.interrupt(r.state, 2 * min)
state = kb.resume(kb.uninterrupt(state, 20 * min), 0)
r = kb.evaluate(state, 1, 20 * min, cfg)
r = kb.evaluate(r.state, 1, 20 * min + 5 * s, cfg)
assertEqual(r.set, null, 'a blank does not count as bright time')
assertEqual(r.state.held, true, 'keeps holding after a blank that followed a short bright spell')

// The same under a closed lid, where nothing is re-applied: only the bright
// time on either side of it counts.
state = kb.initialState(2, 2, 0)
r = kb.evaluate(state, 1, 0, cfg)
r = kb.evaluate(r.state, 1, 5 * s, cfg)
state = kb.observeBrightness(r.state, 0, 10 * s)
r = kb.evaluate(state, 70, 1 * min, cfg)
r = kb.evaluate(r.state, 70, 1 * min + 5 * s, cfg)
state = kb.uninterrupt(kb.interrupt(r.state, 6 * min + 5 * s), 26 * min + 5 * s)
r = kb.evaluate(state, 70, 26 * min + 5 * s, cfg)
assertEqual(r.state.manualOffSince, 10 * s, 'a closed lid does not count as bright time')
assertEqual(r.nextCheckMs, 5 * min, 'counts the bright time from before the lid closed')
r = kb.evaluate(r.state, 70, 31 * min + 5 * s, cfg)
assertEqual(r.state.manualOffSince, 0, 'clears the hold once bright long enough in all')

// A wake with no blank before it pauses only for a moment, and deciding off
// again afterward continues the bright period rather than restarting it, so
// waking every few minutes doesn't keep a hold from clearing.
state = kb.initialState(2, 2, 0)
r = kb.evaluate(state, 1, 0, cfg)
r = kb.evaluate(r.state, 1, 5 * s, cfg)
state = kb.observeBrightness(r.state, 0, 10 * s)
r = kb.evaluate(state, 70, 1 * min, cfg)
r = kb.evaluate(r.state, 70, 1 * min + 5 * s, cfg)
for (const wake of [4 * min, 8 * min]) {
  state = kb.interrupt(r.state, wake)
  state = kb.resume(kb.uninterrupt(state, wake + 100), 0)
  r = kb.evaluate(state, 70, wake + 1 * s, cfg)
  r = kb.evaluate(r.state, 70, wake + 6 * s, cfg)
}
r = kb.evaluate(r.state, 70, 11 * min + 5 * s + 200, cfg)
assertEqual(r.state.manualOffSince, 0, 'wakes without a blank do not restart the bright period')

// Session wake: the restored level is a baseline, not the user's choice.
// Blanked while bright and off, woken in the dark with 0 restored: turns on.
state = kb.initialState(0, 2, 0)
r = kb.evaluate(state, 70, 0, cfg)
r = kb.evaluate(r.state, 70, 5 * s, cfg)
state = kb.resume(r.state, 0)
r = kb.evaluate(state, 1, 1 * hour, cfg)
r = kb.evaluate(r.state, 1, 1 * hour + 5 * s, cfg)
assertEqual(r.set, 2, 'turns on after a wake into a dark room')
assertEqual(r.state.manualOffSince, 0, 'does not take the restored off as a manual off')

// Blanked while dark and on, woken in daylight with the on level restored: turns off
state = kb.resume(r.state, 2)
r = kb.evaluate(state, 70, 9 * hour, cfg)
r = kb.evaluate(r.state, 70, 9 * hour + 5 * s, cfg)
assertEqual(r.set, 0, 'turns off after a wake into daylight')
assertEqual(r.state.level, 2, 'does not take the restored level as the user level')

// A held manual off is put back when a wake restores a lit level in the dark
state = kb.initialState(0, 2, 0)
r = kb.evaluate(state, 1, 0, cfg)
r = kb.evaluate(r.state, 1, 5 * s, cfg)
state = kb.observeBrightness(r.state, 0, 10 * s)
state = kb.resume(state, 2)
r = kb.evaluate(state, 1, 1 * min, cfg)
r = kb.evaluate(r.state, 1, 1 * min + 5 * s, cfg)
assertEqual(r.set, 0, 'restores a held manual off after a wake')
assertEqual(r.state.held, true, 'keeps holding after a wake')

// Our own changes are not mistaken for manual ones
state = kb.initialState(0, 2, 0)
r = kb.evaluate(state, 1, 0, cfg)
r = kb.evaluate(r.state, 1, 5 * s, cfg)
assertEqual(kb.observeBrightness(r.state, 2, 6 * s), r.state, 'ignores the level it set itself')
JS
