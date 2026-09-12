#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command jq

migration="$ROOT/migrations/1787871792.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

plugin_spec="$ROOT/config/opencode/tui-plugins/omarchy-theme.ts"

fixture="$test_dir/fixture-opencode.json"
cat >"$fixture" <<'EOF'
{"$schema":"https://opencode.ai/theme.json","theme":{"primary":"#336699","secondary":"#00ffff","accent":"#336699","error":"#ff0000","warning":"#ffff00","success":"#00ff00","info":"#0000ff","text":"#ffffff","textMuted":"#111111","background":"#000000","backgroundPanel":"#0d0d0d","backgroundElement":"#171717","backgroundMenu":"#0f0f0f","border":"#2e2e2e","borderActive":"#111111","borderSubtle":"#1f1f1f"}}
EOF

run_migration() {
  HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    env -u XDG_CONFIG_HOME -u OPENCODE_CONFIG_DIR bash -euo pipefail "$migration" >/dev/null
}

# A stub standing in for omarchy-theme-refresh: records that it ran and
# produces the staged file a real refresh would generate.
mkdir -p "$test_dir/stubbin"
cat >"$test_dir/stubbin/omarchy-theme-refresh" <<EOF
#!/bin/bash
echo refreshed >>"$test_dir/refresh-log"
mkdir -p "\$HOME/.local/state/omarchy/current/theme"
cp "$fixture" "\$HOME/.local/state/omarchy/current/theme/opencode.json"
EOF
chmod +x "$test_dir/stubbin/omarchy-theme-refresh"

run_migration_with_refresh_stub() {
  HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/stubbin:$ROOT/bin:$PATH" \
    env -u XDG_CONFIG_HOME -u OPENCODE_CONFIG_DIR bash -euo pipefail "$migration" >/dev/null
}

stage_theme() {
  mkdir -p "$1/.local/state/omarchy/current/theme"
  cp "$fixture" "$1/.local/state/omarchy/current/theme/opencode.json"
}

# ------------------------------------------------------------------ no opencode config

rm -rf "$test_dir/home"
run_migration

[[ ! -e $test_dir/home/.config/opencode ]] || fail "migration creates an opencode config from nothing"
pass "migration skips installs without an opencode config"

# ------------------------------------------------------------------ existing tui.json

rm -rf "$test_dir/home"
mkdir -p "$test_dir/home/.config/opencode"
printf '{"theme":"tokyonight","keybinds":{"leader":"<c-b>"}}\n' >"$test_dir/home/.config/opencode/tui.json"
stage_theme "$test_dir/home"
run_migration

plugin="$test_dir/home/.config/opencode/tui-plugins/omarchy-theme.ts"
[[ -L $plugin ]] || fail "migration links the omarchy-theme plugin"
pass "migration links the omarchy-theme plugin"
[[ $(readlink "$plugin") == "$plugin_spec" ]] || fail "plugin link points at the shipped plugin"
pass "plugin link points at the shipped plugin"

jq -e --arg plugin "$plugin" \
  '.theme == "omarchy" and .keybinds.leader == "<c-b>" and (.plugin | index($plugin))' \
  "$test_dir/home/.config/opencode/tui.json" >/dev/null ||
  fail "migration registers the plugin, selects Omarchy, and preserves other tui.json settings"
pass "migration registers the plugin, selects Omarchy, and preserves other tui.json settings"

run_migration
[[ $(jq '.plugin | length' "$test_dir/home/.config/opencode/tui.json") == "1" ]] ||
  fail "migration does not register the plugin twice"
pass "migration is idempotent"

[[ -f $test_dir/home/.config/opencode/themes/omarchy.json ]] ||
  fail "migration syncs the current theme file"
pass "migration syncs the current theme file"

# ------------------------------------------------------------------ plugin order

rm -rf "$test_dir/home"
mkdir -p "$test_dir/home/.config/opencode"
printf '{"theme":"tokyonight","plugin":["first.ts","second.ts"]}\n' >"$test_dir/home/.config/opencode/tui.json"
run_migration

jq -e --arg plugin "$plugin" '.plugin == ["first.ts", "second.ts", $plugin]' \
  "$test_dir/home/.config/opencode/tui.json" >/dev/null ||
  fail "migration appends the plugin without rewriting existing order"
pass "migration appends the plugin without rewriting existing order"

# ------------------------------------------------------------------ no tui.json

rm -rf "$test_dir/home"
mkdir -p "$test_dir/home/.config/opencode"
stage_theme "$test_dir/home"
run_migration

jq -e --arg plugin "$test_dir/home/.config/opencode/tui-plugins/omarchy-theme.ts" \
  '.theme == "omarchy" and .plugin == [$plugin]' \
  "$test_dir/home/.config/opencode/tui.json" >/dev/null ||
  fail "migration creates a tui.json that selects Omarchy when absent"
pass "migration creates a tui.json that selects Omarchy when absent"

# ------------------------------------------------------------------ XDG_CONFIG_HOME

rm -rf "$test_dir/home"
mkdir -p "$test_dir/home/xdg/opencode"
printf '{"theme":"tokyonight"}\n' >"$test_dir/home/xdg/opencode/tui.json"
HOME="$test_dir/home" XDG_CONFIG_HOME="$test_dir/home/xdg" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  env -u OPENCODE_CONFIG_DIR bash -euo pipefail "$migration" >/dev/null

[[ -L $test_dir/home/xdg/opencode/tui-plugins/omarchy-theme.ts ]] ||
  fail "migration follows XDG_CONFIG_HOME for the plugin"
[[ ! -e $test_dir/home/.config/opencode ]] ||
  fail "migration ignores the default tree when XDG_CONFIG_HOME is set"
pass "migration follows XDG_CONFIG_HOME"
jq -e --arg plugin "$test_dir/home/xdg/opencode/tui-plugins/omarchy-theme.ts" \
  '.plugin | index($plugin)' "$test_dir/home/xdg/opencode/tui.json" >/dev/null
pass "migration registers the plugin in the XDG tree"

# ------------------------------------------- stale staged theme

rm -rf "$test_dir/home" "$test_dir/refresh-log"
mkdir -p "$test_dir/home/.config/opencode" "$test_dir/home/.config/omarchy/themes/sandbox-theme" \
  "$test_dir/home/.local/state/omarchy/current/theme"
printf 'sandbox-theme\n' >"$test_dir/home/.local/state/omarchy/current/theme.name"
run_migration_with_refresh_stub

[[ -f $test_dir/refresh-log ]] || fail "migration re-stages a theme predating opencode.json"
pass "migration re-stages a theme predating opencode.json"
cmp -s "$fixture" "$test_dir/home/.config/opencode/themes/omarchy.json" ||
  fail "migration syncs the re-staged theme file"
pass "migration syncs the re-staged theme file"

# ------------------------------------------- fresh staged theme

rm -rf "$test_dir/home" "$test_dir/refresh-log"
mkdir -p "$test_dir/home/.config/opencode" "$test_dir/home/.config/omarchy/themes/sandbox-theme"
stage_theme "$test_dir/home"
printf 'sandbox-theme\n' >"$test_dir/home/.local/state/omarchy/current/theme.name"
run_migration_with_refresh_stub

[[ ! -e $test_dir/refresh-log ]] || fail "migration re-stages a theme that already ships opencode.json"
pass "migration skips re-staging a current theme"

# ------------------------------------------- removed theme

rm -rf "$test_dir/home" "$test_dir/refresh-log"
mkdir -p "$test_dir/home/.config/opencode" "$test_dir/home/.local/state/omarchy/current/theme"
printf 'gone-theme\n' >"$test_dir/home/.local/state/omarchy/current/theme.name"
run_migration_with_refresh_stub

[[ ! -e $test_dir/refresh-log ]] || fail "migration refreshes a theme that no longer exists"
[[ ! -e $test_dir/home/.config/opencode/themes/omarchy.json ]] ||
  fail "migration syncs a theme that no longer exists"
pass "migration leaves a removed theme alone"
