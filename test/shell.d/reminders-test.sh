#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Minutes typed with a leading zero are the same minutes: 08 is not octal, and
# the zero reaches neither the timer nor its messages.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
printf '#!/bin/bash\nprintf "systemd-run %%s\\n" "$*" >>"$TEST_LOG"\n' >"$tmp/bin/systemd-run"
printf '#!/bin/bash\nprintf "notify %%s\\n" "$*" >>"$TEST_LOG"\n' >"$tmp/bin/omarchy-notification-send"
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/omarchy-shell"
chmod +x "$tmp/bin"/*

TEST_LOG="$tmp/log" XDG_RUNTIME_DIR="$tmp" PATH="$tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-reminder" 08 >"$tmp/out" 2>&1 || fail "omarchy-reminder accepts 08 minutes" "$(cat "$tmp/out")"
[[ ! -s $tmp/out ]] || fail "omarchy-reminder sets 08 minutes without errors" "$(cat "$tmp/out")"
grep -q -- '--on-active=8m --unit=omarchy-reminder-8m-' "$tmp/log" || fail "a reminder for 08 minutes runs in 8 minutes" "$(cat "$tmp/log")"
grep -q 'Your 8 minutes are up' "$tmp/log" || fail "a reminder for 08 minutes says 8 minutes" "$(cat "$tmp/log")"
grep -q '^notify .*Reminder set for 8 minutes' "$tmp/log" || fail "the confirmation for 08 minutes says 8 minutes" "$(cat "$tmp/log")"
pass "omarchy-reminder reads minutes with a leading zero as decimal"
