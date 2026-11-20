#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const reach = requireFromRoot('shell/plugins/panels/reach/Model.js')

const status = JSON.stringify({
  running: true,
  me: 'desk',
  screens: ['laptop', 'desk'],
  connected: ['laptop'],
  circle: {
    up: true,
    peers: [
      { name: 'mini', online: false, nearby: false },
      { name: 'laptop', online: true, nearby: true },
      { name: 'spark', online: true, nearby: true },
      { name: 'far', online: true, nearby: false },
      { name: '' },
    ],
  },
})
const s = reach.parseStatus(status)
assertEqual(s.ok, true, 'reach parses its status file')
assertEqual(s.me, 'desk', 'reach reads this machine')
assertDeepEqual(s.screens, ['laptop', 'desk'], 'reach reads the row')
assertDeepEqual(s.connected, ['laptop'], 'reach reads who is connected')
assertEqual(s.circleUp, true, 'reach reads whether Circle is up')
const peers = s.peers
assertDeepEqual(peers.map((p) => p.name), ['mini', 'laptop', 'spark', 'far'], 'reach reads the Circle machines')
assertEqual(reach.nearbyCount(peers), 2, 'reach counts the machines close by')
for (const raw of ['', 'nope', 'null', '[]', JSON.stringify({ screens: ['a'] })]) {
  assertEqual(reach.parseStatus(raw).ok, false, `reach rejects status ${JSON.stringify(raw)}`)
}
assertEqual(reach.parseStatus(JSON.stringify({ me: 'desk' })).circleUp, false, 'reach treats a missing Circle as down')

assertDeepEqual(
  reach.tiles(['laptop', 'desk', 'gone'], 'desk', peers, ['laptop']),
  [
    { name: 'laptop', self: false, online: true, connected: true },
    { name: 'desk', self: true, online: true, connected: true },
    { name: 'gone', self: false, online: null, connected: false },
  ],
  'reach builds one tile per machine in the row'
)
assertDeepEqual(reach.tiles([], 'desk', peers), [{ name: 'desk', self: true, online: true, connected: true }], 'reach shows this machine alone without a row')
assertDeepEqual(reach.tiles(['a', 'b'], 'desk', peers).map((t) => t.name), ['desk'], 'reach ignores a row without this machine')

assertDeepEqual(
  reach.addable(['laptop', 'desk'], 'desk', peers).map((p) => p.name),
  ['spark', 'far', 'mini'],
  'reach offers the Circle machines not in the row, close by first, then online'
)

assertDeepEqual(reach.place([], 'desk', 'laptop', 'left'), ['laptop', 'desk'], 'reach starts a row')
assertDeepEqual(reach.place(['laptop', 'desk'], 'desk', 'mini', 'right'), ['laptop', 'desk', 'mini'], 'reach adds on the right')
assertDeepEqual(reach.place(['laptop', 'desk'], 'desk', 'mini', 'left'), ['mini', 'laptop', 'desk'], 'reach adds on the left')
assertDeepEqual(reach.place(['laptop', 'desk', 'mini'], 'desk', 'laptop', 'right'), ['desk', 'mini', 'laptop'], 'reach moves rather than duplicates')

assertDeepEqual(reach.nudge(['a', 'desk', 'b'], 'desk', 'desk', 1), ['a', 'b', 'desk'], 'reach nudges right')
assertDeepEqual(reach.nudge(['a', 'desk', 'b'], 'desk', 'desk', -1), ['desk', 'a', 'b'], 'reach nudges left')
assertDeepEqual(reach.nudge(['a', 'desk'], 'desk', 'a', -1), ['a', 'desk'], 'reach keeps a nudge at the edge in place')

assertDeepEqual(reach.moveTo(['a', 'desk', 'b'], 'desk', 'b', 0), ['b', 'a', 'desk'], 'reach drops a tile at an index')
assertDeepEqual(reach.moveTo(['a', 'desk'], 'desk', 'a', 9), ['desk', 'a'], 'reach clamps a drop index')

assertDeepEqual(reach.remove(['a', 'desk', 'b'], 'desk', 'b'), ['a', 'desk'], 'reach takes a machine out')
assertDeepEqual(reach.remove(['a', 'desk'], 'desk', 'a'), [], 'reach clears a row of one')
assertDeepEqual(reach.remove(['a', 'desk'], 'desk', 'desk'), ['a', 'desk'], 'reach keeps this machine in its own row')

assertEqual(reach.dropIndex([10, 30, 50], 0, 40), 1, 'reach drops between the tiles it passed')
assertEqual(reach.dropIndex([10, 30, 50], 0, 60), 2, 'reach drops past the last tile')
assertEqual(reach.dropIndex([10, 30, 50], 2, 0), 0, 'reach drops before the first tile')
assertEqual(reach.dropIndex([10, 30, 50], 1, 31), 1, 'reach keeps a tile that barely moved')

assertDeepEqual(
  reach.tiles(['desk.local', 'laptop', 'desk'], 'desk', peers, []).map((t) => t.name),
  ['desk', 'laptop'],
  'reach keeps one tile when this machine is listed under its domain name'
)
assertDeepEqual(
  reach.tiles(['laptop.local', 'laptop', 'desk'], 'desk', peers, ['laptop.local']).map((t) => ({ name: t.name, connected: t.connected })),
  [
    { name: 'laptop.local', connected: true },
    { name: 'desk', connected: true },
  ],
  'reach keeps one tile when another machine is listed twice'
)

const withSelf = reach.parseStatus(JSON.stringify({
  me: 'desk',
  screens: ['desk'],
  circle: { up: true, peers: [{ name: 'desk.lan', online: true, nearby: true }, { name: 'spark', online: true, nearby: true }] },
}))
assertDeepEqual(withSelf.peers.map((p) => p.name), ['spark'], 'reach does not list this machine as one of the others')
assertEqual(reach.nearbyCount(withSelf.peers, 'desk'), 1, 'reach does not count this machine as close by')
assertEqual(reach.nearbyCount([{ name: 'desk', nearby: true }, { name: 'spark', nearby: true }], 'desk'), 1, 'reach skips this machine in a raw peer list')

assertDeepEqual(reach.nudge(['a', 'desk', 'b'], 'desk', 'desk', 0), ['a', 'desk', 'b'], 'reach leaves a tile that was not moved')
assertDeepEqual(reach.place(['laptop', 'desk'], 'desk', 'mini', 'beside'), ['laptop', 'desk'], 'reach ignores a side that is not an end of the row')
assertDeepEqual(reach.place(['laptop', 'desk'], 'desk', '', 'left'), ['laptop', 'desk'], 'reach ignores a blank machine name')
assertDeepEqual(reach.place(['laptop', 'desk'], 'desk', '   ', 'right'), ['laptop', 'desk'], 'reach ignores a machine name that is only spaces')
JS
