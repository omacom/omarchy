#!/bin/bash

set -euo pipefail

# The WezTerm template is Lua that WezTerm runs, so it is rendered here the way
# a theme switch renders it and then loaded by a Lua interpreter, which catches
# a placeholder the palette does not resolve or a value that broke the table.
# The terminal restart is run against a WezTerm config too: WezTerm has no
# reload signal and watches its config file instead.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
next_theme="$test_home/.local/state/omarchy/current/next-theme"
mkdir -p "$next_theme"
cp "$ROOT/themes/tokyo-night/colors.toml" "$next_theme/colors.toml"

HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-set-templates"

rendered="$next_theme/wezterm.lua"
[[ -f $rendered ]] || fail "a theme switch renders wezterm.lua from the template"
! grep -q '{{' "$rendered" || fail "every placeholder in the WezTerm template resolves" "$(grep '{{' "$rendered")"
pass "the WezTerm template renders without unresolved placeholders"

lua - "$rendered" <<'LUA' || fail "the rendered wezterm.lua is a color table WezTerm can load"
local colors = dofile(arg[1])
assert(type(colors) == "table", "the file returns a table")
local hex = "^#%x%x%x%x%x%x$"
for _, key in ipairs({ "foreground", "background", "cursor_bg", "cursor_fg", "cursor_border", "selection_fg", "selection_bg" }) do
  assert(type(colors[key]) == "string" and colors[key]:match(hex), key .. " is a hex color: " .. tostring(colors[key]))
end
for _, list in ipairs({ "ansi", "brights" }) do
  assert(#colors[list] == 8, list .. " has eight colors")
  for i, value in ipairs(colors[list]) do
    assert(value:match(hex), list .. "[" .. i .. "] is a hex color: " .. tostring(value))
  end
end
for _, tab in ipairs({ "active_tab", "inactive_tab", "inactive_tab_hover", "new_tab", "new_tab_hover" }) do
  assert(colors.tab_bar[tab].bg_color:match(hex) and colors.tab_bar[tab].fg_color:match(hex), tab .. " is themed")
end
assert(colors.background == "#1a1b26", "the background follows the palette")
assert(colors.tab_bar.active_tab.bg_color == "#7aa2f7", "the active tab takes the accent")
assert(colors.tab_bar.inactive_tab_hover.bg_color ~= colors.tab_bar.inactive_tab.bg_color, "a hovered tab stands out from a resting one")
LUA
pass "the rendered wezterm.lua loads as a themed color table"

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/killall" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

wezterm_config="$test_home/.config/wezterm/wezterm.lua"
mkdir -p "$(dirname "$wezterm_config")"
: >"$wezterm_config"
touch -d '2000-01-01 00:00:00' "$wezterm_config"
HOME="$test_home" PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-restart-terminal"
(( $(stat -c %Y "$wezterm_config") > 946684800 )) || fail "a theme switch touches the WezTerm config so WezTerm reloads it"
pass "restarting terminals touches the WezTerm config"

rm -rf "$test_home/.config/wezterm"
HOME="$test_home" PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-restart-terminal" || fail "restarting terminals is fine without a WezTerm config"
[[ ! -e $test_home/.config/wezterm ]] || fail "restarting terminals does not create a WezTerm config"
pass "restarting terminals leaves a machine without WezTerm alone"
