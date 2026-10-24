#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" \
  "$test_home/.config/alacritty" \
  "$test_home/.config/ghostty" \
  "$test_home/.config/foot" \
  "$test_home/.config/kitty" \
  "$test_home/.config/fontconfig"

cat >"$mock_bin/fc-list" <<'SH'
#!/bin/bash
printf '%s\n' "CaskaydiaMono Nerd Font" "Test Font" 'Evil"; command = "id' 'Foo$HOME'
printf 'Two\nFamily\n'
SH
for stub in omarchy-restart-shell omarchy-hook omarchy-notification-send pkill; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$stub"
done
# No terminal is running, so font-set sends no restart notification
printf '#!/bin/bash\nexit 1\n' >"$mock_bin/pgrep"
# cmd-present kitty should be false so we only rewrite existing kitty.conf
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

cat >"$test_home/.config/alacritty/alacritty.toml" <<'EOF'
[font.normal]
family = "Old Font"
EOF
cat >"$test_home/.config/ghostty/config" <<'EOF'
font-family = "Old Font"
EOF
cat >"$test_home/.config/foot/foot.ini" <<'EOF'
font=Old Font:size=11
EOF
cat >"$test_home/.config/kitty/kitty.conf" <<'EOF'
font_family Old Font
EOF

run_font_set() {
  HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
    "$ROOT/bin/omarchy-font-set" "$@"
}

run_font_set "CaskaydiaMono Nerd Font"

grep -Fq 'family = "CaskaydiaMono Nerd Font"' "$test_home/.config/alacritty/alacritty.toml" ||
  fail "font-set rewrites the Alacritty family" "$(cat "$test_home/.config/alacritty/alacritty.toml")"
grep -Fq 'font-family = "CaskaydiaMono Nerd Font"' "$test_home/.config/ghostty/config" ||
  fail "font-set rewrites the Ghostty family" "$(cat "$test_home/.config/ghostty/config")"
grep -Fq 'font=CaskaydiaMono Nerd Font:size=9' "$test_home/.config/foot/foot.ini" ||
  fail "font-set rewrites the Foot font" "$(cat "$test_home/.config/foot/foot.ini")"
grep -Fxq 'font_family CaskaydiaMono Nerd Font' "$test_home/.config/kitty/kitty.conf" ||
  fail "font-set rewrites the Kitty family" "$(cat "$test_home/.config/kitty/kitty.conf")"
grep -Fq '<string>CaskaydiaMono Nerd Font</string>' "$test_home/.config/fontconfig/fonts.conf" ||
  fail "font-set writes the family into fonts.conf" "$(cat "$test_home/.config/fontconfig/fonts.conf")"
pass "font-set writes a normal family into terminal configs and fonts.conf"

if run_font_set 'Evil"; command = "id' 2>"$test_tmp/err"; then
  fail "font-set refuses a family name that would close a TOML string"
fi
grep -Fq 'cannot be written into terminal configs' "$test_tmp/err" ||
  fail "font-set names the injection refusal" "$(cat "$test_tmp/err")"
grep -Fq 'family = "CaskaydiaMono Nerd Font"' "$test_home/.config/alacritty/alacritty.toml" ||
  fail "font-set leaves terminal configs unchanged after a refused name"
pass "font-set refuses a quoted font name that would inject terminal settings"

if run_font_set $'Two\nFamily' 2>"$test_tmp/err"; then
  fail "font-set refuses a family name with a newline"
fi
if run_font_set 'Foo$HOME' 2>"$test_tmp/err"; then
  fail "font-set refuses a family name with a dollar sign"
fi
pass "font-set refuses newline and dollar metacharacters in a family name"
