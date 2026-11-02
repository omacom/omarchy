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
if [[ ${1:-} == "up" && ${MISE_UP_FAIL:-} == "1" ]] ||
  [[ ${1:-} == "prune" && ${MISE_PRUNE_FAIL:-} == "1" ]]; then
  exit 1
fi
STUB
chmod +x "$mock_bin/mise"

run_update_mise() {
  MISE_LOG="$test_tmp/mise.log" \
    MISE_UP_FAIL="${1:-}" \
    MISE_PRUNE_FAIL="${2:-}" \
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

: >"$test_tmp/mise.log"
run_update_mise "" 1 || fail "a failed mise prune reports an update failure"
[[ $(<"$test_tmp/mise.log") == $'up\nprune --tools' ]] ||
  fail "a failed mise prune does not follow a successful update" "$(<"$test_tmp/mise.log")"
grep -q 'Could not prune unused mise tool versions.' "$test_tmp/err" ||
  fail "a failed mise prune does not warn"
pass "a failed mise prune warns without failing the update"
