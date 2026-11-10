#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "network panel runtime test"
require_command quickshell

scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
fixtures="$SHELL_TEST_DIR/fixtures/network-panel"

# panel_env carries the fixture-specific environment (nmcli/browser logs, the
# active-UUID file) for the next run_panel. stage_panel resets it, so a case
# only sees the vars its own setup exported.
panel_env=()

# stage_panel <fixture> [setup]: a disposable shell that loads the real network
# Panel.qml, Editor.qml and Model.js against the NetworkMock singleton, driven
# by fixtures/network-panel/<fixture>.qml. The panel's lazy content is exposed
# once, with the union of the private ids the fixtures drive. All networking and
# external actions are mocked; the real connection and browser are never
# touched, and the fixture writes only to its scratch HOME.
# An optional <setup> function installs that case's own stubs (nmcli, the
# captive-portal launcher) and appends its own env to panel_env, so the shared
# staging never bakes in one fixture's fixtures.
stage_panel() {
  local fixture=$1 setup=${2:-}
  stage="$scratch/$fixture"
  panel_env=()
  mkdir -p "$stage/network" "$stage/bin" "$stage/home"
  ln -s "$ROOT/shell/Ui" "$stage/Ui"
  ln -s "$ROOT/shell/Commons" "$stage/Commons"
  cp -r "$fixtures/mocks" "$stage/mocks"
  cp "$fixtures/$fixture.qml" "$stage/shell.qml"
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
// content root and mirrored on the panel once the test builds it. The id list is
// the union of every fixture's entry points; an unused alias is inert.
source = source.replace('      id: keyCatcher\n', `      id: keyCatcher
      property alias testButton: portalAction
      property alias testTitle: heroSsid
      property alias testEditor: editor
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
  readonly property Item testContent: panel.loadedContent
  readonly property Item testButton: panel.loadedContent ? panel.loadedContent.testButton : null
  readonly property Item testKeys: panel.loadedContent
  readonly property Item testMeta: panel.loadedContent ? panel.loadedContent.heroMeta : null
  readonly property Item testTitle: panel.loadedContent ? panel.loadedContent.testTitle : null
  readonly property Item testEditor: panel.loadedContent ? panel.loadedContent.testEditor : null
  property alias testPoll: connectivityPoll
  property alias testApPoll: activeApSignalPoll
  property alias testBarButton: button`)
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
  # Preview uses only synthetic details, never the host's SSID or addresses.
  # Normal assertions keep the details empty to exercise missing-route handling.
  printf '#!/bin/bash\nif [[ -n ${NETWORK_TEST_PREVIEW:-} ]]; then\n  printf "type\\twifi\\niface\\ttest-wifi\\nssid\\tGuest Wi-Fi\\nip\\t192.0.2.10\\ngateway\\t192.0.2.1\\n"\nfi\n' >"$stage/bin/omarchy-network-status"
  chmod +x "$stage/bin/omarchy-network-status"
  if [[ -n $setup ]]; then
    "$setup"
  fi
}

# run_panel <description> [benign-warning-pattern]: run the staged fixture to
# completion. The optional pattern drops one known-benign warning line a fixture
# legitimately trips; every other error still fails.
run_panel() {
  local output filtered
  output=$(env HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" "${panel_env[@]}" \
    timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "$1 fixture exits cleanly" "$output"
  [[ $output == *"RESULT pass"* ]] || fail "$1 runtime assertions pass" "$output"
  filtered=$output
  if [[ -n ${2:-} ]]; then
    filtered=$(rg -v "$2" <<<"$output" || true)
  fi
  if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$filtered"; then
    fail "$1 fixture has no QML errors" "$output"
  fi
}

# The portal case launches the captive-portal command; record its argv so the
# fixture's browser hand-off is asserted from outside, and never the real browser.
setup_portal() {
  printf '#!/bin/bash\nprintf "%%s\\n" "$@" >> "$NETWORK_TEST_BROWSER_LOG"\n' >"$stage/bin/omarchy-network-captive-portal"
  chmod +x "$stage/bin/omarchy-network-captive-portal"
  panel_env+=("NETWORK_TEST_BROWSER_LOG=$stage/browser.log")
}

# The OWE case stubs nmcli so its Wi-Fi reads answer in a fixed order and never
# reach the host's NetworkManager.
setup_owe() {
  cat >"$stage/bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$NETWORK_TEST_NMCLI_LOG"
count=$(wc -l < "$NETWORK_TEST_NMCLI_LOG")
case $count in
  1) printf ' :82\n*:57\n' ;;
  2) sleep 0.5; printf '*:11\n' ;;
  *) printf ' :40\n*:33\n' ;;
esac
SH
  chmod +x "$stage/bin/nmcli"
  panel_env+=("NETWORK_TEST_NMCLI_LOG=$stage/nmcli.log")
}

# The editor case stubs nmcli and records argv (and the stdin a secret is written
# over) so the exact command the panel produced can be asserted; the active UUID
# is read from a file the fixture rewrites to simulate a network switch. The stub
# is shaped like the real tool: `connection show` (the list form) rejects setting
# fields, so it answers a list read only for the allowed NAME,UUID,TYPE,ACTIVE,
# DEVICE set and errors on anything containing a setting field like
# 802-11-wireless.ssid. The SSID is then read per profile with the selector form
# `connection show uuid <uuid>`. modify/edit only log, so no real
# NetworkManager is touched.
setup_editor() {
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
  panel_env+=("NETWORK_TEST_NMCLI_LOG=$stage/nmcli.log" \
    "NETWORK_TEST_NMCLI_STDIN_LOG=$stage/nmcli.stdin.log" \
    "NETWORK_TEST_ACTIVE_FILE=$stage/active.uuid")
}

stage_panel captive-portal setup_portal
run_panel "network portal"
[[ -f $stage/browser.log ]] || fail "portal action launches the browser"
[[ $(<"$stage/browser.log") == "http://ping.omacom.io/nm-check.txt" ]] || fail "portal opens exactly one fixed HTTP URL"
pass "network portal, recovery, disabled checks, outage, disconnect, keyboard navigation, and browser argv work in QML"

stage_panel owe-transition setup_owe
# Answers in call order: 57, then a slow stale 11, then 33. Never touches the
# host's NetworkManager.
run_panel "network OWE"
while IFS= read -r args; do
  [[ $args == "-t -f IN-USE,SIGNAL device wifi list ifname test-wifi --rescan no" ]] || fail "in-use access point read never rescans" "$args"
done <"$stage/nmcli.log"
pass "network keeps Wi-Fi through OWE transition scan churn, reads the in-use access point, and discards stale reads"

stage_panel menu
# The network row's status line carries a pre-existing, benign Qt height
# binding-loop warning: it fires on the base branch the moment any row's status
# changes (here, Forget flipping the row to "Forgetting…"), so it is not this
# menu's doing. Drop that one line; every other error still fails, including any
# loop in the ContextMenu itself (reported against its own file).
run_panel "network menu" 'network/Panel\.qml.*Binding loop detected for property "height"'
pass "network right-click menu opens beside the row, filters Forget off the connected row, closes on Escape, and wires Forget to the profile"

stage_panel editor setup_editor
run_panel "network editor"
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
