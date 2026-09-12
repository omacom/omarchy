#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
kitty_config="$test_home/.config/kitty/kitty.conf"
legacy="$ROOT/test/shell.d/fixtures/kitty/legacy.conf"
migration="$ROOT/migrations/1788745941.sh"
mkdir -p "$(dirname "$kitty_config")" "$test_dir/bin"

run_migration() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration"
}

cp "$legacy" "$kitty_config"
output=$(run_migration)
cmp -s "$ROOT/config/kitty/kitty.conf" "$kitty_config" || fail "stock config becomes the user template"
backups=("$kitty_config".bak.*)
cmp -s "$legacy" "${backups[0]}" || fail "refresh backs up the original config"
[[ $output == *"Close and reopen all Kitty windows"* ]] || fail "migration requires a full restart"
pass "stock config is refreshed with a backup and restart guidance"

output=$(run_migration)
cmp -s "$ROOT/config/kitty/kitty.conf" "$kitty_config" || fail "stock migration is idempotent"
[[ $output != *"Close and reopen"* ]] || fail "rerun does not repeat restart guidance"
pass "stock migration is idempotent"

cat >"$kitty_config" <<'CONF'
# Keep this comment and my theme choice
include my-theme.conf
font_family My Font
font_size 13
map ctrl+insert
include shortcuts.conf
map shift+insert paste_from_clipboard
  allow_remote_control   yes
allow_remote_control y
allow_remote_control true
# allow_remote_control yes
listen_on unix:/tmp/my-kitty
CONF
printf 'allow_remote_control yes  \n' >>"$kitty_config"
cp "$kitty_config" "$test_dir/custom-original"
cat >"$test_dir/expected" <<'CONF'
# Keep this comment and my theme choice
include my-theme.conf
font_family My Font
font_size 13
map ctrl+insert
include shortcuts.conf
map shift+insert paste_from_clipboard
#   allow_remote_control   yes
# allow_remote_control y
# allow_remote_control true
# allow_remote_control yes
listen_on unix:/tmp/my-kitty
CONF
printf '# allow_remote_control yes  \n' >>"$test_dir/expected"
chmod 600 "$kitty_config"
run_migration >/dev/null
cmp -s "$test_dir/expected" "$kitty_config" || fail "customizations survive the security repair"
[[ $(stat -c %a "$kitty_config") == "600" ]] || fail "migration preserves config permissions"
backup=$(rg -l 'allow_remote_control true' "$kitty_config".bak.* | tail -1)
cmp -s "$test_dir/custom-original" "$backup" || fail "custom config is backed up"
run_migration >/dev/null
cmp -s "$test_dir/expected" "$kitty_config" || fail "custom migration is idempotent"
pass "custom config repair preserves ordering, mappings, theme, permissions, and original backup"

for mode in no n false socket-only socket password; do
  printf 'allow_remote_control %s\nfont_size 13\n' "$mode" >"$kitty_config"
  cp "$kitty_config" "$test_dir/expected"
  run_migration >/dev/null
  cmp -s "$test_dir/expected" "$kitty_config" || fail "migration preserves $mode"
done
pass "explicit restricted remote-control modes are preserved"

printf 'font_size 13\n' >"$kitty_config"
cp "$kitty_config" "$test_dir/expected"
run_migration >/dev/null
cmp -s "$test_dir/expected" "$kitty_config" || fail "omitted setting stays omitted"
rm "$kitty_config"
run_migration >/dev/null
[[ ! -e $kitty_config ]] || fail "absent config stays absent"
pass "migration leaves omitted settings and absent user configs alone"

printf 'allow_remote_control yes\nfont_size 13\n' >"$test_dir/dotfiles.conf"
ln -s "$test_dir/dotfiles.conf" "$kitty_config"
run_migration >/dev/null
[[ -L $kitty_config ]] || fail "migration preserves a dotfile symlink"
grep -qx '# allow_remote_control yes' "$test_dir/dotfiles.conf" || fail "symlink target is repaired"
pass "custom dotfile symlinks survive the repair"
rm "$kitty_config"

# Exercise the real font commands without changing the running desktop.
for command in pkill omarchy-restart-shell omarchy-hook omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/pgrep"
printf '#!/bin/bash\nprintf "Test Font\\n"\n' >"$test_dir/bin/fc-list"
printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/kitty"
cat >"$test_dir/bin/gsettings" <<'SH'
#!/bin/bash
if [[ $1 == "get" ]]; then
  if [[ $3 == "font-name" ]]; then
    echo "'Sans 11'"
  else
    echo 1.0
  fi
fi
SH
chmod +x "$test_dir/bin/"*

run_command() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/$@"
}

cp "$ROOT/config/kitty/kitty.conf" "$kitty_config"
output=$(run_command omarchy-display-text-size)
[[ $output == *"terminal font: 9 pt"* ]] || fail "size report accounts for inherited Kitty default"
run_command omarchy-font-set 'Test Font'
run_command omarchy-display-text-size 16
grep -qx 'font_family Test Font' "$kitty_config" || fail "font command creates family override"
run_command omarchy-font-set Font
grep -qx 'font_family Font' "$kitty_config" || fail "font command updates family override"
[[ $(grep -c '^font_family ' "$kitty_config") == "1" ]] || fail "font update avoids duplicate overrides"
grep -qx 'font_size 12.0' "$kitty_config" || fail "size command creates size override"
grep -qx '# font_size 12' "$kitty_config" || fail "font commands keep commented instructions"
run_command omarchy-display-text-size 18
[[ $(grep -c '^font_size ' "$kitty_config") == "1" ]] || fail "size update avoids duplicate overrides"
run_command omarchy-display-text-size reset
grep -qx 'font_size 9.0' "$kitty_config" || fail "size reset restores default"
pass "font controls add and update overrides in the minimal template"

rm "$kitty_config"
output=$(run_command omarchy-display-text-size)
[[ $output == *"terminal font: 9 pt"* ]] || fail "size report handles absent Kitty config"
run_command omarchy-font-set 'Test Font'
run_command omarchy-display-text-size 16
grep -qx 'font_family Test Font' "$kitty_config" || fail "font command handles absent config"
grep -qx 'font_size 12.0' "$kitty_config" || fail "size command handles absent setting"
! grep -q '^include ' "$kitty_config" || fail "font controls must not opt users back into theming"
rm "$kitty_config"
run_command omarchy-display-text-size 16
grep -qx 'font_size 12.0' "$kitty_config" || fail "size command handles absent config"
pass "font controls create missing Kitty overrides without restoring the theme include"

if "$ROOT/bin/omarchy-cmd-present" kitty; then
  kitty +runpy "$(cat "$ROOT/test/shell.d/fixtures/kitty/check-config.py")"
else
  pass "Kitty not installed; skipping native config parser checks"
fi
