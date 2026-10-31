#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const Model = requireFromRoot('shell/plugins/panels/monitor/BrightnessModel.js')

function model() {
  let state = Model.initial()
  const writes = []
  const osds = []
  const p = {
    writes, osds,
    get state() { return state },
    generation() { return Model.readGeneration(state) },
    read(raw, monitor = 'DP-1', generation = Model.readGeneration(state)) {
      state = Model.acceptRead(state, monitor, raw, generation)
    },
    request(value, osd = false) {
      state = Model.request(state, value, osd)
      p.start()
    },
    preview(value) { state = Model.request(state, value, false) },
    step() { p.request(state.percent + 5, true) },
    start() {
      const previous = state.active
      state = Model.start(state)
      if (state.active && state.active !== previous) writes.push(state.active)
    },
    complete(success, request = state.active) {
      const result = Model.finish(state, request, success)
      state = result.state
      if (result.verified !== null) osds.push(result.verified)
    },
    targets() { return writes.map(request => request.target) }
  }
  p.read('30')
  return p
}

function brightness(p, displayed, confirmed, available, description) {
  assertDeepEqual([p.state.percent, p.state.confirmed, p.state.available],
    [displayed, confirmed, available], description)
}

{
  const p = model()
  p.request(50)
  p.request(65)
  p.step()
  p.complete(false)
  p.start()
  assertDeepEqual(p.targets(), [50, 70], 'a failed earlier write preserves the latest target')
  brightness(p, 70, 30, true, 'failure preserves the latest preview and last confirmed value')
  assertEqual(p.osds.length, 0, 'an earlier failure does not verify the queued OSD')
  p.complete(true)
  brightness(p, 70, 70, true, 'the trailing successful write confirms the latest target')
  assertDeepEqual(p.osds, [70], 'the latest success retains the wheel OSD after an earlier failure')
}

{
  const p = model()
  p.step()
  assertEqual(p.osds.length, 0, 'wheel intent has no unconfirmed OSD')
  p.complete(false)
  brightness(p, 30, 30, true, 'a final failure rolls back locally')
  assertEqual(p.osds.length, 0, 'a final failure discards the pending OSD')
  p.request(40)
  p.complete(true)
  assertEqual(p.osds.length, 0, 'a later keyboard success does not inherit a failed wheel OSD')
}

{
  const p = model()
  p.step()
  p.step()
  p.step()
  assertDeepEqual(p.targets(), [35], 'wheel bursts coalesce behind the active request')
  p.complete(true)
  assertDeepEqual(p.targets(), [35], 'completion leaves the latest target available for the next start')
  p.start()
  assertDeepEqual(p.targets(), [35, 45], 'the next start promotes only the newest coalesced target')
  brightness(p, 45, 35, true, 'only the completed request becomes confirmed')
  assertEqual(p.osds.length, 0, 'an intermediate success does not verify the OSD')
  p.complete(true)
  assertDeepEqual(p.osds, [45], 'the final success verifies one OSD for the final target')
}

for (const startDuringWrite of [false, true]) {
  for (const raw of ['5', 'unavailable', '']) {
    const p = model()
    let generation = p.generation()
    p.request(50)
    if (startDuringWrite) generation = p.generation()
    p.complete(true)
    p.read(raw, 'DP-1', generation)
    brightness(p, 50, 50, true, 'a stale poll captured ' + (startDuringWrite ? 'during' : 'before') + ' a write cannot replace brightness with ' + JSON.stringify(raw))
  }
}

for (const success of [true, false]) {
  const p = model()
  p.step()
  p.step()
  const active = p.state.active
  p.read('70', 'DP-2')
  brightness(p, 70, 70, true, 'a monitor switch adopts its snapshot during an old write')
  assertEqual(p.state.epoch.monitor, 'DP-2', 'brightness and target monitor switch together')
  assertEqual(p.state.active, active, 'an old active request remains until its process ends')
  assertEqual(p.state.latest, null, 'a monitor switch discards old queued input')
  p.complete(success)
  p.start()
  brightness(p, 70, 70, true, 'old completion cannot confirm or roll back the new monitor')
  assertDeepEqual(p.targets(), [35], 'old queued input cannot become a new monitor write')
  assertEqual(p.osds.length, 0, 'old completion cannot verify its OSD on the new monitor')
  p.step()
  assertDeepEqual([p.writes.at(-1).epoch.monitor, p.writes.at(-1).target], ['DP-2', 75], 'new input uses the new monitor and brightness')
  p.complete(true)
  brightness(p, 75, 75, true, 'new monitor input completes after the old write')
}

for (const success of [true, false]) {
  for (const value of [30, 70]) {
    const p = model()
    p.step()
    p.read(String(value), 'DP-2')
    p.step()
    assertDeepEqual(p.targets(), [35], 'new monitor input waits behind the old active request')
    p.complete(success)
    p.start()
    assertDeepEqual([p.writes.at(-1).epoch.monitor, p.writes.at(-1).target], ['DP-2', value + 5], 'new monitor intent survives even when its target equals the old request')
    brightness(p, value + 5, value, true, 'old completion cannot confirm the new monitor value')
    assertEqual(p.osds.length, 0, 'old completion cannot verify the new monitor OSD')
    p.complete(true)
    assertDeepEqual(p.osds, [value + 5], 'new monitor success owns its OSD')
  }
}

{
  const p = model()
  p.preview(60)
  const previousEpoch = p.state.epoch
  p.read('70', 'DP-2')
  brightness(p, 70, 70, true, 'a monitor switch replaces a pending preview with its snapshot')
  assert(p.state.epoch !== previousEpoch, 'a monitor switch creates a new epoch')
  assertEqual(p.state.latest, null, 'switching monitors discards the pending preview')
  p.start()
  assertDeepEqual(p.targets(), [], 'a cancelled preview cannot start on the new monitor')
}

for (const success of [true, false]) {
  const p = model()
  p.step()
  p.step()
  p.complete(success)
  p.read('70', 'DP-2')
  p.start()
  brightness(p, 70, 70, true, 'switching before the next start retains the new snapshot')
  assertDeepEqual(p.targets(), [35], 'a deferred old target is discarded after a switch')
  assertEqual(p.osds.length, 0, 'a deferred old OSD is discarded after a switch')
}

for (const success of [true, false]) {
  const p = model()
  const originalEpoch = p.state.epoch
  p.step()
  p.read('70', 'DP-2')
  p.read('32', 'DP-1')
  assert(p.state.epoch !== originalEpoch, 'returning to the original monitor creates another epoch')
  p.complete(success)
  p.start()
  brightness(p, 32, 32, true, 'A-B-A focus changes reject completion from the first A epoch')
  assertDeepEqual(p.targets(), [35], 'returning to a monitor creates no unsolicited write')
  assertEqual(p.osds.length, 0, 'returning to a monitor cannot revive its old OSD')
}

for (const raw of ['unavailable', '']) {
  const p = model()
  p.step()
  p.read(raw, 'DP-2')
  p.complete(false)
  p.start()
  brightness(p, 0, 0, false, 'an unavailable new monitor cannot inherit old brightness or rollback state')
  assertEqual(p.state.latest, null, 'an unavailable new monitor has no pending request')
}

{
  const p = model()
  p.step()
  p.read('70', 'DP-2')
  p.step()
  p.complete(true)
  p.start()
  p.complete(false)
  brightness(p, 70, 70, true, 'new monitor failure rolls back to its own snapshot after an old success')
  assertEqual(p.osds.length, 0, 'new monitor failure cannot verify an old or new OSD')
}

{
  const p = model()
  p.request(50)
  p.read('unavailable')
  brightness(p, 50, 30, true, 'a same-monitor poll cannot hide an active write')
  p.complete(false)
  brightness(p, 30, 30, true, 'stale polling cannot corrupt rollback')
}

for (const startDuringPreview of [false, true]) {
  const p = model()
  let generation = p.generation()
  p.preview(60)
  if (startDuringPreview) generation = p.generation()
  p.read('unavailable', 'DP-1', generation)
  brightness(p, 60, 30, true, 'polls cannot replace a pending preview')
  assertEqual(p.generation(), -1, 'pending previews mark poll snapshots stale')
  p.start()
  assertDeepEqual(p.targets(), [60], 'starting promotes the preserved preview')
  p.preview(80)
  p.complete(true)
  p.start()
  assertDeepEqual(p.targets(), [60, 80], 'completion preserves a newer drag preview')
  assertEqual(p.state.latest, null, 'starting consumes the newest preview')
  p.complete(true)
  const epoch = p.state.epoch
  p.read('42')
  brightness(p, 42, 42, true, 'a fresh idle read updates displayed and confirmed brightness')
  assertEqual(p.state.epoch, epoch, 'a same-monitor read retains the epoch identity')
  p.read('unavailable')
  brightness(p, 0, 42, false, 'a fresh unavailable read hides brightness while retaining its confirmed value')
}

{
  const p = model()
  p.request(50)
  const completed = p.state.active
  p.request(70)
  p.complete(true)
  p.complete(true, completed)
  p.preview(80)
  p.start()
  assertDeepEqual(p.targets(), [50, 80], 'duplicate completion cannot start twice or capture an obsolete preview')
  brightness(p, 80, 50, true, 'duplicate completion cannot confirm the trailing request')
  const active = p.state.active
  const unchanged = p.state
  p.complete(false, completed)
  assertEqual(p.state, unchanged, 'a deferred failed-start completion cannot finish another active request')
  assertEqual(p.state.active, active, 'the trailing request retains its own completion identity')
  p.complete(true)
  brightness(p, 80, 80, true, 'the trailing request completes after duplicate earlier signals')
}

{
  const p = model()
  p.step()
  p.complete(false)
  brightness(p, 30, 30, true, 'a failure completion rolls back through the failure path')
  assertEqual(p.osds.length, 0, 'a failure completion cannot verify an OSD')
  p.request(60)
  const completed = p.state.active
  p.complete(true)
  p.complete(false, completed)
  brightness(p, 60, 60, true, 'a successful completion wins over a later fallback for the same request')
}

{
  const p = model()
  p.request(50)
  p.request(70)
  p.complete(false)
  p.start()
  assertDeepEqual(p.targets(), [50, 70], 'failure preserves a newer target for the next start')
  p.complete(true)
  brightness(p, 70, 70, true, 'the newest target succeeds after an earlier failure')
}

for (const success of [true, false]) {
  const p = model()
  p.request(50)
  p.request(50, true)
  p.complete(success)
  p.start()
  assertDeepEqual(p.targets(), [50], 'a same-epoch same-target intent needs no duplicate write after completion')
  brightness(p, success ? 50 : 30, success ? 50 : 30, true, 'same-target completion confirms or rolls back the burst')
  assertDeepEqual(p.osds, success ? [50] : [], 'a same-target burst verifies its OSD only on success')
}

{
  const p = model()
  for (const [value, target] of [[0, 1], [-4, 1], [101, 100], [42.4, 42], [47.6, 48], ['nope', 1]]) {
    p.request(value)
    assertEqual(p.state.percent, target, 'brightness input clamps ' + JSON.stringify(value))
    p.complete(true)
  }
  const snapshot = p.state
  p.preview(75)
  assertEqual(snapshot.latest, null, 'a new request does not mutate an earlier state snapshot')
  assertEqual(snapshot.percent, 1, 'earlier state snapshots retain their displayed brightness')
}
JS
