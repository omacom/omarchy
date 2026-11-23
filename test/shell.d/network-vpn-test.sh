#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/bin" "$stage/nm"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" > "$stage/bin/$1"
  chmod +x "$stage/bin/$1"
}

# A small NetworkManager: profiles in $NM/connections (uuid:type:name, with
# nmcli's terse escaping), never-default per profile, active ones in
# $NM/active. Profiles listed in $NM/needs-secrets fail to come up without
# --ask, as one with an unsaved password does without an agent.
stub nmcli 'NM=$TEST_NM
ask=0
[[ $1 == "--ask" ]] && { ask=1; shift; }
if [[ $1 == "-t" ]]; then
  if [[ $* == *--active* ]]; then cat "$NM/active" 2>/dev/null; else cat "$NM/connections"; fi
  exit 0
fi
if [[ $1 == "-g" ]]; then
  field=$2 uuid=$6
  case $field in
    ipv4.never-default) cat "$NM/nd-$uuid" 2>/dev/null || echo no ;;
    vpn.service-type) cat "$NM/svc-$uuid" 2>/dev/null ;;
    wireguard.peers) cat "$NM/peers-$uuid" 2>/dev/null ;;
    connection.type) awk -F: -v u="$uuid" "\$1 == u {print \$2}" "$NM/connections" ;;
    connection.id) awk -F: -v u="$uuid" "\$1 == u {print \$3}" "$NM/connections" ;;
    IP4.ADDRESS) grep -q "^$uuid:activated" "$NM/active" 2>/dev/null && echo "10.8.0.2/24" ;;
  esac
  exit 0
fi
echo "$*" >> "$TEST_LOG"
case "$2 $3" in
  "modify uuid")
    uuid=$4; shift 4
    while (( $# )); do
      [[ $1 == "ipv4.never-default" ]] && echo "$2" > "$NM/nd-$uuid"
      shift 2
    done ;;
  "up uuid")
    if (( ! ask )) && grep -qx "$4" "$NM/needs-secrets" 2>/dev/null; then
      # nmcli speaks the user language unless told otherwise.
      if [[ ${LC_ALL:-} == "C" ]]; then
        echo "Error: Connection activation failed: Secrets were required, but not provided" >&2
      else
        echo "Fehler: Aktivierung der Verbindung fehlgeschlagen: Geheimnisse wurden benötigt" >&2
      fi
      exit 4
    fi
    { grep -v "^$4:" "$NM/active" 2>/dev/null; echo "$4:activated"; } > "$NM/active.new"; mv "$NM/active.new" "$NM/active" ;;
  "down uuid")
    { grep -v "^$4:" "$NM/active" 2>/dev/null || true; } > "$NM/active.new"; mv "$NM/active.new" "$NM/active" ;;
  "import type")
    echo "import $4 $(basename "$6")" >> "$TEST_LOG"
    echo "Connection (aaaaaaaa-0000-4000-8000-000000000009) successfully added." ;;
esac'
stub omarchy-notification-send 'echo "notify $*" >> "$TEST_LOG"'
stub omarchy-launch-floating-terminal-with-presentation 'echo "terminal $*" >> "$TEST_LOG"'

WG=aaaaaaaa-0000-4000-8000-000000000001
OVPN=aaaaaaaa-0000-4000-8000-000000000002
WIFI=aaaaaaaa-0000-4000-8000-000000000003
OTHER=aaaaaaaa-0000-4000-8000-000000000004

reset_nm() {
  rm -rf "$stage/nm" "$stage/log" "$stage/runtime"
  mkdir -p "$stage/nm" "$stage/runtime"
  touch "$stage/log"
  cat > "$stage/nm/connections" <<EOF
$WG:wireguard:Office\:Berlin
$OVPN:vpn:Home
$WIFI:802-11-wireless:Cafe
$OTHER:wireguard:Travel
EOF
  echo "org.freedesktop.NetworkManager.openvpn" > "$stage/nm/svc-$OVPN"
  # Office allows everything through its peer; Travel only its own network.
  echo "peerkey allowed-ips=10.8.0.0/24;0.0.0.0/0 endpoint=vpn.example.net:51820" > "$stage/nm/peers-$WG"
  echo "peerkey allowed-ips=10.8.0.0/24 endpoint=vpn.example.net:51820" > "$stage/nm/peers-$OTHER"
}

# Travel as a second VPN that can carry all traffic, already doing so.
travel_full() {
  echo "peerkey allowed-ips=0.0.0.0/0" > "$stage/nm/peers-$OTHER"
  echo no > "$stage/nm/nd-$OTHER"
  echo "$OTHER:activated" > "$stage/nm/active"
}

vpn() {
  TEST_NM="$stage/nm" TEST_LOG="$stage/log" XDG_RUNTIME_DIR="$stage/runtime" OMARCHY_PATH="$ROOT" \
    PATH="$stage/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-network-vpn" "$@" < /dev/null
}

reset_nm
echo yes > "$stage/nm/nd-$WG"
echo "$WG:activated" > "$stage/nm/active"
listed=$(vpn list)
row() { local IFS=$'\t'; echo "$*"; }
expected=$(row "$WG" "Office:Berlin" wireguard up 10.8.0.2 split off,split,full ""
  row "$OVPN" Home openvpn off "" off off,split,full ""
  row "$OTHER" Travel wireguard off "" off off,split "")
[[ $listed == "$expected" ]] || fail "lists only VPNs, with their plugin, state, address and mode" "$listed"
pass "lists only VPNs, with their plugin, state, address and mode"
[[ $(<"$stage/runtime/omarchy/network-vpn") == "$expected" ]] || fail "list writes the snapshot the bar watches" "$(cat "$stage/runtime/omarchy/network-vpn")"
pass "list writes the snapshot the bar watches"

# WireGuard routes only what its peers allow, so full needs a peer that
# allows everything.
reset_nm
if vpn mode "$OTHER" full 2>/dev/null; then fail "refuses full for WireGuard whose peers don't allow everything"; fi
! grep -q "modify" "$stage/log" || fail "a refused full changes nothing" "$(<"$stage/log")"
pass "refuses full for WireGuard whose peers don't allow everything"

# Only one VPN carries all traffic: the one in full drops to split, but only
# once the new one is up.
reset_nm
travel_full
vpn mode "$WG" full
new_up=$(grep -n -m1 "^connection up uuid $WG" "$stage/log" | cut -d: -f1)
old_split=$(grep -n -m1 "^connection modify uuid $OTHER" "$stage/log" | cut -d: -f1)
(( ${new_up:-0} > 0 && ${old_split:-0} > new_up )) || fail "the new VPN is up before the old one leaves full" "$(<"$stage/log")"
pass "the new VPN is up before the old one leaves full"
[[ $(<"$stage/nm/nd-$OTHER") == "yes" && $(<"$stage/nm/nd-$WG") == "no" ]] || fail "full moves the other full VPN to split" "$(<"$stage/log")"
grep -qx "connection up uuid $OTHER" "$stage/log" || fail "the VPN moved to split reconnects to apply it" "$(<"$stage/log")"
pass "full moves the other full VPN to split and reconnects it"
grep -qx "connection modify uuid $WG ipv4.never-default no ipv6.never-default no" "$stage/log" &&
  grep -qx "connection modify uuid $OTHER ipv4.never-default yes ipv6.never-default yes" "$stage/log" ||
  fail "the mode covers IPv6 too" "$(<"$stage/log")"
pass "the mode covers IPv6 too"
[[ $(awk -F'\t' -v u="$WG" '$1 == u {print $4 $6}' "$stage/runtime/omarchy/network-vpn") == "upfull" ]] || fail "a switch rewrites the snapshot" "$(cat "$stage/runtime/omarchy/network-vpn")"
pass "a switch rewrites the snapshot"

vpn mode "$WG" off
! grep -q "^$WG:" "$stage/nm/active" || fail "off disconnects" "$(<"$stage/log")"
pass "off disconnects"

# A VPN without saved credentials asks for them in a terminal instead of failing.
reset_nm
echo "$OVPN" > "$stage/nm/needs-secrets"
vpn mode "$OVPN" split || fail "a missing password is not an error from the panel"
grep -q "^terminal omarchy-network-vpn signin $OVPN split" "$stage/log" || fail "a missing password opens the sign-in terminal" "$(<"$stage/log")"
grep -q "^notify .*Sign in to Home" "$stage/log" || fail "a missing password says where to sign in" "$(<"$stage/log")"
[[ $(vpn list | awk -F'\t' -v u="$OVPN" '$1 == u {print $8}') == "signin" ]] || fail "the row offers Sign in"
pass "a missing password opens a sign-in terminal and the row offers Sign in"
rm "$stage/nm/needs-secrets"

# A switch waiting for sign-in leaves the VPN carrying all traffic as it is.
reset_nm
travel_full
echo "$WG" > "$stage/nm/needs-secrets"
vpn mode "$WG" full
[[ $(<"$stage/nm/nd-$OTHER") == "no" ]] && grep -q "^$OTHER:activated" "$stage/nm/active" ||
  fail "a pending switch keeps the current full VPN" "$(<"$stage/log")"
pass "a pending switch keeps the current full VPN"

# A VPN pushed out of full whose token can't be reused offers Sign in.
reset_nm
travel_full
echo "$OTHER" > "$stage/nm/needs-secrets"
vpn mode "$WG" full
[[ $(vpn list | awk -F'\t' -v u="$OTHER" '$1 == u {print $8}') == "signin" ]] || fail "a VPN dropped from full for a token offers Sign in" "$(<"$stage/log")"
pass "a VPN dropped from full for a token offers Sign in"
rm "$stage/nm/needs-secrets"

vpn mode "$OVPN" split
[[ -z $(vpn list | awk -F'\t' -v u="$OVPN" '$1 == u {print $8}') ]] || fail "connecting clears Sign in"
pass "connecting clears Sign in"

reset_nm
if vpn mode "$WIFI" split 2>/dev/null || vpn mode "$WG" sideways 2>/dev/null || vpn mode "not-a-uuid" off 2>/dev/null; then
  fail "refuses non-VPN profiles, unknown modes and malformed ids"
fi
! grep -q "modify" "$stage/log" || fail "a refused switch changes nothing" "$(<"$stage/log")"
pass "refuses non-VPN profiles, unknown modes and malformed ids without changing anything"

# WireGuard names the interface after the file, which must be a valid
# interface name; the profile keeps the full name and starts off.
reset_nm
mkdir -p "$stage/files"
printf '[Interface]\nPrivateKey = x\nAddress = 10.8.0.2/24\n[Peer]\nEndpoint = vpn.example.net:51820\nAllowedIPs = 10.8.0.0/24\n' > "$stage/files/my office (berlin).conf"
vpn import "$stage/files/my office (berlin).conf" >/dev/null
grep -qx "import wireguard my-office--berl.conf" "$stage/log" || fail "imports WireGuard under a valid interface name" "$(<"$stage/log")"
grep -qx "connection modify uuid aaaaaaaa-0000-4000-8000-000000000009 connection.id my office (berlin) connection.autoconnect no" "$stage/log" || fail "keeps the full name and no autoconnect" "$(<"$stage/log")"
grep -qx "connection down uuid aaaaaaaa-0000-4000-8000-000000000009" "$stage/log" || fail "an imported VPN starts off" "$(<"$stage/log")"
pass "imports WireGuard under a valid interface name, keeps the full name, starts off"

printf 'just some notes\n' > "$stage/files/notes.txt"
: > "$stage/log"
if vpn import "$stage/files/notes.txt" 2>/dev/null; then fail "refuses a file that is not a VPN config"; fi
! grep -q "^import" "$stage/log" || fail "a refused file reaches nmcli" "$(<"$stage/log")"
pass "refuses a file that is not a VPN config"
