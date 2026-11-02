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

# Publishing a generated palette must retain settings and refresh a real file
# in Vencord's watched directory, rather than leave a stale symlink target.
vesktop_home="$test_tmp/vesktop-home"
vesktop_config="$test_tmp/vesktop-config"
mkdir -p "$vesktop_home/.local/state/omarchy/current/theme" "$vesktop_config/vesktop"
printf '{"enabledThemes":["mine.css"],"other":true}\n' > "$vesktop_config/vesktop/settings.json"
cp "$vesktop_config/vesktop/settings.json" "$test_tmp/vesktop-settings.before"
vesktop_source="$vesktop_home/.local/state/omarchy/current/theme/vesktop.theme.css"
vesktop_target="$vesktop_config/vesktop/themes/omarchy.theme.css"
printf ':root { --brand-500: #ffffff; --text: __OMARCHY_ON_ACCENT__; }\n' > "$vesktop_source"
HOME="$vesktop_home" XDG_CONFIG_HOME="$vesktop_config" "$ROOT/bin/omarchy-theme-set-vesktop"
[[ -f $vesktop_target && ! -L $vesktop_target ]] || fail "Vesktop gets a watched theme file"
grep -q -- '--text: #000000' "$vesktop_target" || fail "light accents get dark button text"
cmp "$test_tmp/vesktop-settings.before" "$vesktop_config/vesktop/settings.json" || fail "Vesktop settings are preserved"
vesktop_inode=$(stat -c %i "$vesktop_target")
HOME="$vesktop_home" XDG_CONFIG_HOME="$vesktop_config" "$ROOT/bin/omarchy-theme-set-vesktop"
[[ $(stat -c %i "$vesktop_target") == "$vesktop_inode" ]] || fail "unchanged palettes are not rewritten"
printf ':root { --brand-500: #000000; --text: __OMARCHY_ON_ACCENT__; }\n' > "$vesktop_source"
HOME="$vesktop_home" XDG_CONFIG_HOME="$vesktop_config" "$ROOT/bin/omarchy-theme-set-vesktop"
grep -q -- '--text: #ffffff' "$vesktop_target" || fail "dark accents get light button text"
cp "$vesktop_target" "$test_tmp/vesktop-theme.before"
printf '{{ accent }}\n' > "$vesktop_source"
if HOME="$vesktop_home" XDG_CONFIG_HOME="$vesktop_config" "$ROOT/bin/omarchy-theme-set-vesktop" >/dev/null 2>&1; then
  fail "unresolved palettes are rejected"
fi
cmp "$test_tmp/vesktop-theme.before" "$vesktop_target" || fail "invalid palettes preserve the last theme"
[[ ! -d $vesktop_config/Vesktop ]] || fail "absent Vesktop installations are left alone"
mkdir -p "$vesktop_config/Vesktop" "$vesktop_home/.var/app/dev.vencord.Vesktop/config/vesktop"
cp "$test_tmp/vesktop-theme.before" "$vesktop_source"
HOME="$vesktop_home" XDG_CONFIG_HOME="$vesktop_config" "$ROOT/bin/omarchy-theme-set-vesktop"
cmp "$vesktop_target" "$vesktop_config/Vesktop/themes/omarchy.theme.css" || fail "alternate native data directory receives the palette"
cmp "$vesktop_target" "$vesktop_home/.var/app/dev.vencord.Vesktop/config/vesktop/themes/omarchy.theme.css" || fail "Flatpak data directory receives the palette"
pass "Vesktop theme refresh preserves settings, skips unchanged content, and keeps readable button text"

# Theme-provided CSS need not use Omarchy's contrast placeholder or hex accents.
for custom_css in ':root { --brand-500: rgb(10, 20, 30); }' ':root { --brand-500: var(--custom-accent); }' ':root { --background-primary: #123456; }'; do
  printf '%s\n' "$custom_css" > "$vesktop_source"
  HOME="$vesktop_home" XDG_CONFIG_HOME="$vesktop_config" "$ROOT/bin/omarchy-theme-set-vesktop"
  cmp "$vesktop_source" "$vesktop_target" || fail "custom Vesktop CSS is published unchanged"
done
pass "custom Vesktop CSS does not require a hex accent without the contrast placeholder"
