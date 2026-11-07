#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const model = requireFromRoot('shell/plugins/lock/LockPaintModel.js')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const restart = fs.readFileSync(path.join(root, 'bin/omarchy-restart-shell'), 'utf8')

function run(events) {
  let state = model.initialState()
  let last = null
  for (const event of events) {
    const before = JSON.stringify(state)
    last = model.reduce(state, event)
    if (JSON.stringify(state) !== before) fail('reduce mutates the previous lock-paint state', before)
    state = last.state
  }
  return last
}

const issueLog = [
  'QWaylandGLContext::makeCurrent: eglError: 0x3003',
  'Could not create EGL surface (EGL error 0x3003)',
  'eglSwapBuffers failed with 0x300d, surface: 0x0',
  'omarchy lock 2026-11-07T11:47:55.000Z session-locked=true',
  'omarchy lock 2026-11-07T11:48:01.000Z secure=true'
].join('\n')

assert(model.journalShowsPresentFailure(issueLog), 'the idle-lock EGL allocation failure is a present failure')
assert(!model.journalShowsPresentFailure('omarchy lock 2026-11-07T11:48:01.000Z secure=true\nsession-locked=true'), 'a lock that only reports secure did present as far as the log says')
assert(!model.journalShowsPresentFailure(''), 'an empty shell log is not a present failure')

const begun = run([{ type: 'begin', nowMs: 1_700_000_500 }])
assertEqual(begun.state.generation, 1, 'a lock attempt starts a new paint generation')
assertEqual(begun.state.startedAtSec, 1699999, 'the log window starts one second before the lock attempt')
assertEqual(begun.settle, 'stop', 'starting a lock cancels a settle from the previous one')

const healthy = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'frame', generation: 1, surface: 1 },
  { type: 'secure', secure: true },
  { type: 'journal', generation: 1, result: 'clean' }
])
assert(healthy.state.painted && healthy.state.committed && !healthy.state.unpainted, 'a frame with a clean shell log is a painted lock')
assertEqual(healthy.settle, 'stop', 'a painted lock does not keep waiting')

const stillComingUp = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'frame', generation: 1, surface: 1 },
  { type: 'journal', generation: 1, result: 'failed' }
])
assert(!stillComingUp.state.unpainted && !stillComingUp.state.secure, 'a present failure before the session is secure is not an invisible lock yet')

const invisible = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'surface', delta: 1, generation: 1, surface: 2 },
  { type: 'frame', generation: 1, surface: 1 },
  { type: 'frame', generation: 1, surface: 2 },
  { type: 'secure', secure: true },
  { type: 'journal', generation: 1, result: 'failed' }
])
assert(invisible.state.unpainted && !invisible.state.painted, 'EGL failure overrides frameSwapped once the session is secure')
assert(invisible.queryJournal === false || invisible.state.journal === 'failed', 'a failed present stops the settle')

const lateJournal = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'frame', generation: 1, surface: 1 },
  { type: 'secure', secure: true },
  { type: 'settle', generation: 1 },
  { type: 'journal', generation: 1, result: 'failed' }
])
assert(lateJournal.state.unpainted && !lateJournal.state.painted, 'a present failure that arrives after the settle still unpaints the lock')

const hungJournal = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'frame', generation: 1, surface: 1 },
  { type: 'secure', secure: true },
  { type: 'settle', generation: 1 }
])
assert(hungJournal.state.painted && !hungJournal.state.unpainted, 'a frame stands when the shell log never answers')

const neverPresented = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'secure', secure: true },
  { type: 'journal', generation: 1, result: 'clean' },
  { type: 'settle', generation: 1 }
])
assert(neverPresented.state.unpainted && !neverPresented.state.painted, 'a secure surface that never swaps a frame is unpainted')

const sceneGraph = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'graphics-failed', generation: 1, surface: 1 },
  { type: 'frame', generation: 1, surface: 1 },
  { type: 'secure', secure: true }
])
assert(sceneGraph.state.unpainted, 'a lock surface whose scene graph failed is unpainted once secure')

const secondOutput = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'frame', generation: 1, surface: 1 },
  { type: 'secure', secure: true },
  { type: 'journal', generation: 1, result: 'clean' },
  { type: 'surface', delta: 1, generation: 1, surface: 2 },
  { type: 'graphics-failed', generation: 1, surface: 2 }
])
assert(secondOutput.state.painted && !secondOutput.state.unpainted, 'a later output failure does not unpaint a lock that already presented')

const noSurface = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'secure', secure: true },
  { type: 'journal', generation: 1, result: 'failed' }
])
assert(!noSurface.state.unpainted, 'a present failure with no lock surface is not the invisible-lock state')

const surfaceAfterSecure = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'secure', secure: true },
  { type: 'surface', delta: 1, generation: 1, surface: 1 }
])
assert(surfaceAfterSecure.queryJournal && surfaceAfterSecure.state.journal === 'pending' && !surfaceAfterSecure.state.unpainted, 'a surface that appears after the session is secure still has its present checked')

const stale = run([
  { type: 'begin', nowMs: 1_700_000_500 },
  { type: 'surface', delta: 1, generation: 1, surface: 1 },
  { type: 'begin', nowMs: 1_700_001_500 },
  { type: 'frame', generation: 1, surface: 1 },
  { type: 'journal', generation: 1, result: 'failed' },
  { type: 'surface', delta: 1, generation: 2, surface: 2 },
  { type: 'frame', generation: 2, surface: 2 },
  { type: 'secure', secure: true },
  { type: 'journal', generation: 2, result: 'clean' }
])
assertEqual(stale.state.generation, 2, 'a new lock attempt drops the previous paint generation')
assert(stale.state.painted && !stale.state.unpainted, 'a stale present failure cannot unpaint the next lock')

const clock = run([{ type: 'begin', nowMs: 500 }])
assertEqual(clock.state.startedAtSec, 0, 'a clock at the epoch does not make the log read start at a negative time')

assert(
  /import "LockPaintModel.js" as LockPaintModel/.test(serviceQml),
  'the lock service decides present failures in the shared model'
)
assert(
  /function beginLock\(\) \{[\s\S]*?applyLockPaint\(\{ type: "begin", nowMs: Date\.now\(\) \}\)/.test(serviceQml),
  'a lock attempt starts the present window before the session lock'
)
assert(
  /painted: !!root\.lockPaint\.painted,\s*unpainted: !!root\.lockPaint\.unpainted/.test(serviceQml),
  'lock status reports whether the surface presented'
)
assert(
  /function onFrameSwapped\(\) \{[\s\S]*?type: "frame"/.test(serviceQml),
  'the lock surface records a swapped frame'
)
assert(
  /function onSceneGraphError\(error, message\) \{[\s\S]*?type: "graphics-failed"/.test(serviceQml),
  'a lock surface that loses its graphics context is recorded'
)
assert(
  /journalctl", "--user", "-t", "omarchy-shell", "--since", "@" \+ sinceSec/.test(serviceQml),
  'the present check reads only this lock attempt from the shell journal'
)
assert(
  /interval = LockPaintModel\.PAINT_SETTLE_MS/.test(serviceQml),
  'the settle wait is the model\'s interval'
)
assert(
  /if \(!locked\) root\.applyLockPaint\(\{ type: "reset" \}\)/.test(serviceQml) &&
    /sessionLock\.locked = false\s*applyLockPaint\(\{ type: "reset" \}\)/.test(serviceQml),
  'ending the lock drops its present state'
)

assert(
  /if \.unpainted == true and \.painted != true and \.secure == true then "unpainted" elif \(\.secure == true or \.requested == true\) then "preserve"/.test(restart),
  'restart recovers only a secure lock that never presented, and preserves every other live lock'
)
JS
