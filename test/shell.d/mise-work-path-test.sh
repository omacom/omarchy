#!/bin/bash

# The Work PATH cleanup lives in omarchy-mise-remove-work-bin-path, which the
# migration runs. These cases cover a machine where Mise is gone: finish when
# nothing trusted ~/Work, and stay pending when a grant is left.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command mise

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
cleanup="$ROOT/bin/omarchy-mise-remove-work-bin-path"

run_cleanup() {
  local test_home="$1"

  env -i \
    HOME="$test_home" \
    XDG_CACHE_HOME="$test_home/.cache" \
    XDG_CONFIG_HOME="$test_home/.config" \
    XDG_DATA_HOME="$test_home/.local/share" \
    XDG_STATE_HOME="$test_home/.local/state" \
    MISE_PARANOID="${OMARCHY_TEST_MISE_PARANOID:-false}" \
    ${OMARCHY_TEST_MISE_STATE_DIR:+"MISE_STATE_DIR=$OMARCHY_TEST_MISE_STATE_DIR"} \
    PATH="$ROOT/bin:${OMARCHY_TEST_PATH:-/usr/local/bin:/usr/bin}" \
    "$cleanup"
}

run_mise() {
  local test_home="$1"
  shift

  env -i \
    HOME="$test_home" \
    XDG_CACHE_HOME="$test_home/.cache" \
    XDG_CONFIG_HOME="$test_home/.config" \
    XDG_DATA_HOME="$test_home/.local/share" \
    XDG_STATE_HOME="$test_home/.local/state" \
    MISE_PARANOID="${OMARCHY_TEST_MISE_PARANOID:-false}" \
    ${OMARCHY_TEST_MISE_STATE_DIR:+"MISE_STATE_DIR=$OMARCHY_TEST_MISE_STATE_DIR"} \
    PATH="/usr/local/bin:/usr/bin" \
    mise "$@"
}

mise_environment() {
  local test_home="$1"
  local project="$2"

  (
    cd "$project"
    run_mise "$test_home" env -s bash
  )
}

mise_path_active() {
  local test_home="$1"
  local project="$2"
  local output

  if ! output=$(mise_environment "$test_home" "$project" 2>/dev/null); then
    return 1
  fi

  grep -F "$project/bin" <<<"$output" >/dev/null
}

no_mise_path="$test_dir/usr-bin-without-mise"
mkdir "$no_mise_path"
ln -s "$(realpath /usr/bin)"/* "$no_mise_path/"
rm -f "$no_mise_path/mise"
! PATH="$no_mise_path" command -v mise >/dev/null 2>&1 || fail "the PATH built for a machine without mise still finds one"

removed_home="$test_dir/removed-home"
removed_config="$removed_home/Work/.mise.toml"
removed_project="$removed_home/Work/tries/untrusted-repository"
mkdir -p "$removed_project/bin"
printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$removed_config"
OMARCHY_TEST_PATH="$no_mise_path" run_cleanup "$removed_home" >/dev/null || fail "cleanup without Mise or a Work trust grant completes"
[[ ! -e $removed_config ]] || fail "cleanup without Mise removes the stock Work config"
pass "without Mise and without a Work trust grant the cleanup completes"

printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$removed_config"
run_mise "$removed_home" trust "$removed_config" >/dev/null
mise_path_active "$removed_home" "$removed_project" || fail "trusted legacy config prepends the repository bin directory"
OMARCHY_TEST_PATH="$no_mise_path" run_cleanup "$removed_home" >"$test_dir/removed-output" 2>&1 && fail "cleanup without Mise completes while a Work trust grant remains"
grep -F "omarchy pkg add mise-bin" "$test_dir/removed-output" >/dev/null || fail "cleanup without Mise names how to install it" "$(cat "$test_dir/removed-output")"
run_cleanup "$removed_home" >/dev/null
printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$removed_config"
if mise_path_active "$removed_home" "$removed_project"; then
  fail "Work trust grant left without Mise is revoked once Mise is back"
fi
pass "without Mise the cleanup stays pending while a Work trust grant remains"

tilde_home="$test_dir/tilde-home"
tilde_config="$tilde_home/Work/.mise.toml"
mkdir -p "$tilde_home/Work"
printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$tilde_config"
OMARCHY_TEST_MISE_STATE_DIR='~/mise-state' run_mise "$tilde_home" trust "$tilde_config" >/dev/null
[[ -d $tilde_home/mise-state/trusted-configs ]] || fail "Mise expands a leading ~/ in MISE_STATE_DIR"
if OMARCHY_TEST_MISE_STATE_DIR='~/mise-state' OMARCHY_TEST_PATH="$no_mise_path" run_cleanup "$tilde_home" >"$test_dir/tilde-output" 2>&1; then
  fail "cleanup without Mise finds a Work trust grant under a MISE_STATE_DIR that starts with ~/"
fi
grep -F "Mise is needed to revoke its trust" "$test_dir/tilde-output" >/dev/null || fail "cleanup without Mise stops for the Work trust grant under a MISE_STATE_DIR that starts with ~/" "$(cat "$test_dir/tilde-output")"
pass "without Mise the cleanup finds a Work trust grant under a MISE_STATE_DIR that starts with ~/"
