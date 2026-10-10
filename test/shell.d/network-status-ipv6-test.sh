#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export OMARCHY_TEST_NETWORK_CALLS="$scratch/calls"

cat >"$scratch/bin/ip" <<'SH'
#!/bin/bash
printf 'ip %s\n' "$*" >>"$OMARCHY_TEST_NETWORK_CALLS"
if [[ $* == "route get 1.1.1.1" ]]; then
  "$0" -j route get 1.1.1.1 | jq -r '.[] | "1.1.1.1 dev \(.dev) src \(.prefsrc // .src)"'
  exit
fi
case "$*" in
  "-j route get 1.1.1.1")
    case "$OMARCHY_TEST_NETWORK_MODE" in
      offline|ipv6|ipv6-src|ipv6-no-gateway|ipv6-scoped|ipv6-ping-fails) exit 2 ;;
      empty-v4) echo '[]' ;;
      clat|clat-no-ipv6)
        echo '[{"dev":"clat0","prefsrc":"192.0.0.5","via":{"family":"inet6","host":"fe80::1"}}]'
        ;;
      clat-address)
        echo '[{"dev":"clat0","prefsrc":"192.0.0.7","gateway":"192.0.0.1"}]'
        ;;
      via-ipv6)
        echo '[{"dev":"adnextfixture0","prefsrc":"192.0.2.2","via":{"family":"inet6","host":"fe80::1"}}]'
        ;;
      outside-clat)
        echo '[{"dev":"adnextfixture0","prefsrc":"192.0.0.8","gateway":"192.0.2.1"}]'
        ;;
      *) echo '[{"dev":"adnextfixture0","prefsrc":"192.0.2.2","gateway":"192.0.2.1"}]' ;;
    esac
    ;;
  "-j -6 route get 2606:4700:4700::1111")
    case "$OMARCHY_TEST_NETWORK_MODE" in
      offline|ipv4|clat-no-ipv6) exit 2 ;;
      ipv6-src)
        echo '[{"dev":"adnextfixture0","src":"2001:db8::2","gateway":"fe80::1"}]'
        ;;
      ipv6-no-gateway)
        echo '[{"dev":"adnextfixture0","prefsrc":"2001:db8::2"}]'
        ;;
      ipv6-scoped)
        echo '[{"dev":"adnextfixture0","prefsrc":"2001:db8::2","gateway":"fe80::1%adnextfixture0"}]'
        ;;
      *) echo '[{"dev":"adnextfixture0","prefsrc":"2001:db8::2","gateway":"fe80::1"}]' ;;
    esac
    ;;
  "-j addr show adnextfixture0"|"-j addr show clat0")
    echo '[{"addr_info":[
      {"family":"inet","local":"192.0.2.2","prefixlen":24},
      {"family":"inet","local":"198.51.100.2","prefixlen":25},
      {"family":"inet","local":"192.0.0.5","prefixlen":32},
      {"family":"inet","local":"192.0.0.8","prefixlen":32},
      {"family":"inet6","local":"fe80::2","prefixlen":64},
      {"family":"inet6","local":"2001:db8:1::2","prefixlen":48},
      {"family":"inet6","local":"2001:db8::2","prefixlen":64}
    ]}]'
    ;;
  *) echo "unexpected ip arguments: $*" >&2; exit 2 ;;
esac
SH

cat >"$scratch/bin/ping" <<'SH'
#!/bin/bash
printf 'ping %s\n' "$*" >>"$OMARCHY_TEST_NETWORK_CALLS"
[[ $OMARCHY_TEST_NETWORK_MODE != "ipv6-ping-fails" ]] || exit 1
case "${!#}" in
  fe80::1%adnextfixture0|fe80::1%clat0|192.0.2.1)
    echo '64 bytes from router: icmp_seq=1 ttl=64 time=2.50 ms'
    ;;
  1.1.1.1|2606:4700:4700::1111)
    echo '64 bytes from internet: icmp_seq=1 ttl=64 time=7.25 ms'
    ;;
  *) echo "unexpected ping target: ${!#}" >&2; exit 1 ;;
esac
SH
chmod +x "$scratch/bin/ip" "$scratch/bin/ping"

run_status() {
  PATH="$scratch/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-network-status" "$@"
}

assert_field() {
  local key=$1 expected=$2
  local actual
  actual=$(awk -F '\t' -v key="$key" '$1 == key { print $2; exit }' <<<"$details")
  [[ $actual == "$expected" ]] || fail "$OMARCHY_TEST_NETWORK_MODE: $key" "expected '$expected', got '$actual'"
}

for mode in ipv4 dual-stack; do
  export OMARCHY_TEST_NETWORK_MODE=$mode
  : >"$OMARCHY_TEST_NETWORK_CALLS"
  output=$(run_status)
  [[ $output == $'ethernet\tadnextfixture0\t\t' ]] || fail "$mode: connected status" "$output"
  details=$(run_status --verbose)
  assert_field iface adnextfixture0
  assert_field gateway 192.0.2.1
  assert_field internet_ping_ms 7.25
  assert_field ip 192.0.2.2
  assert_field prefix 24
  if grep -Fq 'route get 2606:' "$OMARCHY_TEST_NETWORK_CALLS"; then
    fail "$mode: ordinary IPv4 must not be replaced with IPv6"
  fi
  pass "$mode keeps its IPv4 route, matching source prefix, and probe"
done

for mode in ipv6 ipv6-src empty-v4 clat clat-address via-ipv6 ipv6-scoped; do
  export OMARCHY_TEST_NETWORK_MODE=$mode
  : >"$OMARCHY_TEST_NETWORK_CALLS"
  output=$(run_status)
  [[ $output == $'ethernet\tadnextfixture0\t\t' ]] || fail "$mode: connected status" "$output"
  details=$(run_status --verbose)
  assert_field iface adnextfixture0
  assert_field ip 2001:db8::2
  assert_field prefix 64
  assert_field router_ping_ms 2.50
  assert_field internet_ping_ms 7.25
  if [[ $mode == "ipv6-scoped" ]]; then
    assert_field gateway fe80::1%adnextfixture0
  else
    assert_field gateway fe80::1
  fi
  grep -Fxq 'ping -n -c 1 -W 1 fe80::1%adnextfixture0' "$OMARCHY_TEST_NETWORK_CALLS" ||
    fail "$mode: link-local router ping must carry the interface scope"
  grep -Fxq 'ping -n -c 1 -W 1 2606:4700:4700::1111' "$OMARCHY_TEST_NETWORK_CALLS" ||
    fail "$mode: native IPv6 internet probe"
  if grep -Fxq 'ping -n -c 1 -W 1 1.1.1.1' "$OMARCHY_TEST_NETWORK_CALLS"; then
    fail "$mode: no IPv4 ping after selecting IPv6"
  fi
  pass "$mode reports the native IPv6 route and scopes its router probe"
done

export OMARCHY_TEST_NETWORK_MODE=outside-clat
: >"$OMARCHY_TEST_NETWORK_CALLS"
details=$(run_status --verbose)
assert_field ip 192.0.0.8
assert_field prefix 32
if grep -Fq 'route get 2606:' "$OMARCHY_TEST_NETWORK_CALLS"; then
  fail "192.0.0.8 is outside the CLAT source range"
fi
pass "the address immediately outside the CLAT range keeps IPv4"

export OMARCHY_TEST_NETWORK_MODE=clat-no-ipv6
output=$(run_status)
[[ $output == $'ethernet\tclat0\t\t' ]] || fail "keep IPv4-over-IPv6 when no native IPv6 route is available" "$output"
details=$(run_status --verbose)
assert_field ip 192.0.0.5
assert_field prefix 32
assert_field gateway fe80::1
assert_field router_ping_ms 2.50
assert_field internet_ping_ms 7.25
pass "a CLAT route remains usable when native IPv6 is unavailable"

export OMARCHY_TEST_NETWORK_MODE=ipv6-no-gateway
details=$(run_status --verbose)
assert_field ip 2001:db8::2
assert_field gateway ""
assert_field internet_ping_ms 7.25
if grep -q '^router_ping_ms' <<<"$details"; then
  fail "an on-link route must not invent a router ping"
fi
pass "an IPv6 on-link route needs no gateway"

export OMARCHY_TEST_NETWORK_MODE=ipv6-ping-fails
details=$(run_status --verbose)
assert_field iface adnextfixture0
assert_field router_ping_ms ""
assert_field internet_ping_ms ""
grep -q '^internet_ping_ms' <<<"$details" || fail "a failed ping must remain an empty sample"
pass "unanswered IPv6 probes remain failed samples"

export OMARCHY_TEST_NETWORK_MODE=offline
output=$(run_status)
[[ $output == $'disconnected\t\t\t' ]] || fail "no route in either family means disconnected" "$output"
details=$(run_status --verbose)
[[ -z $details ]] || fail "an offline link has no route details" "$details"
pass "a missing route in both families remains disconnected"
