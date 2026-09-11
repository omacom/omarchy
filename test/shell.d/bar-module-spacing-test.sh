#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The bar lays modules out with a uniform gutter instead of relying on
# widget-internal padding, so adjacent widgets keep the same rhythm whatever
# is installed. Lock the gutter in both orientations: with spacing 0 the
# visual gap is whatever two neighbours happen to add up to, and widgets
# that change size never move their neighbours apart.
gutter_count=$(rg -c 'spacing: Style\.space\(4\)' "$ROOT/shell/plugins/bar/Bar.qml" || true)
[[ $gutter_count == "2" ]] || fail "bar module lists use the uniform gutter" "spacing: Style.space(4) occurrences: $gutter_count"
pass "bar module lists use the uniform gutter"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping bar module spacing runtime test"
  exit 0
fi

# The bar's ModuleSlot sizes itself from the widget's implicitWidth, so the
# row only reflows on resize when widgets report content-driven widths.
# Exercise the real kit buttons the bar depends on: a text pill that grows
# with its label and an icon button that follows its slot, side by side in
# a row with the bar gutter, and prove the sibling moves.
#
# Positioner reflow needs a rendered scene, so the fixture opens a window on
# the offscreen platform: no compositor required, nothing maps on screen.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"

cat >"$test_tmp/shell.qml" <<'QML'
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

  function checkReflow() {
    var gap = Style.space(4)
    if (row.spacing !== gap) {
      fail("row does not use the bar gutter")
      return false
    }
    var expected = pill.x + pill.width + gap
    if (icon.x !== expected) {
      fail("sibling did not reflow: " + icon.x + " vs " + expected)
      return false
    }
    return true
  }

  Component.onCompleted: Qt.callLater(function() {
    var narrow = pill.implicitWidth
    pill.text = "OpenCode · 82%"
    if (!(pill.implicitWidth > narrow)) {
      fail("pill width does not track content")
      return
    }
    var single = icon.implicitWidth
    icon.slotSize = Style.bar.iconSlot * 2
    if (!(icon.implicitWidth > single)) {
      fail("icon slot does not track slotSize")
      return
    }
    settle.restart()
  })

  Timer {
    id: settle
    interval: 300
    onTriggered: {
      if (!root.checkReflow()) return
      console.log("RESULT pass")
      Qt.quit()
    }
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

  Window {
    visible: true
    width: 400
    height: 60

    Row {
      id: row
      anchors.centerIn: parent
      spacing: Style.space(4)
      WidgetButton { id: pill; bar: testBar; text: "X" }
      BarIconButton { id: icon; bar: testBar; text: "x" }
    }
  }
}
QML

output=$(QT_QPA_PLATFORM=offscreen timeout 15 env \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "bar module spacing fixture exits cleanly"
}

if ! grep -q 'RESULT pass' <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "bar modules reflow when item sizes change"
fi

pass "bar modules reflow when item sizes change"
