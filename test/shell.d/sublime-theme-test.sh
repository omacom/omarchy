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
! grep -q '"font_face"' "$preferences" || fail "installer leaves the font to fontconfig"
grep -q '"font_size": 14' "$preferences" || fail "installer preserves unrelated preferences"
grep -q '// Keep the user' "$preferences" || fail "installer preserves settings comments"
[[ -f $user_package/Omarchy.sublime-theme && -f $user_package/OmarchyWindow.py ]] || fail "installer copies Sublime resources"
cmp -s "$source_scheme" "$user_package/Omarchy.sublime-color-scheme" || fail "installer copies the current scheme"
compgen -G "$preferences.bak.*" >/dev/null || fail "installer backs up existing preferences"

pass "Sublime installer keeps existing settings and applies Omarchy defaults"

printf '{"name":"second"}\n' >"$source_scheme"
HOME="$home" PATH="$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-sublime" || fail "Sublime theme sync succeeds"
cmp -s "$source_scheme" "$user_package/Omarchy.sublime-color-scheme" || fail "theme sync updates the scheme"
[[ ! -L $user_package/Omarchy.sublime-color-scheme ]] || fail "theme sync writes a real file"

pass "Sublime theme sync replaces the scheme without a symlink"

mkdir -p "$home/.local/state/omarchy/toggles"
touch "$home/.local/state/omarchy/toggles/skip-sublime-theme-changes"
printf '{"name":"skipped"}\n' >"$source_scheme"
HOME="$home" PATH="$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-sublime" || fail "skipped Sublime theme sync succeeds"
grep -q '"second"' "$user_package/Omarchy.sublime-color-scheme" || fail "skip-sublime-theme-changes keeps the current scheme"
rm "$home/.local/state/omarchy/toggles/skip-sublime-theme-changes"

pass "Sublime theme sync honors skip-sublime-theme-changes"

skip_home="$test_tmp/skip"
mkdir -p "$skip_home/.local/state/omarchy/toggles" "$skip_home/.local/state/omarchy/current/theme"
touch "$skip_home/.local/state/omarchy/toggles/skip-sublime-theme-changes"
printf '{"name":"skip"}\n' >"$skip_home/.local/state/omarchy/current/theme/Omarchy.sublime-color-scheme"
HOME="$skip_home" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-install-editor-sublime" || fail "Sublime installs with theme changes skipped"
[[ -f $skip_home/.config/sublime-text/Packages/User/Omarchy.sublime-color-scheme ]] ||
  fail "install with skip-sublime-theme-changes still provides the selected scheme"

pass "Sublime install provides its scheme even when theme changes are skipped"

fresh_home="$test_tmp/fresh"
mkdir -p "$fresh_home/.local/state/omarchy/current/theme"
printf '{"name":"fresh"}\n' >"$fresh_home/.local/state/omarchy/current/theme/Omarchy.sublime-color-scheme"

HOME="$fresh_home" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-install-editor-sublime" || fail "Sublime installs with no prior preferences"

fresh_preferences="$fresh_home/.config/sublime-text/Packages/User/Preferences.sublime-settings"
! grep -q '"font_face"' "$fresh_preferences" || fail "fresh install leaves the font to fontconfig"
! compgen -G "$fresh_preferences.bak.*" >/dev/null || fail "fresh install needs no preferences backup"

pass "Sublime installer sets defaults on a fresh profile"

compact="$test_tmp/compact.sublime-settings"
printf '{"theme":"A \\"quoted\\" theme","font_size":14}\n' >"$compact"
python3 "$ROOT/default/sublime/set-preferences.py" "$compact" theme=Omarchy.sublime-theme
grep -q '"theme":"Omarchy.sublime-theme"' "$compact" || fail "compact settings keep the updated theme"
[[ $(grep -o '"theme"' "$compact" | wc -l) == 1 ]] || fail "compact settings do not duplicate the theme key"

pass "Sublime settings update compact JSON without duplicating keys"

commented="$test_tmp/commented.sublime-settings"
cat >"$commented" <<'JSON'
{
  /* "theme": "Old" */
  // "color_scheme": "Old"
  "theme": "Active",
  "color_scheme": "Active",
}
JSON
python3 "$ROOT/default/sublime/set-preferences.py" "$commented" theme=Omarchy.sublime-theme color_scheme=Omarchy.sublime-color-scheme
grep -q '"theme": "Omarchy.sublime-theme"' "$commented" || fail "active theme is updated"
grep -q '"color_scheme": "Omarchy.sublime-color-scheme"' "$commented" || fail "active color scheme is updated"
grep -q '/\* "theme": "Old" \*/' "$commented" || fail "block comment is preserved"
grep -q '// "color_scheme": "Old"' "$commented" || fail "line comment is preserved"

pass "Sublime settings ignore commented values"

nested="$test_tmp/nested.sublime-settings"
printf '{"plugin_options":{"theme":"Nested"},"theme":"Root"}\n' >"$nested"
python3 "$ROOT/default/sublime/set-preferences.py" "$nested" theme=Omarchy.sublime-theme
[[ $(<"$nested") == '{"plugin_options":{"theme":"Nested"},"theme":"Omarchy.sublime-theme"}' ]] ||
  fail "only the root-level setting is updated" "$(<"$nested")"

pass "Sublime settings leave nested keys alone"

typed="$test_tmp/typed.sublime-settings"
printf '{\n  "theme": null,\n  "ignored_packages": ["Vintage", {"theme": 1}], /* } */\n}\n' >"$typed"
python3 "$ROOT/default/sublime/set-preferences.py" "$typed" theme=Omarchy.sublime-theme color_scheme=Omarchy.sublime-color-scheme
grep -q '^  "theme": "Omarchy.sublime-theme",$' "$typed" || fail "a non-string root value is replaced"
grep -q '^  "color_scheme": "Omarchy.sublime-color-scheme",$' "$typed" || fail "a missing key is inserted with the file's indent"
grep -Fq '"ignored_packages": ["Vintage", {"theme": 1}], /* } */' "$typed" || fail "other values and comments are untouched"

pass "Sublime settings replace any value type and insert missing keys"

empty="$test_tmp/empty.sublime-settings"
printf '{}' >"$empty"
python3 "$ROOT/default/sublime/set-preferences.py" "$empty" theme=Omarchy.sublime-theme
grep -q '"theme": "Omarchy.sublime-theme"' "$empty" || fail "an empty settings object receives the setting"

broken="$test_tmp/broken.sublime-settings"
printf '{"theme": "unterminated\n' >"$broken"
if python3 "$ROOT/default/sublime/set-preferences.py" "$broken" theme=Omarchy.sublime-theme 2>/dev/null; then
  fail "malformed settings are reported"
fi
[[ $(<"$broken") == '{"theme": "unterminated' ]] || fail "malformed settings are left unchanged"

pass "Sublime settings handle empty and malformed files"

python3 - "$ROOT/default/sublime/OmarchyWindow.py" <<'PY' || fail "Sublime window defaults apply once"
import runpy
import sys
import types

windows = []
state = {}
saved = []
sublime = types.ModuleType('sublime')
sublime.windows = lambda: windows
sublime.load_settings = lambda _: types.SimpleNamespace(get=state.get, set=state.__setitem__)
sublime.save_settings = saved.append
plugin = types.ModuleType('sublime_plugin')
plugin.EventListener = object
sys.modules['sublime'] = sublime
sys.modules['sublime_plugin'] = plugin
module = runpy.run_path(sys.argv[1])
listener = module['OmarchyWindowDefaults']()


class Window:
    def __init__(self):
        self.menu = True
        self.minimap = True

    def set_menu_visible(self, value):
        self.menu = value

    def set_minimap_visible(self, value):
        self.minimap = value


module['plugin_loaded']()
assert not saved

first = Window()
windows.append(first)
listener.on_new_window(first)
assert not first.menu and not first.minimap
assert saved == ['Omarchy.sublime-settings']

first.menu = first.minimap = True
second = Window()
windows.append(second)
listener.on_new_window(second)
module['plugin_loaded']()
assert first.menu and first.minimap and second.menu and second.minimap
assert len(saved) == 1
PY

pass "Sublime hides the menu and minimap once and then keeps the user's choices"
