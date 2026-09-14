#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1788596255.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
fake_home="$test_tmp/home"
mkdir -p "$stub_bin" "$fake_home"
: >"$call_log"

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$stub_bin/omarchy-pkg-add"

run_migration() {
  PATH="$stub_bin:$PATH" \
    CALL_LOG="$call_log" \
    HOME="$fake_home" \
    OMARCHY_PATH="$ROOT" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration || fail "the migration installs vi as a standard terminal editor"
grep -qxF 'pkg-add vi' "$call_log" ||
  fail "the migration requests the vi package"
pass "the migration installs vi as a standard terminal editor"

run_migration || fail "the migration fails when run a second time"
[[ $(grep -cxF 'pkg-add vi' "$call_log") == 2 ]] ||
  fail "the migration requests vi exactly once per run"
pass "the migration repeats cleanly"
