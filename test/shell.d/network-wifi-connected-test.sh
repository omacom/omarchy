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

# First-run Wi-Fi wait backs off when nm-online fails immediately (e.g. NM down)
# and still runs both follow-up setup hooks once a link comes up.
wifi_bin="$test_tmp/wifi-bin"
wifi_root="$test_tmp/wifi-root"
wifi_log="$test_tmp/wifi.log"
wifi_attempts="$test_tmp/wifi-attempts"
mkdir -p "$wifi_bin" "$wifi_root/install/user/first-run"
echo 0 >"$wifi_attempts"

cat >"$wifi_bin/nm-online" <<'SH'
#!/bin/bash
case "$*" in
  "-q -s -t 30") exit 0 ;;
  "-q -x -t 30") exit 1 ;;
  "-q -t 86400")
    count=$(<"$WIFI_ATTEMPTS")
    count=$((count + 1))
    echo "$count" >"$WIFI_ATTEMPTS"
    (( count == 1 )) && exit 4
    exit 0
    ;;
  *) exit 1 ;;
esac
SH
cat >"$wifi_bin/sleep" <<'SH'
#!/bin/bash
printf 'sleep %s\n' "$*" >>"$WIFI_LOG"
SH
cat >"$wifi_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify\n' >>"$WIFI_LOG"
SH
cat >"$wifi_bin/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s\n' "$1"
SH
chmod +x "$wifi_bin"/*
printf 'printf "setup-agent\\n" >>"$WIFI_LOG"\n' >"$wifi_root/install/user/first-run/setup-agent.hook"
printf 'printf "setup-fingerprint\\n" >>"$WIFI_LOG"\n' >"$wifi_root/install/user/first-run/setup-fingerprint.hook"

(
  export PATH="$wifi_bin:$PATH" OMARCHY_PATH="$wifi_root" WIFI_LOG="$wifi_log" WIFI_ATTEMPTS="$wifi_attempts"
  source "$ROOT/install/user/first-run/wifi.sh"
  wait
)

[[ $(<"$wifi_log") == $'notify\nsleep 5\nsetup-agent\nsetup-fingerprint' ]] ||
  fail "first-run wifi.sh backs off on immediate nm-online failure and runs hooks once online" "$(cat "$wifi_log")"
pass "first-run wifi.sh backs off on immediate nm-online failure and runs hooks once online"
