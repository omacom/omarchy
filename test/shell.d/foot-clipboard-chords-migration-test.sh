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

# A chord the user already gave to another action stays theirs: foot rejects a
# config binding the same keys twice, in either section and whatever the modifier order.
reset_home
printf '%s\n' '[key-bindings]' 'clipboard-copy=Control+Insert' 'clipboard-paste=Shift+Insert' \
  'spawn-terminal=Shift+Control+c' '' '[text-bindings]' '\x16=Control+Shift+v' >"$foot_config"

run_migration

expected=$(printf '%s\n' '[key-bindings]' 'clipboard-copy=Control+Insert XF86Copy' \
  'clipboard-paste=Shift+Insert XF86Paste' 'spawn-terminal=Shift+Control+c' '' '[text-bindings]' '\x16=Control+Shift+v')
[[ $(cat "$foot_config") == "$expected" ]] ||
  fail "chord repair leaves a chord bound to another action alone" "$(cat -A "$foot_config")"
pass "chord repair leaves a chord bound to another action alone"

# A commented-out binding, and an uppercase key foot never matches with Shift held,
# do not hold the chord.
reset_home
printf '%s\n' '  [key-bindings]  # mine' 'clipboard-copy=Control+Insert' '# spawn-terminal=Control+Shift+c' \
  'clipboard-paste=Shift+Insert' 'search-start=Control+Shift+V' >"$foot_config"

run_migration

expected=$(printf '%s\n' '  [key-bindings]  # mine' 'clipboard-copy=Control+Insert Control+Shift+c XF86Copy' \
  '# spawn-terminal=Control+Shift+c' 'clipboard-paste=Shift+Insert Control+Shift+v XF86Paste' 'search-start=Control+Shift+V')
[[ $(cat "$foot_config") == "$expected" ]] ||
  fail "chord repair ignores commented and uppercase bindings" "$(cat -A "$foot_config")"
pass "chord repair ignores commented and uppercase bindings"

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

# A rewrite that cannot be put in place, as on a full disk, leaves the config as it was and nothing beside it.
reset_home
printf '%s\n' '[key-bindings]' 'clipboard-copy=Control+Insert' >"$foot_config"
chmod 640 "$foot_config"
before=$(cat "$foot_config")
mkdir -p "$test_dir/bin"
for tool in cat mv; do
  printf '%s\n' '#!/bin/bash' 'exit 1' >"$test_dir/bin/$tool"
  chmod +x "$test_dir/bin/$tool"
done

PATH="$test_dir/bin:$PATH" run_migration 2>/dev/null && fail "chord repair reports a failed rewrite"
[[ $(cat "$foot_config") == "$before" ]] || fail "chord repair leaves the config whole when the rewrite fails" "$(cat -A "$foot_config")"
[[ $(ls "$home/.config/foot") == foot.ini ]] || fail "chord repair cleans up after a failed rewrite" "$(ls "$home/.config/foot")"
pass "chord repair leaves the config whole when the rewrite fails"

run_migration
[[ $(stat -c %a "$foot_config") == 640 ]] || fail "chord repair keeps the config's mode" "$(stat -c %a "$foot_config")"
pass "chord repair keeps the config's mode"

# Someone who shares the config through an ACL keeps it.
if command -v setfacl >/dev/null && setfacl -m u:nobody:r "$foot_config" 2>/dev/null; then
  printf '%s\n' '[key-bindings]' 'clipboard-copy=Control+Insert' >"$foot_config"
  run_migration
  getfacl -p "$foot_config" 2>/dev/null | grep -qx 'user:nobody:r--' ||
    fail "chord repair keeps the config's ACL" "$(getfacl -p "$foot_config" 2>&1)"
  pass "chord repair keeps the config's ACL"
fi

# A linked config in a directory the user can't write to is still repaired, in place.
reset_home
mkdir -p "$home/locked"
printf '%s\n' '[key-bindings]' 'clipboard-copy=Control+Insert' >"$home/locked/foot.ini"
ln -sf "$home/locked/foot.ini" "$foot_config"
chmod 555 "$home/locked"

# Root can write to the directory anyway, so only another user reaches the in-place write.
if [[ -w $home/locked ]]; then
  chmod 755 "$home/locked"
else
  status=0
  run_migration 2>/dev/null || status=$?
  chmod 755 "$home/locked"
  (( status == 0 )) || fail "chord repair succeeds on a config in a read-only directory"

  grep -qx 'clipboard-copy=Control+Insert Control+Shift+c XF86Copy' "$home/locked/foot.ini" ||
    fail "chord repair rewrites a config in a read-only directory" "$(cat "$home/locked/foot.ini")"
  [[ $(ls "$home/locked") == foot.ini ]] || fail "chord repair leaves nothing beside a config in a read-only directory" "$(ls "$home/locked")"
  pass "chord repair rewrites a config in a read-only directory"
fi

# Machines without foot have nothing to repair.
reset_home
rmdir "$home/.config/foot"
run_migration
[[ ! -e $home/.config/foot ]] || fail "chord repair creates nothing without a foot config"
pass "chord repair creates nothing without a foot config"
