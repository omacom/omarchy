#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789156273.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
package_name_state="$test_tmp/package-name"
package_state="$test_tmp/package-version"
sudo_log="$test_tmp/sudo.log"
output="$test_tmp/output"
mkdir -p "$stub_bin"

cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash

case "$1" in
  -Q)
    if [[ ${PACKAGE_QUERY_ERROR:-} == "true" ]]; then
      echo "error: failed to read the local package database" >&2
      exit 2
    elif [[ $2 == "gpu-screen-recorder" && -f $PACKAGE_STATE ]]; then
      printf '%s %s\n' "$(<"$PACKAGE_NAME_STATE")" "$(<"$PACKAGE_STATE")"
    else
      echo "error: package 'gpu-screen-recorder' was not found" >&2
      exit 1
    fi
    ;;
  -T)
    if [[ ${PACKAGE_DEPTEST_ERROR:-} == "true" ]]; then
      echo "error: failed to read the local package database" >&2
      exit 2
    elif [[ -f $PACKAGE_STATE ]]; then
      exit 0
    else
      echo "$2"
      exit 127
    fi
    ;;
  -S)
    printf 'gpu-screen-recorder' >"$PACKAGE_NAME_STATE"
    printf '%s' "$PACKAGE_UPGRADE_VERSION" >"$PACKAGE_STATE"
    ;;
  *)
    exit 2
    ;;
esac
STUB

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash

printf '%s' "$1" >>"$SUDO_LOG"
shift
printf '\t%s' "$@" >>"$SUDO_LOG"
printf '\n' >>"$SUDO_LOG"
exec pacman "$@"
STUB

chmod +x "$stub_bin/pacman" "$stub_bin/sudo"

run_migration() {
  local installed_version="$1"
  local upgrade_version="${2:-6.1.2-1}"
  local installed_name="${3:-gpu-screen-recorder}"

  : >"$sudo_log"
  : >"$output"
  if [[ -n $installed_version ]]; then
    printf '%s' "$installed_name" >"$package_name_state"
    printf '%s' "$installed_version" >"$package_state"
  else
    rm -f "$package_name_state"
    rm -f "$package_state"
  fi

  PACKAGE_NAME_STATE="$package_name_state" PACKAGE_STATE="$package_state" PACKAGE_UPGRADE_VERSION="$upgrade_version" SUDO_LOG="$sudo_log" \
    PATH="$stub_bin:/usr/bin" bash -euo pipefail "$migration" >"$output" 2>&1
}

run_migration ""
[[ ! -s $sudo_log ]] || fail "the migration reinstalls a removed recorder" "$(<"$sudo_log")"
pass "the migration leaves a removed recorder alone"

if PACKAGE_QUERY_ERROR=true run_migration "6.1.2.r1.gdeadbeef-1" "6.1.2-1" "gpu-screen-recorder-git"; then
  fail "the migration accepts a failed provider package query"
fi
grep -Fq "Could not determine the installed GPU Screen Recorder version" "$output" ||
  fail "the migration explains that a failed package query will retry" "$(<"$output")"
[[ ! -s $sudo_log ]] || fail "the migration upgrades after a failed package query" "$(<"$sudo_log")"
pass "the migration remains pending when a provider package query fails"

if PACKAGE_QUERY_ERROR=true PACKAGE_DEPTEST_ERROR=true run_migration ""; then
  fail "the migration accepts an unreadable package database"
fi
grep -Fq "Could not determine the installed GPU Screen Recorder version" "$output" ||
  fail "the migration explains that an unreadable package database will retry" "$(<"$output")"
pass "the migration remains pending when package dependencies cannot be checked"

for installed_version in 6.1.2-1 6.2.0-1; do
  run_migration "$installed_version"
  [[ ! -s $sudo_log ]] || fail "the migration reinstalls a supported recorder" "$(<"$sudo_log")"
done
pass "the migration leaves supported recorder releases alone"

run_migration "6.1.2.r1.gdeadbeef-1" "6.1.2-1" "gpu-screen-recorder-git"
[[ ! -s $sudo_log ]] || fail "the migration replaces a supported recorder provider" "$(<"$sudo_log")"
pass "the migration leaves a supported recorder provider alone"

run_migration "6.1.1-1"
grep -qxF $'pacman\t-S\t--noconfirm\t--needed\tgpu-screen-recorder>=6.1.2' "$sudo_log" ||
  fail "the migration upgrades an older recorder" "$(<"$sudo_log")"
[[ $(<"$package_state") == "6.1.2-1" ]] ||
  fail "the migration installs the required recorder release" "$(<"$package_state")"
pass "the migration upgrades an older recorder"

if run_migration "6.1.1-1" "6.1.1-2"; then
  fail "the migration accepts a recorder that remains below v6.1.2"
fi
grep -Fq "v6.1.2 or newer is required; v6.1.1-2 is still installed" "$output" ||
  fail "the migration explains why the upgrade remains pending" "$(<"$output")"
pass "the migration remains pending until the required release is installed"
