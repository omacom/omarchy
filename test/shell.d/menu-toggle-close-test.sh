#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')

// shell.toggle must close the image-picker a menu action left open instead of
// re-running the action on the next key press. The menu self-closes by setting
// `opened = false` without calling shell.hide, which leaves a stale
// openPanelIds entry; toggle uses that stale entry as the signal to tear down
// the picker behind Background/Theme — and nothing else.
const toggleBody = shellSource.match(/function toggle\(pluginId, payloadJson\) \{([\s\S]*?)\n  \}/)
assert(toggleBody, 'shell.qml defines a toggle(pluginId, payloadJson) function')

assert(/openPanelIds\[id\]/.test(toggleBody[1]), 'toggle checks the stale openPanelIds entry for the requested plugin')
assert(/omarchy\.image-picker/.test(toggleBody[1]), 'toggle targets only the image-picker a menu action spawns')
assert(/isPluginOpen\(pickerId\)/.test(toggleBody[1]), 'toggle checks whether the spawned picker is still open before closing it')
assert(/hide\(pickerId\)/.test(toggleBody[1]), 'toggle hides the image-picker the menu action left open')
assert(!/for\s*\(\s*var openId in openPanelIds/.test(toggleBody[1]), 'toggle does not close arbitrary open panels')
assert(!/hide\(openId\)/.test(toggleBody[1]), 'toggle does not hide whatever panel happens to be open')
assert(/hide\(id\)/.test(toggleBody[1]), 'toggle cleans up the stale openPanelIds entry for the requested plugin')
assert(/return summon\(id, payloadJson\)/.test(toggleBody[1]), 'toggle still summons when no spawned panel needs closing')

pass('shell.toggle closes a menu-spawned panel on re-press instead of re-running the action')
JS
