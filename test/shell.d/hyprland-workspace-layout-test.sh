#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
log_file="$tmpdir/hyprctl.log"
mkdir -p "$stub_dir" "$home_dir"

cat >"$stub_dir/hyprctl" <<'EOF'
#!/bin/bash

if [[ $1 == "monitors" && -n $HYPRCTL_SPECIAL ]]; then
  printf '[{"focused":true,"specialWorkspace":{"id":-97,"name":"%s"}}]\n' "$HYPRCTL_SPECIAL"
elif [[ $1 == "workspaces" && -n $HYPRCTL_SPECIAL ]]; then
  printf '[{"id":3,"name":"3","tiledLayout":"scrolling"},{"id":-97,"name":"%s","tiledLayout":"dwindle"}]\n' "$HYPRCTL_SPECIAL"
elif [[ $1 == "activeworkspace" && -n $HYPRCTL_BROKEN ]]; then
  printf '{}\n'
elif [[ $1 == "activeworkspace" ]]; then
  printf '{"id":3,"tiledLayout":"dwindle"}\n'
else
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
fi
EOF
chmod +x "$stub_dir/hyprctl"

cat >"$stub_dir/omarchy-notification-send" <<'EOF'
#!/bin/bash
:
EOF
chmod +x "$stub_dir/omarchy-notification-send"

HOME="$home_dir" HYPRCTL_LOG="$log_file" PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle"

layout_file="$home_dir/.local/state/omarchy/workspace-layouts/3.lua"
[[ -f $layout_file ]] || fail "workspace layout toggle saves a workspace rule"
grep -Fx 'hl.workspace_rule({ workspace = "3", layout = "scrolling" })' "$layout_file" >/dev/null ||
  fail "workspace layout toggle saves the selected layout"
grep -Fx 'eval hl.workspace_rule({ workspace = "3", layout = "scrolling" })' "$log_file" >/dev/null ||
  fail "workspace layout toggle applies the selected layout immediately"
pass "workspace layout toggle persists and applies the selected layout"

if HOME="$home_dir" HYPRCTL_LOG="$log_file" HYPRCTL_BROKEN=1 PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle" 2>/dev/null; then
  fail "workspace layout toggle exits nonzero without a workspace id"
fi
[[ -f "$home_dir/.local/state/omarchy/workspace-layouts/null.lua" ]] &&
  fail "workspace layout toggle does not persist a rule without a workspace id"
pass "workspace layout toggle ignores broken hyprctl output"

HOME="$home_dir" OMARCHY_PATH="$ROOT" lua <<'LUA'
local rules = {}

hl = {
  workspace_rule = function(rule)
    table.insert(rules, rule)
  end,
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.workspace-layouts")

assert(#rules == 1)
assert(rules[1].workspace == "3")
assert(rules[1].layout == "scrolling")
LUA
pass "saved workspace layouts load into Hyprland configuration"

special_home="$tmpdir/special-home"
mkdir -p "$special_home"
HOME="$special_home" HYPRCTL_LOG="$log_file" HYPRCTL_SPECIAL="special:my.pad" PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle"

special_file="$special_home/.local/state/omarchy/workspace-layouts/special_my_pad.lua"
[[ -f $special_file ]] || fail "workspace layout toggle saves an open special workspace under a module-safe name"
grep -Fx 'hl.workspace_rule({ workspace = "special:my.pad", layout = "scrolling" })' "$special_file" >/dev/null ||
  fail "workspace layout toggle toggles the open special workspace, not the one under it"
grep -Fx 'eval hl.workspace_rule({ workspace = "special:my.pad", layout = "scrolling" })' "$log_file" >/dev/null ||
  fail "workspace layout toggle applies the special workspace layout immediately"
pass "workspace layout toggle targets an open special workspace"

HOME="$special_home" OMARCHY_PATH="$ROOT" lua - <<'LUA' ||
local rules = {}

hl = {
  workspace_rule = function(rule)
    table.insert(rules, rule)
  end,
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.workspace-layouts")

assert(#rules == 1)
assert(rules[1].workspace == "special:my.pad")
assert(rules[1].layout == "scrolling")
LUA
  fail "saved special workspace layouts load into Hyprland configuration"
pass "saved special workspace layouts load into Hyprland configuration"
