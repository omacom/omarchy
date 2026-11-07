#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
dotfiles="$test_dir/dotfiles"
configs=(alacritty/alacritty.toml ghostty/config foot/foot.ini)

# Link each stock terminal config from a dotfiles checkout, as a dotfiles
# manager would.
for config in "${configs[@]}"; do
  mkdir -p "$dotfiles/$(dirname "$config")" "$test_home/.config/$(dirname "$config")"
  cp "$ROOT/config/$config" "$dotfiles/$config"
  ln -s "$dotfiles/$config" "$test_home/.config/$config"
done

# Exercise the real font commands without changing the running desktop.
mkdir -p "$test_dir/bin"
for command in pkill omarchy-restart-shell omarchy-hook omarchy-notification-send gsettings; do
  printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/pgrep"
printf '#!/bin/bash\nprintf "Test Font\\n"\n' >"$test_dir/bin/fc-list"
chmod +x "$test_dir/bin/"*

run_command() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/$@"
}

run_command omarchy-font-set 'Test Font' >/dev/null
run_command omarchy-display-text-size 16 >/dev/null

for config in "${configs[@]}"; do
  [[ -L $test_home/.config/$config ]] || fail "$config stays a symlink"
done
pass "font and text size commands keep symlinked terminal configs linked"

grep -q 'family = "Test Font"' "$dotfiles/alacritty/alacritty.toml" || fail "alacritty font lands in the symlink target"
grep -qx 'size = 12' "$dotfiles/alacritty/alacritty.toml" || fail "alacritty size lands in the symlink target"
grep -qx 'font-family = "Test Font"' "$dotfiles/ghostty/config" || fail "ghostty font lands in the symlink target"
grep -qx 'font-size = 12' "$dotfiles/ghostty/config" || fail "ghostty size lands in the symlink target"
grep -qx 'font=Test Font:size=12' "$dotfiles/foot/foot.ini" || fail "foot font and size land in the symlink target"
pass "font and text size changes are written through to the symlink targets"
