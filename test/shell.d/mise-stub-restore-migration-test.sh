#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1790712217.sh"
[[ -f $migration ]] || fail "the restore migration is present"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
mkdir -p "$home/.local/bin" "$home/.local/state/omarchy"

run() {
  env HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    bash -euo pipefail "$migration"
}

run
[[ -x $home/.local/bin/gh ]] || fail "an empty ~/.local/bin gets the gh stub back"
[[ -x $home/.local/bin/codex ]] || fail "an empty ~/.local/bin gets the other canonical stubs"
pass "wiping ~/.local/bin restores gh from the canonical list"

printf 'user-owned\n' >"$home/.local/bin/gh"
run
[[ $(cat "$home/.local/bin/gh") == user-owned ]] || fail "an existing gh stub is left alone"
pass "existing files are not overwritten"

ln -sfn /nonexistent/user-launcher "$home/.local/bin/claude"
run
[[ -L $home/.local/bin/claude ]] || fail "a dangling user-owned launcher stays a symlink"
[[ $(readlink "$home/.local/bin/claude") == /nonexistent/user-launcher ]] || fail "a dangling user-owned launcher is not replaced"
pass "dangling user-owned launchers are left alone"

[[ -x $home/.local/bin/codex ]] || fail "a second run still leaves stubs that were already restored"
pass "the restore is idempotent"

touch "$home/.local/state/omarchy/preinstalls-removed"
rm -f "$home/.local/bin/"*
run
[[ ! -e $home/.local/bin/gh && ! -L $home/.local/bin/gh ]] || fail "preinstalls-removed does not restore gh"
[[ ! -e $home/.local/bin/codex && ! -L $home/.local/bin/codex ]] || fail "preinstalls-removed does not restore other stubs"
[[ ! -e $home/.local/bin/hey && ! -L $home/.local/bin/hey ]] || fail "preinstalls-removed does not restore hey"
pass "removed preinstalls stay removed"

# A migration that cannot finish must fail and stay pending. A fresh home, so
# the preinstalls-removed exit cannot pass this on its own.
missing=$(mktemp -d)
mkdir -p "$missing/home/.local/bin"
if env HOME="$missing/home" OMARCHY_PATH="$missing" PATH="$ROOT/bin:$PATH" \
  bash -euo pipefail "$migration" 2>/dev/null; then
  fail "a missing mise install list fails the migration"
fi
pass "a missing mise install list leaves the migration pending"
rm -rf "$missing"
