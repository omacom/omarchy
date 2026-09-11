#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
poison_log="$test_tmp/poison.log"
sudo_ticket="$test_tmp/sudo-ticket"
mkdir -p "$stub_bin"

cleanup() {
  rm -rf "$test_tmp"
  return 0
}
trap cleanup EXIT

cat >"$stub_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash

exit "$TEST_MISSING_STATUS"
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_CALL_LOG"
printf '\t%s' "$@" >>"$TEST_CALL_LOG"
printf '\n' >>"$TEST_CALL_LOG"

if [[ ${1:-} == "-k" ]]; then
  (( $# == 1 )) || exit 96
  if (( TEST_REVOKE_STATUS != 0 )); then
    exit "$TEST_REVOKE_STATUS"
  fi
  rm -f "$TEST_SUDO_TICKET"
  exit 0
fi

if [[ ${1:-} != "pacman" || ${2:-} != "-S" || ${3:-} != "--noconfirm" || ${4:-} != "--needed" ]]; then
  exit 97
fi

: >"$TEST_SUDO_TICKET"
exit "$TEST_INSTALL_STATUS"
SH

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash

printf 'pacman' >>"$TEST_CALL_LOG"
printf '\t%s' "$@" >>"$TEST_CALL_LOG"
printf '\n' >>"$TEST_CALL_LOG"

if [[ -e $TEST_SUDO_TICKET ]]; then
  printf '%s\n' pacman-query-with-live-sudo >>"$TEST_POISON_LOG"
  exit 94
fi

[[ ${1:-} == "-Q" && $# == 2 ]] || exit 95
exit "$TEST_QUERY_STATUS"
SH

chmod +x "$stub_bin/omarchy-pkg-missing" "$stub_bin/sudo" "$stub_bin/pacman"

run_pkg_add() {
  local install_status=${1:-0}
  local revoke_status=${2:-0}
  local query_status=${3:-0}
  local missing_status=${4:-0}
  local status

  : >"$call_log"
  : >"$poison_log"
  rm -f "$sudo_ticket"

  if TEST_CALL_LOG="$call_log" TEST_INSTALL_STATUS="$install_status" \
    TEST_MISSING_STATUS="$missing_status" TEST_POISON_LOG="$poison_log" \
    TEST_QUERY_STATUS="$query_status" TEST_REVOKE_STATUS="$revoke_status" \
    TEST_SUDO_TICKET="$sudo_ticket" PATH="$stub_bin:/usr/bin:/bin" \
    "$ROOT/bin/omarchy-pkg-add" --revoke-sudo libfido2 pam-u2f >/dev/null 2>&1; then
    status=0
  else
    status=$?
  fi

  return "$status"
}

run_pkg_add || fail "package installation succeeds with credential revocation"
mapfile -t calls <"$call_log"
[[ ${calls[0]:-} == $'sudo\tpacman\t-S\t--noconfirm\t--needed\tlibfido2\tpam-u2f' ]] ||
  fail "package helper installs the requested packages" "$(cat "$call_log")"
[[ ${calls[1]:-} == $'sudo\t-k' ]] ||
  fail "package helper revokes sudo immediately after installation" "$(cat "$call_log")"
[[ ${calls[2]:-} == $'pacman\t-Q\tlibfido2' && ${calls[3]:-} == $'pacman\t-Q\tpam-u2f' ]] ||
  fail "package helper checks registration only after revoking sudo" "$(cat "$call_log")"
(( ${#calls[@]} == 4 )) || fail "package helper makes only the expected calls" "$(cat "$call_log")"
[[ ! -e $sudo_ticket ]] || fail "package helper leaves no reusable sudo credentials"
[[ ! -s $poison_log ]] || fail "package checks run while sudo credentials remain live" "$(cat "$poison_log")"
pass "package helper revokes sudo before post-installation callbacks"

install_failure=0
run_pkg_add 42 || install_failure=$?
(( install_failure == 42 )) || fail "package helper preserves installation failure status" "got status $install_failure"
grep -Fxq $'sudo\t-k' "$call_log" || fail "package helper revokes sudo after a failed installation" "$(cat "$call_log")"
! grep -Fq $'pacman\t-Q' "$call_log" || fail "package helper skips registration checks after a failed installation" "$(cat "$call_log")"
[[ ! -e $sudo_ticket ]] || fail "failed package installation leaves no reusable sudo credentials"
pass "package helper revokes sudo and propagates package installation failures"

revoke_failure=0
run_pkg_add 0 55 || revoke_failure=$?
(( revoke_failure != 0 )) || fail "package helper fails when sudo credentials cannot be revoked"
! grep -Fq $'pacman\t-Q' "$call_log" || fail "package helper runs no post-installation callbacks after failed revocation" "$(cat "$call_log")"
pass "package helper stops when sudo credential revocation fails"
