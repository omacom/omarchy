#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

PATH="$ROOT/bin:$PATH"
source "$ROOT/default/bash/completions"

complete_words() {
  COMP_WORDS=("$@")
  COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
  _omarchy_complete
  echo "${COMPREPLY[*]}"
}

# `[--set <name> [lat,lon] | --clear]` is optional as a whole, so completion
# offers both alternatives without the brackets.
[[ $(complete_words omarchy weather location "") == "--set --clear" ]] || fail "completion offers the alternatives inside an optional args line"
pass "completion offers the alternatives inside an optional args line"

[[ $(complete_words omarchy weather location --cl) == "--clear" ]] || fail "completion completes --clear without a trailing bracket"
pass "completion completes --clear without a trailing bracket"

# A single optional placeholder is not a word to offer.
[[ -z $(complete_words omarchy audio output sink "") ]] || fail "completion does not offer an optional placeholder"
pass "completion does not offer an optional placeholder"

# The same optional args must not make the router demand arguments.
mkdir -p "$test_tmp/.local/state/omarchy/settings"
printf '{"name": "Malibu"}\n' >"$test_tmp/.local/state/omarchy/settings/weather.json"
[[ $(HOME="$test_tmp" "$ROOT/bin/omarchy" weather location) == "Malibu" ]] || fail "omarchy weather location with no args shows the saved location"
pass "omarchy weather location with no args shows the saved location"
