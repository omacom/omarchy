#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

harness="$tmpdir/autostart.lua"
cat >"$harness" <<'LUA'
local handlers = {}
local commands = {}
local waylandDisplay = nil
local startupClaimed = false
local legacyShellRunning = false

hl = {
  on = function(event, callback) handlers[event] = callback end,
  exec_cmd = function(command) table.insert(commands, command) end,
}
o = { launch = function(command) return command end }
os.getenv = function(name)
  if name == "WAYLAND_DISPLAY" then return waylandDisplay end
end
o.shell_succeeds = function(command)
  assert(command == "omarchy-hyprland-autostart-claim", "unexpected startup guard command")
  if startupClaimed or legacyShellRunning then return false end
  startupClaimed = true
  return true
end

dofile(arg[1])
local function hasCommand(needle)
  for _, command in ipairs(commands) do
    if command:find(needle, 1, true) then return true end
  end
  return false
end

if arg[2] == "normal" then
  waylandDisplay = nil
  handlers["config.reloaded"]()
  assert(#commands == 0, "the initial config reload ran before Wayland was ready")
  waylandDisplay = "wayland-1"
  handlers["hyprland.start"]()
  assert(#commands > 0, "normal startup did not launch session services")
  assert(hasCommand("omarchy-launch-shell"), "normal startup did not restore the shell")
  assert(hasCommand("omarchy-hook post-boot"), "normal startup did not run post-boot hooks")
elseif arg[2] == "safe-mode" then
  waylandDisplay = "wayland-1"
  handlers["config.reloaded"]()
  assert(#commands > 0, "loading the user config after safe-mode did not launch services")
  assert(hasCommand("omarchy-launch-shell"), "safe-mode recovery did not restore the shell")
  assert(hasCommand("omarchy-hook post-boot"), "safe-mode recovery did not run post-boot hooks")
elseif arg[2] == "existing-session" then
  waylandDisplay = "wayland-1"
  startupClaimed = true
  handlers["config.reloaded"]()
  assert(#commands == 0, "a config reload repeated startup in an existing session")
elseif arg[2] == "legacy-session" then
  waylandDisplay = "wayland-1"
  legacyShellRunning = true
  handlers["config.reloaded"]()
  assert(#commands == 0, "an update reload repeated startup for a pre-marker session")
else
  error("unknown startup scenario: " .. tostring(arg[2]))
end

local startupCommands = #commands
waylandDisplay = "wayland-1"
-- A config reload creates a fresh Lua state, but the claim belongs to the
-- compositor's runtime directory and survives that reload.
dofile(arg[1])
handlers["config.reloaded"]()
assert(#commands == startupCommands, "a fresh config reload repeated session startup")
-- The callback can also be delivered again in this Lua state.
handlers["config.reloaded"]()
assert(#commands == startupCommands, "a later config reload repeated session startup")
LUA

run_case() {
  lua "$harness" "$ROOT/default/hypr/autostart.lua" "$1"
}

run_case normal
pass "normal Hyprland startup launches services once across config reloads"

run_case safe-mode
pass "loading the user config after Hyprland start restores session autostart once"

run_case existing-session
pass "loading config in an already-running session does not repeat autostart"

run_case legacy-session
pass "loading config in a pre-marker session adopts its existing shell without replaying startup"

runtime_dir="$tmpdir/runtime"
instance_dir="$runtime_dir/hypr/test-instance"
mkdir -p "$instance_dir"
mock_bin="$tmpdir/mock-bin"
proc_root="$tmpdir/proc"
mkdir -p "$mock_bin" "$proc_root/123"
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_QUICKSHELL_RUNNING:-false} == "true" ]] && printf '123\n'
SH
chmod +x "$mock_bin/pgrep"
printf 'HYPRLAND_INSTANCE_SIGNATURE=test-instance\0' >"$proc_root/123/environ"
printf 'quickshell\0-n\0-p\0%s/shell\0' "$ROOT" >"$proc_root/123/cmdline"
if PATH="$mock_bin:$PATH" OMARCHY_PROC_ROOT="$proc_root" OMARCHY_PATH="$ROOT" OMARCHY_TEST_QUICKSHELL_RUNNING=false \
  XDG_RUNTIME_DIR="$runtime_dir" HYPRLAND_INSTANCE_SIGNATURE=test-instance \
  "$ROOT/bin/omarchy-hyprland-autostart-claim"; then
  pass "the first Hyprland autostart claim succeeds"
else
  fail "the first Hyprland autostart claim succeeds"
fi
if PATH="$mock_bin:$PATH" OMARCHY_PROC_ROOT="$proc_root" OMARCHY_PATH="$ROOT" OMARCHY_TEST_QUICKSHELL_RUNNING=false \
  XDG_RUNTIME_DIR="$runtime_dir" HYPRLAND_INSTANCE_SIGNATURE=test-instance \
  "$ROOT/bin/omarchy-hyprland-autostart-claim"; then
  fail "a repeated Hyprland autostart claim is rejected"
fi
pass "a repeated Hyprland autostart claim is rejected across processes"

legacy_runtime_dir="$tmpdir/legacy-runtime"
mkdir -p "$legacy_runtime_dir/hypr/legacy-instance"
printf 'HYPRLAND_INSTANCE_SIGNATURE=legacy-instance\0' >"$proc_root/123/environ"
if PATH="$mock_bin:$PATH" OMARCHY_PROC_ROOT="$proc_root" OMARCHY_PATH="$ROOT" OMARCHY_TEST_QUICKSHELL_RUNNING=true \
  XDG_RUNTIME_DIR="$legacy_runtime_dir" HYPRLAND_INSTANCE_SIGNATURE=legacy-instance \
  "$ROOT/bin/omarchy-hyprland-autostart-claim"; then
  fail "a pre-marker shell is adopted instead of claiming fresh startup"
fi
[[ -d $legacy_runtime_dir/hypr/legacy-instance/omarchy-autostart ]] ||
  fail "adopting a pre-marker shell persists the startup claim"
pass "a pre-marker shell is adopted and its startup claim is persisted"

unrelated_runtime_dir="$tmpdir/unrelated-runtime"
mkdir -p "$unrelated_runtime_dir/hypr/unrelated-instance"
printf 'HYPRLAND_INSTANCE_SIGNATURE=other-instance\0' >"$proc_root/123/environ"
if PATH="$mock_bin:$PATH" OMARCHY_PROC_ROOT="$proc_root" OMARCHY_PATH="$ROOT" OMARCHY_TEST_QUICKSHELL_RUNNING=true \
  XDG_RUNTIME_DIR="$unrelated_runtime_dir" HYPRLAND_INSTANCE_SIGNATURE=unrelated-instance \
  "$ROOT/bin/omarchy-hyprland-autostart-claim"; then
  pass "an unrelated Quickshell process does not suppress session startup"
else
  fail "an unrelated Quickshell process does not suppress session startup"
fi
