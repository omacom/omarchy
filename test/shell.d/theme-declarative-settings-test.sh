#!/bin/bash

set -euo pipefail

# shellcheck source=test/shell.d/base-test.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
next_theme="$home/.local/state/omarchy/current/next-theme"
mkdir -p "$next_theme"

write_colors() {
  cat >"$next_theme/colors.toml" <<'TOML'
mode = "dark"
terminal_opacity = 0.78
terminal_blur = true
terminal_blur_radius = 32
accent = "#7aa2f7"
selection = "#292e42"
muted = "#414868"
background = "#1a1b26"
foreground = "#a9b1d6"
color0 = "#1a1b26"
color1 = "#f7768e"
color2 = "#9ece6a"
color3 = "#e0af68"
color4 = "#7aa2f7"
color5 = "#bb9af7"
color6 = "#7dcfff"
color7 = "#a9b1d6"
TOML
}

render() {
  HOME="$home" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-theme-set-templates" 2>"$test_tmp/stderr"
}

reset_theme() {
  rm -rf "$next_theme"
  mkdir -p "$next_theme"
  write_colors
  : >"$test_tmp/stderr"
}

reset_theme
render
grep -qx 'opacity = 0.78' "$next_theme/alacritty.toml" || fail "Alacritty uses terminal opacity"
grep -qx 'blur = true' "$next_theme/alacritty.toml" || fail "Alacritty enables terminal blur"
grep -qx 'alpha=0.78' "$next_theme/foot.ini" || fail "Foot uses terminal opacity"
grep -qx 'blur=yes' "$next_theme/foot.ini" || fail "Foot enables terminal blur"
grep -qx 'background-opacity = 0.78' "$next_theme/ghostty.conf" || fail "Ghostty uses terminal opacity"
grep -qx 'background-blur = 32' "$next_theme/ghostty.conf" || fail "Ghostty uses terminal blur radius"
grep -qx 'background_opacity 0.78' "$next_theme/kitty.conf" || fail "Kitty uses terminal opacity"
grep -qx 'background_blur 32' "$next_theme/kitty.conf" || fail "Kitty uses terminal blur radius"
pass "terminal appearance settings reach every generated terminal config"

reset_theme
sed -i '/^terminal_/d' "$next_theme/colors.toml"
render
! grep -q '^opacity =' "$next_theme/alacritty.toml" || fail "Alacritty leaves undeclared opacity alone"
! grep -q '^blur =' "$next_theme/alacritty.toml" || fail "Alacritty leaves undeclared blur alone"
! grep -q '^alpha=' "$next_theme/foot.ini" || fail "Foot leaves undeclared opacity alone"
grep -qx 'blur=yes' "$next_theme/foot.ini" || fail "Foot retains its launch-ready blur default"
(( $(grep -c '^blur=' "$next_theme/foot.ini") == 1 )) || fail "Foot has exactly one blur setting"
! grep -q '^background-opacity' "$next_theme/ghostty.conf" || fail "Ghostty leaves an undeclared opacity to the user's config"
! grep -q '^background-blur' "$next_theme/ghostty.conf" || fail "Ghostty leaves an undeclared blur to the user's config"
! grep -q '^background_opacity' "$next_theme/kitty.conf" || fail "Kitty leaves undeclared opacity alone"
! grep -q '^background_blur' "$next_theme/kitty.conf" || fail "Kitty leaves undeclared blur alone"
pass "omitted terminal settings preserve upstream defaults without duplicate Foot blur"

blur_defaults="$test_tmp/blur-defaults.toml"
printf 'terminal_blur = true\n' >"$blur_defaults"
blur_values=$(PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-color" --file "$blur_defaults" --all)
grep -qx $'terminal_blur_radius\t20' <<<"$blur_values" || fail "enabled blur defaults to radius 20"
grep -qx $'terminal_blur_ghostty\tbackground-blur = 20' <<<"$blur_values" || fail "Ghostty receives the default blur radius"
grep -q $'^terminal_opacity_ghostty\t#' <<<"$blur_values" || fail "Ghostty leaves an undeclared opacity alone beside a declared blur"
pass "enabled terminal blur defaults to radius 20"

reset_theme
sed -i 's/^terminal_opacity = .*/terminal_opacity = 1.0/; s/^terminal_blur = .*/terminal_blur = false/' "$next_theme/colors.toml"
render
grep -qx 'background-opacity = 1.0' "$next_theme/ghostty.conf" || fail "Ghostty applies a declared opaque background"
grep -qx 'background-blur = false' "$next_theme/ghostty.conf" || fail "Ghostty applies a declared blur off"
pass "Ghostty applies terminal settings the theme declares, even at their defaults"

commented_colors="$test_tmp/commented-colors.toml"
cat >"$commented_colors" <<'TOML'
terminal_opacity = 0.72 # user's "tuned" translucency
terminal_blur = true # user's "compositor" blur
terminal_blur_radius = 28 # user's "balanced" intensity
TOML
commented_values=$(PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-color" --file "$commented_colors" --all)
grep -qx $'terminal_opacity\t0.72' <<<"$commented_values" || fail "commented opacity resolves"
grep -qx $'terminal_blur\ttrue' <<<"$commented_values" || fail "commented blur resolves"
grep -qx $'terminal_blur_radius\t28' <<<"$commented_values" || fail "commented blur radius resolves"
pass "terminal settings accept TOML inline comments"

invalid_colors="$test_tmp/invalid-colors.toml"
cat >"$invalid_colors" <<'TOML'
terminal_opacity = "1.5"
terminal_blur = "sometimes"
terminal_blur_radius = "1000"
TOML
terminal_values=$(PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-color" --file "$invalid_colors" --all 2>"$test_tmp/invalid-stderr")
grep -qx $'terminal_opacity\t1.0' <<<"$terminal_values" || fail "invalid opacity falls back"
grep -qx $'terminal_blur\tfalse' <<<"$terminal_values" || fail "invalid blur falls back"
grep -qx $'terminal_blur_radius\t0' <<<"$terminal_values" || fail "disabled invalid radius emits zero"
grep -q 'invalid terminal_opacity' "$test_tmp/invalid-stderr" || fail "invalid opacity warns"
grep -q 'invalid terminal_blur ' "$test_tmp/invalid-stderr" || fail "invalid blur warns"
grep -q 'invalid terminal_blur_radius' "$test_tmp/invalid-stderr" || fail "invalid radius warns"
pass "invalid terminal settings warn and fall back"

# Exercise real template generation followed by the real Glassy postprocessor,
# not just scalar resolution. Each configuration must survive leaving Glassy.
toggles="$home/.local/state/omarchy/toggles/hypr"
mkdir -p "$toggles"

assert_opacity() {
  local opacity="$1" label="$2"
  grep -qx "opacity = $opacity" "$next_theme/alacritty.toml" || fail "$label Alacritty opacity"
  grep -qx "alpha=$opacity" "$next_theme/foot.ini" || fail "$label Foot opacity"
  grep -qx "background-opacity = $opacity" "$next_theme/ghostty.conf" || fail "$label Ghostty opacity"
  grep -qx "background_opacity $opacity" "$next_theme/kitty.conf" || fail "$label Kitty opacity"
  local file pattern
  for file in alacritty.toml foot.ini ghostty.conf kitty.conf; do
    case "$file" in
      alacritty.toml) pattern='^opacity =' ;;
      foot.ini) pattern='^alpha=' ;;
      ghostty.conf) pattern='^background-opacity =' ;;
      kitty.conf) pattern='^background_opacity ' ;;
    esac
    (( $(grep -c "$pattern" "$next_theme/$file") == 1 )) || fail "$label $file has one opacity setting"
  done
}

for declaration in omitted invalid empty radius-only translucent opaque blurred; do
  reset_theme
  sed -i '/^terminal_/d' "$next_theme/colors.toml"
  case "$declaration" in
    invalid) cat "$invalid_colors" >>"$next_theme/colors.toml" ;;
    empty) printf 'terminal_opacity = ""\nterminal_blur = ""\n' >>"$next_theme/colors.toml" ;;
    radius-only) printf 'terminal_blur_radius = 32\n' >>"$next_theme/colors.toml" ;;
    translucent) printf 'terminal_opacity = 0.45\nterminal_blur = false\n' >>"$next_theme/colors.toml" ;;
    opaque) printf 'terminal_opacity = 1.0\nterminal_blur = false\n' >>"$next_theme/colors.toml" ;;
    blurred) printf 'terminal_opacity = 0.45\nterminal_blur = true\nterminal_blur_radius = 32\n' >>"$next_theme/colors.toml" ;;
  esac
  render
  if [[ $declaration == "invalid" || $declaration == "empty" ]]; then
    grep -q 'invalid terminal_opacity' "$test_tmp/stderr" || fail "$declaration opacity warns during render"
    grep -q 'invalid terminal_blur ' "$test_tmp/stderr" || fail "$declaration blur warns during render"
  fi
  before="$test_tmp/before-$declaration"
  mkdir -p "$before"
  for file in alacritty.toml foot.ini ghostty.conf kitty.conf; do
    cp "$next_theme/$file" "$before/$file"
  done
  touch "$toggles/window-glassy.lua"
  render
  case "$declaration" in
    translucent | blurred) expected_opacity=0.45 ;;
    opaque) expected_opacity=1.0 ;;
    *) expected_opacity=0.65 ;;
  esac
  assert_opacity "$expected_opacity" "$declaration"
  if [[ $declaration == "translucent" || $declaration == "opaque" ]]; then
    grep -qx 'blur = false' "$next_theme/alacritty.toml" || fail "declared Alacritty blur stays off"
    grep -qx 'blur=no' "$next_theme/foot.ini" || fail "declared Foot blur stays off"
    grep -qx 'background-blur = false' "$next_theme/ghostty.conf" || fail "declared Ghostty blur stays off"
    grep -qx "gtk-custom-css = $ROOT/default/gtk/no-blur.css" "$next_theme/ghostty.conf" || fail "declared Ghostty blur off overrides Glassy's GTK blur"
    grep -qx 'background_blur 0' "$next_theme/kitty.conf" || fail "declared Kitty blur stays off"
  elif [[ $declaration == "blurred" ]]; then
    grep -qx 'blur = true' "$next_theme/alacritty.toml" || fail "declared Alacritty blur stays on"
    grep -qx 'blur=yes' "$next_theme/foot.ini" || fail "declared Foot blur stays on"
    grep -qx 'background-blur = 32' "$next_theme/ghostty.conf" || fail "declared Ghostty blur keeps its radius"
    grep -qx 'background_blur 32' "$next_theme/kitty.conf" || fail "declared Kitty blur keeps its radius"
  else
    grep -qx 'blur=yes' "$next_theme/foot.ini" || fail "$declaration Foot remains ready for Glassy blur"
    ! grep -q '^blur =' "$next_theme/alacritty.toml" || fail "$declaration Alacritty emits no blur override"
    ! grep -q '^background-blur =' "$next_theme/ghostty.conf" || fail "$declaration Ghostty emits no blur override"
    ! grep -q '^background_blur ' "$next_theme/kitty.conf" || fail "$declaration Kitty emits no blur override"
  fi
  (( $(grep -c '^blur=' "$next_theme/foot.ini") == 1 )) || fail "$declaration Foot has one blur setting under Glassy"
  if [[ $declaration != "translucent" && $declaration != "opaque" ]]; then
    grep -qx "gtk-custom-css = $ROOT/default/gtk/glass.css" "$next_theme/ghostty.conf" || fail "$declaration Ghostty preserves Glassy's default CSS blur"
  fi
  python3 - "$next_theme/alacritty.toml" <<'PY'
import sys
import tomllib
from pathlib import Path
tomllib.loads(Path(sys.argv[1]).read_text())
PY
  if command -v foot >/dev/null; then
    HOME="$home" XDG_CONFIG_HOME="$home/.config" foot --check-config -c "$next_theme/foot.ini" >"$test_tmp/foot-check.log" 2>&1 ||
      fail "$declaration generated Foot config is valid" "$(<"$test_tmp/foot-check.log")"
  else
    skip "$declaration Foot config validation: foot is not installed"
  fi
  if command -v ghostty >/dev/null; then
    HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_CACHE_HOME="$home/.cache" \
      ghostty +validate-config --config-file="$next_theme/ghostty.conf" >"$test_tmp/ghostty-check.log" 2>&1 ||
      fail "$declaration generated Ghostty config is valid" "$(<"$test_tmp/ghostty-check.log")"
  else
    skip "$declaration Ghostty config validation: ghostty is not installed"
  fi
  # Repeat the real postprocessor, then remove only its additions in place.
  HOME="$home" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" \
    "$ROOT/bin/omarchy-theme-set-glass" "$next_theme"
  assert_opacity "$expected_opacity" "$declaration repeated"
  (( $(grep -c '^gtk-custom-css =' "$next_theme/ghostty.conf") == 1 )) || fail "$declaration Ghostty gets one managed CSS entry"
  rm "$toggles/window-glassy.lua"
  HOME="$home" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" \
    "$ROOT/bin/omarchy-theme-set-glass" "$next_theme"
  for file in alacritty.toml foot.ini ghostty.conf kitty.conf; do
    cmp -s "$before/$file" "$next_theme/$file" || fail "$declaration leaving Glassy restores $file byte for byte"
  done
  render
  for file in alacritty.toml foot.ini ghostty.conf kitty.conf; do
    cmp -s "$before/$file" "$next_theme/$file" || fail "$declaration opaque rerender preserves $file"
  done
  pass "$declaration terminal declarations compose with Glassy and survive switching it off"
done

reset_theme
cat >"$next_theme/hyprland.toml" <<'TOML'
schema = 1

[general]
gaps_in = 4
gaps_out = 9
border_size = 3

[decoration]
rounding = 14
rounding_power = 2.5
active_opacity = 1.0
inactive_opacity = 0.91
fullscreen_opacity = 1.0
dim_inactive = true
dim_strength = 0.08

[decoration.blur]
enabled = true
size = 5
passes = 3
noise = 0.02
contrast = 0.9
brightness = 0.8
vibrancy = 0.15
vibrancy_darkness = 0.7
ignore_opacity = true

[decoration.shadow]
enabled = true
range = 20
render_power = 4
color = "background"
color_inactive = "#11223344"
offset = "-2 3"
scale = 1.0

[group.groupbar]
enabled = true
render_titles = true
scrolling = false
font_size = 12
height = 24
indicator_height = 2
indicator_gap = 5
gaps_in = 4
gaps_out = 1
text_color = "foreground"
text_color_inactive = "#8899aabb"
active_color = "accent"
inactive_color = "background"
gradients = true
gradient_rounding = 6
gradient_round_only_edges = false

[[beziers]]
name = "themeEase"
x1 = 0.25
y1 = 0.46
x2 = 0.45
y2 = 0.94

[[animations]]
name = "windows"
enabled = true
speed = 3.5
curve = "themeEase"
style = "popin 87%"
TOML
render
grep -Fq -- '-- Generated from declarative hyprland.toml' "$next_theme/hyprland.lua" || fail "valid Hyprland declaration is generated"
grep -Fq 'gaps_in = 4' "$next_theme/hyprland.lua" || fail "Hyprland general settings are generated"
grep -Fq 'color = "rgb(1a1b26)"' "$next_theme/hyprland.lua" || fail "Hyprland color resolves a palette reference"
grep -Fq 'color_inactive = "rgba(11223344)"' "$next_theme/hyprland.lua" || fail "Hyprland literal color is normalized"
grep -Fq 'offset = { -2, 3 }' "$next_theme/hyprland.lua" || fail "Hyprland shadow offset is generated as a vector"
grep -Fq 'hl.curve("themeEase"' "$next_theme/hyprland.lua" || fail "Hyprland bezier is generated"
grep -Fq 'leaf = "windows"' "$next_theme/hyprland.lua" || fail "Hyprland animation leaf is generated"
lua - <<LUA
hl = { config = function(_) end, curve = function(_, _) end, animation = function(_) end }
dofile("$next_theme/hyprland.lua")
LUA
pass "valid hyprland.toml generates syntactically valid allowlisted Lua"

reset_theme
sed -i 's/^background =/bg =/; s/^foreground =/fg =/' "$next_theme/colors.toml"
cat >"$next_theme/hyprland.toml" <<'TOML'
schema = 1
[decoration.shadow]
color = "background"
color_inactive = "dark_background"
[group.groupbar]
text_color = "foreground"
TOML
resolved_values=$(PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-color" --file "$next_theme/colors.toml" --all)
derived_background=$(awk -F '\t' '$1 == "dark_background" { print $2 }' <<<"$resolved_values")
render
grep -Fq 'color = "rgb(1a1b26)"' "$next_theme/hyprland.lua" || fail "Hyprland resolves legacy background aliases"
grep -Fq 'text_color = "rgb(a9b1d6)"' "$next_theme/hyprland.lua" || fail "Hyprland resolves legacy foreground aliases"
grep -Fq "color_inactive = \"rgb(${derived_background#\#})\"" "$next_theme/hyprland.lua" || fail "Hyprland resolves derived colors"
pass "Hyprland declarations use shared palette aliases and derived colors"

reset_theme
render
! grep -Fq 'Generated from declarative hyprland.toml' "$next_theme/hyprland.lua" || fail "absent hyprland.toml changes no generated behavior"
[[ ! -s $test_tmp/stderr ]] || fail "absent hyprland.toml produces no warning" "$(cat "$test_tmp/stderr")"
pass "absent hyprland.toml retains the base Hyprland output"

marker="$test_tmp/pwned"
for invalid_case in unknown malicious malformed schema-type color-form bounds; do
  reset_theme
  case "$invalid_case" in
    unknown)
      printf 'schema = 1\n[general]\nlayout = "master"\n' >"$next_theme/hyprland.toml"
      ;;
    malicious)
      cat >"$next_theme/hyprland.toml" <<TOML
schema = 1
[[animations]]
name = "windows"
enabled = true
style = "fade\"); os.execute(\"touch $marker\") --"
TOML
      ;;
    malformed)
      printf 'schema = 1\n[decoration\nrounding = 4\n' >"$next_theme/hyprland.toml"
      ;;
    schema-type)
      printf 'schema = 1.0\n' >"$next_theme/hyprland.toml"
      ;;
    color-form)
      printf 'schema = 1\n[decoration.shadow]\ncolor = "rgb(11223344)"\n' >"$next_theme/hyprland.toml"
      ;;
    bounds)
      printf 'schema = 1\n[decoration]\nrounding = 21\n' >"$next_theme/hyprland.toml"
      ;;
  esac
  render
  ! grep -Fq 'Generated from declarative hyprland.toml' "$next_theme/hyprland.lua" || fail "$invalid_case Hyprland TOML emits no override"
  grep -q 'ignoring invalid hyprland.toml' "$test_tmp/stderr" || fail "$invalid_case Hyprland TOML warns"
done
[[ ! -e $marker ]] || fail "malicious Hyprland TOML executes nothing"
pass "invalid and malicious hyprland.toml safely fall back to the base output"

reset_theme
printf 'trusted-local-hyprland\n' >"$next_theme/hyprland.lua"
printf 'schema = 1\n[general]\ngaps_in = 99\n' >"$next_theme/hyprland.toml"
render
[[ $(cat "$next_theme/hyprland.lua") == "trusted-local-hyprland" ]] || fail "existing Hyprland Lua remains untouched"
pass "trusted hyprland.lua retains precedence over hyprland.toml"
