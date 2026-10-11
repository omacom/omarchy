#!/bin/bash
source "$(dirname "$0")/base-test.sh"

require_compositor "Button pixel centering runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping Button pixel centering runtime test"
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

# Nerd Font icons are fractionally wide (󰐲 is ~14.98px at 19.5px). With
# anchors.horizontalCenter, Qt rounds the button's center and the content's
# half-width separately, so a 27px button put the content at x=7 instead
# of 6. Content must stay on whole pixels and within half a pixel of center.
cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  property var failures: []

  function contentRow(button) {
    for (var i = 0; i < button.children.length; i++) {
      var child = button.children[i]
      if (String(child).indexOf("QQuickRow") === 0) return child
    }
    return null
  }

  function whole(value) {
    return Math.abs(value - Math.round(value)) < 0.001
  }

  function check(button, label, leftAligned) {
    var row = contentRow(button)
    if (!row) {
      failures.push(label + ": content row not found")
      return
    }
    var pos = row.mapToItem(scene, 0, 0)
    if (!whole(button.width) || !whole(button.height))
      failures.push(label + ": size " + button.width + "x" + button.height + " is fractional")
    if (!whole(pos.x))
      failures.push(label + ": content x " + pos.x + " is fractional")
    if (leftAligned) {
      if (Math.abs(row.x - button._reservedContentLeftInset) > 0.001)
        failures.push(label + ": content x " + row.x + " is not the reserved inset " + button._reservedContentLeftInset)
    } else if (Math.abs(row.x - (button.width - row.width) / 2) > 0.5) {
      failures.push(label + ": content x " + row.x + " is more than half a pixel off center")
    }
  }

  function runChecks() {
    check(rightQr, "right-anchored QR icon", false)
    check(rightSpeed, "right-anchored speed-test icon", false)
    check(plainIcon, "plain-row icon", false)
    check(leftAligned, "leftAlign button", true)
    if (failures.length > 0) console.log("RESULT fail " + failures.join("; "))
    else console.log("RESULT pass")
    Qt.quit()
  }

  Component.onCompleted: Qt.callLater(runChecks)

  Item {
    id: scene
    width: 360
    height: 200

    Item {
      x: 13
      width: 347
      height: 40

      RowLayout {
        anchors.right: parent.right
        spacing: 8

        Button {
          id: rightQr
          iconText: "󰐲"
          iconSize: 19.5
          horizontalPadding: 5
          verticalPadding: 2
        }

        Button {
          id: rightSpeed
          iconText: "󰓅"
          iconSize: 19.5
          horizontalPadding: 5
          verticalPadding: 2
        }

        Item {
          implicitWidth: 40
          implicitHeight: 20
        }
      }
    }

    Row {
      y: 60

      Button {
        id: plainIcon
        iconText: "󰐲"
        iconSize: 19.5
      }
    }

    Button {
      id: leftAligned
      y: 120
      width: 200
      leftAlign: true
      iconText: "󰐲"
      text: "Left aligned"
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "Button pixel centering runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "Button content stays on whole pixels and centered"
fi

pass "Button content stays on whole pixels and centered"
