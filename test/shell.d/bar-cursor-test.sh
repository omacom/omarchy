#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The bar keeps the arrow cursor over its widgets, the way the macOS menu bar,
# GNOME's top bar, and KDE's panel do. Popups and panels opened from the bar
# are dialogs and may use whatever cursor they like; this pins only the bar.

assert_no_hand() {
  local file="$1" description="$2"

  if /usr/bin/grep -n "PointingHandCursor" "$ROOT/$file"; then
    fail "$description" "$file names Qt.PointingHandCursor"
  fi
  pass "$description"
}

# The first cursorShape after `id: <id>` is that MouseArea's own.
cursor_shape_after_id() {
  local file="$1" id="$2"

  awk -v id="$id" '
    $0 ~ "id: " id "$" { found = 1; next }
    found && /cursorShape:/ { print; exit }
  ' "$ROOT/$file"
}

assert_no_hand shell/Ui/WidgetButton.qml "widget buttons keep the arrow cursor"
assert_no_hand shell/plugins/bar/widgets/ActiveWindow.qml "the active window title keeps the arrow cursor"
assert_no_hand shell/plugins/bar/Bar.qml "module slots keep the arrow cursor over click targets"

tray_icon_cursor=$(cursor_shape_after_id shell/plugins/bar/widgets/Tray.qml mouseArea)
[[ $tray_icon_cursor == *"Qt.ArrowCursor"* && $tray_icon_cursor != *"PointingHandCursor"* ]] ||
  fail "tray icons on the bar keep the arrow cursor" "$tray_icon_cursor"
pass "tray icons on the bar keep the arrow cursor"

# Reordering a module by dragging is feedback about a drag in progress, not
# hover, so the closed hand stays.
/usr/bin/grep -q "cursorShape: dragging ? Qt.ClosedHandCursor : Qt.ArrowCursor" "$ROOT/shell/plugins/bar/Bar.qml" ||
  fail "module drag keeps the closed-hand cursor while dragging"
pass "module drag keeps the closed-hand cursor while dragging"
