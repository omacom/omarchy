#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "network panel runtime test"
require_command quickshell
require_command wtype

scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
fixtures="$SHELL_TEST_DIR/fixtures/network-panel"

# stage_panel <fixture>: a disposable shell that loads the real network Panel.qml
# and Model.js against the NetworkMock singleton, driven by fixtures/network-panel/<fixture>.qml.
# All networking and external actions are mocked; the real connection and
# browser are never touched, and the fixture writes only to its scratch HOME.
stage_panel() {
  stage="$scratch/$1"
  mkdir -p "$stage/network" "$stage/bin" "$stage/home"
  ln -s "$ROOT/shell/Ui" "$stage/Ui"
  ln -s "$ROOT/shell/Commons" "$stage/Commons"
  cp -r "$fixtures/mocks" "$stage/mocks"
  cp "$fixtures/$1.qml" "$stage/shell.qml"
  cp "$ROOT/shell/plugins/panels/network/Model.js" "$stage/network/Model.js"
  node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Keep installed enum values and actual UI bindings. Only replace the singleton
// and expose private IDs in the disposable copy, never in production code.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
// The panel's content is built lazily, so its private IDs are exposed from
// the content root and mirrored on the panel once the test builds it.
source = source.replace('      id: keyCatcher\n', `      id: keyCatcher
      property alias testButton: portalAction
      property alias testTitle: heroSsid
      property alias testNetworkList: networkList
`)
source = source.replace('        id: pwField\n', '        id: pwField\n        objectName: "testPasswordField"\n')
source = source.replace('        id: revealPwBtn\n', '        id: revealPwBtn\n        objectName: "testRevealButton"\n')
source = source.replace('  id: root', `  id: root
  function testEnsureContent() { return panel.ensureContent() }
  readonly property Item testContent: panel.loadedContent
  readonly property Item testButton: panel.loadedContent ? panel.loadedContent.testButton : null
  readonly property Item testKeys: panel.loadedContent
  readonly property Item testMeta: panel.loadedContent ? panel.loadedContent.heroMeta : null
  readonly property Item testNetworkList: panel.loadedContent ? panel.loadedContent.testNetworkList : null
  readonly property Item testTitle: panel.loadedContent ? panel.loadedContent.testTitle : null
  property alias testPoll: connectivityPoll
  property alias testApPoll: activeApSignalPoll
  property alias testBarButton: button`)
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
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
  printf '#!/bin/bash\nprintf "%%s\\n" "$@" >> "$NETWORK_TEST_BROWSER_LOG"\n' >"$stage/bin/omarchy-network-captive-portal"
  chmod +x "$stage/bin/omarchy-network-captive-portal"
}

check_panel_output() {
  local description=$1 output=$2
  [[ $output == *"RESULT pass"* ]] || fail "$description runtime assertions pass" "$output"
  if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
    fail "$description fixture has no QML errors" "$output"
  fi
}

# run_panel <description>: run the staged fixture to completion.
run_panel() {
  local output
  output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
    NETWORK_TEST_BROWSER_LOG="$stage/browser.log" NETWORK_TEST_NMCLI_LOG="$stage/nmcli.log" \
    timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "$1 fixture exits cleanly" "$output"
  check_panel_output "$1" "$output"
}

# Run a fixture until its focused control asks for Escape, then send a real
# compositor key event. This covers the path QML signal calls cannot emulate.
run_panel_with_escape() {
  local description=$1 output_file="$stage/output" output pid ready=false
  HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
    NETWORK_TEST_BROWSER_LOG="$stage/browser.log" NETWORK_TEST_NMCLI_LOG="$stage/nmcli.log" \
    timeout 30 quickshell -p "$stage" --no-color >"$output_file" 2>&1 &
  pid=$!
  for _ in {1..100}; do
    if rg -q 'INPUT escape' "$output_file"; then ready=true; break; fi
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.05
  done
  if [[ $ready != true ]]; then
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    fail "$description fixture reaches the Escape check" "$(<"$output_file")"
  fi
  wtype -k Escape
  wait "$pid" || fail "$description fixture exits cleanly" "$(<"$output_file")"
  output=$(<"$output_file")
  check_panel_output "$description" "$output"
}

stage_panel captive-portal
run_panel "network portal"
[[ -f $stage/browser.log ]] || fail "portal action launches the browser"
[[ $(<"$stage/browser.log") == "http://ping.omacom.io/nm-check.txt" ]] || fail "portal opens exactly one fixed HTTP URL"
pass "network portal, recovery, disabled checks, outage, disconnect, keyboard navigation, and browser argv work in QML"

stage_panel owe-transition
# Answers in call order: 57, then a slow stale 11, then 33. Never touches the
# host's NetworkManager.
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
run_panel "network OWE"
while IFS= read -r args; do
  [[ $args == "-t -f IN-USE,SIGNAL device wifi list ifname test-wifi --rescan no" ]] || fail "in-use access point read never rescans" "$args"
done <"$stage/nmcli.log"
pass "network keeps Wi-Fi through OWE transition scan churn, reads the in-use access point, and discards stale reads"

stage_panel password-visibility
run_panel_with_escape "network password visibility"
pass "network passphrases reveal on demand, stay in place, return focus, and cancel from the reveal action"
