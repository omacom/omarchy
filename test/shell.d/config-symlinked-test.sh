#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
dotfiles="$tmpdir/dotfiles"
mkdir -p "$home/.config/hypr" "$dotfiles/omarchy"
touch "$home/.config/hypr/looknfeel.lua" "$dotfiles/bindings.lua" "$dotfiles/omarchy/shell.json"
ln -s "$dotfiles/bindings.lua" "$home/.config/hypr/bindings.lua"
ln -s "$dotfiles/omarchy" "$home/.config/omarchy"

symlinked() {
  HOME="$home" "$ROOT/bin/omarchy-config-symlinked" "$1"
}

symlinked "$home/.config/hypr/bindings.lua" || fail "a config linked into a dotfiles folder is symlink-managed"
symlinked "$home/.config/omarchy/shell.json" || fail "a config inside a linked folder is symlink-managed"
symlinked "$home/.config/omarchy/missing.json" || fail "a missing config inside a linked folder is symlink-managed"
pass "config-symlinked finds a link at the config or a folder above it"

symlinked "$home/.config/hypr/looknfeel.lua" && fail "a plain config is not symlink-managed"
symlinked "$home/.config/hypr/missing.lua" && fail "a missing config in a plain folder is not symlink-managed"
pass "config-symlinked leaves plain configs to migrations"

# Some systems reach every home through a link, such as /home to /var/home.
ln -s "$home" "$tmpdir/linked-home"
HOME="$tmpdir/linked-home" "$ROOT/bin/omarchy-config-symlinked" "$tmpdir/linked-home/.config/hypr/looknfeel.lua" &&
  fail "a link at the home folder itself does not count"
pass "config-symlinked ignores a link at the home folder"
