#!/bin/bash
# Which recipes the backend reads: the refreshed catalog when it is newer than the bundled recipes.json, the bundled
# one when there is no catalog or the plugin was updated after the last refresh.
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
PANEL=$TMP/panel
mkdir -p "$PANEL" "$TMP/cache"
echo bundled >"$PANEL/recipes.json"
pick() {
  eval "$(grep -E '^(CATALOG|RECIPES)=|^\[\[ .*CATALOG' "$ROOT/bin/omarchy-local-ai" | sed "s|/var/cache/omarchy-local-ai|$TMP/cache|")"
  cat "$RECIPES"
}
[[ $(pick) == bundled ]] || fail "local-ai no catalog"
echo refreshed >"$TMP/cache/recipes.json"
touch -d '1 minute ago' "$PANEL/recipes.json"
[[ $(pick) == refreshed ]] || fail "local-ai a refresh after the install"
touch "$PANEL/recipes.json"
touch -d '1 minute ago' "$TMP/cache/recipes.json"
[[ $(pick) == bundled ]] || fail "local-ai an update after the last refresh"
pass "local-ai a refreshed catalog is read until an update brings newer recipes"
