#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "bar icon geometry test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping bar icon geometry test"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"
ln -s "$ROOT/shell/plugins/panels/dropbox/DropboxIcon.qml" "$test_tmp/DropboxIcon.qml"
ln -s "$ROOT/shell/plugins/panels/tailscale/TailscaleIcon.qml" "$test_tmp/TailscaleIcon.qml"

cat >"$test_tmp/shell.qml" <<'QML'
import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root
  property real customWidth: 15
  property bool completed: false
  property bool testsStarted: false
  property int customRenderType: -1
  property real textBoxWidth: 32
  property real alignedTextContentWidth: 0
  property real pathX: 6
  property real pathY: 8
  readonly property bool imageReady: customImage.componentPaintedWidth > 0 && croppedImage.componentPaintedWidth > 0
  readonly property string imageSource: "data:image/svg+xml;base64," + Qt.btoa('<svg xmlns="http://www.w3.org/2000/svg" width="15" height="9"><rect width="15" height="9" fill="white"/></svg>'.split("").map(function(c) { return c.charCodeAt(0) }))

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  function findItem(item, matches) {
    if (matches(item)) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findItem(item.children[i], matches)
      if (found) return found
    }
    return null
  }

  function checkPaintedBounds(icon, name) {
    if (Math.abs(icon.opticalCenterErrorX) > 0.05 || Math.abs(icon.opticalCenterErrorY) > 0.05) {
      fail(name + " painted bounds are off center: " + icon.opticalCenterErrorX + ", " + icon.opticalCenterErrorY)
      return false
    }
    if (Math.abs(Math.max(icon.glyphPaintedWidth, icon.glyphPaintedHeight) - Style.bar.iconSize) > 0.05) {
      fail(name + " painted size is " + icon.glyphPaintedWidth + " × " + icon.glyphPaintedHeight)
      return false
    }
    return true
  }

  function checkIcon(icon, name) {
    if (icon.implicitWidth !== Style.bar.iconSlot) {
      fail(name + " slot width is " + icon.implicitWidth)
      return false
    }
    if (icon.opticalSize !== Style.bar.iconCanvas) {
      fail(name + " optical canvas is " + icon.opticalSize)
      return false
    }
    if (icon.glyphFontSize !== Style.bar.iconFont) {
      fail(name + " font size is " + icon.glyphFontSize)
      return false
    }
    return checkPaintedBounds(icon, name)
  }

  function checkGeometry() {
    if (!checkIcon(bluetooth, "bluetooth")) return false
    if (!checkIcon(network, "network")) return false
    if (!checkIcon(audio, "audio")) return false
    if (!checkIcon(monitor, "monitor")) return false
    if (!checkIcon(power, "power")) return false
    if (!checkIcon(elsewhen, "elsewhen")) return false
    if (!checkIcon(menu, "menu")) return false
    var sourceRatio = sourceMetrics.tightBoundingRect.width / sourceMetrics.tightBoundingRect.height
    if (Math.abs(bluetooth.glyphPaintedWidth / bluetooth.glyphPaintedHeight - sourceRatio) > 0.01) {
      fail("the glyph's aspect ratio changes")
      return false
    }
    if (!checkPaintedBounds(smallFont, "small source font")) return false
    if (!checkPaintedBounds(largeFont, "large source font")) return false
    if (!checkPaintedBounds(customSize, "15px size override")) return false
    if (!checkPaintedBounds(smallCanvas, "small source canvas")) return false
    if (!legacyIcon.iconLabel
        || Math.abs(Math.max(legacyIcon.iconPaintedWidth, legacyIcon.iconPaintedHeight) - Style.bar.iconSize) > 0.05
        || Math.abs(legacyIcon.iconCenterErrorX) > 0.05 || Math.abs(legacyIcon.iconCenterErrorY) > 0.05) {
      fail("a custom WidgetButton does not fit: " + legacyIcon.iconLabel + " "
        + legacyIcon.iconPaintedWidth + " × " + legacyIcon.iconPaintedHeight + " "
        + legacyIcon.iconCenterErrorX + ", " + legacyIcon.iconCenterErrorY)
      return false
    }
    if (textLabel.iconLabel || textLabel.fontSize !== 15) {
      fail("icon normalization changes an ordinary text label")
      return false
    }
    if (customRenderType !== Text.CurveRendering) {
      fail("custom glyphs do not use the scalable renderer")
      return false
    }
    var alignedBounds = centeredGlyph.componentSourceBounds
    var textSpare = root.textBoxWidth - 3 - 5 - root.alignedTextContentWidth
    var expectedTextX = 3 + textSpare / 2 + customTextMetrics.tightBoundingRect.x
    var pathBounds = paddedShape.componentSourceBounds
    if (Math.abs(alignedBounds.x - expectedTextX) > 0.05
        || Math.abs(pathBounds.x - root.pathX) > 0.05 || Math.abs(pathBounds.y - root.pathY) > 0.05
        || Math.abs(pathBounds.width - 12) > 0.05 || Math.abs(pathBounds.height - 10) > 0.05) {
      fail("custom source bounds are incorrect. Text origin: " + alignedBounds.x + " instead of " + expectedTextX
        + ". Shape bounds: " + [pathBounds.x, pathBounds.y, pathBounds.width, pathBounds.height].join(", "))
      return false
    }
    var expectedRightX = 3 + textSpare + customTextMetrics.tightBoundingRect.x
    if (Math.abs(rightGlyph.componentSourceBounds.x - expectedRightX) > 0.05
        || Math.abs(mirroredGlyph.componentSourceBounds.x - expectedRightX) > 0.05) {
      fail("right-aligned or mirrored custom text has an incorrect origin")
      return false
    }
    var shapeScale = Math.min(24 / (root.pathX + 12), 36 / (root.pathY + 10))
    var fittedBounds = fittedShape.componentSourceBounds
    if (Math.abs(fittedBounds.x - root.pathX * shapeScale) > 0.05
        || Math.abs(fittedBounds.y - (36 - 10 * shapeScale)) > 0.05
        || Math.abs(fittedBounds.width - 12 * shapeScale) > 0.05
        || Math.abs(fittedBounds.height - 10 * shapeScale) > 0.05) {
      fail("a resized shape's path bounds ignore its fill mode or alignment")
      return false
    }
    var customIcons = [customBox, nestedBox, customGlyph, rotatedBox, customImage, croppedImage,
      centeredGlyph, rightGlyph, mirroredGlyph, paddedShape, fittedShape]
    for (var i = 0; i < customIcons.length; i++) {
      var custom = customIcons[i]
      if (Math.abs(Math.max(custom.componentPaintedWidth, custom.componentPaintedHeight) - Style.bar.iconSize) > 0.05
          || Math.abs(custom.opticalCenterErrorX) > 0.05 || Math.abs(custom.opticalCenterErrorY) > 0.05) {
        fail("custom component " + i + " does not fit: " + custom.componentPaintedWidth + " × "
          + custom.componentPaintedHeight + " " + custom.opticalCenterErrorX + ", " + custom.opticalCenterErrorY)
        return false
      }
    }
    if (Math.abs(customBox.componentPaintedWidth / customBox.componentPaintedHeight - root.customWidth / 9) > 0.01
        || Math.abs(rotatedBox.componentPaintedWidth / rotatedBox.componentPaintedHeight - 9 / 15) > 0.01
        || Math.abs(customImage.componentPaintedWidth / customImage.componentPaintedHeight - 15 / 9) > 0.01
        || Math.abs(croppedImage.componentPaintedWidth / croppedImage.componentPaintedHeight - 1) > 0.01) {
      fail("a custom component's aspect ratio changes")
      return false
    }
    if (!checkPaintedBounds(labelledPower, "battery percentage")) return false
    if (Math.abs(labelledPower.glyphPaintedWidth - power.glyphPaintedWidth) > 0.05
        || Math.abs(labelledPower.glyphPaintedHeight - power.glyphPaintedHeight) > 0.05) {
      fail("the battery percentage changes the icon's size")
      return false
    }
    // The percentage reads before the icon: "100% 󰁹", not "󰁹 100%".
    var percentLabel = findItem(labelledPower, function(item) { return item.text === "100%" })
    var batteryGlyph = findItem(labelledPower, function(item) { return item.paintedSize !== undefined && item.text === "󰁹" })
    if (!percentLabel || !batteryGlyph) {
      fail("the battery percentage fixture has a label and a glyph")
      return false
    }
    var labelRight = percentLabel.mapToItem(labelledPower, percentLabel.implicitWidth, 0).x
    var glyphLeft = batteryGlyph.mapToItem(labelledPower, batteryGlyph.paintedCenterX - batteryGlyph.paintedWidth / 2, 0).x
    if (labelRight > glyphLeft) {
      fail("the battery percentage ends at " + labelRight + ", past the icon's left edge at " + glyphLeft)
      return false
    }
    if (vector.implicitWidth !== Style.bar.iconSlot || vector.opticalSize !== Style.bar.iconCanvas) {
      fail("vector icon does not share glyph geometry")
      return false
    }
    if (verticalIcon.implicitWidth !== Style.bar.sizeVertical || verticalIcon.implicitHeight !== Style.bar.iconSlot) {
      fail("vertical icon does not use the shared slot")
      return false
    }
    if (!checkPaintedBounds(verticalIcon, "vertical icon")) return false
    if (!checkPaintedBounds(horizontalIndicator, "horizontal indicator")) return false
    if (!checkPaintedBounds(verticalIndicator, "vertical indicator")) return false
    if (verticalIndicator.implicitWidth !== Style.bar.sizeVertical || verticalIndicator.implicitHeight >= Style.bar.iconSlot) {
      fail("vertical indicator does not retain compact spacing")
      return false
    }
    if (horizontalIndicator.implicitWidth >= Style.bar.iconSlot) {
      fail("horizontal indicator does not retain compact spacing")
      return false
    }
    if (horizontalIndicatorPair.implicitWidth >= Style.bar.iconSlot * 2
        || verticalIndicatorPair.implicitHeight >= Style.bar.iconSlot * 2) {
      fail("indicator groups do not retain compact internal spacing")
      return false
    }
    if (compactStatusIcon.implicitWidth !== Style.bar.statusSlot
        || compactVerticalStatusIcon.implicitHeight !== Style.bar.statusSlot) {
      fail("compact status icons do not use the shared status slot")
      return false
    }
    if (!checkPaintedBounds(compactStatusIcon, "compact status icon")) return false
    if (!checkPaintedBounds(compactVerticalStatusIcon, "compact vertical status icon")) return false
    if (!checkPaintedBounds(rotatedIcon, "rotated icon")) return false
    if (Math.abs(Math.max(dropbox.width, dropbox.height) - Style.bar.iconSize) > 0.05
        || Math.abs(Math.max(tailscale.width, tailscale.height) - Style.bar.iconSize) > 0.05) {
      fail("vector icons do not use the shared visual size")
      return false
    }
    return true
  }

  function runGeometryTests() {
    if (testsStarted) return
    testsStarted = true
    if (!checkGeometry()) return
    var labelBaseline = plainLabel.baselineY
    root.customWidth = 23
    root.textBoxWidth = 48
    root.pathX = 2
    root.pathY = 3
    Style.applyShellValues({ "font.base-size": "18", "bar.icon-size": "14", "bar.icon-canvas": "19" })
    Qt.callLater(function() {
      if (!checkGeometry()) return
      if (Style.bar.iconSize !== 21 || Style.bar.iconCanvas !== 29) {
        fail("theme icon dimensions do not follow the font scale")
        return
      }
      if (plainLabel.baselineY !== labelBaseline) {
        fail("bar icon settings change a text label's baseline")
        return
      }
      Style.applyShellValues({ "font.base-size": "18", "bar.scale-with-font": "false", "bar.icon-size": "20" })
      Qt.callLater(function() {
        if (!checkGeometry()) return
        if (Style.bar.iconSize !== Style.bar.iconCanvas) {
          fail("oversized icons do not fit their canvas")
          return
        }
        console.log("RESULT pass")
        Qt.quit()
      })
    })
  }

  onImageReadyChanged: if (imageReady && completed) Qt.callLater(runGeometryTests)
  Component.onCompleted: {
    completed = true
    if (imageReady) Qt.callLater(runGeometryTests)
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

  BarIconButton { id: bluetooth; bar: testBar; text: "󰂯" }
  BarIconButton { id: network; bar: testBar; text: "󰖩" }
  BarIconButton { id: audio; bar: testBar; text: "󰖁" }
  BarIconButton { id: monitor; bar: testBar; text: "󰍹" }
  BarIconButton { id: power; bar: testBar; text: "󰁹" }
  BarIconButton { id: elsewhen; bar: testBar; text: "󰇧" }
  TextMetrics {
    id: sourceMetrics
    font.family: testBar.fontFamily
    font.pixelSize: Style.bar.iconFont
    text: bluetooth.text
  }
  BarIconButton { id: menu; bar: testBar; text: "\ue900"; fontFamily: "omarchy" }
  BarIconButton { id: smallFont; bar: testBar; text: "\uf053"; fontSize: 8 }
  BarIconButton { id: largeFont; bar: testBar; text: "󰍹"; fontSize: 24 }
  BarIconButton { id: customSize; bar: testBar; text: "󰍹"; iconSize: 15 }
  BarIconButton { id: smallCanvas; bar: testBar; text: "󰍹"; opticalSize: 8 }
  WidgetButton { id: legacyIcon; bar: testBar; text: "󰍹"; fontSize: 15 }
  WidgetButton { id: textLabel; bar: testBar; text: "GPU"; fontSize: 15 }
  BarIconButton {
    id: customBox
    bar: testBar
    iconSize: 15
    iconComponent: Component { Rectangle { width: root.customWidth; height: 9; color: "white" } }
  }
  BarIconButton {
    id: nestedBox
    bar: testBar
    iconComponent: Component {
      Item {
        Rectangle { x: 1; y: 5; width: 15; height: 9; color: "white" }
      }
    }
  }
  BarIconButton {
    id: customGlyph
    bar: testBar
    iconComponent: Component {
      Text {
        textFormat: Text.PlainText
        text: "\ue900"
        font.family: "omarchy"
        font.pixelSize: 15
        onRenderTypeChanged: root.customRenderType = renderType
      }
    }
  }
  TextMetrics {
    id: customTextMetrics
    font.family: "omarchy"
    font.pixelSize: 15
    text: "\ue900"
  }
  component AlignedTextIcon: Text {
    width: root.textBoxWidth
    height: 28
    leftPadding: 3
    rightPadding: 5
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    textFormat: Text.PlainText
    text: "\ue900"
    font.family: "omarchy"
    font.pixelSize: 15
  }
  BarIconButton {
    id: centeredGlyph
    bar: testBar
    iconComponent: Component {
      AlignedTextIcon {
        id: alignedText
        onContentWidthChanged: root.alignedTextContentWidth = alignedText.contentWidth
        Component.onCompleted: root.alignedTextContentWidth = alignedText.contentWidth
      }
    }
  }
  BarIconButton {
    id: rightGlyph
    bar: testBar
    iconComponent: Component { AlignedTextIcon { horizontalAlignment: Text.AlignRight } }
  }
  BarIconButton {
    id: mirroredGlyph
    bar: testBar
    iconComponent: Component {
      AlignedTextIcon {
        horizontalAlignment: Text.AlignLeft
        LayoutMirroring.enabled: true
      }
    }
  }
  component PaddedShapeIcon: Shape {
    width: 24
    height: 24
    ShapePath {
      strokeWidth: 0
      fillColor: "white"
      startX: root.pathX
      startY: root.pathY
      PathLine { x: root.pathX + 12; y: root.pathY }
      PathLine { x: root.pathX + 12; y: root.pathY + 10 }
      PathLine { x: root.pathX; y: root.pathY + 10 }
      PathLine { x: root.pathX; y: root.pathY }
    }
  }
  BarIconButton {
    id: paddedShape
    bar: testBar
    iconComponent: Component { PaddedShapeIcon {} }
  }
  BarIconButton {
    id: fittedShape
    bar: testBar
    iconComponent: Component {
      PaddedShapeIcon {
        height: 36
        fillMode: Shape.PreserveAspectFit
        horizontalAlignment: Shape.AlignHCenter
        verticalAlignment: Shape.AlignBottom
      }
    }
  }
  BarIconButton {
    id: rotatedBox
    bar: testBar
    iconComponent: Component { Rectangle { width: 15; height: 9; rotation: 90; color: "white" } }
  }
  BarIconButton {
    id: customImage
    bar: testBar
    iconComponent: Component {
      Image {
        fillMode: Image.PreserveAspectFit
        source: root.imageSource
      }
    }
  }
  BarIconButton {
    id: croppedImage
    bar: testBar
    iconComponent: Component {
      Image {
        width: 15
        height: 15
        fillMode: Image.PreserveAspectCrop
        source: root.imageSource
      }
    }
  }
  BarIconButton { id: labelledPower; bar: testBar; text: "󰁹"; labelText: "100%"; slotSize: Style.bar.iconSlot * 2 }
  BarIconButton { id: rotatedIcon; bar: verticalBar; text: "\uf053"; textRotation: 90 }
  OpticalGlyph { id: plainLabel; width: 30; height: 20; text: "12"; fontSize: 12 }
  DropboxIcon { id: dropbox; iconSize: Style.bar.iconSize / aspectRatio; artworkScale: 1 }
  TailscaleIcon { id: tailscale; iconSize: Style.bar.iconSize }
  BarIconButton {
    id: vector
    bar: testBar
    iconComponent: Component { Rectangle { width: 12; height: 12 } }
  }
  BarIconButton { id: verticalIcon; bar: verticalBar; text: "\uf021" }
  BarIconButton { id: compactStatusIcon; bar: testBar; text: "\uf021"; slotSize: Style.bar.statusSlot }
  BarIconButton { id: compactVerticalStatusIcon; bar: verticalBar; text: "\uf021"; slotSize: Style.bar.statusSlot }
  Row {
    id: horizontalIndicatorPair
    BarIndicator { id: horizontalIndicator; bar: testBar; active: true; activeText: "󰅶" }
    BarIndicator { bar: testBar; active: true; activeText: "󰔎" }
  }
  Column {
    id: verticalIndicatorPair
    BarIndicator { id: verticalIndicator; bar: verticalBar; active: true; activeText: "󰅶" }
    BarIndicator { bar: verticalBar; active: true; activeText: "󰔎" }
  }
}
QML

output=$(timeout 15 env \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "bar icon geometry fixture exits cleanly"
}

if ! grep -q 'RESULT pass' <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "bar icons share visual size and center geometry"
fi

pass "bar icons share visual size and center geometry"
