#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp
export OMARCHY_PATH=$ROOT
export PATH="$ROOT/bin:$PATH"

mkdir -p "$HOME/.local/state/omarchy/current/theme"
ln -sfn "$ROOT/themes/tokyo-night/colors.toml" "$HOME/.local/state/omarchy/current/theme/colors.toml"

out=$(omarchy-show-logo)
mapfile -t painted < <(printf '%s\n' "$out" | grep $'\033\[38;2;')
# 10-line FIGlet, 4-3-4-3-5 scaled to 2-2-2-1-3: crest, crest, hover, hover, lit, lit, mid, dim, dim, dim.
[[ ${painted[0]} == *$'\033[38;2;171;190;245m'* ]] ||
  fail "the first row is crest" "$(printf '%q' "${painted[0]}")"
[[ ${painted[1]} == *$'\033[38;2;171;190;245m'* ]] ||
  fail "the second row is crest" "$(printf '%q' "${painted[1]}")"
[[ ${painted[6]} == *$'\033[38;2;95;125;190m'* ]] ||
  fail "the seventh row is mid" "$(printf '%q' "${painted[6]}")"
[[ ${painted[7]} == *$'\033[38;2;68;88;133m'* ]] ||
  fail "the eighth row is dim" "$(printf '%q' "${painted[7]}")"
pass "logo rows follow 2-2-2-1-3"
(( ${#painted[@]} == 10 )) || fail "every logo line is coloured" "${#painted[@]} lines"
pass "every logo line is coloured"
