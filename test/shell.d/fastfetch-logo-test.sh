#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

config="$ROOT/etc/fastfetch/config.jsonc"
helper="$ROOT/bin/omarchy-fastfetch-logo"
compact="$ROOT/default/fastfetch/logo.txt"
small="$ROOT/default/fastfetch/logo-small.txt"
full="$ROOT/logo.txt"

jq empty "$config"
pass "fastfetch config is valid JSON"

config_left=$(jq -r '.logo.padding.left' "$config")
config_right=$(jq -r '.logo.padding.right' "$config")

[[ -x $helper ]] || fail "the wordmark helper is executable"
pass "the wordmark helper is executable"
[[ -f $compact && -f $small && -f $full ]] || fail "full, compact, and small wordmarks are shipped"
pass "full, compact, and small wordmarks are shipped"

line_width() {
  python3 - "$1" <<'PYTHON'
from pathlib import Path
import sys
print(max(map(len, Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()), default=0))
PYTHON
}

full_w=$(line_width "$full")
compact_w=$(line_width "$compact")
small_w=$(line_width "$small")
full_h=$(wc -l <"$full")
compact_h=$(wc -l <"$compact")
small_h=$(wc -l <"$small")
icon_h=$(wc -l <"$ROOT/icon.txt")

(( compact_w < full_w && compact_h <= full_h )) || fail "the compact wordmark is smaller than the full one" "$compact_w×$compact_h vs $full_w×$full_h"
pass "the compact wordmark is smaller than the full one"
(( small_w < compact_w && small_h < icon_h )) || fail "the small mark is smaller than the compact wordmark and the About icon" "$small_w×$small_h vs compact $compact_w icon $icon_h"
pass "the small mark is smaller than the compact wordmark and the About icon"

# 80-column terminals are the ones the huge About icon broke: padding + 54-column
# modules leave this much for the logo, and the small mark has to fit in it.
room=$(( 80 - config_left - config_right - 54 ))
(( small_w <= room )) || fail "the small mark fits beside the modules in 80 columns" "logo $small_w, room $room"
pass "the small mark fits beside the modules in 80 columns"

export OMARCHY_PATH="$ROOT"
export PATH="$ROOT/bin:$PATH"
export NO_COLOR=1

run_logo() {
  COLUMNS=$1 LINES=$2 omarchy-fastfetch-logo
}

wide=$(run_logo 160 40)
[[ $wide == *"▄███████████▄"* ]] || fail "a wide terminal gets the full wordmark" "$wide"
pass "a wide terminal gets the full wordmark"

medium=$(run_logo 120 40)
[[ $medium == *"▄█████▄"* && $medium != *"▄███████████▄"* ]] || fail "a medium terminal gets the compact wordmark" "$medium"
pass "a medium terminal gets the compact wordmark"

tight=$(run_logo 80 24)
[[ $tight == *"██████████████"* && $tight != *"▄█████▄"* ]] || fail "an 80-column terminal gets the compact O" "$tight"
pass "an 80-column terminal gets the compact O"

# Hide the logo when none fits beside the actual module box.
narrow=$(run_logo 40 12)
[[ -z $narrow ]] || fail "a terminal too small for any mark suppresses the logo" "$narrow"
[[ $(COLUMNS=64 LINES=24 omarchy-fastfetch-logo --path) == "$ROOT/default/fastfetch/logo-none.txt" ]] || fail "narrow file selection must suppress the logo"
pass "a terminal too small for any mark suppresses the logo"

# Packaged installs only ship share trees under /usr/share/omarchy (no etc/).
packaged_root=$(mktemp -d)
trap 'rm -rf "$packaged_root"' EXIT
mkdir -p "$packaged_root/default/fastfetch"
cp "$full" "$packaged_root/logo.txt"
cp "$compact" "$packaged_root/default/fastfetch/logo.txt"
cp "$small" "$packaged_root/default/fastfetch/logo-small.txt"
cp "$ROOT/default/fastfetch/logo-none.txt" "$packaged_root/default/fastfetch/logo-none.txt"
packaged_tight=$(OMARCHY_PATH="$packaged_root" COLUMNS=80 LINES=24 omarchy-fastfetch-logo)
[[ $packaged_tight == "$tight" ]] ||
  fail "a packaged layout still picks the compact O at 80 columns" "$packaged_tight"
pass "a packaged layout still picks the compact O at 80 columns"

[[ $wide == *$'\e'* || $medium == *$'\e'* || $tight == *$'\e'* ]] && fail "NO_COLOR leaves the wordmark uncoloured"
pass "NO_COLOR leaves the wordmark uncoloured"

unset NO_COLOR
coloured=$(COLUMNS=80 LINES=24 omarchy-fastfetch-logo)
[[ $coloured != *$'\e'* ]] || fail "redirected helper output must remain plain"
pass "redirected helper output remains plain without NO_COLOR"

for columns in 80 120 160; do
  normal=$(COLUMNS=$columns LINES=40 omarchy-fastfetch-logo --path)
  byte_locale=$(LC_ALL=C COLUMNS=$columns LINES=40 omarchy-fastfetch-logo --path)
  [[ $normal == "$byte_locale" ]] || fail "the C locale must select the same file"
done
pass "logo path selection is independent of the inherited locale"

require_command fastfetch
python3 "$ROOT/test/shell.d/fastfetch-render-check.py" "$ROOT" ||
  fail "native fastfetch preserves sizes and terminal color policy"
pass "native fastfetch preserves sizes and terminal color policy"
