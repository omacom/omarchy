import QtQuick
import qs.Commons
import qs.Commons as Commons

// The three workspace layouts, shown by the same four windows: they split the
// screen for tiling, line up on a strip for scrolling, and overlap under
// titlebars above a dock for floating. Going from one option to another
// rearranges the windows already there, which is what changing the layout does.
Desk {
  id: root

  // dwindle, scrolling or floating: Hyprland's names, which the commands take.
  // Empty for an option that sets no layout: no layout is drawn for it, since
  // any arrangement would be taken for the one it leaves in place.
  property string mode: "dwindle"

  // Windows open one at a time, focus walks back across them, and it starts
  // over. Each beat is how many are open and which one has focus.
  readonly property var beats: [[1, 0], [2, 1], [3, 2], [4, 3], [4, 3], [4, 1], [4, 0], [4, 0]]
  // Where the loop has got to. With motion reduced the beat shown is the one
  // with every window open, whenever that is turned on.
  property int turn: 0
  readonly property int beat: Style.reduceMotion ? 4 : turn
  readonly property int count: mode === "" ? 0 : beats[beat][0]
  readonly property int focused: beats[beat][1]

  // A change of layout is answered at once with every window open, which is
  // where the three look least alike: two windows side by side are tiling and
  // scrolling both. The loop carries on from there, and holds that beat a
  // second time before it moves. A layout the scene opens on is not a change,
  // and starts with its first window like any other.
  property bool opened: false
  Component.onCompleted: opened = true
  onModeChanged: if (opened) turn = 3

  // A scrolling column's share of the screen, so a third one runs off its edge.
  readonly property real columnWidth: 0.44
  // Where each window was dropped on a floating workspace.
  readonly property var floats: [
    Qt.rect(0.05, 0.07, 0.36, 0.56),
    Qt.rect(0.2, 0.3, 0.36, 0.54),
    Qt.rect(0.6, 0.05, 0.34, 0.5),
    Qt.rect(0.5, 0.36, 0.3, 0.46)
  ]

  // Dwindle: every window but the last keeps the first half of what was left,
  // splitting side by side and then top and bottom in turn.
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

  // The strip slides only as far as brings the focused column into view.
  function scrolled(index, focus) {
    var shift = Math.max(0, (focus + 1) * columnWidth - 1)
    return Qt.rect(index * columnWidth - shift, 0, columnWidth, 1)
  }

  // A window not open yet waits where it will open, so it arrives in place.
  function slot(index) {
    var open = Math.max(count, index + 1)
    if (mode === "scrolling") return scrolled(index, Math.min(focused, open - 1))
    if (mode === "floating") return floats[index]
    return tiled(open, index)
  }

  Timer {
    interval: 950
    repeat: true
    running: root.visible && root.mode !== "" && !Style.reduceMotion
    onTriggered: root.turn = (root.turn + 1) % root.beats.length
  }

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
      active: open && index === root.focused
      titlebar: root.mode === "floating" ? 1 : 0
      opacity: open ? 1 : 0
      scale: open ? 1 : 0.97
      foreground: root.foreground
      accent: root.accent

      Behavior on x { NumberAnimation { duration: Style.duration(260); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on y { NumberAnimation { duration: Style.duration(260); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on width { NumberAnimation { duration: Style.duration(260); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on height { NumberAnimation { duration: Style.duration(260); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on titlebar { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
      Behavior on opacity { NumberAnimation { duration: Style.duration(win.open ? 180 : 120); easing.type: Easing.OutCubic } }
      Behavior on scale { NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
    }
  }

  // The dock a floating workspace shows.
  Rectangle {
    readonly property bool shown: root.mode === "floating"

    anchors.horizontalCenter: parent.horizontalCenter
    y: parent.height - height - Style.space(2) + (shown ? 0 : Style.space(8))
    z: 5
    width: apps.width + Style.space(12)
    height: Style.space(17)
    opacity: shown ? 1 : 0
    color: Commons.Color.menu.background
    radius: Style.cornerRadius
    border.width: Style.spacing.hairline
    border.color: Util.alpha(root.foreground, 0.3)

    Behavior on y { NumberAnimation { duration: Style.duration(220); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
    Behavior on opacity { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }

    Row {
      id: apps
      anchors.centerIn: parent
      spacing: Style.space(5)

      Repeater {
        model: 5

        Rectangle {
          required property int index
          width: Style.space(7)
          height: width
          color: Util.alpha(index === 0 ? root.accent : root.foreground, index === 0 ? 0.9 : 0.4)
        }
      }
    }
  }
}
