#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')

// scannerEnabled lives on a shared WifiDevice with no reference counting, so
// the panel has to own what it enabled. Run the helper's own JavaScript against
// stand-in devices: the two invariants it carries are that a closed panel never
// takes a device, and that adopting a new one releases the previous.
const scannerHelper = panelSource.match(/function setScannerEnabled\(enabled\) \{[\s\S]*?\n {2}\}/)
assert(scannerHelper, 'network has a scanner ownership helper')

var opened = false
var wifiDevice = { scannerEnabled: false }
var scannerDevice = null
eval(scannerHelper[0])

setScannerEnabled(true)
assert(
  scannerDevice === null && wifiDevice.scannerEnabled === false,
  'network does not let a closed panel claim or enable a scanner device'
)

var previousScannerDevice = { scannerEnabled: true }
var replacementScannerDevice = { scannerEnabled: false }
opened = true
scannerDevice = previousScannerDevice
wifiDevice = replacementScannerDevice
setScannerEnabled(true)
assert(
  previousScannerDevice.scannerEnabled === false &&
    scannerDevice === replacementScannerDevice &&
    replacementScannerDevice.scannerEnabled === true,
  'network releases the previous scanner device before enabling its replacement'
)

assertDeepEqual(
  network.parseNetworkStatus('wifi\tCafe WiFi\t78\t5200\n'),
  { kind: 'wifi', label: 'Cafe WiFi', signalStrength: 78, frequency: '5200' },
  'network parses bar status'
)
assertEqual(network.connectionIcon('wifi', 80), network.wifiIconFor(80), 'network maps wifi icon from signal')

// NetworkManager's two dBm-to-strength formulas (scan results, and the
// connected access point's station refresh) must not change the bars for the
// same link, and a strong -50 dBm link shows full bars either way.
const scanStrength = dbm => Math.round(100 - (Math.abs(Math.min(Math.max(dbm, -100), -40) + 40) * 100) / 60)
const stationStrength = dbm => Math.min(Math.max(dbm, -90), -20) + 120
for (const dbm of [-44, -50, -56, -66, -70, -74, -82, -88]) {
  assertEqual(network.wifiIconFor(stationStrength(dbm)), network.wifiIconFor(scanStrength(dbm)), `network shows the same bars for ${dbm} dBm from either NetworkManager formula`)
}
assertEqual(network.wifiIconFor(stationStrength(-50)), network.wifiIconFor(100), 'network shows full bars for a -50 dBm link')

// OWE transition mode: between scans NetworkManager files the in-use access
// point under the hidden "_owetm_" SSID and drops the active profile from the
// device's AvailableConnections, so Quickshell lists no connected network. The
// bar trusts the device's own state and reads the in-use AP's strength instead
// of flickering to disconnected.
assertEqual(network.connectedSignalStrength(0.8, 40), 80, 'network prefers the connected network strength')
assertEqual(network.connectedSignalStrength(0, 67), 67, 'network falls back to the in-use access point strength')
assertEqual(network.connectedSignalStrength(0, -1), 0, 'network reports no strength when the in-use access point is unknown')
assertEqual(network.parseActiveApSignal(' :82\n*:67\n :50\n'), 67, 'network parses the in-use access point strength from nmcli')
assertEqual(network.parseActiveApSignal(' :82\n'), -1, 'network reports no in-use access point when none is marked')
assertEqual(network.parseActiveApSignal(''), -1, 'network tolerates empty nmcli output')
assertEqual(network.formatHeaderSpeed('1000'), '1gbit', 'network formats gigabit speed')
assertEqual(network.formatHeaderSpeed('2500'), '2.5gbit', 'network formats fractional gigabit speed')
assertEqual(network.formatHeaderFreq('2462'), '2.4ghz', 'network formats 2.4GHz wifi band')
assertEqual(network.formatHeaderFreq('5200'), '5ghz', 'network formats 5GHz wifi band')
assertEqual(network.formatHeaderFreq('6455.0'), '6ghz', 'network formats 6GHz wifi band')
assertEqual(network.formatHeaderFreq('18300'), '18.3ghz', 'network falls back to exact GHz for unknown bands')
assertEqual(network.headerDetail({ type: 'ethernet', speed: '100' }), '100mbit', 'network header uses ethernet speed')

assertDeepEqual(
  network.parseKeyValue('iface\twlan0\nrx_bytes\t100\ntx_bytes\t50\n'),
  { iface: 'wlan0', rx_bytes: '100', tx_bytes: '50' },
  'network parses detail key values'
)
assertEqual(network.decodeIwSsid('Cafe\\xe2\\x80\\x99'), 'Cafe’', 'network decodes UTF-8 SSID bytes')
assertEqual(network.decodeIwSsid('Smile \\xf0\\x9f\\x98\\x80'), 'Smile 😀', 'network decodes emoji SSID bytes')
assertEqual(network.decodeIwSsid('\\x20Cafe\\x20'), ' Cafe ', 'network preserves edge spaces in SSIDs')
assertEqual(network.decodeIwSsid('slash\\x5cname'), 'slash\\name', 'network decodes SSID backslashes once')
assertEqual(network.decodeIwSsid('invalid\\xff'), 'invalid\\xff', 'network preserves invalid UTF-8 escapes')
assertEqual(network.decodeIwSsid('already 😀'), 'already 😀', 'network safely preserves unexpected non-BMP input')
assertDeepEqual(
  network.parseKeyValue('ssid\tline\\x0abreak\\x09tab\\x00nul\nsignal_dbm\t-40\n'),
  { ssid: 'line\\x0abreak\\x09tab\\x00nul', signal_dbm: '-40' },
  'network leaves control-byte escapes safe for single-line display'
)
assertDeepEqual(
  network.throughputState({ prevIface: '', prevSampleTime: 0 }, { iface: 'wlan0', rx_bytes: '100', tx_bytes: '50' }, 10),
  { prevIface: 'wlan0', prevRxBytes: 100, prevTxBytes: 50, prevSampleTime: 10, downloadRate: 0, uploadRate: 0 },
  'network seeds throughput state on first sample'
)
assertDeepEqual(
  network.throughputState({ prevIface: 'wlan0', prevRxBytes: 100, prevTxBytes: 50, prevSampleTime: 10 }, { iface: 'wlan0', rx_bytes: '300', tx_bytes: '90' }, 12),
  { prevIface: 'wlan0', prevRxBytes: 300, prevTxBytes: 90, prevSampleTime: 12, downloadRate: 100, uploadRate: 20 },
  'network computes throughput deltas'
)

let ping = network.pingLatencyState(
  { pingIface: '', routerPingSamples: [], internetPingSamples: [] },
  { iface: 'wlan0', router_ping_ms: '2.0', internet_ping_ms: '20.0' },
  4
)
assertDeepEqual(
  ping,
  { pingIface: 'wlan0', routerPingSamples: [2], internetPingSamples: [20], routerPingLatency: 2, internetPingLatency: 20, internetPingPacketLoss: 0 },
  'network seeds ping latency samples'
)

ping = network.pingLatencyState(ping, { iface: 'wlan0', router_ping_ms: '4.0', internet_ping_ms: '' }, 4)
assertDeepEqual(
  ping,
  { pingIface: 'wlan0', routerPingSamples: [2, 4], internetPingSamples: [20, null], routerPingLatency: 3, internetPingLatency: 20, internetPingPacketLoss: 50 },
  'network averages recent successful ping samples'
)

assertDeepEqual(
  network.pingLatencyState(ping, { iface: 'eth0', router_ping_ms: '1.5', internet_ping_ms: '10.0' }, 4),
  { pingIface: 'eth0', routerPingSamples: [1.5], internetPingSamples: [10], routerPingLatency: 1.5, internetPingLatency: 10, internetPingPacketLoss: 0 },
  'network resets ping samples when interface changes'
)

assertDeepEqual(
  network.pingLatencyState(ping, { iface: 'wlan0', internet_ping_ms: '22.0' }, 4),
  { pingIface: 'wlan0', routerPingSamples: [], internetPingSamples: [20, null, 22], routerPingLatency: -1, internetPingLatency: 21, internetPingPacketLoss: 33 },
  'network clears ping samples when a target is unavailable'
)

assertEqual(network.formatBytes(1536), '1.5 KB', 'network formats bytes')
assertEqual(network.formatRate(1536), '1.5 KB/s', 'network formats rates')
assertEqual(network.formatPingLatency('2.54'), '2.5 ms', 'network formats low ping with precision')
assertEqual(network.formatPingLatency('25.4'), '25 ms', 'network formats ping')
assertEqual(network.formatPingLatency(''), 'Timeout', 'network formats missing ping as timeout')
assertEqual(network.formatPingLatency(-1, false), '--', 'network holds the ping row before the first sample')
assertEqual(network.formatPingLatency('25.4', true), '25 ms', 'network formats ping once samples exist')
assertEqual(network.formatPingLatency('', true), 'Timeout', 'network still reports a timeout among real samples')
assertEqual(network.formatPacketLoss(2), '2%', 'network formats packet loss')
assertEqual(network.formatPacketLoss(0), '0%', 'network formats zero packet loss')
assertEqual(network.formatPacketLoss(0, false), '--', 'network holds the packet loss row before the first sample')
assertEqual(network.formatPacketLoss(0, true), '0%', 'network reports zero loss once samples exist')
assertEqual(network.internetPingReadable([], 'full'), false, 'network hides ping before the first sample')
assertEqual(network.internetPingReadable([null, null], 'full'), true, 'network still reports lost probes on a working connection')
assertEqual(network.internetPingReadable([null, 12], 'full'), true, 'network shows ping once a probe comes back')
assertEqual(network.internetPingReadable([12], 'portal'), false, 'network hides ping behind a captive portal')
assertEqual(network.internetPingReadable([12], 'limited'), false, 'network hides ping on a limited connection')
assertEqual(network.internetPingReadable([12], 'none'), false, 'network hides ping when offline')
assertEqual(network.internetPingReadable([12], 'unknown'), true, 'network shows ping when connectivity checks are off')

const rows = network.sortWifiRows([
  { ssid: 'Open', connected: false, known: false, signal: 95 },
  { ssid: 'Known', connected: false, known: true, signal: 10 },
  { ssid: 'Connected', connected: true, known: true, signal: 20 }
])
assertDeepEqual(rows.map(row => row.ssid), ['Connected', 'Known', 'Open'], 'network sorts wifi rows by connection and known state')
assertDeepEqual(
  network.sortWifiRows([
    { ssid: 'Fresh', connected: false, known: false, signal: 99 },
    { ssid: 'Weak', connected: false, known: false, signal: 90 },
    { ssid: 'Strong', connected: false, known: false, signal: 10 },
    { ssid: 'Known', connected: false, known: true, signal: 5 }
  ], [
    { ssid: 'Known', connected: false, known: true, signal: 5 },
    { ssid: 'Strong', connected: false, known: false, signal: 80 },
    { ssid: 'Gone', connected: false, known: false, signal: 70 },
    { ssid: 'Weak', connected: false, known: false, signal: 30 }
  ]).map(row => row.ssid + ':' + row.signal),
  ['Known:5', 'Strong:80', 'Weak:30', 'Fresh:99'],
  'network holds the wifi rows on screen in place, with their signal, while a passphrase prompt is open'
)
assertDeepEqual(
  network.sortWifiRows([
    { ssid: 'hasOwnProperty', connected: false, known: false, signal: 10 },
    { ssid: 'Other', connected: false, known: false, signal: 90 }
  ], [
    { ssid: 'hasOwnProperty', connected: false, known: false, signal: 50 }
  ]).map(row => row.ssid),
  ['hasOwnProperty', 'Other'],
  'network holds wifi rows whatever their SSID, even one named like an Object method'
)
assertEqual(network.wifiSectionTitle(rows, 0), 'KNOWN NETWORKS', 'network labels known wifi section')
assertEqual(network.wifiSectionTitle(rows, 2), 'OTHER NETWORKS', 'network labels other wifi section')

const wifiRow = network.wifiRow({ connected: true, known: true, name: 'Home', signalStrength: 0.8, security: 1 })
assertDeepEqual(
  wifiRow,
  { connected: true, known: true, ssid: 'Home', signal: 80, security: 1 },
  'network projects wifi rows with primitives so delegates never hold the live WifiNetwork object'
)
assertDeepEqual(
  Object.keys(wifiRow).sort(),
  ['connected', 'known', 'security', 'signal', 'ssid'],
  'network wifi rows project exactly the primitive fields, so each delegate stores no live QObject'
)

const security = {
  Wpa3SuiteB192: 0,
  Sae: 1,
  Wpa2Eap: 2,
  Wpa2Psk: 3,
  WpaEap: 4,
  WpaPsk: 5,
  StaticWep: 6,
  DynamicWep: 7,
  Leap: 8,
  Owe: 9,
  Open: 10,
  Unknown: 11
}
for (const name of ['Wpa3SuiteB192', 'Sae', 'Wpa2Eap', 'Wpa2Psk', 'WpaEap', 'WpaPsk', 'StaticWep', 'DynamicWep', 'Leap', 'Unknown']) {
  assertEqual(network.requiresCredentials(security[name], security.Open, security.Owe), true, 'network asks for ' + name + ' credentials')
}
assertEqual(network.requiresCredentials(security.Owe, security.Open, security.Owe), false, 'network does not ask for OWE credentials')
assertEqual(network.requiresCredentials(security.Open, security.Open, security.Owe), false, 'network does not ask for open-network credentials')

const reasons = { NoSecrets: 1, WifiAuthTimeout: 2, WifiNetworkLost: 3, WifiClientDisconnected: 4, WifiClientFailed: 5 }
assertEqual(network.networkFailureReason(reasons.NoSecrets, true, reasons), 'Passphrase required', 'network maps missing credential failures')
assertEqual(network.networkFailureReason(reasons.WifiAuthTimeout, true, reasons), 'Wrong password', 'network maps credentialed auth timeouts')
assertEqual(network.networkFailureReason(reasons.WifiAuthTimeout, true, reasons, undefined, true), 'Connection timed out', 'network does not call enterprise timeouts a wrong password')
assertEqual(network.networkFailureReason(reasons.NoSecrets, false, reasons), 'Failed to connect', 'network gives passwordless missing-secret failures generic copy')
assertEqual(network.networkFailureReason(reasons.WifiAuthTimeout, false, reasons), 'Failed to connect', 'network gives passwordless auth timeouts generic copy')
assertEqual(network.networkFailureReason(99, true, reasons), 'Failed to connect', 'network maps unknown failures')
assertEqual(network.canForgetNetwork({ known: true, connected: false, security: security.Owe }), true, 'network can forget known disconnected OWE networks')
assertEqual(network.canForgetNetwork({ known: true, connected: false, security: security.Open }), true, 'network can forget known disconnected open networks')
assertEqual(network.canForgetNetwork({ known: false, connected: false, security: security.Owe }), false, 'network cannot forget unknown networks')
assertEqual(network.canForgetNetwork({ known: true, connected: true, security: security.Owe }), false, 'network cannot forget the connected network')

assertEqual(network.shouldRepromptPassphrase(reasons.NoSecrets, true, reasons), true, 'network reprompts when required credentials are missing')
assertEqual(network.shouldRepromptPassphrase(reasons.NoSecrets, false, reasons), false, 'network does not ask a passwordless network for missing secrets')
assertEqual(network.shouldRepromptPassphrase(reasons.WifiAuthTimeout, true, reasons), true, 'network reprompts a credentialed network after a wrong password')
assertEqual(network.shouldRepromptPassphrase(reasons.WifiAuthTimeout, false, reasons), false, 'network does not reprompt an open network on auth timeout')
assertEqual(network.shouldRepromptPassphrase(reasons.WifiClientFailed, true, reasons), false, 'network does not reprompt on generic connection failures')

assertEqual(network.bandLabel('2.4'), '2.4ghz', 'network labels the 2.4GHz band')
assertEqual(network.bandLabel('6'), '6ghz', 'network labels the 6GHz band')
assertEqual(network.bandLabel('auto'), 'Auto', 'network labels the automatic band choice')

assertEqual(network.bandSectionTitle('auto', '2.4'), 'WI-FI BAND: 2.4GHZ', 'network names the live band in the header under automatic')
assertEqual(network.bandSectionTitle('auto', ''), 'WI-FI BAND', 'network omits an unknown band from the header')
assertEqual(network.bandSectionTitle('5', '5'), 'WI-FI BAND', 'network drops the header band once the pills are showing')
assertEqual(network.bandSectionTitle('5', '2.4'), 'WI-FI BAND', 'network keeps a plain header while a pin is settling')

assertDeepEqual(
  network.parseBandStatus('band\t5\navailable\t2.4 5 6\nselected\tauto\n'),
  { band: '5', selected: 'auto', available: ['2.4', '5', '6'] },
  'network parses band status'
)
assertDeepEqual(
  network.parseBandStatus(''),
  { band: '', selected: 'auto', available: [] },
  'network parses empty band status without a wifi connection'
)

assertEqual(network.headerDetail({ type: 'wifi', freq: '5745' }), '', 'network keeps wifi band state out of the hero')
assertEqual(network.headerDetail({ type: 'ethernet', speed: '100' }), '100mbit', 'network keeps ethernet speed in the hero')
JS

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/nmcli"
cat >"$tmpdir/bin/rfkill" <<'SH'
#!/bin/bash
if [[ $* == *"--output HARD"* ]]; then
  [[ $LC_ALL == "C" ]] || exit 2
  printf '%s\n' "$HARD_BLOCKS"
fi
SH
chmod +x "$tmpdir/bin/"*
PATH="$tmpdir/bin:$PATH" HARD_BLOCKS=unblocked "$ROOT/bin/omarchy-restart-wifi" >"$tmpdir/output" 2>&1 ||
  fail "Wi-Fi restart accepts radios without a hard block" "$(cat "$tmpdir/output")"
status=0
PATH="$tmpdir/bin:$PATH" HARD_BLOCKS=$'unblocked\nblocked' "$ROOT/bin/omarchy-restart-wifi" >"$tmpdir/output" 2>&1 || status=$?
(( status == 1 )) && grep -q "still hardware-blocked" "$tmpdir/output" ||
  fail "Wi-Fi restart reports a remaining hardware block" "status=$status: $(cat "$tmpdir/output")"
pass "Wi-Fi restart distinguishes unblocked and hardware-blocked radios"

rm -rf "$tmpdir"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/state"
export NMCLI_STATE=$tmp/state

cat >"$tmp/bin/nmcli" <<'EOF'
#!/bin/bash
set -euo pipefail
state=${NMCLI_STATE:?}
echo "$*" >>"$state/log"

profile_get() {
  local uuid=$1
  local key=$2
  local file=$state/profile.$uuid
  [[ -f $file ]] || return 0
  awk -F= -v k="$key" '$1 == k { print substr($0, index($0, "=") + 1); exit }' "$file"
}

profile_set() {
  local uuid=$1
  local key=$2
  local value=$3
  local file=$state/profile.$uuid
  local tmpf=$state/profile.$uuid.tmp
  if [[ -f $file ]]; then
    awk -F= -v k="$key" '$1 != k { print }' "$file" >"$tmpf"
  else
    : >"$tmpf"
  fi
  printf '%s=%s\n' "$key" "$value" >>"$tmpf"
  mv "$tmpf" "$file"
}

if [[ $1 == "-t" && $2 == "-f" && $3 == "UUID,TYPE" ]]; then
  while IFS= read -r uuid; do
    [[ -n $uuid ]] || continue
    printf '%s:802-11-wireless\n' "$uuid"
  done <"$state/wifi-uuids"
  exit 0
fi

# nmcli -g escapes : and \ by default; -e no returns the raw SSID.
escape_nmcli_value() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//:/\\:}
  printf '%s\n' "$value"
}

if [[ $1 == "-e" && $2 == "no" && $3 == "-g" && $5 == "connection" && $6 == "show" && $7 == "uuid" ]]; then
  case "$4" in
    802-11-wireless.ssid) profile_get "$8" ssid ;;
    802-11-wireless-security.key-mgmt) profile_get "$8" key-mgmt ;;
  esac
  exit 0
fi

if [[ $1 == "-g" && $3 == "connection" && $4 == "show" && $5 == "uuid" ]]; then
  case "$2" in
    802-11-wireless.ssid) escape_nmcli_value "$(profile_get "$6" ssid)" ;;
    802-11-wireless-security.key-mgmt) profile_get "$6" key-mgmt ;;
  esac
  exit 0
fi

if [[ $1 == "connection" && $2 == "add" ]]; then
  uuid=""
  ssid=""
  identity=""
  i=1
  while (( i <= $# )); do
    arg=${!i}
    if [[ $arg == connection.uuid ]]; then
      (( i++ ))
      uuid=${!i}
    elif [[ $arg == ssid ]]; then
      (( i++ ))
      ssid=${!i}
    elif [[ $arg == 802-1x.identity ]]; then
      (( i++ ))
      identity=${!i}
    fi
    (( i++ )) || true
  done
  [[ -n $uuid && -n $ssid ]] || exit 1
  printf '%s\n' "$uuid" >>"$state/wifi-uuids"
  cat >"$state/profile.$uuid" <<PROF
ssid=$ssid
key-mgmt=wpa-eap
identity=$identity
created=1
PROF
  echo "$uuid" >"$state/last-created"
  exit 0
fi

if [[ $1 == "connection" && $2 == "edit" && $3 == "uuid" ]]; then
  uuid=$4
  while IFS= read -r line; do
    case "$line" in
      "set 802-1x.identity "*) profile_set "$uuid" identity "${line#set 802-1x.identity }" ;;
      "set 802-1x.password "*) profile_set "$uuid" password "${line#set 802-1x.password }" ;;
      save|quit) ;;
      *) ;;
    esac
  done
  exit 0
fi

if [[ $1 == "connection" && $2 == "up" && $3 == "uuid" ]]; then
  uuid=$4
  if [[ -f $state/fail-up ]]; then
    exit 1
  fi
  echo "$uuid" >"$state/last-up"
  exit 0
fi

if [[ $1 == "connection" && $2 == "delete" && $3 == "uuid" ]]; then
  uuid=$4
  echo "$uuid" >>"$state/deleted"
  rm -f "$state/profile.$uuid"
  if [[ -f $state/wifi-uuids ]]; then
    grep -vxF "$uuid" "$state/wifi-uuids" >"$state/wifi-uuids.tmp" || true
    mv "$state/wifi-uuids.tmp" "$state/wifi-uuids"
  fi
  exit 0
fi

echo "unexpected nmcli: $*" >&2
exit 99
EOF
chmod +x "$tmp/bin/nmcli"

seed() {
  printf '%s\n' "$1" >>"$tmp/state/wifi-uuids"
  cat >"$tmp/state/profile.$1" <<PROF
ssid=$2
key-mgmt=$3
identity=${4:-}
PROF
}

profile_field() {
  awk -F= -v k="$2" '$1 == k { print substr($0, index($0, "=") + 1); exit }' "$tmp/state/profile.$1"
}

script=$(node -e "const m=require('$ROOT/shell/plugins/panels/network/Model.js'); process.stdout.write(m.enterpriseConnectScript)")

run_script() {
  local ssid=$1 identity=$2 password=$3
  PATH="$tmp/bin:$PATH" bash -c "$script" nmcli-eap "$ssid" "$identity" <<<"$password"
}

: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
rm -f "$tmp/state/deleted" "$tmp/state/last-up" "$tmp/state/last-created" "$tmp/state/fail-up"
seed cat-eduroam eduroam wpa-eap user@school.edu
seed home-psk HomeNet wpa-psk

run_script eduroam user@school.edu 's3cret'
[[ $(<"$tmp/state/last-up") == cat-eduroam ]] || fail "reuses the existing wpa-eap profile UUID" "up=$(cat "$tmp/state/last-up" 2>/dev/null || true)"
[[ ! -e $tmp/state/last-created ]] || fail "does not create a second profile when one exists"
[[ $(profile_field cat-eduroam password) == s3cret ]] || fail "updates the password on the existing profile"
[[ $(profile_field cat-eduroam identity) == user@school.edu ]] || fail "updates the identity on the existing profile"
[[ ! -e $tmp/state/deleted ]] || fail "never deletes a pre-existing enterprise profile"
pass "reuses an existing wpa-eap profile"

: >"$tmp/state/log"
rm -f "$tmp/state/last-up" "$tmp/state/last-created" "$tmp/state/deleted"
run_script campus campus-user 'newpass'
created=$(cat "$tmp/state/last-created")
[[ -n $created ]] || fail "creates a profile when none exists for the SSID"
[[ $(<"$tmp/state/last-up") == "$created" ]] || fail "activates the newly created profile"
[[ $(profile_field "$created" password) == newpass ]] || fail "stores the password on the new profile"
pass "creates a minimal profile when none exists"

: >"$tmp/state/log"
rm -f "$tmp/state/last-up" "$tmp/state/last-created" "$tmp/state/deleted"
touch "$tmp/state/fail-up"
seed keep-me keepme wpa-eap keep@school.edu
status=0
run_script keepme keep@school.edu 'bad' || status=$?
(( status != 0 )) || fail "failed activation exits non-zero"
[[ ! -e $tmp/state/deleted ]] || fail "failed activation does not delete a pre-existing profile" "$(cat "$tmp/state/deleted" 2>/dev/null || true)"
[[ -f $tmp/state/profile.keep-me ]] || fail "pre-existing profile survives a failed reconnect"
pass "failed reconnect keeps the institutional profile"

rm -f "$tmp/state/fail-up"
: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
rm -f "$tmp/state"/profile.* "$tmp/state/deleted" "$tmp/state/last-up" "$tmp/state/last-created"
touch "$tmp/state/fail-up"
status=0
run_script brand-new brand-user 'pw' || status=$?
(( status != 0 )) || fail "failed activation of a new profile exits non-zero"
created=$(cat "$tmp/state/last-created" 2>/dev/null || true)
[[ -n $created ]] || fail "records the UUID it created before activation failed"
grep -qxF "$created" "$tmp/state/deleted" || fail "failed activation deletes only the profile this attempt created" "deleted=$(cat "$tmp/state/deleted" 2>/dev/null || true)"
[[ ! -f $tmp/state/profile.$created ]] || fail "created profile file is gone after cleanup"
pass "failed brand-new connect cleans up its own UUID"

# Default nmcli -g escaping would turn these into Campus\:Secure / Campus\\Secure
# and miss the existing profile. The helper must query with -e no.
: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
rm -f "$tmp/state"/profile.* "$tmp/state/deleted" "$tmp/state/last-up" "$tmp/state/last-created" "$tmp/state/fail-up"
seed cat-colon 'Campus:Secure' wpa-eap user@campus.edu
run_script 'Campus:Secure' user@campus.edu 's3cret'
[[ $(<"$tmp/state/last-up") == cat-colon ]] || fail "reuses a profile whose SSID contains a colon" "up=$(cat "$tmp/state/last-up" 2>/dev/null || true)"
[[ ! -e $tmp/state/last-created ]] || fail "does not synthesize a second profile for a colon SSID"
pass "reuses an existing profile when the SSID contains a colon"

: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
rm -f "$tmp/state"/profile.* "$tmp/state/deleted" "$tmp/state/last-up" "$tmp/state/last-created"
seed cat-backslash 'Campus\Secure' wpa-eap user@campus.edu
run_script 'Campus\Secure' user@campus.edu 's3cret'
[[ $(<"$tmp/state/last-up") == cat-backslash ]] || fail "reuses a profile whose SSID contains a backslash" "up=$(cat "$tmp/state/last-up" 2>/dev/null || true)"
[[ ! -e $tmp/state/last-created ]] || fail "does not synthesize a second profile for a backslash SSID"
pass "reuses an existing profile when the SSID contains a backslash"
