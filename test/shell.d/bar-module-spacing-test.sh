#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Bar sections keep ink-to-ink gaps uniform by padding every module slot
# from its own painted width, instead of a fixed positioner spacing that
# stacks on top of the widest widget bearings. Lock the mechanism in:
# per-slot compensation driven by paint metrics, zero positioner spacing,
# and the pure-gap spacer exempt.
gutter_count=$(rg -c 'spacing: 0' "$ROOT/shell/plugins/bar/Bar.qml" || true)
[[ $gutter_count == "2" ]] || fail "bar module lists leave spacing to the slots" "spacing: 0 occurrences: $gutter_count"
pass "bar module lists leave spacing to the slots"

for anchor in 'paintHalfGap' 'paintIntrude' 'slotPad' 'paintedExtent' 'paintChild' 'paintItem' 'labelTightWidth' 'iconContentItem' 'BarModel\.slotPad\(' 'BarModel\.paintChild\(activeItem\)' 'omarchy\.spacer'; do
  rg -q "$anchor" "$ROOT/shell/plugins/bar/Bar.qml" || fail "bar normalizes slot spacing from painted widths" "$anchor"
done
pass "bar normalizes slot spacing from painted widths"

run_node_test <<'JS'
const bar = requireFromRoot('shell/plugins/bar/BarModel.js')

// Standard icon: 27px slot, ~11px of tight glyph paint. The padding goes
// slightly negative here: it intrudes into the widget's own empty margin
// to enforce the gap, never into paint.
assertEqual(bar.slotPad(27, 11, 6, 3), -2, 'an icon slot enforces the half gap')
// Text pill: 30px slot, ~13px label.
assertEqual(bar.slotPad(30, 13, 6, 3), -2.5, 'a text pill enforces the half gap')
// Overflowing paint (icon + percentage in an icon slot) pads extra
// instead of touching its neighbour.
assertEqual(bar.slotPad(27, 43, 6, 3), 14, 'overflowing paint is compensated, not clipped')
// Intrusion is bounded: even a wildly over-reported bearing only ever
// overlaps neighbouring hit areas by the cap, never paint.
assertEqual(bar.slotPad(60, 10, 6, 3), -3, 'intrusion stops at the cap')
assertEqual(bar.slotPad(100, 4, 6, 3), -3, 'a lying bearing still stops at the cap')
// Without the cap the padding stays outward-only, as before.
assertEqual(bar.slotPad(30, 13, 6), 0, 'no cap means outward-only padding')
// Hidden widgets stay collapsed and contribute no gap.
assertEqual(bar.slotPad(0, 0, 6, 3), 0, 'a zero span stays collapsed')
assertEqual(bar.slotPad(-4, 0, 6, 3), 0, 'a negative span stays collapsed')
assertEqual(bar.slotPad(27, 11, 0, 3), 0, 'a zero half gap pads nothing')

// The identity the bar relies on: pad + own bearing on both sides of a
// pair always sums to the full uniform gap.
function pairGap(spanA, paintedA, spanB, paintedB, half, cap) {
  const bearing = (span, painted) => (span - painted) / 2
  return bar.slotPad(spanA, paintedA, half, cap) + bearing(spanA, paintedA)
    + bar.slotPad(spanB, paintedB, half, cap) + bearing(spanB, paintedB)
}
assertEqual(pairGap(27, 11, 27, 11, 6, 3), 12, 'two icons land on the uniform gap')
assertEqual(pairGap(27, 11, 30, 13, 6, 3), 12, 'icon and pill land on the uniform gap')
assertEqual(pairGap(27, 43, 27, 11, 6, 3), 12, 'overflowing paint and icon land on the uniform gap')

// The bar measures the button inside the widget root: paint metrics live
// on the button, never on the root, while popup buttons nest deeper.
const bareButton = { labelWidth: 40, children: [] }
assertEqual(bar.paintChild(bareButton), bareButton, 'a root that is the button measures itself')
const service = { refresh: function() {} }
const button = { glyphPaintedWidth: 43 }
const widget = { children: [service, button] }
assertEqual(bar.paintChild(widget), button, 'a button child of the root is measured')
assertEqual(bar.paintChild({ children: [{ children: [button] }] }), null, 'popup-depth buttons are never measured')
assertEqual(bar.paintChild({ children: [service] }), null, 'a root without metrics measures nothing')
assertEqual(bar.paintChild(null), null, 'a missing widget measures nothing')
assertEqual(bar.hasPaintMetrics(button), true, 'glyph paint is a metric')
assertEqual(bar.hasPaintMetrics(service), false, 'service objects carry no metrics')
JS

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping bar module spacing runtime test"
  exit 0
fi

# The compensation above only works when the kit reports truthful paint
# metrics, including text painted wider than its slot. Exercise the real
# buttons the bar measures. Positioner reflow needs a rendered scene, so
# the fixture opens a window on the offscreen platform: no compositor
# required, nothing maps on screen.
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
  property real narrowWidth: 0
  property real narrowTight: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  Component.onCompleted: Qt.callLater(function() {
    narrowWidth = pill.labelWidth
    narrowTight = pill.labelTightWidth
    pill.text = "OpenCode · 82%"
    overflow.text = "X 100%"
    settle.restart()
  })

  Timer {
    id: settle
    interval: 300
    onTriggered: {
      if (!(pill.labelWidth > narrowWidth)) {
        fail("pill paint width does not track content")
        return
      }
      if (!(pill.labelTightWidth > narrowTight)) {
        fail("pill tight width does not track content")
        return
      }
      // Tight bounds exclude the font side bearings, so pills pad from ink
      // like tight-measured icon glyphs. Ink may overshoot the advance
      // slightly, so allow a small tolerance around the label width.
      if (!(pill.labelTightWidth > 0 && Math.abs(pill.labelTightWidth - pill.labelWidth) <= 5)) {
        fail("pill tight width is not a sane measure of its label")
        return
      }
      if (!(glyph.glyphPaintedWidth > 0 && glyph.glyphPaintedWidth < Style.bar.iconSlot)) {
        fail("icon paint width is not inside its slot")
        return
      }
      if (!(overflow.glyphPaintedWidth > Style.bar.iconSlot)) {
        fail("overflowing paint is not visible past its slot")
        return
      }
      if (overflow.opticalSize !== Style.bar.iconCanvas) {
        fail("icon canvas does not match the shared canvas")
        return
      }
      // Vector icons size themselves under the canvas (like the font-sized
      // status icons); the bar must see that size, not a full canvas.
      if (!(vector.iconContentItem && vector.iconContentItem.implicitWidth === 12)) {
        fail("vector icon content is not measurable through the button")
        return
      }
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
      WidgetButton { id: pill; bar: testBar; text: "X" }
      BarIconButton { id: glyph; bar: testBar; text: "x" }
      BarIconButton { id: overflow; bar: testBar; text: "x" }
      BarIconButton {
        id: vector
        bar: testBar
        iconComponent: Component {
          Rectangle { implicitWidth: 12; implicitHeight: 12 }
        }
      }
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
  fail "bar paint metrics track content for slot compensation"
fi

pass "bar paint metrics track content for slot compensation"
