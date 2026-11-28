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

  Password { id: password; editable: true }

  function init() {
    password.clear()
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
}
QML

output=$(QT_QPA_PLATFORM=offscreen "$qml_test_runner" -input "$test_tmp/tst_password.qml" -o -,txt 2>&1) ||
  fail "the password drops control characters and loses whole characters to Backspace" "$output"
pass "the password drops control characters and loses whole characters to Backspace"
