#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1792716821.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash
[[ ${RTKIT_MISSING:-0} == 1 ]]
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALL_LOG"
[[ ${PKG_ADD_FAILS:-0} == 0 ]] || exit 1
RTKIT_INSTALLED=1
printf '1\n' >"$INSTALLED_MARKER"
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$stub_bin"/*

export CALL_LOG="$test_tmp/calls"
export INSTALLED_MARKER="$test_tmp/installed"
export PATH="$stub_bin:$PATH"

: >"$CALL_LOG"
RTKIT_MISSING=1 bash -euo pipefail "$migration" >/dev/null
expected=$'pkg-add rtkit\nsystemctl --user try-restart xdg-desktop-portal.service'
[[ $(cat "$CALL_LOG") == "$expected" ]] ||
  fail "missing rtkit is installed and xdg-desktop-portal is restarted" "$(cat "$CALL_LOG")"
pass "missing rtkit is installed and xdg-desktop-portal is restarted"

: >"$CALL_LOG"
RTKIT_MISSING=0 bash -euo pipefail "$migration" >/dev/null
[[ ! -s $CALL_LOG ]] ||
  fail "an already-installed rtkit leaves xdg-desktop-portal alone" "$(cat "$CALL_LOG")"
pass "an already-installed rtkit leaves xdg-desktop-portal alone"

: >"$CALL_LOG"
if RTKIT_MISSING=1 PKG_ADD_FAILS=1 bash -euo pipefail "$migration" >/dev/null 2>&1; then
  fail "a failed rtkit install fails the migration so it stays pending"
fi
[[ $(cat "$CALL_LOG") == "pkg-add rtkit" ]] ||
  fail "a failed rtkit install stops before restarting xdg-desktop-portal" "$(cat "$CALL_LOG")"
pass "a failed rtkit install fails the migration so it stays pending"
