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

assert(
  /TapHandler/.test(buttonQml),
  'Button presses cover the full control bounds'
)

assert(
  /grabPermissions:\s*PointerHandler\.TakeOverForbidden/.test(buttonQml),
  'Button taps keep the pointer grab through a small wiggle'
)

assert(
  /dragThreshold:\s*(?:Style\.space\(\s*(1[0-9]|[2-9]\d|[1-9]\d{2,})\s*\)|[1-9]\d+)/.test(buttonQml),
  'Button taps allow an explicit click wiggle before counting as a drag'
)

assert(
  /opacity:\s*enabled \? 1 : 0\.4/.test(buttonQml),
  'Disabled buttons dim'
)

const dialogQml = fs.readFileSync(path.join(root, 'shell/Ui/ConfirmDialog.qml'), 'utf8')
const handleKey = dialogQml.match(/function handleKey\(event\) \{([\s\S]*?)\n  \}/)
assert(handleKey, 'ConfirmDialog handles keys')
const handleBody = handleKey[1]
assert(
  handleBody.includes('cancelKey') && handleBody.includes('confirmKey'),
  'ConfirmDialog accepts cancel and confirm shortcut keys'
)
assert(
  handleBody.trimEnd().endsWith('return true'),
  'An open confirm dialog consumes leftover keys'
)
assert(
  /width:\s*Math\.max\(Style\.space\(88\),\s*label\.implicitWidth/.test(dialogQml),
  'Confirm buttons grow to fit their labels'
)
JS

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

  Component.onCompleted: {
    Style.styleOverrides = ({
      "hover-cursor-border-width": 3,
      "selected-border-width": 5,
      "focus-border-width": 7
    })
    Qt.callLater(runChecks)
  }

  Item {
    Button {
      id: plainButton
      text: "Refresh"
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
  fail "Button hover geometry runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "Button implicit geometry is stable across hover/selected states"
fi

pass "Button implicit geometry is stable across hover/selected states"

cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import QtTest
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  property int clicks: 0
  property int cancels: 0
  property int confirms: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  function check(condition, message) {
    if (!condition) root.fail(message)
  }

  // mouseClick needs a TestCase. The window is the layer shell, so this
  // case does not wait for a Qt Test window of its own.
  TestCase {
    id: driver
    name: "ButtonPress"
    when: false
  }

  PanelWindow {
    id: window
    implicitWidth: 320
    implicitHeight: 200
    color: "black"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Button {
      id: padButton
      x: 16
      y: 16
      text: "I"
      horizontalPadding: 40
      verticalPadding: 16
      onClicked: root.clicks++
    }

    Button {
      id: disabledButton
      x: 16
      y: 90
      text: "Off"
      enabled: false
      onClicked: root.clicks++
    }

    ConfirmDialog {
      id: dialog
      anchors.fill: parent
      cancelText: "Keep (K)"
      confirmText: "Discard (D)"
      cancelKey: Qt.Key_K
      confirmKey: Qt.Key_D
      onCanceled: root.cancels++
      onConfirmed: root.confirms++
    }
  }

  function runInput() {
    var spins = 0
    while ((padButton.width < 40 || padButton.height < 8) && spins < 40) {
      driver.wait(25)
      spins++
    }
    root.check(padButton.width > padButton.implicitWidth - 1, "the button has its padded width")

    var before = root.clicks
    driver.mouseClick(padButton, 4, padButton.height / 2)
    driver.wait(20)
    root.check(root.clicks === before + 1, "a click in the padding fires clicked, clicks=" + root.clicks)

    before = root.clicks
    var y = padButton.height / 2
    driver.mousePress(padButton, 4, y)
    driver.mouseMove(padButton, 8, y, -1, Qt.LeftButton)
    driver.mouseRelease(padButton, 8, y)
    driver.wait(20)
    root.check(root.clicks === before + 1, "a small move during the press is still a click, clicks=" + root.clicks)

    before = root.clicks
    driver.mousePress(padButton, padButton.width / 2, y)
    driver.mouseMove(padButton, padButton.width + 24, y, -1, Qt.LeftButton)
    driver.mouseRelease(padButton, padButton.width + 24, y)
    driver.wait(20)
    root.check(root.clicks === before, "a press that leaves the button is not a click, clicks=" + root.clicks)

    before = root.clicks
    driver.mouseClick(disabledButton, disabledButton.width / 2, disabledButton.height / 2)
    driver.wait(20)
    root.check(root.clicks === before, "a disabled button does not click")
    root.check(Math.abs(disabledButton.opacity - 0.4) < 0.01, "a disabled button dims, opacity=" + disabledButton.opacity)

    dialog.opened = true
    root.cancels = 0
    root.confirms = 0
    root.check(dialog.handleKey({ key: Qt.Key_K }) === true, "K is consumed")
    root.check(root.cancels === 1 && root.confirms === 0, "K cancels")
    root.check(dialog.handleKey({ key: Qt.Key_D }) === true, "D is consumed")
    root.check(root.cancels === 1 && root.confirms === 1, "D confirms")
    root.check(dialog.handleKey({ key: Qt.Key_B }) === true, "an unrelated key is consumed")
    root.check(root.cancels === 1 && root.confirms === 1, "an unrelated key does not choose a button")
    dialog.opened = false
    root.check(dialog.handleKey({ key: Qt.Key_K }) === false, "a closed dialog ignores keys")
    root.check(root.cancels === 1, "a closed dialog does not cancel")

    console.log("RESULT pass")
    Qt.quit()
  }

  Component.onCompleted: Qt.callLater(runInput)
}
QML

input_output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$input_output" >&2
  fail "Button press and confirm-dialog fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$input_output"; then
  printf '%s\n' "$input_output" >&2
  fail "Button padding clicks and confirm-dialog keys behave"
fi

pass "Button padding clicks and confirm-dialog keys behave"
