#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export TEST_EVENT_LOG="$test_tmp/events"
export TEST_SYSTEM_SCRIPT="$test_tmp/omarchy-install-dev-env-system"
export HOME="$test_tmp/home"
mkdir -p "$test_tmp/bin" "$HOME" "$test_tmp/php/conf.d"

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
set -euo pipefail
case "${1:-}" in
  -k) echo REVOKE >>"$TEST_EVENT_LOG" ;;
  -h) echo 'usage: sudo [-ABbEHkNnPS] command' ;;
  -N)
    [[ $# == 10 && $2 == -- && $3 == /usr/bin/env && $4 == -i &&
      $5 == PATH=/usr/bin:/usr/sbin:/bin:/sbin && $6 == /usr/bin/bash &&
      $7 == -p && $8 == -- && $9 == /usr/bin/omarchy-install-dev-env-system ]]
    [[ ${10} == php || ${10} == symfony ]]
    echo "AUTH:${10}" >>"$TEST_EVENT_LOG"
    /usr/bin/bash -p -- "$TEST_SYSTEM_SCRIPT" "${10}"
    ;;
  *) exit 90 ;;
esac
SH
cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "PACKAGES:$*" >>"$TEST_EVENT_LOG"
exit "${TEST_PACKAGE_STATUS:-0}"
SH
for tool in mise composer; do
  cat >"$test_tmp/bin/$tool" <<'SH'
#!/bin/bash
echo "USER:${0##*/}:$*" >>"$TEST_EVENT_LOG"
exit "${TEST_USER_STATUS:-0}"
SH
done

for name in omarchy-security-functions omarchy-install-security-functions omarchy-install-dev-env; do
  sed -e "s#/usr/bin/sudo#$test_tmp/bin/sudo#g" \
    -e "s#/usr/bin/omarchy-pkg-add#$test_tmp/bin/omarchy-pkg-add#g" \
    "$ROOT/bin/$name" >"$test_tmp/$name"
done
# Only the fixture bypasses root identity; all effects target ordinary temporary files.
sed -e 's/if (( EUID != 0 )) ||/if/' \
  -e "s#/usr/bin/omarchy-pkg-add#$test_tmp/bin/omarchy-pkg-add#g" \
  -e "s#/etc/php/#$test_tmp/php/#g" \
  "$ROOT/bin/omarchy-install-dev-env-system" >"$TEST_SYSTEM_SCRIPT"
chmod 755 "$test_tmp/bin/"* "$test_tmp/omarchy-install-dev-env"
export PATH="$test_tmp/bin:/usr/bin:/bin"

reset_config() {
  printf ';zend_extension=xdebug.so\n;xdebug.mode=debug\n' >"$test_tmp/php/conf.d/xdebug.ini"
  printf ';extension=%s\n' bcmath intl iconv openssl pdo_sqlite pdo_mysql >"$test_tmp/php/php.ini"
  : >"$TEST_EVENT_LOG"
}

for environment in php laravel symfony; do
  reset_config
  "$test_tmp/omarchy-install-dev-env" "$environment" >"$test_tmp/output" 2>&1 ||
    fail "$environment completes its fixed system phase"
  [[ $(grep -c '^AUTH:' "$TEST_EVENT_LOG") == 1 ]] || fail "$environment authenticates once in total"
  [[ $(head -n 1 "$TEST_EVENT_LOG") == REVOKE && $(tail -n 1 "$TEST_EVENT_LOG") == REVOKE ]] ||
    fail "$environment revokes on entry and exit"
  expected='PACKAGES:php composer php-sqlite xdebug'
  [[ $environment != symfony ]] || expected+=' symfony-cli'
  grep -Fxq "$expected" "$TEST_EVENT_LOG" || fail "$environment installs its exact complete package set"
  if grep -q '^;' "$test_tmp/php/conf.d/xdebug.ini" "$test_tmp/php/php.ini"; then
    fail "$environment enables every required PHP setting"
  fi
  awk '/^AUTH:/ { cold=0 } /^REVOKE$/ { cold=1 } /^USER:/ && !cold { exit 1 }' "$TEST_EVENT_LOG" ||
    fail "$environment revokes before user tools"
done
pass "PHP, Laravel and Symfony use one fixed authentication for packages and configuration"

reset_config
if TEST_PACKAGE_STATUS=42 "$test_tmp/omarchy-install-dev-env" laravel >"$test_tmp/output" 2>&1; then
  fail "PHP package failure propagates"
else
  [[ $? == 42 ]] || fail "PHP preserves the package failure status"
fi
[[ $(tail -n 1 "$TEST_EVENT_LOG") == REVOKE ]] || fail "PHP package failure revokes"
if grep -q '^USER:' "$TEST_EVENT_LOG" || grep -q '^extension=' "$test_tmp/php/php.ini"; then
  fail "PHP package failure precedes configuration and user work"
fi
pass "PHP package failure prevents configuration and user work and still revokes"

reset_config
if /usr/bin/bash -p -- "$TEST_SYSTEM_SCRIPT" unsupported >"$test_tmp/output" 2>&1; then
  fail "system phase rejects an unsupported selector"
fi
[[ ! -s $TEST_EVENT_LOG ]] || fail "invalid system selector reaches no package operation"
if /usr/bin/bash -p -- "$TEST_SYSTEM_SCRIPT" php extra >"$test_tmp/output" 2>&1; then
  fail "system phase rejects extra arguments"
fi
pass "system phase has a closed argument vocabulary"

cat >"$test_tmp/startup" <<'SH'
: >"$TEST_STARTUP_MARKER"
unset BASH_ENV
set -o privileged
SH
export TEST_STARTUP_MARKER="$test_tmp/startup-ran"
for name in omarchy-pkg-add omarchy-install-dev-env omarchy-install-font omarchy-install-gaming-battlenet omarchy-install-gaming-geforce-now omarchy-install-gaming-gpu-lib32; do
  sed -e "s#/usr/bin/sudo#$test_tmp/bin/sudo#g" \
    -e "s#/usr/bin/omarchy-pkg-add#$test_tmp/bin/omarchy-pkg-add#g" \
    "$ROOT/bin/$name" >"$test_tmp/$name"
  rm -f "$TEST_STARTUP_MARKER"
  : >"$TEST_EVENT_LOG"
  if BASH_ENV="$test_tmp/startup" /usr/bin/bash "$test_tmp/$name" -p >"$test_tmp/output" 2>&1; then
    fail "$name rejects ordinary Bash with a post-script -p"
  else
    [[ $? == 126 ]] || fail "$name rejects unsafe startup before operational work"
  fi
  [[ -f $TEST_STARTUP_MARKER && ! -s $TEST_EVENT_LOG ]] || fail "$name validates actual interpreter startup"
done
pass "all five installers and the package helper reject a decoy privileged startup"
