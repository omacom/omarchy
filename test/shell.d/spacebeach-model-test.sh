#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const modelPath = 'shell/plugins/spacebeach/SpaceBeachModel.js'
const spacebeach = requireFromRoot(modelPath)
const modelSource = fs.readFileSync(path.join(root, modelPath), 'utf8')

function window(address, appId, workspace, overrides = {}) {
  return Object.assign({
    address,
    lifecycleId: 'lifecycle-' + String(address).toLowerCase(),
    appId,
    workspace,
    monitor: 0,
    x: workspace * 100,
    y: 40,
    width: 900,
    height: 700,
    floating: false,
    fullscreen: false,
    pinned: false
  }, overrides)
}

function snapshot(capturedAt, windows, overrides = {}) {
  return Object.assign({
    capturedAt,
    reason: 'event',
    sessionId: 'hypr-session-a',
    observerId: 'observer-a',
    focusedAddress: windows.length > 0 ? windows[0].address : '',
    windows
  }, overrides)
}

const normalized = spacebeach.normalizeSnapshot({
  capturedAt: '123.9',
  reason: 'UNTRUSTED REASON',
  session: ' session-a ',
  observerId: ' observer-a ',
  activeAddress: 'ABC',
  clients: [
    {
      address: 'def',
      lifecycleId: ' lifecycle-def ',
      class: 'org.example.Editor',
      workspace: { id: '3', name: 'code' },
      monitor: { id: 1, name: 'DP-1' },
      at: [20.4, 30.6],
      size: [800.2, 599.8],
      floating: 1,
      title: 'private document title',
      command: 'rm -rf /'
    },
    { address: '0xabc', lifecycleId: 'lifecycle-abc', appId: 'Browser', workspace: 1, width: -20, height: Infinity },
    { address: '$(touch /tmp/no)', appId: 'hostile' },
    { address: '0xdef', lifecycleId: 'zzz-duplicate', appId: 'zzz-duplicate', workspace: 99 },
    null
  ]
})

assertEqual(normalized.capturedAt, 123, 'SpaceBeach floors checkpoint timestamps')
assertEqual(normalized.reason, 'capture', 'SpaceBeach constrains unknown checkpoint reasons')

assertEqual(spacebeach.canonicalWorkspaceTarget(4, ''), '4', 'SpaceBeach targets positive workspace IDs directly')
assertEqual(spacebeach.canonicalWorkspaceTarget(-2, 'Web'), 'name:Web', 'SpaceBeach prefixes raw named workspaces')
assertEqual(spacebeach.canonicalWorkspaceTarget(-2, 'name:Web'), 'name:Web', 'SpaceBeach preserves canonical named workspaces')
assertEqual(spacebeach.canonicalWorkspaceTarget(-2, 'Deep Work'), 'name:Deep Work', 'SpaceBeach supports named workspaces containing spaces')
assertEqual(spacebeach.canonicalWorkspaceTarget(-99, 'special:magic'), 'special:magic', 'SpaceBeach preserves special workspaces')
assertEqual(spacebeach.canonicalWorkspaceTarget(-99, ''), '', 'SpaceBeach refuses a negative workspace ID without a stable name')
assertEqual(spacebeach.canonicalWorkspaceTarget(-2, 'name:bad,selector'), '', 'SpaceBeach rejects dispatcher delimiters in workspace names')
assertEqual(normalized.sessionId, 'session-a', 'SpaceBeach normalizes compositor session IDs')
assertEqual(normalized.observerId, 'observer-a', 'SpaceBeach normalizes observer epoch IDs')
assertEqual(normalized.focusedAddress, '0xabc', 'SpaceBeach canonicalizes focused window addresses')
assertEqual(normalized.windows.length, 2, 'SpaceBeach drops unsafe addresses and duplicate clients')
assertDeepEqual(
  normalized.windows.map(entry => entry.address),
  ['0xabc', '0xdef'],
  'SpaceBeach orders normalized clients by stable address'
)
assertDeepEqual(
  normalized.windows[1],
  {
    address: '0xdef',
    lifecycleId: 'lifecycle-def',
    appId: 'org.example.Editor',
    workspace: 3,
    workspaceName: 'code',
    monitor: 1,
    monitorName: 'DP-1',
    x: 20,
    y: 31,
    width: 800,
    height: 600,
    floating: true,
    fullscreen: false,
    pinned: false
  },
  'SpaceBeach projects compositor clients into immutable metadata primitives'
)
assert(!('title' in normalized.windows[1]) && !('command' in normalized.windows[1]), 'SpaceBeach snapshot projection excludes private titles and commands')
assertEqual(normalized.windows[0].width, 0, 'SpaceBeach clamps invalid negative window widths')
assertEqual(normalized.windows[0].height, 0, 'SpaceBeach replaces non-finite window heights')
assertEqual(spacebeach.normalizeWindow({ address: '1', appId: 'Game', width: Symbol('bad'), fullscreen: 2 }).fullscreen, true, 'SpaceBeach safely normalizes numeric compositor state flags')

const hashBase = snapshot(100, [
  window('0xb', 'Terminal', 2),
  window('0xa', 'Browser', 1)
], { focusedAddress: '0xa' })
const hashReordered = snapshot(999, [
  Object.assign({ title: 'not retained' }, window('0xa', 'Browser', 1)),
  window('0xb', 'Terminal', 2)
], { reason: 'sample', focusedAddress: '0xa' })

assertEqual(spacebeach.snapshotHash(hashBase), spacebeach.snapshotHash(hashReordered), 'SpaceBeach hashes desktop state independently of capture time and client order')
assert(spacebeach.snapshotHash(hashBase) !== spacebeach.snapshotHash(Object.assign({}, hashBase, { focusedAddress: '0xb' })), 'SpaceBeach checkpoint hashes include real focus changes')
assert(spacebeach.snapshotHash(hashBase) !== spacebeach.snapshotHash(snapshot(100, hashBase.windows, { sessionId: 'hypr-session-b' })), 'SpaceBeach checkpoint hashes separate compositor sessions')
assert(spacebeach.snapshotHash(hashBase) !== spacebeach.snapshotHash(snapshot(100, hashBase.windows, { observerId: 'observer-b' })), 'SpaceBeach checkpoint hashes separate observer epochs')
assert(spacebeach.snapshotHash(hashBase) !== spacebeach.snapshotHash(snapshot(100, [window('0xb', 'Terminal', 2), window('0xa', 'Browser', 1, { lifecycleId: 'replacement-a' })], { focusedAddress: '0xa' })), 'SpaceBeach checkpoint hashes include observed window lifecycles')
assert(spacebeach.snapshotHash(hashBase) !== spacebeach.snapshotHash(snapshot(100, [window('0xa', 'Browser', 4), window('0xb', 'Terminal', 2)])), 'SpaceBeach checkpoint hashes include layout changes')

const checkpointOne = snapshot(100, [window('0xa', 'Browser', 1)])
const checkpointOneDuplicate = snapshot(150, [window('0xa', 'Browser', 1)], { reason: 'sample' })
const checkpointTwo = snapshot(200, [window('0xa', 'Browser', 2)])
const checkpointThree = snapshot(300, [window('0xa', 'Browser', 3)])
let journal = spacebeach.appendSnapshot([], checkpointOne, { limit: 2 })
journal = spacebeach.appendSnapshot(journal, checkpointOneDuplicate, { limit: 2 })
assertEqual(journal.length, 1, 'SpaceBeach coalesces consecutive identical checkpoints')
journal = spacebeach.appendSnapshot(journal, checkpointTwo, { limit: 2 })
journal = spacebeach.appendSnapshot(journal, checkpointThree, { limit: 2 })
assertDeepEqual(journal.map(entry => entry.capturedAt), [200, 300], 'SpaceBeach keeps the newest checkpoints within its hard limit')
assert(journal.every(entry => entry.hash === spacebeach.snapshotHash(entry)), 'SpaceBeach recalculates trusted hashes for journal entries')

const cutoffJournal = spacebeach.appendSnapshot([checkpointOne, checkpointTwo], checkpointThree, { limit: 10, cutoff: 150 })
assertDeepEqual(cutoffJournal.map(entry => entry.capturedAt), [200, 300], 'SpaceBeach removes checkpoints older than the supplied retention cutoff')
assertDeepEqual(spacebeach.appendSnapshot(cutoffJournal, checkpointOne, { limit: 10 }), cutoffJournal, 'SpaceBeach refuses out-of-order checkpoint appends')
assertDeepEqual(spacebeach.appendSnapshot(cutoffJournal, { capturedAt: 400, windows: 'corrupt' }, { limit: 10 }), cutoffJournal, 'SpaceBeach ignores corrupt checkpoint appends')
assertDeepEqual(spacebeach.appendSnapshot(cutoffJournal, checkpointThree, { limit: 0 }), [], 'SpaceBeach supports disabling history with a zero limit')
assertDeepEqual(
  spacebeach.normalizeJournal([{ nope: true }, checkpointThree, checkpointOne, checkpointTwo], { limit: 10 }).map(entry => entry.capturedAt),
  [100, 200, 300],
  'SpaceBeach sanitizes and orders a partially corrupt journal'
)
assertDeepEqual(spacebeach.normalizeJournal('not an array', { limit: 10 }), [], 'SpaceBeach rejects corrupt journal roots')

const before = snapshot(1000, [
  window('0x1', 'Browser', 1),
  window('0x2', 'Terminal', 2),
  window('0x4', 'Music', 4)
], { focusedAddress: '0x1' })
const after = snapshot(1100, [
  window('0x1', 'Browser', 3, { x: 800 }),
  window('0x2', 'Terminal', 2, { floating: true }),
  window('0x3', 'Editor', 5)
], { focusedAddress: '0x3' })
const desktopDiff = spacebeach.diffSnapshots(before, after)

assertDeepEqual(desktopDiff.added.map(entry => entry.address), ['0x3'], 'SpaceBeach diff reports windows that really arrived')
assertDeepEqual(desktopDiff.removed.map(entry => entry.address), ['0x4'], 'SpaceBeach diff reports windows that really disappeared')
assertDeepEqual(desktopDiff.moved.map(entry => entry.address), ['0x1'], 'SpaceBeach diff reports real layout transitions')
assertDeepEqual(desktopDiff.stateChanged.map(entry => entry.address), ['0x2'], 'SpaceBeach diff reports real window state transitions')
assertEqual(desktopDiff.focusChanged, true, 'SpaceBeach diff reports focus transitions')
assertEqual(desktopDiff.sameSession, true, 'SpaceBeach diff labels same-session address comparisons')

const restartedDiff = spacebeach.diffSnapshots(before, snapshot(1200, before.windows, { sessionId: 'hypr-session-b' }))
assertEqual(restartedDiff.sameSession, false, 'SpaceBeach detects compositor-session boundaries')
assertEqual(restartedDiff.added.length, 3, 'SpaceBeach treats reused addresses after restart as new windows')
assertEqual(restartedDiff.removed.length, 3, 'SpaceBeach never claims stale addresses survived a restart')

const fidelityTarget = snapshot(2000, [
  window('0x10', 'Browser', 1),
  window('0x11', 'Terminal', 1),
  window('0x12', 'Terminal', 9),
  window('0x13', 'Music', 3),
  window('0x14', 'Orphan', 4)
])
const fidelityCurrent = snapshot(2100, [
  window('0x10', 'Browser', 2),
  window('0x21', 'Terminal', 8),
  window('0x22', 'Terminal', 1),
  window('0x99', 'Notes', 7)
])
const matches = spacebeach.matchWindows(fidelityTarget, fidelityCurrent, ['Music'])

assertDeepEqual(
  matches.map(match => match.fidelity),
  ['exact', 'layout-only', 'layout-only', 'launch-only', 'lost'],
  'SpaceBeach reports honest exact, layout-only, launch-only, and lost fidelity'
)
assertEqual(matches[1].current.address, '0x22', 'SpaceBeach pairs replacement windows to the nearest matching layout')
assertEqual(matches[2].current.address, '0x21', 'SpaceBeach uses each live replacement window at most once')
assert(matches[0].safeExact && matches.slice(1).every(match => !match.safeExact), 'SpaceBeach reserves safeExact for proven same-session identities')
assertEqual(matches[0].current.lifecycleId, 'lifecycle-0x10', 'SpaceBeach exact fidelity retains the observed lifecycle token')

const restartedMatches = spacebeach.matchWindows(fidelityTarget, snapshot(2200, fidelityCurrent.windows, { sessionId: 'hypr-session-b' }), ['Music'])
assertEqual(restartedMatches[0].fidelity, 'layout-only', 'SpaceBeach downgrades an address match across compositor sessions')
assertEqual(
  spacebeach.classifyFidelity(window('0xaa', 'Browser', 1), [window('0xaa', 'Browser', 1)], [], {}).fidelity,
  'layout-only',
  'SpaceBeach single-window fidelity refuses exact claims without session IDs'
)

const recycledTarget = snapshot(2300, [window('0x70', 'Browser', 1, { lifecycleId: 'browser-before-close' })])
const recycledCurrent = snapshot(2400, [window('0x70', 'Browser', 9, { lifecycleId: 'browser-after-reopen' })])
const recycledMatch = spacebeach.matchWindows(recycledTarget, recycledCurrent)[0]
const recycledDiff = spacebeach.diffSnapshots(recycledTarget, recycledCurrent)
const recycledPlan = spacebeach.buildRestorePlan(recycledTarget, recycledCurrent)
assertEqual(recycledMatch.fidelity, 'layout-only', 'SpaceBeach rejects a recycled same-address same-app window as exact')
assertEqual(recycledMatch.safeExact, false, 'SpaceBeach marks lifecycle-token mismatches as non-executable')
assertDeepEqual(recycledDiff.removed.map(entry => entry.lifecycleId), ['browser-before-close'], 'SpaceBeach diff records the prior recycled lifecycle as removed')
assertDeepEqual(recycledDiff.added.map(entry => entry.lifecycleId), ['browser-after-reopen'], 'SpaceBeach diff records the replacement lifecycle as added')
assertEqual(recycledPlan.moves.length, 0, 'SpaceBeach never builds a move for a recycled address')
assertEqual(recycledPlan.suggestions[0].fidelity, 'layout-only', 'SpaceBeach keeps a recycled address available only as an inert layout suggestion')

const observerRestartTarget = snapshot(2500, [window('0x71', 'Terminal', 1)])
const observerRestartCurrent = snapshot(2600, [window('0x71', 'Terminal', 7)], { observerId: 'observer-b' })
const observerRestartDiff = spacebeach.diffSnapshots(observerRestartTarget, observerRestartCurrent)
const observerRestartPlan = spacebeach.buildRestorePlan(observerRestartTarget, observerRestartCurrent)
assertEqual(observerRestartDiff.sameCompositorSession, true, 'SpaceBeach distinguishes an observer restart from a compositor restart')
assertEqual(observerRestartDiff.sameSession, false, 'SpaceBeach denies identity continuity after an observer restart')
assertEqual(observerRestartDiff.removed.length, 1, 'SpaceBeach treats pre-restart observations as ended lifecycles')
assertEqual(observerRestartDiff.added.length, 1, 'SpaceBeach treats post-restart observations as new lifecycles')
assertEqual(spacebeach.matchWindows(observerRestartTarget, observerRestartCurrent)[0].fidelity, 'layout-only', 'SpaceBeach downgrades same-address matches across observer epochs')
assertEqual(observerRestartPlan.moves.length, 0, 'SpaceBeach never restores through a stale observer epoch')
assertEqual(observerRestartPlan.sameSession, false, 'SpaceBeach marks observer-crossing restore plans unsafe')

const unknownTarget = snapshot(2700, [window('0x72', 'unknown', 1)])
const unknownCurrent = snapshot(2800, [window('0x72', 'unknown', 8)])
const unknownDiff = spacebeach.diffSnapshots(unknownTarget, unknownCurrent)
const unknownPlan = spacebeach.buildRestorePlan(unknownTarget, unknownCurrent, ['unknown'])
assertEqual(spacebeach.matchWindows(unknownTarget, unknownCurrent, ['unknown'])[0].fidelity, 'lost', 'SpaceBeach never grants exact or launch fidelity to an unknown app ID')
assertEqual(unknownDiff.moved.length, 0, 'SpaceBeach does not interpret unknown-app address reuse as a move')
assertEqual(unknownDiff.removed.length, 1, 'SpaceBeach ends the prior unknown-app identity in diffs')
assertEqual(unknownDiff.added.length, 1, 'SpaceBeach begins a new unknown-app identity in diffs')
assertEqual(unknownPlan.moves.length, 0, 'SpaceBeach never emits an executable move for an unknown app ID')
assertEqual(unknownPlan.unresolved[0].fidelity, 'lost', 'SpaceBeach leaves unknown app IDs explicitly unrecoverable')

const legacyLifecycleTarget = snapshot(2810, [window('0x73', 'Files', 1, { lifecycleId: '' })])
const legacyLifecycleCurrent = snapshot(2820, [window('0x73', 'Files', 5)])
const legacyObserverTarget = snapshot(2830, [window('0x74', 'Mail', 1)], { observerId: '' })
const legacyObserverCurrent = snapshot(2840, [window('0x74', 'Mail', 5)])
assertEqual(spacebeach.matchWindows(legacyLifecycleTarget, legacyLifecycleCurrent)[0].fidelity, 'layout-only', 'SpaceBeach keeps old lifecycle-less records view-only')
assertEqual(spacebeach.buildRestorePlan(legacyLifecycleTarget, legacyLifecycleCurrent).moves.length, 0, 'SpaceBeach never executes a lifecycle-less legacy record')
assertEqual(spacebeach.matchWindows(legacyObserverTarget, legacyObserverCurrent)[0].fidelity, 'layout-only', 'SpaceBeach keeps old observer-less records view-only')
assertEqual(spacebeach.buildRestorePlan(legacyObserverTarget, legacyObserverCurrent).moves.length, 0, 'SpaceBeach never executes an observer-less legacy record')

const restoreTarget = snapshot(3000, [
  window('0x1', 'Browser', 1),
  window('0x2', 'Code', 2),
  window('0x3', 'Terminal', 3),
  window('0x4', 'Music', 4),
  window('0x5', 'Orphan', 5)
])
const restoreCurrent = snapshot(3100, [
  window('0x1', 'Browser', 9),
  window('0x2', 'Code', 2),
  window('0x33', 'Terminal', 8),
  window('0x99', 'Notes', 9)
])
const restorePlan = spacebeach.buildRestorePlan(restoreTarget, restoreCurrent, ['Music'])

assertEqual(restorePlan.moves.length, 1, 'SpaceBeach restore plans move only changed exact windows')
assertEqual(restorePlan.moves[0].address, '0x1', 'SpaceBeach restore move targets the proven live address')
assertEqual(restorePlan.sessionId, 'hypr-session-a', 'SpaceBeach restore plans bind to the current compositor session')
assertEqual(restorePlan.observerId, 'observer-a', 'SpaceBeach restore plans bind to the current observer epoch')
assertEqual(restorePlan.moves[0].lifecycleId, 'lifecycle-0x1', 'SpaceBeach restore moves bind to the current live lifecycle token')
assertDeepEqual(restorePlan.unchanged, [{ address: '0x2', lifecycleId: 'lifecycle-0x2', appId: 'Code', fidelity: 'exact' }], 'SpaceBeach restore plans leave exact windows already in place alone')
assertEqual(restorePlan.suggestions.length, 2, 'SpaceBeach exposes both unhandled tiled geometry and replacement-window layout matches as manual suggestions')
assertDeepEqual(restorePlan.moves[0].fields, ['workspace'], 'SpaceBeach restore moves contain only dispatcher-executable fields')
assertEqual(restorePlan.suggestions[0].executable, false, 'SpaceBeach layout-only suggestions are inert')
assertDeepEqual(restorePlan.unresolved.map(entry => entry.fidelity), ['launch-only', 'lost'], 'SpaceBeach leaves relaunch and unrecoverable windows unresolved')
assertDeepEqual(restorePlan.ignoredExtraWindows.map(entry => entry.address), ['0x99'], 'SpaceBeach explicitly preserves unrelated live windows')
assertDeepEqual(
  restorePlan.policy,
  {
    closeExtraWindows: false,
    launchApplications: false,
    executeCommands: false,
    exactMatchesOnly: true
  },
  'SpaceBeach restore plan encodes its non-destructive policy'
)

function dangerousRestoreInstruction(value) {
  if (!value || typeof value !== 'object') return false
  for (const key of Object.keys(value)) {
    if (['command', 'argv', 'shell', 'exec'].includes(key.toLowerCase())) return true
    if (key === 'kind' && /close|kill|launch|exec/i.test(String(value[key]))) return true
    if (dangerousRestoreInstruction(value[key])) return true
  }
  return false
}

assert(!dangerousRestoreInstruction(restorePlan), 'SpaceBeach restore plans contain no close, launch, shell, or command instruction')
assert(restorePlan.requiresConfirmation, 'SpaceBeach restore plans require confirmation before an exact move')

const tiledGeometryPlan = spacebeach.buildRestorePlan(
  snapshot(3200, [window('0x6', 'Files', 2, { x: 900 })]),
  snapshot(3300, [window('0x6', 'Files', 2, { x: 200 })])
)
assertEqual(tiledGeometryPlan.moves.length, 0, 'SpaceBeach does not claim tiled geometry as an executable restore move')
assertDeepEqual(tiledGeometryPlan.suggestions[0].fields, ['x'], 'SpaceBeach discloses tiled geometry as layout-only')

const monitorOnlyPlan = spacebeach.buildRestorePlan(
  snapshot(3400, [window('0x7', 'Chat', 2, { monitor: 1, monitorName: 'DP-2' })]),
  snapshot(3500, [window('0x7', 'Chat', 2, { monitor: 0, monitorName: 'DP-1' })])
)
assertEqual(monitorOnlyPlan.moves.length, 0, 'SpaceBeach does not claim monitor placement it cannot dispatch exactly')
assertDeepEqual(monitorOnlyPlan.suggestions[0].fields, ['monitor', 'monitorName'], 'SpaceBeach exposes monitor placement as layout-only')

const floatingGeometryPlan = spacebeach.buildRestorePlan(
  snapshot(3600, [window('0x8', 'Image', 2, { floating: true, x: 700, width: 1100 })]),
  snapshot(3700, [window('0x8', 'Image', 2, { floating: true, x: 200, width: 800 })])
)
assertEqual(floatingGeometryPlan.moves.length, 1, 'SpaceBeach can restore geometry for a window that is floating in both states')
assertDeepEqual(floatingGeometryPlan.moves[0].fields, ['x', 'width'], 'SpaceBeach whitelists only executable floating geometry fields')

const stateOnlyPlan = spacebeach.buildRestorePlan(
  snapshot(3800, [window('0x9', 'Video', 2, { fullscreen: true })]),
  snapshot(3900, [window('0x9', 'Video', 2, { fullscreen: false })])
)
assertEqual(stateOnlyPlan.moves.length, 0, 'SpaceBeach does not claim fullscreen state as restored')
assertDeepEqual(stateOnlyPlan.suggestions[0].fields, ['fullscreen'], 'SpaceBeach discloses unsupported state restoration explicitly')

const tideOne = snapshot(4000, [
  window('0xa', 'Browser', 1),
  window('0xb', 'Terminal', 2)
], { focusedAddress: '0xa' })
const tideTwo = snapshot(4100, [
  window('0xa', 'Browser', 3, { x: 700 }),
  window('0xc', 'Editor', 4)
], { focusedAddress: '0xc' })
const tideThree = snapshot(4200, [
  window('0xa', 'Browser', 3, { x: 700 }),
  window('0xc', 'Editor', 4, { floating: true })
], { focusedAddress: '0xa' })
const tideJournal = [tideOne, tideTwo, tideThree]
const run = spacebeach.deriveTideRun(tideJournal)
const repeatedRun = spacebeach.deriveTideRun(tideJournal)

assertEqual(run.valid, true, 'SpaceBeach derives a playable Tide Run from recorded transitions')
assertEqual(run.synthetic, false, 'SpaceBeach marks Tide Runs as non-synthetic')
assertEqual(run.sourceKind, 'recorded-journal', 'SpaceBeach identifies the journal as the only Tide Run source')
assertDeepEqual(run, repeatedRun, 'SpaceBeach derives byte-for-byte deterministic Tide Runs')
assertEqual(run.waves.length, 2, 'SpaceBeach creates exactly one wave per changed recorded transition')
assertDeepEqual(
  run.waves[0].events.map(event => event.kind),
  ['undertow', 'crosscurrent', 'arrival', 'beacon'],
  'SpaceBeach translates real close, move, open, and focus transitions into the first wave'
)
assertDeepEqual(
  run.waves[1].events.map(event => event.kind),
  ['squall', 'beacon'],
  'SpaceBeach translates real state and focus transitions into the next wave'
)
assertEqual(run.waves[0].fromHash, spacebeach.snapshotHash(tideOne), 'SpaceBeach waves retain their source checkpoint hash')
assertEqual(run.waves[0].toHash, spacebeach.snapshotHash(tideTwo), 'SpaceBeach waves retain their destination checkpoint hash')
assertEqual(run.source.transitionCount, run.waves.length, 'SpaceBeach source provenance counts only recorded waves')
assert(!/Math\.random|Date\.now|new Date/.test(modelSource), 'SpaceBeach game model uses no random or wall-clock synthetic input')

const invalidRun = spacebeach.deriveTideRun([tideOne])
assertEqual(invalidRun.valid, false, 'SpaceBeach refuses to invent a Tide Run without enough history')
assertEqual(invalidRun.synthetic, false, 'SpaceBeach invalid runs still promise no synthetic fallback')
assert(invalidRun.error.includes('two changed'), 'SpaceBeach explains when real history is insufficient')
assertEqual(spacebeach.deriveTideRun('corrupt').valid, false, 'SpaceBeach rejects a corrupt Tide Run journal')
assertEqual(spacebeach.deriveTideRun([{ bad: true }, tideOne]).valid, false, 'SpaceBeach ignores corrupt records without fabricating replacement waves')

const emptyOriginRun = spacebeach.deriveTideRun([
  snapshot(4300, []),
  snapshot(4400, [window('0xd', 'Mail', 5)])
])
assertEqual(emptyOriginRun.valid, true, 'SpaceBeach accepts a real arrival wave from an empty starting desktop')
assertEqual(emptyOriginRun.vessels.length, 0, 'SpaceBeach does not fabricate an origin vessel for an empty desktop')
const arrivedFromEmpty = spacebeach.advanceTideRun(emptyOriginRun)
assertEqual(arrivedFromEmpty.vessels.length, 1, 'SpaceBeach can play an arrival wave before a fleet exists')
assertEqual(arrivedFromEmpty.vessels[0].appId, 'Mail', 'SpaceBeach creates the arriving vessel from recorded metadata')

const observationGapRun = spacebeach.deriveTideRun([
  snapshot(4450, [window('0xe', 'Docs', 1)], { observerId: 'observer-before-gap' }),
  snapshot(4500, [window('0xf', 'Mail', 2)], { observerId: 'observer-after-gap' })
])
assertEqual(observationGapRun.valid, false, 'SpaceBeach refuses to invent close or arrival waves across an observation gap')

const postGapOrigin = snapshot(4550, [
  window('0xf', 'Mail', 2)
], { observerId: 'observer-after-gap' })
const postGapDestination = snapshot(4600, [
  window('0xf', 'Mail', 3),
  window('0x10', 'Terminal', 4)
], { observerId: 'observer-after-gap' })
const postGapRun = spacebeach.deriveTideRun([
  snapshot(4450, [window('0xe', 'Docs', 1)], { observerId: 'observer-before-gap' }),
  postGapOrigin,
  postGapDestination
])
const isolatedPostGapRun = spacebeach.deriveTideRun([postGapOrigin, postGapDestination])
assertEqual(postGapRun.valid, true, 'SpaceBeach can play a real transition after an observation gap')
assertEqual(postGapRun.source.firstHash, spacebeach.snapshotHash(postGapOrigin), 'SpaceBeach anchors a resumed run after the unobserved interval')
assertEqual(postGapRun.source.checkpointCount, 2, 'SpaceBeach provenance excludes checkpoints across an observation gap')
assertDeepEqual(postGapRun.vessels, isolatedPostGapRun.vessels, 'SpaceBeach builds the resumed fleet from its actual post-gap origin')
assertEqual(postGapRun.seed, isolatedPostGapRun.seed, 'SpaceBeach excludes an unplayed observation gap from the run seed')

const recycledGameRun = spacebeach.deriveTideRun([
  snapshot(4700, [window('0x11', 'Browser', 1, { lifecycleId: 'browser-before-reuse' })]),
  snapshot(4800, [window('0x11', 'Browser', 1, { lifecycleId: 'browser-after-reuse' })])
])
assertEqual(recycledGameRun.valid, true, 'SpaceBeach can represent a real close and arrival at a recycled address')
assertEqual(recycledGameRun.waves[0].events[0].kind, 'undertow', 'SpaceBeach sends the old recycled lifecycle into undertow')
assertEqual(recycledGameRun.waves[0].events[1].kind, 'arrival', 'SpaceBeach charts the replacement lifecycle as an arrival')
assert(recycledGameRun.waves[0].events[0].vesselId !== recycledGameRun.waves[0].events[1].vesselId, 'SpaceBeach gives recycled lifecycles distinct game identities')
const resolvedRecycledGame = spacebeach.advanceTideRun(recycledGameRun)
assertEqual(resolvedRecycledGame.vessels.length, 2, 'SpaceBeach never folds a replacement lifecycle into the old game vessel')
assertEqual(resolvedRecycledGame.vessels[0].alive, false, 'SpaceBeach resolves undertow against the old lifecycle only')
assertEqual(resolvedRecycledGame.vessels[1].alive, true, 'SpaceBeach keeps the replacement lifecycle independently alive')

function runVesselId(sourceRun, address) {
  const vessel = sourceRun.vessels.find(candidate => candidate.address === address)
  return vessel ? vessel.id : ''
}

const browserVesselId = runVesselId(run, '0xa')
const terminalVesselId = runVesselId(run, '0xb')

let anchored = spacebeach.applyIntervention(run, 'anchor', terminalVesselId)
assertEqual(anchored.pendingIntervention.kind, 'anchor', 'SpaceBeach can anchor a selected live vessel')
anchored = spacebeach.advanceTideRun(anchored)
assertEqual(anchored.status, 'running', 'SpaceBeach advances one recorded wave at a time')
assertEqual(anchored.turn, 1, 'SpaceBeach advances the deterministic wave cursor')
assertEqual(anchored.charge, 1, 'SpaceBeach spends the anchor charge when its wave resolves')
assertEqual(anchored.score, 43, 'SpaceBeach scores the anchored recorded wave deterministically')
assertEqual(anchored.vessels.find(vessel => vessel.address === '0xb').integrity, 2, 'SpaceBeach anchor converts an undertow into survivable damage')
assertEqual(anchored.vessels.find(vessel => vessel.address === '0xa').integrity, 1, 'SpaceBeach applies unprotected recorded crosscurrents')
assertEqual(anchored.vessels.find(vessel => vessel.address === '0xc').origin, false, 'SpaceBeach arrivals remain traceable as journal-born vessels')

let scanned = spacebeach.applyIntervention(anchored, 'scan')
assertEqual(scanned.pendingIntervention.kind, 'scan', 'SpaceBeach can scan the next recorded wave')
scanned = spacebeach.advanceTideRun(scanned)
assertEqual(scanned.status, 'complete', 'SpaceBeach completes after the last recorded wave')
assertEqual(scanned.charge, 0, 'SpaceBeach spends scan charge only when the wave resolves')
assertEqual(scanned.score, 106, 'SpaceBeach final scoring is deterministic and rewards surviving vessels')
assertEqual(scanned.outcome, 'held-the-line', 'SpaceBeach reports the deterministic fleet outcome')
assertEqual(scanned.history.length, 2, 'SpaceBeach retains one auditable resolution row per played wave')

let drifted = spacebeach.applyIntervention(run, 'drift', browserVesselId)
drifted = spacebeach.advanceTideRun(drifted)
assertEqual(drifted.vessels.find(vessel => vessel.address === '0xa').integrity, 3, 'SpaceBeach drift evades the selected vessel damage')
assertEqual(drifted.vessels.find(vessel => vessel.address === '0xa').workspace, 1, 'SpaceBeach drift avoids the selected crosscurrent movement')
assertEqual(drifted.vessels.find(vessel => vessel.address === '0xb').alive, false, 'SpaceBeach leaves unprotected vessels exposed to recorded undertow')

let repairRun = spacebeach.advanceTideRun(run)
assertEqual(repairRun.vessels.find(vessel => vessel.address === '0xa').integrity, 1, 'SpaceBeach can carry real unprotected damage into the next wave')
assertEqual(repairRun.charge, 2, 'SpaceBeach preserves charge when a wave is met without an intervention')
repairRun = spacebeach.applyIntervention(repairRun, 'repair', browserVesselId)
assertEqual(repairRun.pendingIntervention.kind, 'repair', 'SpaceBeach can commit Repair for a damaged vessel')
repairRun = spacebeach.advanceTideRun(repairRun)
assertEqual(repairRun.vessels.find(vessel => vessel.address === '0xa').integrity, 2, 'SpaceBeach Repair restores one integrity before the next wave resolves')
assertEqual(repairRun.charge, 0, 'SpaceBeach spends Repair charge only when its wave resolves')

const invalidIntervention = spacebeach.applyIntervention(run, 'teleport', browserVesselId)
assertEqual(invalidIntervention.pendingIntervention, null, 'SpaceBeach rejects invented interventions')
assertEqual(invalidIntervention.charge, run.charge, 'SpaceBeach rejected interventions spend no charge')
assertEqual(spacebeach.applyIntervention(run, 'repair', browserVesselId).pendingIntervention, null, 'SpaceBeach does not spend repair on an undamaged vessel')
assertEqual(spacebeach.applyIntervention(run, 'anchor', 'not-a-vessel').pendingIntervention, null, 'SpaceBeach rejects unknown vessel identities')
assertEqual(spacebeach.applyIntervention({ corrupt: true }, 'anchor', browserVesselId).valid, false, 'SpaceBeach rejects corrupt game state without throwing')
assertEqual(spacebeach.advanceTideRun({ corrupt: true }).valid, false, 'SpaceBeach refuses to advance corrupt game state')
assertEqual(spacebeach.advanceTideRun(Object.assign({}, run, { waves: [{}] })).valid, false, 'SpaceBeach rejects structurally corrupt waves without throwing')

const committedAnchor = spacebeach.applyIntervention(run, 'anchor', browserVesselId)
const replacementScan = spacebeach.applyIntervention(committedAnchor, 'scan')
assertEqual(replacementScan.pendingIntervention.kind, 'anchor', 'SpaceBeach does not silently replace a committed intervention')
assert(replacementScan.lastError.includes('already committed'), 'SpaceBeach explains how to resolve a locked intervention')
const revealedScan = spacebeach.applyIntervention(run, 'scan')
assertEqual(revealedScan.revealedThrough, 1, 'SpaceBeach scan reveals the following recorded wave')
const cancelledScan = spacebeach.applyIntervention(revealedScan, 'none')
assertEqual(cancelledScan.pendingIntervention, null, 'SpaceBeach can cancel a committed intervention before resolution')
assertEqual(cancelledScan.revealedThrough, 0, 'SpaceBeach withdraws unpaid scan intel when scan is cancelled')

const oneWaveRun = spacebeach.deriveTideRun(tideJournal, { waveLimit: 1 })
assertEqual(oneWaveRun.waves.length, 1, 'SpaceBeach can bound a Tide Run to the newest real transition')
assertEqual(oneWaveRun.waves[0].fromHash, spacebeach.snapshotHash(tideTwo), 'SpaceBeach bounded runs remain anchored to actual adjacent checkpoints')
JS
