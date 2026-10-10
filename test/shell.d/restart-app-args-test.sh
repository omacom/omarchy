#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
mkdir -p "$mock_bin"

for tool in pkill setsid uwsm-app; do
  printf '#!/bin/bash\nprintf "%s %%s\\n" "$*" >>"$CALL_LOG"\n' "$tool" >"$mock_bin/$tool"
  chmod +x "$mock_bin/$tool"
done

run_restart_app() {
  CALL_LOG="$call_log" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-restart-app" "$@"
}

# Without an application name the script used to pkill nothing and spawn a
# bare `uwsm-app --` launcher with no application, exiting 0 throughout.
: >"$call_log"
if run_restart_app >/dev/null 2>"$test_tmp/stderr"; then
  fail "restart-app with no application name is rejected"
fi
grep -q 'Usage:' "$test_tmp/stderr" || fail "restart-app with no name prints usage" "$(cat "$test_tmp/stderr")"
if grep -q 'uwsm-app' "$call_log"; then
  fail "restart-app with no name never launches" "$(cat "$call_log")"
fi
pass "restart-app with no application name is rejected"

: >"$call_log"
run_restart_app myapp --flag
grep -q '^pkill -x -- myapp$' "$call_log" || fail "restart-app kills the named application" "$(cat "$call_log")"
# The relaunch is backgrounded, so its log line can land after the script exits.
relaunched=false
for ((attempt = 0; attempt < 100; attempt++)); do
  if grep -q '^setsid uwsm-app -- myapp --flag$' "$call_log"; then
    relaunched=true
    break
  fi
  sleep 0.01
done
[[ $relaunched == "true" ]] || fail "restart-app relaunches with the same arguments" "$(cat "$call_log")"
pass "restart-app kills and relaunches the named application"
