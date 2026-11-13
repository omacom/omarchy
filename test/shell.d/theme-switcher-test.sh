#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command magick

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
theme="$home/.config/omarchy/themes/walk-colours-only"
mock_bin="$test_tmp/bin"
mkdir -p "$theme" "$test_tmp/omarchy/themes" "$mock_bin"

cat >"$mock_bin/omarchy-menu-images" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/omarchy-menu-images"

open_switcher() {
  HOME="$home" OMARCHY_PATH="$test_tmp/omarchy" XDG_CACHE_HOME="$test_tmp/cache" PATH="$mock_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-theme-switcher"
}

preview_colour() {
  magick "$test_tmp/cache/omarchy/theme-selector/previews/walk-colours-only.png" -format '%[hex:p{0,0}]' info:
}

# A theme with only a colors.toml gets a preview in its background colour, and
# editing that file in place redraws it.
printf 'background = "#1a1b26"\n' >"$theme/colors.toml"
touch -d '2020-01-01' "$theme/colors.toml"
open_switcher
[[ $(preview_colour) == "1A1B26" ]] || fail "a colours-only theme gets a preview in its background colour" "$(preview_colour)"

printf 'background = "#eff1f5"\n' >"$theme/colors.toml"
open_switcher
[[ $(preview_colour) == "EFF1F5" ]] || fail "editing colors.toml in place redraws the preview" "$(preview_colour)"

pass "a colours-only theme's preview follows its background colour"
