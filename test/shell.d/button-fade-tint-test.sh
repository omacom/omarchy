#!/bin/bash
source "$(dirname "$0")/base-test.sh"

require_compositor "Button fade tint runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping Button fade tint runtime test"
  exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

ln -s "$ROOT/shell/Ui" "$TMPDIR/Ui"
ln -s "$ROOT/shell/Commons" "$TMPDIR/Commons"

# A chip fading between selected and resting must only change alpha. When the
# RGB differs too, ColorAnimation's unpremultiplied blend flashes mid-fade.
cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  function sameRgb(a, b) {
    return Math.abs(a.r - b.r) < 0.01 && Math.abs(a.g - b.g) < 0.01 && Math.abs(a.b - b.b) < 0.01
  }

  function check() {
    var selected = group.children[0]
    var resting = group.children[1]
    if (!sameRgb(selected.color, resting.color) || resting.color.a !== 0) {
      console.log("RESULT fail group chips " + selected.color + " vs " + resting.color)
    } else if (!sameRgb(selected.color, plain.color) || plain.color.a !== 0) {
      console.log("RESULT fail plain button rests on " + plain.color)
    } else {
      console.log("RESULT pass")
    }
    Qt.quit()
  }

  Component.onCompleted: Qt.callLater(check)

  Item {
    ButtonGroup {
      id: group
      options: ["top", "bottom"]
      value: "top"
    }

    Button {
      id: plain
      text: "Refresh"
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "Button fade tint runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "Resting Buttons share the state tint's RGB so fades change only alpha"
fi

pass "Resting Buttons share the state tint's RGB so fades change only alpha"
