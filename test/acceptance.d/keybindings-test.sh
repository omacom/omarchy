#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
config="$HOME/.config/hypr/hyprland.lua"
cp "$config" "$test_dir/hyprland.lua"
menu_pid=""
cleanup() {
  omarchy-shell shell hide omarchy.menu >/dev/null 2>&1 || true
  if [[ -n $menu_pid ]]; then kill "$menu_pid" 2>/dev/null || true; fi
  cp "$test_dir/hyprland.lua" "$config"
  hyprctl reload >/dev/null
  rm -rf "$test_dir"
}
trap cleanup EXIT

cat >"$test_dir/fixture.lua" <<LUA
-- These are normal runtime queries, and used to hang the menu's fake objects.
for _, monitor in ipairs(hl.get_monitors()) do end
for _, workspace in ipairs(hl.get_workspaces()) do end
for _, window in ipairs(hl.get_windows()) do end
local loads = assert(io.open("$test_dir/loads", "a"))
loads:write("loaded\\n")
loads:close()
local secret = "captured-local"
local function record(value)
  local file = assert(io.open("$test_dir/actions", "a"))
  file:write(value .. "\\n")
  file:close()
end
qa_keybindings = {}
qa_keybindings.closure = hl.bind("SUPER + F12", function() record(secret) end, { description = "QA retained closure" })
qa_keybindings.native = hl.bind("SUPER + F11", hl.dsp.exec_cmd("printf 'native\\n' >> '$test_dir/actions'"), { description = "QA native dispatcher" })
qa_keybindings.disabled = hl.bind("SUPER + F10", function() record("disabled") end, { description = "QA disabled" })
qa_keybindings.disabled:set_enabled(false)
hl.bind("SUPER + F9", function() record("unbound") end, { description = "QA unbound" })
hl.unbind("SUPER + F9")
qa_keybindings.removed = hl.bind("SUPER + F8", function() record("removed") end, { description = "QA removed" })
qa_keybindings.removed:remove()
hl.bind("MOD3 + code:20", function() record("code") end, { description = "QA extra modifier" })
hl.bind("SUPER + F7", function() record("first") end, { description = "QA identical" })
hl.bind("SUPER + F7", function() record("second") end, { description = "QA identical" })
hl.define_submap("qa-keybindings", function()
  hl.bind("A", function() record("submap") end, { description = "QA submap" })
end)
LUA
printf '\ndofile("%s/fixture.lua")\n' "$test_dir" >>"$config"
hyprctl reload >/dev/null

snapshot() { hyprctl repl 'return omarchy_keybindings.snapshot()'; }
fixture_loaded() { snapshot | jq -e '.bindings[] | select(.description == "QA retained closure")' >/dev/null; }
wait_until "live keybindings fixture loads" 10 fixture_loaded
[[ -z $(hyprctl configerrors | tr -d '\n') ]] || fail "fixture loads without configuration errors"

snapshot >"$test_dir/before.json"
loads=$(wc -l <"$test_dir/loads")
for i in {1..12}; do
  timeout 10 omarchy-menu-keybindings --print >"$test_dir/menu-$i" &
done
wait
[[ $(wc -l <"$test_dir/loads") == "$loads" ]] || fail "listing must not evaluate the configuration again"
for i in {1..12}; do
  grep -q 'QA retained closure' "$test_dir/menu-$i" || fail "every concurrent menu completes"
  cmp "$test_dir/menu-1" "$test_dir/menu-$i" || fail "concurrent snapshots render consistently"
done
pass "twelve simultaneous menus complete without replaying configuration"
! grep -Eq 'QA (disabled|unbound|removed)' "$test_dir/menu-1" || fail "inactive bindings must not be listed"
grep -q 'MOD3 + MINUS.*QA extra modifier' "$test_dir/menu-1" || fail "original keycodes and extra modifiers survive"
snapshot | jq -e '.bindings[] | select(.description == "QA submap" and .submap == "qa-keybindings")' >/dev/null || fail "submap metadata survives"
pass "live handles preserve keycodes and submaps and exclude inactive bindings"

invoke() {
  local data="$1" description="$2" token id
  token=$(jq -r .generation <<<"$data")
  id=$(jq -r --arg description "$description" '.bindings[] | select(.description == $description) | .id' <<<"$data")
  hyprctl dispatch "function() return omarchy_keybindings.invoke(\"$token\", $id) end"
}

invoke "$(snapshot)" "QA retained closure" >/dev/null
grep -qx 'captured-local' "$test_dir/actions" || fail "original Lua closure executes with its captured state"
invoke "$(snapshot)" "QA native dispatcher" >/dev/null
wait_until "retained native dispatcher executes" 5 grep -qx native "$test_dir/actions"

hyprctl eval 'qa_keybindings.disabled:set_enabled(true)' >/dev/null
snapshot | jq -e '.bindings[] | select(.description == "QA disabled")' >/dev/null || fail "re-enabled bindings return without a config reload"
data=$(snapshot)
hyprctl eval 'qa_keybindings.disabled:set_enabled(false)' >/dev/null
output=$(invoke "$data" "QA disabled" 2>&1) || true
[[ $output == *"removed or disabled"* ]] || fail "a selection disabled after listing must be rejected" "$output"
pass "enabled state is checked again when invoking a selection"

# A menu selection must not point at a reused ID after a configuration reload.
data=$(snapshot)
old_generation=$(jq -r .generation <<<"$data")
hyprctl reload >/dev/null
generation_changed() { [[ $(snapshot | jq -r .generation) != "$old_generation" ]]; }
wait_until "configuration reload replaces the registry generation" 10 generation_changed
before=$(wc -l <"$test_dir/actions")
output=$(invoke "$data" "QA retained closure" 2>&1) || true
[[ $output == *"Keybindings changed"* ]] || fail "stale selections must be rejected" "$output"
[[ $(wc -l <"$test_dir/actions") == "$before" ]] || fail "stale selection must not execute any action"
pass "reload rejects stale selections instead of invoking reused IDs"

# Exercise the actual searchable menu and its dispatch path, not just the API.
omarchy-menu-keybindings >"$test_dir/menu-output" 2>&1 &
menu_pid=$!
wait_until "keybindings menu opens" 10 layer_present omarchy-menu
wtype 'QA retained closure'
wait_until "custom closure is searchable" 10 screen_contains 'QA retained closure'
screenshot success-keybindings-closure-search
before=$(wc -l <"$test_dir/actions")
wtype -k Return
wait_until "keybindings menu closes after selection" 10 layer_absent omarchy-menu
wait "$menu_pid" || fail "menu dispatch exits successfully" "$(cat "$test_dir/menu-output")"
menu_pid=""
(( $(wc -l <"$test_dir/actions") == before + 1 )) || fail "menu invokes the selected closure once"
pass "real menu search and selection execute the retained closure"
screenshot success-keybindings-after-selection

# Failures after selection must reach a desktop user, not just the launcher's
# stderr. Keep the real menu open while invalidating its captured selection.
for change in disabled reload; do
  omarchy-shell notifications dismissAll >/dev/null
  omarchy-menu-keybindings >"$test_dir/menu-output" 2>&1 &
  menu_pid=$!
  wait_until "menu opens before $change" 10 layer_present omarchy-menu
  wtype 'QA retained closure'
  wait_until "closure is searchable before $change" 10 screen_contains 'QA retained closure'
  before=$(wc -l <"$test_dir/actions")
  if [[ $change == "disabled" ]]; then
    hyprctl eval 'qa_keybindings.closure:set_enabled(false)' >/dev/null
  else
    hyprctl reload >/dev/null
    wait_until "fixture reloads before selecting stale entry" 10 fixture_loaded
  fi
  wtype -k Return
  wait_until "menu closes after $change rejection" 10 layer_absent omarchy-menu
  if wait "$menu_pid"; then fail "$change selection must fail"; fi
  menu_pid=""
  [[ $(wc -l <"$test_dir/actions") == "$before" ]] || fail "$change selection must not execute an action"
  wait_until "$change selection shows a recovery notification" 10 screen_contains 'Reopen the menu'
  screenshot "success-keybindings-$change-notification"
  hyprctl eval 'qa_keybindings.closure:set_enabled(true)' >/dev/null
done

# A hand-edited entrypoint can set package.path without loading bootstrap.
# Exercise the migration and recover by applying its exact documented line.
omarchy-shell notifications dismissAll >/dev/null
awk '
  index($0, "/default/hypr/bootstrap.lua") {
    print "package.path = os.getenv(\"HOME\") .. \"/.local/state/?.lua;\" .. os.getenv(\"HOME\") .. \"/.config/?.lua;\" .. os.getenv(\"OMARCHY_PATH\") .. \"/?.lua;\" .. package.path"
    next
  }
  { print }
' "$config" >"$test_dir/no-bootstrap.lua"
cp "$test_dir/no-bootstrap.lua" "$config"
hyprctl reload >/dev/null
registry_absent() { [[ $(hyprctl repl 'return type(omarchy_keybindings)') == "nil" ]]; }
wait_until "custom entrypoint loads without a registry" 10 registry_absent
[[ -z $(hyprctl configerrors | tr -d '\n') ]] || fail "custom entrypoint remains valid Lua"
for session in offline expired live; do
  case "$session" in
    offline) signature="" ;;
    expired) signature="qa-compositor-that-has-exited" ;;
    live) signature="$HYPRLAND_INSTANCE_SIGNATURE" ;;
  esac
  HYPRLAND_INSTANCE_SIGNATURE="$signature" bash -euo pipefail "$ROOT/migrations/1789328800.sh" >"$test_dir/migration-output" || fail "$session migration must not block the queue"
  grep -Fq 'dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")' "$test_dir/migration-output" || fail "$session migration must explain the missing bootstrap"
  cmp "$config" "$test_dir/no-bootstrap.lua" || fail "migration must preserve the custom entrypoint"
done
pass "offline, expired and live migrations preserve custom Lua and explain recovery"
if omarchy-menu-keybindings >"$test_dir/menu-output" 2>&1; then fail "missing registry must fail"; fi
wait_until "missing registry shows bootstrap recovery instructions" 10 screen_contains 'bootstrap.lua'
screenshot success-keybindings-bootstrap-notification
omarchy-shell notifications invokeLast >/dev/null
wait_until "notification opens complete setup instructions" 10 screen_contains 'Press Enter to close'
screenshot success-keybindings-bootstrap-instructions
wtype -k Return
{
  echo 'dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")'
  cat "$test_dir/no-bootstrap.lua"
} >"$config"
hyprctl reload >/dev/null
wait_until "documented bootstrap line restores the collector" 10 fixture_loaded
omarchy-menu-keybindings --print >"$test_dir/recovered-menu"
grep -q 'QA retained closure' "$test_dir/recovered-menu" || fail "recovered custom entrypoint lists its real bindings"
omarchy-shell notifications dismissAll >/dev/null
