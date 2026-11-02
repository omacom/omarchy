#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
omarchy_path="$tmpdir/omarchy"

mkdir -p "$home/.config/hypr" "$omarchy_path/config/hypr"

cat >"$omarchy_path/config/hypr/bindings.lua" <<'EOF'
-- refreshed from OMARCHY_PATH
EOF

cat >"$home/.config/hypr/bindings.lua" <<'EOF'
-- existing user config
EOF

HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/bindings.lua >/dev/null

cmp -s "$omarchy_path/config/hypr/bindings.lua" "$home/.config/hypr/bindings.lua" ||
  fail "refresh-config copies from OMARCHY_PATH/config"

backup=$(find "$home/.config/hypr" -name 'bindings.lua.bak.*' -print -quit)
[[ -n $backup ]] || fail "refresh-config backs up replaced user config"
grep -Fq -- '-- existing user config' "$backup" ||
  fail "refresh-config backup contains previous user config"

pass "refresh-config copies from OMARCHY_PATH/config and backs up existing files"

if HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/missing.lua >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "refresh-config rejects configs missing from OMARCHY_PATH/config"
fi

grep -Fq 'Not a shipped user config: hypr/missing.lua' "$tmpdir/err" ||
  fail "refresh-config reports missing shipped config"

pass "refresh-config validates against OMARCHY_PATH/config"

mkdir -p "$tmpdir/dotfiles"
cat >"$tmpdir/dotfiles/input.lua" <<'EOF2'
-- stowed user config
EOF2
cp "$tmpdir/dotfiles/input.lua" "$omarchy_path/config/hypr/stowed.lua"
echo '-- refreshed input' >"$omarchy_path/config/hypr/input.lua"
ln -s "$tmpdir/dotfiles/input.lua" "$home/.config/hypr/input.lua"
ln -s "$tmpdir/dotfiles/input.lua" "$home/.config/hypr/stowed.lua"

HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/input.lua >/dev/null

grep -Fq -- '-- stowed user config' "$tmpdir/dotfiles/input.lua" ||
  fail "refresh-config leaves the target of a symlinked config alone"
[[ -f $home/.config/hypr/input.lua && ! -L $home/.config/hypr/input.lua ]] ||
  fail "refresh-config replaces a symlinked config with a regular file"
cmp -s "$omarchy_path/config/hypr/input.lua" "$home/.config/hypr/input.lua" ||
  fail "refresh-config copies the default over a symlinked config"
backup=$(find "$home/.config/hypr" -name 'input.lua.bak.*' -print -quit)
[[ -L $backup && $(readlink "$backup") == "$tmpdir/dotfiles/input.lua" ]] ||
  fail "refresh-config backs up a symlinked config as the symlink"

HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/stowed.lua >/dev/null

[[ -L $home/.config/hypr/stowed.lua ]] ||
  fail "refresh-config leaves a symlinked config matching the default alone"
[[ -z $(find "$home/.config/hypr" -name 'stowed.lua.bak.*' -print -quit) ]] ||
  fail "refresh-config makes no backup when nothing changes"

pass "refresh-config replaces symlinked configs without writing through them"

echo '-- private user config' >"$home/.config/hypr/looknfeel.lua"
echo '-- refreshed looknfeel' >"$omarchy_path/config/hypr/looknfeel.lua"
chmod 600 "$home/.config/hypr/looknfeel.lua"
ln "$home/.config/hypr/looknfeel.lua" "$tmpdir/looknfeel-link.lua"

HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/looknfeel.lua >/dev/null

cmp -s "$omarchy_path/config/hypr/looknfeel.lua" "$home/.config/hypr/looknfeel.lua" ||
  fail "refresh-config copies the default over a regular config"
[[ $(stat -c %a "$home/.config/hypr/looknfeel.lua") == "600" ]] ||
  fail "refresh-config keeps a regular config's mode"
cmp -s "$omarchy_path/config/hypr/looknfeel.lua" "$tmpdir/looknfeel-link.lua" ||
  fail "refresh-config keeps a regular config's hard links"

pass "refresh-config overwrites regular configs in place"
