#!/bin/bash
source "$(dirname "$0")/base-test.sh"

require_compositor "Button content centering runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping Button content centering runtime test"
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

# A layout hands a button any width, odd or even, whole or fractional. The
# content must land on a whole pixel within half a pixel of the centre, mirrored
# or not, and leftAlign must keep its inset on the mirrored side.
cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  function contentRow(button) {
    for (var i = 0; i < button.children.length; i++) {
      if (typeof button.children[i].spacing === "number") return button.children[i]
    }
    return null
  }

  function check(repeater, mirrored, failures) {
    for (var i = 0; i < repeater.count; i++) {
      var button = repeater.itemAt(i)
      var row = contentRow(button)
      var label = (mirrored ? "mirrored " : "") + button.iconText + button.text + " at width " + button.width + ": x " + row.x
      var centre = (button.width - row.width) / 2
      if (Math.abs(row.x - centre) > 0.5 || row.x !== Math.round(row.x)) {
        failures.push(label + ", centre " + centre)
      }
    }
    var aligned = contentRow(mirrored ? mirroredLeftAligned : leftAligned)
    var button = aligned.parent
    var expected = mirrored ? button.width - aligned.width - button._reservedContentLeftInset : button._reservedContentLeftInset
    if (aligned.x !== expected) failures.push((mirrored ? "mirrored " : "") + "leftAlign: x " + aligned.x + ", expected " + expected)
  }

  function runChecks() {
    var failures = []
    check(plain.repeater, false, failures)
    check(mirrored.repeater, true, failures)
    if (failures.length > 0) console.log("RESULT fail " + failures.join("; "))
    else console.log("RESULT pass")
    Qt.quit()
  }

  Component.onCompleted: Qt.callLater(runChecks)

  readonly property var contents: [
    { iconText: "󰓅", text: "" },
    { iconText: "󰐲", text: "" },
    { iconText: "", text: "OK" },
    { iconText: "", text: "Refresh" },
    { iconText: "󰓅", text: "Run" }
  ]
  readonly property var widthOffsets: [-1, 0, 1, 2, 3, 4, 0.5, 1.25, 2.75]

  component Cases: Item {
    property alias repeater: cases

    Repeater {
      id: cases
      model: root.contents.length * root.widthOffsets.length

      Button {
        required property int index
        readonly property var content: root.contents[Math.floor(index / root.widthOffsets.length)]
        width: Math.floor(implicitWidth) + root.widthOffsets[index % root.widthOffsets.length]
        iconText: content.iconText
        text: content.text
        iconSize: 19.5
        fontSize: 13.5
      }
    }
  }

  Cases {
    id: plain

    Button {
      id: leftAligned
      width: 120
      text: "Refresh"
      leftAlign: true
    }
  }

  Cases {
    id: mirrored
    LayoutMirroring.enabled: true
    LayoutMirroring.childrenInherit: true

    Button {
      id: mirroredLeftAligned
      width: 120
      text: "Refresh"
      leftAlign: true
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "Button content centering runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "Button centres its content on a whole pixel at any width"
fi

pass "Button centres its content on a whole pixel at any width"
