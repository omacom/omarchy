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
// Expose the passphrase field's id to the fixture so it can prove a typed
// secret does not survive into the next edit session; production keeps it
// private. The form's Save/Cancel buttons, the auto-connect toggle and the
// picker's choice buttons are tagged the same way so the fixture can read their
// keyboard-reachability properties.
let editorSource = fs.readFileSync(`${root}/shell/plugins/panels/network/Editor.qml`, 'utf8')
editorSource = editorSource.replace('        id: pskField\n', '        id: pskField\n        objectName: "pskField"\n')
editorSource = editorSource.replace('          text: root.copy.save\n', '          text: root.copy.save\n          objectName: "saveButton"\n')
editorSource = editorSource.replace('          text: root.copy.cancel\n', '          text: root.copy.cancel\n          objectName: "cancelButton"\n')
editorSource = editorSource.replace('      id: autoToggle\n', '      id: autoToggle\n      objectName: "autoToggle"\n')
editorSource = editorSource.replace('        required property var modelData\n        width: picker.width\n', '        required property var modelData\n        width: picker.width\n        objectName: "pickerChoice"\n')
fs.writeFileSync(`${stage}/network/Editor.qml`, editorSource)
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
  # nmcli stub shaped like the real tool: `connection show` (the list form)
  # rejects setting fields, so it answers a list read only for the allowed
  # NAME,UUID,TYPE,ACTIVE,DEVICE set and errors on anything containing a setting
  # field like 802-11-wireless.ssid. The SSID is then read per profile with the
  # selector form `connection show uuid <uuid>`. `connection show --active`
  # reads the active UUID from a file the fixture rewrites to simulate a network
  # switch before Save. `connection edit` writes its stdin to a separate log so
  # a secret written over stdin can be told apart from argv; modify/edit only
  # log, so no real NetworkManager is touched.
  cat >"$stage/bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$NETWORK_TEST_NMCLI_LOG"
if [[ ${1:-} == "-t" ]]; then
  args="$*"
  if [[ $args == *"--active"* ]]; then
    cat "$NETWORK_TEST_ACTIVE_FILE"
  elif [[ $args == *"connection show" && $args != *"connection show uuid "* ]]; then
    # List form: only the connection-list fields are valid. A setting field such
    # as 802-11-wireless.ssid is rejected the way the real tool rejects it, so a
    # regression to the old single-step read fails loudly here.
    if [[ $args == *"NAME,UUID,TYPE,ACTIVE,DEVICE"* ]]; then
      printf 'KEMENKEU:11111111-1111-1111-1111-111111111111:802-11-wireless:yes:wlo1\n'
      printf 'KEMENKEU:22222222-2222-2222-2222-222222222222:802-11-wireless:no:\n'
      printf 'AMBIG:33333333-3333-3333-3333-333333333333:802-11-wireless:no:\n'
      printf 'AMBIG:44444444-4444-4444-4444-444444444444:802-11-wireless:no:\n'
      printf 'CORP:55555555-5555-5555-5555-555555555555:802-11-wireless:no:\n'
    else
      printf "Error: invalid field '802-11-wireless.ssid'; allowed fields: NAME,UUID,TYPE,TIMESTAMP,AUTOCONNECT,AUTOCONNECT-PRIORITY,READONLY,DBUS-PATH,ACTIVE,DEVICE,STATE,ACTIVE-PATH,PORT,FILENAME\n" >&2
      exit 2
    fi
  elif [[ $args == *"connection show uuid "* ]]; then
    uuid="${args##*uuid }"
    if [[ $args == *"802-11-wireless.ssid"* ]]; then
      # Selector form: answer with the requested profile's saved ssid.
      case "$uuid" in
        11111111-1111-1111-1111-111111111111) printf '802-11-wireless.ssid:KEMENKEU\n' ;;
        22222222-2222-2222-2222-222222222222) printf '802-11-wireless.ssid:KEMENKEU\n' ;;
        33333333-3333-3333-3333-333333333333) printf '802-11-wireless.ssid:AMBIG\n' ;;
        44444444-4444-4444-4444-444444444444) printf '802-11-wireless.ssid:AMBIG\n' ;;
        55555555-5555-5555-5555-555555555555) printf '802-11-wireless.ssid:CORP\n' ;;
        *) printf '802-11-wireless.ssid:\n' ;;
      esac
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
fi
if [[ ${2:-} == "edit" ]]; then
  while IFS= read -r line; do
    printf '%s\n' "$line" >> "$NETWORK_TEST_NMCLI_STDIN_LOG"
    [[ $line == "quit" ]] && break
  done
fi
SH
  chmod +x "$stage/bin/nmcli"
  printf '11111111-1111-1111-1111-111111111111\n' >"$stage/active.uuid"
  : >"$stage/nmcli.log"
  : >"$stage/nmcli.stdin.log"
}

# run_panel: run the staged fixture to completion.
run_panel() {
  local output
  output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
    NETWORK_TEST_NMCLI_LOG="$stage/nmcli.log" NETWORK_TEST_NMCLI_STDIN_LOG="$stage/nmcli.stdin.log" \
    NETWORK_TEST_ACTIVE_FILE="$stage/active.uuid" \
    timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network editor fixture exits cleanly" "$output"
  [[ $output == *"RESULT pass"* ]] || fail "network editor runtime assertions pass" "$output"
  if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
    fail "network editor fixture has no QML errors" "$output"
  fi
}

stage_panel editor
run_panel

# The connection list must use only the fields nmcli's list form allows (the
# real tool and the stub both reject a setting field such as
# 802-11-wireless.ssid), and each Wi-Fi profile's saved SSID must be read
# separately with the selector form.
nmcli_log=$(cat "$stage/nmcli.log")
if rg -q -- '-f [^ ]*802-11-wireless\.ssid[^ ]* +connection +show$' <<<"$nmcli_log"; then
  fail "editor never asks the nmcli connection list for a setting field" "$nmcli_log"
fi
rg -q -- '-t -f NAME,UUID,TYPE,ACTIVE,DEVICE connection show$' <<<"$nmcli_log" \
  || fail "editor lists connections with only the nmcli list fields" "$nmcli_log"
rg -q -- '-t -f 802-11-wireless.ssid connection show uuid ' <<<"$nmcli_log" \
  || fail "editor reads each Wi-Fi profile's saved ssid with the selector form" "$nmcli_log"

pass "network editor prefills a saved profile, saves only the changed key by uuid, sends a passphrase over stdin, reconnects the active profile, picks among duplicate profiles, edits an EAP password over stdin, lists connections with only valid list fields and reads each ssid by uuid, stays keyboard reachable (Save/Cancel/picker focusable, auto-connect activatable, Escape closes), ignores Escape during a busy save, and drops a callback from a cancelled session"
