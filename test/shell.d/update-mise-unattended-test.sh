#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mise_log="$test_tmp/mise.log"
mkdir -p "$stub_bin"

cat >"$stub_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_MISE_LOG"
SH
chmod +x "$stub_bin/mise"

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == mise ]]
SH
chmod +x "$stub_bin/omarchy-cmd-present"

run_mise_update() {
  : >"$mise_log"
  TEST_MISE_LOG="$mise_log" PATH="$stub_bin:$PATH" "$@" "$ROOT/bin/omarchy-update-mise"
}

run_mise_update env -u OMARCHY_UPDATE_UNATTENDED
grep -Fx -- "up" "$mise_log" >/dev/null ||
  fail "interactive update runs mise up without --yes" "$(cat "$mise_log")"
pass "interactive update runs mise up without --yes"

run_mise_update env OMARCHY_UPDATE_UNATTENDED=1
grep -Fx -- "up --yes" "$mise_log" >/dev/null ||
  fail "unattended update passes --yes to mise up" "$(cat "$mise_log")"
pass "unattended update passes --yes to mise up"
