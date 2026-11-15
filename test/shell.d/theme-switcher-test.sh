#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command magick

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

theme="$test_tmp/home/.config/omarchy/themes/colours-only"
mkdir -p "$theme" "$test_tmp/omarchy/themes" "$test_tmp/bin"
printf '#!/bin/bash\n' >"$test_tmp/bin/omarchy-menu-images"
chmod +x "$test_tmp/bin/omarchy-menu-images"

# A theme with only a colors.toml gets a preview in its background colour.
printf 'background = "#1a1b26"\n' >"$theme/colors.toml"
HOME="$test_tmp/home" OMARCHY_PATH="$test_tmp/omarchy" XDG_CACHE_HOME="$test_tmp/cache" PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-theme-switcher"
preview="$test_tmp/cache/omarchy/theme-selector/previews/colours-only.png"
[[ -f $preview ]] || fail "a colours-only theme gets a preview"
colour=$(magick "$preview" -format '%[hex:p{0,0}]' info:)
[[ $colour == "1A1B26" ]] || fail "a colours-only theme's preview is its background colour" "$colour"

pass "a colours-only theme gets a preview in its background colour"
