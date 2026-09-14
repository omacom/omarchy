#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
mkdir -p "$stub_bin"
: >"$call_log"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
printf 'gum %s\n' "$*" >>"$CALL_LOG"
if [[ $1 == "confirm" ]]; then
  exit "${GUM_CONFIRM_STATUS:-0}"
fi
SH
chmod +x "$stub_bin/gum"

run_confirm() {
  : >"$call_log"
  PATH="$stub_bin:$PATH" \
    CALL_LOG="$call_log" \
    GUM_CONFIRM_STATUS="${1:-0}" \
    bash "$ROOT/bin/omarchy-update-confirm" >"$test_tmp/out" 2>&1
}

run_confirm 0 || fail "confirming the update proceeds"
grep -q 'Ready to update?' "$call_log" ||
  fail "the confirmation shows the update warning first"
grep -q 'cannot stop the update' "$call_log" ||
  fail "the confirmation warns the update cannot be stopped"
grep -q '^gum confirm Continue with update?$' "$call_log" ||
  fail "the confirmation asks to continue with the update"
pass "a confirmed update proceeds after the warning"

style_line=$(grep -n 'Ready to update?' "$call_log" | cut -d: -f1)
confirm_line=$(grep -n '^gum confirm' "$call_log" | cut -d: -f1)
((style_line < confirm_line)) ||
  fail "the warning is shown before asking to continue"
pass "the warning is shown before asking to continue"

if run_confirm 1; then
  fail "declining the update proceeds anyway"
fi
grep -q 'Update cancelled' "$test_tmp/out" ||
  fail "declining the update reports the cancellation"
pass "declining the update stops with a cancellation message"
