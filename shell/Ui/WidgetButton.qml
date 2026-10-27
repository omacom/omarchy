import QtQuick
import qs.Commons
import qs.Commons as Commons

Item {
  id: root

  property var bar: null
  property string text: ""
  property string fontFamily: bar ? bar.fontFamily : Style.font.family
  property real fontSize: Style.font.body
  property color foreground: bar ? bar.barForeground : Commons.Color.foreground
  property color activeColor: bar ? bar.urgent : Commons.Color.urgent
  property bool active: false
  property real horizontalMargin: 8.5
  property real verticalPadding: 6
  property real fixedWidth: -1
  property real fixedHeight: -1
  property real textRotation: 0
  property bool keepSpace: false
  property bool dimmed: false
  property bool concealed: false
  property bool interactive: true
  property bool pressable: true
  property bool useActiveColor: true
  property bool maintainIndicatorReveal: false
  property bool labelVisible: true
  // Off for icon-font labels, whose figure metrics say nothing about the glyph.
  property bool centerFigures: true
  property bool hasVisualContent: text !== ""
  property var revealHost: bar
  property string tooltipText: ""
  property var registeredBar: null
  // Set by the bar while its own press handler, laid over the widget for
  // dragging, holds this button down; mouseArea never sees that press.
  property int heldButtons: Qt.NoButton
  // The mouse buttons the mark gives under. A button whose click changes the
  // mark itself, like the clock's format cycle, is left out.
  property int pressFeedbackButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

  signal pressed(int button)
  signal wheelMoved(int delta)

  function triggerPress(button) {
    if (root.bar) root.bar.hideTooltip(root)
    root.pressed(button)
  }

  function hideOwnTooltip() {
    if (root.bar) root.bar.hideTooltip(root)
  }

  function syncClickRegistration() {
    if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)
    registeredBar = root.bar
    if (registeredBar && registeredBar.registerClickTarget) registeredBar.registerClickTarget(root)
  }

  onBarChanged: syncClickRegistration()
  onVisibleChanged: if (!visible) hideOwnTooltip()
  onInteractiveChanged: if (!interactive) hideOwnTooltip()
  onConcealedChanged: if (concealed) hideOwnTooltip()
  Component.onCompleted: syncClickRegistration()
  Component.onDestruction: if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)

  readonly property bool vertical: bar ? bar.vertical : false
  readonly property int barSize: bar ? bar.barSize : Style.bar.sizeHorizontal
  readonly property real scaledHorizontalMargin: Style.spaceReal(horizontalMargin)
  readonly property real scaledVerticalPadding: Style.spaceReal(verticalPadding)
  readonly property bool tooltipHovered: visible && interactive && !concealed && mouseArea.containsMouse
  // Width of the painted label, for bar chrome that wants to line up with the
  // text rather than with the slot it sits in. Zero on icon-only buttons.
  readonly property real labelWidth: label.visible ? label.implicitWidth : 0
  readonly property bool iconLabel: labelVisible && isIconGlyph(text)
  readonly property real iconPaintedWidth: iconLabel && iconLoader.item ? iconLoader.item.paintedWidth : 0
  readonly property real iconPaintedHeight: iconLabel && iconLoader.item ? iconLoader.item.paintedHeight : 0
  readonly property real iconCenterErrorX: iconLabel && iconLoader.item
    ? iconLoader.x + iconLoader.item.paintedCenterX - width / 2 : 0
  readonly property real iconCenterErrorY: iconLabel && iconLoader.item
    ? iconLoader.y + iconLoader.item.paintedCenterY - height / 2 : 0

  function isIconGlyph(value) {
    var text = String(value || "")
    if (!text) return false
    var code = text.codePointAt(0)
    if (text.length !== (code > 0xffff ? 2 : 1)) return false
    return (code >= 0xe000 && code <= 0xf8ff)
      || (code >= 0xf0000 && code <= 0xffffd)
      || (code >= 0x100000 && code <= 0x10fffd)
      || (code >= 0x2190 && code <= 0x2bff)
  }

  visible: hasVisualContent || keepSpace
  opacity: !hasVisualContent || concealed ? 0 : (dimmed ? 0.45 : 1)
  implicitWidth: fixedWidth > 0 ? fixedWidth
    : (vertical ? barSize : (iconLabel ? Style.bar.iconSlot : Math.max(12, label.implicitWidth + scaledHorizontalMargin * 2)))
  implicitHeight: fixedHeight > 0 ? fixedHeight
    : (vertical ? (iconLabel ? Style.bar.iconSlot : Math.max(12, label.implicitHeight + scaledVerticalPadding * 2)) : barSize)

  Behavior on opacity {
    NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
  }

  // Held down, the mark gives a little, so a click is felt as well as seen.
  // Only the label and glyph shrink, never the button, so the hit area and
  // the bar's layout hold still. A bar glyph is small, so it gives more than
  // a panel button's 0.97, or nothing would show.
  property real pressScale: root.pressable && ((mouseArea.pressedButtons | root.heldButtons) & root.pressFeedbackButtons) ? 0.9 : 1
  Behavior on pressScale {
    NumberAnimation {
      duration: Style.duration(160)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  Text {
    id: label
    textFormat: Text.PlainText
    visible: root.labelVisible && !root.iconLabel
    anchors.centerIn: parent
    // Centering the line box puts the figures above the bar's middle, since
    // the box keeps room for descenders. Center the figure height instead, so
    // labels line up with the icons beside them.
    anchors.verticalCenterOffset: !root.centerFigures || root.vertical || root.text.indexOf("\n") !== -1
      ? 0
      : (labelMetrics.descent - labelMetrics.ascent + labelMetrics.tightBoundingRect("0").height) / 2
    text: root.text
    color: root.active && root.useActiveColor ? root.activeColor : root.foreground
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    renderType: Text.NativeRendering
    rotation: root.textRotation
    scale: root.pressScale
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
      enabled: !root.bar || root.bar.foregroundAnimationEnabled
      ColorAnimation { duration: Style.duration(160) }
    }
  }

  FontMetrics {
    id: labelMetrics
    font: label.font
  }

  Loader {
    id: iconLoader
    active: root.iconLabel
    width: Style.bar.iconCanvas
    height: Style.bar.iconCanvas
    x: (root.width - width) / 2
    y: (root.height - height) / 2
    scale: root.pressScale
    sourceComponent: Component {
      OpticalGlyph {
        text: root.text
        fontFamily: root.fontFamily
        fontSize: root.fontSize
        paintedSize: Style.bar.iconSize
        color: root.active && root.useActiveColor ? root.activeColor : root.foreground
        rotation: root.textRotation
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    enabled: root.interactive
    hoverEnabled: true
    cursorShape: root.pressable ? Qt.PointingHandCursor : Qt.ArrowCursor
    onEntered: {
      if (root.bar) {
        root.bar.showTooltip(root, root.tooltipText)
      }
      if (root.maintainIndicatorReveal && root.revealHost && root.revealHost.setIndicatorItemHovered)
        root.revealHost.setIndicatorItemHovered(true)
    }
    onExited: {
      if (root.bar) {
        root.bar.hideTooltip(root)
      }
      if (root.maintainIndicatorReveal && root.revealHost && root.revealHost.setIndicatorItemHovered)
        root.revealHost.setIndicatorItemHovered(false)
    }
    onClicked: function(mouse) { if (root.pressable) root.triggerPress(mouse.button) }
    onWheel: function(wheel) { root.wheelMoved(wheel.angleDelta.y) }
  }
}
