import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import "../Commons/BorderGeometry.js" as Geometry

// Rectangle-compatible surface with Omarchy border specs. Uses native
// Rectangle.border for cheap flat/uniform borders and BorderOverlay for
// gradients or per-side widths.
//
// When Hyprland uses triangular corners (Style.cornerChamfer), the surface
// is masked to a 45°-cut outline and the border is drawn along that outline,
// so shell surfaces match window corners. Rounded themes keep the original,
// unmasked path.
Rectangle {
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
  readonly property bool chamfered: Style.cornerChamfer && radius > 0
  // Hyprland cuts window corners at rounding * rounding_power / 2
  // (CWindow::rounding), so scale the radius the same way. A cut as deep as
  // half the height still turns short surfaces (rows, OSD, notifications)
  // into hexagons, so it is also capped relative to the shorter side.
  readonly property real chamferSize: Math.min(radius * Style.cornerPower / 2, Math.min(width, height) * 0.3)
  readonly property bool usesOverlayBorder: Border.needsOverlay(borderSpec) || chamfered

  // The native fill would clamp `radius` to half the height and round the
  // corners inside the cut, so paint it square and let the mask cut it.
  topLeftRadius: chamfered ? 0 : radius
  topRightRadius: chamfered ? 0 : radius
  bottomLeftRadius: chamfered ? 0 : radius
  bottomRightRadius: chamfered ? 0 : radius

  border.color: Border.canUseNative(borderSpec) ? Border.color(borderSpec) : "transparent"
  border.width: Border.canUseNative(borderSpec) && !chamfered ? Border.uniformWidth(borderSpec) : 0

  layer.enabled: chamfered
  layer.effect: MultiEffect {
    maskEnabled: true
    maskSource: chamferMask
    maskThresholdMin: 0.5
    maskSpreadAtMin: 1.0
  }

  Item {
    id: chamferMask

    anchors.fill: parent
    visible: false
    layer.enabled: root.chamfered

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        strokeWidth: 0
        strokeColor: "transparent"
        fillColor: "white"
        PathSvg { path: root.chamfered ? Geometry.surfacePath(root.width, root.height, root.chamferSize, true) : "" }
      }
    }
  }

  Loader {
    anchors.fill: parent
    active: root.usesOverlayBorder

    sourceComponent: BorderOverlay {
      anchors.fill: parent
      radius: root.chamfered ? root.chamferSize : root.radius
      chamfer: root.chamfered
      borderSpec: root.borderSpec
    }
  }
}
