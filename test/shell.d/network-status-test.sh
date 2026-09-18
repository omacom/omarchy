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
  "-j -4 route show table main default")
    printf '%s\n' '[{"dst":"default","gateway":"198.18.0.2","dev":"Meta","prefsrc":"198.18.0.1","metric":10},{"dst":"default","gateway":"10.0.11.1","dev":"enp0s13f0u1u4c2","metric":100}]'
    ;;
  "-j route get 1.1.1.1")
    printf '%s\n' '[{"dst":"1.1.1.1","gateway":"198.18.0.2","dev":"Meta","prefsrc":"198.18.0.1"}]'
    ;;
  "-j addr show enp0s13f0u1u4c2")
    printf '%s\n' '[{"addr_info":[{"family":"inet","local":"10.0.11.181","prefixlen":24,"scope":"global"}]}]'
    ;;
  *)
    printf 'unexpected ip invocation: %s\n' "$*" >&2
    exit 1
    ;;
esac
EOF

cat >"$tmp/bin/nmcli" <<'EOF'
#!/bin/bash
case "$*" in
  "-g GENERAL.TYPE device show Meta")
    echo tun
    ;;
  "-g GENERAL.TYPE device show enp0s13f0u1u4c2")
    echo ethernet
    ;;
  *)
    printf 'unexpected nmcli invocation: %s\n' "$*" >&2
    exit 1
    ;;
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

chmod +x "$tmp/bin/ip" "$tmp/bin/nmcli" "$tmp/bin/omarchy-cmd-present" "$tmp/bin/ping"

output=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status")
[[ $output == $'ethernet\tenp0s13f0u1u4c2\t\t' ]] ||
  fail "network status reports the physical transport behind a TUN" "expected physical ethernet, got: $output"
pass "network status reports the physical transport behind a TUN"

verbose=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status" --verbose)
for expected in \
  $'iface\tenp0s13f0u1u4c2' \
  $'ip\t10.0.11.181' \
  $'prefix\t24' \
  $'gateway\t10.0.11.1' \
  $'type\tethernet'; do
  grep -Fxq "$expected" <<<"$verbose" ||
    fail "verbose network status reports physical route details" "missing '$expected' in:\n$verbose"
done
pass "verbose network status reports physical route details"

if grep -Fq "route get 1.1.1.1" "$NETWORK_STATUS_IP_LOG"; then
  fail "network status avoids policy-routed probes when a physical default exists"
fi
pass "network status avoids policy-routed probes when a physical default exists"
