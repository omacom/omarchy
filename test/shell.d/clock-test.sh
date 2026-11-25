#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const calendar = requireFromRoot('shell/plugins/panels/clock/Model.js')

// ---- countdown timers and stopwatches
assertEqual(calendar.parseTimerDuration('5'), 300, 'timer reads a bare number as minutes')
assertEqual(calendar.parseTimerDuration('1:30'), 90, 'timer reads minutes and seconds')
assertEqual(calendar.parseTimerDuration('1:00:00'), 3600, 'timer reads hours, minutes and seconds')
assertEqual(calendar.parseTimerDuration('90s'), 90, 'timer reads a seconds unit')
assertEqual(calendar.parseTimerDuration('1h 5m 10s'), 3910, 'timer reads combined units')
assertEqual(calendar.parseTimerDuration('1:75'), 0, 'timer rejects out-of-range seconds')
assertEqual(calendar.parseTimerDuration('0'), 0, 'timer rejects a zero duration')
assertEqual(calendar.parseTimerDuration('25h'), 0, 'timer rejects more than a day')
assertEqual(calendar.parseTimerDuration('soon'), 0, 'timer rejects text')
assertEqual(calendar.formatTimer(245), '4:05', 'timer formats minutes and seconds')
assertEqual(calendar.formatTimer(3723), '1:02:03', 'timer formats hours')
assertEqual(calendar.formatTimer(0.2), '0:01', 'countdown rounds a partial second up')
assertEqual(calendar.formatElapsed(0.9), '0:00', 'stopwatch rounds a partial second down')
assertEqual(calendar.describeTimer(5400), '1 hour 30 minutes', 'timer describes its duration in words')
assertEqual(calendar.describeTimer(61, (key, n, english) => key + ':' + n), 'clock.minutes:1 clock.seconds:1', 'timer hands each unit to the translator')
assertEqual(calendar.shortTimerLabel(90), '1m30s', 'timer labels an unnamed duration compactly')
assertEqual(calendar.shortTimerLabel(3600), '1h', 'timer labels drop empty units')
assertEqual(calendar.shortTimerLabel(0), '0s', 'timer labels show zero as seconds')
assertEqual(calendar.shortTimerLabel(3690, function(key, english) {
  return { 'clock.shortHours': '%1 t', 'clock.shortMinutes': '%1 min', 'clock.shortSeconds': '%1 s' }[key]
}), '1 t1 min30 s', 'timer labels take each unit from the translator')
assertEqual(calendar.timerRemaining({ running: true, endsAt: 15000 }, 10000), 5, 'running timer counts down to its end')
assertEqual(calendar.timerRemaining({ running: false, pausedRemaining: 7 }, 10000), 7, 'paused timer holds its remainder')
assertEqual(calendar.stopwatchElapsed({ running: true, startedAt: 1000, elapsedBefore: 10 }, 6000), 15, 'running stopwatch adds to its banked time')
assertEqual(calendar.stopwatchElapsed({ running: false, startedAt: 1000, elapsedBefore: 10 }, 6000), 10, 'paused stopwatch holds its banked time')
assertEqual(calendar.soonestTimer([
  { kind: 'timer', id: 1, running: false, pausedRemaining: 1 },
  { kind: 'timer', id: 2, running: true, endsAt: 20000 },
  { kind: 'timer', id: 3, running: true, endsAt: 15000 },
  { kind: 'stopwatch', id: 4, running: true, startedAt: 0, elapsedBefore: 0 }
], 10000).timer.id, 3, 'bar shows the running countdown closest to done')
assertEqual(calendar.soonestTimer([{ kind: 'stopwatch', id: 1, running: true }], 0), null, 'stopwatches are not countdowns')
assertEqual(calendar.barTimerLabel({ kind: 'timer', name: 'Pasta para la cena', running: false, pausedRemaining: 65 }, 0), 'Pasta para \u2026 1:05', 'bar shortens a long timer name')
assertDeepEqual(calendar.verticalTimerLines('1:00:00'), ['1', '00', '00'], 'vertical bar stacks an hour-long reading one unit per line')
assertDeepEqual(calendar.verticalTimerLines('4:05'), ['4', '05'], 'vertical bar stacks minutes over seconds')
assertDeepEqual(calendar.verticalTimerLines(''), [], 'vertical bar adds no lines without a timer')
assertEqual(calendar.barTimerLabel({ kind: 'stopwatch', name: '', running: false, elapsedBefore: 3 }, 0), '0:03', 'bar shows an unnamed stopwatch as its time')
assertEqual(calendar.parseBool('true'), true, 'settings read a string true')
assertEqual(calendar.parseBool(undefined), false, 'settings default a missing flag to off')

const restored = calendar.restoreTimers([
  { kind: 'timer', id: 1, total: 60, endsAt: 5, running: true },
  { kind: 'timer', id: 1, total: 60, endsAt: 5, running: true },
  { kind: 'stopwatch', id: 2, startedAt: 3, elapsedBefore: 4, running: false },
  { kind: 'timer', id: 3, total: -1 },
  null,
  'junk',
  { kind: 'timer', id: 4, total: 60, pausedRemaining: 30, running: false, name: '  Tea  ' }
])
assertDeepEqual(restored.map(t => t.id), [1, 2, 4], 'timer state drops malformed and duplicate records')
assertEqual(restored[2].name, 'Tea', 'timer state trims restored names')
assertDeepEqual(calendar.restoreTimers('not a list'), [], 'timer state ignores a non-list file')
JS
