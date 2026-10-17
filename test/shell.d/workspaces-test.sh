#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "workspaces model" <<'JS'
const model = requireFromRoot('shell/plugins/bar/widgets/WorkspacesModel.js')

const two = [
  { id: 1, monitor: 'DP-1' },
  { id: 3, monitor: 'DP-1' },
  { id: 7, monitor: 'HDMI-A-1' },
  { id: 10, monitor: 'HDMI-A-1' }
]

assertDeepEqual(model.workspaceIds(two, {}, 'DP-1'), [1, 2, 3, 4, 5, 7, 10], 'defaults show 1-5 plus every open workspace on every bar')
assertDeepEqual(model.workspaceIds(two, { persistent: [] }, 'DP-1'), [1, 3, 7, 10], 'an empty persistent list shows only open workspaces')
assertDeepEqual(model.workspaceIds(two, { persistent: [], perMonitor: true }, 'DP-1'), [1, 3], 'perMonitor keeps the workspaces on this bar\'s monitor')
assertDeepEqual(model.workspaceIds(two, { persistent: [], perMonitor: true }, 'HDMI-A-1'), [7, 10], 'the other monitor\'s bar lists its own')
assertDeepEqual(model.workspaceIds(two, { perMonitor: true }, 'HDMI-A-1'), [2, 4, 5, 7, 10], 'a persistent number open on another monitor shows only there')
assertDeepEqual(model.workspaceIds(two, { perMonitor: true }, ''), [1, 2, 3, 4, 5, 7, 10], 'perMonitor without a known screen falls back to every workspace')
assertDeepEqual(model.workspaceIds([{ id: -98, monitor: 'DP-1' }, { id: 11, monitor: 'DP-1' }], { persistent: [] }, 'DP-1'), [], 'special and out-of-range workspaces are left out')

assertDeepEqual(model.persistentIds(undefined), [1, 2, 3, 4, 5], 'persistent defaults to 1-5')
assertDeepEqual(model.persistentIds([3, 3, 0, 11, 'x', 1.5, 9]), [3, 9], 'persistent keeps whole numbers 1-10, once each')
JS
