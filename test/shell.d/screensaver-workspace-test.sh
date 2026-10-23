#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
require_command lua

tmpdir=$(mktemp -d)
cleanup() {
  [[ -f $tmpdir/socat.pid ]] && kill "$(<"$tmpdir/socat.pid")" 2>/dev/null || true
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$tmpdir/bin"
mkfifo "$tmpdir/events"
# Held open for writing so the event reader never sees end of file between events.
exec {events}<>"$tmpdir/events"

cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/calls"
case "$*" in
  'monitors -j')
    printf '[{"name":"DP-1","specialWorkspace":{"name":""}},{"name":"DP-2","specialWorkspace":{"name":"special:scratchpad"}}]\n'
    ;;
  'clients -j')
    cat "$TEST_DIR/clients.json"
    printf 'read\n' >>"$TEST_DIR/clients-read"
    ;;
  *exec_cmd*)
    count=$(($(wc -l <"$TEST_DIR/spawned") + 1))
    printf '%s\n' "$count" >>"$TEST_DIR/spawned"
    printf 'openwindow>>%s,1,org.omarchy.screensaver,foot\n' "$count" >"$TEST_DIR/events"
    ;;
esac
SH
cat >"$tmpdir/bin/socat" <<'SH'
#!/bin/bash
printf '%s\n' "$$" >"$TEST_DIR/socat.pid"
exec cat "$TEST_DIR/events"
SH
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/pgrep"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-toggle-enabled"
printf '#!/bin/bash\necho DP-1\n' >"$tmpdir/bin/omarchy-hyprland-monitor-focused"
printf '#!/bin/bash\necho foot.desktop\n' >"$tmpdir/bin/xdg-terminal-exec"
chmod +x "$tmpdir/bin/"*

: >"$tmpdir/calls"
: >"$tmpdir/spawned"
# Replaced whole, so the launcher's background waiter never reads a half-written list.
clients() {
  printf '%s\n' "$1" >"$tmpdir/clients.json.new"
  mv "$tmpdir/clients.json.new" "$tmpdir/clients.json"
}
showing='[{"class":"org.omarchy.screensaver","mapped":true},{"class":"popped","address":"0xp0p","pinned":true,"mapped":true}]'
closed='[{"class":"org.omarchy.screensaver","mapped":false},{"class":"popped","address":"0xp0p","pinned":false,"mapped":true}]'
clients "$showing"

PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
  timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force

mapfile -t spawns < <(grep exec_cmd "$tmpdir/calls")
(( ${#spawns[@]} == 2 )) || fail "a screensaver opens on each monitor" "$(<"$tmpdir/calls")"
[[ ${spawns[0]} == *"[workspace special:screensaver-DP-1]"* ]] ||
  fail "the screensaver opens on its own special workspace, leaving a fullscreen window alone" "${spawns[0]}"
pass "the screensaver opens on its own special workspace, leaving a fullscreen window alone"
[[ ${spawns[1]} == *"[workspace special:scratchpad]"* ]] ||
  fail "the screensaver shares a special workspace that is already showing" "${spawns[1]}"
pass "the screensaver shares a special workspace that is already showing"

# Pinned windows draw above any fullscreen window, so they are unpinned before the first screensaver maps.
unpin=$(grep -n 'hl.dsp.window.pin({ window = "address:0xp0p", action = "disable" })' "$tmpdir/calls" | head -1 | cut -d: -f1 || true)
spawn=$(grep -n exec_cmd "$tmpdir/calls" | head -1 | cut -d: -f1 || true)
[[ -n $unpin ]] && (( unpin < spawn )) ||
  fail "a pinned window is unpinned before the screensaver maps" "$(<"$tmpdir/calls")"
pass "a pinned window is unpinned before the screensaver maps"

# Emptying a special workspace focuses its monitor; the last screensaver to close must not keep focus.
: >"$tmpdir/calls"
printf 'closewindow>>1\n' >&"$events"
sleep 0.5
grep -q 'hl.dsp.focus' "$tmpdir/calls" && fail "focus waits until the last screensaver has closed" "$(<"$tmpdir/calls")"
pass "focus waits until the last screensaver has closed"
grep -q 'hl.dsp.window.pin' "$tmpdir/calls" && fail "pinned windows stay unpinned until the last screensaver has closed" "$(<"$tmpdir/calls")"
pass "pinned windows stay unpinned until the last screensaver has closed"
clients "$closed"
printf 'closewindow>>2\n' >&"$events"
for (( attempt = 0; attempt < 100; attempt++ )); do
  grep -q 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls" && break
  sleep 0.05
done
grep -q 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls" ||
  fail "focus returns to the monitor that had it once the screensaver closes" "$(<"$tmpdir/calls")"
pass "focus returns to the monitor that had it once the screensaver closes"
grep -q 'hl.dsp.window.pin({ window = "address:0xp0p", action = "enable" })' "$tmpdir/calls" ||
  fail "a window unpinned for the screensaver is pinned again once it closes" "$(<"$tmpdir/calls")"
pass "a window unpinned for the screensaver is pinned again once it closes"

# Screensavers can close while the launcher is still waiting on another monitor, consuming their events.
kill "$(<"$tmpdir/socat.pid")"
: >"$tmpdir/calls"
: >"$tmpdir/spawned"
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
  timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force
for (( attempt = 0; attempt < 100; attempt++ )); do
  (( $(grep -c 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls") == 3 )) && break
  sleep 0.05
done
(( $(grep -c 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls") == 3 )) ||
  fail "focus returns without waiting for a close that has already happened" "$(<"$tmpdir/calls")"
pass "focus returns without waiting for a close that has already happened"

# Losing Hyprland's event stream must not leave a window unpinned for good.
kill "$(<"$tmpdir/socat.pid")"
clients "$showing"
: >"$tmpdir/calls"
: >"$tmpdir/clients-read"
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
  timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force
# The second client list read is the waiter's, so it has seen the screensaver up before its stream goes away.
for (( attempt = 0; attempt < 100; attempt++ )); do
  (( $(wc -l <"$tmpdir/clients-read") >= 2 )) && break
  sleep 0.05
done
kill "$(<"$tmpdir/socat.pid")"
sleep 0.5
clients "$closed"
for (( attempt = 0; attempt < 100; attempt++ )); do
  grep -q 'action = "enable"' "$tmpdir/calls" && break
  sleep 0.05
done
grep -q 'hl.dsp.window.pin({ window = "address:0xp0p", action = "enable" })' "$tmpdir/calls" ||
  fail "a window unpinned for the screensaver is pinned again after the event stream ends" "$(<"$tmpdir/calls")"
pass "a window unpinned for the screensaver is pinned again after the event stream ends"

# The launcher's workspace only holds for the first map. A terminal mapped again as it closes falls back to
# the class rule, which must keep it off the regular workspaces where its fullscreen rule would take over.
fallback=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
hl = setmetatable({
  window_rule = function(rule)
    if rule.match.class == "org.omarchy.screensaver" and rule.workspace then print(rule.workspace) end
  end,
}, { __index = function() return function() return {} end end })
require("default.hypr.helpers")
require("default.hypr.apps.system")
LUA
)
[[ $fallback == "special:screensaver silent" ]] ||
  fail "a screensaver mapped again as it closes stays off the regular workspaces" "workspace rule: ${fallback:-none}"
pass "a screensaver mapped again as it closes stays off the regular workspaces"
