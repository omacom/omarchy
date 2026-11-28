import QtQuick
import QtQuick.Shapes

// The show-password toggle's eye, drawn as the padlock is (Lock.qml), crossed
// out while the password is hidden. Laid out on a 96x64 grid.
Item {
  id: eye

  property color color
  property color cutout
  property bool crossed

  readonly property real unit: height / 64

  width: 96 * unit

  Shape {
    anchors.fill: parent

    ShapePath {
      strokeColor: eye.color
      strokeWidth: 8 * eye.unit
      fillColor: "transparent"
      startX: 4 * eye.unit
      startY: 32 * eye.unit

      PathQuad { x: 92 * eye.unit; y: 32 * eye.unit; controlX: 48 * eye.unit; controlY: -14 * eye.unit }
      PathQuad { x: 4 * eye.unit; y: 32 * eye.unit; controlX: 48 * eye.unit; controlY: 78 * eye.unit }
    }
  }

  Rectangle {
    anchors.centerIn: parent
    width: 26 * eye.unit
    height: width
    radius: width / 2
    color: eye.color
  }

  // The stroke, set off from the eye by a cutout in the background's color.
  Shape {
    anchors.fill: parent
    visible: eye.crossed

    ShapePath {
      strokeColor: eye.cutout
      strokeWidth: 20 * eye.unit
      fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      startX: 16 * eye.unit
      startY: 60 * eye.unit

      PathLine { x: 80 * eye.unit; y: 4 * eye.unit }
    }

    ShapePath {
      strokeColor: eye.color
      strokeWidth: 8 * eye.unit
      fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      startX: 16 * eye.unit
      startY: 60 * eye.unit

      PathLine { x: 80 * eye.unit; y: 4 * eye.unit }
    }
  }
}
