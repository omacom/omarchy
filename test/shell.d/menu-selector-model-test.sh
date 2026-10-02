#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Qt Quick Test is optional on headless CI; no Quickshell or compositor needed.
runner=$(command -v qmltestrunner || command -v qmltestrunner6 || true)
if [[ -z $runner && -x /usr/lib/qt6/bin/qmltestrunner ]]; then
  runner=/usr/lib/qt6/bin/qmltestrunner
fi
if [[ -z $runner ]]; then
  skip "selector model runtime test requires optional Qt 6 qmltestrunner"
  exit 0
fi
require_command node

fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT
export SELECTOR_MODEL_FIXTURE_DIR="$fixture_dir"

# Execute the production functions, rather than a copied JS implementation.
# Only the desktop boundary (cursor reveal and result-file writing) is stubbed.
node <<'JS'
const fs = require('fs')
const path = require('path')
const source = fs.readFileSync(path.join(process.env.ROOT, 'shell/plugins/menu/Menu.qml'), 'utf8')
const functions = ['rebuildDmenuDisplay', 'activateIndex', 'applyDmenuSelection'].map(name => {
  const match = source.match(new RegExp(`^  function ${name}\\([^\\n]*\\) \\{[\\s\\S]*?^  \\}`, 'm'))
  if (!match) throw new Error(`Cannot extract Menu.qml function ${name}`)
  return match[0]
}).join('\n\n')
const template = fs.readFileSync(path.join(process.env.ROOT, 'test/shell.d/fixtures/menu-selector-model/tst_selector.qml'), 'utf8')
fs.writeFileSync(path.join(process.env.SELECTOR_MODEL_FIXTURE_DIR, 'tst_selector.qml'), template.replace('// PRODUCTION_FUNCTIONS', functions))
JS

# The GTK platform theme can try to open a display even with offscreen selected.
QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
  "$runner" -input "$fixture_dir"
pass "selector production functions preserve Qt model rows, roles, selection, and batched signals"
