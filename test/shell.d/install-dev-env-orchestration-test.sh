#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "${test_tmp:?}"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home"
export HOME="$test_tmp/home"
export TEST_EVENT_LOG="$test_tmp/events"
export TEST_SUDO_TOKEN="$test_tmp/sudo-token"
export TEST_INSTALLED_MARKER="$test_tmp/installed"
export TEST_STUB_BIN="$test_tmp/bin"
export PATH="$TEST_STUB_BIN:/usr/bin:/bin"

cat >"$TEST_STUB_BIN/sudo" <<'SH'
#!/bin/bash
set -euo pipefail
case "${1:-}" in
  -k)
    printf 'REVOKE\n' >>"$TEST_EVENT_LOG"
    rm -f -- "$TEST_SUDO_TOKEN"
    ;;
  -h)
    printf 'CAPABILITY\n' >>"$TEST_EVENT_LOG"
    printf 'usage: sudo [-ABbEHkNnPS] command\n'
    ;;
  -N)
    shift
    [[ ${1:-} == -- && ${2:-} == "$TEST_STUB_BIN/pacman" ]] || exit 90
    printf 'SUDO_NO_UPDATE\n' >>"$TEST_EVENT_LOG"
    shift
    "$@"
    ;;
  --)
    shift
    [[ ${1:-} == "$TEST_STUB_BIN/pacman" ]] || exit 90
    printf 'SUDO_DEFAULT\n' >>"$TEST_EVENT_LOG"
    "$@"
    ;;
  *) exit 90 ;;
esac
SH

cat >"$TEST_STUB_BIN/omarchy-pkg-add" <<'SH'
#!/bin/bash
set -euo pipefail
[[ ${OMARCHY_SUDO_NO_UPDATE:-0} == 1 && $* == symfony-cli ]] || exit 98
printf 'PACKAGE_REQUEST:%s\n' "$*" >>"$TEST_EVENT_LOG"
if [[ ${TEST_PACKAGE_PRESENT:-0} == 1 ]]; then
  printf 'PACKAGE_PRESENT\n' >>"$TEST_EVENT_LOG"
else
  [[ ${TEST_PACKAGE_STATUS:-0} == 0 ]] || exit "$TEST_PACKAGE_STATUS"
  printf 'PACKAGE_INSTALL\n' >>"$TEST_EVENT_LOG"
  # Model a credential left by a prerequisite; the installer must clear it.
  : >"$TEST_SUDO_TOKEN"
fi
SH

cat >"$TEST_STUB_BIN/mise" <<'SH'
#!/bin/bash
set -euo pipefail
[[ ! -e $TEST_SUDO_TOKEN ]] || exit 97
printf 'USER:%s\n' "$*" >>"$TEST_EVENT_LOG"
exit "${TEST_USER_STATUS:-0}"
SH

cat >"$TEST_STUB_BIN/omarchy-pkg-missing" <<'SH'
#!/bin/bash
[[ ${TEST_PACKAGE_PRESENT:-0} != 1 ]]
SH

cat >"$TEST_STUB_BIN/pacman" <<'SH'
#!/bin/bash
set -euo pipefail
case "${1:-}" in
  -S)
    printf 'PACMAN_INSTALL\n' >>"$TEST_EVENT_LOG"
    : >"$TEST_INSTALLED_MARKER"
    ;;
  -Q)
    printf 'PACMAN_QUERY:%s\n' "${3:-}" >>"$TEST_EVENT_LOG"
    [[ -e $TEST_INSTALLED_MARKER || ${TEST_PACKAGE_PRESENT:-0} == 1 ]]
    ;;
  *) exit 91 ;;
esac
SH

for name in omarchy-security-functions omarchy-install-security-functions omarchy-install-dev-env omarchy-pkg-add; do
  sed -e "s#/usr/bin/sudo#$TEST_STUB_BIN/sudo#g" \
    -e "s#/usr/bin/omarchy-pkg-add#$TEST_STUB_BIN/omarchy-pkg-add#g" \
    -e "s#/usr/bin/omarchy-pkg-missing#$TEST_STUB_BIN/omarchy-pkg-missing#g" \
    -e "s#/usr/bin/pacman#$TEST_STUB_BIN/pacman#g" \
    "$ROOT/bin/$name" >"$test_tmp/$name"
done
chmod 0755 "$TEST_STUB_BIN/"*
if grep -Fq '/usr/bin/sudo' "$test_tmp/omarchy-security-functions" "$test_tmp/omarchy-install-security-functions" "$test_tmp/omarchy-install-dev-env" "$test_tmp/omarchy-pkg-add"; then
  fail "installer fixture still reaches host sudo"
fi
if grep -Eq '/etc/php|(^|[[:space:]])sed[[:space:]]+(-i|--in-place)' "$test_tmp/omarchy-install-dev-env"; then
  fail "installer fixture would edit host PHP configuration"
fi

reset_events() {
  : >"$TEST_EVENT_LOG"
  rm -f -- "$TEST_SUDO_TOKEN" "$TEST_INSTALLED_MARKER"
}

run_installer() {
  local environment=$1 expected_status=$2 status
  if /usr/bin/bash -p -- "$test_tmp/omarchy-install-dev-env" "$environment" >"$test_tmp/output" 2>&1; then
    status=0
  else
    status=$?
  fi
  (( status == expected_status )) || fail "$environment returned $status instead of $expected_status" "$(<"$test_tmp/output")"
  [[ ! -e $TEST_SUDO_TOKEN ]] || fail "$environment left a reusable credential in the fixture"
  [[ $(tail -n 1 "$TEST_EVENT_LOG") == REVOKE ]] || fail "$environment did not revoke on exit"
}

for environment in php laravel; do
  reset_events
  : >"$TEST_SUDO_TOKEN"
  run_installer "$environment" 0
  [[ $(head -n 1 "$TEST_EVENT_LOG") == REVOKE ]] || fail "$environment did not revoke before mise"
  ! grep -Eq '^(PACKAGE_|PACMAN_|SUDO_|CAPABILITY)' "$TEST_EVENT_LOG" ||
    fail "$environment entered a privileged PHP package or configuration phase"
  grep -Fxq 'USER:tool-alias set php github:nunomaduro/static-php-builds' "$TEST_EVENT_LOG" ||
    fail "$environment did not select user-owned static PHP"
  grep -Fxq 'USER:use --global php@latest' "$TEST_EVENT_LOG" || fail "$environment did not install PHP through mise"
  grep -Fxq "USER:x php -- composer global config bin-dir $HOME/.local/bin" "$TEST_EVENT_LOG" ||
    fail "$environment did not configure the user composer bin directory"
done
grep -Fxq 'USER:x php -- composer global require laravel/installer' "$TEST_EVENT_LOG" ||
  fail "Laravel did not reach its user composer callback"
pass "PHP and Laravel use mise without privileged PHP package or configuration work"

reset_events
run_installer symfony 0
mapfile -t events <"$TEST_EVENT_LOG"
[[ ${events[0]:-} == REVOKE && ${events[1]:-} == CAPABILITY &&
  ${events[2]:-} == PACKAGE_REQUEST:symfony-cli && ${events[3]:-} == PACKAGE_INSTALL &&
  ${events[4]:-} == REVOKE && ${events[5]:-} == USER:* ]] ||
  fail "Symfony prerequisite did not finish before user-owned PHP callbacks" "$(<"$TEST_EVENT_LOG")"
[[ $(grep -c '^PACKAGE_REQUEST:' "$TEST_EVENT_LOG") == 1 ]] ||
  fail "Symfony requested its prerequisite more than once"
pass "Symfony installs its one package prerequisite before user-owned PHP work"

reset_events
TEST_PACKAGE_PRESENT=1 run_installer symfony 0
grep -Fxq PACKAGE_PRESENT "$TEST_EVENT_LOG" || fail "installed Symfony prerequisite was not recognized"
! grep -Fxq PACKAGE_INSTALL "$TEST_EVENT_LOG" || fail "installed Symfony prerequisite was installed again"
pass "an installed Symfony prerequisite is skipped"

for status in 42 130; do
  reset_events
  TEST_PACKAGE_STATUS=$status run_installer symfony "$status"
  ! grep -q '^USER:' "$TEST_EVENT_LOG" || fail "Symfony status $status continued into user callbacks"
  TEST_PACKAGE_STATUS=0 run_installer symfony 0
  grep -q '^USER:' "$TEST_EVENT_LOG" || fail "Symfony retry did not reach user callbacks"
done
pass "Symfony package failure and simulated cancellation stop before callbacks and permit retry"

reset_events
/usr/bin/bash -p -- "$test_tmp/omarchy-pkg-add" alpha beta
[[ $(grep -c '^SUDO_DEFAULT$' "$TEST_EVENT_LOG") == 1 ]] ||
  fail "ordinary package install made more than one default sudo call"
! grep -Fxq SUDO_NO_UPDATE "$TEST_EVENT_LOG" || fail "ordinary package install unexpectedly used no-update sudo"
[[ $(grep -c '^PACMAN_INSTALL$' "$TEST_EVENT_LOG") == 1 ]] || fail "package helper installed more than once"
pass "ordinary package helper keeps one default sudo call for a package set"

reset_events
TEST_PACKAGE_PRESENT=1 /usr/bin/bash -p -- "$test_tmp/omarchy-pkg-add" alpha beta
! grep -Eq '^(SUDO_|PACMAN_INSTALL)' "$TEST_EVENT_LOG" || fail "already-installed packages prompted or reinstalled"
pass "ordinary package helper skips sudo when its packages are present"
