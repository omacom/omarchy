#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
net_class="$test_tmp/net"
mkdir -p "$stub_bin" "$net_class/wlan0/wireless" "$net_class/eth0"

# The route the kernel picks for the internet, from ROUTE_DEV; none without it.
cat >"$stub_bin/ip" <<'SH'
#!/bin/bash
[[ $* == "route get 1.1.1.1" ]] || exit 64
[[ -n ${ROUTE_DEV:-} ]] || { echo "RTNETLINK answers: Network is unreachable" >&2; exit 2; }
printf '1.1.1.1 via 192.168.1.1 dev %s src 192.168.1.20 uid 1000 \n    cache \n' "$ROUTE_DEV"
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

chmod +x "$stub_bin"/*

connected() {
  OMARCHY_NET_CLASS_PATH="$net_class" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-network-wifi-connected"
}

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

grep -Fq '"when":"omarchy-network-wifi-connected"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu's Wi-Fi QR Code row asks the cheap predicate"
pass "the menu's Wi-Fi QR Code row asks the cheap predicate"
