#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

shell_catalog="$ROOT/default/i18n/en/shell.json"
menu_catalog="$ROOT/default/i18n/en/menu.json"
plugins=("$ROOT"/shell/plugins/lock/* "$ROOT"/shell/plugins/polkit/*)

# The face's words live in the English catalog like every other string the
# shell shows; translations follow through upstream's sync.
mapfile -t referenced < <(grep -ohE '(I18n\.t|[^a-zA-Z_.]t)\("[a-z][a-zA-Z0-9]*(\.[a-zA-Z0-9]+)+"' "${plugins[@]}" |
  sed -E 's/.*\("//; s/"$//' | grep -i face | sort -u)
(( ${#referenced[@]} >= 10 )) || fail "the lock and polkit plugins name their face strings by catalog key" "${referenced[*]}"
for key in "${referenced[@]}"; do
  jq -e --arg key "$key" 'has($key) and (.[$key] | type == "string" and length > 0)' "$shell_catalog" >/dev/null ||
    fail "the English shell catalog defines $key"
done
mapfile -t cataloged < <(jq -r 'keys[] | select(test("face"; "i"))' "$shell_catalog")
for key in "${cataloged[@]}"; do
  printf '%s\n' "${referenced[@]}" | grep -qxF "$key" || fail "the face key $key is shown somewhere"
done
pass "every face string the lock and polkit show comes from the English catalog, and every face key is used"

for key in "${cataloged[@]}"; do
  english=$(jq -r --arg key "$key" '.[$key]' "$shell_catalog")
  ! grep -hv '^[[:space:]]*//' "$ROOT"/shell/plugins/lock/*.qml "$ROOT"/shell/plugins/polkit/*.qml | grep -qF "\"$english\"" ||
    fail "the QML shows \"$english\" through its key $key, never as a literal"
done
pass "no face string is written into the QML as English"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
entries=$(grep -v '^[[:space:]]*//' "$menu" | sed -E ':a;N;$!ba;s/,([[:space:]]*[]}])/\1/g')
for id in setup.security.face remove.security.face; do
  [[ $(jq -r --arg id "$id" '.[$id].label' "$menu_catalog") == "$(jq -r --arg id "$id" '.[$id].label' <<<"$entries")" ]] ||
    fail "the English menu catalog mirrors the $id row"
done
pass "the English menu catalog mirrors the face rows"
