import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons

// A tailnet: this machine and two others, each reaching the others directly.
// Left alone, they sit apart.
Desk {
  id: root

  // Whether the option being shown sets Tailscale up, or leaves it.
  property bool connected: true
  property real turn: 0

  // The machines, as glyph and place on the screen.
  readonly property var machines: [
    { glyph: "\uf109", x: 0.2, y: 0.7 },
    { glyph: "\uf233", x: 0.5, y: 0.22 },
    { glyph: "\uf108", x: 0.8, y: 0.7 }
  ]
  readonly property color wire: connected ? Util.alpha(accent, 0.75) : Util.alpha(foreground, 0.18)

  function place(index) {
    return Qt.point(machines[index].x * stage.width, machines[index].y * stage.height)
  }

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(2600)
    loops: Animation.Infinite
    running: root.visible && root.connected && !Style.reduceMotion
  }

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeColor: root.wire
      strokeWidth: Style.spacing.hairline
      strokeStyle: root.connected ? ShapePath.SolidLine : ShapePath.DashLine
      dashPattern: [3, 4]
      fillColor: "transparent"
      startX: root.place(0).x
      startY: root.place(0).y
      PathLine { x: root.place(1).x; y: root.place(1).y }
      PathLine { x: root.place(2).x; y: root.place(2).y }
      PathLine { x: root.place(0).x; y: root.place(0).y }
    }
  }

  // Something on its way along each link.
  Repeater {
    model: 3

    Rectangle {
      required property int index
      readonly property point from: root.place(index)
      readonly property point to: root.place((index + 1) % 3)
      readonly property real along: (root.turn + index / 3) % 1

      visible: root.connected && !Style.reduceMotion
      width: Style.space(5)
      height: width
      x: from.x + (to.x - from.x) * along - width / 2
      y: from.y + (to.y - from.y) * along - height / 2
      color: root.accent
      opacity: Math.sin(Math.PI * along)
    }
  }

  Repeater {
    model: root.machines

    Rectangle {
      required property int index
      required property var modelData

      width: Style.space(46)
      height: Style.space(34)
      x: root.place(index).x - width / 2
      y: root.place(index).y - height / 2
      color: Commons.Color.menu.background
      radius: Style.cornerRadius
      border.width: Style.spacing.hairline
      border.color: root.connected ? root.accent : Util.alpha(root.foreground, 0.3)

      Text {
        textFormat: Text.PlainText
        text: modelData.glyph
        color: root.connected ? root.accent : Util.alpha(root.foreground, 0.5)
        font.family: Style.font.menuFamily
        font.pixelSize: Style.space(17)
        anchors.centerIn: parent
      }
    }
  }
}
