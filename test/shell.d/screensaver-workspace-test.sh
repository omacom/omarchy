#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
require_command lua

tmpdir=$(mktemp -d)
# Every launch starts its own event reader, so stop each one, or a reader outlives the test holding the runner's output open.
cleanup() {
  local pids=()
  [[ -f $tmpdir/socat.pid ]] && mapfile -t pids <"$tmpdir/socat.pid"
  (( ${#pids[@]} > 0 )) && kill "${pids[@]}" 2>/dev/null || true
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
    cat "$TEST_DIR/monitors.json"
    ;;
  'clients -j')
    cat "$TEST_DIR/clients.json"
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
printf '%s\n' "$$" >>"$TEST_DIR/socat.pid"
exec cat "$TEST_DIR/events"
SH
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/pgrep"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-toggle-enabled"
printf '#!/bin/bash\necho "${FOCUSED_NAME:-DP-1}"\n' >"$tmpdir/bin/omarchy-hyprland-monitor-focused"
printf '#!/bin/bash\necho foot.desktop\n' >"$tmpdir/bin/xdg-terminal-exec"
chmod +x "$tmpdir/bin/"*

: >"$tmpdir/calls"
: >"$tmpdir/spawned"
printf '[{"class":"org.omarchy.screensaver","mapped":true}]\n' >"$tmpdir/clients.json"

printf '[{"name":"DP-1","specialWorkspace":{"name":""}},{"name":"DP-2","specialWorkspace":{"name":"special:scratchpad"}}]\n' >"$tmpdir/monitors.json"
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

# Emptying a special workspace focuses its monitor; the last screensaver to close must not keep focus.
: >"$tmpdir/calls"
printf 'closewindow>>1\n' >&"$events"
sleep 0.5
grep -q 'hl.dsp.focus' "$tmpdir/calls" && fail "focus waits until the last screensaver has closed" "$(<"$tmpdir/calls")"
pass "focus waits until the last screensaver has closed"
printf '[{"class":"org.omarchy.screensaver","mapped":false}]\n' >"$tmpdir/clients.json"
printf 'closewindow>>2\n' >&"$events"
for (( attempt = 0; attempt < 100; attempt++ )); do
  grep -q 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls" && break
  sleep 0.05
done
grep -q 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls" ||
  fail "focus returns to the monitor that had it once the screensaver closes" "$(<"$tmpdir/calls")"
pass "focus returns to the monitor that had it once the screensaver closes"

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


# Monitor and special-workspace names reach the Lua expression the launcher
# dispatches, so a name that is not a plain connector (a headless output can
# carry anything) must be refused rather than interpolated, exactly like the
# sibling monitor toggles. jq is real, so the payload travels the same pipeline.
printf '[{"name":"DP-1","specialWorkspace":{"name":"special:my stuff"}}]\n' >"$tmpdir/monitors.json"
: >"$tmpdir/calls"
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
  timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force
for (( attempt = 0; attempt < 100; attempt++ )); do
  (( $(grep -c 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls") == 3 )) && break
  sleep 0.05
done
(( $(grep -c 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls") == 3 )) ||
  fail "a special workspace named with a space still gets the screensaver" "$(<"$tmpdir/calls")"
grep -q "exec_cmd(\[\[\[workspace special:my stuff\] " "$tmpdir/calls" ||
  fail "a special workspace named with a space still gets the screensaver" "$(<"$tmpdir/calls")"
pass "a special workspace named with a space still gets the screensaver"

monitor_name='DP-1\"]]);os.execute([[id]]);--'
printf '[{"name":"%s","specialWorkspace":{"name":""}}]\n' "$monitor_name" >"$tmpdir/monitors.json"
: >"$tmpdir/calls"
set +e
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force >/dev/null 2>"$tmpdir/err"
status=$?
set -e
(( status == 1 )) || fail "an unsafe output name is refused with exit 1, not a timeout" "status=$status $(<"$tmpdir/calls")"
grep -q "Refusing unsafe monitor name" "$tmpdir/err" || fail "an unsafe output name is refused with the monitor message" "stderr=$(<"$tmpdir/err")"
grep -q "exec_cmd" "$tmpdir/calls" && fail "an unsafe output name never reaches the Lua dispatch" "$(<"$tmpdir/calls")"
grep -q "os.execute" "$tmpdir/calls" && fail "an unsafe output name cannot inject Lua"
grep -q "hl.dsp.focus" "$tmpdir/calls" && fail "an unsafe output name does not move focus before refusing" "$(<"$tmpdir/calls")"
pass "an unsafe output name is refused before the Lua dispatch"

workspace_name='special:x]]);os.execute([[id]]);--'
printf '[{"name":"DP-1","specialWorkspace":{"name":"%s"}}]\n' "$workspace_name" >"$tmpdir/monitors.json"
: >"$tmpdir/calls"
set +e
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force >/dev/null 2>"$tmpdir/err"
status=$?
set -e
(( status == 1 )) || fail "an unsafe special-workspace name is refused with exit 1, not a timeout" "status=$status $(<"$tmpdir/calls")"
grep -q "Refusing unsafe workspace name" "$tmpdir/err" || fail "an unsafe special-workspace name is refused with the workspace message" "stderr=$(<"$tmpdir/err")"
grep -q "exec_cmd" "$tmpdir/calls" && fail "an unsafe special-workspace name never reaches the Lua dispatch" "$(<"$tmpdir/calls")"
grep -q "os.execute" "$tmpdir/calls" && fail "an unsafe special-workspace name cannot inject Lua"
grep -q "hl.dsp.focus" "$tmpdir/calls" && fail "an unsafe special-workspace name does not move focus before refusing" "$(<"$tmpdir/calls")"
pass "an unsafe special-workspace name is refused before the Lua dispatch"

# A semicolon cannot leave the Lua string, but it splits the [workspace ...] rule into further window rules.
printf '[{"name":"DP-1","specialWorkspace":{"name":"special:x;float"}}]\n' >"$tmpdir/monitors.json"
: >"$tmpdir/calls"
set +e
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force >/dev/null 2>"$tmpdir/err"
status=$?
set -e
(( status == 1 )) || fail "a special-workspace name with a semicolon is refused with exit 1" "status=$status $(<"$tmpdir/calls")"
grep -q "Refusing unsafe workspace name" "$tmpdir/err" || fail "a special-workspace name with a semicolon is refused with the workspace message" "stderr=$(<"$tmpdir/err")"
grep -q "exec_cmd" "$tmpdir/calls" && fail "a special-workspace name with a semicolon never reaches the dispatch" "$(<"$tmpdir/calls")"
pass "a special-workspace name with a semicolon cannot add window rules"

# A refusal on a later monitor must not leave an earlier screen on the wrong
# monitor, so every name is checked before the first terminal is launched.
printf '[{"name":"DP-1","specialWorkspace":{"name":""}},{"name":"%s","specialWorkspace":{"name":""}}]
' "$monitor_name" >"$tmpdir/monitors.json"
: >"$tmpdir/calls"
set +e
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force >/dev/null 2>"$tmpdir/err"
status=$?
set -e
(( status == 1 )) || fail "a later unsafe output name is refused with exit 1, not a timeout" "status=$status $(<"$tmpdir/calls")"
grep -q "Refusing unsafe monitor name" "$tmpdir/err" || fail "a later unsafe output name is refused with the monitor message" "stderr=$(<"$tmpdir/err")"
grep -q "exec_cmd" "$tmpdir/calls" && fail "no terminal is launched before every name is checked" "$(<"$tmpdir/calls")"
grep -q "hl.dsp.focus" "$tmpdir/calls" && fail "a later unsafe output name does not move focus before refusing" "$(<"$tmpdir/calls")"
pass "every name is checked before the first screensaver is launched"

# The focused monitor's name comes from the same compositor data, and reaches the same dispatch when focus is handed back.
printf '[{"name":"DP-1","specialWorkspace":{"name":""}}]\n' >"$tmpdir/monitors.json"
: >"$tmpdir/calls"
set +e
FOCUSED_NAME='DP-1"}) os.execute("id") --' PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force >/dev/null 2>"$tmpdir/err"
status=$?
set -e
(( status == 1 )) || fail "an unsafe focused monitor name is refused with exit 1, not a timeout" "status=$status $(<"$tmpdir/calls")"
grep -q "Refusing unsafe monitor name" "$tmpdir/err" || fail "an unsafe focused monitor name is refused with the monitor message" "stderr=$(<"$tmpdir/err")"
grep -q "os.execute" "$tmpdir/calls" && fail "an unsafe focused monitor name cannot inject Lua" "$(<"$tmpdir/calls")"
pass "an unsafe focused monitor name is refused before the Lua dispatch"
