#!/bin/bash

set -euo pipefail
# shellcheck source=base-test.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command node

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin" "$tmpdir/home"
export HOME="$tmpdir/home" XDG_STATE_HOME="$tmpdir/state" CALLS="$tmpdir/calls"
export PATH="$tmpdir/bin:$PATH" OMARCHY_PATH="$ROOT"

cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALLS"
exit "${RELOAD_FAILURE:-0}"
SH
for command in omarchy-shell omarchy-notification-send omarchy-i18n; do
  cat >"$tmpdir/bin/$command" <<'SH'
#!/bin/bash
printf '%s\n' "$(basename "$0") $*" >>"$CALLS"
SH
done
chmod +x "$tmpdir/bin/"*

flag="$XDG_STATE_HOME/omarchy/toggles/no-monitor-workspaces"
command="$ROOT/bin/omarchy-toggle-monitor-workspaces"
"$command" off
[[ -f $flag ]] || fail "off persists global numbering under XDG_STATE_HOME"
grep -qx 'reload' "$CALLS" || fail "off reloads Hyprland"
grep -q 'omarchy.workspaces refresh' "$CALLS" || fail "off refreshes the workspace widget"
[[ ! -e $HOME/.local/state/omarchy/toggles/no-monitor-workspaces ]] || fail "the command respects XDG_STATE_HOME"
pass "off saves the opt-out, reloads Hyprland and refreshes the bar"

: >"$CALLS"
"$command" off
[[ ! -s $CALLS ]] || fail "off is idempotent"
"$command" on
[[ ! -e $flag ]] || fail "on restores the default"
"$command"
[[ -f $flag ]] || fail "toggle switches to global"
"$command" toggle
[[ ! -e $flag ]] || fail "toggle switches back to per-monitor"
pass "on, off and toggle are explicit and idempotent"

: >"$CALLS"
if "$command" invalid 2>"$tmpdir/error"; then fail "invalid mode is rejected"; fi
if "$command" on extra 2>"$tmpdir/error"; then fail "extra arguments are rejected"; fi
[[ ! -s $CALLS && ! -e $flag ]] || fail "invalid input cannot change state or reload"
pass "invalid arguments leave the desktop untouched"

if RELOAD_FAILURE=1 "$command" off 2>"$tmpdir/error"; then fail "reload failure is reported"; fi
[[ ! -e $flag ]] || fail "failed off restores the previous setting"
"$command" off
if RELOAD_FAILURE=1 "$command" on 2>"$tmpdir/error"; then fail "reload failure on enable is reported"; fi
[[ -f $flag ]] || fail "failed on restores the previous setting"
pass "reload failure rolls back either setting"

XDG_STATE_HOME='' "$command" off
[[ -f $HOME/.local/state/omarchy/toggles/no-monitor-workspaces ]] || fail "empty XDG_STATE_HOME falls back to HOME"
pass "empty XDG_STATE_HOME uses the standard state directory"

run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(path.join(root, 'shell/plugins/bar/widgets/Workspaces.qml'), 'utf8')
const hyprland = { workspaces: { values: [
  { id: 1, monitor: { name: 'eDP-1' } },
  { id: 6, monitor: { name: 'DP-1' } },
  { id: 16, monitor: { name: 'DP-1' } },
  { id: -1, monitor: { name: 'DP-1' } }
] } }
const widget = { slots: 10, block: 1, monitorName: 'DP-1', perMonitorWorkspaces: true, dispatches: [] }
widget.dispatch = expression => widget.dispatches.push(expression)
for (const name of ['blockOf', 'slotOf', 'workspaceIds', 'focusWorkspace', 'modeGlyph']) {
  const match = source.match(new RegExp(`\\n  function ${name}\\(([^)]*)\\) \\{([\\s\\S]*?)\\n  \\}`))
  if (!match) fail(`can extract ${name} from the real widget`)
  const fn = new Function('root', 'Hyprland', match[1], match[2])
  widget[name] = value => fn(widget, hyprland, value)
}
assertDeepEqual(widget.workspaceIds(), [11, 12, 13, 14, 15, 16, 6], 'per-monitor bar retains its slots and guests')
assertEqual(widget.slotOf(16), 6, 'per-monitor bar labels internal 16 as local 6')
widget.focusWorkspace(16)
assertEqual(widget.dispatches.pop(), 'o.workspaces.focus(6, "DP-1")', 'per-monitor clicks use the local slot')
widget.perMonitorWorkspaces = false
assertDeepEqual(widget.workspaceIds(), [1, 2, 3, 4, 5, 6, 16], 'global bar shows shared ids without dropping higher occupied workspaces')
assertEqual(widget.slotOf(16), 16, 'global bar never relabels id 16 as 6')
widget.focusWorkspace(16)
assertEqual(widget.dispatches.pop(), 'hl.dsp.focus({ workspace = "16" })', 'global clicks focus the actual id')
const labelBinding = source.match(/^\s+text: (.+)$/m)
if (!labelBinding) fail('can extract the workspace button label binding')
const label = new Function('root', 'slot', 'shown', 'return ' + labelBinding[1])
widget.activeMode = 'scrolling'
for (const [perMonitor, id, expected] of [[true, 10, '0'], [true, 20, '0'], [true, 16, '6'], [false, 10, '10'], [false, 20, '20'], [false, 16, '16']]) {
  widget.perMonitorWorkspaces = perMonitor
  assertEqual(label(widget, widget.slotOf(id), false), expected, `${perMonitor ? 'per-monitor' : 'global'} mode labels inactive workspace ${id}`)
  assertEqual(label(widget, widget.slotOf(id), true), widget.modeGlyph(widget.activeMode), 'the shown workspace keeps its layout glyph in either scope')
}
JS
