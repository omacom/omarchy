#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
drop_in="$test_home/.config/fontconfig/conf.d/20-omarchy-hinting.conf"
fonts_conf="$test_home/.config/fontconfig/fonts.conf"
calls="$test_dir/calls"
mkdir -p "$test_home/.config/omarchy/hooks/font-hinting.d" "$test_dir/bin"

for command in omarchy-restart-shell omarchy-notification-send gsettings; do
  printf '#!/bin/bash\nprintf "%%s\\n" "%s $*" >>"%s"\n' "$command" "$calls" >"$test_dir/bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/pgrep"
printf '#!/bin/bash\nprintf "Test Font\\n"\n' >"$test_dir/bin/fc-list"
chmod +x "$test_dir/bin/"*
printf '#!/bin/bash\nprintf "%%s\\n" "hook $1" >>"%s"\n' "$calls" >"$test_home/.config/omarchy/hooks/font-hinting.d/record"

run_command() {
  env HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/$@"
}

[[ ! -e $drop_in ]] || fail "test starts without a hinting override"
default_hinting=$(run_command omarchy-font-hinting)
[[ $default_hinting =~ ^(none|slight|medium|full)$ ]] || fail "current hinting is one of the four styles" "$default_hinting"
[[ ! -e $calls ]] || fail "reading the hinting changes nothing"
pass "font hinting reports the style fontconfig resolves"

for style in full medium slight none; do
  : >"$calls"
  run_command omarchy-font-hinting "$style"
  grep -q "<const>hint$style</const>" "$drop_in" || fail "$style writes its hintstyle"
  [[ $(run_command omarchy-font-hinting) == "$style" ]] || fail "fontconfig resolves $style after setting it"
  grep -qx "gsettings set org.gnome.desktop.interface font-hinting $style" "$calls" || fail "$style reaches GTK"
  grep -q '^omarchy-restart-shell' "$calls" || fail "$style restarts the shell"
  grep -qx "hook $style" "$calls" || fail "$style runs the font-hinting hook"
done
grep -q '<bool>false</bool>' "$drop_in" || fail "none turns hinting off"
pass "font hinting sets fontconfig and GTK together"

run_command omarchy-font-hinting full
run_command omarchy-font-set 'Test Font' >/dev/null
grep -q 'Test Font' "$fonts_conf" || fail "font set writes fonts.conf"
[[ $(run_command omarchy-font-hinting) == "full" ]] || fail "hinting survives a font change"
pass "font hinting survives omarchy-font-set rewriting fonts.conf"

: >"$calls"
run_command omarchy-font-hinting reset
[[ ! -e $drop_in ]] || fail "reset removes the override"
[[ $(run_command omarchy-font-hinting) == "$default_hinting" ]] || fail "reset returns to the default style"
grep -qx "gsettings reset org.gnome.desktop.interface font-hinting" "$calls" || fail "reset reaches GTK"
grep -qx "hook $default_hinting" "$calls" || fail "reset runs the hook with the default style"
pass "font hinting reset restores the defaults"

: >"$calls"
if run_command omarchy-font-hinting bold 2>/dev/null; then
  fail "an unknown style is rejected"
fi
[[ ! -e $drop_in && ! -s $calls ]] || fail "an unknown style changes nothing"
pass "font hinting rejects unknown styles"

node - "$ROOT" <<'JS'
const fs = require('fs')
const path = require('path')
const root = process.argv[2]
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')
const menuJsonc = fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8')
const providerBlock = menuQml.match(/readonly property var providers: \(\{[\s\S]*?\n  \}\)/)[0]
if (!/"font-hinting": \{[\s\S]*?omarchy-font-hinting "/.test(providerBlock)) {
  console.error('menu has no font-hinting provider')
  process.exit(1)
}
if (!/"style\.font-hinting": \{[^}]*"provider":"font-hinting"\}/.test(menuJsonc)) {
  console.error('style menu has no font hinting entry')
  process.exit(1)
}
JS
pass "style menu offers font hinting"
