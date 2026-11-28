import QtQuick

// The layout toggle's keyboard, drawn as the padlock is (Lock.qml): two rows
// of keys over a space bar. Laid out on a 20x14 grid.
Item {
  id: keyboard

  property color color

  readonly property real unit: height / 14

  width: 20 * unit

  Rectangle {
    anchors.fill: parent
    radius: 2 * keyboard.unit
    color: "transparent"
    border.width: 2 * keyboard.unit
    border.color: keyboard.color
  }

  Repeater {
    model: 10

    Rectangle {
      required property int index
      x: (3 + index % 5 * 3) * keyboard.unit
      y: (3 + Math.floor(index / 5) * 3) * keyboard.unit
      width: 2 * keyboard.unit
      height: width
      color: keyboard.color
    }
  }

  Rectangle {
    x: 6 * keyboard.unit
    y: 9 * keyboard.unit
    width: 8 * keyboard.unit
    height: 2 * keyboard.unit
    color: keyboard.color
  }
}
