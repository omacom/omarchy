#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "network panel runtime test"
require_command quickshell

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
      property alias testMobileRow: mobileRow
`)
source = source.replace('  id: root', `  id: root
  function testEnsureContent() { return panel.ensureContent() }
  readonly property Item testContent: panel.loadedContent
  readonly property Item testButton: panel.loadedContent ? panel.loadedContent.testButton : null
  readonly property Item testKeys: panel.loadedContent
  readonly property Item testMeta: panel.loadedContent ? panel.loadedContent.heroMeta : null
  readonly property Item testTitle: panel.loadedContent ? panel.loadedContent.testTitle : null
  readonly property Item testMobileRow: panel.loadedContent ? panel.loadedContent.testMobileRow : null
  property alias testPoll: connectivityPoll
  property alias testApPoll: activeApSignalPoll
  property alias testBarButton: button`)
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
  printf '#!/bin/bash\nexit 0\n' >"$stage/bin/noop"
  chmod +x "$stage/bin/noop"
  for command in omarchy-dns omarchy-network-band nmcli mmcli; do
    ln -s noop "$stage/bin/$command"
  done
  # Preview uses only synthetic details, never the host's SSID or addresses.
  # Normal assertions keep the details empty to exercise missing-route handling.
  printf '#!/bin/bash\nif [[ -n ${NETWORK_TEST_PREVIEW:-} ]]; then\n  printf "type\\twifi\\niface\\ttest-wifi\\nssid\\tGuest Wi-Fi\\nip\\t192.0.2.10\\ngateway\\t192.0.2.1\\n"\nfi\n' >"$stage/bin/omarchy-network-status"
  chmod +x "$stage/bin/omarchy-network-status"
  printf '#!/bin/bash\nprintf "%%s\\n" "$@" >> "$NETWORK_TEST_BROWSER_LOG"\n' >"$stage/bin/omarchy-network-captive-portal"
  chmod +x "$stage/bin/omarchy-network-captive-portal"
}

# run_panel <description>: run the staged fixture to completion.
run_panel() {
  local output
  output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
    NETWORK_TEST_BROWSER_LOG="$stage/browser.log" NETWORK_TEST_NMCLI_LOG="$stage/nmcli.log" \
    NETWORK_TEST_LOG="$stage/commands.log" NETWORK_TEST_STATE="$stage/modem-state" \
    timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "$1 fixture exits cleanly" "$output"
  [[ $output == *"RESULT pass"* ]] || fail "$1 runtime assertions pass" "$output"
  if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
    fail "$1 fixture has no QML errors" "$output"
  fi
}

stage_panel captive-portal
run_panel "network portal"
[[ -f $stage/browser.log ]] || fail "portal action launches the browser"
[[ $(<"$stage/browser.log") == "http://ping.omacom.io/nm-check.txt" ]] || fail "portal opens exactly one fixed HTTP URL"
pass "network portal, recovery, disabled checks, outage, disconnect, keyboard navigation, and browser argv work in QML"

stage_panel owe-transition
# Answers in call order: 57, then a slow stale 11, then 33. Never touches the
# host's NetworkManager. Replace the noop link, not the noop it points to.
rm -f -- "$stage/bin/nmcli"
cat >"$stage/bin/nmcli" <<'SH'
#!/bin/bash
# The panel's modem probe. This fixture has no modem, and the probe must not
# shift the call-order answers below.
if [[ $* == "-t -f DEVICE,TYPE dev" ]]; then
  exit 0
fi
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

stage_panel live-rows
run_panel "network live rows"
pass "network rows follow connects, drops, saves and forgets made outside the panel, with the cursor on its network"

stage_panel mobile
# The modem lives in a state file the stubs share, so the host's
# NetworkManager and ModemManager are never queried or changed.
# It starts absent: ModemManager has not found it when the shell starts.
printf 'absent\n' > "$stage/modem-state"
rm -f -- "$stage/bin/nmcli" "$stage/bin/mmcli"
cat > "$stage/bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$NETWORK_TEST_LOG"
state=$(<"$NETWORK_TEST_STATE")
case $* in
  "-t -f DEVICE,TYPE dev")
    printf 'test-wifi:wifi\n'
    [[ $state == "absent" ]] || printf 'cdc-wdm0:gsm\n'
    ;;
  "-e no -t -f GENERAL.STATE,GENERAL.CONNECTION,GENERAL.CON-UUID,GENERAL.IP-IFACE,GENERAL.UDI dev show cdc-wdm0")
    if [[ $state == "connected" ]]; then
      printf 'GENERAL.STATE:100 (connected)\nGENERAL.CONNECTION:Test Carrier\nGENERAL.CON-UUID:mobile-uuid\nGENERAL.IP-IFACE:wwan0\n'
    else
      printf 'GENERAL.STATE:30 (disconnected)\nGENERAL.CONNECTION:\nGENERAL.CON-UUID:\nGENERAL.IP-IFACE:\n'
    fi
    printf 'GENERAL.UDI:/org/freedesktop/ModemManager1/Modem/0\n'
    ;;
  "-t radio wwan")
    printf 'enabled\n'
    ;;
  "-g UUID,TYPE con show")
    printf 'wifi-uuid:802-11-wireless\nmobile-uuid:gsm\n'
    ;;
  "-e no -g connection.interface-name con show uuid mobile-uuid")
    ;;
  "-e no -g connection.id con show uuid mobile-uuid")
    printf 'Test Carrier\n'
    ;;
  "device disconnect cdc-wdm0")
    printf 'disconnected\n' > "$NETWORK_TEST_STATE"
    ;;
  "radio wwan on")
    ;;
  "--wait 45 connection up uuid mobile-uuid ifname cdc-wdm0")
    printf 'connected\n' > "$NETWORK_TEST_STATE"
    ;;
  *)
    exit 1
    ;;
esac
SH
cat > "$stage/bin/mmcli" <<'SH'
#!/bin/bash
[[ $* == "-m /org/freedesktop/ModemManager1/Modem/0 -K" ]] || exit 1
state=$(<"$NETWORK_TEST_STATE")
if [[ $state != "connected" ]]; then
  state=registered
fi
printf 'modem.generic.state                             : %s\n' "$state"
printf 'modem.generic.access-technologies.value[1]      : lte\n'
printf 'modem.generic.signal-quality.value              : 70\n'
printf 'modem.3gpp.operator-name                        : Test Carrier \n'
SH
# ModemManager's signal stream: the modem comes up shortly after it starts.
cat > "$stage/bin/gdbus" <<'SH'
#!/bin/bash
printf 'gdbus %s\n' "$*" >> "$NETWORK_TEST_LOG"
sleep 0.5
printf 'connected\n' > "$NETWORK_TEST_STATE"
printf '/org/freedesktop/ModemManager1/Bearer/0: org.freedesktop.DBus.Properties.PropertiesChanged (%s)\n' "'org.freedesktop.ModemManager1.Bearer', {'Connected': <true>}, @as []"
printf '/org/freedesktop/ModemManager1/Modem/0: org.freedesktop.ModemManager1.Modem.StateChanged (8, 11, uint32 1)\n'
exec sleep 30 </dev/null >/dev/null 2>&1
SH
cat > "$stage/bin/omarchy-network-status" <<'SH'
#!/bin/bash
if [[ $(<"$NETWORK_TEST_STATE") == "connected" ]]; then
  printf 'iface\twwan0\nip\t192.0.2.20\ngateway\t192.0.2.21\ntype\tmobile\n'
fi
SH
chmod +x "$stage/bin/nmcli" "$stage/bin/mmcli" "$stage/bin/gdbus" "$stage/bin/omarchy-network-status"
run_panel "network mobile broadband"
log=$(<"$stage/commands.log")
[[ $log == *"gdbus monitor --system --dest org.freedesktop.ModemManager1"* ]] || fail "panel follows ModemManager's signals" "$log"
(( $(grep -c '^gdbus ' <<< "$log") == 1 )) || fail "one ModemManager stream per panel" "$log"
[[ ${log%%gdbus *} == *$'-t -f DEVICE,TYPE dev\n-t -f DEVICE,TYPE dev'* ]] || fail "no ModemManager stream starts before a probe finds the modem" "$log"
[[ $log == *"device disconnect cdc-wdm0"* ]] || fail "disconnect targets the modem device" "$log"
[[ $log == *$'radio wwan on\n--wait 45 connection up uuid mobile-uuid ifname cdc-wdm0'* ]] || fail "connect turns the radio on, then brings the profile up by UUID on the modem's device" "$log"
pass "network panel finds a modem that appears after startup, follows ModemManager events, and connects and disconnects it"
