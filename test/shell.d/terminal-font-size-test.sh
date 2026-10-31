#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
stubs="$test_dir/bin"
calls="$test_dir/calls.log"
mkdir -p "$stubs" "$test_home/.config"/{alacritty,ghostty,kitty,foot}

cp "$ROOT/config/alacritty/alacritty.toml" "$test_home/.config/alacritty/alacritty.toml"
cp "$ROOT/config/ghostty/config" "$test_home/.config/ghostty/config"
cp "$ROOT/config/kitty/kitty.conf" "$test_home/.config/kitty/kitty.conf"
cp "$ROOT/config/foot/foot.ini" "$test_home/.config/foot/foot.ini"

# Nothing may signal or notify the real session. pgrep reports no running
# terminals; fc-list knows one font, for omarchy-font-set.
for name in pkill gsettings omarchy-notification-send omarchy-restart-shell omarchy-hook; do
  printf '#!/bin/bash\nprintf "%s %%s\\n" "$*" >>"%s"\n' "$name" "$calls" >"$stubs/$name"
done
printf '#!/bin/bash\nexit 1\n' >"$stubs/pgrep"
printf '#!/bin/bash\necho "/usr/share/fonts/Test.ttf: Test Mono:style=Regular"\n' >"$stubs/fc-list"
chmod +x "$stubs"/*

run() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$test_dir" PATH="$stubs:$ROOT/bin:$PATH" "$@"
}

sizes() {
  printf '%s|%s|%s|%s' \
    "$(grep -oP '^size = \K.*' "$test_home/.config/alacritty/alacritty.toml")" \
    "$(grep -oP '^font-size = \K.*' "$test_home/.config/ghostty/config")" \
    "$(grep -oP '^font_size \K.*' "$test_home/.config/kitty/kitty.conf" | tail -1)" \
    "$(grep -oP ':size=\K[0-9.]+' "$test_home/.config/foot/foot.ini")"
}

[[ $(run omarchy-terminal-font-size) == "9" ]] || fail "reports the stock terminal size" "$(run omarchy-terminal-font-size)"
pass "reports the stock terminal size"

run omarchy-terminal-font-size 12
[[ $(sizes) == "12|12|12.0|12" ]] || fail "sets every terminal's size" "$(sizes)"
[[ $(run omarchy-terminal-font-size) == "12" ]] || fail "reads back the new size"
grep -q 'font-family = "JetBrainsMono Nerd Font"' "$test_home/.config/ghostty/config" || fail "leaves the font family alone"
grep -q '^font=JetBrainsMono Nerd Font:size=12' "$test_home/.config/foot/foot.ini" || fail "leaves Foot's font family alone"
grep -q '^pkill -SIGUSR2 ghostty' "$calls" || fail "reloads Ghostty"
grep -q '^pkill -USR1 kitty' "$calls" || fail "reloads Kitty"
! grep -q '^gsettings' "$calls" || fail "leaves GTK text scaling alone"
[[ ! -e $test_home/.config/omarchy/shell.toml ]] || fail "leaves the shell text size alone"
pass "sets only the terminal size, in every terminal"

run omarchy-terminal-font-size 08
[[ $(sizes) == "8|8|8.0|8" ]] || fail "reads a leading zero as decimal" "$(sizes)"
pass "reads a leading zero as decimal"

for bad in 5 25 abc 1.5; do
  if run omarchy-terminal-font-size "$bad" 2>/dev/null; then
    fail "rejects $bad"
  fi
done
[[ $(sizes) == "8|8|8.0|8" ]] || fail "a rejected size changes nothing" "$(sizes)"
pass "rejects sizes outside 6–24 and non-integers"

run omarchy-terminal-font-size reset
[[ $(sizes) == "9|9|9.0|9" ]] || fail "reset returns to 9pt" "$(sizes)"
pass "reset returns to 9pt"

: >"$calls"
run omarchy-display-text-size 16
[[ $(sizes) == "12|12|12.0|12" ]] || fail "desktop text size keeps terminals in proportion" "$(sizes)"
grep -q '^gsettings set org.gnome.desktop.interface text-scaling-factor' "$calls" || fail "desktop text size still scales GTK"
grep -q '^base-size = 16' "$test_home/.config/omarchy/shell.toml" || fail "desktop text size still scales the shell"
[[ $(run omarchy-display-text-size) == *"terminal font: 12 pt"* ]] || fail "desktop text size reports the terminal size"
pass "desktop text size sets terminals through omarchy-terminal-font-size"

run omarchy-terminal-font-size 14
run omarchy-font-set "Test Mono"
grep -q '^font=Test Mono:size=14' "$test_home/.config/foot/foot.ini" || fail "changing the font keeps Foot's size" "$(grep '^font=' "$test_home/.config/foot/foot.ini")"
pass "changing the font keeps Foot's size"
