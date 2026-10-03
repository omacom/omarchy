#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT

export HOME="$test_dir/home"
mkdir -p "$HOME/.config/alacritty" "$HOME/.config/kitty" "$HOME/.config/ghostty" "$HOME/.config/foot"
printf 'family = "Old Font"\n' >"$HOME/.config/alacritty/alacritty.toml"
printf 'font_family Old Font\n' >"$HOME/.config/kitty/kitty.conf"
printf 'font-family = "Old Font"\n' >"$HOME/.config/ghostty/config"
printf 'font=Old Font:size=9\n' >"$HOME/.config/foot/foot.ini"

# Stub the commands the script reaches out to. pkill and omarchy-restart-shell
# are stubbed so the test never signals a real terminal or restarts the live
# shell.
stub_dir="$test_dir/bin"
mkdir -p "$stub_dir"
cat >"$stub_dir/fc-list" <<'STUB'
#!/bin/bash
echo "Fake/Font & Friends:style=Regular"
STUB
cat >"$stub_dir/pkill" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$stub_dir/omarchy-restart-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$stub_dir/omarchy-notification-send" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$stub_dir/omarchy-hook" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$stub_dir/omarchy-cmd-present" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$stub_dir"/*

# Slash is the sed delimiter and ampersand is special in a replacement, so this
# name only survives when the script escapes it before rewriting each config.
PATH="$stub_dir:$PATH" "$ROOT/bin/omarchy-font-set" 'Fake/Font & Friends'

grep -Fq 'family = "Fake/Font & Friends"' "$HOME/.config/alacritty/alacritty.toml" ||
  fail "alacritty keeps a font name containing / and &" "$(cat "$HOME/.config/alacritty/alacritty.toml")"
pass "alacritty keeps a font name containing / and &"

grep -Fq 'font_family Fake/Font & Friends' "$HOME/.config/kitty/kitty.conf" ||
  fail "kitty keeps a font name containing / and &" "$(cat "$HOME/.config/kitty/kitty.conf")"
pass "kitty keeps a font name containing / and &"

grep -Fq 'font-family = "Fake/Font & Friends"' "$HOME/.config/ghostty/config" ||
  fail "ghostty keeps a font name containing / and &" "$(cat "$HOME/.config/ghostty/config")"
pass "ghostty keeps a font name containing / and &"

grep -Fq 'font=Fake/Font & Friends:size=9' "$HOME/.config/foot/foot.ini" ||
  fail "foot keeps a font name containing / and &" "$(cat "$HOME/.config/foot/foot.ini")"
pass "foot keeps a font name containing / and &"

grep -Fq '<string>Fake/Font &amp; Friends</string>' "$HOME/.config/fontconfig/fonts.conf" ||
  fail "fontconfig escapes & in the font family" "$(cat "$HOME/.config/fontconfig/fonts.conf")"
pass "fontconfig escapes & in the font family"
