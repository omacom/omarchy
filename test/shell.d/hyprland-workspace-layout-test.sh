#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
log_file="$tmpdir/hyprctl.log"
mkdir -p "$stub_dir" "$home_dir"

cat >"$stub_dir/hyprctl" <<'STUB'
#!/bin/bash

if [[ $1 == "activeworkspace" && -n $HYPRCTL_BROKEN ]]; then
  printf '{}\n'
elif [[ $1 == "activeworkspace" && -n $HYPRCTL_NAMED ]]; then
  printf '{"id":-1340,"name":"my-project","tiledLayout":"dwindle"}\n'
elif [[ $1 == "activeworkspace" ]]; then
  printf '{"id":3,"name":"3","tiledLayout":"dwindle"}\n'
else
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
fi
STUB
chmod +x "$stub_dir/hyprctl"

cat >"$stub_dir/omarchy-notification-send" <<'STUB'
#!/bin/bash
:
STUB
chmod +x "$stub_dir/omarchy-notification-send"

HOME="$home_dir" HYPRCTL_LOG="$log_file" PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle"

layout_file="$home_dir/.local/state/omarchy/workspace-layouts/3.lua"
[[ -f $layout_file ]] || fail "workspace layout toggle saves a workspace rule"
grep -Fx 'hl.workspace_rule({ workspace = "3", layout = "scrolling" })' "$layout_file" >/dev/null ||
  fail "workspace layout toggle saves the selected layout"
grep -Fx 'eval hl.workspace_rule({ workspace = "3", layout = "scrolling" })' "$log_file" >/dev/null ||
  fail "workspace layout toggle applies the selected layout immediately"
! grep -E 'keyword workspace' "$log_file" >/dev/null ||
  fail "workspace layout toggle does not use hyprctl keyword fallback"
pass "workspace layout toggle persists and applies the selected layout"

: >"$log_file"
HOME="$home_dir" HYPRCTL_LOG="$log_file" HYPRCTL_NAMED=1 PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle"

named_layout_file="$home_dir/.local/state/omarchy/workspace-layouts/name:my-project.lua"
[[ -f $named_layout_file ]] || fail "workspace layout toggle saves a named-workspace rule"
grep -Fx 'hl.workspace_rule({ workspace = "name:my-project", layout = "scrolling" })' "$named_layout_file" >/dev/null ||
  fail "workspace layout toggle keys named workspaces with name: selector"
grep -Fx 'eval hl.workspace_rule({ workspace = "name:my-project", layout = "scrolling" })' "$log_file" >/dev/null ||
  fail "workspace layout toggle applies named-workspace layout with name: selector"
! grep -E 'workspace = "-1340"|workspace "-1340' "$log_file" >/dev/null ||
  fail "workspace layout toggle does not use negative workspace ids as selectors"
! grep -E 'workspace = "-1340"' "$named_layout_file" >/dev/null ||
  fail "workspace layout toggle does not persist negative workspace ids as selectors"
[[ -f "$home_dir/.local/state/omarchy/workspace-layouts/-1340.lua" ]] &&
  fail "workspace layout toggle does not persist rules under negative workspace ids"
pass "workspace layout toggle uses name: selector for named workspaces"

if HOME="$home_dir" HYPRCTL_LOG="$log_file" HYPRCTL_BROKEN=1 PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle" 2>/dev/null; then
  fail "workspace layout toggle exits nonzero without a workspace id"
fi
[[ -f "$home_dir/.local/state/omarchy/workspace-layouts/null.lua" ]] &&
  fail "workspace layout toggle does not persist a rule without a workspace id"
[[ -f "$home_dir/.local/state/omarchy/workspace-layouts/name:null.lua" ]] &&
  fail "workspace layout toggle does not persist a name:null rule without a workspace id"
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

local by_workspace = {}
for _, rule in ipairs(rules) do
  by_workspace[rule.workspace] = rule.layout
end

assert(by_workspace["3"] == "scrolling")
assert(by_workspace["name:my-project"] == "scrolling")
assert(by_workspace["-1340"] == nil)
LUA
pass "saved workspace layouts load into Hyprland configuration"
