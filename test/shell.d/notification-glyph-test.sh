#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# omarchy-notification-send takes its glyph as -g's argument. When an edit
# strips the glyph (multi-byte icons are easy to lose), -g swallows whatever
# follows instead: the next option (`-g -u low`) or the message itself, so the
# notification shows the wrong headline. Every literal -g in bin/ must be
# followed by an actual glyph or a variable holding one.
bad=$(grep -nE 'omarchy-notification-send[^#]*[[:space:]]-g([[:space:]]+(-|"\$\(omarchy-i18n|"[A-Za-z])|[[:space:]]*$)' "$ROOT"/bin/* || true)
[[ -z $bad ]] || fail "every notification -g carries a glyph" "$bad"
pass "every notification -g carries a glyph"
