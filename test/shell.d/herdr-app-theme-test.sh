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
for name in catppuccin-latte nord; do
  render_theme "$name"
  omarchy-theme-set-herdr-app
  cmp -s "$current/herdr-app.json" "$HERDR_APP_HOME/themes/omarchy.json" || fail "Herdr must receive the $name palette"
done
pass "each switch publishes the current palette"

cp "$HERDR_APP_HOME/themes/omarchy.json" "$test_tmp/good-theme.json"
for filter in '.background = "{{ unresolved }}"' '.ansi = []' '.unknown = true'; do
  jq "$filter" "$test_tmp/good-theme.json" >"$current/herdr-app.json"
  omarchy-theme-set-herdr-app 2>/dev/null || fail "an invalid palette must not fail the theme switch"
  cmp -s "$test_tmp/good-theme.json" "$HERDR_APP_HOME/themes/omarchy.json" || fail "an invalid palette must keep the last good theme"
done
pass "invalid palettes keep the last good theme"

render_theme nord
unset HERDR_APP_HOME
export XDG_CONFIG_HOME="$test_tmp/custom config"
mkdir -p "$XDG_CONFIG_HOME/herdr-app"
omarchy-theme-set-herdr-app
[[ -f $XDG_CONFIG_HOME/herdr-app/themes/omarchy.json ]] || fail "a custom XDG_CONFIG_HOME must receive the palette"
pass "Herdr's home is found the way Herdr finds it"
