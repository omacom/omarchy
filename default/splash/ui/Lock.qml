import QtQuick
import QtQuick.Shapes

// The padlock from the Omarchy Plymouth theme (default/plymouth/lock.png),
// drawn so it takes the theme's colors. Laid out on that image's 84x96 grid.
Item {
  id: lock

  property color color
  property color cutout

  readonly property real unit: height / 96

  width: 84 * unit

  Shape {
    anchors.fill: parent

    ShapePath {
      strokeColor: lock.color
      strokeWidth: 12 * lock.unit
      fillColor: "transparent"
      capStyle: ShapePath.FlatCap
      startX: 20 * lock.unit
      startY: 46 * lock.unit

      PathLine { x: 20 * lock.unit; y: 28 * lock.unit }
      PathArc { x: 64 * lock.unit; y: 28 * lock.unit; radiusX: 22 * lock.unit; radiusY: 22 * lock.unit }
      PathLine { x: 64 * lock.unit; y: 46 * lock.unit }
    }
  }

  Rectangle {
    y: 40 * lock.unit
    width: parent.width
    height: 56 * lock.unit
    radius: 12 * lock.unit
    color: lock.color

    Rectangle {
      x: 38 * lock.unit
      y: 18 * lock.unit
      width: 8 * lock.unit
      height: 22 * lock.unit
      radius: width / 2
      color: lock.cutout
    }
  }
}
