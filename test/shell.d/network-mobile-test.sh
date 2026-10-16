#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const network = requireFromRoot('shell/plugins/panels/network/Model.js')

const connected = network.parseMobileStatus([
  'device\tcdc-wdm0',
  'state\t100 (connected)',
  'connection\tCarrier',
  'iface\twwan0',
  'radio\tenabled',
  'profile_uuid\tmobile-uuid',
  'profile\tCarrier',
  'modem_state\tconnected',
  'tech\tlte',
  'signal\t54',
  'operator\tCarrier ',
  ''
].join('\n'))
assert(connected.available && connected.state === 'connected', 'connected modem parses as connected')
assertEqual(connected.operator, 'Carrier', 'operator name is trimmed')
assertEqual(network.mobileTitle(connected), 'Carrier', 'row is titled by the active profile')
assertEqual(network.mobileDetail(connected), 'LTE · 54% · Connected', 'connected row reads technology, signal and state')

assertDeepEqual(network.parseMobileStatus(''), { available: false }, 'no modem means no mobile section')

const idle = network.parseMobileStatus('device\tcdc-wdm0\nstate\t30 (disconnected)\nconnection\t\nradio\tenabled\nprofile_uuid\tmobile-uuid\nprofile\tCarrier\ntech\tlte\nsignal\t40\n')
assertEqual(idle.state, 'disconnected', 'disconnected modem parses as disconnected')
assertEqual(network.mobileTitle(idle), 'Carrier', 'disconnected row falls back to the saved profile name')
assertEqual(network.mobileDetail(idle), 'LTE · 40%', 'disconnected row shows signal without a state')
assertEqual(network.parseMobileStatus('device\tcdc-wdm0\nstate\t70 (connecting (getting IP configuration))\n').state, 'connecting', 'activation states parse as connecting')
assertEqual(network.mobileDetail(network.parseMobileStatus('device\tcdc-wdm0\nstate\t30 (disconnected)\nradio\tenabled\n')), 'No connection set up', 'modem without a profile says so')
assertEqual(network.mobileDetail(network.parseMobileStatus('device\tcdc-wdm0\nstate\t20 (unavailable)\nradio\tdisabled\n')), 'Mobile radio off', 'radio off wins over other states')
assertEqual(network.mobileDetail(network.parseMobileStatus('device\tcdc-wdm0\nstate\t20 (unavailable)\nradio\tenabled\nmodem_state\tlocked\n')), 'SIM locked', 'locked SIM is named')
assertEqual(network.parseMobileStatus('device\tcdc-wdm0\nconnection\t--\n').connection, '', 'nmcli placeholders read as empty')

for (const [tech, label] of [['lte', 'LTE'], ['5gnr', '5G'], ['hspa-plus', '3G'], ['edge', '2G'], ['', '']]) {
  assertEqual(network.mobileTechLabel(tech), label, `access technology ${tech || '(none)'} reads as ${label || 'nothing'}`)
}

assertEqual(network.mobileIconFor(54, false), '󰞃', 'unusable modem uses the crossed-out icon')
for (const [signal, icon] of [[0, '󰢿'], [20, '󰢿'], [40, '󰢼'], [70, '󰢽'], [100, '󰢾'], [-1, '󰢿']]) {
  assertEqual(network.mobileIconFor(signal, true), icon, `signal ${signal} picks its bars`)
}
assertEqual(network.connectionIcon('mobile', 70, 'full'), network.mobileIconFor(70, true), 'bar uses cellular bars for a mobile connection')

assert(network.isMobileStatusEvent("/org/freedesktop/ModemManager1/Modem/0: org.freedesktop.ModemManager1.Modem.StateChanged (8, 11, uint32 1)"), 'modem state change re-probes')
assert(network.isMobileStatusEvent("/org/freedesktop/ModemManager1/Modem/0: org.freedesktop.DBus.Properties.PropertiesChanged ('org.freedesktop.ModemManager1.Modem', {'SignalQuality': <(uint32 60, true)>}, @as [])"), 'signal change re-probes')
assert(network.isMobileStatusEvent("/org/freedesktop/ModemManager1/Modem/0: org.freedesktop.DBus.Properties.PropertiesChanged ('org.freedesktop.ModemManager1.Modem.Modem3gpp', {'OperatorName': <'Carrier'>}, @as [])"), 'operator change re-probes')
assert(!network.isMobileStatusEvent("/org/freedesktop/ModemManager1/Bearer/1: org.freedesktop.DBus.Properties.PropertiesChanged ('org.freedesktop.ModemManager1.Bearer', {'Stats': <{'duration': <uint32 5>}>}, @as [])"), 'bearer traffic counters do not re-probe')
assert(!network.isMobileStatusEvent('Monitoring signals from all objects owned by org.freedesktop.ModemManager1'), 'gdbus banner does not re-probe')
JS

# The probe itself, against stub nmcli/mmcli: two modems, and saved profiles
# for each, so every value must come from the one the row shows.
probe=$(mktemp -d)
trap 'rm -rf -- "$probe"' EXIT
node -e "process.stdout.write(require(process.argv[1]).mobileStatusScript)" "$ROOT/shell/plugins/panels/network/Model.js" > "$probe/probe.sh"
cat > "$probe/nmcli" <<'SH'
#!/bin/bash
case $* in
  "-t -f DEVICE,TYPE dev") printf 'ttyUSB0:gsm\ncdc-wdm1:gsm\n' ;;
  "-e no -t -f GENERAL.STATE,GENERAL.CONNECTION,GENERAL.CON-UUID,GENERAL.IP-IFACE,GENERAL.UDI dev show ttyUSB0")
    printf 'GENERAL.STATE:30 (disconnected)\nGENERAL.CONNECTION:\nGENERAL.CON-UUID:\nGENERAL.IP-IFACE:\nGENERAL.UDI:/org/freedesktop/ModemManager1/Modem/3\n' ;;
  "-t radio wwan") [[ ${LC_ALL:-} == C ]] && printf 'disabled\n' || printf 'deaktiviert\n' ;;
  "-g UUID,TYPE con show") printf 'other-uuid:gsm\nwifi-uuid:802-11-wireless\nmine-uuid:gsm\n' ;;
  "-e no -g connection.interface-name con show uuid other-uuid") printf 'cdc-wdm1\n' ;;
  "-e no -g connection.interface-name con show uuid mine-uuid") printf 'cdc-wdm0\n' ;;
  "-e no -g connection.id con show uuid mine-uuid") printf 'Work:LTE\n' ;;
  *) exit 1 ;;
esac
SH
cat > "$probe/mmcli" <<'SH'
#!/bin/bash
[[ $* == "-m /org/freedesktop/ModemManager1/Modem/3 -K" ]] || { printf 'modem.3gpp.operator-name : Wrong Carrier\n'; exit 0; }
printf 'modem.generic.ports.value[1]                    : cdc-wdm0 (mbim)\n'
printf 'modem.generic.ports.value[2]                    : ttyUSB0 (at)\n'
printf 'modem.generic.ports.value[3]                    : wwan0 (net)\n'
printf 'modem.3gpp.operator-name                        : Right Carrier\n'
printf 'modem.generic.signal-quality.value              : 61\n'
SH
chmod +x "$probe/nmcli" "$probe/mmcli"
probed=$(LC_ALL=POSIX PATH="$probe:$PATH" bash "$probe/probe.sh")
[[ $probed == *$'profile_uuid\tmine-uuid\n'* ]] || fail "probe skips a profile bound to the other modem and matches one bound to this modem's MBIM port" "$probed"
[[ $probed == *$'profile\tWork:LTE'* ]] || fail "profile names are read without nmcli escapes" "$probed"
[[ $probed == *$'radio\tdisabled'* ]] || fail "radio state is read in the C locale" "$probed"
[[ $probed == *$'operator\tRight Carrier'* && $probed != *Wrong* ]] || fail "modem details come from this device's ModemManager object" "$probed"
pass "mobile probe describes only the modem the row shows"

require_compositor "network mobile broadband runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage" "$probe"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/network-mobile"
mkdir -p "$stage/network" "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp -r "$fixture/mocks" "$stage/mocks"
cp "$fixture/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/network/Model.js" "$stage/network/Model.js"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Replace only the singleton and expose private IDs in the disposable copy.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
source = source.replace('      id: keyCatcher\n', `      id: keyCatcher
      property alias testTitle: heroSsid
      property alias testMobileRow: mobileRow
`)
source = source.replace('  id: root', `  id: root
  function testEnsureContent() { return panel.ensureContent() }
  readonly property Item testKeys: panel.loadedContent
  readonly property Item testTitle: panel.loadedContent ? panel.loadedContent.testTitle : null
  readonly property Item testMobileRow: panel.loadedContent ? panel.loadedContent.testMobileRow : null`)
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
printf '#!/bin/bash\nexit 0\n' > "$stage/bin/noop"
chmod +x "$stage/bin/noop"
for command in omarchy-dns omarchy-network-band; do
  ln -s noop "$stage/bin/$command"
done

# The modem lives in a state file the stubs share, so the host's
# NetworkManager and ModemManager are never queried or changed.
printf 'disconnected\n' > "$stage/modem-state"
cat > "$stage/bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$NETWORK_TEST_LOG"
state=$(<"$NETWORK_TEST_STATE")
case $* in
  "-t -f DEVICE,TYPE dev")
    printf 'test-wifi:wifi\ncdc-wdm0:gsm\n'
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

output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" NETWORK_TEST_SCREENSHOT="${NETWORK_TEST_SCREENSHOT:-}" \
  NETWORK_TEST_LOG="$stage/commands.log" NETWORK_TEST_STATE="$stage/modem-state" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network mobile fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "network mobile runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "network mobile fixture has no QML errors" "$output"
fi
log=$(<"$stage/commands.log")
[[ $log == *"gdbus monitor --system --dest org.freedesktop.ModemManager1"* ]] || fail "panel follows ModemManager's signals" "$log"
(( $(grep -c '^gdbus ' <<< "$log") == 1 )) || fail "one ModemManager stream per panel" "$log"
[[ $log == *"device disconnect cdc-wdm0"* ]] || fail "disconnect targets the modem device" "$log"
[[ $log == *$'radio wwan on\n--wait 45 connection up uuid mobile-uuid ifname cdc-wdm0'* ]] || fail "connect turns the radio on, then brings the profile up by UUID on the modem's device" "$log"
pass "network panel shows the modem, follows ModemManager events, and connects and disconnects it"
