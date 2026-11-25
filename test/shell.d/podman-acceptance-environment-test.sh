#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

# Exercise the real acceptance preamble without opening graphical windows.
sed '/^systemctl --user start podman.socket/,$d' "$ROOT/test/acceptance.d/podman-test.sh" >"$test_dir/check.sh"
cat >"$test_dir/base-test.sh" <<'SH'
fail() { echo "$*" >&2; exit 1; }
SH
cat >"$test_dir/systemd-run" <<'SH'
#!/bin/bash
[[ ${TEST_MANAGER_FAIL:-0} == 0 ]] || exit 1
while [[ $1 == --* ]]; do shift; done
exec "$@"
SH
cat >"$test_dir/pacman" <<'SH'
#!/bin/bash
[[ $* == '-Q podman-docker' && $TEST_COMPAT == 1 ]]
SH
chmod +x "$test_dir/systemd-run" "$test_dir/pacman"
export PATH="$test_dir:$PATH" XDG_RUNTIME_DIR="$test_dir/runtime" TEST_COMPAT=0
unset DOCKER_HOST
bash "$test_dir/check.sh" || fail "native acceptance requires optional Docker environment"
export TEST_COMPAT=1 DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
bash "$test_dir/check.sh" || fail "compatibility acceptance rejects correct endpoint"
unset DOCKER_HOST
! bash "$test_dir/check.sh" 2>/dev/null || fail "compatibility acceptance allows missing endpoint"
export TEST_COMPAT=0 DOCKER_HOST=unix:///wrong/socket
! bash "$test_dir/check.sh" 2>/dev/null || fail "native acceptance allows unintended Docker endpoint"
unset DOCKER_HOST
export TEST_MANAGER_FAIL=1
! bash "$test_dir/check.sh" 2>/dev/null || fail "acceptance hides a failed user manager"
pass "acceptance distinguishes native and optional Docker environments"
