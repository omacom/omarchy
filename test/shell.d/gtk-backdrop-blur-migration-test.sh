#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1792376022.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

gtk_css="$test_dir/.config/gtk-4.0/gtk.css"
toggles_dir="$test_dir/.local/state/omarchy/toggles/hypr"
import="@import url(\"file://$ROOT/default/gtk/glass.css\");"

run_migration() {
  HOME="$test_dir" XDG_RUNTIME_DIR="$test_dir" XDG_STATE_HOME="" XDG_CONFIG_HOME="" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
}

# See-through windows get the backdrop blur once, beside the user's own CSS.
mkdir -p "${gtk_css%/*}"
printf 'label { color: red; }\n' >"$gtk_css"
run_migration
run_migration
grep -qxF "$import" "$gtk_css" || fail "see-through windows import the GTK backdrop blur" "$(cat "$gtk_css")"
(( $(grep -cF "$import" "$gtk_css") == 1 )) || fail "a second run does not import it twice" "$(cat "$gtk_css")"
grep -qx 'label { color: red; }' "$gtk_css" || fail "the user's own GTK CSS is kept"
pass "see-through windows import the GTK backdrop blur once, keeping the user's CSS"

# Opaque windows get none, and no gtk.css is made for them.
rm -rf "$test_dir/.config"
mkdir -p "$toggles_dir"
cp "$ROOT/default/hypr/toggles/window-opaque.lua" "$toggles_dir/"
run_migration
[[ ! -e $gtk_css ]] || fail "opaque windows get no GTK CSS" "$(cat "$gtk_css")"
pass "opaque windows get no GTK backdrop blur"
