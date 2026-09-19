#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const buttonQml = fs.readFileSync(path.join(root, 'shell/Ui/Button.qml'), 'utf8')

assert(
  /anchors\.leftMargin:\s*root\.leftAlign \? root\._reservedContentLeftInset : 0/.test(buttonQml),
  'Button left-aligned content uses reserved border inset'
)

assert(
  !/implicitWidth:[^\n]*\bborderLeft\b/.test(buttonQml) && !/implicitHeight:[^\n]*\bborderTop\b/.test(buttonQml),
  'Button implicit size does not depend on current hover/focus border'
)
JS

require_compositor "Button hover geometry runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping Button hover geometry runtime test"
  exit 0
fi

TMPDIR=$(mktemp -d)
cleanup() {
  if [[ -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

ln -s "$ROOT/shell/Ui" "$TMPDIR/Ui"
ln -s "$ROOT/shell/Commons" "$TMPDIR/Commons"

cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root
  property var powers: [2, 1, 1.5, 4, 10, 2]
  property int powerIndex: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  function checkStable(button, width, height, label, next) {
    Qt.callLater(function() {
      if (button.implicitWidth !== width || button.implicitHeight !== height) {
        root.fail(label + " changed from " + width + "x" + height + " to " + button.implicitWidth + "x" + button.implicitHeight)
        return
      }
      next()
    })
  }

  function runChecks() {
    if (parentBound.radius !== 9 || parentBound.color.toString() !== "#123456") {
      root.fail("surface properties must bind in the caller's context")
      return
    }
    var plainWidth = plainButton.implicitWidth
    var plainHeight = plainButton.implicitHeight
    plainButton.hasCursor = true
    checkStable(plainButton, plainWidth, plainHeight, "hover-cursor", function() {
      plainButton.hasCursor = false
      plainButton.selected = true
      checkStable(plainButton, plainWidth, plainHeight, "selected", function() {
        var focusWidth = focusableButton.implicitWidth
        var focusHeight = focusableButton.implicitHeight
        focusableButton.hasCursor = true
        checkStable(focusableButton, focusWidth, focusHeight, "focusable hover-cursor", function() {
          if (++root.powerIndex < root.powers.length) {
            plainButton.hasCursor = false
            plainButton.selected = false
            focusableButton.hasCursor = false
            Qt.callLater(runChecks)
          } else {
            console.log("RESULT pass")
            Qt.quit()
          }
        })
      })
    })
  }

  Component.onCompleted: {
    Style.styleOverrides = ({
      "hover-cursor-border-width": 3,
      "selected-border-width": 5,
      "focus-border-width": 7
    })
    Qt.callLater(runChecks)
  }

  Item {
    property real radius: 9
    property color color: "#123456"
    CornerRectangle {
      id: parentBound
      radius: parent.radius
      color: parent.color
      roundingPower: 1
    }

    Button {
      id: plainButton
      text: "Refresh"
      radius: 10
      roundingPower: root.powers[Math.min(root.powerIndex, root.powers.length - 1)]
    }

    Button {
      id: focusableButton
      text: "Save"
      radius: 10
      roundingPower: root.powers[Math.min(root.powerIndex, root.powers.length - 1)]
      focusable: true
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "Button hover geometry runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "Button implicit geometry is stable across hover/selected states"
fi

pass "Button implicit geometry is stable across hover/selected states"
