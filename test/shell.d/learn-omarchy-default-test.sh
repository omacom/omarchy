#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -qxF learn-omarchy "$ROOT/install/omarchy-base.packages" ||
  fail "learn-omarchy ships in the base package set"
pass "a fresh install includes the interactive Learn Omarchy course"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/home"
export TEST_CALLS="$work/calls"
cat >"$work/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$TEST_CALLS"
[[ ${TEST_INSTALL_FAIL:-0} == 0 ]]
SH
chmod +x "$work/bin/omarchy-pkg-add"

migration="$ROOT/migrations/1789972045.sh"
run_migration() {
  HOME="$work/home" PATH="$work/bin:$PATH" bash -euo pipefail "$migration"
}
run_migration >/dev/null
run_migration >/dev/null
grep -Fx 'omarchy-pkg-add learn-omarchy' "$TEST_CALLS" >/dev/null ||
  fail "the migration installs learn-omarchy for existing installs"
pass "the migration installs learn-omarchy through the package helper"

if TEST_INSTALL_FAIL=1 run_migration >/dev/null 2>&1; then
  fail "a failed install must leave the migration pending"
fi
pass "a failed learn-omarchy install is propagated"

learn_toast="$ROOT/install/user/first-run/learn.sh"
grep -q -- '--exec uwsm-app -- learn-omarchy' "$learn_toast" ||
  fail "the first-login toast launches learn-omarchy when clicked"
grep -q 'first-run/learn.sh' "$ROOT/bin/omarchy-provision-first-run" ||
  fail "first-run shows the Learn Omarchy toast"
pass "first login invites the user to the interactive course"
