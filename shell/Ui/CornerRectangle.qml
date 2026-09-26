import QtQuick
import QtQuick.Shapes
import qs.Commons
import "../Commons/BorderGeometry.js" as Geometry

// Theme-shaped Rectangle replacement. Intentional circles and pills should
// remain Rectangles, or explicitly set roundingPower: 2.
Item {
  id: root

  // Own these properties rather than aliasing the backing Rectangle: bindings
  // such as radius: parent.radius must resolve in the caller's item context.
  property color color: "white"
  property real radius: 0
  component BorderProperties: QtObject {
    property color color: "black"
    property real width: 0
  }
  readonly property BorderProperties border: BorderProperties {}
  property real roundingPower: Style.cornerRoundingPower
  readonly property bool customCorners: radius > 0 && Geometry.roundingPower(roundingPower) !== 2

  Rectangle {
    anchors.fill: parent
    visible: !root.customCorners
    color: root.color
    radius: root.radius
    border.color: root.border.color
    border.width: root.border.width
    antialiasing: true
  }

  Loader {
    anchors.fill: parent
    active: root.customCorners
    sourceComponent: Item {
      Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
          strokeWidth: 0
          fillColor: root.color
          PathSvg { path: Geometry.surfacePath(root.width, root.height, root.radius, root.roundingPower) }
        }
      }

      BorderOverlay {
        radius: root.radius
        roundingPower: root.roundingPower
        borderSpec: ({ color: root.border.color, widths: Geometry.parseWidthSpec(root.border.width, 0) })
      }
    }
  }
}
