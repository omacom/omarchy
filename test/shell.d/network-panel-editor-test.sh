#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "network panel editor test"
require_command quickshell

scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
fixtures="$SHELL_TEST_DIR/fixtures/network-panel"

# stage_panel <fixture>: a disposable shell that loads the real network
# Panel.qml, Editor.qml and Model.js against the NetworkMock singleton, driven
# by fixtures/network-panel/<fixture>.qml. Only the singleton is swapped and the
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
// content root and mirrored on the panel once the test builds it.
source = source.replace('      id: keyCatcher\n', `      id: keyCatcher
      property alias testEditor: editor
`)
source = source.replace('  id: root', `  id: root
  function testEnsureContent() { return panel.ensureContent() }
  readonly property Item testContent: panel.loadedContent
  readonly property Item testEditor: panel.loadedContent ? panel.loadedContent.testEditor : null`)
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
  # nmcli stub: a connection list with a connected KEMENKEU beside a duplicate,
  # the KEMENKEU settings, and a log of every invocation. Reads are answered from
  # fixtures; modify/edit only log, so no real NetworkManager is touched.
  cat >"$stage/bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$NETWORK_TEST_NMCLI_LOG"
if [[ ${1:-} == "-t" ]]; then
  if [[ $* == *"NAME,UUID,ACTIVE"* ]]; then
    printf 'KEMENKEU:11111111-1111-1111-1111-111111111111:yes\n'
    printf 'KEMENKEU:22222222-2222-2222-2222-222222222222:no\n'
  else
    printf 'connection.autoconnect:yes\n'
    printf 'connection.autoconnect-priority:0\n'
    printf 'connection.metered:unknown\n'
    printf 'ipv4.method:auto\n'
    printf 'ipv4.addresses:\n'
    printf 'ipv4.gateway:\n'
    printf '802-1x.identity:\n'
  fi
fi
if [[ ${2:-} == "edit" ]]; then
  cat >/dev/null
fi
SH
  chmod +x "$stage/bin/nmcli"
}

# run_panel: run the staged fixture to completion.
run_panel() {
  local output
  output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
    NETWORK_TEST_NMCLI_LOG="$stage/nmcli.log" \
    timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network editor fixture exits cleanly" "$output"
  [[ $output == *"RESULT pass"* ]] || fail "network editor runtime assertions pass" "$output"
  if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
    fail "network editor fixture has no QML errors" "$output"
  fi
}

stage_panel editor
run_panel
pass "network editor prefills a saved profile, saves only the changed key by uuid, and never puts a secret in argv"
