#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
log="$test_tmp/calls.log"
home="$test_tmp/home"
mkdir -p "$mock_bin" "$home"
: >"$log"

cat >"$mock_bin/omarchy-theme-set-browser-policy" <<'SH'
#!/bin/bash
printf 'policy' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
(( ${POLICY_FAIL:-0} == 0 ))
SH

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/timeout" <<'SH'
#!/bin/bash
printf 'timeout' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
# Simulate a browser that never returns before the bound expires.
exit 124
SH

chmod +x "$mock_bin"/*

run_theme_browser() {
  PATH="$mock_bin:$PATH" \
    HOME="$home" \
    TEST_LOG="$log" \
    OMARCHY_PATH="$ROOT" \
    POLICY_FAIL="${POLICY_FAIL:-0}" \
    bash "$ROOT/bin/omarchy-theme-set-browser"
}

run_theme_browser

[[ $(grep -c '^policy' "$log") -eq 1 ]] ||
  fail "browser theme policy is still written before refreshes" "$(cat "$log")"

[[ $(grep -c '^timeout' "$log") -eq 5 ]] ||
  fail "every running Chromium-family browser refresh is bounded" "$(cat "$log")"

grep -Fqx $'timeout\t--kill-after=1s\t10s\tchromium\t--refresh-platform-policy\t--no-startup-window' "$log" ||
  fail "Chromium policy refresh has a hard ten-second bound" "$(cat "$log")"
grep -Fqx $'timeout\t--kill-after=1s\t10s\tgoogle-chrome-stable\t--refresh-platform-policy\t--no-startup-window' "$log" ||
  fail "Chrome policy refresh has a hard ten-second bound" "$(cat "$log")"
grep -Fqx $'timeout\t--kill-after=1s\t10s\tmicrosoft-edge-stable\t--refresh-platform-policy\t--no-startup-window' "$log" ||
  fail "Edge policy refresh has a hard ten-second bound" "$(cat "$log")"
grep -Fqx $'timeout\t--kill-after=1s\t10s\tbrave\t--refresh-platform-policy\t--no-startup-window' "$log" ||
  fail "Brave policy refresh has a hard ten-second bound" "$(cat "$log")"
grep -Fqx $'timeout\t--kill-after=1s\t10s\tbrave-origin\t--refresh-platform-policy\t--no-startup-window' "$log" ||
  fail "Brave Origin policy refresh has a hard ten-second bound" "$(cat "$log")"

! grep -q $'timeout\t--kill-after=1s\t10s\tgoogle-chrome\t' "$log" ||
  fail "a timed-out installed Chrome refresh does not launch the fallback binary" "$(cat "$log")"

pass "browser policy refresh timeouts cannot wedge theme updates"

: >"$log"
if POLICY_FAIL=1 run_theme_browser; then
  fail "browser refresh timeouts do not hide a policy write failure"
fi
[[ $(grep -c '^policy' "$log") -eq 1 ]] ||
  fail "failed policy write is attempted exactly once" "$(cat "$log")"
pass "browser policy write failures still propagate"
