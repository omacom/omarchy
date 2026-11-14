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

# App icons are an icon set, drawn in the current theme's colors after the
# switch into a dir the links point at. The set is picked apart from the theme,
# which supplies colors and no icons. A user's set of the same name lies over
# the built-in one; a user's own icon stays; and a theme that can't draw them
# takes the icons and their links away again.
state="$home/.local/state/omarchy/current"
apps="$home/.local/share/icons/hicolor/scalable/apps"
sets="$home/.config/omarchy/icons"
mkdir -p "$state" "$apps"
mv "$next" "$state/theme"
mkdir -p "$state/theme/icons"
printf 'shipped\n' >"$state/theme/icons/hype.svg"
printf 'spoof\n' >"$state/theme/icons/firefox.svg"
printf 'mine\n' >"$apps/omacut.svg"
mkdir -p "$sets/papercraft"
printf '<svg>{{ icon_main }}</svg>\n' >"$sets/papercraft/plain.svg.tpl"
printf 'drawn\n' >"$sets/papercraft/gliff.svg"
ln -s "$test_tmp/gone/omacalc.svg" "$apps/omacalc.svg"
mkdir -p "$test_tmp/stubs"
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/stubs/omarchy-notification-send"
chmod +x "$test_tmp/stubs/omarchy-notification-send"
packaged="$test_tmp/packaged"
mkdir -p "$packaged"
icons() { HOME="$home" XDG_DATA_HOME="$home/.local/share" OMARCHY_PATH="$ROOT" OMARCHY_PACKAGED_ICONS_PATH="$packaged" PATH="$test_tmp/stubs:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-$1" "${@:2}"; }
set_icons() { icons theme-set-icons; }
set_icons
for tpl in "$ROOT"/icons/papercraft/*.tpl; do
  name=${tpl##*/}
  name=${name%.tpl}
  [[ -f $state/icons/$name ]] || fail "every app icon template renders ($name)"
  [[ $(<"$state/icons/$name") != *"{{"* ]] || fail "every app icon template resolves all its colors ($name)"
done
[[ $(<"$state/icons/hype.svg") != "shipped" && ! -e $apps/firefox.svg ]] || fail "a theme supplies the icons' colors and no icons of its own"
[[ $(<"$state/icons/plain.svg") == "<svg>#"* && -L $apps/plain.svg ]] || fail "a user's icon template lies over the built-in set's"
[[ $(<"$state/icons/gliff.svg") == "drawn" ]] || fail "a user's finished icon replaces the built-in set's template"
[[ $(readlink "$apps/omawrite.svg") == "$state/icons/omawrite.svg" ]] || fail "app icons link over the packaged ones"
[[ $(<"$apps/omacut.svg") == "mine" ]] || fail "app icons leave an icon the user put there"
[[ $(readlink "$apps/omacalc.svg") == "$state/icons/omacalc.svg" ]] || fail "app icons replace a dangling link at their name"
[[ -s $state/icons.revision ]] || fail "app icons tell the shell they changed"
pass "the icon set renders after the switch and links into the user's icon theme"

# A set of the user's own may draw any app, in the theme's colors or as it is,
# and draws only what it holds. Switching sets takes the last one's icons away.
mkdir -p "$sets/mine"
printf '<svg>{{ icon_mark }}</svg>\n' >"$sets/mine/firefox.svg.tpl"
printf 'fixed\n' >"$sets/mine/mpv.svg"
[[ $(icons icons-current) == "Papercraft" ]] || fail "the default icon set is in use until another is picked"
[[ $(icons icons-list) == $'Mine\nOriginal\nPapercraft' ]] || fail "icon sets list the built-in ones, the user's and Original"
icons icons-set Mine
[[ $(icons icons-current) == "Mine" && $(icons icons-current --id) == "mine" ]] || fail "an icon set is picked by the name it is listed under"
[[ $(<"$apps/firefox.svg") == "<svg>#"* && $(<"$apps/mpv.svg") == "fixed" ]] || fail "a user's icon set draws any app, themed or as it is"
[[ ! -e $state/icons/omawrite.svg && ! -L $apps/omawrite.svg ]] || fail "switching icon sets takes the last set's icons away"
[[ $(<"$apps/omacut.svg") == "mine" ]] || fail "switching icon sets leaves an icon the user put there"
pass "an icon set is picked apart from the theme and draws any app"

# A set cloned from a git repo holds whatever its author pushed, so its
# symlinks are left out; a set the user wrote themselves keeps its own.
printf 'elsewhere\n' >"$test_tmp/elsewhere.svg"
ln -s "$test_tmp/elsewhere.svg" "$sets/mine/imv.svg"
set_icons
[[ $(<"$apps/imv.svg") == "elsewhere" ]] || fail "a user's own icon set may link to its icons"
mkdir "$sets/mine/.git"
set_icons
[[ ! -e $apps/imv.svg && $(<"$apps/mpv.svg") == "fixed" ]] || fail "a cloned icon set's symlinks are left out"
rmdir "$sets/mine/.git"
pass "a cloned icon set contributes only its own icon files"

# Original is the set with nothing in it, so every app shows its own icon.
icons icons-set Original
[[ -z $(ls "$state/icons") && ! -e $apps/firefox.svg && ! -e $apps/mpv.svg ]] || fail "the Original icon set brings every app's own icon back"
[[ $(<"$apps/omacut.svg") == "mine" ]] || fail "the Original icon set leaves an icon the user put there"
! icons icons-set "No Such Set" >/dev/null 2>&1 || fail "an icon set that isn't there is refused"
! icons icons-set "../themes" >/dev/null 2>&1 || fail "an icon set name can't climb out of the sets dir"
[[ $(icons icons-current --id) == "original" ]] || fail "a refused icon set leaves the current one in use"
pass "the Original icon set shows every app's own icon"

# A package installs an icon set beside Omarchy's own. It is listed and picked
# like any other, the user's set of its name lies over it, and Omarchy's own
# tree is read ahead of a packaged copy of one of its sets. A directory named
# for Original never makes it draw.
mkdir -p "$packaged/neon" "$packaged/papercraft" "$packaged/original" "$sets/original"
printf '<svg>{{ icon_main }}</svg>\n' >"$packaged/neon/firefox.svg.tpl"
printf 'neon\n' >"$packaged/neon/mpv.svg"
printf 'stale\n' >"$packaged/papercraft/zzz.svg"
printf 'never\n' >"$packaged/original/mpv.svg"
printf 'never\n' >"$sets/original/mpv.svg"
[[ $(icons icons-list) == $'Mine\nNeon\nOriginal\nPapercraft' ]] || fail "icon sets list the ones packages installed"
[[ $(icons icons-dir neon) == "$packaged/neon" && $(icons icons-dir papercraft) == "$ROOT/icons/papercraft" ]] || fail "Omarchy's own icon sets are read ahead of packaged copies"
icons icons-set Neon
[[ $(<"$apps/firefox.svg") == "<svg>#"* && $(<"$apps/mpv.svg") == "neon" ]] || fail "a packaged icon set draws its icons in the theme's colors"
mkdir -p "$sets/neon"
printf 'my neon\n' >"$sets/neon/mpv.svg"
icons theme-set-icons
[[ $(<"$apps/mpv.svg") == "my neon" && $(<"$apps/firefox.svg") == "<svg>#"* ]] || fail "a user's icon set lies over the packaged one of its name"
icons icons-remove Neon >/dev/null
[[ $(icons icons-current --id) == "neon" && $(<"$apps/mpv.svg") == "neon" ]] || fail "removing the user's layer leaves the packaged icon set in use"
icons icons-set Original
[[ -z $(ls "$state/icons") && ! -e $apps/mpv.svg ]] || fail "a directory named for Original never makes it draw"
rm -r "$sets/original"
pass "a package installs an icon set that is listed, picked and layered like any other"

# Removing the set in use falls back to the default one.
icons icons-set Mine
icons icons-remove Mine >/dev/null
[[ ! -d $sets/mine && $(icons icons-current --id) == "papercraft" && -L $apps/omawrite.svg && ! -e $apps/firefox.svg ]] || fail "removing the icon set in use falls back to the default"
! icons icons-remove "../themes" >/dev/null 2>&1 || fail "removing an icon set can't climb out of the sets dir"
pass "removing the icon set in use falls back to the default"

printf 'accent = "nope"\nbackground = "#1a1b26"\nforeground = "#a9b1d6"\n' >"$state/theme/colors.toml"
set_icons
[[ ! -e $state/icons/omawrite.svg && ! -L $apps/omawrite.svg ]] || fail "a theme that can't draw app icons brings the packaged ones back"
[[ $(<"$state/icons/gliff.svg") == "drawn" ]] || fail "an icon that needs no colors stays under a theme that can't draw the rest"
pass "a theme that can't draw app icons brings the packaged ones back"
