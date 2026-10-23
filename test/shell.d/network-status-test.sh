#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
net_class="$test_tmp/net"
mkdir -p "$stub_bin" "$net_class/tun0" "$net_class/wlan0/wireless" "$net_class/eth0/device"

# The route the kernel picks for the internet, from ROUTE_DEV; none without it.
cat >"$stub_bin/ip" <<'SH'
#!/bin/bash
[[ $* == "route get 1.1.1.1" ]] || exit 64
[[ -n ${ROUTE_DEV:-} ]] || { echo "RTNETLINK answers: Network is unreachable" >&2; exit 2; }
printf '1.1.1.1 via 192.168.1.1 dev %s src 192.168.1.20 uid 1000 \n    cache \n' "$ROUTE_DEV"
SH

# NetworkManager reports the Wi-Fi profile and signal on wlan0 only.
cat >"$stub_bin/nmcli" <<'SH'
#!/bin/bash
case "$*" in
"-t -f GENERAL.STATE,GENERAL.CONNECTION dev show wlan0")
  printf 'GENERAL.STATE:%s\nGENERAL.CONNECTION:%s\n' "${NM_STATE:-100 (connected)}" "${SSID:-HomeWiFi}"
  ;;
"-t -f IN-USE,SIGNAL dev wifi list ifname wlan0 --rescan no")
  printf '*:%s\n' "${SIGNAL:-70}"
  ;;
*)
  echo "Error: NetworkManager is not running." >&2
  exit 1
  ;;
esac
SH

cat >"$stub_bin/iw" <<'SH'
#!/bin/bash
[[ $* == "dev wlan0 link" ]] || exit 64
printf 'Connected to aa:bb:cc:dd:ee:ff (on wlan0)\n\tSSID: HomeWiFi\n\tfreq: 5180\n\tsignal: -55 dBm\n\ttx bitrate: 866.7 MBit/s\n'
SH

chmod +x "$stub_bin"/*

status() {
  OMARCHY_NET_CLASS_PATH="$net_class" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-network-status"
}

set_operstate() {
  printf '%s\n' "$2" >"$net_class/$1/operstate"
}

# What each link reports, keyed by how the kernel reaches the internet.
wifi_line=$'wifi\tHomeWiFi\t70\t5180'

set_operstate wlan0 up
set_operstate eth0 down

[[ $(ROUTE_DEV=tun0 status) == $wifi_line ]] \
  || fail "a tunnel default route on Wi-Fi reports the Wi-Fi connection"
pass "a tunnel default route on Wi-Fi reports the Wi-Fi connection"

[[ $(ROUTE_DEV=wlan0 status) == $wifi_line ]] \
  || fail "a Wi-Fi default route still reports the Wi-Fi connection"
pass "a Wi-Fi default route still reports the Wi-Fi connection"

set_operstate wlan0 down
set_operstate eth0 up

[[ $(ROUTE_DEV=tun0 status) == $'ethernet\teth0\t\t' ]] \
  || fail "a tunnel default route on wired reports the wired connection"
pass "a tunnel default route on wired reports the wired connection"

[[ $(ROUTE_DEV=eth0 status) == $'ethernet\teth0\t\t' ]] \
  || fail "a wired default route still reports the wired connection"
pass "a wired default route still reports the wired connection"

set_operstate eth0 down

[[ $(ROUTE_DEV=tun0 status) == $'ethernet\ttun0\t\t' ]] \
  || fail "a tunnel with no link behind it keeps reporting the tunnel"
pass "a tunnel with no link behind it keeps reporting the tunnel"

[[ $(ROUTE_DEV= status) == $'disconnected\t\t\t' ]] \
  || fail "no route at all is disconnected"
pass "no route at all is disconnected"
