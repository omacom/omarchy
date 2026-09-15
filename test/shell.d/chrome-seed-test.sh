#!/bin/bash

set -euo pipefail

# Chromium's BrowserThemeColor policy is a seed, not a paint color: Chromium
# derives the chrome color from it by adjusting lightness while preserving HSL
# saturation. Near-black and near-white seeds are degenerate there, so a tinted
# background would render as loud, saturated chrome of its hue. The generated
# chromium.theme must be the clamped seed, not the raw background — unless the
# theme defines its own chrome_seed, or the background is not plain hex at all.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
next_theme="$home/.local/state/omarchy/current/next-theme"
mkdir -p "$next_theme"

generated_chromium_theme() {
  local background="$1"
  local chrome_seed="${2:-}"

  # Templates never overwrite an output that already exists, so each case
  # starts from a clean staging directory.
  rm -rf "$next_theme"
  mkdir -p "$next_theme"

  cat >"$next_theme/colors.toml" <<TOML
mode = "dark"

accent = "#7aa2f7"
selection = "#292e42"
muted = "#414868"

background = "$background"
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

  if [[ -n $chrome_seed ]]; then
    printf '\nchrome_seed = "%s"\n' "$chrome_seed" >>"$next_theme/colors.toml"
  fi

  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-theme-set-templates"

  cat "$next_theme/chromium.theme"
}

assert_chromium_theme() {
  local description="$1"
  local expected="$2"
  local actual

  actual=$(generated_chromium_theme "$3" "$4")
  [[ $actual == "$expected" ]] ||
    fail "$description" "background $3 chrome_seed ${4:-<none>}: expected $expected, got $actual"
  pass "$description"
}

assert_chromium_theme \
  "a near-black blue-tinted background generates a neutral chrome seed" \
  "3,3,3" "#000107" ""

assert_chromium_theme \
  "a near-white warm background generates a neutral chrome seed" \
  "249,249,249" "#fffcf0" ""

assert_chromium_theme \
  "a dark tinted background above the degenerate range keeps its seed" \
  "26,27,38" "#1a1b26" ""

assert_chromium_theme \
  "a saturated background keeps its seed" \
  "255,0,0" "#ff0000" ""

assert_chromium_theme \
  "a theme-defined chrome_seed wins over the derived one" \
  "18,52,86" "#000107" "#123456"

assert_chromium_theme \
  "a non-hex background passes through as the chrome seed" \
  "rgba(010203ee) rgba(040506ee) 45deg" "rgba(010203ee) rgba(040506ee) 45deg" ""
