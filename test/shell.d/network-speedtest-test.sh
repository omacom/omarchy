#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin" "$TMPDIR/sysfs/eth0/statistics"
echo 1000000 >"$TMPDIR/sysfs/eth0/statistics/rx_bytes"
echo 500000 >"$TMPDIR/sysfs/eth0/statistics/tx_bytes"

# api.fast.com fails the way it does where Netflix withdrew its OCA nodes;
# the Cloudflare endpoints answer the probe and then serve a bounded amount
# of traffic before closing, which is what ends the workers.
cat >"$TMPDIR/bin/curl" <<'SH'
#!/bin/bash

printf 'curl %s\n' "$*" >>"$CURL_LOG"

for arg in "$@"; do
  case "$arg" in
    *api.fast.com*)
      exit 22
      ;;
    *__down\?bytes=1000*)
      printf 'x'
      exit 0
      ;;
    *__down*)
      hits=$(wc -l <"$CURL_HITS" 2>/dev/null || echo 0)
      (( hits < 8 )) || exit 22
      printf 'hit\n' >>"$CURL_HITS"
      dd if=/dev/zero bs=1k count=64 2>/dev/null
      exit 0
      ;;
    *__up*)
      if [[ $* == *--data-binary\ probe* ]]; then
        exit 0
      fi
      hits=$(wc -l <"$CURL_HITS" 2>/dev/null || echo 0)
      (( hits < 8 )) || exit 22
      printf 'hit\n' >>"$CURL_HITS"
      cat >/dev/null
      exit 0
      ;;
  esac
done
exit 0
SH

cat >"$TMPDIR/bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$TMPDIR/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$TMPDIR/bin/curl" "$TMPDIR/bin/sleep" "$TMPDIR/bin/omarchy-cmd-present"

speedtest() {
  : >"$TMPDIR/curl.log"
  : >"$TMPDIR/hits"
  OMARCHY_SPEEDTEST_IFACE=eth0 OMARCHY_SPEEDTEST_SYSFS="$TMPDIR/sysfs" \
    CURL_LOG="$TMPDIR/curl.log" CURL_HITS="$TMPDIR/hits" \
    PATH="$TMPDIR/bin:$PATH" "$ROOT/bin/omarchy-network-speedtest" "$1"
}

# With api.fast.com down, the run falls back to Cloudflare instead of
# failing outright.
down_out=$(speedtest down)
grep -q "api.fast.com" "$TMPDIR/curl.log" ||
  fail "speedtest tries api.fast.com first" "$(cat "$TMPDIR/curl.log")"
grep -q "__down?bytes=1000" "$TMPDIR/curl.log" ||
  fail "speedtest probes the Cloudflare download endpoint" "$(cat "$TMPDIR/curl.log")"
grep -q "__down?bytes=25000000" "$TMPDIR/curl.log" ||
  fail "speedtest downloads from the Cloudflare fallback" "$(cat "$TMPDIR/curl.log")"
[[ -n $down_out ]] ||
  fail "speedtest still prints a rate with the fallback"
pass "speedtest falls back to Cloudflare when api.fast.com is unavailable"

# The upload direction falls back to the Cloudflare __up endpoint.
speedtest up >/dev/null
grep -q -- "--data-binary probe" "$TMPDIR/curl.log" ||
  fail "speedtest probes the Cloudflare upload endpoint" "$(cat "$TMPDIR/curl.log")"
grep -qE "POST .*__up|__up" "$TMPDIR/curl.log" ||
  fail "speedtest uploads to the Cloudflare fallback" "$(cat "$TMPDIR/curl.log")"
pass "speedtest falls back to Cloudflare for uploads"

# When api.fast.com answers, the fallback is never contacted.
cat >"$TMPDIR/bin/curl" <<'SH'
#!/bin/bash

printf 'curl %s\n' "$*" >>"$CURL_LOG"

for arg in "$@"; do
  case "$arg" in
    *api.fast.com*)
      printf '{"targets":[{"url":"https://oca.example.com/one"},{"url":"https://oca.example.com/two"}]}'
      exit 0
      ;;
    *speed.cloudflare.com*)
      exit 99
      ;;
    *oca.example.com*)
      hits=$(wc -l <"$CURL_HITS" 2>/dev/null || echo 0)
      (( hits < 8 )) || exit 22
      printf 'hit\n' >>"$CURL_HITS"
      dd if=/dev/zero bs=1k count=64 2>/dev/null
      exit 0
      ;;
  esac
done
exit 0
SH
chmod +x "$TMPDIR/bin/curl"

speedtest down >/dev/null
grep -q "oca.example.com" "$TMPDIR/curl.log" ||
  fail "speedtest uses the api.fast.com endpoints when available" "$(cat "$TMPDIR/curl.log")"
! grep -q "speed.cloudflare.com" "$TMPDIR/curl.log" ||
  fail "speedtest does not contact the fallback when api.fast.com works" "$(cat "$TMPDIR/curl.log")"
pass "speedtest leaves the fallback alone when api.fast.com works"

# When both are unreachable the run still fails with the readable error.
cat >"$TMPDIR/bin/curl" <<'SH'
#!/bin/bash
exit 22
SH
chmod +x "$TMPDIR/bin/curl"

if speedtest down >/dev/null 2>"$TMPDIR/err"; then
  fail "speedtest fails when every endpoint is unreachable"
fi
grep -q "Failed to fetch speed test endpoints" "$TMPDIR/err" ||
  fail "speedtest keeps the readable error when everything fails" "$(cat "$TMPDIR/err")"
pass "speedtest keeps the readable error when every endpoint fails"
