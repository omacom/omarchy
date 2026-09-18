#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp
export OMARCHY_PATH=$ROOT
export PATH="$ROOT/bin:$PATH"

mkdir -p "$HOME/.local/state/omarchy/current/theme"
ln -sfn "$ROOT/themes/tokyo-night/colors.toml" "$HOME/.local/state/omarchy/current/theme/colors.toml"

out=$(omarchy-show-logo)
printf '%s\n' "$out" | grep -q $'\033\[38;2;171;190;245m' ||
  fail "the crest rows use the theme crest colour"
pass "the crest rows use the theme crest colour"

# tokyo-night lit is #7aa2f7
printf '%s\n' "$out" | grep -q $'\033\[38;2;122;162;247m' ||
  fail "a later row uses theme lit"
pass "a later row uses theme lit"

mapfile -t painted < <(printf '%s\n' "$out" | grep $'\033\[38;2;')
(( ${#painted[@]} >= 10 )) || fail "every logo line is coloured" "${#painted[@]} lines"
pass "every logo line is coloured"
