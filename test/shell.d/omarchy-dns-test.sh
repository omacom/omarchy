#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-dns sets DNS on every wifi/ethernet profile. NetworkManager refuses
# ipv4.dns on a shared-method profile (a hotspot), and under set -e that aborts
# the run before resolved.conf is written. The helpers are loaded without the
# dispatch at the end, which parses $1 and needs root.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

lib="$test_tmp/omarchy-dns-helpers.sh"
sed '/^if (( \$# == 0 ))/,$d' "$ROOT/bin/omarchy-dns" >"$lib"

stub_bin="$test_tmp/bin"
calls="$test_tmp/nmcli.log"
mkdir -p "$stub_bin"

cat >"$stub_bin/nmcli" <<'SH'
#!/bin/bash
case "$*" in
  "-t -f UUID,TYPE connection show") printf '%s\n' "hot:802-11-wireless" "wired:802-3-ethernet" ;;
  "-g ipv4.method connection show hot") echo shared ;;
  "-g ipv4.method connection show wired") echo auto ;;
  connection\ modify\ hot\ *)
    echo "Error: Failed to modify connection 'hot': ipv4.dns: this property is not allowed for 'method=shared'" >&2
    exit 8
    ;;
  connection\ modify\ *) printf '%s\n' "$*" >>"$TEST_CALLS" ;;
esac
SH
chmod +x "$stub_bin/nmcli"

# Each helper runs in its own shell with set -e, as it does inside omarchy-dns.
run_helper() {
  PATH="$stub_bin:$PATH" TEST_CALLS="$calls" bash -c 'source "$1"; shift; "$@"' _ "$lib" "$@"
}

: >"$calls"
run_helper set_connection_dns "1.1.1.1 1.0.0.1" "2606:4700:4700::1111" ||
  fail "set_connection_dns gets past a shared hotspot profile"
grep -q '^connection modify wired ipv4.ignore-auto-dns yes ' "$calls" &&
  ! grep -q 'modify hot' "$calls" ||
  fail "set_connection_dns sets DNS on the ordinary profile only" "got: $(<"$calls")"
pass "set_connection_dns skips shared hotspot profiles and sets ordinary ones"

: >"$calls"
run_helper clear_connection_dns ||
  fail "clear_connection_dns gets past a shared hotspot profile"
grep -q '^connection modify wired ipv4.ignore-auto-dns no ' "$calls" &&
  ! grep -q 'modify hot' "$calls" ||
  fail "clear_connection_dns clears the ordinary profile only" "got: $(<"$calls")"
pass "clear_connection_dns skips shared hotspot profiles and clears ordinary ones"
