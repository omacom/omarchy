#!/bin/bash

# Issue #15548: sed bracket ranges [a-z] and [A-Z] follow the locale's
# collation order, not ASCII, so under tr_TR.UTF-8 they do not match i/I and
# the helpers read back nothing (or miss a capitalization). Every command that
# parses an ASCII value with a range pins LC_ALL=C.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command localedef

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/locales"

if ! localedef -i tr_TR -f UTF-8 "$stage/locales/tr_TR.UTF-8" 2>/dev/null; then
  skip "tr_TR locale data is not installed; skipping the locale sed-range tests"
  exit 0
fi

# The whole point is the collation quirk; a glibc where [a-z] matches i under
# tr_TR cannot tell the fix from the bug, so there is nothing to hold against.
printf 'mode = "floating"\n' >"$stage/probe.txt"
if [[ -n $(LOCPATH=$stage/locales LC_ALL=tr_TR.UTF-8 sed -n 's/.*mode = "\([a-z]*\)".*/\1/p' "$stage/probe.txt") ]]; then
  skip "this glibc matches [a-z] under tr_TR.UTF-8; skipping the locale sed-range tests"
  exit 0
fi

run_tr() {
  LOCPATH=$stage/locales LC_ALL=tr_TR.UTF-8 HOME=$stage/home XDG_STATE_HOME=$stage/state "$@"
}

mkdir -p "$stage/state/omarchy/workspace-layouts"
printf 'return { mode = "floating" }\n' >"$stage/state/omarchy/workspace-layouts/2.lua"
mode=$(run_tr "$ROOT/bin/omarchy-hyprland-workspace-layout-current" 2)
[[ $mode == "floating" ]] ||
  fail "layout-current reads a saved mode under tr_TR.UTF-8" "expected: floating\nactual:   $mode"
pass "layout-current reads a saved mode under tr_TR.UTF-8"

printf 'return { default = "scrolling" }\n' >"$stage/state/omarchy/workspace-layouts/default.lua"
mode=$(run_tr "$ROOT/bin/omarchy-hyprland-workspace-layout-default")
[[ $mode == "scrolling" ]] ||
  fail "layout-default reads the saved default under tr_TR.UTF-8" "expected: scrolling\nactual:   $mode"
pass "layout-default reads the saved default under tr_TR.UTF-8"

mkdir -p "$stage/home/.local/state/omarchy/current"
printf 'nord-ikigai\n' >"$stage/home/.local/state/omarchy/current/theme.name"
name=$(run_tr env HOME="$stage/home" "$ROOT/bin/omarchy-theme-current")
[[ $name == "Nord Ikigai" ]] ||
  fail "theme-current capitalizes a theme named after i under tr_TR.UTF-8" "expected: Nord Ikigai\nactual:   $name"
pass "theme-current capitalizes a theme named after i under tr_TR.UTF-8"

mkdir -p "$stage/home/.config/omarchy/themes/nord-ikigai" "$stage/omarchy/themes/tokyo-night"
listing=$(run_tr env HOME="$stage/home" OMARCHY_PATH="$stage/omarchy" "$ROOT/bin/omarchy-theme-list")
[[ $listing == *"Nord Ikigai"* && $listing == *"Tokyo Night"* ]] ||
  fail "theme-list capitalizes theme names under tr_TR.UTF-8" "expected both: Nord Ikigai, Tokyo Night\nactual:   $listing"
pass "theme-list capitalizes theme names under tr_TR.UTF-8"

mkdir -p "$stage/config/fontconfig/conf.d"
printf '<?xml version="1.0"?>\n<fontconfig>\n<alias><family>monospace</family><accept><family>Noto Sans CJK JP</family></accept></alias>\n</fontconfig>\n' \
  >"$stage/config/fontconfig/conf.d/50-omarchy-input-method.conf"
variant=$(run_tr env XDG_CONFIG_HOME="$stage/config" "$ROOT/bin/omarchy-font-cjk")
[[ $variant == "jp" ]] ||
  fail "font-cjk reads back the variant under tr_TR.UTF-8" "expected: jp\nactual:   $variant"
pass "font-cjk reads back the variant under tr_TR.UTF-8"

mkdir -p "$stage/home/.local/state/omarchy/workspace-layouts"
printf 'hl.workspace_rule({ workspace = "3", layout = "scrolling" })\n' >"$stage/home/.local/state/omarchy/workspace-layouts/3.lua"
run_tr env HOME="$stage/home" XDG_STATE_HOME= bash -c 'source "$1"' _ "$ROOT/migrations/1791698594.sh" >/dev/null
saved=$(<"$stage/home/.local/state/omarchy/workspace-layouts/3.lua")
[[ $saved == 'o.workspace_mode({ workspace = "3", mode = "scrolling" })' ]] ||
  fail "the workspace-mode migration converts a layout named with an i under tr_TR.UTF-8" "expected: o.workspace_mode({ workspace = \"3\", mode = \"scrolling\" })\nactual:   $saved"
pass "the workspace-mode migration converts a layout named with an i under tr_TR.UTF-8"
