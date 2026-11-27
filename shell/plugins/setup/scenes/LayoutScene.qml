import QtQuick
import qs.Commons
import qs.Commons as Commons

// The three workspace layouts, shown by four distinct miniature apps: they
// split the screen for tiling, line up on a strip for scrolling, and overlap
// with drop shadows under titlebars above a dock for floating.
Desk {
  id: root

  // dwindle, scrolling or floating: Hyprland's names, which the commands take.
  property string mode: "dwindle"

  // Windows open one at a time, focus walks across them, and it starts over.
  readonly property var beats: [[1, 0], [2, 1], [3, 2], [4, 3], [4, 3], [4, 1], [4, 0], [4, 0]]
  property int turn: 0
  readonly property int beat: Style.reduceMotion ? 4 : turn
  readonly property int count: mode === "" ? 0 : beats[beat][0]
  readonly property int focused: beats[beat][1]

  // Brief cross-settle on mode changes so windows never collide in a tangled
  // pile across the stage, while keeping smooth intra-layout animations.
  property bool opened: false
  property bool switching: false
  property real modeFade: 1

  Component.onCompleted: opened = true
  onModeChanged: {
    if (!opened) return
    turn = 3
    if (!Style.reduceMotion) modeSettle.restart()
  }

  SequentialAnimation {
    id: modeSettle
    PropertyAction { target: root; property: "switching"; value: true }
    PropertyAction { target: root; property: "modeFade"; value: 0.25 }
    PauseAnimation { duration: Style.duration(16) }
    PropertyAction { target: root; property: "switching"; value: false }
    NumberAnimation {
      target: root
      property: "modeFade"
      to: 1
      duration: Style.duration(200)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  // A scrolling column's share of the screen so a third column peeks cleanly.
  readonly property real columnWidth: 0.45
  // Balanced staggered cascade above the floating dock.
  readonly property var floats: [
    Qt.rect(0.04, 0.05, 0.42, 0.56),
    Qt.rect(0.15, 0.21, 0.42, 0.55),
    Qt.rect(0.54, 0.05, 0.42, 0.54),
    Qt.rect(0.45, 0.21, 0.43, 0.55)
  ]

  function tiled(open, index) {
    var x = 0, y = 0, w = 1, h = 1
    for (var k = 0; k < index; k++) {
      if (k % 2 === 0) { x += w / 2; w /= 2 } else { y += h / 2; h /= 2 }
    }
    if (index < open - 1) {
      if (index % 2 === 0) w /= 2
      else h /= 2
    }
    return Qt.rect(x, y, w, h)
  }

  function scrolled(index, focus) {
    var shift = Math.max(0, (focus + 1) * columnWidth - 1)
    return Qt.rect(index * columnWidth - shift, 0, columnWidth, 1)
  }

  function slot(index) {
    var open = Math.max(count, index + 1)
    if (mode === "scrolling") return scrolled(index, Math.min(focused, open - 1))
    if (mode === "floating") return floats[index]
    return tiled(open, index)
  }

  Timer {
    interval: 1050
    repeat: true
    running: root.visible && root.mode !== "" && !Style.reduceMotion
    onTriggered: root.turn = (root.turn + 1) % root.beats.length
  }

  Item {
    anchors.fill: parent
    opacity: root.modeFade

    Repeater {
      model: 4

      Win {
        id: win

        required property int index
        readonly property rect slot: root.slot(index)
        readonly property bool open: index < root.count

        x: slot.x * root.stage.width + root.gap / 2
        y: slot.y * root.stage.height + root.gap / 2
        width: slot.width * root.stage.width - root.gap
        height: slot.height * root.stage.height - root.gap
        z: active ? 4 : index
        variant: index
        active: open && index === root.focused
        titlebar: root.mode === "floating" ? 1 : 0
        shadow: root.mode === "floating" && open
        opacity: open ? 1 : 0
        scale: open ? 1 : 0.97
        foreground: root.foreground
        accent: root.accent

        Behavior on x { enabled: !root.switching; NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
        Behavior on y { enabled: !root.switching; NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
        Behavior on width { enabled: !root.switching; NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
        Behavior on height { enabled: !root.switching; NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
        Behavior on titlebar { enabled: !root.switching; NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Style.duration(win.open ? 180 : 120); easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      }
    }
  }

  // The dock a floating workspace shows, with an active dot under the focused app.
  Rectangle {
    readonly property bool shown: root.mode === "floating"

    anchors.horizontalCenter: parent.horizontalCenter
    y: parent.height - height - Style.space(4) + (shown ? 0 : Style.space(10))
    z: 5
    width: apps.width + Style.space(16)
    height: Style.space(22)
    opacity: shown ? 1 : 0
    color: Commons.Color.menu.background
    radius: Style.cornerRadius
    border.width: Style.spacing.hairline
    border.color: Util.alpha(root.foreground, 0.34)

    Behavior on y { NumberAnimation { duration: Style.duration(200); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
    Behavior on opacity { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }

    Row {
      id: apps
      anchors.centerIn: parent
      spacing: Style.space(6)

      Repeater {
        model: 5

        Column {
          required property int index
          readonly property bool lit: index === root.focused
          spacing: Style.space(2)

          Rectangle {
            width: Style.space(9)
            height: width
            radius: Style.cornerRadius > 0 ? Style.space(2) : 0
            color: lit ? root.accent : Util.alpha(root.foreground, 0.34)
            Behavior on color { ColorAnimation { duration: Style.duration(140) } }
          }

          Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Style.space(3)
            height: Style.space(2)
            color: lit ? root.accent : "transparent"
          }
        }
      }
    }
  }
}
