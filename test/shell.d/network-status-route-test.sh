#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
export NETWORK_STATUS_IP_LOG="$tmp/ip.log"

cat >"$tmp/bin/ip" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$NETWORK_STATUS_IP_LOG"
case "$*" in
  "-j -4 route show table main default") printf '%s\n' "$TEST_ROUTES" ;;
  "-j route get 1.1.1.1") printf '%s\n' "$TEST_PROBE" ;;
  "-j -4 route get "*" oif "*) printf '%s\n' "${TEST_GATEWAY_ROUTE:-[]}" ;;
  "-j addr show "*) printf '%s\n' "$TEST_ADDRS" ;;
  *) printf 'unexpected ip invocation: %s\n' "$*" >&2; exit 1 ;;
esac
EOF
cat >"$tmp/bin/nmcli" <<'EOF'
#!/bin/bash
case "$*" in
  "-g GENERAL.TYPE device show Meta") echo tun ;;
  "-g GENERAL.TYPE device show wg0") echo wireguard ;;
  "-g GENERAL.TYPE device show eth0") echo ethernet ;;
  "-g GENERAL.TYPE device show wlan0") echo wifi ;;
  "-g GENERAL.TYPE device show br0") echo bridge ;;
  "-g GENERAL.TYPE device show bond0") echo bond ;;
  *) exit 1 ;;
esac
EOF
cat >"$tmp/bin/omarchy-cmd-present" <<'EOF'
#!/bin/bash
exit 0
EOF
cat >"$tmp/bin/ping" <<'EOF'
#!/bin/bash
printf '64 bytes from test: time=1.25 ms\n'
EOF
chmod +x "$tmp/bin/"*

export TEST_ROUTES='[{"dev":"Meta","gateway":"198.18.0.2","metric":10},{"dev":"eth0","gateway":"10.0.11.1","metric":100}]'
export TEST_PROBE='[{"dev":"Meta","gateway":"198.18.0.2","prefsrc":"198.18.0.1"}]'
export TEST_ADDRS='[{"addr_info":[{"family":"inet","local":"10.0.11.181","prefixlen":24,"scope":"global"}]}]'
export TEST_GATEWAY_ROUTE='[{"dev":"eth0","prefsrc":"10.0.11.181"}]'

status=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status")
[[ $status == $'ethernet\teth0\t\t' ]] || fail "TUN leaves physical default visible" "$status"
pass "TUN leaves physical default visible"
verbose=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status" --verbose)
for expected in $'iface\teth0' $'ip\t10.0.11.181' $'prefix\t24' $'gateway\t10.0.11.1'; do
  grep -Fxq "$expected" <<<"$verbose" || fail "physical route details" "$verbose"
done
if grep -Fq 'route get 1.1.1.1' "$NETWORK_STATUS_IP_LOG"; then
  fail "physical route avoids policy-routed probe"
fi
pass "physical route details avoid policy-routed probe"

export TEST_ROUTES='[{"dev":"br0","gateway":"192.168.1.1","metric":425},{"dev":"wlan0","gateway":"192.168.1.1","metric":600}]'
export TEST_ADDRS='[{"addr_info":[{"family":"inet","local":"192.168.1.20","prefixlen":24,"scope":"global"}]}]'
status=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status")
[[ $status == $'ethernet\tbr0\t\t' ]] || fail "preferred bridge beats backup Wi-Fi" "$status"
pass "preferred bridge beats backup Wi-Fi"

export TEST_ROUTES='[{"dev":"Meta","gateway":"198.18.0.2","metric":10},{"dev":"bond0","gateway":"192.168.1.1","metric":300}]'
status=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status")
[[ $status == $'ethernet\tbond0\t\t' ]] || fail "bond default beats TUN" "$status"
pass "bond default beats TUN"

export TEST_ROUTES='[{"dev":"eth0","gateway":"192.168.1.1","metric":100,"flags":["dead"]},{"dev":"wlan0","gateway":"192.168.1.1","metric":600}]'
verbose=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status" --verbose)
grep -Fxq $'iface\twlan0' <<<"$verbose" || fail "dead route is skipped" "$verbose"
pass "dead route is skipped"

export TEST_ROUTES='[{"dev":"eth0","gateway":"192.168.2.1","metric":100}]'
export TEST_ADDRS='[{"addr_info":[{"family":"inet","local":"10.0.0.5","prefixlen":8,"scope":"global"},{"family":"inet","local":"192.168.2.50","prefixlen":24,"scope":"global"}]}]'
export TEST_GATEWAY_ROUTE='[{"dev":"eth0","prefsrc":"192.168.2.50"}]'
verbose=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status" --verbose)
grep -Fxq $'ip\t192.168.2.50' <<<"$verbose" || fail "gateway source address, not first address" "$verbose"
grep -Fxq $'prefix\t24' <<<"$verbose" || fail "prefix follows selected source address" "$verbose"
pass "gateway source and prefix match"

export TEST_ROUTES='[{"dev":"eth0","gateway":"192.168.2.1","prefsrc":"192.168.2.50","metric":100}]'
verbose=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status" --verbose)
grep -Fxq $'prefix\t24' <<<"$verbose" || fail "prefsrc prefix matches source" "$verbose"
pass "prefsrc prefix matches source"

export TEST_ROUTES='[]'
export TEST_PROBE='[{"dev":"Meta","gateway":"198.18.0.2","prefsrc":"198.18.0.1"}]'
status=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status")
[[ $status == $'ethernet\tMeta\t\t' ]] || fail "probe fallback without main default" "$status"
grep -Fxq -- '-j route get 1.1.1.1' "$NETWORK_STATUS_IP_LOG" || fail "probe fallback was not called"
pass "probe fallback without main default"
