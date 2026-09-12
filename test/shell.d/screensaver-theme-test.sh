#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

theme=$ROOT/bin/omarchy-screensaver-theme
[[ -x $theme ]] || fail "omarchy-screensaver-theme is executable"

catppuccin=$("$theme" "$ROOT/themes/catppuccin/colors.toml")
[[ $catppuccin == $'#101019\n#b8cbf5,#a0bff7,#89b4fa,#4c6289,#6a8bc1\nrgb:10/10/19' ]] ||
  fail "catppuccin field ramp is crest, hover, lit, mid, dim" "$catppuccin"
pass "catppuccin field ramp is crest, hover, lit, mid, dim"

latte=$("$theme" "$ROOT/themes/catppuccin-latte/colors.toml")
[[ $latte == *$'\n#9fb5e3,#5e8dec,#1e66f5,#7a9fe8,#4c82ee\n'* ]] ||
  fail "a light theme mixes hover and crest toward background" "$latte"
pass "a light theme mixes hover and crest toward background"

tokyo=$("$theme" "$ROOT/themes/tokyo-night/colors.toml")
[[ $tokyo == $'#0e0e14\n#abbef5,#92b0f6,#7aa2f7,#445885,#5f7dbe\nrgb:0e/0e/14' ]] ||
  fail "tokyo-night uses accent, not the site's green brand" "$tokyo"
pass "tokyo-night uses accent, not the site's green brand"

if "$theme" /tmp/missing-omarchy-colors.toml 2>/dev/null; then
  fail "a missing colors.toml exits non-zero"
fi
pass "a missing colors.toml exits non-zero"

# shellcheck source=../../bin/omarchy-screensaver-theme
source "$theme"
nineteen=""
for i in $(seq 0 18); do nineteen+=$(field_band_index_n "$i" 19); done
[[ $nineteen == 0000011222233344444 ]] || fail "19 lines stay 5-2-4-3-5" "$nineteen"
pass "19 lines stay 5-2-4-3-5"

ten=""
for i in $(seq 0 9); do ten+=$(field_band_index_n "$i" 10); done
[[ $ten == 0001223444 ]] || fail "10 lines scale to 3-1-2-1-3" "$ten"
pass "10 lines scale to 3-1-2-1-3"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub=$test_tmp/bin
mkdir -p "$stub"

cat >"$stub/ttfx" <<'STUB'
#!/bin/bash
if [[ $1 == --help ]]; then
  echo "      --palette"
  exit 0
fi
printf '%s\n' "$@"
STUB
chmod +x "$stub/ttfx"

# shellcheck source=../../bin/omarchy-screensaver-theme
source "$ROOT/bin/omarchy-screensaver-theme"
PATH="$stub:$PATH"

ttfx_supports_palette || fail "ttfx --help with --palette is detected"
pass "ttfx --help with --palette is detected"

cat >"$stub/ttfx" <<'STUB'
#!/bin/bash
if [[ $1 == --help ]]; then
  echo "      --random-effect"
  exit 0
fi
exit 0
STUB
chmod +x "$stub/ttfx"
ttfx_supports_palette && fail "ttfx --help without --palette is rejected"
pass "ttfx --help without --palette is rejected"

cat >"$stub/ttfx" <<'STUB'
#!/bin/bash
if [[ $1 == --help ]]; then
  echo "      --palette"
  echo "      --bands"
  exit 0
fi
printf '%s\n' "$@"
STUB
chmod +x "$stub/ttfx"
ttfx_supports_bands || fail "ttfx --help with --bands is detected"
pass "ttfx --help with --bands is detected"

cat >"$stub/ttfx" <<'STUB'
#!/bin/bash
if [[ $1 == --help ]]; then
  echo "      --palette"
  exit 0
fi
exit 0
STUB
chmod +x "$stub/ttfx"
ttfx_supports_bands && fail "ttfx --help without --bands is rejected"
pass "ttfx --help without --bands is rejected"
