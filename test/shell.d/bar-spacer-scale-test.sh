#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "bar spacer scale test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping bar spacer scale test"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/home"

ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"
ln -s "$ROOT/shell/plugins/bar/widgets" "$test_tmp/Widgets"

cat >"$test_tmp/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import "Widgets"

// A spacer is a gap, so its authored size is a spacing value: [spacing] scale
// and [font] base-size move it the way they move every other gap in the bar.
// Changing the text size must re-evaluate the live spacer, not just a rebuilt
// one, because the shell reflows running widgets when shell.toml changes.
ShellRoot {
  id: root

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  function shellValues(values) {
    Style.applyShellValues(values)
  }

  QtObject {
    id: testBar
    property bool vertical: false
    property int barSize: Style.bar.sizeHorizontal
    property string fontFamily: Style.font.family
    property color barForeground: "white"
    property color urgent: "red"
    property bool foregroundAnimationEnabled: false
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
    function hideTooltip(target) {}
    function showTooltip(target, text) {}
  }

  QtObject {
    id: verticalBar
    property bool vertical: true
    property int barSize: Style.bar.sizeVertical
    property string fontFamily: Style.font.family
    property color barForeground: "white"
    property color urgent: "red"
    property bool foregroundAnimationEnabled: false
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
    function hideTooltip(target) {}
    function showTooltip(target, text) {}
  }

  Spacer { id: spacer; bar: testBar; settings: ({ size: 6 }) }
  Spacer { id: defaultSpacer; bar: testBar }
  Spacer { id: hiddenSpacer; bar: testBar; settings: ({ size: 0 }) }
  Spacer { id: verticalSpacer; bar: verticalBar; settings: ({ size: 6 }) }

  Component.onCompleted: Qt.callLater(function() {
    if (spacer.span !== 6) return fail("size 6 at base-size 12 should be 6, got " + spacer.span)
    if (defaultSpacer.span !== 12) return fail("an unset size should default to 12, got " + defaultSpacer.span)
    if (hiddenSpacer.span !== 0 || hiddenSpacer.visible) return fail("size 0 should stay hidden")

    // Live reflow: the running spacer, not a rebuilt one.
    shellValues({ "font.base-size": "15" })
    if (spacer.span !== 8) return fail("size 6 at base-size 15 should be 8, got " + spacer.span)

    shellValues({ "font.base-size": "20" })
    if (spacer.span !== 10) return fail("size 6 at base-size 20 should be 10, got " + spacer.span)

    shellValues({ "font.base-size": "9" })
    if (spacer.span !== 5) return fail("size 6 at base-size 9 should be 5, got " + spacer.span)

    shellValues({ "font.base-size": "12", "spacing.scale": "0.5" })
    if (spacer.span !== 3) return fail("size 6 at spacing scale 0.5 should be 3, got " + spacer.span)

    // The opt-out: [spacing] scale-with-font = false leaves the spacer alone.
    shellValues({ "font.base-size": "20", "spacing.scale-with-font": "false" })
    if (spacer.span !== 6) return fail("scale-with-font off should keep 6, got " + spacer.span)

    shellValues({ "font.base-size": "12" })
    if (verticalSpacer.implicitHeight !== verticalSpacer.span || verticalSpacer.implicitWidth !== verticalBar.barSize) {
      return fail("a vertical bar should stack the span against the bar width")
    }
    if (spacer.implicitWidth !== spacer.span || spacer.implicitHeight !== testBar.barSize) {
      return fail("a horizontal bar should lay the span along the bar")
    }

    console.log("RESULT pass")
    Qt.quit()
  })
}
QML

output=$(timeout 15 env \
  HOME="$test_tmp/home" \
  XDG_CONFIG_HOME="$test_tmp/home/.config" \
  XDG_CACHE_HOME="$test_tmp/home/.cache" \
  XDG_STATE_HOME="$test_tmp/home/.local/state" \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "bar spacer scale fixture exits cleanly"
}

if ! grep -q 'RESULT pass' <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "bar spacer size follows the spacing scale and text size"
fi

pass "bar spacer size follows the spacing scale and text size"
