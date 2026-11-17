#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" HERDR_APP_HOME="$test_tmp/herdr" PATH="$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$test_tmp/runtime"
unset XDG_CONFIG_HOME
mkdir -p "$XDG_RUNTIME_DIR"
current="$HOME/.local/state/omarchy/current/theme"
next="$HOME/.local/state/omarchy/current/next-theme"

render_theme() {
  mkdir -p "$next" "$current"
  cp "$ROOT/themes/$1/colors.toml" "$next/colors.toml"
  omarchy-theme-set-templates
  cp "$next/herdr-app.json" "$next/colors.toml" "$current/"
  rm -rf "$next"
}

render_theme nord
omarchy-theme-set-herdr-app
[[ ! -e $HERDR_APP_HOME ]] || fail "theme sync must not create an unused Herdr home"
pass "machines without Herdr get no Herdr home"

mkdir -p "$HERDR_APP_HOME"
render_theme catppuccin-latte
omarchy-theme-set-herdr-app
cp "$current/herdr-app.json" "$test_tmp/latte.json"
render_theme nord
omarchy-theme-set-herdr-app
cmp -s "$current/herdr-app.json" "$HERDR_APP_HOME/themes/omarchy-dark.json" || fail "Herdr must receive the nord palette as its dark theme"
cmp -s "$test_tmp/latte.json" "$HERDR_APP_HOME/themes/omarchy-light.json" || fail "a dark theme must leave the light palette in place"
pass "each switch publishes the current palette for its mode"

# Activating in light mode selects light now and dark on the first dark switch.
# A closed window (the stub failing) keeps dark pending for the next dark switch.
mkdir -p "$test_tmp/bin"
printf '%s\n' '#!/bin/bash' \
  '[[ $1 == "--version" ]] && { echo "herdr-app 0.1.13"; exit; }' \
  'echo "$*" >>"$HERDR_APP_HOME/calls"' \
  '[[ ! -e $HERDR_APP_HOME/closed ]]' \
  >"$test_tmp/bin/herdr-app"
chmod +x "$test_tmp/bin/herdr-app"
switch_to() {
  render_theme "$1"
  PATH="$test_tmp/bin:$PATH" omarchy-theme-set-herdr-app "${@:2}"
}
switch_to catppuccin-latte --activate
touch "$HERDR_APP_HOME/closed"
switch_to nord
rm "$HERDR_APP_HOME/closed"
switch_to tokyo-night
switch_to rose-pine
switch_to nord
calls=$(<"$HERDR_APP_HOME/calls")
[[ $calls == $'do app.theme --name omarchy-light\ndo app.theme --name omarchy-dark\ndo app.theme --name omarchy-dark' ]] || fail "activation must select each mode until Herdr takes it, got: $calls"
pass "activation selects the other appearance once Herdr can take it"

cp "$HERDR_APP_HOME/themes/omarchy-dark.json" "$test_tmp/good-theme.json"
for filter in '.background = "{{ unresolved }}"' '.ansi = []' '.unknown = true'; do
  jq "$filter" "$test_tmp/good-theme.json" >"$current/herdr-app.json"
  omarchy-theme-set-herdr-app 2>/dev/null || fail "an invalid palette must not fail the theme switch"
  cmp -s "$test_tmp/good-theme.json" "$HERDR_APP_HOME/themes/omarchy-dark.json" || fail "an invalid palette must keep the last good theme"
done
pass "invalid palettes keep the last good theme"

render_theme nord
unset HERDR_APP_HOME
export XDG_CONFIG_HOME="$test_tmp/custom config"
mkdir -p "$XDG_CONFIG_HOME/herdr-app"
omarchy-theme-set-herdr-app
[[ -f $XDG_CONFIG_HOME/herdr-app/themes/omarchy-dark.json ]] || fail "a custom XDG_CONFIG_HOME must receive the palette"
pass "Herdr's home is found the way Herdr finds it"
