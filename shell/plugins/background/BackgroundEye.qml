import QtQuick
import QtQuick.Shapes
import qs.Commons
import "EffectsModel.js" as EffectsModel

// One eye of a background's "eyes" effect. Its white is painted over the
// image's own and its pupil on top, so at rest it matches the picture exactly;
// with the pointer tracked, the pupil rolls toward it.
Item {
  id: root

  property var eye
  // EffectsModel.cropTransform for this screen.
  property var crop
  property point pointer: Qt.point(0, 0)
  property bool tracking: false
  // Screen pixels from the eye at which the pupil is halfway to the rim.
  property real reach: 100

  // crop can turn null a moment before the Repeater drops this eye.
  readonly property real factor: crop ? crop.scale : 0
  readonly property var offset: tracking
    ? EffectsModel.pupilOffset(eye, pointer.x - x, pointer.y - y, reach)
    : EffectsModel.pupilOffset(eye, null, null, reach)

  x: crop ? crop.x + eye.center.x * factor : 0
  y: crop ? crop.y + eye.center.y * factor : 0

  Ellipse {
    radiusX: root.eye.radius.x * root.factor
    radiusY: root.eye.radius.y * root.factor
    fill: root.eye.color
  }

  Item {
    x: root.offset.x * root.factor
    y: root.offset.y * root.factor

    // A short glide, so a pointer that enters the desktop far from where the
    // eye last looked does not snap it across.
    Behavior on x { NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
    Behavior on y { NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }

    Ellipse {
      radiusX: root.eye.pupil.radius.x * root.factor
      radiusY: root.eye.pupil.radius.y * root.factor
      fill: root.eye.pupil.color
    }

    Ellipse {
      readonly property var highlight: root.eye.pupil.highlight
      visible: highlight !== null
      x: highlight ? highlight.offset.x * root.factor - radiusX : 0
      y: highlight ? highlight.offset.y * root.factor - radiusY : 0
      radiusX: highlight ? highlight.radius.x * root.factor : 0
      radiusY: highlight ? highlight.radius.y * root.factor : 0
      fill: highlight ? highlight.color : "transparent"
    }
  }

  // An ellipse centered on its parent's origin unless placed otherwise.
  component Ellipse: Shape {
    id: ellipse
    property real radiusX: 0
    property real radiusY: 0
    property color fill: "transparent"

    x: -radiusX
    y: -radiusY
    width: radiusX * 2
    height: radiusY * 2
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: ellipse.fill
      strokeWidth: -1
      PathAngleArc {
        centerX: ellipse.radiusX
        centerY: ellipse.radiusY
        radiusX: ellipse.radiusX
        radiusY: ellipse.radiusY
        startAngle: 0
        sweepAngle: 360
      }
    }
  }
}
