#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$stub_bin" "$test_home"

SUDO_LOG="$test_tmp/sudo.log"
PACMAN_KEY_LOG="$test_tmp/pacman-key.log"
PACMAN_LOG="$test_tmp/pacman.log"
PKG_ADD_LOG="$test_tmp/pkg-add.log"
: >"$SUDO_LOG"
: >"$PACMAN_KEY_LOG"
: >"$PACMAN_LOG"
: >"$PKG_ADD_LOG"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

reset_logs() {
  : >"$SUDO_LOG"
  : >"$PACMAN_KEY_LOG"
  : >"$PACMAN_LOG"
  : >"$PKG_ADD_LOG"
}

write_stub omarchy-pkg-missing 'exit 0'
write_stub omarchy-pkg-present 'exit 1'
write_stub omarchy-cmd-missing 'exit 1'

write_stub pacman-key '
printf "%s\n" "$*" >>"${PACMAN_KEY_LOG:-/dev/null}"
if [[ $* == *--recv-keys* ]]; then
  exit "${TEST_RECV_EXIT:-0}"
fi
if [[ $* == *--list-keys* ]]; then
  exit "${TEST_LIST_EXIT:-0}"
fi
exit 0'

write_stub pacman '
printf "%s\n" "$*" >>"${PACMAN_LOG:-/dev/null}"
if [[ $* == *archlinux-keyring* ]]; then
  exit "${TEST_ARCH_EXIT:-0}"
fi
exit 0'

write_stub omarchy-pkg-add '
printf "%s\n" "$*" >>"${PKG_ADD_LOG:-/dev/null}"
exit "${TEST_PKG_ADD_EXIT:-0}"'

write_stub sudo '
printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"
if [[ ${1:-} == "-n" && ${2:-} == "true" && $# -eq 2 ]]; then
  exit "${TEST_SUDO_N_TRUE_EXIT:-0}"
fi
exec "$@"'

export SUDO_LOG PACMAN_KEY_LOG PACMAN_LOG PKG_ADD_LOG

run_keyring() {
  HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-keyring"
}

# Success: unattended with auth, full sequence, Keys correct exactly once.
reset_logs
set +e
export OMARCHY_UPDATE_UNATTENDED="1"
export TEST_SUDO_N_TRUE_EXIT="0"
export TEST_RECV_EXIT="0"
export TEST_LIST_EXIT="0"
export TEST_ARCH_EXIT="0"
export TEST_PKG_ADD_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-keyring" >"$test_tmp/success.out" 2>"$test_tmp/success.err"
success_status=$?
set -e
(( success_status == 0 )) || fail "keyring success exits 0" "got $success_status; err=$(cat "$test_tmp/success.err")"
(( $(grep -c '^Keys are correct$' "$test_tmp/success.out") == 1 )) || fail "keyring success prints Keys are correct exactly once" "$(cat "$test_tmp/success.out")"
grep -q -- '--recv-keys' "$SUDO_LOG" || fail "keyring success receives keys" "$(cat "$SUDO_LOG")"
grep -q -- '--lsign-key' "$SUDO_LOG" || fail "keyring success signs keys" "$(cat "$SUDO_LOG")"
grep -q -- 'archlinux-keyring' "$SUDO_LOG" || fail "keyring success installs archlinux-keyring" "$(cat "$SUDO_LOG")"
recv_line=$(grep -n -- '--recv-keys' "$SUDO_LOG" | head -n 1 | cut -d: -f1)
lsign_line=$(grep -n -- '--lsign-key' "$SUDO_LOG" | head -n 1 | cut -d: -f1)
arch_line=$(grep -n -- 'archlinux-keyring' "$SUDO_LOG" | head -n 1 | cut -d: -f1)
(( recv_line < lsign_line )) || fail "keyring success receives before signing" "$(cat "$SUDO_LOG")"
(( lsign_line < arch_line )) || fail "keyring success signs before archlinux-keyring install" "$(cat "$SUDO_LOG")"
pass "keyring success prints Keys are correct once with sane sequence"

# Unattended no-auth: probe fails, nonzero before any recv attempt.
reset_logs
set +e
export OMARCHY_UPDATE_UNATTENDED="1"
export TEST_SUDO_N_TRUE_EXIT="1"
export TEST_RECV_EXIT="0"
export TEST_LIST_EXIT="0"
export TEST_ARCH_EXIT="0"
export TEST_PKG_ADD_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-keyring" >"$test_tmp/noauth.out" 2>"$test_tmp/noauth.err"
noauth_status=$?
set -e
(( noauth_status != 0 )) || fail "unattended no-auth exits nonzero" "got 0"
grep -q -- '--recv-keys' "$SUDO_LOG" && fail "unattended no-auth never attempts recv-keys" "$(cat "$SUDO_LOG")"
grep -q 'sudo -n' "$test_tmp/noauth.err" || fail "unattended no-auth reports actionable sudo message" "$(cat "$test_tmp/noauth.err")"
grep -q '^Keys are correct$' "$test_tmp/noauth.out" && fail "unattended no-auth prints no success" "$(cat "$test_tmp/noauth.out")"
pass "unattended no-auth fails before recv-keys without false success"

# Unattended with auth but recv failure: nonzero, no Keys-correct.
reset_logs
set +e
export OMARCHY_UPDATE_UNATTENDED="1"
export TEST_SUDO_N_TRUE_EXIT="0"
export TEST_RECV_EXIT="1"
export TEST_LIST_EXIT="0"
export TEST_ARCH_EXIT="0"
export TEST_PKG_ADD_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-keyring" >"$test_tmp/recvfail.out" 2>"$test_tmp/recvfail.err"
recvfail_status=$?
set -e
(( recvfail_status != 0 )) || fail "recv failure exits nonzero" "got 0"
grep -q '^Keys are correct$' "$test_tmp/recvfail.out" && fail "recv failure prints no success" "$(cat "$test_tmp/recvfail.out")"
pass "recv failure propagates without false success"

# Archlinux-keyring install failure: nonzero, no Keys-correct.
reset_logs
set +e
export OMARCHY_UPDATE_UNATTENDED="1"
export TEST_SUDO_N_TRUE_EXIT="0"
export TEST_RECV_EXIT="0"
export TEST_LIST_EXIT="0"
export TEST_ARCH_EXIT="1"
export TEST_PKG_ADD_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-keyring" >"$test_tmp/archfail.out" 2>"$test_tmp/archfail.err"
archfail_status=$?
set -e
(( archfail_status != 0 )) || fail "archlinux-keyring failure exits nonzero" "got 0"
grep -q '^Keys are correct$' "$test_tmp/archfail.out" && fail "archlinux-keyring failure prints no success" "$(cat "$test_tmp/archfail.out")"
pass "archlinux-keyring failure propagates without false success"

# omarchy-pkg-add failure: nonzero, no Keys-correct.
reset_logs
set +e
export OMARCHY_UPDATE_UNATTENDED="1"
export TEST_SUDO_N_TRUE_EXIT="0"
export TEST_RECV_EXIT="0"
export TEST_LIST_EXIT="0"
export TEST_ARCH_EXIT="0"
export TEST_PKG_ADD_EXIT="1"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-keyring" >"$test_tmp/pkgaddfail.out" 2>"$test_tmp/pkgaddfail.err"
pkgaddfail_status=$?
set -e
(( pkgaddfail_status != 0 )) || fail "omarchy-pkg-add failure exits nonzero" "got 0"
grep -q '^Keys are correct$' "$test_tmp/pkgaddfail.out" && fail "omarchy-pkg-add failure prints no success" "$(cat "$test_tmp/pkgaddfail.out")"
pass "omarchy-pkg-add failure propagates without false success"

# Interactive (no UNATTENDED): no early -n precheck, success path.
reset_logs
set +e
unset OMARCHY_UPDATE_UNATTENDED
export TEST_SUDO_N_TRUE_EXIT="1"
export TEST_RECV_EXIT="0"
export TEST_LIST_EXIT="0"
export TEST_ARCH_EXIT="0"
export TEST_PKG_ADD_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-keyring" >"$test_tmp/interactive.out" 2>"$test_tmp/interactive.err"
interactive_status=$?
set -e
(( interactive_status == 0 )) || fail "interactive keyring exits 0 without precheck" "got $interactive_status; err=$(cat "$test_tmp/interactive.err")"
(( $(grep -c '^Keys are correct$' "$test_tmp/interactive.out") == 1 )) || fail "interactive keyring prints Keys are correct once" "$(cat "$test_tmp/interactive.out")"
pass "interactive keyring skips nonprompting precheck"

unset OMARCHY_UPDATE_UNATTENDED
unset TEST_SUDO_N_TRUE_EXIT TEST_RECV_EXIT TEST_LIST_EXIT TEST_ARCH_EXIT TEST_PKG_ADD_EXIT
