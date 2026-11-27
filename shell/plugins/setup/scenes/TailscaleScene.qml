import QtQuick
import qs.Commons
import qs.Commons as Commons

// A tailnet: this machine and two others linked directly in a private mesh.
// Drawn with anti-aliased Canvas lines so strokes stay uniform across every
// angle, with smooth toggle transitions and subtle node arrival pulses.
Desk {
  id: root

  property bool connected: true
  property real turn: 0
  property real connectMix: connected ? 1 : 0

  Behavior on connectMix {
    NumberAnimation {
      duration: Style.duration(220)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  readonly property var machines: [
    { glyph: "\uf109", x: 0.18, y: 0.72 },
    { glyph: "\uf233", x: 0.5,  y: 0.23 },
    { glyph: "\uf108", x: 0.82, y: 0.72 }
  ]

  function place(index) {
    return Qt.point(machines[index].x * stage.width, machines[index].y * stage.height)
  }

  // Returns 0..1 arrival highlight when a packet reaches node `index`.
  function arrival(index) {
    if (!connected || Style.reduceMotion) return 0
    var incomingEdge = (index + 2) % 3
    var along = (turn + incomingEdge / 3) % 1
    if (along > 0.82) return (along - 0.82) / 0.18
    if (along < 0.14) return 1 - along / 0.14
    return 0
  }

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(2800)
    loops: Animation.Infinite
    running: root.visible && root.connected && !Style.reduceMotion
  }

  // Crisp anti-aliased mesh lines with smooth disconnected-to-connected blend.
  Canvas {
    id: meshCanvas
    anchors.fill: parent

    readonly property real mix: root.connectMix
    onMixChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    Connections {
      target: root
      function onAccentChanged() { meshCanvas.requestPaint() }
      function onForegroundChanged() { meshCanvas.requestPaint() }
    }

    onPaint: {
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      if (width <= 0 || height <= 0) return

      var p0 = root.place(0)
      var p1 = root.place(1)
      var p2 = root.place(2)

      // Disconnected dashed outline fades out smoothly as connected fades in.
      if (mix < 0.99) {
        ctx.save()
        ctx.strokeStyle = Util.alpha(root.foreground, 0.22 * (1 - mix)).toString()
        ctx.lineWidth = 1.25
        ctx.setLineDash([4, 5])
        ctx.beginPath()
        ctx.moveTo(p0.x, p0.y)
        ctx.lineTo(p1.x, p1.y)
        ctx.lineTo(p2.x, p2.y)
        ctx.closePath()
        ctx.stroke()
        ctx.restore()
      }

      // Connected solid mesh with a soft accent halo for uniform clarity.
      if (mix > 0.01) {
        ctx.save()
        ctx.lineJoin = "round"
        ctx.strokeStyle = Util.alpha(root.accent, 0.16 * mix).toString()
        ctx.lineWidth = 4
        ctx.beginPath()
        ctx.moveTo(p0.x, p0.y)
        ctx.lineTo(p1.x, p1.y)
        ctx.lineTo(p2.x, p2.y)
        ctx.closePath()
        ctx.stroke()

        ctx.strokeStyle = Util.alpha(root.accent, 0.72 * mix).toString()
        ctx.lineWidth = 1.5
        ctx.beginPath()
        ctx.moveTo(p0.x, p0.y)
        ctx.lineTo(p1.x, p1.y)
        ctx.lineTo(p2.x, p2.y)
        ctx.closePath()
        ctx.stroke()
        ctx.restore()
      }
    }
  }

  // Packets travelling smoothly between machines, clipped cleanly before nodes.
  Repeater {
    model: 3

    Rectangle {
      required property int index
      readonly property point from: root.place(index)
      readonly property point to: root.place((index + 1) % 3)
      readonly property real along: (root.turn + index / 3) % 1
      readonly property real travel: 0.14 + along * 0.72

      visible: root.connected && !Style.reduceMotion
      width: Style.space(6)
      height: width
      radius: Style.cornerRadius > 0 ? width / 2 : 0
      x: from.x + (to.x - from.x) * travel - width / 2
      y: from.y + (to.y - from.y) * travel - height / 2
      color: root.accent
      opacity: Math.sin(Math.PI * along)
    }
  }

  // Machine tiles with crisp arrival illumination.
  Repeater {
    model: root.machines

    Rectangle {
      required property int index
      required property var modelData
      readonly property real pulse: root.arrival(index)

      width: Style.space(52)
      height: Style.space(38)
      x: Math.round(root.place(index).x - width / 2)
      y: Math.round(root.place(index).y - height / 2)
      color: Commons.Color.menu.background
      radius: Style.cornerRadius
      border.width: root.connected ? Math.max(1, Style.space(1.5)) : Style.spacing.hairline
      border.color: root.connected ? root.accent : Util.alpha(root.foreground, 0.3)

      Behavior on border.color { ColorAnimation { duration: Style.duration(180) } }

      // Subtle inner wash that breathes gently when a packet arrives.
      Rectangle {
        anchors.fill: parent
        anchors.margins: parent.border.width
        radius: Math.max(0, parent.radius - 1)
        color: Util.alpha(root.accent, root.connected ? 0.06 + 0.14 * pulse : 0)
      }

      Text {
        textFormat: Text.PlainText
        text: modelData.glyph
        color: root.connected ? root.accent : Util.alpha(root.foreground, 0.5)
        font.family: Style.font.menuFamily
        font.pixelSize: Style.space(18)
        anchors.centerIn: parent
        Behavior on color { ColorAnimation { duration: Style.duration(180) } }
      }
    }
  }
}
