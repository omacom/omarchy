#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The speed test asks Fast.com for a list of download targets and hands them
# to curl. The answer comes from the network, so the transfer is bounded and
# only https targets are used: a response that never ends must not fill
# memory, and a hijacked or malformed answer must not point the transfer
# somewhere else.

stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT

cat >"$stub_dir/ip" <<'SH'
#!/bin/bash
echo "1.1.1.1 via 192.0.2.1 dev lo src 1.1.1.1"
SH

cat >"$stub_dir/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

# The endpoint answer is what a hostile or hijacked response looks like: a
# target that is not https, far more targets than the script asked for, a
# target that would be split on whitespace or expanded as a glob, and a body
# that keeps going. Every argument is logged on its own line, so the
# boundaries the application receives are visible.
cat >"$stub_dir/curl" <<'SH'
#!/bin/bash
for argument in "$@"; do
  case "$argument" in
    *api.fast.com*)
      printf 'api\n' >>"$CURL_LOG"
      printf '%s\n' "$@" >>"$CURL_LOG"
      if [[ -n ${TEST_OVERSIZED:-} ]]; then
        # A body that is larger than the cap, and that would parse if it
        # reached the parser whole.
        printf '{"targets":['
        for number in $(seq 1 20000); do
          printf '{"url":"https://192.0.2.1/target-%s"},' "$number"
        done
        printf '{"url":"https://192.0.2.1/last"}]}'
        exit 0
      fi
      printf '{"targets":[{"url":"file:///etc/shadow"},{"url":"http://192.0.2.1/payload"}'
      printf ',{"url":"https://192.0.2.1/target with space"}'
      printf ',{"url":"https://192.0.2.1/target*glob"}'
      for number in $(seq 1 200); do
        printf ',{"url":"https://192.0.2.1/target-%s"}' "$number"
      done
      printf ']}'
      exit 0
      ;;
  esac
done
# The arguments the transfer received, one per line, so a target that was
# split or expanded shows up as more than one line.
printf '%s\n' "$@" >>"$CURL_TARGETS"
# Each worker walks the list it was given, so the download fails only after
# that many targets. The counter is per worker, keyed by the parent process.
counter="$CURL_COUNTS/$PPID"
calls=$(cat "$counter" 2>/dev/null || echo 0)
calls=$((calls + 1))
echo "$calls" >"$counter"
(( calls > 3 )) && exit 1
exit 0
SH
chmod +x "$stub_dir/ip" "$stub_dir/curl" "$stub_dir/omarchy-cmd-present"

mkdir -p "$stub_dir/counts"

run_speedtest() {
  local log=$1 targets=$2
  : >"$log"
  : >"$targets"
  PATH="$stub_dir:$PATH" OMARCHY_PATH="$ROOT" CURL_LOG="$log" CURL_TARGETS="$targets" \
    CURL_COUNTS="$stub_dir/counts" bash "$ROOT/bin/omarchy-network-speedtest" down >/dev/null 2>&1
}

log="$stub_dir/calls"
targets_log="$stub_dir/targets"
run_speedtest "$log" "$targets_log" || true

# The endpoint fetch carries a bound, so an answer that never ends cannot hold
# the transfer open indefinitely.
grep -q 'api' "$log" || fail "the endpoint was fetched" "$(cat "$log")"
grep -q -- '--max-time' "$log" || fail "the endpoint fetch is bounded in time" "$(cat "$log")"
grep -q -- '--max-filesize' "$log" || fail "the endpoint fetch is bounded in size" "$(cat "$log")"
pass "the endpoint fetch is bounded in time and in size"

# Only https targets are transferred, and no target outside the scheme the
# script asked for is ever handed to curl.
! grep -q 'file:///etc/shadow' "$targets_log" || fail "a non-https target is never transferred" "$(cat "$targets_log")"
! grep -q 'http://192.0.2.1/payload' "$targets_log" || fail "a plain http target is never transferred" "$(cat "$targets_log")"
pass "only https targets are transferred"

# The script asked the endpoint for three targets, and it transfers those
# three: a response that names hundreds does not turn into hundreds of
# transfers, and a script that kept only the first target would fail here.
transferred=$(grep '^https://' "$targets_log" | sort -u)
(( $(wc -l <<<"$transferred") == 3 )) ||
  fail "the targets the script asked for are the ones it transfers" "$(cat "$targets_log")"
for target in 'https://192.0.2.1/target with space' 'https://192.0.2.1/target*glob' 'https://192.0.2.1/target-1'; do
  grep -qxF "$target" <<<"$transferred" ||
    fail "the targets the script asked for are the ones it transfers" "$(cat "$targets_log")"
done
pass "the targets the script asked for are the ones it transfers"

# A target keeps its boundaries: a target with whitespace in it is not split
# into two arguments and a target with a glob in it is not expanded.
grep -qxF 'https://192.0.2.1/target with space' "$targets_log" ||
  fail "a target with whitespace in it reaches the transfer whole" "$(cat "$targets_log")"
grep -qxF 'https://192.0.2.1/target*glob' "$targets_log" ||
  fail "a target with a glob in it reaches the transfer whole" "$(cat "$targets_log")"
pass "a target keeps its boundaries on the way to the transfer"

# An answer that is larger than the cap is refused, and nothing is
# transferred from it.
oversized_log="$stub_dir/oversized-calls"
oversized_targets="$stub_dir/oversized-targets"
TEST_OVERSIZED=1 run_speedtest "$oversized_log" "$oversized_targets" || true
[[ ! -s $oversized_targets ]] ||
  fail "an oversized answer is refused instead of transferred" "$(cat "$oversized_targets")"
pass "an oversized answer is refused instead of transferred"
