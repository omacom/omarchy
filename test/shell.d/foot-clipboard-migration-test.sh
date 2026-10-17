#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration=$(ls "$ROOT"/migrations/*.sh | xargs -n1 basename | sort -n | while read -r name; do
  if grep -q 'Add Ctrl+Shift clipboard chords to existing Foot configs' "$ROOT/migrations/$name"; then
    echo "$name"
    break
  fi
done)

[[ -n $migration ]] || fail "foot clipboard migration exists"
pass "foot clipboard migration exists"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/.config/foot"
export HOME="$tmp"
export OMARCHY_PATH="$ROOT"

cat >"$tmp/.config/foot/foot.ini" <<'INI'
[key-bindings]
clipboard-copy=Control+Insert
primary-paste=none
clipboard-paste=Shift+Insert
INI

bash -euo pipefail "$ROOT/migrations/$migration"

grep -qxF 'clipboard-copy=Control+Insert Control+Shift+c' "$tmp/.config/foot/foot.ini" ||
  fail "migration adds Control+Shift+c to clipboard-copy" "$(cat "$tmp/.config/foot/foot.ini")"
pass "migration adds Control+Shift+c to clipboard-copy"

grep -qxF 'clipboard-paste=Shift+Insert Control+Shift+v' "$tmp/.config/foot/foot.ini" ||
  fail "migration adds Control+Shift+v to clipboard-paste" "$(cat "$tmp/.config/foot/foot.ini")"
pass "migration adds Control+Shift+v to clipboard-paste"

bash -euo pipefail "$ROOT/migrations/$migration"

grep -c 'Control+Shift+c' "$tmp/.config/foot/foot.ini" | grep -qx 1 ||
  fail "migration is idempotent for clipboard-copy"
pass "migration is idempotent for clipboard-copy"

# Already-complete configs are left alone.
cat >"$tmp/.config/foot/foot.ini" <<'INI'
[key-bindings]
clipboard-copy=Control+Insert Control+Shift+c XF86Copy
primary-paste=none
clipboard-paste=Shift+Insert Control+Shift+v XF86Paste
INI

before=$(cat "$tmp/.config/foot/foot.ini")
bash -euo pipefail "$ROOT/migrations/$migration"
after=$(cat "$tmp/.config/foot/foot.ini")
[[ $before == "$after" ]] || fail "migration leaves complete foot configs unchanged"
pass "migration leaves complete foot configs unchanged"
