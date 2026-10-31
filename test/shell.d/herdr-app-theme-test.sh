#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" HERDR_APP_HOME="$test_tmp/herdr" PATH="$ROOT/bin:$PATH"
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
pass "Herdr theme sync skips an app that has never been opened"

mkdir -p "$HERDR_APP_HOME"
printf '{"zoom":1.25,"sounds":{"enabled":false},"theme":"moss","colors":{"border":"#123456"}}\n' >"$HERDR_APP_HOME/settings.json"
cp "$HERDR_APP_HOME/settings.json" "$test_tmp/original.json"
omarchy-theme-set-herdr-app
cmp -s "$test_tmp/original.json" "$HERDR_APP_HOME/settings.json" || fail "publishing must preserve a personal theme"
jq -e '.ansi | length == 16' "$HERDR_APP_HOME/themes/omarchy.json" >/dev/null || fail "published theme has sixteen terminal colors"
pass "Herdr discovers Omarchy without replacing a personal theme"

omarchy-theme-set-herdr-app --activate
jq -e '.theme == "omarchy" and .appearance == "dark" and .zoom == 1.25 and .sounds.enabled == false and .colors.border == "#123456"' "$HERDR_APP_HOME/settings.json" >/dev/null || fail "activation preserves unrelated settings"
pass "explicit activation selects Omarchy and preserves other settings"

for name in catppuccin-latte nord; do
  render_theme "$name"
  omarchy-theme-set-herdr-app
  mode=$(omarchy-theme-color mode)
  background=$(jq -r .background "$current/herdr-app.json")
  jq -e --arg mode "$mode" --arg background "$background" '.appearance == $mode and .colors.background == $background' "$HERDR_APP_HOME/settings.json" >/dev/null || fail "Herdr follows a light/dark palette change"
  cmp -s "$current/herdr-app.json" "$HERDR_APP_HOME/themes/omarchy.json" || fail "Herdr receives the new palette"
done
pass "active Herdr follows dark to light to dark using rendered palettes"

jq '.colors.accent = "#123abc"' "$current/herdr-app.json" >"$test_tmp/accent.json"
mv "$test_tmp/accent.json" "$current/herdr-app.json"
omarchy-theme-set-herdr-app
jq -e '.colors.accent == "#123abc"' "$HERDR_APP_HOME/settings.json" >/dev/null || fail "an accent-only edit must trigger reload on released Herdr"
pass "accent-only changes reach Herdr without changing the terminal palette"

settings_time=$(stat -c %y "$HERDR_APP_HOME/settings.json")
theme_time=$(stat -c %y "$HERDR_APP_HOME/themes/omarchy.json")
omarchy-theme-set-herdr-app
[[ $(stat -c %y "$HERDR_APP_HOME/settings.json") == "$settings_time" && $(stat -c %y "$HERDR_APP_HOME/themes/omarchy.json") == "$theme_time" ]] || fail "unchanged sync must not rewrite watched files"
pass "unchanged palettes do not cause reloads"

cp "$HERDR_APP_HOME/settings.json" "$test_tmp/good-settings.json"
cp "$HERDR_APP_HOME/themes/omarchy.json" "$test_tmp/good-theme.json"
sed -i 's/#[0-9a-fA-F]\{6\}/{{ unresolved }}/g' "$current/herdr-app.json"
if omarchy-theme-set-herdr-app >"$test_tmp/invalid.log" 2>&1; then
  fail "invalid generated colors must be rejected"
fi
cmp -s "$test_tmp/good-settings.json" "$HERDR_APP_HOME/settings.json" || fail "invalid palette must preserve settings"
cmp -s "$test_tmp/good-theme.json" "$HERDR_APP_HOME/themes/omarchy.json" || fail "invalid palette must preserve last good theme"
pass "invalid palettes leave the working theme and settings untouched"

render_theme catppuccin-latte
printf '{broken\n' >"$HERDR_APP_HOME/settings.json"
if omarchy-theme-set-herdr-app >"$test_tmp/broken.log" 2>&1; then
  fail "broken settings must be reported"
fi
cmp -s "$test_tmp/good-theme.json" "$HERDR_APP_HOME/themes/omarchy.json" || fail "broken settings must not partially publish a theme"
pass "broken settings are not overwritten or partially applied"
