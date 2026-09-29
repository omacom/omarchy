#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

bin_dir="$test_tmp/bin"
sys_dir="$test_tmp/sys"
mkdir -p "$bin_dir" "$sys_dir/devices/virtual/net/Meta" "$sys_dir/class/net/Meta" "$sys_dir/class/net/wlan0/wireless"

# Mock ip
cat >"$bin_dir/ip" <<'EOF'
#!/bin/bash
if [[ "$*" == *"route get 1.1.1.1"* ]]; then
  if [[ -n ${MOCK_IP_TUN:-} ]]; then
    if [[ "$*" == *"-j"* ]]; then
      echo '[{"gateway":"198.18.0.2","dev":"Meta","table":"2022","prefsrc":"198.18.0.1"}]'
    else
      echo "1.1.1.1 via 198.18.0.2 dev Meta table 2022 src 198.18.0.1 uid 1000"
    fi
  else
    if [[ "$*" == *"-j"* ]]; then
      echo '[{"gateway":"192.168.1.1","dev":"wlan0","prefsrc":"192.168.1.100"}]'
    else
      echo "1.1.1.1 via 192.168.1.1 dev wlan0 src 192.168.1.100 uid 1000"
    fi
  fi
  exit 0
fi

if [[ "$*" == *"route show table main default"* ]]; then
  if [[ "$*" == *"-j"* ]]; then
    echo '[{"dst":"default","gateway":"192.168.1.1","dev":"wlan0","metric":600}]'
  else
    echo "default via 192.168.1.1 dev wlan0 proto dhcp src 192.168.1.100 metric 600"
  fi
  exit 0
fi

if [[ "$*" == *"addr show wlan0"* ]]; then
  echo '[{"addr_info":[{"family":"inet","local":"192.168.1.100","prefixlen":24}]}]'
  exit 0
fi

exit 1
EOF
chmod +x "$bin_dir/ip"

cat >"$bin_dir/nmcli" <<'EOF'
#!/bin/bash
if [[ "$*" == *"dev show wlan0"* ]]; then
  echo "GENERAL.STATE:100 (connected)"
  echo "GENERAL.CONNECTION:MyHomeWifi"
  exit 0
fi
if [[ "$*" == *"dev wifi list"* ]]; then
  echo "*:78"
  exit 0
fi
exit 0
EOF
chmod +x "$bin_dir/nmcli"

cat >"$bin_dir/iw" <<'EOF'
#!/bin/bash
echo "freq: 5180"
echo "SSID: MyHomeWifi"
echo "signal: -52 dBm"
echo "tx bitrate: 866.7 MBit/s"
exit 0
EOF
chmod +x "$bin_dir/iw"

cat >"$bin_dir/omarchy-cmd-present" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$bin_dir/omarchy-cmd-present"

# Substitute /sys paths in script under test
script="$test_tmp/omarchy-network-status"
sed -e "s|/sys/devices/virtual/net|$sys_dir/devices/virtual/net|g" \
    -e "s|/sys/class/net|$sys_dir/class/net|g" \
    "$ROOT/bin/omarchy-network-status" >"$script"
chmod +x "$script"

# Test 1: Direct physical connection (no TUN)
out=$(PATH="$bin_dir:$PATH" bash "$script")
[[ $out == wifi$'\t'MyHomeWifi$'\t'* ]] || fail "direct physical connection reports wifi" "$out"
pass "direct physical connection reports wifi"

# Test 2: TUN/VPN active (e.g. Clash Meta), physical uplink is wlan0
out_tun=$(PATH="$bin_dir:$PATH" MOCK_IP_TUN=1 bash "$script")
[[ $out_tun == wifi$'\t'MyHomeWifi$'\t'* ]] || fail "virtual TUN default route resolves physical wifi uplink" "$out_tun"
pass "virtual TUN default route resolves physical wifi uplink"

# Test 3: Verbose mode with TUN active resolves physical uplink interface and details
out_verbose=$(PATH="$bin_dir:$PATH" MOCK_IP_TUN=1 bash "$script" --verbose)
grep -qx "iface	wlan0" <<<"$out_verbose" || fail "verbose mode resolves physical iface wlan0" "$out_verbose"
grep -qx "type	wifi" <<<"$out_verbose" || fail "verbose mode resolves type wifi" "$out_verbose"
grep -qx "gateway	192.168.1.1" <<<"$out_verbose" || fail "verbose mode resolves physical gateway" "$out_verbose"
grep -qx "ip	192.168.1.100" <<<"$out_verbose" || fail "verbose mode resolves physical IP" "$out_verbose"
grep -qx "prefix	24" <<<"$out_verbose" || fail "verbose mode resolves physical prefix" "$out_verbose"
pass "verbose mode resolves physical uplink details under TUN/VPN"
