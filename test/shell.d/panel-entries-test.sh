#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')

// Handing the Instantiator a fresh array rebuilt every panel on each plugin
// change, several times during startup, so a keepLoaded panel such as the OSD
// could load twice at once and register its IPC handler twice.
assert(
  /Instantiator \{\s*model: panelEntryModel/.test(shellQml) && !shellQml.includes('panelEntries'),
  'panel loaders come from a model synced in place, not a reassigned array'
)
assert(
  /if \(next && next\.kind === row\.entryKind && next\.keepLoaded === row\.keepLoaded && next\.sourceUrl === row\.sourceUrl\) \{\s*delete wanted\[row\.pluginId\]/.test(shellQml),
  'a panel whose plugin still loads the same way keeps its loader'
)
assert(
  /function unloadPanels\(\) \{[\s\S]*?panelEntryModel\.clear\(\)/.test(shellQml),
  'a full plugin reload still rebuilds every panel from fresh code'
)
assert(
  (shellQml.match(/shell\.syncPanelEntries\(\)/g) || []).length === 2,
  'plugin changes and finished scans sync the panel entries'
)
JS
