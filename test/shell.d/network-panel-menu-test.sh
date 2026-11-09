#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "network panel menu test"
require_command quickshell

scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
fixtures="$SHELL_TEST_DIR/fixtures/network-panel"

# stage_panel <fixture>: a disposable shell that loads the real network Panel.qml
# and Model.js against the NetworkMock singleton, driven by
# fixtures/network-panel/<fixture>.qml. Only the singleton is swapped and the
# private ids the fixture drives are exposed in the disposable copy; production
# code keeps none of it.
stage_panel() {
  stage="$scratch/$1"
  mkdir -p "$stage/network" "$stage/bin" "$stage/home"
  ln -s "$ROOT/shell/Ui" "$stage/Ui"
  ln -s "$ROOT/shell/Commons" "$stage/Commons"
  cp -r "$fixtures/mocks" "$stage/mocks"
  cp "$fixtures/$1.qml" "$stage/shell.qml"
  cp "$ROOT/shell/plugins/panels/network/Model.js" "$stage/network/Model.js"
  cp "$ROOT/shell/plugins/panels/network/Editor.qml" "$stage/network/Editor.qml"
  node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Keep installed enum values and actual UI bindings. Only replace the singleton
// and expose private IDs in the disposable copy, never in production code.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
// The panel's content is built lazily, so its private ids are exposed from the
// content root. The fixture drives the row's right-click entry point with the
// real delegate row and checks the row's click target accepts right clicks.
source = source.replace('      id: keyCatcher\n', `      id: keyCatcher
      property alias testMenu: contextMenu
      function testFindObject(obj, name) {
        if (!obj) return null
        if (obj.objectName === name) return obj
        var kids = obj.children || []
        for (var i = 0; i < kids.length; i++) {
          var found = testFindObject(kids[i], name)
          if (found) return found
        }
        return null
      }
      function testRowMouse(index) { return testFindObject(networkList.itemAtIndex(index), "rowMouse") }
      function testRowGesture(index, button) {
        var item = networkList.itemAtIndex(index)
        if (item && item.modelData) root.rowGesture(item.modelData, index, button)
      }
      function testRowHasCursor(index) {
        var item = networkList.itemAtIndex(index)
        var row = testFindByProp(item, "hasCursor")
        return row ? row.hasCursor : null
      }
      function testFindByProp(obj, prop) {
        if (!obj) return null
        if (obj[prop] !== undefined) return obj
        var kids = obj.children || []
        for (var i = 0; i < kids.length; i++) {
          var found = testFindByProp(kids[i], prop)
          if (found) return found
        }
        return null
      }
      function testMenuPopup() {
        var data = contextMenu.data || []
        for (var i = 0; i < data.length; i++) {
          var c = data[i]
          if (c && c.opened !== undefined && c.height !== undefined) return c
        }
        return null
      }
`)
source = source.replace('      id: rowMouse\n', `      id: rowMouse
      objectName: "rowMouse"
`)
source = source.replace('  id: root', `  id: root
  function testEnsureContent() { return panel.ensureContent() }
  readonly property Item testContent: panel.loadedContent`)
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
  printf '#!/bin/bash\nexit 0\n' >"$stage/bin/noop"
  chmod +x "$stage/bin/noop"
  for command in omarchy-dns omarchy-network-band; do
    ln -s noop "$stage/bin/$command"
  done
  # Only synthetic details, and nothing unless a preview asks for them; the host's
  # SSID and addresses never leak in.
  printf '#!/bin/bash\nif [[ -n ${NETWORK_TEST_PREVIEW:-} ]]; then\n  printf "type\\twifi\\niface\\ttest-wifi\\nssid\\tGuest Wi-Fi\\nip\\t192.0.2.10\\ngateway\\t192.0.2.1\\n"\nfi\n' >"$stage/bin/omarchy-network-status"
  chmod +x "$stage/bin/omarchy-network-status"
}

# run_panel: run the staged fixture to completion.
run_panel() {
  local output filtered
  output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
    timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network menu fixture exits cleanly" "$output"
  [[ $output == *"RESULT pass"* ]] || fail "network menu runtime assertions pass" "$output"
  # The network row's status line carries a pre-existing, benign Qt height
  # binding-loop warning: it fires on the base branch the moment any row's
  # status changes (here, Forget flipping the row to "Forgetting…"), so it is
  # not this menu's doing. Drop that one line; every other error still fails,
  # including any loop in the ContextMenu itself (reported against its own
  # file).
  filtered=$(rg -v 'network/Panel\.qml.*Binding loop detected for property "height"' <<<"$output" || true)
  if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$filtered"; then
    fail "network menu fixture has no QML errors" "$output"
  fi
}

stage_panel menu
run_panel
pass "network right-click menu opens beside the row, filters Forget off the connected row, closes on Escape, and wires Forget to the profile"
