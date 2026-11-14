import QtQuick
import QtQuick.Shapes
import "../Commons/BorderGeometry.js" as Geometry

// Visual-only rounded fill. Solid surfaces keep the native Rectangle path.
Item {
  id: root

  property var fillSpec: null
  property real radius: 0

  readonly property var colors: fillSpec && fillSpec.gradient ? fillSpec.gradient.colors : []
  readonly property var endpoints: Geometry.gradientEndpoints(width, height, fillSpec && fillSpec.gradient ? fillSpec.gradient.angle : 0)
  readonly property real corner: Math.max(0, Math.min(radius, width / 2, height / 2))
  readonly property string outline: Geometry.roundedRectPath(0, 0, width, height, {
    tlrx: corner, tlry: corner, trrx: corner, trry: corner,
    brrx: corner, brry: corner, blrx: corner, blry: corner
  })

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeWidth: 0
      fillGradient: LinearGradient {
        x1: root.endpoints.x1
        y1: root.endpoints.y1
        x2: root.endpoints.x2
        y2: root.endpoints.y2

        GradientStop { position: Geometry.stopPosition(root.colors, 0); color: Geometry.stopColor(root.colors, 0) }
        GradientStop { position: Geometry.stopPosition(root.colors, 1); color: Geometry.stopColor(root.colors, 1) }
        GradientStop { position: Geometry.stopPosition(root.colors, 2); color: Geometry.stopColor(root.colors, 2) }
        GradientStop { position: Geometry.stopPosition(root.colors, 3); color: Geometry.stopColor(root.colors, 3) }
        GradientStop { position: Geometry.stopPosition(root.colors, 4); color: Geometry.stopColor(root.colors, 4) }
        GradientStop { position: Geometry.stopPosition(root.colors, 5); color: Geometry.stopColor(root.colors, 5) }
        GradientStop { position: Geometry.stopPosition(root.colors, 6); color: Geometry.stopColor(root.colors, 6) }
        GradientStop { position: Geometry.stopPosition(root.colors, 7); color: Geometry.stopColor(root.colors, 7) }
        GradientStop { position: Geometry.stopPosition(root.colors, 8); color: Geometry.stopColor(root.colors, 8) }
        GradientStop { position: Geometry.stopPosition(root.colors, 9); color: Geometry.stopColor(root.colors, 9) }
      }
      PathSvg { path: root.outline }
    }
  }
}
