#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const wifiqr = requireFromRoot('shell/plugins/panels/wifiqr/Model.js')

assertDeepEqual(
  wifiqr.parseQrOutput('meta\twlan0\tWPA\tCafe WiFi\n010\n111\n010\n'),
  { meta: { iface: 'wlan0', security: 'WPA', ssid: 'Cafe WiFi' }, matrix: { rows: ['010', '111', '010'], size: 3 } },
  'wifiqr parses the meta header and a square matrix'
)
assertDeepEqual(
  wifiqr.parseQrOutput('meta\twlan0\tnopass\tTab\tName\n010\n111\n010\n').meta.ssid,
  'Tab\tName',
  'wifiqr keeps tabs inside the SSID field'
)
assertDeepEqual(
  wifiqr.parseQrOutput('010\n111\n010\n'),
  { meta: { iface: '', security: '', ssid: '' }, matrix: { rows: ['010', '111', '010'], size: 3 } },
  'wifiqr tolerates output without a meta header'
)
assertDeepEqual(wifiqr.parseQrOutput('meta\twlan0\tWPA\tCafe\n01\n111\n').matrix, { rows: [], size: 0 }, 'wifiqr rejects ragged QR rows')
assertDeepEqual(wifiqr.parseQrOutput('010\n101\n').matrix, { rows: [], size: 0 }, 'wifiqr rejects a non-square QR matrix')
assertDeepEqual(wifiqr.parseQrOutput('010\n1x1\n010\n').matrix, { rows: [], size: 0 }, 'wifiqr rejects invalid QR modules')

assertDeepEqual(
  wifiqr.parseWifiQr('WIFI:T:WPA;S:Cafe\\;Guest\\\\5G;P:p\\,a\\:ss\\;word\\\\42;;'),
  { valid: true, ssid: 'Cafe;Guest\\5G', password: 'p,a:ss;word\\42', security: 'WPA', hidden: false },
  'wifiqr unescapes WIFI QR credentials'
)
assertDeepEqual(
  wifiqr.parseWifiQr('WIFI:T:SAE;S:ModernNet;P:wpa3secret;H:true;;'),
  { valid: true, ssid: 'ModernNet', password: 'wpa3secret', security: 'SAE', hidden: true },
  'wifiqr parses WPA3 SAE hidden network QR'
)
assertDeepEqual(
  wifiqr.parseWifiQr('WIFI:T:nopass;S:OpenLobby;P:;;'),
  { valid: true, ssid: 'OpenLobby', password: '', security: 'nopass', hidden: false },
  'wifiqr parses open network QR'
)
assertDeepEqual(
  wifiqr.parseWifiQr('WIFI:T:OWE;S:EnhancedLobby;;'),
  { valid: true, ssid: 'EnhancedLobby', password: '', security: 'OWE', hidden: false },
  'wifiqr preserves OWE mode distinctly from plain open networks'
)
assertDeepEqual(
  wifiqr.parseWifiQr('https://omarchy.org'),
  { valid: false, reason: 'notWifi' },
  'wifiqr rejects non-WIFI QR payloads'
)
assertDeepEqual(
  wifiqr.parseWifiQr('WIFI:T:WPA;S:LockedNet;;'),
  { valid: false, reason: 'missingPassword', ssid: 'LockedNet' },
  'wifiqr rejects secured QR without password'
)
assertDeepEqual(
  wifiqr.parseWifiQr('WIFI:T:WPA2-EAP;S:CorpNet;P:secret;;'),
  { valid: false, reason: 'enterpriseUnsupported', ssid: 'CorpNet' },
  'wifiqr rejects enterprise Wi-Fi QR payloads'
)
assertDeepEqual(
  wifiqr.parseScannerLine('qr\t' + Buffer.from('WIFI:T:WPA;S:Café ☕;P:clave123;;', 'utf8').toString('base64')),
  { type: 'qr', raw: 'WIFI:T:WPA;S:Café ☕;P:clave123;;' },
  'wifiqr decodes base64 UTF-8 scanner lines'
)
JS

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/runtime"

cat >"$tmp/bin/omarchy-hw-webcam" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$tmp/bin/omarchy-hw-webcam"

scan_out=$(PATH="$tmp/bin:$PATH" XDG_RUNTIME_DIR="$tmp/runtime" "$ROOT/shell/plugins/panels/wifiqr/scan-webcam-qr.sh" || true)
[[ $scan_out == $'error\tnoWebcam' ]] || fail "webcam scanner guards against missing webcam hardware" "actual: $scan_out"
pass "webcam scanner guards against missing webcam hardware"

cat >"$tmp/bin/nmcli" <<'EOF'
#!/bin/bash
for arg in "$@"; do
  [[ $arg != "topsecret123" ]] || exit 98
done
printf '%s\n' "$*" >>"$NMCLI_LOG_FILE"
if [[ $* == *"radio wifi"* ]]; then
  echo "enabled"
elif [[ $* == *"GENERAL.CON-UUID"* ]]; then
  echo "--"
elif [[ $* == *"UUID,TYPE connection show"* ]]; then
  printf 'other-adapter-uuid:802-11-wireless\nsaved-uuid-1:802-11-wireless\n'
elif [[ $* == *"802-11-wireless.ssid connection show uuid "* ]]; then
  echo "Cafe WiFi"
elif [[ $* == *"connection.interface-name connection show uuid other-adapter-uuid"* ]]; then
  echo "wlan1"
elif [[ $* == *"connection.interface-name connection show uuid saved-uuid-1"* ]]; then
  echo "wlan0"
elif [[ $* == *"connection edit"* ]]; then
  cat >"$NMCLI_STDIN_FILE"
elif [[ $* == *"connection up"* ]]; then
  exit "${NMCLI_UP_EXIT:-0}"
fi
exit 0
EOF
cat >"$tmp/bin/uuidgen" <<'EOF'
#!/bin/bash
echo "new-temp-uuid"
EOF
chmod +x "$tmp/bin/nmcli" "$tmp/bin/uuidgen"

export NMCLI_STDIN_FILE="$tmp/nmcli-stdin"
export NMCLI_LOG_FILE="$tmp/nmcli-log"

# 1. Successful connection: verifies via temp profile, then updates saved-uuid-1 in place without deleting saved profiles
: >"$NMCLI_LOG_FILE"
printf 'topsecret123\n' | NMCLI_UP_EXIT=0 PATH="$tmp/bin:$PATH" "$ROOT/shell/plugins/panels/wifiqr/connect-wifi-qr.sh" "Cafe WiFi" "WPA" "no" "wlan0"
[[ $(<"$NMCLI_STDIN_FILE") == $'set 802-11-wireless-security.psk topsecret123\nsave\nquit' ]] \
  || fail "connect helper sends the Wi-Fi passphrase over stdin rather than argv"
grep -qxF "connection modify uuid saved-uuid-1 wifi-sec.key-mgmt wpa-psk" "$NMCLI_LOG_FILE" \
  || fail "connect helper updates the matching saved profile in place after verification"
grep -qxF "connection delete uuid new-temp-uuid" "$NMCLI_LOG_FILE" \
  || fail "connect helper cleans up the temporary verification profile after updating the saved profile"
if grep -q "delete uuid saved-uuid-1\|delete uuid other-adapter-uuid\|modify uuid other-adapter-uuid" "$NMCLI_LOG_FILE"; then
  fail "connect helper must never delete saved profiles or touch another adapter's profile" "$(<"$NMCLI_LOG_FILE")"
fi
pass "connect helper verifies credentials on a temporary profile, updates the matching profile in place, and leaves other profiles intact"

# 2. Failed connection: deletes only the temporary profile and preserves saved-uuid-1
: >"$NMCLI_LOG_FILE"
if printf 'topsecret123\n' | NMCLI_UP_EXIT=1 PATH="$tmp/bin:$PATH" "$ROOT/shell/plugins/panels/wifiqr/connect-wifi-qr.sh" "Cafe WiFi" "SAE" "no" "wlan0" 2>/dev/null; then
  fail "connect helper fails when nmcli connection up fails"
fi
if grep -q "delete uuid saved-uuid-1\|modify uuid saved-uuid-1\|edit uuid saved-uuid-1" "$NMCLI_LOG_FILE"; then
  fail "failed scan must not modify or delete an existing saved profile" "$(<"$NMCLI_LOG_FILE")"
fi
if grep -q "wpa-psk" "$NMCLI_LOG_FILE"; then
  fail "explicit SAE scan must not downgrade to wpa-psk" "$(<"$NMCLI_LOG_FILE")"
fi
grep -qxF "connection delete uuid new-temp-uuid" "$NMCLI_LOG_FILE" \
  || fail "failed scan cleans up its temporary profile"
pass "failed SAE scan preserves existing saved profiles and never downgrades to WPA2"

# 3. OWE connection: configures wifi-sec.key-mgmt owe
: >"$NMCLI_LOG_FILE"
printf '\n' | NMCLI_UP_EXIT=0 PATH="$tmp/bin:$PATH" "$ROOT/shell/plugins/panels/wifiqr/connect-wifi-qr.sh" "EnhancedLobby" "OWE" "no" "wlan0"
grep -qxF "connection modify uuid new-temp-uuid wifi-sec.key-mgmt owe" "$NMCLI_LOG_FILE" \
  || fail "OWE scan configures wifi-sec.key-mgmt owe"
pass "OWE scan configures wifi-sec.key-mgmt owe"
