#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
next="$home/.local/state/omarchy/current/next-theme"
themed="$home/.config/omarchy/themed"
mkdir -p "$next" "$themed"

cat >"$next/colors.toml" <<'EOF'
accent = "#ff0000"
foreground = "#e0e0e0"
background = "#000000"
red = "#ff0000"
blue = "#0000ff"
hyprland_active_border = "0xffa8b0c0 rgb(10,20,300,0.5) accent -12.5deg"
EOF

cat >"$themed/probe.txt.tpl" <<'EOF'
plain={{ accent }} {{ accent_strip }} {{ accent_rgb }}
round={{ mix background accent 30% }} {{ mix background accent 0.3 }} {{ mix background accent 12.5% }} {{ mix background accent 150 }}
variants={{ mix_strip background accent 30% }} {{ mix_rgb red blue 50% }}
spacing={{  mix   background   accent   30%  }} {{accent}}
untouched={{ mix nope accent 30% }} {{ mix background accent }} {{ unknown_key }} {{{ accent }}}
hypr={{ hypr_gradient hyprland_active_border accent }} {{ hypr_gradient missing_border rgba(00000000) }} {{ hypr_gradient missing_border }}
start={{ gradient_start hyprland_active_border accent }} {{ gradient_start missing_border 0xff112233 }}
shell={{ shell_gradient hyprland_active_border accent }}
EOF

# A user template shadows the built-in of the same name, a file the theme ships
# is never overwritten, and an empty template still leaves its file behind.
printf 'user {{ accent }}\n' >"$themed/kitty.conf.tpl"
printf 'shipped\n' >"$next/foot.ini"
: >"$themed/empty.txt.tpl"
printf 'no newline {{ accent }}' >"$themed/tail.txt.tpl"
# Function arguments may be separated by any whitespace, tabs included.
printf '{{ mix\tbackground accent 30%% }} {{\tmix_rgb red\tblue 50%%\t}} {{ gradient_start\thyprland_active_border accent }}\n' >"$themed/tabs.txt.tpl"

HOME="$home" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-set-templates"

# Expected values were produced by the sed-based renderer this replaced, so
# every theme keeps rendering byte for byte the same.
expected=$(cat <<'EOF'
plain=#ff0000 ff0000 255,0,0
round=#4d0000 #4d0000 #200000 #ff0000
variants=4d0000 128,0,128
spacing=#4d0000 {{accent}}
untouched={{ mix nope accent 30% }} {{ mix background accent }} {{ unknown_key }} {#ff0000}
hypr={ colors = { "0xffa8b0c0", "rgb(10,20,300,0.5)", "#ff0000" }, angle = -12.5 } "rgba(00000000)" "missing_border"
start=#a8b0c0 #112233
shell=0xffa8b0c0 rgb(10,20,300,0.5) #ff0000 -12.5deg
EOF
)

[[ $(<"$next/probe.txt") == "$expected" ]] ||
  fail "theme templates render values, mixes and gradients as before: $(diff <(printf '%s\n' "$expected") "$next/probe.txt")"
pass "theme templates render values, mixes and gradients as before"

[[ $(<"$next/tabs.txt") == "#4d0000 128,0,128 #a8b0c0" ]] || fail "theme templates resolve function tokens separated by tabs"
pass "theme templates resolve function tokens separated by tabs"

[[ $(<"$next/kitty.conf") == "user #ff0000" ]] || fail "a user template shadows the built-in of the same name"
[[ $(<"$next/foot.ini") == "shipped" ]] || fail "a file the theme ships is not overwritten"
[[ -f $next/empty.txt && ! -s $next/empty.txt ]] || fail "an empty template still produces its file"
[[ $(od -An -c "$next/tail.txt" | tr -d ' \n') == *"#ff0000" ]] || fail "a template without a final newline renders without one"
pass "theme templates keep user, theme and file-ending precedence"

for tpl in "$ROOT"/default/themed/*.tpl; do
  name=${tpl##*/}
  name=${name%.tpl}
  [[ -f $next/$name ]] || fail "every built-in template renders ($name)"
done
pass "theme templates render every built-in template"

[[ ! -e $next/icons ]] || fail "theme templates leave app icons to the retints after the switch"
pass "theme templates leave app icons to the retints after the switch"

icon_role() {
  local colors="$1" role="$2"
  { "$ROOT/bin/omarchy-theme-color" --file "$colors" --all; "$ROOT/bin/omarchy-theme-color" --file "$colors" --raw | sed 's/^/raw_/'; } | "$ROOT/bin/omarchy-theme-icon-palette" | awk -F '\t' -v role="$role" '$1 == role { print $2 }'
}

# Magenta is Tokyo Night's violet but Gruvbox's pink, which the icons pass over
# for its amber; Kanagawa's accent is its foreground, so its blue stands in.
[[ $(icon_role "$ROOT/themes/tokyo-night/colors.toml" icon_mark) == "#bb9af7" ]] || fail "app icons take a theme's violet for their highlight"
[[ $(icon_role "$ROOT/themes/gruvbox/colors.toml" icon_mark) == "#d8a657" ]] || fail "app icons skip a pink magenta for the theme's amber"
[[ $(icon_role "$ROOT/themes/kanagawa/colors.toml" icon_main) == "#7e9cd8" ]] || fail "app icons replace an accent that matches the paper with blue"
[[ $(icon_role "$ROOT/themes/rose-pine/colors.toml" icon_paper) == "#faf4ed" ]] || fail "app icons draw paper from a light theme's background"
pass "app icon colors fit each theme's palette"

printf 'accent = "#7aa2f7"\nbackground = "#1a1b26"\nforeground = "#a9b1d6"\nicon_mark = "#123456"\nred = "rgba(247,118,142,1)"\n' >"$test_tmp/chosen.toml"
[[ $(icon_role "$test_tmp/chosen.toml" icon_mark) == "#123456" ]] || fail "a theme chooses its own app icon color"
[[ $(icon_role "$test_tmp/chosen.toml" icon_red) == "#f7768e" ]] || fail "app icons read a color written as rgba()"
printf 'accent = "0xff7aa2f7"\nbackground = "#1a1b26"\nforeground = "#a9b1d6"\n' >"$test_tmp/argb.toml"
[[ $(icon_role "$test_tmp/argb.toml" icon_main) == "#7aa2f7" ]] || fail "app icons read a color written as 0xAARRGGBB"
printf 'accent = "nope"\nbackground = "#1a1b26"\nforeground = "#a9b1d6"\n' >"$test_tmp/unreadable.toml"
[[ -z $("$ROOT/bin/omarchy-theme-color" --file "$test_tmp/unreadable.toml" --all | "$ROOT/bin/omarchy-theme-icon-palette") ]] || fail "app icons are skipped when the accent can't be read as a color"

# A theme that sets only its accent, background and foreground still gets
# paper, text and a highlight that stand apart.
printf 'accent = "#e06c75"\nbackground = "#1e2127"\nforeground = "#abb2bf"\n' >"$test_tmp/bare.toml"
[[ $(icon_role "$test_tmp/bare.toml" icon_ink) != "$(icon_role "$test_tmp/bare.toml" icon_paper)" ]] || fail "a bare theme's app icons get text that shows on their paper"
[[ $(icon_role "$test_tmp/bare.toml" icon_mark) != "#abb2bf" ]] || fail "a bare theme's app icons get a highlight with a hue"
[[ $(icon_role "$test_tmp/bare.toml" icon_red) != "#abb2bf" ]] || fail "a bare theme's app icons get a red"
printf 'accent = "#e06c75"\nbackground = "#1e2127"\nforeground = "#abb2bf"\nred = "#abb2bf"\n' >"$test_tmp/grey.toml"
[[ $(icon_role "$test_tmp/grey.toml" icon_red) == "#abb2bf" ]] || fail "a theme that names its red grey keeps it"
printf 'accent = "#e06c75"\ncolor0 = "#1e2127"\ncolor7 = "#abb2bf"\n' >"$test_tmp/ansi.toml"
[[ $(icon_role "$test_tmp/ansi.toml" icon_mark) == "$(icon_role "$test_tmp/bare.toml" icon_mark)" ]] || fail "a theme naming only its neutral ANSI slots gets the same highlight as a bare one"
pass "app icon colors honor the theme and skip palettes they cannot draw"

# App icons draw from the current theme after the switch, into a dir the links
# point at. A theme's own icon wins; a user's own icon stays; a theme's icon for
# an app Omarchy has no template for is not linked; and a theme that can't draw
# them takes the icons and their links away again.
state="$home/.local/state/omarchy/current"
apps="$home/.local/share/icons/hicolor/scalable/apps"
mkdir -p "$state" "$apps"
mv "$next" "$state/theme"
mkdir -p "$state/theme/icons"
printf 'shipped\n' >"$state/theme/icons/hype.svg"
printf 'spoof\n' >"$state/theme/icons/firefox.svg"
printf 'mine\n' >"$apps/omacut.svg"
mkdir -p "$home/.config/omarchy/themed/icons"
printf '<svg>{{ icon_main }}</svg>\n' >"$home/.config/omarchy/themed/icons/plain.svg.tpl"
ln -s "$test_tmp/gone/omacalc.svg" "$apps/omacalc.svg"
set_icons() { HOME="$home" XDG_DATA_HOME="$home/.local/share" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-set-icons"; }
set_icons
for tpl in "$ROOT"/default/themed/icons/*.tpl; do
  name=${tpl##*/}
  name=${name%.tpl}
  [[ -f $state/icons/$name ]] || fail "every app icon template renders ($name)"
  [[ $(<"$state/icons/$name") != *"{{"* ]] || fail "every app icon template resolves all its colors ($name)"
done
[[ $(<"$state/icons/hype.svg") == "shipped" ]] || fail "a theme's own app icon wins over the template"
[[ $(<"$state/icons/plain.svg") == "<svg>#"* && -L $apps/plain.svg ]] || fail "a user's icon template shadows the built-in and stays published"
[[ $(readlink "$apps/omawrite.svg") == "$state/icons/omawrite.svg" ]] || fail "app icons link over the packaged ones"
[[ $(<"$apps/omacut.svg") == "mine" ]] || fail "app icons leave an icon the user put there"
[[ $(readlink "$apps/omacalc.svg") == "$state/icons/omacalc.svg" ]] || fail "app icons replace a dangling link at their name"
[[ ! -e $apps/firefox.svg ]] || fail "app icons link only Omarchy's own icons"
[[ -s $state/icons.revision ]] || fail "app icons tell the shell they changed"
pass "app icons render after the switch and link into the user's icon theme"

printf 'accent = "nope"\nbackground = "#1a1b26"\nforeground = "#a9b1d6"\n' >"$state/theme/colors.toml"
set_icons
[[ ! -e $state/icons/omawrite.svg && ! -L $apps/omawrite.svg ]] || fail "a theme that can't draw app icons brings the packaged ones back"
pass "a theme that can't draw app icons brings the packaged ones back"
