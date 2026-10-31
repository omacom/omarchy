#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1792478700.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
layout_file="$test_tmp/button-layout"
cat >"$test_tmp/bin/gsettings" <<'SH'
#!/bin/bash
[[ $2 == "org.gnome.desktop.wm.preferences" && $3 == "button-layout" ]] || exit 1
case "$1" in
  get) printf "'%s'\n" "$(cat "$LAYOUT_FILE")" ;;
  set) printf '%s' "$4" >"$LAYOUT_FILE" ;;
  *) exit 1 ;;
esac
SH
chmod +x "$test_tmp/bin/gsettings"

run_migration() {
  printf '%s' "$1" >"$layout_file"
  LAYOUT_FILE="$layout_file" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
  LAYOUT_FILE="$layout_file" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
  cat "$layout_file"
}

[[ $(run_migration "appmenu:close") == "appmenu:" ]] ||
  fail "the migration hides the close button from GNOME's stock layout"
pass "the migration hides the close button from GNOME's stock layout and can run twice"

[[ $(run_migration ":minimize,maximize,close") == ":minimize,maximize,close" ]] ||
  fail "the migration keeps a layout the user picked"
pass "the migration keeps a layout the user picked"

[[ $(run_migration "appmenu:") == "appmenu:" ]] ||
  fail "the migration leaves an already hidden close button alone"
pass "the migration leaves an already hidden close button alone"
