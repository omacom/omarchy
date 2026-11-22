#!/bin/bash

# Regression coverage for #15548: sed ranges such as [a-z] use collation, so
# a private Turkish locale makes a saved "floating" read back as empty.
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command localedef
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/locales" "$stage/bin"
if ! localedef -i tr_TR -f UTF-8 "$stage/locales/tr_TR.UTF-8" 2>/dev/null; then
  skip "tr_TR locale data is not installed; skipping locale sed-range tests"
  exit 0
fi

printf 'mode = "floating"\n' >"$stage/probe.txt"
if [[ -n $(LOCPATH=$stage/locales LC_ALL=tr_TR.UTF-8 sed -n 's/.*mode = "\([a-z]*\)".*/\1/p' "$stage/probe.txt") ]]; then
  skip "this glibc does not expose the Turkish [a-z] collation case"
  exit 0
fi

run_tr() {
  LOCPATH=$stage/locales LC_ALL=tr_TR.UTF-8 HOME=$stage/home XDG_STATE_HOME=$stage/state \
    PATH="$stage/bin:$PATH" "$@"
}

cat >"$stage/bin/hyprctl" <<'SH'
#!/bin/bash
case "$1 ${2:-}" in
"workspaces -j") printf '[{"id":2,"tiledLayout":"dwindle"}]\n' ;;
"getoption general.layout") printf '{"str":"dwindle"}\n' ;;
*) exit 1 ;;
esac
SH
chmod +x "$stage/bin/hyprctl"

mkdir -p "$stage/state/omarchy/workspace-layouts"
printf 'return { mode = "floating" }\n' >"$stage/state/omarchy/workspace-layouts/2.lua"
[[ $(run_tr "$ROOT/bin/omarchy-hyprland-workspace-layout-current" 2) == floating ]] ||
  fail "layout-current reads a saved mode under tr_TR.UTF-8"
pass "layout-current reads a saved mode under tr_TR.UTF-8"

printf 'return { default = "scrolling" }\n' >"$stage/state/omarchy/workspace-layouts/default.lua"
[[ $(run_tr "$ROOT/bin/omarchy-hyprland-workspace-layout-default") == scrolling ]] ||
  fail "layout-default reads a saved default under tr_TR.UTF-8"
pass "layout-default reads a saved default under tr_TR.UTF-8"

mkdir -p "$stage/home/.local/state/omarchy/current"
printf 'nord-ikigai\n' >"$stage/home/.local/state/omarchy/current/theme.name"
[[ $(run_tr "$ROOT/bin/omarchy-theme-current") == "Nord Ikigai" ]] ||
  fail "theme-current capitalizes an i-bearing name under tr_TR.UTF-8"
pass "theme-current capitalizes an i-bearing name under tr_TR.UTF-8"

mkdir -p "$stage/home/.config/omarchy/themes/nord-ikigai" "$stage/omarchy/themes/tokyo-night"
listing=$(run_tr env OMARCHY_PATH="$stage/omarchy" "$ROOT/bin/omarchy-theme-list")
[[ $listing == *"Nord Ikigai"* && $listing == *"Tokyo Night"* ]] ||
  fail "theme-list capitalizes names under tr_TR.UTF-8" "$listing"
pass "theme-list capitalizes names under tr_TR.UTF-8"

mkdir -p "$stage/config/fontconfig/conf.d"
printf '<family>Noto Sans CJK JP</family>\n' >"$stage/config/fontconfig/conf.d/50-omarchy-input-method.conf"
[[ $(run_tr env XDG_CONFIG_HOME="$stage/config" "$ROOT/bin/omarchy-font-cjk") == jp ]] ||
  fail "font-cjk reads a saved variant under tr_TR.UTF-8"
pass "font-cjk reads a saved variant under tr_TR.UTF-8"

mkdir -p "$stage/home/.local/state/omarchy/workspace-layouts"
printf 'hl.workspace_rule({ workspace = "3", layout = "scrolling" })\n' >"$stage/home/.local/state/omarchy/workspace-layouts/3.lua"
run_tr env HOME="$stage/home" XDG_STATE_HOME= bash -c 'source "$1"' _ "$ROOT/migrations/1791698594.sh" >/dev/null
[[ $(<"$stage/home/.local/state/omarchy/workspace-layouts/3.lua") == 'o.workspace_mode({ workspace = "3", mode = "scrolling" })' ]] ||
  fail "workspace-mode migration converts scrolling under tr_TR.UTF-8"
pass "workspace-mode migration converts scrolling under tr_TR.UTF-8"
