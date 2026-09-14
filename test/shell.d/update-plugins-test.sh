#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/home"
export test_tmp
omarchy-plugin-update() {
  printf '%s\n' "called $#" >> "$test_tmp/calls"
  return "${UPDATE_RESULT:-0}"
}
export -f omarchy-plugin-update

run_update() {
  HOME="$test_tmp/home" bash "$ROOT/bin/omarchy-update-plugins"
}
[[ -z $(run_update) ]] || fail "absent plugin directory is a quiet no-op"
mkdir -p "$test_tmp/home/.config/omarchy/plugins/copied.plugin"
[[ -z $(run_update) ]] || fail "copied plugins are a quiet no-op"
pass "users without git-managed plugins are not prompted"

mkdir -p "$test_tmp/home/.config/omarchy/plugins/git.plugin/.git"
run_update > "$test_tmp/output"
[[ ! -e $test_tmp/calls ]] || fail "non-terminal updates do not invoke the updater"
grep -q 'Skipping plugin updates' "$test_tmp/output" || fail "non-terminal skip is explained"
pass "non-terminal updates report and skip plugin review"

run_interactive() {
  HOME="$test_tmp/home" script -qec "bash '$ROOT/bin/omarchy-update-plugins'" /dev/null > "$test_tmp/output"
}
OMARCHY_UPDATE_UNATTENDED=1 run_interactive
[[ ! -e $test_tmp/calls ]] || fail "unattended updates do not prompt even inside script's terminal"
pass "unattended updates skip even with a terminal"

run_interactive
[[ $(<"$test_tmp/calls") == "called 0" ]] || fail "interactive updates retain per-plugin confirmation"
pass "interactive updates invoke the existing updater without --yes"

UPDATE_RESULT=1 run_interactive || fail "plugin failures do not abort system update completion"
grep -q 'Some plugins could not be updated' "$test_tmp/output" || fail "plugin failures are reported"
pass "plugin failures are reported while system update completion can continue"
