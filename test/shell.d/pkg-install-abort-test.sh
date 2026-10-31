#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

stub_bin="$TMPDIR/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
case ${1:-} in
  -v) exit "${SUDO_VALIDATE_RESULT:-0}" ;;
  -n) exit 0 ;;
esac
exec "$@"
STUB

# The sudo keepalive loop sleeps between refreshes, and its trap kills the loop
# without reaping an in-flight sleep. Keep the stub short so test runs do not
# leave a minute of stray sleeps behind. command -p skips the stub PATH.
cat >"$stub_bin/sleep" <<'STUB'
#!/bin/bash
command -p sleep 0.2
STUB

cat >"$stub_bin/fzf" <<'STUB'
#!/bin/bash
echo testpkg
STUB

cat >"$stub_bin/omarchy-show-done" <<'STUB'
#!/bin/bash
echo "done ${1:-0}" >>"${CALL_LOG:?}"
STUB

cat >"$stub_bin/updatedb" <<'STUB'
#!/bin/bash
echo updatedb >>"${CALL_LOG:?}"
STUB

cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
if [[ $1 == "-Slq" ]]; then
  echo testpkg
  exit 0
fi
echo "pacman $*" >>"${CALL_LOG:?}"
exit "${PACMAN_RESULT:-0}"
STUB

cat >"$stub_bin/yay" <<'STUB'
#!/bin/bash
if [[ $1 == "-Slqa" ]]; then
  echo testpkg
  exit 0
fi
echo "yay $*" >>"${CALL_LOG:?}"
exit "${YAY_RESULT:-0}"
STUB

chmod +x "$stub_bin"/*

run_pkg_install() {
  : >"$call_log"
  CALL_LOG="$call_log" PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$TMPDIR/home" \
    bash "$ROOT/bin/omarchy-pkg-install" >/dev/null 2>&1
}

run_pkg_aur_install() {
  : >"$call_log"
  CALL_LOG="$call_log" PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$TMPDIR/home" \
    bash "$ROOT/bin/omarchy-pkg-aur-install" >/dev/null 2>&1
}

mkdir -p "$TMPDIR/home"

# A successful pacman run still reports done.
call_log="$TMPDIR/calls-success"
PACMAN_RESULT=0 run_pkg_install || fail "pkg-install exits clean on successful install"
grep -q '^done 0$' "$call_log" || fail "pkg-install reports done on successful install"
pass "pkg-install reports done on successful install"

# A pacman run that exits non-zero (dependency conflict, download failure)
# hands its status to the done prompt, which shows it as a failure.
call_log="$TMPDIR/calls-failure"
PACMAN_RESULT=1 run_pkg_install || true
grep -q '^done [1-9]' "$call_log" || fail "pkg-install reports a failed install as failed"
pass "pkg-install reports a failed install as failed"

# An interrupt at the initial sudo validation (the first password prompt) must
# stop before the package transaction starts, and close without a keypress
# since there is nothing to read.
call_log="$TMPDIR/calls-sudo-abort"
if SUDO_VALIDATE_RESULT=1 run_pkg_install; then
  fail "pkg-install exits non-zero when sudo validation is interrupted"
fi
grep -q '^pacman ' "$call_log" && fail "pkg-install skips the pacman transaction when sudo validation is interrupted"
grep -q '^done' "$call_log" && fail "pkg-install closes without a prompt when sudo validation is interrupted"
pass "pkg-install aborts before the transaction when sudo validation is interrupted"

# A successful yay run reports done and refreshes the file database.
call_log="$TMPDIR/aur-calls-success"
YAY_RESULT=0 run_pkg_aur_install || fail "pkg-aur-install exits clean on successful install"
grep -q '^done 0$' "$call_log" || fail "pkg-aur-install reports done on successful install"
pass "pkg-aur-install reports done on successful install"
grep -q '^updatedb$' "$call_log" || fail "pkg-aur-install refreshes file database on success"
pass "pkg-aur-install refreshes file database on success"

# A failed yay run reports its own status, not updatedb's.
call_log="$TMPDIR/aur-calls-failure"
YAY_RESULT=1 run_pkg_aur_install || true
grep -q '^done [1-9]' "$call_log" || fail "pkg-aur-install reports a failed install as failed"
pass "pkg-aur-install reports a failed install as failed"

# The same initial sudo validation interrupt must stop the AUR flow before yay.
call_log="$TMPDIR/aur-calls-sudo-abort"
if SUDO_VALIDATE_RESULT=1 run_pkg_aur_install; then
  fail "pkg-aur-install exits non-zero when sudo validation is interrupted"
fi
grep -q '^yay ' "$call_log" && fail "pkg-aur-install skips the yay transaction when sudo validation is interrupted"
grep -q '^updatedb$' "$call_log" && fail "pkg-aur-install skips updatedb when sudo validation is interrupted"
grep -q '^done' "$call_log" && fail "pkg-aur-install closes without a prompt when sudo validation is interrupted"
pass "pkg-aur-install aborts before the transaction when sudo validation is interrupted"
