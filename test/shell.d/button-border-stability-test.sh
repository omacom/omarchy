#!/bin/bash
source "$(dirname "$0")/base-test.sh"

require_compositor "Button hover geometry runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping Button hover geometry runtime test"
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

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  function sameRgb(a, b) {
    return Math.abs(a.r - b.r) < 0.01 && Math.abs(a.g - b.g) < 0.01 && Math.abs(a.b - b.b) < 0.01
  }

  function chips() {
    var list = []
    for (var i = 0; i < group.children.length; i++) {
      var child = group.children[i]
      if (child && child.selected !== undefined && child.text !== undefined)
        list.push(child)
    }
    return list
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

  function runGeometry() {
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
          console.log("RESULT pass")
          Qt.quit()
        })
      })
    })
  }

  // The shell's own style file loads after startup and replaces these, so
  // every step sets them again and starts over if they were swapped out.
  function applyOverrides() {
    Style.styleOverrides = ({
      "hover-cursor-border-width": 3,
      "selected-border-width": 5,
      "focus-border-width": 7,
      "hover-cursor-color": "accent",
      "selected-color": "foreground"
    })
  }

  function overridesHeld() {
    return Style.hoverColorToken === "accent" && Style.selectedColorToken === "foreground"
  }

  function after(next) {
    settle.next = next
    settle.restart()
  }

  function runChecks(attempt) {
    if (attempt > 5) {
      root.fail("style overrides never held")
      return
    }
    applyOverrides()
    plainButton.hasCursor = false
    after(function() {
      if (!overridesHeld()) return runChecks(attempt + 1)

      var row = chips()
      if (row.length < 2) return root.fail("group rendered " + row.length + " chips")
      var selectedChip = row[0]
      var restingChip = row[1]
      if (!sameRgb(selectedChip.color, restingChip.color) || restingChip.color.a !== 0)
        return root.fail("group chips " + selectedChip.color + " vs " + restingChip.color)

      // Hover tints with the accent here and selection with the foreground,
      // so a button that left hover on the selected RGB would show it.
      var hover = Style.hoverFillFor(plainButton.foreground, plainButton.accent)
      if (sameRgb(hover, selectedChip.color)) return root.fail("hover and selected share an rgb")
      plainButton.hasCursor = true
      after(function() {
        if (!overridesHeld()) return runChecks(attempt + 1)
        if (!sameRgb(plainButton.color, hover)) return root.fail("hover fill " + plainButton.color + " vs " + hover)
        plainButton.hasCursor = false
        after(function() {
          if (!overridesHeld()) return runChecks(attempt + 1)
          if (!sameRgb(plainButton.color, hover) || plainButton.color.a !== 0)
            return root.fail("rest after hover " + plainButton.color + " vs " + hover)
          runGeometry()
        })
      })
    })
  }

  Timer {
    id: settle
    interval: 250
    repeat: false
    property var next: null
    onTriggered: if (next) next()
  }

  Component.onCompleted: {
    applyOverrides()
    Qt.callLater(function() { runChecks(1) })
  }

  Item {
    ButtonGroup {
      id: group
      options: ["top", "bottom"]
      value: "top"
      foreground: "#ffffff"
      accent: "#ff0000"
    }

    Button {
      id: plainButton
      text: "Refresh"
      foreground: "#ffffff"
      accent: "#ff0000"
    }

    Button {
      id: focusableButton
      text: "Save"
      focusable: true
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "Button hover runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "Button size stays put, and a clear fill fades on the color it left"
fi

pass "Button size stays put, and a clear fill fades on the color it left"
