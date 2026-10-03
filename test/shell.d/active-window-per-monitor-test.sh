#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

ACTIVE_WINDOW="$ROOT/shell/plugins/bar/widgets/ActiveWindow.qml"
BAR="$ROOT/shell/plugins/bar/Bar.qml"

[[ -f $ACTIVE_WINDOW ]] || fail "ActiveWindow.qml is missing"
[[ -f $BAR ]] || fail "Bar.qml is missing"

run_node_test <<'JS'
const fs = require('fs')

const active = fs.readFileSync(path.join(root, 'shell/plugins/bar/widgets/ActiveWindow.qml'), 'utf8')
const bar = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')

// Bars are built once per output; the title widget must not treat focus as
// global or every copy shows the same window.
assert(
  /model:\s*Quickshell\.screens/.test(bar) && /screen:\s*modelData/.test(bar),
  'bar instantiates a surface per Quickshell.screens entry'
)

assert(
  active.includes('import Quickshell.Hyprland'),
  'active-window imports Hyprland to resolve the focused toplevel monitor'
)

assert(
  /ToplevelManager\.activeToplevel/.test(active),
  'active-window still starts from the Wayland active toplevel'
)

// Guard against a silent return to global-only display: the Wayland active
// toplevel must be matched through Hyprland and gated on this bar's screen.
assert(
  /Hyprland\.toplevels\.values/.test(active) &&
    /\.wayland\s*===\s*waylandToplevel/.test(active),
  'active-window matches the Wayland toplevel to a Hyprland.toplevels entry via .wayland'
)

assert(
  /hyprlandToplevel\.monitor|activeMonitor/.test(active) &&
    /QsWindow\.window/.test(active) &&
    /barScreenName/.test(active) &&
    /activeMonitorName/.test(active) &&
    /onThisScreen/.test(active),
  'active-window compares the Hyprland monitor name to this bar surface screen name'
)

assert(
  /toplevel:\s*onThisScreen\s*\?\s*activeWayland\s*:\s*null/.test(active) ||
    /onThisScreen\s*\?\s*activeWayland\s*:\s*null/.test(active),
  'active-window exposes the Wayland toplevel only when onThisScreen'
)

assert(
  /visible:\s*title\s*!==\s*""\s*&&\s*!vertical/.test(active),
  'active-window stays hidden on vertical bars'
)

assert(
  /implicitWidth:\s*visible\s*\?[\s\S]*:\s*0/.test(active),
  'active-window collapses its slot with implicitWidth 0 when hidden'
)

// Click handlers must keep using the gated toplevel so activate/close cannot
// fire from a bar that is not showing the title.
assert(
  /if\s*\(\s*!root\.toplevel\s*\)\s*return/.test(active) &&
    active.includes('root.toplevel.close()') &&
    active.includes('root.toplevel.activate()'),
  'active-window preserves activate/close against the gated toplevel'
)

// A raw assignment of the global active toplevel as the displayed toplevel
// without an onThisScreen gate is the original bug; keep it from returning.
assert(
  !/readonly property var toplevel:\s*ToplevelManager\.activeToplevel\b/.test(active),
  'active-window must not bind toplevel directly to global ToplevelManager.activeToplevel'
)

assert(
  !/title:\s*ToplevelManager\.activeToplevel/.test(active),
  'active-window must not read the title straight from the global active toplevel'
)
JS

pass "active-window gates the title to the matching monitor"
