#!/bin/bash

# The per-monitor workspace change keeps an existing global numbering when a
# workspace rule or an older cloned indicator still depends on it.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration=$(grep -l "older workspace indicator still uses those numbers" "$ROOT"/migrations/*.sh)
[[ -n $migration ]] || fail "global workspace migration is missing"

run_migration() {
  local test_home="$1"
  (
    cd "$test_home"
    env -i \
      HOME="$test_home" \
      XDG_CONFIG_HOME="$test_home/.config" \
      XDG_STATE_HOME="$test_home/.local/state" \
      OMARCHY_PATH="$ROOT" \
      PATH="/usr/bin:/bin" \
      bash -euo pipefail "$migration"
  )
}

new_home() {
  local test_home="$test_tmp/$1"
  mkdir -p "$test_home/.config/hypr" "$test_home/.local/state"
  printf '%s\n' \
    '-- Load Omarchy defaults.' \
    'require("default.hypr.omarchy")' \
    '' \
    '-- Personal configuration.' \
    >"$test_home/.config/hypr/hyprland.lua"
  echo "$test_home"
}

flag_count() {
  grep -cE '^omarchy_global_workspaces = true$' "$1/.config/hypr/hyprland.lua"
}

home=$(new_home pinned)
cat >"$home/.config/hypr/monitors.lua" <<'LUA'
hl.workspace_rule({
  workspace = "4",
  monitor = "desc:Dell Inc. DELL U2723QE",
})
hl.workspace_rule({ workspace = "5", monitor = "desc:Dell Inc. DELL U2723QE" })
hl.workspace_rule({ workspace = "6", monitor = "desc:Dell Inc. DELL U2723QE" })
LUA
run_migration "$home" >/dev/null
[[ $(flag_count "$home") == 1 ]] || fail "migration turns global workspaces on for pinned numbers"
grep -q "saved layouts stay with them" "$home/.config/hypr/hyprland.lua" || fail "migration tells the user what was preserved"
grep -q "Set this to false" "$home/.config/hypr/hyprland.lua" || fail "migration tells the user how to opt out"
# The flag has to be set before the defaults load.
flag_line=$(grep -n '^omarchy_global_workspaces = true$' "$home/.config/hypr/hyprland.lua" | cut -d: -f1)
require_line=$(grep -n 'require("default.hypr.omarchy")' "$home/.config/hypr/hyprland.lua" | cut -d: -f1)
(( flag_line < require_line )) || fail "migration sets the flag after the defaults load"
[[ $(cat "$home/.local/state/omarchy/monitors/global-workspaces") == "1" ]] || fail "migration tells the bar to keep global numbers"
grep -q 'Personal configuration.' "$home/.config/hypr/hyprland.lua" || fail "migration rewrote the rest of hyprland.lua"
run_migration "$home" >/dev/null
[[ $(flag_count "$home") == 1 ]] || fail "migration inserts the flag again"
pass "migration keeps pinned global workspaces and is idempotent"

opted=$(new_home opted-out)
printf '\n%s\n' 'omarchy_global_workspaces = false' >>"$opted/.config/hypr/hyprland.lua"
cat >"$opted/.config/hypr/monitors.lua" <<'LUA'
hl.workspace_rule({ workspace = "4", monitor = "DP-1" })
LUA
run_migration "$opted" >/dev/null
[[ $(grep -c 'omarchy_global_workspaces' "$opted/.config/hypr/hyprland.lua") == 1 ]] || fail "migration overrides an explicit opt-out"
[[ ! -e $opted/.local/state/omarchy/monitors/global-workspaces ]] || fail "migration writes the bar flag after an opt-out"
pass "migration leaves an explicit opt-out alone"

block=$(new_home block)
cat >"$block/.config/hypr/hyprland.lua" <<'LUA'
require("default.hypr.omarchy")
hl.workspace_rule({ workspace = "21", monitor = "DP-5" })
LUA
printf '%s\n' 'hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })' >>"$block/.config/hypr/monitors.lua"
run_migration "$block" >/dev/null
grep -q 'omarchy_global_workspaces' "$block/.config/hypr/hyprland.lua" && fail "migration treats block numbers or laptop workspace 1 as the old workflow"
pass "migration leaves per-monitor block numbers and a laptop default alone"

commented=$(new_home commented)
printf '%s\n' '-- hl.workspace_rule({ workspace = "4", monitor = "DP-1" })' >>"$commented/.config/hypr/hyprland.lua"
run_migration "$commented" >/dev/null
grep -q '^omarchy_global_workspaces = true$' "$commented/.config/hypr/hyprland.lua" && fail "migration follows a commented-out rule"
pass "migration ignores a workspace rule that is commented out"

clone=$(new_home clone)
mkdir -p "$clone/.config/omarchy/plugins/me.workspaces"
cat >"$clone/.config/omarchy/plugins/me.workspaces/manifest.json" <<'JSON'
{
  "omarchy": {
    "clonedFrom": "omarchy.workspaces"
  }
}
JSON
cat >"$clone/.config/omarchy/plugins/me.workspaces/Workspaces.qml" <<'QML'
readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
text: focused ? glyph : (modelData === 10 ? "0" : String(modelData))
QML
run_migration "$clone" >/dev/null
[[ $(flag_count "$clone") == 1 ]] || fail "migration keeps numbers for an older cloned indicator"
pass "migration keeps numbers for an older cloned workspace indicator"

updated=$(new_home updated-clone)
mkdir -p "$updated/.config/omarchy/plugins/me.workspaces"
cat >"$updated/.config/omarchy/plugins/me.workspaces/manifest.json" <<'JSON'
{ "omarchy": { "clonedFrom": "omarchy.workspaces" } }
JSON
cat >"$updated/.config/omarchy/plugins/me.workspaces/Workspaces.qml" <<'QML'
readonly property bool shown: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
function slotOf(id) { return id }
text: String(slot)
QML
run_migration "$updated" >/dev/null
grep -q '^omarchy_global_workspaces = true$' "$updated/.config/hypr/hyprland.lua" && fail "migration rewrites a clone that already uses slots"
pass "migration leaves a slot-based workspace clone on per-monitor numbers"

missing=$(new_home missing)
rm "$missing/.config/hypr/hyprland.lua"
run_migration "$missing" >/dev/null || fail "migration fails when hyprland.lua is absent"
pass "migration does nothing when there is no hyprland config"
