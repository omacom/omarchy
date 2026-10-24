#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/mise" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$MISE_LOG"
[[ ${1:-} != "up" || ${MISE_UP_FAIL:-} != "1" ]]
STUB
chmod +x "$mock_bin/mise"

run_update_mise() {
  MISE_LOG="$test_tmp/mise.log" \
    MISE_UP_FAIL="${1:-}" \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-update-mise" >"$test_tmp/out" 2>"$test_tmp/err"
}

: >"$test_tmp/mise.log"
run_update_mise || fail "a successful mise update reports a failure"
[[ $(<"$test_tmp/mise.log") == $'up\nprune --tools' ]] ||
  fail "a successful mise update prunes only unused tool versions" "$(<"$test_tmp/mise.log")"
pass "a successful mise update prunes unused tool versions"

: >"$test_tmp/mise.log"
if run_update_mise 1; then
  fail "a failed mise update reports success"
fi
[[ $(<"$test_tmp/mise.log") == "up" ]] ||
  fail "a failed mise update attempts pruning" "$(<"$test_tmp/mise.log")"
pass "a failed mise update does not prune"
