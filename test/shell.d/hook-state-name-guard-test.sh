#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

fake_home="$work_dir/home"
mkdir -p "$fake_home/.config/omarchy/hooks" "$fake_home/.local/state/omarchy"

# A hook or state name is a label, not a path. One carrying a slash, or one
# that is a bare `.` or `..`, would reach outside the hooks or state directory:
# the runner would run a script from there, the installer would mkdir/cp
# there, and state set would touch a file there.

# --- names that stay inside the directory ------------------------------------

cat >"$fake_home/.config/omarchy/hooks/test-hook" <<'SH'
touch "$HOME/hook-ran"
SH

HOME="$fake_home" "$ROOT/bin/omarchy-hook" test-hook
[[ -f $fake_home/hook-ran ]] ||
  fail "omarchy hook runs a named hook from the hooks directory"
pass "omarchy hook runs a named hook from the hooks directory"

# Dots inside a name are not a path. a..b stays inside the hooks directory.
cat >"$fake_home/.config/omarchy/hooks/a..b" <<'SH'
touch "$HOME/dotted-hook-ran"
SH

HOME="$fake_home" "$ROOT/bin/omarchy-hook" a..b
[[ -f $fake_home/dotted-hook-ran ]] ||
  fail "omarchy hook accepts a hook name with dots in the middle"
pass "omarchy hook accepts a hook name with dots in the middle"

source_hook="$work_dir/source-hook"
cat >"$source_hook" <<'SH'
#!/bin/bash
true
SH

HOME="$fake_home" "$ROOT/bin/omarchy-hook-install" post-update "$source_hook" >/dev/null
[[ -f $fake_home/.config/omarchy/hooks/post-update.d/source-hook ]] ||
  fail "omarchy hook install still installs a named hook"
pass "omarchy hook install still installs a named hook"

HOME="$fake_home" "$ROOT/bin/omarchy-hook-install" a..b "$source_hook" >/dev/null
[[ -f $fake_home/.config/omarchy/hooks/a..b.d/source-hook ]] ||
  fail "omarchy hook install accepts a hook name with dots in the middle"
pass "omarchy hook install accepts a hook name with dots in the middle"

state_dir="$fake_home/.local/state/omarchy"

HOME="$fake_home" "$ROOT/bin/omarchy-state" set reboot-required
[[ -f $state_dir/reboot-required ]] ||
  fail "omarchy state set still creates a plain state file"
pass "omarchy state set still creates a plain state file"

HOME="$fake_home" "$ROOT/bin/omarchy-state" set v1..2
[[ -f $state_dir/v1..2 ]] ||
  fail "omarchy state set accepts a state name with dots in the middle"
pass "omarchy state set accepts a state name with dots in the middle"

# --- names that would leave it ------------------------------------------------

# This file sits where a hook name of ../../evil would resolve: hooks/../.. is
# ~/.config. The same name is ~/.config/evil.d to the installer and
# ~/.local/evil to state set.
cat >"$fake_home/.config/evil" <<'SH'
touch "$HOME/escape-ran"
SH
chmod +x "$fake_home/.config/evil"

snapshot() {
  find "$fake_home" | sort
}

# A refused name exits 2 and leaves the home exactly as it was: nothing run,
# nothing created.
refused() {
  local description=$1 before after status=0
  shift
  before=$(snapshot)
  HOME="$fake_home" "$@" >/dev/null 2>&1 || status=$?
  after=$(snapshot)
  (( status == 2 )) || fail "$description" "exit: $status"
  [[ $after == "$before" ]] || fail "$description" "$(diff <(printf '%s\n' "$before") <(printf '%s\n' "$after"))"
  pass "$description"
}

for name in . .. ../../evil sub/dir; do
  refused "omarchy hook refuses a hook name of $name" "$ROOT/bin/omarchy-hook" "$name"
  refused "omarchy hook install refuses a hook name of $name" "$ROOT/bin/omarchy-hook-install" "$name" "$source_hook"
  refused "omarchy state set refuses a state name of $name" "$ROOT/bin/omarchy-state" set "$name"
done

# clear takes patterns by design ("state-name-or-pattern") and matches
# basenames through find -name, so it can never walk out of the directory.
touch "$state_dir/restart-a-required" "$state_dir/restart-b-required" "$state_dir/keep-me"
HOME="$fake_home" "$ROOT/bin/omarchy-state" clear "restart-*-required"
[[ ! -e $state_dir/restart-a-required && ! -e $state_dir/restart-b-required && -f $state_dir/keep-me ]] ||
  fail "omarchy state clear still clears matching patterns only"
pass "omarchy state clear still clears matching patterns only"
