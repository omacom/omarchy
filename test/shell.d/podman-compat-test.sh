#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
export TEST_LOG="$test_dir/calls" TEST_PROVIDER=missing TEST_DB_FAIL=0
cat >"$test_dir/bin/pacman" <<'SH'
#!/bin/bash
[[ $TEST_DB_FAIL == 0 ]] || exit 1
if [[ $* == '-Qq docker' ]]; then
  [[ $TEST_PROVIDER != missing ]] || exit 1
  echo "$TEST_PROVIDER"
fi
SH
for command in systemctl omarchy-pkg-add omarchy-pkg-drop dbus-update-activation-environment; do
  cat >"$test_dir/bin/$command" <<'SH'
#!/bin/bash
echo "${0##*/} $*" >>"$TEST_LOG"
SH
done
chmod +x "$test_dir/bin/"*
export PATH="$test_dir/bin:$PATH"
unset DOCKER_HOST DOCKER_CONTEXT

for TEST_PROVIDER in docker docker-git; do
  : >"$TEST_LOG"
  ! "$ROOT/bin/omarchy-install-docker-compat" >"$test_dir/output" 2>&1 || fail "existing engine must block shim installation"
  [[ ! -s $TEST_LOG ]] || fail "existing engine guard changes packages or services"
done
TEST_PROVIDER=missing TEST_DB_FAIL=1
! "$ROOT/bin/omarchy-install-docker-compat" >"$test_dir/output" 2>&1 || fail "failed package query must block installation"
TEST_DB_FAIL=0
"$ROOT/bin/omarchy-install-docker-compat" >"$test_dir/output" 2>&1
grep -q '^omarchy-pkg-add podman-docker$' "$TEST_LOG" || fail "optional shim not installed"
grep -q '^dbus-update-activation-environment --systemd DOCKER_HOST$' "$TEST_LOG" || fail "API activation environment not refreshed"
for variable in DOCKER_HOST DOCKER_CONTEXT; do
  : >"$TEST_LOG"
  env "$variable=custom" "$ROOT/bin/omarchy-install-docker-compat" >"$test_dir/output" 2>&1
  ! grep -q '^dbus-update' "$TEST_LOG" || fail "explicit $variable overwritten"
done
"$ROOT/bin/omarchy-remove-docker-compat" >"$test_dir/output" 2>&1
grep -q '^omarchy-pkg-drop podman-docker$' "$TEST_LOG" || fail "optional removal targets wrong package"
! grep -qx podman-docker "$ROOT/install/omarchy-base.packages" || fail "compatibility is still a default dependency"
pass "optional compatibility preserves real engines and configured endpoints"
