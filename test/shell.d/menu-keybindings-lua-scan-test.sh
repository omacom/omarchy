#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# The keybindings menu learns about Lua-only binds by running the user's
# hyprland.lua under a stub `hl`. That stub has to survive whatever a config
# does at load time, or the scan hangs (one user config spun a `lua` at 100%
# CPU for 27 hours after a single SUPER+K) or aborts halfway, silently dropping
# every bind declared after the failing line.

script="$ROOT/bin/omarchy-menu-keybindings"
scan=$(awk '/lua (-E - )?<<.LUA.$/ { capture = 1; next } /^LUA$/ { capture = 0 } capture' "$script")
[[ -n $scan ]] || fail "keybindings menu embeds the Lua bind scan"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/home/.config/hypr"
cat >"$TMPDIR/home/.config/hypr/hyprland.lua" <<'LUA'
-- Load-time reads a real config does against the compositor state.
for _, monitor in ipairs(hl.get_monitors()) do
  hl.monitor({ output = monitor.name, scale = monitor.scale })
end

local monitor = hl.get_active_monitor()
if not monitor or not monitor.scale or monitor.scale <= 0 then
  error("comparison should not raise")
end
local reserved = monitor.height - monitor.reserved.top * monitor.scale
local label = "monitor " .. monitor.name .. " " .. tostring(monitor.scale)
if #hl.get_workspaces() ~= 0 then
  error("stub collections should be empty")
end
if monitor.scale > 1 then
  error("stub comparisons should be false")
end

hl.bind("SUPER + K", hl.dsp.exec_cmd("omarchy-menu keybindings"), { description = "Keybindings menu" })
hl.bind("SUPER + code:20", hl.dsp.workspace({ name = "special" }), { description = "Lua only bind" })
LUA

# No time budget, so a slow machine cannot fail it: a scan that never ended
# would be killed by the timeout, which fails the run on its exit status.
output=$(HOME="$TMPDIR/home" DEBUG=1 timeout 60 lua -E - <<<"$scan" 2>&1) || fail "Lua bind scan exits cleanly on a config that iterates and compares compositor state (output: $output)"
pass "Lua bind scan survives load-time loops, comparisons, and arithmetic over stub state"

[[ $output != *"lua bind scan failed"* ]] || fail "Lua bind scan does not abort on stub comparisons ($output)"
grep -qF $'64\tKeybindings menu\tK\texec\tomarchy-menu keybindings' <<<"$output" || fail "Lua bind scan reports exec binds declared after load-time reads (got: $output)"
grep -qF $'64\tLua only bind\tcode:20\tlua\thl.dsp.workspace({ name = "special" })' <<<"$output" || fail "Lua bind scan reports Lua dispatcher binds (got: $output)"
pass "Lua bind scan reports binds declared after load-time compositor reads"

grep -q "timeout 10 lua -E - <<'LUA'" "$script" || fail "Lua bind scan is time-boxed"
pass "Lua bind scan is time-boxed"

# A loop nothing in the stub can end is stopped inside the scan, well before
# the timeout, and the binds declared ahead of it are still reported.
cat >"$TMPDIR/home/.config/hypr/hyprland.lua" <<'LUA'
hl.bind("SUPER + K", hl.dsp.exec_cmd("omarchy-menu keybindings"), { description = "Keybindings menu" })
while true do end
LUA

output=$(HOME="$TMPDIR/home" DEBUG=1 timeout 60 lua -E - <<<"$scan" 2>&1) || fail "Lua bind scan stops a runaway config instead of running until killed (output: $output)"
grep -qF $'64\tKeybindings menu\tK\texec\tomarchy-menu keybindings' <<<"$output" || fail "Lua bind scan keeps binds declared before a runaway loop (got: $output)"
pass "Lua bind scan stops a runaway config and keeps the binds declared before it"

# Indexing a collection still reads a stand-in: only `ipairs` sees it as empty,
# so a config that names its first or last monitor keeps the binds after it.
cat >"$TMPDIR/home/.config/hypr/hyprland.lua" <<'LUA'
local monitors = hl.get_monitors()
local first = monitors[1].name
local last = monitors[#monitors].name
hl.monitor({ output = first, scale = 1 })
hl.monitor({ output = last, scale = 1 })
hl.bind("SUPER + K", hl.dsp.exec_cmd("omarchy-menu keybindings"), { description = "Keybindings menu" })
LUA

output=$(HOME="$TMPDIR/home" DEBUG=1 timeout 60 lua -E - <<<"$scan" 2>&1) || fail "Lua bind scan reads an indexed stub collection (output: $output)"
[[ $output != *"lua bind scan failed"* ]] || fail "Lua bind scan does not abort on an indexed stub collection ($output)"
grep -qF $'64\tKeybindings menu\tK\texec\tomarchy-menu keybindings' <<<"$output" || fail "Lua bind scan reports binds declared after indexing a stub collection (got: $output)"
pass "Lua bind scan reads an indexed stub collection and keeps the binds after it"

# A walk by index ends too, and the binds after it are still reported.
cat >"$TMPDIR/home/.config/hypr/hyprland.lua" <<'LUA'
local monitors = hl.get_monitors()
local i = 1
while monitors[i] do
  i = i + 1
end
hl.bind("SUPER + K", hl.dsp.exec_cmd("omarchy-menu keybindings"), { description = "Keybindings menu" })
LUA

output=$(HOME="$TMPDIR/home" DEBUG=1 timeout 60 lua -E - <<<"$scan" 2>&1) || fail "Lua bind scan ends an indexed walk over a stub collection (output: $output)"
[[ $output != *"lua bind scan failed"* ]] || fail "Lua bind scan does not abort on an indexed walk over a stub collection ($output)"
grep -qF $'64\tKeybindings menu\tK\texec\tomarchy-menu keybindings' <<<"$output" || fail "Lua bind scan reports binds declared after an indexed walk (got: $output)"
pass "Lua bind scan ends an indexed walk over a stub collection and keeps the binds after it"
