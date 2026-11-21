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
  # Answer from the "name:value" profile in $QR_NMCLI_FIELDS the way nmcli
  # does: --terse keeps the names, --get-values drops them, and the fields of a
  # setting the profile lacks print nothing at all.
  terse=false
  while (( $# )); do
    case $1 in
      --terse) terse=true ;;
      --fields | --get-values) requested=$2; shift ;;
    esac
    shift
  done
  IFS=, read -ra names <<<"$requested"
  for name in "${names[@]}"; do
    while IFS= read -r line; do
      [[ $line == "$name:"* ]] || continue
      if [[ $terse == "true" ]]; then
        printf '%s\n' "$line"
      else
        printf '%s\n' "${line#*:}"
      fi
    done <<<"$QR_NMCLI_FIELDS"
  done
fi
EOF

# A Wi-Fi profile as name:value lines. The security fields exist only when the
# profile has an 802-11-wireless-security setting, which open networks lack.
profile() {
  local ssid=$1 hidden=$2
  printf '802-11-wireless.ssid:%s\n802-11-wireless.hidden:%s\n' "$ssid" "$hidden"
  if (( $# > 2 )); then
    printf '802-11-wireless-security.key-mgmt:%s\n' "$3"
    printf '802-11-wireless-security.psk:%s\n' "${4:-}"
    printf '802-11-wireless-security.wep-key0:%s\n' "${5:-}"
  fi
}

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
    expected_ssid=${expected_ssid#802-11-wireless.ssid:}
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
  "$(profile 'Cafe;Guest\5G' no wpa-psk 'p,a:ss;word\42')" \
  'WIFI:T:WPA;S:Cafe\;Guest\\5G;P:p\,a\:ss\;word\\42;;' \
  --meta wlan0

# Without --meta the output stays a bare matrix, which pre-plugin clones of
# the network widget still parse.
run_success_case \
  "network QR helper keeps the bare matrix without --meta" \
  "$(profile 'Cafe;Guest\5G' no wpa-psk 'p,a:ss;word\42')" \
  'WIFI:T:WPA;S:Cafe\;Guest\\5G;P:p\,a\:ss\;word\\42;;' \
  wlan0

# With no interface argument the helper finds the connected Wi-Fi device.
run_success_case \
  "network QR helper detects the Wi-Fi interface" \
  "$(profile 'Cafe Detected' no wpa-psk secret)" \
  'WIFI:T:WPA;S:Cafe Detected;P:secret;;' \
  --meta

QR_ROUTE_EXIT=2 run_success_case \
  "network QR helper detects Wi-Fi when route lookup fails" \
  "$(profile 'Cafe No Route' no wpa-psk secret)" \
  'WIFI:T:WPA;S:Cafe No Route;P:secret;;' \
  --meta

# An open network's profile has no 802-11-wireless-security setting, so nmcli
# prints only the SSID and hidden fields.
run_success_case \
  "network QR helper supports open networks" \
  "$(profile 'Cafe Open' no)" \
  'WIFI:T:nopass;S:Cafe Open;P:;;' \
  --meta wlan0

run_success_case \
  "network QR helper marks hidden networks" \
  "$(profile 'Hidden Network' yes wpa-psk secret)" \
  'WIFI:T:WPA;S:Hidden Network;P:secret;H:true;;' \
  --meta wlan0

# NetworkManager models WEP as key-mgmt "none" plus a wep-key, which must not
# be mistaken for an open network.
run_success_case \
  "network QR helper encodes WEP networks" \
  "$(profile 'Old Router' no none '' wep-secret)" \
  'WIFI:T:WEP;S:Old Router;P:wep-secret;;' \
  --meta wlan0

export QR_NMCLI_FIELDS=$(profile Enterprise no wpa-eap secret)
export QR_PAYLOAD_FILE="$tmp/enterprise-payload"
if PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-qr" wlan0 >"$tmp/enterprise-output" 2>"$tmp/enterprise-error"; then
  fail "network QR helper rejects enterprise networks" "helper unexpectedly succeeded"
fi
enterprise_error=$(<"$tmp/enterprise-error")
expected_error="Enterprise Wi-Fi cannot be shared with a password QR code"
[[ $enterprise_error == "$expected_error" ]] || fail "network QR helper rejects enterprise networks" "expected: $expected_error\nactual: $enterprise_error"
[[ ! -e $QR_PAYLOAD_FILE ]] || fail "network QR helper rejects enterprise networks" "qrencode unexpectedly ran"
pass "network QR helper rejects enterprise networks"
