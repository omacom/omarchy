import QtQuick
import qs.Commons

// Item-based surface with Omarchy border specs. Its color/radius/border
// subset is Rectangle-like, but it is not a Rectangle: plugins using
// Rectangle-only properties (gradient, corner radii, border.pixelAligned,
// antialiasing) must use a native Rectangle instead. Native flat/uniform
// borders stay cheap; gradients and per-side widths use BorderOverlay.
CornerRectangle {
  id: root

  property var borderSpec: Border.none()
  property real padding: 0
  property real topPadding: padding
  property real rightPadding: padding
  property real bottomPadding: padding
  property real leftPadding: padding

  readonly property real borderTop: Border.top(borderSpec)
  readonly property real borderRight: Border.right(borderSpec)
  readonly property real borderBottom: Border.bottom(borderSpec)
  readonly property real borderLeft: Border.left(borderSpec)
  readonly property real contentTopInset: borderTop + topPadding
  readonly property real contentRightInset: borderRight + rightPadding
  readonly property real contentBottomInset: borderBottom + bottomPadding
  readonly property real contentLeftInset: borderLeft + leftPadding
  readonly property bool usesOverlayBorder: Border.needsOverlay(borderSpec) || (customCorners && !Border.isNone(borderSpec))

  border.color: Border.canUseNative(borderSpec) ? Border.color(borderSpec) : "transparent"
  border.width: !customCorners && Border.canUseNative(borderSpec) ? Border.uniformWidth(borderSpec) : 0

  Loader {
    anchors.fill: parent
    active: root.usesOverlayBorder

    sourceComponent: BorderOverlay {
      anchors.fill: parent
      radius: root.effectiveRadius
      roundingPower: root.roundingPower
      borderSpec: root.borderSpec
    }
  }
}
