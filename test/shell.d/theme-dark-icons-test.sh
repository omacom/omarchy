#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The light Yaru variants draw their panel and tray icons dark for a light bar,
# so a dark theme naming one leaves those icons unreadable (#8844).
light_yaru='^Yaru(-(blue|magenta|olive|prussiangreen|purple|red|sage|wartybrown|yellow))?$'

dark_themes=0
for colors in "$ROOT"/themes/*/colors.toml; do
  theme_dir=${colors%/*}
  [[ $("$ROOT/bin/omarchy-theme-color" --file "$colors" mode) == "dark" ]] || continue
  dark_themes=$(( dark_themes + 1 ))
  [[ -f $theme_dir/icons.theme ]] || continue

  icons=$(<"$theme_dir/icons.theme")
  if [[ $icons =~ $light_yaru ]]; then
    fail "dark stock themes use a dark Yaru icon variant" "${theme_dir##*/} uses $icons"
  fi
done
(( dark_themes > 0 )) || fail "dark stock themes use a dark Yaru icon variant" "no dark stock theme was found"
pass "dark stock themes use a dark Yaru icon variant"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
current="$home/.local/state/omarchy/current"
overlay="$home/.config/omarchy/themes/nord"
mkdir -p "$current/theme" "$test_tmp/bin"

printf '#!/bin/bash\nprintf "%%s\\n" "$*" >"%s/gsettings.log"\n' "$test_tmp" >"$test_tmp/bin/gsettings"
printf '#!/bin/bash\ntouch "%s/refreshed"\n' "$test_tmp" >"$test_tmp/bin/omarchy-theme-refresh"
chmod +x "$test_tmp/bin/gsettings" "$test_tmp/bin/omarchy-theme-refresh"

in_test_home() {
  HOME="$home" OMARCHY_PATH="$ROOT" DBUS_SESSION_BUS_ADDRESS="unix:path=$test_tmp/bus" PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$@"
}

# A theme without an icons.theme gets the default, which has to follow its mode.
cp "$ROOT/themes/nord/colors.toml" "$current/theme/colors.toml"
in_test_home "$ROOT/bin/omarchy-theme-set-gnome"
grep -Fxq 'set org.gnome.desktop.interface icon-theme Yaru-blue-dark' "$test_tmp/gsettings.log" ||
  fail "a dark theme without icons.theme gets the dark Yaru icons"
cp "$ROOT/themes/rose-pine/colors.toml" "$current/theme/colors.toml"
in_test_home "$ROOT/bin/omarchy-theme-set-gnome"
grep -Fxq 'set org.gnome.desktop.interface icon-theme Yaru-blue' "$test_tmp/gsettings.log" ||
  fail "a light theme without icons.theme gets the light Yaru icons"
pass "a theme without icons.theme gets the Yaru icons for its mode"

# First run applies the staged theme's icons rather than a fixed light set.
cp "$ROOT/themes/nord/colors.toml" "$current/theme/colors.toml"
cp "$ROOT/themes/nord/icons.theme" "$current/theme/icons.theme"
in_test_home bash "$ROOT/install/user/first-run/gnome-theme.sh"
grep -Fxq 'set org.gnome.desktop.interface icon-theme Yaru-blue-dark' "$test_tmp/gsettings.log" ||
  fail "first run applies the staged theme's icons"
rm "$current/theme/icons.theme"
pass "first run applies the staged theme's icons"

run_migration() {
  rm -f "$test_tmp/refreshed"
  in_test_home bash -euo pipefail "$ROOT/migrations/1791527796.sh" >/dev/null
}

printf 'nord\n' >"$current/theme.name"
cp "$ROOT/themes/nord/colors.toml" "$current/theme/colors.toml"
printf 'Yaru-blue\n' >"$current/theme/icons.theme"
run_migration
[[ -e $test_tmp/refreshed ]] || fail "the migration re-stages a dark theme staged with the light icons"
pass "the migration re-stages a dark theme staged with the light icons"

mkdir -p "$overlay"
printf 'Yaru-blue\n' >"$overlay/icons.theme"
run_migration
[[ ! -e $test_tmp/refreshed ]] || fail "the migration keeps an icons.theme the user chose"
rm "$overlay/icons.theme"
printf 'mode = "light"\n' >"$current/theme/colors.toml"
run_migration
[[ ! -e $test_tmp/refreshed ]] || fail "the migration leaves a theme the user made light alone"
cp "$ROOT/themes/nord/colors.toml" "$current/theme/colors.toml"
printf 'Yaru-blue-dark\n' >"$current/theme/icons.theme"
run_migration
[[ ! -e $test_tmp/refreshed ]] || fail "the migration leaves a theme already on the dark icons alone"
printf 'rose-pine\n' >"$current/theme.name"
cp "$ROOT/themes/rose-pine/colors.toml" "$current/theme/colors.toml"
printf 'Yaru-blue\n' >"$current/theme/icons.theme"
run_migration
[[ ! -e $test_tmp/refreshed ]] || fail "the migration leaves a light theme alone"
printf 'my-own-theme\n' >"$current/theme.name"
run_migration
[[ ! -e $test_tmp/refreshed ]] || fail "the migration leaves a theme Omarchy does not ship alone"
pass "the migration leaves every other theme alone"

# A mode it cannot resolve leaves the migration pending rather than done.
printf 'nord\n' >"$current/theme.name"
cp "$ROOT/themes/nord/colors.toml" "$current/theme/colors.toml"
mkdir -p "$test_tmp/broken"
printf '#!/bin/bash\nexit 17\n' >"$test_tmp/broken/omarchy-theme-color"
chmod +x "$test_tmp/broken/omarchy-theme-color"
if HOME="$home" OMARCHY_PATH="$ROOT" PATH="$test_tmp/broken:$test_tmp/bin:$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1791527796.sh" >/dev/null 2>&1; then
  fail "the migration fails when it cannot resolve the theme's mode"
fi
pass "the migration fails when it cannot resolve the theme's mode"
