#!/bin/bash

set -euo pipefail

# Every generated theme file comes from the palette, and foot's include of the
# generated foot.ini is not optional. A theme with no palette therefore has to
# be refused at staging rather than swapped in, or the default terminal stops
# starting and there is no terminal left to set a working theme from.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
state="$home/.local/state/omarchy/current"
themes="$home/.config/omarchy/themes"
mkdir -p "$state" "$themes"

set_theme() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
    XDG_RUNTIME_DIR="$test_tmp" \
    bash "$ROOT/bin/omarchy-theme-set" "$1" >"$test_tmp/stdout" 2>"$test_tmp/stderr"
}

write_colors() {
  cat >"$themes/$1/colors.toml" <<'TOML'
background = "#1a1b26"
foreground = "#c0caf5"
accent = "#7aa2f7"
TOML
}

# A theme carrying a palette applies, and the terminal config the palette is
# there to generate lands with it.
mkdir -p "$themes/with-palette"
write_colors with-palette
set_theme with-palette || fail "a theme with colors.toml applies" "$(cat "$test_tmp/stderr")"
[[ -f $state/theme/colors.toml ]] || fail "the applied theme keeps its palette"
[[ -f $state/theme/foot.ini ]] || fail "the applied theme generates foot.ini"
pass "a theme with a palette applies and generates its terminal config"

# Now the case from the report: a theme directory carrying neither colors.toml
# nor an alacritty.toml to derive one from.
applied_before=$(cat "$state/theme.name")
mkdir -p "$themes/no-palette"
printf '%s\n' 'general { col.active_border = rgb(ffffff) }' >"$themes/no-palette/hyprland.conf"

if set_theme no-palette; then
  fail "a theme with no palette is refused" "$(cat "$test_tmp/stdout" "$test_tmp/stderr")"
fi
grep -Fq 'colors.toml' "$test_tmp/stderr" || fail "the refusal names colors.toml" "$(cat "$test_tmp/stderr")"
pass "a theme with no palette is refused instead of applied"

# The refusal has to be inert: the theme that was working stays working, and no
# staging directory is left behind to be picked up as a half-applied theme.
[[ $(cat "$state/theme.name") == "$applied_before" ]] ||
  fail "a refused theme leaves the applied theme alone"
[[ -f $state/theme/foot.ini ]] || fail "a refused theme leaves the generated terminal config in place"
[[ ! -e $state/next-theme ]] || fail "a refused theme leaves no staging directory behind"
pass "a refused theme changes nothing that was already applied"
