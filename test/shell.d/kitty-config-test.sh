#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
kitty_config="$test_home/.config/kitty/kitty.conf"
mkdir -p "$(dirname "$kitty_config")" "$test_dir/bin"

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

# Link the other stock terminal configs from a dotfiles checkout, as a dotfiles
# manager would; the edits must land in the targets and leave the links alone.
dotfiles="$test_dir/dotfiles"
linked_configs=(alacritty/alacritty.toml ghostty/config foot/foot.ini)
for config in "${linked_configs[@]}"; do
  mkdir -p "$dotfiles/$(dirname "$config")" "$test_home/.config/$(dirname "$config")"
  cp "$ROOT/config/$config" "$dotfiles/$config"
  ln -s "$dotfiles/$config" "$test_home/.config/$config"
done
run_command omarchy-font-set 'Test Font'
run_command omarchy-display-text-size 16
for config in "${linked_configs[@]}"; do
  [[ -L $test_home/.config/$config ]] || fail "$config stays a symlink"
done
grep -q 'family = "Test Font"' "$dotfiles/alacritty/alacritty.toml" || fail "alacritty font lands in the symlink target"
grep -qx 'size = 12' "$dotfiles/alacritty/alacritty.toml" || fail "alacritty size lands in the symlink target"
grep -qx 'font-family = "Test Font"' "$dotfiles/ghostty/config" || fail "ghostty font lands in the symlink target"
grep -qx 'font-size = 12' "$dotfiles/ghostty/config" || fail "ghostty size lands in the symlink target"
grep -qx 'font=Test Font:size=12' "$dotfiles/foot/foot.ini" || fail "foot font and size land in the symlink target"
pass "font controls write through symlinked terminal configs and keep them linked"

# try-omarchy VMs put a wrapper named kitty on PATH that exits 127 until Kitty
# is installed, so a command on PATH is not enough: ask Kitty itself.
if "$ROOT/bin/omarchy-cmd-present" kitty && kitty --version >/dev/null 2>&1; then
  kitty +runpy "$(cat "$ROOT/test/shell.d/fixtures/kitty/check-config.py")"
else
  skip "Kitty not installed; skipping native config parser checks"
fi
