#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_dir="$test_tmp/bin"
call_log="$test_tmp/curl-calls"
mkdir -p "$stub_dir"

cat >"$stub_dir/ip" <<'SH'
#!/bin/bash
printf '%s\n' '1.1.1.1 via 127.0.0.1 dev lo src 127.0.0.1'
SH

cat >"$stub_dir/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_dir/curl" <<'SH'
#!/bin/bash
for arg in "$@"; do
  if [[ $arg == https://api.fast.com/* ]]; then
    printf '%s\n' "$FAST_API_RESPONSE"
    exit 0
  fi
done

printf '%q ' "$@" >>"$CALL_LOG"
printf '\n' >>"$CALL_LOG"
exit 22
SH

chmod +x "$stub_dir/"*

FAST_API_RESPONSE='{"targets":[{"url":"http://127.0.0.1/internal"},{"url":"--url=http://169.254.169.254/latest/meta-data/"},{"url":"https://example.com/"},{"url":"https://fast.com.example.com/"},{"url":"https://fast.com:8443/"},{"url":"https://edge.oca.nflxvideo.net/speedtest/range/0-1"}]}' \
  CALL_LOG="$call_log" PATH="$stub_dir:$ROOT/bin:/usr/bin:/bin" \
  "$ROOT/bin/omarchy-network-speedtest" down >"$test_tmp/out" 2>"$test_tmp/err"

grep -Fq -- '-- https://edge.oca.nflxvideo.net/speedtest/range/0-1' "$call_log" ||
  fail "network speedtest terminates curl options before a validated target" "$(cat "$call_log")"
if grep -Eq '127\.0\.0\.1|169\.254\.169\.254|--url=|example\.com|:8443/' "$call_log"; then
  fail "network speedtest rejects non-vendor and option-like API targets" "$(cat "$call_log")"
fi
pass "network speedtest accepts only HTTPS targets on Fast vendor domains"

: >"$call_log"
if FAST_API_RESPONSE='{"targets":[{"url":"http://127.0.0.1/internal"}]}' \
  CALL_LOG="$call_log" PATH="$stub_dir:$ROOT/bin:/usr/bin:/bin" \
  "$ROOT/bin/omarchy-network-speedtest" down >"$test_tmp/out" 2>"$test_tmp/err"; then
  fail "network speedtest refuses a response with no valid targets"
fi
grep -Fq 'Failed to fetch valid speed test endpoints' "$test_tmp/err" ||
  fail "network speedtest explains that no valid target was returned" "$(cat "$test_tmp/err")"
[[ ! -s $call_log ]] || fail "network speedtest makes no target request after rejecting every API target" "$(cat "$call_log")"
pass "network speedtest fails closed when the API returns no valid target"
