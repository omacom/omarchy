#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

OMARCHY_PATH="$ROOT" python "$ROOT/test/shell.d/typing-setup-checks.py"

run_node_test <<'JS'
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const options = ['French', '\tJapanese (Mozc)', 'x\tSame label\tfirst', 'x\tSame label\tsecond']
assertEqual(menu.dmenuValue(options[2]), 'Same label\tfirst', 'multi-select keeps a stable subtext value without the icon')
assertDeepEqual(menu.dmenuSelections(options, ['Same label\tsecond', 'French', 'stale']), ['French', 'Same label\tsecond'], 'multi-select preserves option order and excludes stale choices')
assertDeepEqual(menu.dmenuSelections(options, ['Same label\tsecond', 'French', 'stale'], true), ['Same label\tsecond', 'French'], 'immediate selections preserve switching order')
assertDeepEqual(menu.toggleDmenuSelection(['French'], 'French'), [], 'deselecting the final option produces an empty selection')
assertDeepEqual(menu.toggleDmenuSelection(['French'], 'Japanese (Mozc)'), ['French', 'Japanese (Mozc)'], 'selecting an input retains earlier choices')
JS
