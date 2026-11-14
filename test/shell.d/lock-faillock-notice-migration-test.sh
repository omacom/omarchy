#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1792159654.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
stub="$tmp/bin"
mkdir -p "$stub"
cat >"$stub/omarchy-apply-lock" <<'SH'
#!/bin/bash
echo ran >>"$APPLY_CALLS"
[[ ${APPLY_FAILS:-false} != "true" ]]
SH
chmod +x "$stub/omarchy-apply-lock"

run_migration() {
  local pam="$1" calls="$2"
  shift 2
  OMARCHY_LOCK_PAM_FILE="$pam" APPLY_CALLS="$calls" PATH="$stub:$PATH" "$@" bash -euo pipefail "$migration"
}

silent="$tmp/silent"
printf 'auth required pam_faillock.so preauth silent deny=10 unlock_time=120\n' >"$silent"
calls="$tmp/calls-silent"
if run_migration "$silent" "$calls" env >/dev/null && [[ -f $calls ]]; then
  pass "a silent lock stack is rewritten through omarchy-apply-lock"
else
  fail "a silent lock stack is rewritten through omarchy-apply-lock"
fi

fixed="$tmp/fixed"
printf 'auth required pam_faillock.so preauth deny=10 unlock_time=120\n' >"$fixed"
calls="$tmp/calls-fixed"
if run_migration "$fixed" "$calls" env >/dev/null && [[ ! -f $calls ]]; then
  pass "an already rewritten stack is left alone"
else
  fail "an already rewritten stack is left alone"
fi

calls="$tmp/calls-missing"
if run_migration "$tmp/missing" "$calls" env >/dev/null && [[ ! -f $calls ]]; then
  pass "a machine without the lock stack is skipped"
else
  fail "a machine without the lock stack is skipped"
fi

calls="$tmp/calls-failed"
if ! output=$(run_migration "$silent" "$calls" env APPLY_FAILS=true 2>&1) && [[ $output == *"omarchy-migrate again from a terminal"* ]]; then
  pass "a rewrite that needs privileges keeps the migration pending"
else
  fail "a rewrite that needs privileges keeps the migration pending" "$output"
fi

if [[ $(stat -c '%a' "$migration") == "644" ]] && head -1 "$migration" | grep -q '^echo '; then
  pass "migration follows the file conventions"
else
  fail "migration follows the file conventions"
fi
