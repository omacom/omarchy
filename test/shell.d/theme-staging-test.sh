#!/bin/bash

set -euo pipefail

# A theme installed with `omarchy theme install` is a stranger's git repo, so
# omarchy-theme-set drops the files that would run its code -- Lua, terminal
# configs, vscode.json -- and keeps the colour. A theme the user wrote themselves
# is not filtered at all.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
state="$home/.local/state/omarchy/current"
themes="$home/.config/omarchy/themes"
mkdir -p "$state" "$themes"

marker="omarchy-theme-staging-marker"

set_theme() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
    XDG_RUNTIME_DIR="$test_tmp" \
    bash "$ROOT/bin/omarchy-theme-set" "$1" 2>"$test_tmp/stderr" || return $?
}

staged() {
  printf '%s' "$state/theme/$1"
}

assert_staged() {
  [[ -f $(staged "$1") ]] || fail "$2"
}

assert_not_staged() {
  [[ ! -e $(staged "$1") ]] || fail "$2"
}

assert_no_marker() {
  ! grep -q "$marker" "$(staged "$1")" || fail "$2"
}

write_colors() {
  cat >"$1" <<TOML
mode = "light"

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

# A theme that ships everything it is not allowed to ship.
hostile="$themes/hostile"
mkdir -p "$hostile/backgrounds" "$hostile/.git"
write_colors "$hostile/colors.toml"
touch "$hostile/light.mode"
printf 'os.execute("%s")\n' "$marker" >"$hostile/hyprland.lua"
printf 'vim.cmd("%s")\n' "$marker" >"$hostile/neovim.lua"
printf 'shell %s\n' "$marker" >"$hostile/kitty.conf"
printf '[terminal.shell]\nprogram = "%s"\n' "$marker" >"$hostile/alacritty.toml"
printf 'shell = "%s"\n' "$marker" >"$hostile/foot.ini"
printf 'command = "%s"\n' "$marker" >"$hostile/ghostty.conf"
printf 'hl.env("GUM_INPUT_PROMPT", "%s")\n' "$marker" >"$hostile/gum_env.lua"
printf '[bar]\nbackground = "#%s"\n' "000000" >"$hostile/shell.toml"
printf '{}\n' >"$hostile/vscode.json"
printf 'Yaru-red\n' >"$hostile/icons.theme"
printf 'theme[main_bg]="#000000"\n' >"$hostile/btop.theme"
printf 'png\n' >"$hostile/preview.png"
printf 'png\n' >"$hostile/backgrounds/1-real.png"
printf '%s\n' "$marker" >"$hostile/backgrounds/payload.sh"
printf '# notes\n' >"$hostile/README.md"
ln -s /etc/hostname "$hostile/unlock.png"

set_theme hostile || fail "omarchy-theme-set applies a theme that ships disallowed files"

assert_staged colors.toml "the theme's colors.toml is staged"
grep -q '#7aa2f7' "$(staged colors.toml)" || fail "the staged colors.toml is the theme's palette"
assert_staged light.mode "the light mode marker is staged"
assert_staged preview.png "the theme's preview image is staged"
assert_staged backgrounds/1-real.png "an image in backgrounds/ is staged"

assert_not_staged unlock.png "a symlink is not followed out of the theme"
assert_not_staged vscode.json "vscode.json names an extension to install and is not staged"

assert_staged icons.theme "the theme's icon set name is staged"
grep -q 'Yaru-red' "$(staged icons.theme)" || fail "the staged icons.theme is the theme's"
assert_staged btop.theme "the theme's btop colours are staged"
grep -q 'main_bg' "$(staged btop.theme)" || fail "the staged btop.theme is the theme's"
assert_not_staged .git "the clone's own git directory is never staged"

# These run code, so the theme's versions must lose to Omarchy's generated ones
# rather than merely be absent.
for generated in hyprland.lua neovim.lua gum_env.lua kitty.conf alacritty.toml foot.ini ghostty.conf; do
  assert_staged "$generated" "$generated is generated from Omarchy's template"
  assert_no_marker "$generated" "an installed theme cannot supply $generated"
done

# Colour is kept, including a file Omarchy would otherwise have generated.
assert_staged shell.toml "shell.toml is staged"
grep -q '000000' "$(staged shell.toml)" || fail "an installed theme's shell.toml colours are kept"

grep -q 'hyprland.lua' "$test_tmp/stderr" || fail "omarchy-theme-set names the files it ignored"
! grep -q 'README.md' "$test_tmp/stderr" || fail "omarchy-theme-set does not report a theme's documentation"

pass "an installed theme keeps its colour and loses everything that runs code"

# icons.theme is staged verbatim and handed to gsettings, so a symlinked one
# would stage a copy of whatever it points at.
linked="$themes/linked"
mkdir -p "$linked/.git"
write_colors "$linked/colors.toml"
ln -s /etc/hostname "$linked/icons.theme"

set_theme linked || fail "omarchy-theme-set applies a theme whose icons.theme is a symlink"
assert_not_staged icons.theme "a symlinked icons.theme is not followed"

pass "a symlinked icon set name is refused like any other symlink"

# A theme predating colors.toml still gets a palette, without its alacritty.toml
# reaching the staged theme.
legacy="$themes/legacy"
mkdir -p "$legacy/.git"
cat >"$legacy/alacritty.toml" <<TOML
[terminal.shell]
program = "$marker"

[colors.primary]
background = "#102030"
foreground = "#a0b0c0"

[colors.normal]
black = "#102030"
red = "#ff0000"
green = "#00ff00"
yellow = "#ffff00"
blue = "#0000ff"
magenta = "#ff00ff"
cyan = "#00ffff"
white = "#a0b0c0"
TOML

set_theme legacy || fail "omarchy-theme-set applies a theme that only ships alacritty.toml"
assert_staged colors.toml "a legacy theme's palette is recovered from its alacritty.toml"
grep -q '#102030' "$(staged colors.toml)" || fail "the recovered palette is the theme's"
assert_no_marker alacritty.toml "a legacy theme's alacritty.toml is not staged"

pass "a theme older than colors.toml keeps its palette and loses its terminal config"

# An overlay on a stock theme still repaints it, and still cannot add code.
mkdir -p "$themes/tokyo-night/.git"
write_colors "$themes/tokyo-night/colors.toml"
sed -i 's/#7aa2f7/#abcdef/' "$themes/tokyo-night/colors.toml"
printf 'os.execute("%s")\n' "$marker" >"$themes/tokyo-night/hyprland.lua"

set_theme "Tokyo Night" || fail "omarchy-theme-set applies a stock theme with a user overlay"
grep -q '#abcdef' "$(staged colors.toml)" || fail "a user overlay still replaces the stock palette"
assert_no_marker hyprland.lua "a user overlay cannot add Lua to a stock theme"

pass "an overlay on a stock theme repaints it without adding code"

# A theme the user wrote themselves has no git repo behind it and is theirs.
mine="$themes/mine"
mkdir -p "$mine"
write_colors "$mine/colors.toml"
printf 'os.execute("%s")\n' "$marker" >"$mine/hyprland.lua"
printf '{"name":"Mine","extension":"pub.ext"}\n' >"$mine/vscode.json"

set_theme mine || fail "omarchy-theme-set applies a theme the user wrote"
grep -q "$marker" "$(staged hyprland.lua)" || fail "a theme the user wrote keeps its own hyprland.lua"
assert_staged vscode.json "a theme the user wrote keeps every file it ships"
[[ ! -s $test_tmp/stderr ]] || fail "a theme the user wrote reports nothing ignored" "$(cat "$test_tmp/stderr")"

pass "a theme the user wrote is not held to the installed-theme list"

# A working copy symlinked into the themes folder is the user's own too.
ln -s "$mine" "$themes/mine-link"
set_theme mine-link || fail "omarchy-theme-set applies a symlinked working copy"
grep -q "$marker" "$(staged hyprland.lua)" || fail "a symlinked working copy is the user's own"

pass "a symlinked working copy is the user's own"

# The name is joined into paths that get removed and copied into.
for name in .. . "../../evil"; do
  if set_theme "$name" >/dev/null; then
    fail "omarchy-theme-set rejects the theme name '$name'"
  fi
done

pass "a theme name cannot climb out of the theme directories"

# A removed theme can leave a backgrounds-only directory behind: omarchy-themes-intros
# still ships themes/osaka-jade after the theme left the repo (#17198). That
# directory alone must not pass as a theme -- the switch used to exit 0 having
# staged nothing, and foot then pointed at a theme file that was never generated.
# OMARCHY_PATH is only read for themes/ here, so a shadow tree carrying the
# package-shipped directory stands in for the installed Omarchy. The refusal
# fires before the staging area is rebuilt, so what was staged before survives.
shipped="$test_tmp/shipped-omarchy"
mkdir -p "$shipped/themes/osaka-jade/backgrounds/intros"
printf 'mp4\n' >"$shipped/themes/osaka-jade/backgrounds/intros/1-glowing-city.mp4"

# The refusal fires before the staging area is rebuilt, so the working theme
# (mine-link, from the case above) must survive it untouched: same palette,
# same name.
if HOME="$home" OMARCHY_PATH="$shipped" PATH="$ROOT/bin:$PATH" \
  OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
  XDG_RUNTIME_DIR="$test_tmp" \
  bash "$ROOT/bin/omarchy-theme-set" osaka-jade >"$test_tmp/stdout" 2>&1; then
  fail "omarchy-theme-set refuses a backgrounds-only theme directory"
fi
grep -q 'no colors.toml' "$test_tmp/stdout" || fail "the refusal names the missing palette" "$(cat "$test_tmp/stdout")"
grep -q '#7aa2f7' "$(staged colors.toml)" || fail "the refusal keeps the working theme's palette"
[[ $(<"$state/theme.name") == "mine-link" ]] || fail "the refusal keeps the working theme's name"

pass "a theme directory without a palette is refused, not silently applied"

# Staging itself can still lose the palette. An installed theme's colors.toml
# is a symlink, which the installed-theme filter drops, and an alacritty.toml
# missing a normal colour converts to nothing. Either must refuse the switch
# with the working theme (mine-link) left exactly as it was.
linked_palette="$themes/linked-palette"
mkdir -p "$linked_palette/.git"
ln -s /etc/hostname "$linked_palette/colors.toml"

if HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
  XDG_RUNTIME_DIR="$test_tmp" \
  bash "$ROOT/bin/omarchy-theme-set" linked-palette >"$test_tmp/stdout" 2>&1; then
  fail "omarchy-theme-set refuses an installed theme whose colors.toml is a symlink"
fi
grep -q 'staged no colors.toml' "$test_tmp/stdout" || fail "the symlinked palette refusal names the staged palette" "$(cat "$test_tmp/stdout")"
grep -q '#7aa2f7' "$(staged colors.toml)" || fail "the symlinked palette refusal keeps the working theme's palette"
[[ $(<"$state/theme.name") == "mine-link" ]] || fail "the symlinked palette refusal keeps the working theme's name"

pass "an installed theme whose only palette is a symlink is refused, not applied"

partial="$themes/partial-alacritty"
mkdir -p "$partial/.git"
cat >"$partial/alacritty.toml" <<TOML
[colors.primary]
background = "#102030"

[colors.normal]
black = "#102030"
red = "#ff0000"
TOML

if HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
  XDG_RUNTIME_DIR="$test_tmp" \
  bash "$ROOT/bin/omarchy-theme-set" partial-alacritty >"$test_tmp/stdout" 2>&1; then
  fail "omarchy-theme-set refuses an alacritty.toml that converts to no palette"
fi
grep -q 'staged no colors.toml' "$test_tmp/stdout" || fail "the partial alacritty refusal names the staged palette" "$(cat "$test_tmp/stdout")"
grep -q '#7aa2f7' "$(staged colors.toml)" || fail "the partial alacritty refusal keeps the working theme's palette"
[[ $(<"$state/theme.name") == "mine-link" ]] || fail "the partial alacritty refusal keeps the working theme's name"

pass "an alacritty.toml that yields no palette is refused, not applied"

# A denylist is only correct while someone adding a template classifies what it
# generates. Every generated theme file is either denied to an installed theme or
# recorded here as carrying colour, so a new template fails until it is placed.
denied=(alacritty.toml foot.ini ghostty.conf kitty.conf gum_env.lua hyprland.lua neovim.lua vscode.json)
colour_only=(btop.theme chromium.theme claude.json fcitx5-theme.conf helix.toml hermes.yaml hyprland-preview-share-picker.css keyboard.rgb obsidian.css pi.json shell.toml t3code.json vscode-theme.json)

for tpl in "$ROOT"/default/themed/*.tpl; do
  generated=$(basename "$tpl" .tpl)
  classified=""

  for name in "${denied[@]}" "${colour_only[@]}"; do
    if [[ $generated == "$name" ]]; then
      classified=1
      break
    fi
  done

  [[ -n $classified ]] ||
    fail "every generated theme file is classified as code or colour" \
      "$generated has a template but is in neither list in $(basename "$0"); decide whether an installed theme may ship it"
done

pass "every file Omarchy generates is classified as code or colour"
