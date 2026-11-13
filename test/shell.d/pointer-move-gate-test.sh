#!/bin/bash
# omarchy:exclusive
# Windows opening beside it in the pool make the compositor send the real pointer's position, which the menu takes as the click's first sample.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "pointer movement gate runtime test"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

cp "$SHELL_TEST_DIR/fixtures/pointer-move-gate/shell.qml" "$test_tmp/shell.qml"
ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"

output=$(timeout 15 quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "pointer movement gate runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "pointer movement gate runtime behavior is correct"
fi

pass "pointer movement gate runtime behavior is correct"

qml_fixture_scratch
trap 'rm -rf "$test_tmp"; qml_fixture_cleanup' EXIT
cat >"$QML_FIXTURE_TMP/menu.jsonc" <<'EOF'
{
  "one": {"label": "One", "action": "true"},
  "two": {"label": "Two"},
  "two.only": {"label": "Two Only", "action": "true"},
  "three": {"label": "Three"},
  "three.a": {"label": "Three A", "action": "true"},
  "three.b": {"label": "Three B", "action": "true"},
  "three.c": {"label": "Three C", "action": "true"}
}
EOF
MENU_FIXTURE_FILE="$QML_FIXTURE_TMP/menu.jsonc" \
  run_qml_fixture menu-pointer "a click into a submenu selects the row left under the pointer" Ui Commons
