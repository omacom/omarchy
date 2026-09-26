#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

lock_view="$ROOT/shell/plugins/lock/LockView.qml"
[[ -f $lock_view ]] || fail "LockView.qml is present"

# Qt TextInput.Password falls back to plaintext when passwordCharacter is not
# in the active font. Monospace Nerd Fonts often lack U+25CF.
grep -Eq 'passwordCharacter:[[:space:]]*"\*"' "$lock_view" ||
  fail "lock password mask uses ASCII asterisk" "$(grep passwordCharacter "$lock_view" || true)"

! grep -Eq 'passwordCharacter:[[:space:]]*"(\\u25CF|●)"' "$lock_view" ||
  fail "lock password mask must not use U+25CF"

grep -Eq 'echoMode:[[:space:]]*TextInput\.Password' "$lock_view" ||
  fail "lock password field stays in Password echo mode"

grep -Eq 'passwordMaskDelay:[[:space:]]*0' "$lock_view" ||
  fail "lock password masks immediately (no plaintext flash)"

pass "lock password mask stays in-font so Qt cannot reveal plaintext"
