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

# try-omarchy VMs put a wrapper named kitty on PATH that exits 127 until Kitty
# is installed, so a command on PATH is not enough: ask Kitty itself.
if "$ROOT/bin/omarchy-cmd-present" kitty && kitty --version >/dev/null 2>&1; then
  kitty +runpy "$(cat "$ROOT/test/shell.d/fixtures/kitty/check-config.py")"
else
  skip "Kitty not installed; skipping native config parser checks"
fi

# Slash is the sed delimiter and ampersand is special in a replacement and in
# XML, so a family like this only survives when the command escapes it before
# rewriting each config. Reuse the stubs above.
printf '#!/bin/bash\nprintf "Fake/Font & Friends:style=Regular\\n"\n' >"$test_dir/bin/fc-list"
mkdir -p "$test_home/.config/alacritty" "$test_home/.config/ghostty" "$test_home/.config/foot"
printf 'family = "Old Font"\n' >"$test_home/.config/alacritty/alacritty.toml"
printf 'font-family = "Old Font"\n' >"$test_home/.config/ghostty/config"
printf 'font=Old Font:size=12\n' >"$test_home/.config/foot/foot.ini"
cp "$ROOT/config/kitty/kitty.conf" "$kitty_config"
printf 'font_family Old Font\n' >>"$kitty_config"
run_command omarchy-font-set 'Fake/Font & Friends'
grep -Fq 'family = "Fake/Font & Friends"' "$test_home/.config/alacritty/alacritty.toml" ||
  fail "alacritty keeps a family containing / and &" "$(cat "$test_home/.config/alacritty/alacritty.toml")"
grep -Fq 'font_family Fake/Font & Friends' "$kitty_config" ||
  fail "kitty keeps a family containing / and &" "$(cat "$kitty_config")"
[[ $(grep -c '^font_family ' "$kitty_config") == "1" ]] ||
  fail "kitty rewrites the family it already had instead of appending a second one" "$(cat "$kitty_config")"
! grep -Fq 'Old Font' "$kitty_config" ||
  fail "kitty replaces the seeded family instead of leaving it behind" "$(cat "$kitty_config")"
grep -Fq 'font-family = "Fake/Font & Friends"' "$test_home/.config/ghostty/config" ||
  fail "ghostty keeps a family containing / and &" "$(cat "$test_home/.config/ghostty/config")"
grep -Fq 'font=Fake/Font & Friends:size=12' "$test_home/.config/foot/foot.ini" ||
  fail "foot keeps a family containing / and & and the size it already had" "$(cat "$test_home/.config/foot/foot.ini")"
grep -Fq '<string>Fake/Font &amp; Friends</string>' "$test_home/.config/fontconfig/fonts.conf" ||
  fail "fontconfig escapes & in the family" "$(cat "$test_home/.config/fontconfig/fonts.conf")"
pass "font commands escape / and & for sed, TOML, ghostty, foot and fontconfig"
