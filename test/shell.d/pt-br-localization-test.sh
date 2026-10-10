#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

keyboard_cmd="$ROOT/bin/omarchy-keyboard-set"
keyboard_menu="$ROOT/bin/omarchy-menu-keyboard"
locale_cmd="$ROOT/bin/omarchy-locale-set"
locale_menu="$ROOT/bin/omarchy-menu-locale"
menu_json="$ROOT/default/omarchy/omarchy-menu.pt_BR.jsonc"
menu_qml="$ROOT/shell/plugins/menu/Menu.qml"

# 1. Executable and metadata contract
[[ -x $keyboard_cmd ]] || fail "omarchy-keyboard-set is executable"
[[ -x $keyboard_menu ]] || fail "omarchy-menu-keyboard is executable"
[[ -x $locale_cmd ]] || fail "omarchy-locale-set is executable"
[[ -x $locale_menu ]] || fail "omarchy-menu-locale is executable"

grep -F '# omarchy:group=keyboard' "$keyboard_cmd" >/dev/null || fail "keyboard-set declares group=keyboard"
grep -F '# omarchy:name=set' "$keyboard_cmd" >/dev/null || fail "keyboard-set declares name=set"
grep -F '# omarchy:group=locale' "$locale_cmd" >/dev/null || fail "locale-set declares group=locale"
grep -F '# omarchy:name=set' "$locale_cmd" >/dev/null || fail "locale-set declares name=set"

pass "localization CLI scripts declare valid Omarchy routing metadata"

# 2. Menu JSONC validation
node -e "
const fs = require('fs');
const content = fs.readFileSync('$menu_json', 'utf8');
const lines = content.split('\n').filter(l => !l.trim().startsWith('//')).join('\n');
const parsed = JSON.parse(lines);
if (!parsed.apps || !parsed.system || !parsed.setup) {
  process.exit(1);
}
" || fail "omarchy-menu.pt_BR.jsonc is valid JSONC with required root items"

pass "omarchy-menu.pt_BR.jsonc parses correctly and includes core categories"

# 3. Dynamic locale detection in Menu.qml
grep -F 'isPtBrLocale' "$menu_qml" >/dev/null || fail "Menu.qml checks for pt-BR locale"
grep -F 'omarchy-menu.pt_BR.jsonc' "$menu_qml" >/dev/null || fail "Menu.qml loads pt-BR menu catalog"

pass "Menu.qml dynamically routes to Portuguese catalog on pt-BR locales"

# 4. Keyboard set script uses hyprctl eval hl.config safely and preserves Latin shortcuts
grep -F 'hyprctl eval "$lua_cmd"' "$keyboard_cmd" >/dev/null || fail "keyboard-set updates Hyprland layout via hyprctl eval"
grep -F 'non_latin_layouts' "$keyboard_cmd" >/dev/null || fail "keyboard-set handles non-Latin layout rules"

pass "omarchy-keyboard-set updates live compositor state safely with non-Latin fallback"
