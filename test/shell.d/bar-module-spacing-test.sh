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

for anchor in 'paintHalfGap' 'paintIntrude' 'slotPad' 'paintedExtent' 'paintChild' 'paintItem' 'labelTightWidth' 'labelTightHeight' 'glyphPaintedHeight' 'iconContentItem' 'vectorPaintedExtent' 'targetInSlot' 'BarModel\.slotPad\(' 'BarModel\.paintChild\(activeItem\)' 'BarModel\.paintedExtent\(' 'BarModel\.targetInSlot\(target, slot\)' 'omarchy\.spacer'; do
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
// Scaled bar font (half gap 8, intrude 5): a wide-bearing text pill next to
// a status icon. The pill needs 4.5px of intrusion; a narrower cap would
// clamp and leave a 16.5px residual instead of the uniform 16px.
assertEqual(bar.slotPad(37, 12, 8, 5), -4.5, 'a scaled pill intrudes past the old cap')
assertEqual(bar.slotPad(37, 12, 8, 4), -4, 'a narrower cap clamps instead of equalizing')
assertEqual(pairGap(37, 12, 28, 11, 8, 5), 16, 'scaled pill and icon land on the uniform gap')

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

// Vector icon content arrives as-is from its panel: tailscale and dropbox
// center the real icon in a bare Item wrapper with no implicit size, so the
// bar must measure through the wrapper instead of falling back to the
// full canvas.
assertDeepEqual(bar.vectorPaintedExtent(null), { width: 0, height: 0 }, 'missing vector content measures nothing')
assertDeepEqual(bar.vectorPaintedExtent({ implicitWidth: 12, implicitHeight: 12 }), { width: 12, height: 12 }, 'a directly sized icon measures itself')
assertDeepEqual(
  bar.vectorPaintedExtent({ children: [{ implicitWidth: 11, implicitHeight: 11 }] }),
  { width: 11, height: 11 },
  'a tailscale-style wrapper measures its icon, not the canvas'
)
assertDeepEqual(
  bar.vectorPaintedExtent({ children: [{ implicitWidth: 14.16, implicitHeight: 12 }] }),
  { width: 14.16, height: 12 },
  'a dropbox-style wrapper keeps its aspect'
)
assertDeepEqual(
  bar.vectorPaintedExtent({ children: [service, { implicitWidth: 11, implicitHeight: 11 }] }),
  { width: 11, height: 11 },
  'non-visual wrapper children drop out'
)
assertDeepEqual(
  bar.vectorPaintedExtent({ children: [{ children: [{ children: [{ children: [{ implicitWidth: 11, implicitHeight: 11 }] }] }] }] }),
  { width: 0, height: 0 },
  'the wrapper scan stays shallow'
)

// The painted-extent decision tree the slot delegates to: every branch,
// both axes.
assertEqual(bar.paintedExtent({ vertical: false, glyphPaintedWidth: 11, contentWidth: 27 }), 11, 'a glyph measures its paint')
assertEqual(bar.paintedExtent({ vertical: false, labelTightWidth: 13, labelWidth: 16, contentWidth: 30 }), 13, 'tight label ink wins over advance')
assertEqual(bar.paintedExtent({ vertical: false, labelWidth: 40, contentWidth: 52 }), 40, 'a custom label measures its advance')
assertEqual(bar.paintedExtent({ vertical: false, vectorWidth: 12, vectorHeight: 12, opticalSize: 16, contentWidth: 27 }), 12, 'a vector icon measures under the canvas')
assertEqual(bar.paintedExtent({ vertical: false, vectorWidth: 11, vectorHeight: 11, opticalSize: 16, contentWidth: 27 }), 11, 'a wrapped vector icon keeps its mark, not the canvas')
assertEqual(bar.paintedExtent({ vertical: false, vectorWidth: 24, vectorHeight: 24, opticalSize: 16, contentWidth: 27 }), 16, 'an over-reporting vector caps at the canvas')
assertEqual(bar.paintedExtent({ vertical: false, vectorWidth: 12, vectorHeight: 12, contentWidth: 27 }), 12, 'a vector without canvas measures itself')
assertEqual(bar.paintedExtent({ vertical: false, opticalSize: 16, contentWidth: 27 }), 16, 'an unmeasurable icon falls back to the canvas')
assertEqual(bar.paintedExtent({ vertical: false, contentWidth: 27 }), 27, 'an opaque custom falls back to full-bleed')
assertEqual(bar.paintedExtent(null), 0, 'a missing snapshot measures nothing')
assertEqual(bar.paintedExtent({ vertical: true, glyphPaintedHeight: 12, opticalSize: 16, contentHeight: 27 }), 12, 'a vertical glyph measures its ink, not the canvas')
assertEqual(bar.paintedExtent({ vertical: true, labelTightHeight: 20, contentHeight: 34 }), 20, 'a vertical label measures its ink, not the slot')
assertEqual(bar.paintedExtent({ vertical: true, vectorWidth: 11, vectorHeight: 11, opticalSize: 16, contentHeight: 27 }), 11, 'a vertical vector measures its mark')
assertEqual(bar.paintedExtent({ vertical: true, vectorWidth: 24, vectorHeight: 24, opticalSize: 16, contentHeight: 27 }), 16, 'a vertical over-report caps at the canvas')
assertEqual(bar.paintedExtent({ vertical: true, opticalSize: 16, contentHeight: 27 }), 16, 'a vertical icon without ink metrics keeps the canvas')
assertEqual(bar.paintedExtent({ vertical: true, contentHeight: 27 }), 27, 'a vertical opaque custom falls back to full-bleed')

// Clicks resolve per slot: only the slot's own targets compete, so a
// neighbour's button overlapping a negatively padded edge cannot steal
// the press; the slot falls back to its own active item instead.
const slotA = { activeItem: { id: 'a' } }
const buttonA = { parent: slotA.activeItem }
const nestedA = { parent: buttonA }
const slotB = { activeItem: { id: 'b' } }
const buttonB = { parent: slotB.activeItem }
assertEqual(bar.targetInSlot(buttonA, slotA), true, 'a slot button belongs to its slot')
assertEqual(bar.targetInSlot(nestedA, slotA), true, 'a nested target belongs to its slot')
assertEqual(bar.targetInSlot(slotA.activeItem, slotA), true, 'an active item belongs to its slot')
assertEqual(bar.targetInSlot(buttonB, slotA), false, 'a neighbour button does not belong to this slot')
assertEqual(bar.targetInSlot(buttonA, slotB), false, 'scoping is per slot, not global')
assertEqual(bar.targetInSlot(null, slotA), false, 'a missing target belongs nowhere')
assertEqual(bar.targetInSlot(buttonA, null), false, 'a target without a slot belongs nowhere')
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
ln -s "$ROOT/shell/plugins/bar/BarModel.js" "$test_tmp/BarModel.js"

cat >"$test_tmp/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "BarModel.js" as BarModel

ShellRoot {
  id: root

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  // The slot geometry identity the bar relies on: pad + own bearing on one
  // side always sums to the uniform half gap, whatever the widget paints.
  function gapHolds(span, painted) {
    var half = Style.space(6)
    var bearing = (span - painted) / 2
    return Math.abs(BarModel.slotPad(span, painted, half, Style.space(4)) + bearing - half) < 0.01
  }

  Component.onCompleted: Qt.callLater(function() {
    narrowWidth = pill.labelWidth
    narrowTight = pill.labelTightWidth
    pill.text = "OpenCode · 82%"
    overflow.text = "X 100%"
    settle.restart()
  })

  property real narrowWidth: 0
  property real narrowTight: 0

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
      // Tailscale/dropbox panels wrap the real icon in a bare Item with no
      // implicit size: the slot must measure through the wrapper to the
      // ~11px mark, not fall back to the 16px canvas.
      var wrappedSize = BarModel.vectorPaintedExtent(wrapped.iconContentItem)
      if (!(wrappedSize.width === 11 && wrappedSize.height === 11)) {
        fail("wrapped vector icon is not measured through its wrapper")
        return
      }
      var wrappedPainted = BarModel.paintedExtent({
        vertical: false,
        vectorWidth: wrappedSize.width,
        vectorHeight: wrappedSize.height,
        opticalSize: wrapped.opticalSize,
        contentWidth: wrapped.implicitWidth
      })
      if (wrappedPainted !== 11) {
        fail("wrapped vector extent is not the icon mark")
        return
      }
      if (!(wrappedPainted < wrapped.opticalSize)) {
        fail("wrapped vector extent falls back to the canvas")
        return
      }
      // Slot-level check on rendered buttons: pad + own bearing lands on
      // the uniform half gap for every horizontal paint kind.
      var glyphPainted = BarModel.paintedExtent({ vertical: false, glyphPaintedWidth: glyph.glyphPaintedWidth, contentWidth: glyph.implicitWidth })
      var pillPainted = BarModel.paintedExtent({ vertical: false, labelTightWidth: pill.labelTightWidth, labelWidth: pill.labelWidth, contentWidth: pill.implicitWidth })
      var vectorPainted = BarModel.paintedExtent({ vertical: false, vectorWidth: 12, vectorHeight: 12, opticalSize: vector.opticalSize, contentWidth: vector.implicitWidth })
      if (!gapHolds(glyph.implicitWidth, glyphPainted)) {
        fail("icon slot does not land on the uniform gap")
        return
      }
      if (!gapHolds(pill.implicitWidth, pillPainted)) {
        fail("pill slot does not land on the uniform gap")
        return
      }
      if (!gapHolds(vector.implicitWidth, vectorPainted)) {
        fail("vector slot does not land on the uniform gap")
        return
      }
      if (!gapHolds(wrapped.implicitWidth, wrappedPainted)) {
        fail("wrapped vector slot does not land on the uniform gap")
        return
      }
      // Vertical bar: tight ink heights, not the canvas or the full slot.
      var glyphVPainted = BarModel.paintedExtent({ vertical: true, glyphPaintedHeight: glyphV.glyphPaintedHeight, opticalSize: glyphV.opticalSize, contentHeight: glyphV.implicitHeight })
      if (!(glyphV.glyphPaintedHeight > 0 && glyphVPainted === glyphV.glyphPaintedHeight)) {
        fail("vertical icon paint height is not measured")
        return
      }
      if (!(glyphVPainted < glyphV.opticalSize)) {
        fail("vertical icon extent falls back to the canvas")
        return
      }
      var pillVPainted = BarModel.paintedExtent({ vertical: true, labelTightHeight: pillV.labelTightHeight, contentHeight: pillV.implicitHeight })
      if (!(pillV.labelTightHeight > 0 && pillVPainted === pillV.labelTightHeight)) {
        fail("vertical label paint height is not measured")
        return
      }
      // Multi-line stacks cannot tighten (TextMetrics bounds do not span
      // lines), so they keep the full-bleed fallback instead of collapsing.
      if (!(pillVStack.labelTightHeight === 0)) {
        fail("stacked label pretends to a tight height")
        return
      }
      var stackPainted = BarModel.paintedExtent({ vertical: true, labelTightHeight: pillVStack.labelTightHeight, contentHeight: pillVStack.implicitHeight })
      if (!(stackPainted === pillVStack.implicitHeight)) {
        fail("stacked label does not keep full-bleed")
        return
      }
      var vectorVSize = BarModel.vectorPaintedExtent(vectorV.iconContentItem)
      var vectorVPainted = BarModel.paintedExtent({ vertical: true, vectorWidth: vectorVSize.width, vectorHeight: vectorVSize.height, opticalSize: vectorV.opticalSize, contentHeight: vectorV.implicitHeight })
      if (!(vectorVPainted === 11)) {
        fail("vertical vector extent is not the icon mark")
        return
      }
      if (!gapHolds(glyphV.implicitHeight, glyphVPainted)) {
        fail("vertical icon slot does not land on the uniform gap")
        return
      }
      if (!gapHolds(pillV.implicitHeight, pillVPainted)) {
        fail("vertical label slot does not land on the uniform gap")
        return
      }
      if (!gapHolds(pillVStack.implicitHeight, stackPainted)) {
        fail("stacked label slot does not land on the uniform gap")
        return
      }
      if (!gapHolds(vectorV.implicitHeight, vectorVPainted)) {
        fail("vertical vector slot does not land on the uniform gap")
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

  QtObject {
    id: testBarV
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
      // Tailscale/dropbox shape: the real icon centered in a bare Item
      // wrapper with no implicit size of its own.
      BarIconButton {
        id: wrapped
        bar: testBar
        iconComponent: Component {
          Item {
            Rectangle { anchors.centerIn: parent; implicitWidth: 11; implicitHeight: 11 }
          }
        }
      }
      BarIconButton { id: glyphV; bar: testBarV; text: "x" }
      WidgetButton { id: pillV; bar: testBarV; text: "AB" }
      WidgetButton { id: pillVStack; bar: testBarV; text: "A\nB" }
      BarIconButton {
        id: vectorV
        bar: testBarV
        iconComponent: Component {
          Rectangle { implicitWidth: 11; implicitHeight: 11 }
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
