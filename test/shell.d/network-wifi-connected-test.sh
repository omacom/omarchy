#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
net_class="$test_tmp/net"
mkdir -p "$stub_bin" "$net_class/wlan0/wireless" "$net_class/wlan0/device" "$net_class/eth0/device" "$net_class/br0" "$net_class/ppp0" "$net_class/tun0" "$net_class/tun1"

# Radios, NICs and bridges are ARPHRD_ETHER, PPP is ARPHRD_PPP, and TUN and WireGuard tunnels ARPHRD_NONE.
for device in wlan0 eth0 br0; do echo 1 >"$net_class/$device/type"; done
echo 512 >"$net_class/ppp0/type"
for device in tun0 tun1; do echo 65534 >"$net_class/$device/type"; done
for device in wlan0 eth0 br0 ppp0 tun0 tun1; do echo up >"$net_class/$device/operstate"; done

# The route the kernel picks for the internet is ROUTE_DEV, none without it. The main
# table's default routes are DEFAULTS, as "device:metric" pairs, "dev+dev:metric:multipath" for ECMP.
cat >"$stub_bin/ip" <<'SH'
#!/bin/bash
address() { case $1 in tun0) echo 198.18.0.1 ;; eth0) echo 10.0.0.20 ;; *) echo 192.168.1.20 ;; esac; }
gateway() { case $1 in eth0) echo 10.0.0.1 ;; *) echo 192.168.1.1 ;; esac; }

case "$*" in
"route get 1.1.1.1" | "-j route get 1.1.1.1")
  [[ -n ${ROUTE_DEV:-} ]] || { echo "RTNETLINK answers: Network is unreachable" >&2; exit 2; }
  if [[ $1 == "-j" ]]; then
    printf '[{"dst":"1.1.1.1","dev":"%s","prefsrc":"%s"}]\n' "$ROUTE_DEV" "$(address "$ROUTE_DEV")"
  else
    printf '1.1.1.1 dev %s src %s uid 1000 \n    cache \n' "$ROUTE_DEV" "$(address "$ROUTE_DEV")"
  fi
  ;;
"-j route show default")
  for route in ${DEFAULTS:-}; do
    IFS=: read -r dev metric multipath <<<"$route"
    if [[ -n $multipath ]]; then
      legs=$(for leg in ${dev//+/ }; do printf '{"gateway":"%s","dev":"%s"}\n' "$(gateway "$leg")" "$leg"; done | jq -sc .)
      printf '{"dst":"default","metric":%s,"nexthops":%s}\n' "$metric" "$legs"
    else
      printf '{"dst":"default","gateway":"%s","dev":"%s","metric":%s}\n' "$(gateway "$dev")" "$dev" "$metric"
    fi
  done | jq -s .
  ;;
"-j route show default dev "*)
  printf '[{"dst":"default","gateway":"%s"}]\n' "$(gateway "$6")"
  ;;
"-j addr show "*)
  printf '[{"addr_info":[{"family":"inet","local":"%s","prefixlen":24,"scope":"global"}]}]\n' "$(address "$4")"
  ;;
*)
  exit 64
  ;;
esac
SH

# NetworkManager over D-Bus: wlan0 is device 3 in NM_STATE; no daemon with NM_DOWN.
cat >"$stub_bin/busctl" <<'SH'
#!/bin/bash
[[ -z ${NM_DOWN:-} ]] || { echo "Failed to connect to bus" >&2; exit 1; }
case "$*" in
"--system call org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager GetDeviceByIpIface s wlan0")
  echo 'o "/org/freedesktop/NetworkManager/Devices/3"'
  ;;
"--system get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager/Devices/3 org.freedesktop.NetworkManager.Device State")
  echo "u ${NM_STATE:-100}"
  ;;
*)
  echo "No such device" >&2
  exit 1
  ;;
esac
SH

# The same NetworkManager as nmcli, and the link iw reports, for omarchy-network-status.
cat >"$stub_bin/nmcli" <<'SH'
#!/bin/bash
case "$*" in
"-t -f GENERAL.STATE,GENERAL.CONNECTION dev show wlan0") printf 'GENERAL.STATE:%s (connected)\nGENERAL.CONNECTION:HomeWiFi\n' "${NM_STATE:-100}" ;;
"-t -f IN-USE,SIGNAL dev wifi list ifname wlan0 --rescan no") printf '*:70\n' ;;
*) exit 1 ;;
esac
SH

cat >"$stub_bin/iw" <<'SH'
#!/bin/bash
[[ $* == "dev wlan0 link" ]] || exit 1
printf 'Connected to aa:bb:cc:dd:ee:ff (on wlan0)\n\tSSID: HomeWiFi\n\tfreq: 5180\n\tsignal: -55 dBm\n\ttx bitrate: 866.7 MBit/s\n'
SH

printf '#!/bin/bash\nexit 1\n' >"$stub_bin/ping"

chmod +x "$stub_bin"/*

connected() {
  OMARCHY_NET_CLASS_PATH="$net_class" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-network-wifi-connected"
}

status() {
  OMARCHY_NET_CLASS_PATH="$net_class" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-network-status" "$@"
}

wifi_line=$'wifi\tHomeWiFi\t70\t5180'

ROUTE_DEV=wlan0 connected || fail "an activated Wi-Fi default route is connected Wi-Fi"
pass "an activated Wi-Fi default route is connected Wi-Fi"

! ROUTE_DEV=eth0 connected || fail "an Ethernet default route is not Wi-Fi"
! ROUTE_DEV= connected || fail "no default route is not Wi-Fi"
pass "Ethernet and no route at all are not Wi-Fi"

# 70 is NM_DEVICE_STATE_IP_CONFIG: associated but not yet activated, which
# omarchy-network-status reports as disconnected.
! ROUTE_DEV=wlan0 NM_STATE=70 connected || fail "a Wi-Fi device NetworkManager has not activated is not connected"
! ROUTE_DEV=wlan0 NM_DOWN=1 connected || fail "Wi-Fi NetworkManager cannot answer for is not connected"
pass "Wi-Fi counts only once NetworkManager has it activated, as omarchy-network-status does"

# A VPN or proxy tunnel takes the route itself; both commands report the link it rides on.
export ROUTE_DEV=tun0 DEFAULTS="wlan0:600"
connected && [[ $(status) == $wifi_line ]] || fail "a tunnel over Wi-Fi is Wi-Fi"
verbose=$(status --verbose)
[[ $verbose == *$'iface\twlan0\nip\t192.168.1.20\nprefix\t24\ngateway\t192.168.1.1\n'* && $verbose == *$'type\twifi\nssid\tHomeWiFi\n'* ]] ||
  fail "a tunnel over Wi-Fi gives the panel the Wi-Fi's own addresses" "$verbose"
pass "a tunnel over Wi-Fi is Wi-Fi, with its own addresses"

DEFAULTS="tun0:50 tun1:60 wlan0:600 eth0:100"
! connected && [[ $(status) == $'ethernet\teth0\t\t' ]] || fail "a tunnel on a docked laptop rides the lower-metric Ethernet, past another tunnel"
DEFAULTS="tun0:50 tun1+eth0:100:multipath wlan0:600"
! connected && [[ $(status) == $'ethernet\teth0\t\t' ]] || fail "a multipath default route names its devices through its next hops"
DEFAULTS=""
! connected && [[ $(status) == $'ethernet\ttun0\t\t' ]] || fail "a tunnel with no default route behind it stays the tunnel"
pass "a tunnel resolves to the best default route on another device, or stays itself"

DEFAULTS="br0:425 ppp0:50 wlan0:600"
[[ $(ROUTE_DEV=br0 status) == $'ethernet\tbr0\t\t' && $(ROUTE_DEV=ppp0 status) == $'ethernet\tppp0\t\t' ]] ||
  fail "a bridge or PPP link carrying the default route stays itself"
pass "a bridge or PPP link carrying the default route stays itself"
unset ROUTE_DEV DEFAULTS

grep -Fq '"when":"omarchy-network-wifi-connected"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu's Wi-Fi QR Code row asks the cheap predicate"
pass "the menu's Wi-Fi QR Code row asks the cheap predicate"
