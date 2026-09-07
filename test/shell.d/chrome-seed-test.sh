#!/bin/bash

set -euo pipefail

# Chromium's BrowserThemeColor policy is a seed, not a paint color: Chromium
# derives the chrome color from it by adjusting lightness while preserving HSL
# saturation. Near-black and near-white seeds are degenerate there, so a tinted
# background would render as loud, saturated chrome of its hue. The generated
# chromium.theme must be the clamped seed, not the raw background.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
next_theme="$home/.local/state/omarchy/current/next-theme"
mkdir -p "$next_theme"

generated_chrome_seed() {
  local background="$1"

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

  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-theme-set-templates"

  tr -d '[:space:]' <"$next_theme/chromium.theme"
}

while read -r background expected; do
  actual=$(generated_chrome_seed "$background")
  [[ $actual == "$expected" ]] ||
    fail "chromium.theme is the clamped chrome seed of the background" \
      "background $background: expected $expected, got $actual"
  pass "background $background generates chromium.theme $expected"
done <<'EOF'
#000107 3,3,3
#fffcf0 249,249,249
#1a1b26 26,27,38
#ff0000 255,0,0
EOF
