#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/Meta" "$tmp/wlp3s0/wireless" "$tmp/ens18"
echo 65534 >"$tmp/Meta/type"
echo 1 >"$tmp/wlp3s0/type"
echo 1 >"$tmp/ens18/type"

net_sysfs=$tmp

is_tunnel_iface() {
  local device=$1
  local type_file=$net_sysfs/$device/type
  local iface_type

  [[ -n $device ]] || return 1
  [[ -e $net_sysfs/$device/tun ]] && return 0
  [[ -r $type_file ]] || return 1
  iface_type=$(< "$type_file")
  [[ $iface_type == 65534 || $iface_type == 512 ]]
}

is_tunnel_iface Meta || fail "TUN iface Meta is classified as a tunnel"
is_tunnel_iface wlp3s0 && fail "wifi iface wlp3s0 is not classified as a tunnel"
is_tunnel_iface ens18 && fail "ethernet iface ens18 is not classified as a tunnel"
pass "TUN type 65534 is a tunnel; wifi and ethernet are not"

script=$ROOT/bin/omarchy-network-status

grep -q 'OMARCHY_NET_SYSFS' "$script" || fail "omarchy-network-status honors OMARCHY_NET_SYSFS"
pass "omarchy-network-status honors OMARCHY_NET_SYSFS"

grep -q 'is_tunnel_iface' "$script" || fail "omarchy-network-status skips tunnel route devices"
pass "omarchy-network-status skips tunnel route devices"

grep -q 'prefer_wifi_over_tunnel' "$script" || fail "omarchy-network-status substitutes wifi only for tunnel routes"
pass "omarchy-network-status substitutes wifi only for tunnel routes"

# Both the bar pill and --verbose (the panel) must share the substitution.
awk '
  /^print_status\(\)/ { in_status=1; in_verbose=0 }
  /^print_verbose\(\)/ { in_status=0; in_verbose=1 }
  /^[a-zA-Z_][a-zA-Z0-9_]*\(\)/ && !/^print_status\(\)/ && !/^print_verbose\(\)/ { in_status=0; in_verbose=0 }
  in_status && /prefer_wifi_over_tunnel/ { status=1 }
  in_verbose && /prefer_wifi_over_tunnel/ { verbose=1 }
  END {
    if (!status) exit 1
    if (!verbose) exit 2
  }
' "$script" || fail "print_status and print_verbose both prefer wifi over a tunnel route"
pass "print_status and print_verbose both prefer wifi over a tunnel route"

if grep -A20 'prefer_wifi_over_tunnel()' "$script" | grep -q 'wireless'; then
  fail "wifi substitution is gated on tunnel type, not a missing wireless sysfs dir"
fi
pass "wifi substitution is gated on tunnel type, not a missing wireless sysfs dir"
