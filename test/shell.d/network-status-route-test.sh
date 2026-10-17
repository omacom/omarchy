#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/bin"

cat >"$stage/bin/ip" <<'MOCK'
#!/bin/bash
case "$*" in
  '-j -4 route show table main default') printf '%s\n' "${MOCK_MAIN_ROUTES:-[]}" ;;
  '-j -4 route get 1.1.1.1') printf '%s\n' '[{"dev":"lo","gateway":"198.18.0.2","prefsrc":"198.18.0.1","table":"2022"}]' ;;
  '-j addr show lo') printf '%s\n' '[{"addr_info":[{"family":"inet","prefixlen":8}]}]' ;;
  *) exit 1 ;;
esac
MOCK
cat >"$stage/bin/omarchy-cmd-present" <<'MOCK'
#!/bin/bash
exit 0
MOCK
cat >"$stage/bin/ping" <<'MOCK'
#!/bin/bash
printf '64 bytes from test: icmp_seq=1 ttl=64 time=1.00 ms\n'
MOCK
cat >"$stage/bin/cat" <<'MOCK'
#!/bin/bash
case "$1" in
  /sys/class/net/lo/speed|/sys/class/net/lo/duplex) exit 0 ;;
  *) exec /usr/bin/cat "$@" ;;
esac
MOCK
chmod +x "$stage/bin/ip" "$stage/bin/omarchy-cmd-present" "$stage/bin/ping" "$stage/bin/cat"

main_routes='[{"dev":"lo","gateway":"192.0.2.1","prefsrc":"192.0.2.10","metric":600}]'
status=$(PATH="$stage/bin:$ROOT/bin:$PATH" MOCK_MAIN_ROUTES="$main_routes" "$ROOT/bin/omarchy-network-status")
[[ $status == $'ethernet\tlo\t\t' ]] || fail "status uses the physical default route" "$status"

details=$(PATH="$stage/bin:$ROOT/bin:$PATH" MOCK_MAIN_ROUTES="$main_routes" "$ROOT/bin/omarchy-network-status" --verbose)
[[ $details == *$'iface\tlo'* ]] || fail "details use the physical default interface" "$details"
[[ $details == *$'ip\t192.0.2.10'* ]] || fail "details use the physical IP" "$details"
[[ $details == *$'gateway\t192.0.2.1'* ]] || fail "details use the physical gateway" "$details"

fallback=$(PATH="$stage/bin:$ROOT/bin:$PATH" MOCK_MAIN_ROUTES='[]' "$ROOT/bin/omarchy-network-status" --verbose)
[[ $fallback == *$'gateway\t198.18.0.2'* ]] || fail "status falls back when there is no main default route" "$fallback"

pass "network status ignores a TUN policy route when a main default route exists"
