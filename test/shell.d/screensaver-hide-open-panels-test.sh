#!/bin/bash

# #15643: an open panel built on KeyboardPanel (clock, clipboard, emoji picker)
# is an overlay layer surface that holds keyboard focus, so the screensaver
# terminals map unfocused and their fullscreen window rule never applies. The
# launcher must close every open panel before spawning them, via the shell's
# hideOpenPanels IPC.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

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
    printf '[{"name":"DP-1","specialWorkspace":{"name":""}}]\n'
    ;;
  'clients -j')
    printf '[{"class":"org.omarchy.screensaver","mapped":true}]\n'
    ;;
  *exec_cmd*)
    printf 'openwindow>>1,1,org.omarchy.screensaver,foot\n' >"$TEST_DIR/events"
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
# Record every IPC call so the test can assert the launcher closed the panels.
cat >"$tmpdir/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/ipc"
exit 0
SH
chmod +x "$tmpdir/bin/"*

: >"$tmpdir/calls"
: >"$tmpdir/ipc"

PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
  timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force

grep -Eq '(^| )shell hideOpenPanels$' "$tmpdir/ipc" ||
  fail "the launcher closes every open panel before spawning the screensaver" "$(cat "$tmpdir/ipc")"
pass "the launcher closes every open panel before spawning the screensaver"

ipc_line=$(grep -nE '(^| )shell hideOpenPanels$' "$tmpdir/ipc" | head -1 | cut -d: -f1)
spawn_line=$(grep -n 'exec_cmd' "$tmpdir/calls" | head -1 | cut -d: -f1)
[[ -n $spawn_line ]] || fail "the screensaver was spawned" "$(cat "$tmpdir/calls")"
(( ipc_line <= spawn_line )) ||
  fail "the panels are closed before the first screensaver terminal is spawned" \
    "ipc call line $ipc_line, first spawn line $spawn_line"
pass "the panels are closed before the first screensaver terminal is spawned"

# The QML side: hideOpenPanels closes every panel the shell reports open and
# reports their ids, so the shell IPC answer says what was closed.
run_node_test <<'JS'
const fs = require('fs')
const src = fs.readFileSync(root + '/shell/shell.qml', 'utf8')
const match = src.match(/function hideOpenPanels\(\) \{([\s\S]*?)\n  \}/)
assert(match, 'shell.qml defines hideOpenPanels')
const hideOpenPanels = new Function('panelLoaders', 'shell', match[1])

const closed = []
const panelLoaders = { 'omarchy.clock': {}, 'omarchy.menu': {}, 'omarchy.notepad': {} }
const shellStub = {
  isPluginOpen(id) { return id === 'omarchy.clock' || id === 'omarchy.menu' },
  hide(id) { closed.push(id); return id !== 'omarchy.menu' }
}

const result = hideOpenPanels(panelLoaders, shellStub)
assert(Array.isArray(result) && result.length === 1 && result[0] === 'omarchy.clock',
  'only the panels that were open and closed successfully are reported: ' + JSON.stringify(result))
assert(closed.length === 2 && closed[0] === 'omarchy.clock' && closed[1] === 'omarchy.menu',
  'every open panel gets a hide attempt: ' + JSON.stringify(closed))

assert(/function hideOpenPanels\(\): string \{\n      return JSON\.stringify\(shell\.hideOpenPanels\(\)\)/.test(src),
  'the shell IPC target exposes hideOpenPanels')
JS
