#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/bar/widgets/WorkspacesModel.js')

assertEqual(model.baseOpacity(true, false), 1, 'an occupied workspace button rests at full opacity')
assertEqual(model.baseOpacity(false, true), 1, 'the focused workspace button rests at full opacity')
assertEqual(model.baseOpacity(false, false), 0.5, 'an empty unused workspace button rests dimmed')
assertEqual(model.baseOpacity(true, true), 1, 'an occupied focused workspace button rests at full opacity')

assertEqual(model.shouldFlash(true, false), true, 'an urgent unfocused workspace flashes')
assertEqual(model.shouldFlash(false, false), false, 'a workspace without urgent windows does not flash')
assertEqual(model.shouldFlash(false, true), false, 'the focused workspace does not flash without urgency')
assertEqual(model.shouldFlash(true, true), false, 'the focused workspace does not flash while the user is on it')
assertEqual(model.shouldFlash(undefined, false), false, 'a missing urgency source does not flash')
assertEqual(model.shouldFlash(1, false), false, 'a truthy non-boolean urgency value does not flash')
assertEqual(model.shouldFlash(null, false), false, 'null urgency does not flash')

assertEqual(model.FLASH_MIN_OPACITY, 0.4, 'flash dims to the configured minimum opacity')
assertEqual(model.FLASH_DIRECTION_MS, 400, 'each flash direction runs for the configured duration')
JS