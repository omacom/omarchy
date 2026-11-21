#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const { applyHover } = requireFromRoot("shell/Ui/CursorPolicy.js")

function cursor() {
  return {
    active: false,
    section: "",
    index: -1,
    owns(section, index) {
      return this.active && this.section === section && this.index === index
    },
    claim(section, index) {
      this.active = true
      this.section = section
      this.index = index
    },
    release() {
      this.active = false
    },
    hover(on, section, index) {
      applyHover(
        on,
        this.owns(section, index),
        () => this.claim(section, index),
        () => this.release()
      )
    }
  }
}

const state = cursor()

state.hover(true, "a", 0)
assert(state.active && state.section === "a", "pointer enter claims the cursor")

state.hover(false, "a", 0)
assert(!state.active, "pointer leave releases the cursor it still owns")

state.hover(true, "a", 0)
state.hover(true, "b", 0)
state.hover(false, "a", 0)
assert(state.active && state.section === "b", "leaving the old row keeps the new row's cursor")

state.hover(true, "a", 0)
state.claim("b", 0)
state.hover(false, "a", 0)
assert(state.active && state.section === "b", "a stale pointer leave does not clear a keyboard selection")

state.hover(true, "a", 0)
state.claim("action", 0)
state.hover(false, "a", 0)
assert(state.active && state.section === "action", "leaving a row for its inline action keeps the action's cursor")

state.hover(false, "action", 0)
assert(!state.active, "leaving the inline action releases the cursor")
JS

qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -z $qml_test_runner ]]; then
  skip "Qt6 qmltestrunner not found; skipping cursor hover signal test"
  exit 0
fi

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/qs/Commons" "$fixture/qs/Ui" "$fixture/home"
cp "$SHELL_TEST_DIR/cursor-hover/Commons/"* "$fixture/qs/Commons/"
cp "$ROOT/shell/Commons/Border.qml" "$ROOT/shell/Commons/BorderGeometry.js" "$fixture/qs/Commons/"
cp "$SHELL_TEST_DIR/cursor-hover/Ui/qmldir" "$fixture/qs/Ui/"
cp "$ROOT/shell/Ui/BorderSurface.qml" "$ROOT/shell/Ui/BorderOverlay.qml" "$ROOT/shell/Ui/CursorSurface.qml" "$ROOT/shell/Ui/Cursor.qml" "$ROOT/shell/Ui/CursorPolicy.js" "$fixture/qs/Ui/"
cp "$SHELL_TEST_DIR/cursor-hover/qml/"* "$fixture/"

output=$(HOME="$fixture/home" XDG_CONFIG_HOME="$fixture/home/.config" XDG_STATE_HOME="$fixture/home/.state" \
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software QT_QUICK_CONTROLS_STYLE=Basic \
  "$qml_test_runner" -import "$fixture" -input "$fixture" -o -,txt 2>&1) ||
  fail "CursorSurface forwards pointer hover and Cursor releases it on leave" "$output"
if [[ $output == *QWARN* ]]; then
  fail "CursorSurface hover fixture has no QML warnings" "$output"
fi
printf '%s\n' "$output" | sed -n '/^Totals:/p'
pass "CursorSurface forwards pointer hover and Cursor releases it on leave"
