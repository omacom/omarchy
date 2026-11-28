#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
export QR_ROUTE_EXIT=0

# Loopback is never wireless, so exercise the connected-Wi-Fi fallback.
cat >"$tmp/bin/ip" <<'EOF'
#!/bin/bash
[[ $QR_ROUTE_EXIT == "0" ]] || exit "$QR_ROUTE_EXIT"
printf '1.1.1.1 dev lo\n'
EOF

cat >"$tmp/bin/nmcli" <<'EOF'
#!/bin/bash
if [[ $* == *"DEVICE,TYPE,STATE"* ]]; then
  printf 'eth0:ethernet:connected\nwlan0:wifi:connected\n'
elif [[ $* == *GENERAL.CON-UUID* ]]; then
  echo test-uuid
else
  printf '%s' "$QR_NMCLI_FIELDS"
fi
EOF

cat >"$tmp/bin/qrencode" <<'EOF'
#!/bin/bash
for arg in "$@"; do
  [[ $arg != WIFI:* ]] || exit 97
done
payload=$(</dev/stdin)
printf '%s' "$payload" >"$QR_PAYLOAD_FILE"
printf '##    \n  ##  \n    ##\n'
EOF
chmod +x "$tmp/bin/ip" "$tmp/bin/nmcli" "$tmp/bin/qrencode"

run_success_case() {
  local description=$1 fields=$2 expected_payload=$3
  shift 3
  local output meta matrix payload arg with_meta=false
  local expected_matrix expected_security expected_ssid expected_iface="wlan0"

  for arg in "$@"; do
    [[ $arg == "--meta" ]] && with_meta=true || expected_iface=$arg
  done

  export QR_NMCLI_FIELDS=$fields
  export QR_PAYLOAD_FILE="$tmp/payload"
  output=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-qr" "$@")

  expected_matrix=$'100\n010\n001'
  if [[ $with_meta == "true" ]]; then
    meta=$(head -n1 <<<"$output")
    matrix=$(tail -n +2 <<<"$output")

    # The metadata reports the requested interface, or the connected Wi-Fi
    # interface supplied by the nmcli stub when no interface was requested.
    expected_security=${expected_payload#WIFI:T:}
    expected_security=${expected_security%%;*}
    expected_ssid=$(head -n1 <<<"$fields")
    [[ $meta == meta$'\t'$expected_iface$'\t'"$expected_security"$'\t'"$expected_ssid" ]] \
      || fail "$description leads with the interface, security, and SSID" "actual: $meta"
  else
    matrix=$output
  fi
  [[ $matrix == "$expected_matrix" ]] || fail "$description emits a compact module matrix" "expected: $expected_matrix\nactual: $matrix"

  payload=$(<"$QR_PAYLOAD_FILE")
  [[ $payload == "$expected_payload" ]] || fail "$description generates the Wi-Fi payload" "expected: $expected_payload\nactual: $payload"
  pass "$description"
}

run_success_case \
  "network QR helper escapes WPA credentials through stdin" \
  $'Cafe;Guest\\5G\nwpa-psk\np,a:ss;word\\42\nno\n' \
  'WIFI:T:WPA;S:Cafe\;Guest\\5G;P:p\,a\:ss\;word\\42;;' \
  --meta wlan0

# Without --meta the output stays a bare matrix, which pre-plugin clones of
# the network widget still parse.
run_success_case \
  "network QR helper keeps the bare matrix without --meta" \
  $'Cafe;Guest\\5G\nwpa-psk\np,a:ss;word\\42\nno\n' \
  'WIFI:T:WPA;S:Cafe\;Guest\\5G;P:p\,a\:ss\;word\\42;;' \
  wlan0

# With no interface argument the helper finds the connected Wi-Fi device.
run_success_case \
  "network QR helper detects the Wi-Fi interface" \
  $'Cafe Detected\nwpa-psk\nsecret\nno\n' \
  'WIFI:T:WPA;S:Cafe Detected;P:secret;;' \
  --meta

QR_ROUTE_EXIT=2 run_success_case \
  "network QR helper detects Wi-Fi when route lookup fails" \
  $'Cafe No Route\nwpa-psk\nsecret\nno\n' \
  'WIFI:T:WPA;S:Cafe No Route;P:secret;;' \
  --meta

run_success_case \
  "network QR helper supports open networks" \
  $'Cafe Open\nnone\n\nno\n' \
  'WIFI:T:nopass;S:Cafe Open;P:;;' \
  --meta wlan0

run_success_case \
  "network QR helper marks hidden networks" \
  $'Hidden Network\nwpa-psk\nsecret\nyes\n' \
  'WIFI:T:WPA;S:Hidden Network;P:secret;H:true;;' \
  --meta wlan0

# NetworkManager models WEP as key-mgmt "none" plus a wep-key, which must not
# be mistaken for an open network.
run_success_case \
  "network QR helper encodes WEP networks" \
  $'Old Router\nnone\n\nno\nwep-secret\n' \
  'WIFI:T:WEP;S:Old Router;P:wep-secret;;' \
  --meta wlan0

export QR_NMCLI_FIELDS=$'Enterprise\nwpa-eap\nsecret\nno\n'
export QR_PAYLOAD_FILE="$tmp/enterprise-payload"
if PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-qr" wlan0 >"$tmp/enterprise-output" 2>"$tmp/enterprise-error"; then
  fail "network QR helper rejects enterprise networks" "helper unexpectedly succeeded"
fi
enterprise_error=$(<"$tmp/enterprise-error")
expected_error="Enterprise Wi-Fi cannot be shared with a password QR code"
[[ $enterprise_error == "$expected_error" ]] || fail "network QR helper rejects enterprise networks" "expected: $expected_error\nactual: $enterprise_error"
[[ ! -e $QR_PAYLOAD_FILE ]] || fail "network QR helper rejects enterprise networks" "qrencode unexpectedly ran"
pass "network QR helper rejects enterprise networks"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const wifiqrQml = fs.readFileSync(path.join(root, 'shell/plugins/panels/wifiqr/Panel.qml'), 'utf8')
const fns = [
  wifiqrQml.match(/function safeIface\(value\) \{[\s\S]*?\n  \}/)[0],
  wifiqrQml.match(/function close\(\) \{[\s\S]*?\n  \}/)[0],
  wifiqrQml.match(/function generate\(requestedIface\) \{[\s\S]*?\n  \}/)[0]
].join('\n')

const ctx = {
  opened: true,
  pendingShow: false,
  expectedStop: false,
  pwExpectedStop: false,
  qrSize: 3,
  qrRows: ['101', '010', '101'],
  error: '',
  loading: false,
  iface: 'wlan0',
  ssid: 'Cafe',
  secured: true,
  password: 'old-secret',
  passwordVisible: true,
  passwordError: '',
  I18n: { t: k => k },
  qrProc: { running: false, command: [] },
  pwProc: { running: true, command: [] }
}
ctx.root = ctx
vm.runInNewContext(fns, ctx)

ctx.close()
assert(ctx.pwExpectedStop === true && !ctx.pwProc.running, 'wifiqr close marks an in-flight password fetch as expectedStop')
assertEqual(ctx.password, '', 'wifiqr close clears the password from memory')

ctx.generate('--bad-flag')
assert(!ctx.qrProc.running && ctx.error === 'wifiqr.generateFailed', 'wifiqr rejects dash-prefixed interface names')
ctx.generate('wlan0')
assertDeepEqual(ctx.qrProc.command, ['omarchy-network-qr', '--meta', 'wlan0'], 'wifiqr runs generator for valid interface names')
JS

run_node_test <<'JS'
const wifiqr = requireFromRoot('shell/plugins/panels/wifiqr/Model.js')

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

mkdir -p "$tmp/scan-bin" "$tmp/runtime"

cat >"$tmp/scan-bin/omarchy-hw-webcam" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$tmp/scan-bin/omarchy-hw-webcam"

scan_out=$(PATH="$tmp/scan-bin:$PATH" XDG_RUNTIME_DIR="$tmp/runtime" "$ROOT/shell/plugins/panels/wifiqr/scan-webcam-qr.sh" || true)
[[ $scan_out == $'error\tnoWebcam' ]] || fail "webcam scanner guards against missing webcam hardware" "actual: $scan_out"
pass "webcam scanner guards against missing webcam hardware"

cat >"$tmp/scan-bin/nmcli" <<'EOF'
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
cat >"$tmp/scan-bin/uuidgen" <<'EOF'
#!/bin/bash
echo "new-temp-uuid"
EOF
chmod +x "$tmp/scan-bin/nmcli" "$tmp/scan-bin/uuidgen"

export NMCLI_STDIN_FILE="$tmp/nmcli-stdin"
export NMCLI_LOG_FILE="$tmp/nmcli-log"

# 1. Successful connection: verifies credentials on the new profile, enables autoconnect, and leaves saved profiles untouched
: >"$NMCLI_LOG_FILE"
printf 'topsecret123\n' | NMCLI_UP_EXIT=0 PATH="$tmp/scan-bin:$PATH" "$ROOT/shell/plugins/panels/wifiqr/connect-wifi-qr.sh" "Cafe WiFi" "WPA" "no" "wlan0"
[[ $(<"$NMCLI_STDIN_FILE") == $'set 802-11-wireless-security.psk topsecret123\nsave\nquit' ]] \
  || fail "connect helper sends the Wi-Fi passphrase over stdin rather than argv"
grep -qxF "connection modify uuid new-temp-uuid connection.autoconnect yes" "$NMCLI_LOG_FILE" \
  || fail "connect helper enables autoconnect on the verified profile"
if grep -q "saved-uuid-1\|other-adapter-uuid" "$NMCLI_LOG_FILE"; then
  fail "connect helper must never overwrite or delete existing saved profiles" "$(<"$NMCLI_LOG_FILE")"
fi
pass "connect helper creates a dedicated profile, enables autoconnect after verification, and leaves saved profiles untouched"

# 2. Failed connection: deletes only the temporary profile and preserves saved-uuid-1
: >"$NMCLI_LOG_FILE"
if printf 'topsecret123\n' | NMCLI_UP_EXIT=1 PATH="$tmp/scan-bin:$PATH" "$ROOT/shell/plugins/panels/wifiqr/connect-wifi-qr.sh" "Cafe WiFi" "SAE" "no" "wlan0" 2>/dev/null; then
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
printf '\n' | NMCLI_UP_EXIT=0 PATH="$tmp/scan-bin:$PATH" "$ROOT/shell/plugins/panels/wifiqr/connect-wifi-qr.sh" "EnhancedLobby" "OWE" "no" "wlan0"
grep -qxF "connection modify uuid new-temp-uuid wifi-sec.key-mgmt owe" "$NMCLI_LOG_FILE" \
  || fail "OWE scan configures wifi-sec.key-mgmt owe"
pass "OWE scan configures wifi-sec.key-mgmt owe"

# 4. Input guard: rejects dash-prefixed interface names before invoking nmcli
: >"$NMCLI_LOG_FILE"
if printf 'topsecret123\n' | PATH="$tmp/scan-bin:$PATH" "$ROOT/shell/plugins/panels/wifiqr/connect-wifi-qr.sh" "Cafe WiFi" "WPA" "no" "--bad-flag" 2>/dev/null; then
  fail "connect helper rejects dash-prefixed interface names"
fi
[[ ! -s $NMCLI_LOG_FILE ]] || fail "connect helper rejects invalid interface names before calling nmcli" "$(<"$NMCLI_LOG_FILE")"
pass "connect helper rejects dash-prefixed interface names"

# 5. Multi-QR router sticker: prefers WIFI: payload over non-Wi-Fi QR codes in the same frame
cat >"$tmp/scan-bin/omarchy-hw-webcam" <<'EOF'
#!/bin/bash
exit 0
EOF
cat >"$tmp/scan-bin/omarchy-capture-webcam-list" <<'EOF'
#!/bin/bash
printf '/dev/video0  Integrated Camera\n'
EOF
cat >"$tmp/scan-bin/v4l2-ctl" <<'EOF'
#!/bin/bash
printf "\t[0]: 'MJPG'\n\t\tSize: Discrete 1280x720\n"
EOF
cat >"$tmp/scan-bin/setpriv" <<'EOF'
#!/bin/bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pdeathsig) shift 2 ;;
    *) break ;;
  esac
done
exec "$@"
EOF
cat >"$tmp/scan-bin/ffmpeg" <<'EOF'
#!/bin/bash
out="${!#}"
printf 'fake-jpg' >"$out"
sleep 0.5
EOF
cat >"$tmp/scan-bin/zbarimg" <<'EOF'
#!/bin/bash
printf 'https://router.example/setup\nWIFI:T:WPA;S:RouterSticker;P:stickersecret;;\n'
EOF
chmod +x "$tmp/scan-bin"/{omarchy-hw-webcam,omarchy-capture-webcam-list,v4l2-ctl,setpriv,ffmpeg,zbarimg}

multi_out=$(PATH="$tmp/scan-bin:$PATH" XDG_RUNTIME_DIR="$tmp/runtime" "$ROOT/shell/plugins/panels/wifiqr/scan-webcam-qr.sh" || true)
expected_b64=$(printf '%s' 'WIFI:T:WPA;S:RouterSticker;P:stickersecret;;' | base64 -w0)
grep -qxF $'qr\t'"$expected_b64" <<<"$multi_out" \
  || fail "webcam scanner prefers WIFI: QR payload when multiple QR codes are in view" "$multi_out"
pass "webcam scanner prefers WIFI: QR payload when multiple QR codes are in view"
