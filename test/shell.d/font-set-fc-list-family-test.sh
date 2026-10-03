#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

font_set="$ROOT/bin/omarchy-font-set"

grep -Fq 'fc-list ":family=$font_name"' "$font_set" ||
  fail "font-set asks fontconfig for that family instead of dumping every face"
! grep -Eq '^if ! fc-list \| grep' "$font_set" ||
  fail "font-set no longer greps the full fc-list dump"

# The kitty harness stubs fc-list as a one-line printer that ignores arguments,
# so a family filter still has to be grepped for the name the user typed.
grep -Fq 'grep -Fqi -- "$font_name"' "$font_set" ||
  fail "font-set still checks the family string after the fontconfig filter"
pass "font-set looks up a family instead of scanning every installed font"
