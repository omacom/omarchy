#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
mkdir -p "$test_dir/bin" "$test_home/.config/"{alacritty,foot,ghostty,kitty}
cp "$ROOT/config/alacritty/alacritty.toml" "$test_home/.config/alacritty/alacritty.toml"
cp "$ROOT/config/foot/foot.ini" "$test_home/.config/foot/foot.ini"
cp "$ROOT/config/ghostty/config" "$test_home/.config/ghostty/config"
cp "$ROOT/etc/xdg/kitty/kitty.conf" "$test_home/.config/kitty/kitty.conf"
printf 'Adwaita Sans 11\n' >"$test_home/font-name"
printf '1.0\n' >"$test_home/text-scaling-factor"

cat >"$test_dir/bin/gsettings" <<'SH'
#!/bin/bash
case "$1 $3" in
  'get font-name') printf "'%s'\n" "$(<"$HOME/font-name")" ;;
  'get text-scaling-factor') printf '%s\n' "$(<"$HOME/text-scaling-factor")" ;;
  'set font-name') printf '%s\n' "$4" >"$HOME/font-name" ;;
  'set text-scaling-factor') printf '%s\n' "$4" >"$HOME/text-scaling-factor" ;;
  'reset text-scaling-factor') printf '1.0\n' >"$HOME/text-scaling-factor" ;;
  'set '*) : ;;
  *) exit 1 ;;
esac
SH
printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/pkill"
printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/omarchy-restart-shell"
printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/omarchy-hook"
printf '#!/bin/bash\nprintf "Test Font\\n"\n' >"$test_dir/bin/fc-list"
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/pgrep"
chmod +x "$test_dir/bin/"*

run_command() {
  env HOME="$test_home" PATH="$test_dir/bin:$ROOT/bin:$PATH" bash "$1" "${@:2}"
}

grep -q '^base-size = 13$' "$ROOT/default/themed/shell.toml.tpl" || fail "theme starts at 13px"
grep -q 'property int fontBaseSize: 13' "$ROOT/shell/Commons/Style.qml" || fail "shell fallback starts at 13px"
grep -q 'var nextBase = 13' "$ROOT/shell/Commons/Style.qml" || fail "shell reload falls back to 13px"
grep -q 'textSizeStops: \[10, 11, 12, 13, 14, 16, 18\]' "$ROOT/shell/plugins/panels/monitor/Panel.qml" || fail "display slider has seven new stops"
pass "shell theme, fallback, and display slider use the new defaults"

run_command "$ROOT/install/user/first-run/gnome-theme.sh"
[[ $(<"$test_home/font-name") == "Adwaita Sans 9" ]] || fail "first run sets GTK interface font to 9pt"
[[ $(<"$test_home/text-scaling-factor") == "1.0" ]] || fail "first run keeps GTK scale at 1.0"
pass "first run sets GTK font to 9pt without scaling"

for step in '10:0.7778:7' '11:0.8889:8' '12:0.8889:8' '13:1.0000:9' '14:1.1111:10' '16:1.2222:11' '18:1.3333:12'; do
  IFS=: read -r shell gtk terminal <<<"$step"
  run_command "$ROOT/bin/omarchy-display-text-size" "$shell"
  grep -q "^base-size = $shell$" "$test_home/.config/omarchy/shell.toml" || fail "shell changes at $shell"
  [[ $(<"$test_home/text-scaling-factor") == "$gtk" ]] || fail "GTK scales at $shell"
  [[ $(<"$test_home/font-name") == "Adwaita Sans 9" ]] || fail "GTK font stays 9pt at $shell"
  grep -q "^size = $terminal$" "$test_home/.config/alacritty/alacritty.toml" || fail "Alacritty scales at $shell"
  grep -q "^font=.*:size=$terminal$" "$test_home/.config/foot/foot.ini" || fail "Foot scales at $shell"
  grep -q "^font-size = $terminal$" "$test_home/.config/ghostty/config" || fail "Ghostty scales at $shell"
  grep -q "^font_size $terminal.0$" "$test_home/.config/kitty/kitty.conf" || fail "Kitty scales at $shell"
done
pass "all seven slider stops scale the shell, GTK, and four terminals"

run_command "$ROOT/bin/omarchy-display-text-size" reset
[[ $(<"$test_home/text-scaling-factor") == "1.0" ]] || fail "reset restores GTK scale"
[[ $(<"$test_home/font-name") == "Adwaita Sans 9" ]] || fail "reset preserves GTK font"
output=$(run_command "$ROOT/bin/omarchy-display-text-size")
[[ $output == *"text size: 13 (default) px"* && $output == *"terminal font: 9 pt"* ]] || fail "reset reports 13px and 9pt defaults"
pass "reset restores 13px shell, 9pt terminals, and GTK scale 1.0"

run_command "$ROOT/bin/omarchy-font-set" "Test Font"
grep -q '^font=Test Font:size=9$' "$test_home/.config/foot/foot.ini" || fail "changing font family keeps Foot at 9pt"
pass "changing the font family preserves Foot's 9pt default"
