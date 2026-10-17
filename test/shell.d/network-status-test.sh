#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/sys/class/net/eth0" "$tmp_dir/sys/class/net/wlan0/wireless" "$tmp_dir/sys/class/net/wlan0/statistics"
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_SYS_CLASS_NET="$tmp_dir/sys/class/net"

# Fake sysfs entries
printf '1000\n' >"$tmp_dir/sys/class/net/eth0/speed"
printf 'full\n' >"$tmp_dir/sys/class/net/eth0/duplex"
printf '1234567\n' >"$tmp_dir/sys/class/net/wlan0/statistics/rx_bytes"
printf '7654321\n' >"$tmp_dir/sys/class/net/wlan0/statistics/tx_bytes"

cat >"$tmp_dir/bin/ip" <<'SH'
#!/bin/bash
if [[ $* == *"route get"* ]]; then
  if [[ -n ${FAKE_DISCONNECTED:-} ]]; then
    exit 1
  fi
  if [[ -n ${FAKE_NO_GATEWAY:-} ]]; then
    if [[ $1 == "-j" ]]; then
      echo '[{"dev":"wg0","prefsrc":"10.0.0.2"}]'
    else
      echo '1.1.1.1 dev wg0 src 10.0.0.2 uid 1000'
    fi
    exit 0
  fi
  if [[ -n ${FAKE_ETHERNET:-} ]]; then
    if [[ $1 == "-j" ]]; then
      echo '[{"dev":"eth0","gateway":"192.168.1.1","prefsrc":"192.168.1.50"}]'
    else
      echo '1.1.1.1 via 192.168.1.1 dev eth0 src 192.168.1.50 uid 1000'
    fi
    exit 0
  fi
  if [[ $1 == "-j" ]]; then
    echo '[{"dev":"wlan0","gateway":"192.168.1.1","prefsrc":"192.168.1.100"}]'
  else
    echo '1.1.1.1 via 192.168.1.1 dev wlan0 src 192.168.1.100 uid 1000'
  fi
  exit 0
elif [[ $* == *"-j addr show"* ]]; then
  echo '[{"addr_info":[{"family":"inet","prefixlen":24}]}]'
  exit 0
fi
exit 0
SH
chmod +x "$tmp_dir/bin/ip"

cat >"$tmp_dir/bin/nmcli" <<'SH'
#!/bin/bash
if [[ $* == *"dev show"* ]]; then
  cat <<'EOF'
GENERAL.DEVICE:wlan0
GENERAL.TYPE:wifi
GENERAL.STATE:100 (connected)
GENERAL.CONNECTION:HomeWiFi
EOF
  exit 0
elif [[ $* == *"dev wifi list"* ]]; then
  cat <<'EOF'
*:75
:50
EOF
  exit 0
fi
exit 0
SH
chmod +x "$tmp_dir/bin/nmcli"

cat >"$tmp_dir/bin/iw" <<'SH'
#!/bin/bash
cat <<'EOF'
Connected to 00:11:22:33:44:55 (on wlan0)
	SSID: HomeWiFi
	freq: 5180
	signal: -55 dBm
	tx bitrate: 866.7 MBit/s
EOF
exit 0
SH
chmod +x "$tmp_dir/bin/iw"

cat >"$tmp_dir/bin/ping" <<'SH'
#!/bin/bash
echo '64 bytes from 1.1.1.1: icmp_seq=1 ttl=57 time=14.2 ms'
exit 0
SH
chmod +x "$tmp_dir/bin/ping"

network_status="$ROOT/bin/omarchy-network-status"

# Test 1: Disconnected state
out=$(FAKE_DISCONNECTED=1 "$network_status")
[[ $out == $'disconnected\t\t\t' ]] || fail "network status reports disconnected when route get fails"
pass "network status reports disconnected when offline"

# Test 2: Standard Wi-Fi output
out=$("$network_status")
[[ $out == $'wifi\tHomeWiFi\t75\t5180' ]] || fail "network status reports active wifi connection" "$out"
pass "network status reports wifi connection with ssid, signal and frequency"

# Test 3: Verbose output for Wi-Fi
out=$("$network_status" --verbose)
assert_contains() {
  local desc=$1 text=$2 substr=$3
  [[ $text == *"$substr"* ]] || fail "$desc: expected '$substr'" "$text"
  pass "$desc"
}

assert_contains "verbose reports interface" "$out" $'iface\twlan0'
assert_contains "verbose reports ip address" "$out" $'ip\t192.168.1.100'
assert_contains "verbose reports prefix" "$out" $'prefix\t24'
assert_contains "verbose reports gateway" "$out" $'gateway\t192.168.1.1'
assert_contains "verbose reports rx_bytes" "$out" $'rx_bytes\t1234567'
assert_contains "verbose reports tx_bytes" "$out" $'tx_bytes\t7654321'
assert_contains "verbose reports wifi type" "$out" $'type\twifi'
assert_contains "verbose reports ssid" "$out" $'ssid\tHomeWiFi'
assert_contains "verbose reports signal dbm" "$out" $'signal_dbm\t-55'
assert_contains "verbose reports frequency" "$out" $'freq\t5180'
assert_contains "verbose reports bitrate" "$out" $'bitrate\t866.7 MBit/s'
assert_contains "verbose reports ping latency" "$out" $'internet_ping_ms\t14.2'

# Test 4: Standard Ethernet output
out=$(FAKE_ETHERNET=1 "$network_status")
[[ $out == $'ethernet\teth0\t\t' ]] || fail "network status reports active ethernet connection" "$out"
pass "network status reports ethernet connection"

# Test 5: Verbose Ethernet output
out=$(FAKE_ETHERNET=1 "$network_status" --verbose)
assert_contains "verbose ethernet reports interface" "$out" $'iface\teth0'
assert_contains "verbose ethernet reports ip" "$out" $'ip\t192.168.1.50'
assert_contains "verbose ethernet reports gateway" "$out" $'gateway\t192.168.1.1'
assert_contains "verbose ethernet reports type" "$out" $'type\tethernet'
assert_contains "verbose ethernet reports speed" "$out" $'speed\t1000'
assert_contains "verbose ethernet reports duplex" "$out" $'duplex\tfull'

# Test 6: Route without gateway (e.g. VPN or point-to-point)
out=$(FAKE_NO_GATEWAY=1 "$network_status" --verbose)
assert_contains "no-gateway route reports interface" "$out" $'iface\twg0'
assert_contains "no-gateway route keeps correct ip" "$out" $'ip\t10.0.0.2'
assert_contains "no-gateway route leaves gateway empty" "$out" $'gateway\t'
assert_contains "no-gateway route reports ethernet type when wireless absent" "$out" $'type\tethernet'
