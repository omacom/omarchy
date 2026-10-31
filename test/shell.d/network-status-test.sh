#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/timeout" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$TIMEOUT_LOG"
exit "${TCP_STATUS:-0}"
SH

cat >"$stub_bin/ping" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$PING_LOG"
printf '64 bytes from %s: icmp_seq=1 ttl=54 time=17.4 ms\n' "$2"
SH

chmod +x "$stub_bin"/*

PATH="$stub_bin:$ROOT/bin:$PATH"
# shellcheck disable=SC1091
source "$ROOT/bin/omarchy-network-status"

: >"$tmp_dir/timeout.log"
: >"$tmp_dir/ping.log"
ms=$(TCP_STATUS=0 TIMEOUT_LOG="$tmp_dir/timeout.log" PING_LOG="$tmp_dir/ping.log" ping_latency_ms 1.1.1.1 443)
[[ $ms =~ ^[0-9]+(\.[0-9]+)?$ ]] || fail "TCP connect reports latency in ms" "$ms"
awk -v ms="$ms" 'BEGIN { exit !(ms + 0 > 0 && ms + 0 < 900) }' || fail "TCP connect latency is a short round trip" "$ms"
[[ ! -s $tmp_dir/ping.log ]] || fail "TCP success does not fall back to ICMP" "$(cat "$tmp_dir/ping.log")"
grep -Fq '/dev/tcp/1.1.1.1/443' "$tmp_dir/timeout.log" || fail "TCP connect targets the requested host and port" "$(cat "$tmp_dir/timeout.log")"
pass "TCP connect reports latency without ICMP"

: >"$tmp_dir/timeout.log"
: >"$tmp_dir/ping.log"
ms=$(TCP_STATUS=124 TIMEOUT_LOG="$tmp_dir/timeout.log" PING_LOG="$tmp_dir/ping.log" ping_latency_ms 1.1.1.1 443)
[[ $ms == "17.4" ]] || fail "a TCP timeout falls back to ICMP" "$ms"
pass "a TCP timeout falls back to ICMP"

: >"$tmp_dir/timeout.log"
: >"$tmp_dir/ping.log"
ms=$(TCP_STATUS=1 TIMEOUT_LOG="$tmp_dir/timeout.log" PING_LOG="$tmp_dir/ping.log" ping_latency_ms 10.0.0.1 80)
[[ $ms =~ ^[0-9]+(\.[0-9]+)?$ ]] || fail "a refused TCP connect still counts as a round trip" "$ms"
[[ ! -s $tmp_dir/ping.log ]] || fail "a refused TCP connect does not fall back to ICMP" "$(cat "$tmp_dir/ping.log")"
pass "a refused TCP connect still counts as a round trip"

: >"$tmp_dir/timeout.log"
: >"$tmp_dir/ping.log"
ms=$(TIMEOUT_LOG="$tmp_dir/timeout.log" PING_LOG="$tmp_dir/ping.log" ping_latency_ms fe80::1 80)
[[ $ms == "17.4" ]] || fail "IPv6 targets skip /dev/tcp and use ICMP" "$ms"
[[ ! -s $tmp_dir/timeout.log ]] || fail "IPv6 targets do not use /dev/tcp" "$(cat "$tmp_dir/timeout.log")"
pass "IPv6 targets skip /dev/tcp and use ICMP"
