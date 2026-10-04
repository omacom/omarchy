#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
mock_bin="$test_tmp/bin"
user_package="$home/.config/sublime-text/Packages/User"
source_scheme="$home/.local/state/omarchy/current/theme/Omarchy.sublime-color-scheme"
mkdir -p "$mock_bin" "$user_package" "$(dirname "$source_scheme")"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
[[ $1 == sublime-text-4 ]]
SH

cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$mock_bin"/*

cat >"$user_package/Preferences.sublime-settings" <<'JSON'
{
  // Keep the user's other settings.
  "font_size": 14,
  "theme": "A \"quoted\" theme",
}
JSON

printf '{"name":"first"}\n' >"$source_scheme"

HOME="$home" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-install-editor-sublime" || fail "Sublime installer succeeds"

preferences="$user_package/Preferences.sublime-settings"
grep -q '"theme": "Omarchy.sublime-theme"' "$preferences" || fail "installer selects the Omarchy UI theme"
grep -q '"color_scheme": "Omarchy.sublime-color-scheme"' "$preferences" || fail "installer selects the generated scheme"
grep -q '"overlay_scroll_bars": "enabled"' "$preferences" || fail "installer enables overlay scrollbars"
grep -q '"font_face": "monospace"' "$preferences" || fail "installer uses the system monospace font"
grep -q '"font_size": 14' "$preferences" || fail "installer preserves unrelated preferences"
grep -q '// Keep the user' "$preferences" || fail "installer preserves settings comments"
[[ -f $user_package/Omarchy.sublime-theme && -f $user_package/OmarchyWindow.py ]] || fail "installer copies Sublime resources"
cmp -s "$source_scheme" "$user_package/Omarchy.sublime-color-scheme" || fail "installer copies the current scheme"
compgen -G "$preferences.bak.*" >/dev/null || fail "installer backs up existing preferences"

pass "Sublime installer keeps existing settings and applies Omarchy defaults"

printf '{"name":"second"}\n' >"$source_scheme"
HOME="$home" bash "$ROOT/bin/omarchy-theme-set-sublime" || fail "Sublime theme sync succeeds"
cmp -s "$source_scheme" "$user_package/Omarchy.sublime-color-scheme" || fail "theme sync updates the scheme"
[[ ! -L $user_package/Omarchy.sublime-color-scheme ]] || fail "theme sync writes a real file"

pass "Sublime theme sync replaces the scheme without a symlink"

HOME="$home" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-font-set-sublime" 'Adwaita Mono' || fail "Sublime font sync succeeds"
grep -q '"font_face": "Adwaita Mono"' "$preferences" || fail "font sync writes the selected font"
grep -q '"font_size": 14' "$preferences" || fail "font sync preserves the user's font size"

pass "Sublime font sync preserves other preferences"

fresh_home="$test_tmp/fresh"
mkdir -p "$fresh_home/.local/state/omarchy/current/theme"
printf '{"name":"fresh"}\n' >"$fresh_home/.local/state/omarchy/current/theme/Omarchy.sublime-color-scheme"

HOME="$fresh_home" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-install-editor-sublime" || fail "Sublime installs with no prior preferences"

fresh_preferences="$fresh_home/.config/sublime-text/Packages/User/Preferences.sublime-settings"
grep -q '"font_face": "monospace"' "$fresh_preferences" || fail "fresh install uses the system font"
! compgen -G "$fresh_preferences.bak.*" >/dev/null || fail "fresh install needs no preferences backup"

pass "Sublime installer sets defaults on a fresh profile"

compact="$test_tmp/compact.sublime-settings"
printf '{"theme":"A \\"quoted\\" theme","font_size":14}\n' >"$compact"
python3 "$ROOT/default/sublime/set-preferences.py" "$compact" theme=Omarchy.sublime-theme
grep -q '"theme":"Omarchy.sublime-theme"' "$compact" || fail "compact settings keep the updated theme"
[[ $(grep -o '"theme"' "$compact" | wc -l) == 1 ]] || fail "compact settings do not duplicate the theme key"

pass "Sublime settings update compact JSON without duplicating keys"
