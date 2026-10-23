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
    # No screensaver is up until the launcher spawns one, or its already-running gate would exit.
    if [[ -s $TEST_DIR/spawned ]]; then
      cat "$TEST_DIR/clients.json"
    else
      echo '[]'
    fi
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
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/pidof"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-toggle-enabled"
printf '#!/bin/bash\necho DP-1\n' >"$tmpdir/bin/omarchy-hyprland-monitor-focused"
printf '#!/bin/bash\necho foot.desktop\n' >"$tmpdir/bin/xdg-terminal-exec"
chmod +x "$tmpdir/bin/"*

: >"$tmpdir/calls"
: >"$tmpdir/spawned"
printf '[{"class":"org.omarchy.screensaver","mapped":true}]\n' >"$tmpdir/clients.json"

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
