#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration=$(grep -l '^echo "Install Reach' "$ROOT"/migrations/*.sh)
[[ -n $migration ]] || fail "the Reach migration exists"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Reach installed or not, the package published or not, no ufw, and a user
# manager that only records what it's asked. No running shell at all.
cat >"$stub_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash
[[ ${TEST_INSTALLED:-1} != 1 ]]
SH
cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
[[ ${TEST_PUBLISHED:-1} == 1 ]]
SH
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "pkg-add $*" >>"$TEST_CALLS"
SH
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
echo "systemctl $*" >>"$TEST_CALLS"
SH
cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
echo "no shell is running" >&2
exit 1
SH
chmod +x "$stub_bin"/*

# Runs the migration as omarchy-migrate does, in a fresh HOME; prints its exit status.
run_migration() {
  local home="$1"
  HOME="$home" PATH="$stub_bin:$PATH" TEST_CALLS="$test_tmp/calls" \
    bash -euo pipefail "$migration" >/dev/null 2>&1 && echo 0 || echo $?
}

new_home() {
  local home="$test_tmp/home-$1"
  mkdir -p "$home/.config/omarchy"
  printf '%s\n' "$home"
}

bar_ids() {
  jq -c '[.bar.layout[]? | arrays | .[] | if type == "object" then .id else . end]' "$1/.config/omarchy/shell.json"
}

# Waits for the package without failing the update while it isn't published.
home=$(new_home unpublished)
status=$(TEST_INSTALLED=0 TEST_PUBLISHED=0 run_migration "$home")
[[ $status == 75 ]] || fail "the migration waits (exit 75) for an unpublished reach package" "exit $status"
pass "the migration waits (exit 75) for an unpublished reach package"

home=$(new_home published)
: >"$test_tmp/calls"
status=$(TEST_INSTALLED=0 run_migration "$home")
[[ $status == 0 ]] || fail "the migration installs a published reach package" "exit $status"
grep -qx "pkg-add reach" "$test_tmp/calls" || fail "the migration installs a published reach package" "$(cat "$test_tmp/calls")"
grep -qx "systemctl --user enable --now reach.service" "$test_tmp/calls" || fail "the migration starts Reach" "$(cat "$test_tmp/calls")"
pass "the migration installs a published reach package and starts it"

# Puts the icon before Network with no shell running, and only once.
home=$(new_home network)
cat >"$home/.config/omarchy/shell.json" <<'JSON'
{"bar": {"layout": {"left": ["omarchy.menu"], "right": [{"id": "omarchy.audio"}, {"id": "omarchy.network", "x": 1}]}}}
JSON
[[ $(run_migration "$home") == 0 ]] || fail "the migration adds the icon without a running shell"
[[ $(bar_ids "$home") == '["omarchy.menu","omarchy.audio","omarchy.reach","omarchy.network"]' ]] ||
  fail "the migration puts the icon before Network" "$(bar_ids "$home")"
[[ $(jq -c '.bar.layout.right[2]' "$home/.config/omarchy/shell.json") == '{"id":"omarchy.network","x":1}' ]] ||
  fail "the migration keeps Network's settings"
run_migration "$home" >/dev/null
[[ $(bar_ids "$home") == '["omarchy.menu","omarchy.audio","omarchy.reach","omarchy.network"]' ]] ||
  fail "the migration adds the icon only once" "$(bar_ids "$home")"
pass "the migration puts the icon before Network without a running shell, once"

home=$(new_home no-network)
echo '{"bar": {"layout": {"right": [{"id": "omarchy.power"}]}}}' >"$home/.config/omarchy/shell.json"
run_migration "$home" >/dev/null
[[ $(bar_ids "$home") == '["omarchy.power","omarchy.reach"]' ]] || fail "the migration ends the right section without Network" "$(bar_ids "$home")"
pass "the migration ends the right section when there's no Network icon"

home=$(new_home moved)
echo '{"bar": {"layout": {"left": [{"id": "omarchy.reach"}], "right": [{"id": "omarchy.network"}]}}}' >"$home/.config/omarchy/shell.json"
run_migration "$home" >/dev/null
[[ $(bar_ids "$home") == '["omarchy.reach","omarchy.network"]' ]] || fail "the migration leaves an icon the user placed" "$(bar_ids "$home")"
pass "the migration leaves a Reach icon the user already placed"

home=$(new_home default-layout)
echo '{"theme": "x"}' >"$home/.config/omarchy/shell.json"
run_migration "$home" >/dev/null
[[ $(jq -c . "$home/.config/omarchy/shell.json") == '{"theme":"x"}' ]] || fail "the migration leaves a default layout alone"
home=$(new_home no-config)
[[ $(run_migration "$home") == 0 && ! -e $home/.config/omarchy/shell.json ]] || fail "the migration needs no shell.json"
pass "the migration leaves the default layout, which has Reach, alone"

home=$(new_home broken)
echo '{"bar": ' >"$home/.config/omarchy/shell.json"
status=$(run_migration "$home")
[[ $status != 0 ]] || fail "the migration stays pending on a shell.json it can't read"
[[ $(cat "$home/.config/omarchy/shell.json") == '{"bar": ' ]] || fail "the migration leaves an unreadable shell.json as it was"
pass "the migration stays pending on a shell.json it can't read, and leaves it as it was"

home=$(new_home linked)
echo '{"bar": {"layout": {"right": [{"id": "omarchy.network"}]}}}' >"$test_tmp/dotfiles-shell.json"
ln -s "$test_tmp/dotfiles-shell.json" "$home/.config/omarchy/shell.json"
run_migration "$home" >/dev/null
[[ -L $home/.config/omarchy/shell.json ]] || fail "the migration keeps a linked shell.json a link"
[[ $(bar_ids "$home") == '["omarchy.reach","omarchy.network"]' ]] || fail "the migration writes through a linked shell.json" "$(bar_ids "$home")"
pass "the migration writes through a shell.json linked from dotfiles"
