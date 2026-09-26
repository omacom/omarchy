#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1790539777.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
foot_config="$home/.config/foot/foot.ini"

run_migration() {
  HOME="$home" bash -euo pipefail "$migration" >/dev/null
}

reset_home() {
  rm -rf "$home"
  mkdir -p "$home/.config/foot"
}

# The shipped config with the Insert-only bindings put back is exactly what an
# older install has, so the repair has to land on the shipped config byte for byte.
reset_home
sed \
  -e 's/^clipboard-copy=.*/clipboard-copy=Control+Insert/' \
  -e 's/^clipboard-paste=.*/clipboard-paste=Shift+Insert/' \
  "$ROOT/config/foot/foot.ini" >"$foot_config"

run_migration

diff -u "$ROOT/config/foot/foot.ini" "$foot_config" >/dev/null ||
  fail "chord repair restores the shipped foot config" "$(diff -u "$ROOT/config/foot/foot.ini" "$foot_config")"
pass "chord repair restores the shipped foot config"

before=$(sha256sum "$foot_config")
run_migration
[[ $before == $(sha256sum "$foot_config") ]] || fail "chord repair is idempotent"
pass "chord repair is idempotent"

# A current config already has the chords.
reset_home
cp "$ROOT/config/foot/foot.ini" "$foot_config"
run_migration
diff -u "$ROOT/config/foot/foot.ini" "$foot_config" >/dev/null ||
  fail "chord repair leaves a current config alone" "$(diff -u "$ROOT/config/foot/foot.ini" "$foot_config")"
pass "chord repair leaves a current config alone"

# A binding the user changed is theirs, and search mode has its own
# clipboard-paste that universal paste never reaches.
reset_home
cat >"$foot_config" <<'EOF'
[key-bindings]
clipboard-copy=Control+Insert Mod4+c
clipboard-paste=Shift+Insert

[search-bindings]
clipboard-paste=Shift+Insert
EOF

run_migration

expected=$(printf '%s\n' '[key-bindings]' 'clipboard-copy=Control+Insert Mod4+c' 'clipboard-paste=Shift+Insert Control+Shift+v XF86Paste' '' '[search-bindings]' 'clipboard-paste=Shift+Insert')
[[ $(cat "$foot_config") == "$expected" ]] ||
  fail "chord repair only rewrites the shipped key-bindings lines" "$(cat -A "$foot_config")"
pass "chord repair only rewrites the shipped key-bindings lines"

# Dotfile setups symlink the config; the link has to survive the rewrite.
reset_home
mkdir -p "$home/dotfiles"
printf '%s\n' '[key-bindings]' 'clipboard-copy=Control+Insert' >"$home/dotfiles/foot.ini"
ln -sf "$home/dotfiles/foot.ini" "$foot_config"

run_migration

[[ -L $foot_config ]] || fail "chord repair writes through a symlinked config"
grep -qx 'clipboard-copy=Control+Insert Control+Shift+c XF86Copy' "$home/dotfiles/foot.ini" ||
  fail "chord repair rewrites the symlink target" "$(cat "$home/dotfiles/foot.ini")"
pass "chord repair writes through a symlinked config"

# Machines without foot have nothing to repair.
reset_home
rmdir "$home/.config/foot"
run_migration
[[ ! -e $home/.config/foot ]] || fail "chord repair creates nothing without a foot config"
pass "chord repair creates nothing without a foot config"
