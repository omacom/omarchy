#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# default/splash/ui/Password.qml edits the password at the boot unlock and the
# login screen alike.

# /usr/bin/qmltestrunner is the Qt 5 binary, which exits 0 having run nothing.
qml_test_runner=/usr/lib/qt6/bin/qmltestrunner
if [[ ! -x $qml_test_runner ]]; then
  skip "qt6 qmltestrunner not found; skipping the splash's password editing"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

cat >"$test_tmp/tst_password.qml" <<QML
import QtQuick
import QtTest
import "file://$ROOT/default/splash/ui"

TestCase {
  name: "Password"
  when: windowShown

  Password { id: password; editable: true }
  Layouts { id: layouts; layout: "dk,us" }

  TextInput {
    id: input
    width: 1
    height: 1
    opacity: 0
    focus: true
    echoMode: TextInput.Password

    onTextChanged: {
      if (text === "") return
      password.append(text)
      text = ""
    }

    Keys.onPressed: event => {
      event.accepted = true
      const action = password.actionForKey(
        event.key, event.modifiers, event.text, event.isAutoRepeat,
        true, layouts.count
      )
      if (action === "toggleReveal") password.revealed = !password.revealed
      else if (action === "nextLayout") layouts.next()
      else if (action === "append") password.append(event.text)
    }
  }

  function init() {
    password.clear()
    password.revealed = false
    password.revealHeld = false
    password.revealTimeoutMs = 15000
    layouts.index = 0
    input.forceActiveFocus()
  }

  function test_control_characters_never_go_in() {
    password.append("a\u0009b\u007fc\u0085d")
    compare(password.text, "abcd")
    password.failed = true
    password.append("\u0003")
    verify(password.failed, "a control character alone types nothing")
  }

  function test_backspace_takes_a_whole_character() {
    password.append("é😀")
    password.removeLast()
    compare(password.text, "é")
  }

  function test_take_hides_revealed_password() {
    password.append("secret")
    password.revealed = true
    compare(password.take(), "secret")
    compare(password.text, "")
    verify(!password.revealed, "submitting hides a toggled-on password")
  }

  function test_tab_toggles_visibility_and_ignores_repeats_and_modifiers() {
    compare(password.actionForKey(Qt.Key_Tab, Qt.NoModifier, "\t", false, true, 1), "toggleReveal")
    compare(password.actionForKey(Qt.Key_Tab, Qt.NoModifier, "\t", true, true, 1), "ignore")
    compare(password.actionForKey(Qt.Key_Tab, Qt.NoModifier, "\t", false, false, 1), "ignore")
    compare(password.actionForKey(Qt.Key_Tab, Qt.ControlModifier, "\t", false, true, 2), "append")
    compare(password.actionForKey(Qt.Key_Tab, Qt.AltModifier, "\t", false, true, 2), "append")
  }

  function test_shift_tab_cycles_layout_only_with_multiple_layouts() {
    compare(password.actionForKey(Qt.Key_Backtab, Qt.ShiftModifier, "", false, true, 1), "ignore")
    compare(password.actionForKey(Qt.Key_Backtab, Qt.ShiftModifier, "", false, true, 2), "nextLayout")
    compare(password.actionForKey(Qt.Key_Backtab, Qt.NoModifier, "", false, true, 2), "nextLayout")
    compare(password.actionForKey(Qt.Key_Tab, Qt.ShiftModifier, "", false, true, 2), "nextLayout")
    compare(password.actionForKey(Qt.Key_Backtab, Qt.ShiftModifier, "", true, true, 2), "ignore")
    compare(password.actionForKey(Qt.Key_Backtab, Qt.ShiftModifier, "", false, false, 2), "ignore")
    compare(password.actionForKey(Qt.Key_Backtab, Qt.ShiftModifier | Qt.ControlModifier, "", false, true, 2), "append")
  }

  function test_toggled_reveal_hides_after_inactivity_unless_held_or_typing() {
    password.revealTimeoutMs = 80
    password.revealed = true
    password.revealHeld = false
    wait(45)
    password.append("a")
    wait(45)
    verify(password.revealed, "typing extends the inactivity deadline")
    tryCompare(password, "revealed", false, 300)

    password.revealHeld = true
    password.revealed = true
    wait(120)
    verify(password.revealed, "holding Alt+F8 does not auto-hide")
    password.revealHeld = false
    password.revealed = false
  }

  function test_text_input_keeps_focus_on_tab_and_shift_tab() {
    verify(input.activeFocus)
    keyClick(Qt.Key_Tab)
    verify(password.revealed, "Tab toggles visibility through TextInput")
    verify(input.activeFocus, "Tab does not move focus away from TextInput")
    keyClick(Qt.Key_Tab)
    verify(!password.revealed, "second Tab hides visibility again")

    keyClick(Qt.Key_Backtab, Qt.ShiftModifier)
    compare(layouts.label, "US")
    verify(input.activeFocus, "Backtab does not move focus away from TextInput")

    keyClick(Qt.Key_Tab, Qt.ShiftModifier)
    compare(layouts.label, "DK")
    compare(password.text, "")
  }
}
QML

output=$(QT_QPA_PLATFORM=offscreen "$qml_test_runner" -input "$test_tmp/tst_password.qml" -o -,txt 2>&1) ||
  fail "the password edits text and routes Tab and Shift+Tab shortcuts" "$output"
pass "the password edits text and routes Tab and Shift+Tab shortcuts"
