#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "workspaces model" <<'JS'
const model = requireFromRoot('shell/plugins/bar/widgets/WorkspacesModel.js')

// DP-1 owns block 0 (1-10), HDMI-A-1 block 1 (11-20). Workspace 23 belongs to
// an unplugged third monitor and is visiting HDMI-A-1.
const two = [
  { id: 1, monitor: 'DP-1' },
  { id: 3, monitor: 'DP-1' },
  { id: 17, monitor: 'HDMI-A-1' },
  { id: 20, monitor: 'HDMI-A-1' },
  { id: 23, monitor: 'HDMI-A-1' }
]

assertDeepEqual(model.workspaceIds(two, {}, 0, 'DP-1'), [1, 2, 3, 4, 5], 'defaults show slots 1-5 plus the open ones of this block')
assertDeepEqual(model.workspaceIds(two, {}, 1, 'HDMI-A-1'), [11, 12, 13, 14, 15, 17, 20, 23], 'the second monitor counts its slots in its own block, then its guests')
assertDeepEqual(model.workspaceIds(two, { persistent: [] }, 0, 'DP-1'), [1, 3], 'an empty persistent list shows only open workspaces')
assertDeepEqual(model.workspaceIds(two, { persistent: [] }, 1, 'HDMI-A-1'), [17, 20, 23], 'an empty persistent list keeps the visiting workspaces')
assertDeepEqual(model.workspaceIds(two, { persistent: [2] }, 1, 'HDMI-A-1'), [12, 17, 20, 23], 'persistent slots map into the block')
assertDeepEqual(model.workspaceIds(two, { persistent: [10] }, 0, 'DP-1'), [1, 3, 10], 'slot 10 is the last of the block')
assertDeepEqual(model.workspaceIds(two, { persistent: [] }, 1, ''), [17, 20], 'no guests without a known monitor')
assertDeepEqual(model.workspaceIds([{ id: -98, monitor: 'DP-1' }], { persistent: [] }, 0, 'DP-1'), [], 'special workspaces are left out')

assertDeepEqual(model.persistentSlots(undefined), [1, 2, 3, 4, 5], 'persistent defaults to 1-5')
assertDeepEqual(model.persistentSlots([3, 3, 0, 11, 'x', 1.5, 9]), [3, 9], 'persistent keeps whole slots 1-10, once each')
JS
