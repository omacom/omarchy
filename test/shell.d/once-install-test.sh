#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command pacman

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home" "$test_tmp/db/local"
printf '9\n' >"$test_tmp/db/local/ALPM_DB_VERSION"
printf '[options]\n' >"$test_tmp/pacman.conf"

# Use pacman's actual dependency comparison against an isolated package database.
# Package installation, sudo, and the service itself are never run on the host.
export ONCE_TEST_PACMAN=$(type -P pacman)
export ONCE_TEST_DIR="$test_tmp"
export HOME="$test_tmp/home"
export OMARCHY_PATH="$ROOT"
export PATH="$test_tmp/bin:$PATH"

cat >"$test_tmp/bin/pacman" <<'SH'
#!/bin/bash
printf 'check\n' >>"$ONCE_TEST_DIR/calls"
exec "$ONCE_TEST_PACMAN" --config "$ONCE_TEST_DIR/pacman.conf" --dbpath "$ONCE_TEST_DIR/db" "$@"
SH

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
[[ $# == 1 && $1 == "once-bin" ]] || exit 99
printf 'install\n' >>"$ONCE_TEST_DIR/calls"
exit "${ONCE_TEST_INSTALL_STATUS:-0}"
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
case "$*" in
  'systemctl enable --now once-background.service')
    printf 'enable\n' >>"$ONCE_TEST_DIR/calls"
    exit "${ONCE_TEST_SERVICE_STATUS:-0}"
    ;;
  once) printf 'launch\n' >>"$ONCE_TEST_DIR/calls" ;;
  *) exit 99 ;;
esac
SH

chmod +x "$test_tmp/bin/"*

installed_version() {
  rm -rf "$test_tmp/db/local/once-bin-"*
  if [[ -n $1 ]]; then
    mkdir -p "$test_tmp/db/local/once-bin-$1"
    printf '%%NAME%%\nonce-bin\n\n%%VERSION%%\n%s\n' "$1" >"$test_tmp/db/local/once-bin-$1/desc"
  fi
}

run_installer() {
  : >"$test_tmp/calls"
  if "$ROOT/bin/omarchy-install-service-once" >"$test_tmp/output" 2>&1; then
    status=0
  else
    status=$?
  fi
}

for version in '' 0.3.0-1 0.3.3-1 0.3.3-99; do
  installed_version "$version"
  run_installer
  (( status != 0 )) || fail "missing or vulnerable ONCE is rejected: ${version:-missing}"
  [[ $(<"$test_tmp/calls") == $'install\ncheck' ]] || fail "unsafe ONCE never starts" "$(cat "$test_tmp/calls")"
  grep -q 'omarchy update' "$test_tmp/output" || fail "rejected ONCE explains how to update"
  grep -q 'then omarchy-install-service-once' "$test_tmp/output" || fail "rejected ONCE names the command to retry"
done
pass "missing and vulnerable packages cannot enable the service or launch ONCE"

for version in 0.3.4-1 0.3.4-2 0.3.10-1 0.4.0-1; do
  installed_version "$version"
  run_installer
  (( status == 0 )) || fail "patched ONCE can be installed: $version" "$(cat "$test_tmp/output")"
  [[ $(<"$test_tmp/calls") == $'install\ncheck\nenable\nlaunch' ]] || fail "patched ONCE starts after verification" "$(cat "$test_tmp/calls")"
done
pass "patched and newer packages enable the service and launch ONCE"

export ONCE_TEST_INSTALL_STATUS=1
run_installer
(( status != 0 )) || fail "package installation failure is reported"
[[ $(<"$test_tmp/calls") == "install" ]] || fail "a failed installation cannot reach the service"
unset ONCE_TEST_INSTALL_STATUS
pass "package installation failure stops the installer even with a patched package present"

export ONCE_TEST_SERVICE_STATUS=1
run_installer
(( status != 0 )) || fail "service startup failure is reported"
[[ $(<"$test_tmp/calls") == $'install\ncheck\nenable' ]] || fail "a failed service startup cannot launch ONCE"
pass "service startup failure stops the installer before launching ONCE"
