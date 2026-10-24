#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
function panelFunction(name) {
  const start = source.indexOf('  function ' + name + '(')
  assert(start >= 0, 'panel exposes ' + name)
  return source.slice(start, source.indexOf('\n  }', start) + 4)
}
const dueBody = source.match(/readonly property double resetDueMs: \{([\s\S]*?)\n  \}/)[1]
const tickBody = source.match(/interval: 30000[\s\S]*?onTriggered: ([^\n]+)/)[1]
const timerBody = source.match(/id: resetTimer\n\s+onTriggered: ([^\n]+)/)[1]
const resumeBody = source.match(/function onResumed\(\) \{ ([^\n]+) \}/)[1]
const openStart = source.indexOf('onOpenedChanged: if (opened) {')
const openBody = source.slice(openStart + 'onOpenedChanged: '.length, source.indexOf('\n  }', openStart) + 4)
const helpers = ['nextResetMs', 'resetTickDelay', 'armResetTimer', 'advanceClock'].map(panelFunction).join('\n')
const startTime = Date.parse('2026-10-11T12:00:00Z')
const firstReset = Date.parse('2026-10-11T13:30:00Z')
const secondReset = Date.parse('2026-10-14T00:00:00Z')

function panel(resets = [firstReset, secondReset]) {
  let wallClock = startTime
  let clock = wallClock
  let fetches = 0
  const timer = {
    interval: 0, running: false,
    restart() { this.running = true },
    stop() { this.running = false }
  }
  const model = {
    Date: class extends Date { static now() { return wallClock } },
    providers: [{ limits: resets.map(reset => ({ resetsAt: new Date(reset).toISOString() })) }],
    usage: { refreshLimits() { fetches++ } },
    resetTimer: timer,
    opened: true, addStage: '', panelFlick: null,
    resetKeys() {}, Qt: { callLater() {} },
    get nowMs() { return clock },
    set nowMs(value) {
      const due = this.resetDueMs
      clock = value
      // Model QML's immediate binding update: advancing nowMs can replace the
      // deadline and cancel the previous timer before its callback is handled.
      if (this.resetDueMs !== due) this.armResetTimer()
    }
  }
  model.root = model
  vm.createContext(model)
  vm.runInContext(helpers + '\nfunction dueBinding() {' + dueBody + '\n}', model)
  Object.defineProperty(model, 'resetDueMs', { get: () => model.dueBinding() })
  model.armResetTimer()
  return {
    model, timer,
    at(value) { wallClock = value },
    fire(body) { vm.runInContext(body, model) },
    get fetches() { return fetches }
  }
}

let p = panel()
p.at(firstReset + 3001)
p.fire(tickBody)
assertEqual(p.fetches, 1, 'a 30-second tick handled before an overdue reset timer still fetches that window')
assertEqual(p.model.nowMs, firstReset + 3001, 'the clock tick advances the clock read by the bar')
assertEqual(p.model.resetDueMs, secondReset + 3000, 'the tick rearms for the next actual window')
p.fire(timerBody)
assertEqual(p.fetches, 1, 'a queued reset callback after the clock tick does not fetch twice')

p = panel()
p.at(firstReset + 3000)
p.fire(timerBody)
p.fire(tickBody)
assertEqual(p.fetches, 1, 'reset timer before clock tick also fetches once at the exact deadline')

p = panel()
p.at(firstReset + 3001)
p.fire(openBody)
assertEqual(p.fetches, 1, 'opening after a deadline requests one refresh')
p = panel()
p.fire(openBody)
assertEqual(p.fetches, 1, 'opening before a deadline still fetches fresh limits once')

p = panel()
p.at(secondReset + 10000)
p.fire(resumeBody)
assertEqual(p.fetches, 1, 'resume past several resets fetches all limits once')
assertEqual(p.model.resetDueMs, 0, 'resume past the final reset leaves no pending deadline')
assertEqual(p.timer.running, false, 'resume past the final reset stops the timer')
p.fire(resumeBody)
assertEqual(p.fetches, 1, 'a repeated resume with no pending reset does not fetch')

p = panel()
p.at(firstReset + 2000)
p.fire(resumeBody)
assertEqual(p.fetches, 0, 'resume inside the provider grace period does not fetch early')
assertEqual(p.model.nowMs, firstReset + 2000, 'resume inside the grace period still updates the bar clock')
assertEqual(p.timer.interval, 1000, 'resume inside the grace period waits only the remaining second')
p.at(firstReset + 3000)
p.fire(timerBody)
assertEqual(p.fetches, 1, 'the remaining grace timer fetches at its deadline')

p = panel([startTime + 30 * 86400000])
assertEqual(p.timer.interval, 2147483647, 'a distant reset initially waits the maximum timer interval')
p.at(startTime + 2147483647)
p.timer.running = false
p.fire(timerBody)
assertEqual(p.fetches, 0, 'a capped wait does not fetch before the reset')
assertEqual(p.timer.running, true, 'a capped wait rearms even when the deadline binding stays unchanged')
assertEqual(p.timer.interval, 30 * 86400000 + 3000 - 2147483647, 'a capped wait uses its remaining wall-clock duration')

p = panel()
p.at(startTime - 10000)
p.fire(timerBody)
assertEqual(p.fetches, 0, 'a backward clock adjustment does not fetch early')
assertEqual(p.timer.interval, firstReset + 3000 - startTime + 10000, 'a backward clock adjustment rearms against the wall clock')

p = panel([])
p.at(startTime + 10000)
p.fire(tickBody)
p.fire(resumeBody)
assertEqual(p.fetches, 0, 'clock ticks and resume with no reset do not fetch')
p.fire(openBody)
assertEqual(p.fetches, 1, 'opening with no reset still fetches fresh limits')

assertEqual((source.match(/\b(?:root\.)?nowMs\s*=/g) || []).length, 1, 'all production clock updates go through the tested function')
assert(/firstPartyServiceFor\("omarchy\.idle"\)/.test(source), 'the panel subscribes to the non-authentication idle service')
assert(!/firstPartyServiceFor\("omarchy\.lock"\)/.test(source), 'resume does not depend on the authentication service')
JS
