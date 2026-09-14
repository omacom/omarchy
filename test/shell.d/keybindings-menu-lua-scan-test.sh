#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua
require_command xkbcli
require_command setsid

# The keybindings menu learns about Lua-only binds by running the user's
# hyprland.lua under a stub `hl`. Configs read compositor state at load time,
# and the stub has to hand back something those reads can finish with: a loop
# over hl.get_monitors() that never ended left a `lua` at 100% CPU behind every
# SUPER + K until reboot.

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to stub Hyprland in"
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
cache="$tmpdir/cache"
config="$home/.config/hypr/hyprland.lua"
mkdir -p "$home/.config/hypr" "$stub_bin"

lua_bind() {
  printf 'bind\n\tmodmask: %s\n\tsubmap: \n\tkey: %s\n\tkeycode: 0\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: __lua\n\targ: \n' "$1" "$2" "$3"
}

stub_hyprctl() {
  {
    echo '#!/bin/bash'
    echo 'case "$1" in'
    echo '  binds) cat <<'"'"'BINDS'"'"''
    cat
    echo 'BINDS'
    echo '  ;;'
    echo '  devices) echo "active keymap: English (US)" ;;'
    echo 'esac'
  } >"$stub_bin/hyprctl"
  chmod +x "$stub_bin/hyprctl"
}

# Runs the menu against the fixture config with a cold cache. The run gets a
# session of its own, so a scanner it leaves behind can be told apart from any
# other `lua` on the machine, and a background job in a shell without job
# control is not a group leader, so setsid makes the job itself the leader.
keybindings() {
  local pid started

  rm -rf "$cache"
  started=$(date +%s)
  setsid env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$cache" OMARCHY_PATH="$ROOT" "$@" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print >"$tmpdir/stdout" 2>"$tmpdir/stderr" &
  pid=$!
  wait "$pid" || true

  elapsed=$(( $(date +%s) - started ))
  rendered=$(<"$tmpdir/stdout")
  errors=$(<"$tmpdir/stderr")
  survivors=$(ps -o pid=,comm= --sid "$pid" 2>/dev/null || true)
}

# Every list getter the stub names, one it does not, and the numeric-index
# shapes a config reaches for. Under a real Hyprland each of these terminates;
# under the stub they used to spin forever.
cat >"$config" <<'LUA'
local seen = 0

for _, monitor in ipairs(hl.get_monitors()) do
  seen = seen + 1
end

for _, window in ipairs(hl.get_windows()) do
  seen = seen + 1
end

for _, workspace in ipairs(hl.get_workspaces()) do
  seen = seen + 1
end

for _, plugin in ipairs(hl.get_loaded_plugins()) do
  seen = seen + 1
end

for index = 1, #hl.get_windows() do
  seen = seen + 1
end

local cursor = hl.get_loaded_plugins()[1]
while cursor do
  seen = seen + 1
  cursor = cursor.next
end

if seen ~= 0 then
  error("stub lists should be empty")
end

-- String keys still chain, so reads of a single stub value keep working.
if hl.get_active_monitor().name == nil then
  error("stub values should still answer string keys")
end

hl.bind("SUPER + W", hl.dsp.kill_active(), { description = "Close window" })
hl.bind("SUPER + Q", hl.dsp.kill_active(), { description = "Close window" })
hl.bind("SUPER + code:20", hl.dsp.workspace({ name = "special" }), { description = "Lua only bind" })
LUA

# Hyprland reports the two Close window chords as dispatcher __lua, so they
# only share a row once the scan has recovered what they run; the code: bind
# arrives without its key, which the scan supplies too.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + W" "Close window")
$(lua_bind 64 "SUPER + Q" "Close window")
$(lua_bind 64 "" "Lua only bind")
BINDS

keybindings
(( elapsed < 5 )) || fail "iterating stub list getters terminates" "took ${elapsed}s"
[[ -z $survivors ]] || fail "iterating stub list getters leaves no scanner behind" "$survivors"
[[ $errors != *"scan failed"* && $errors != *"timed out"* ]] ||
  fail "iterating stub list getters does not abort the scan" "$errors"
pass "iterating stub list getters terminates"

grep -q 'SUPER + W / SUPER + Q  *→ Close window' <<<"$rendered" ||
  fail "binds declared after load-time loops are still discovered" "$rendered"
grep -q 'SUPER + MINUS  *→ Lua only bind' <<<"$rendered" ||
  fail "a code: key declared after load-time loops is still recovered" "$rendered"
pass "binds declared after load-time loops are still discovered"

[[ -n $(find "$cache/omarchy" -maxdepth 1 -name 'keybindings-*.records' 2>/dev/null) ]] ||
  fail "a scan that finished is cached"
pass "a scan that finished is cached"

# A config the stub still cannot satisfy: nothing in this loop indexes a
# number, so no stub value can end it. The scan has to be cut off, the menu
# has to open anyway with what Hyprland reported, and the cut-off result must
# not be cached, or every later press would serve the incomplete menu.
cat >"$config" <<'LUA'
hl.bind("SUPER + W", hl.dsp.kill_active(), { description = "Close window" })

while hl.get_active_monitor() do
end

hl.bind("SUPER + Q", hl.dsp.kill_active(), { description = "Close window" })
LUA

keybindings OMARCHY_KEYBINDINGS_SCAN_TIMEOUT=2
(( elapsed < 8 )) || fail "a scan that never finishes is cut off" "took ${elapsed}s"
[[ -z $survivors ]] || fail "a cut-off scan leaves no scanner behind" "$survivors"
pass "a scan that never finishes is cut off"

[[ $errors == *"timed out after 2s"* ]] ||
  fail "a cut-off scan says so on stderr" "$errors"
(( $(grep -c '→ Close window$' <<<"$rendered") == 2 )) ||
  fail "the menu still opens with what Hyprland reported after a cut-off scan" "$rendered"
pass "the menu still opens after a cut-off scan"

[[ -z $(find "$cache/omarchy" -maxdepth 1 -name 'keybindings*' 2>/dev/null) ]] ||
  fail "a cut-off scan is not cached" "$(ls -A "$cache/omarchy")"
pass "a cut-off scan is not cached"
