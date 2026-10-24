#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791698594.sh"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
layouts="$tmpdir/home/.local/state/omarchy/workspace-layouts"
mkdir -p "$layouts" "$tmpdir/dotfiles"

printf 'hl.workspace_rule({ workspace = "2", layout = "scrolling" })\n' >"$layouts/2.lua"
printf 'o.workspace_mode({ workspace = "3", mode = "floating" })\n' >"$layouts/3.lua"
printf 'o.workspace_mode({ default = "floating" })\n' >"$layouts/default.lua"
printf 'hl.workspace_rule({ workspace = "4", layout = "dwindle" })\n' >"$tmpdir/dotfiles/4.lua"
ln -s "$tmpdir/dotfiles/4.lua" "$layouts/4.lua"

# Twice, as a retried update would.
for run in 1 2; do
  env -u XDG_STATE_HOME HOME="$tmpdir/home" bash -euo pipefail "$migration" >/dev/null
done

[[ $(<"$layouts/2.lua") == 'o.workspace_mode({ workspace = "2", mode = "scrolling" })' ]] ||
  fail "a saved layout rule becomes a mode" "$(cat "$layouts/2.lua")"
[[ $(<"$layouts/3.lua") == 'o.workspace_mode({ workspace = "3", mode = "floating" })' ]] ||
  fail "a saved mode is left alone" "$(cat "$layouts/3.lua")"
[[ $(<"$layouts/default.lua") == 'o.workspace_mode({ default = "floating" })' ]] ||
  fail "the default layout is left alone" "$(cat "$layouts/default.lua")"
pass "saved layout rules become modes, and modes are left alone"

[[ -L $layouts/4.lua && $(<"$tmpdir/dotfiles/4.lua") == 'o.workspace_mode({ workspace = "4", mode = "dwindle" })' ]] ||
  fail "a symlinked layout stays linked and its target is converted" "$(ls -l "$layouts/4.lua"; cat "$tmpdir/dotfiles/4.lua")"
pass "a symlinked layout stays linked and its target is converted"
