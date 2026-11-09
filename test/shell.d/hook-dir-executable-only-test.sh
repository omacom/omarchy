#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

fake_home="$work_dir/home"
hook_dir="$fake_home/.config/omarchy/hooks/post-update.d"
mkdir -p "$hook_dir"

# The directory convention already ships two kinds of file: runnable hooks
# (mode 755, e.g. setup-agent.hook) and inert samples (mode 644, *.sample).
# A hook runner that goes by "any file that is not .sample" executes the
# second kind of thing whenever it is not named .sample: a README, an editor
# backup, notes. `omarchy hook install` chmods 755, so the executable bit is
# already how the package says "this one runs".

make_hook() {
  local path=$1 mode=$2 label=$3
  printf 'printf "%%s\\n" %q >> "$HOME/order"\n' "$label" >"$path"
  chmod "$mode" "$path"
}

make_hook "$hook_dir/10-first.hook" 755 "10"
make_hook "$hook_dir/20-second.hook" 755 "20"
# Not executable: dropped in by a person, not installed. Must not run.
make_hook "$hook_dir/README.md" 644 "readme"
# Executable but a sample: skipped for its own reason, every time.
make_hook "$hook_dir/30-example.sample" 755 "sample"

HOME="$fake_home" "$ROOT/bin/omarchy-hook" post-update

order=$(cat "$fake_home/order")
if [[ $order != $'10\n20' ]]; then
  fail "hook runner should run the two executable hooks in name order and nothing else; got: $(printf '%q' "$order")"
fi
pass "hook runner runs executable hooks in name order and skips the rest"

# A non-executable file alone must leave the directory silently inert rather
# than half-running it.
rm -f "$fake_home/order"
chmod 644 "$hook_dir/10-first.hook" "$hook_dir/20-second.hook"
HOME="$fake_home" "$ROOT/bin/omarchy-hook" post-update
if [[ -f "$fake_home/order" ]]; then
  fail "hook runner executed a directory of non-executable files"
fi
pass "hook runner leaves a directory with no executable hook inert"
