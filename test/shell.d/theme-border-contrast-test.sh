#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Render each built-in theme's Hyprland borders the way a theme switch does: a
# shipped hyprland.lua wins, otherwise the template fills it from colors.toml.
# Without either, Hyprland keeps the inactive border from looknfeel.lua.
borders="$test_tmp/borders"
: >"$borders"
for theme_dir in "$ROOT"/themes/*/; do
  theme=$(basename "$theme_dir")
  home="$test_tmp/$theme"
  next="$home/.local/state/omarchy/current/next-theme"
  mkdir -p "$next"
  cp "$theme_dir/colors.toml" "$next/"
  [[ -f $theme_dir/hyprland.lua ]] && cp "$theme_dir/hyprland.lua" "$next/"

  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-set-templates"

  active=$(sed -n 's/^local active_border_color = //p' "$next/hyprland.lua")
  inactive=$(sed -n 's/^local inactive_border_color = //p' "$next/hyprland.lua")
  [[ -n $inactive ]] || inactive=$(sed -n 's/^local inactive_border_color = //p' "$ROOT/default/hypr/looknfeel.lua")
  printf '%s\037%s\037%s\n' "$theme" "$active" "$inactive" >>"$borders"
done

# Below 2:1, the focused window's border is hard to tell from the others; every
# dark theme already clears it against the default inactive grey.
failures=$(python3 - "$borders" "$ROOT/themes" <<'PY'
import re, sys, tomllib

MIN_RATIO = 2.0
STOP = re.compile(r'#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?|rgba?\(([0-9a-fA-F]{6})([0-9a-fA-F]{2})?\)|0x([0-9a-fA-F]{2})([0-9a-fA-F]{6})')

def stops(spec, background):
    colors = []
    for m in STOP.finditer(spec):
        if m.group(1):
            rgb, alpha = m.group(1), m.group(2)
        elif m.group(3):
            rgb, alpha = m.group(3), m.group(4)
        else:
            rgb, alpha = m.group(6), m.group(5)
        a = int(alpha, 16) / 255 if alpha else 1
        colors.append(tuple(int(rgb[i:i + 2], 16) * a + background[i // 2] * (1 - a) for i in (0, 2, 4)))
    return colors

def luminance(rgb):
    c = [x / 255 for x in rgb]
    c = [x / 12.92 if x <= 0.03928 else ((x + 0.055) / 1.055) ** 2.4 for x in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]

def ratio(a, b):
    a, b = luminance(a), luminance(b)
    return (max(a, b) + 0.05) / (min(a, b) + 0.05)

for line in open(sys.argv[1]):
    theme, active, inactive = line.rstrip('\n').split('\x1f')
    with open(f'{sys.argv[2]}/{theme}/colors.toml', 'rb') as f:
        bg = tomllib.load(f)['background'].lstrip('#')
    background = tuple(int(bg[i:i + 2], 16) for i in (0, 2, 4))
    a, i = stops(active, background), stops(inactive, background)
    if not a or not i:
        print(f'{theme}: unreadable border colors ({active} / {inactive})')
        continue
    worst = min(ratio(x, y) for x in a for y in i)
    if worst < MIN_RATIO:
        print(f'{theme}: {worst:.2f}:1 between {active} and {inactive}')
PY
)

[[ -z $failures ]] || fail "every theme's active border stands out from its inactive border" "$failures"
pass "every theme's active border stands out from its inactive border"
