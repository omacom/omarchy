import QtQuick
import qs.Commons
import qs.Commons as Commons

// A history filling up: each commit arrives under the last with the name and
// address it was made under, and GitHub, signed in to, is where it can go.
Desk {
  id: root

  // The row under the cursor, whose mark is GitHub's.
  property var option: null

  // How many commits there are so far. It holds on the last, clears, and
  // starts over.
  readonly property var counts: [1, 2, 3, 4, 4, 0]
  property int beat: Style.reduceMotion ? 3 : 0
  readonly property int count: counts[beat]
  // How long each commit's message is.
  readonly property var messages: [0.5, 0.72, 0.4, 0.62]

  Timer {
    interval: 1000
    repeat: true
    running: root.visible && !Style.reduceMotion
    onTriggered: root.beat = (root.beat + 1) % root.counts.length
  }

  Win {
    id: log
    width: parent.width * 0.56
    height: parent.height * 0.82
    x: parent.width * 0.06
    y: (parent.height - height) / 2
    active: true
    lines: false
    foreground: root.foreground
    accent: root.accent

    readonly property real row: Math.min(Style.space(38), (height - Style.space(20)) / 4)
    readonly property real inset: (height - row * 4) / 2

    // The line the commits hang on.
    Rectangle {
      x: Style.space(18)
      y: log.inset + log.row / 2
      width: Style.spacing.hairline
      height: log.row * Math.max(0, root.count - 1)
      color: Util.alpha(root.foreground, 0.3)

      Behavior on height { NumberAnimation { duration: Style.duration(220); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
    }

    Repeater {
      model: root.messages

      Item {
        id: commit

        required property int index
        required property real modelData
        readonly property bool made: index < root.count
        readonly property bool newest: index === root.count - 1

        x: Style.space(10)
        y: log.inset + log.row * index
        width: parent.width - Style.space(20)
        height: log.row
        opacity: made ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: Style.duration(commit.made ? 180 : 120); easing.type: Easing.OutCubic } }

        Rectangle {
          id: dot
          width: Style.space(9)
          height: width
          radius: width / 2
          x: Style.space(8) - width / 2 + Style.spacing.hairline / 2
          anchors.verticalCenter: parent.verticalCenter
          color: commit.newest ? root.accent : Commons.Color.menu.background
          border.width: Style.spacing.hairline
          border.color: commit.newest ? root.accent : Util.alpha(root.foreground, 0.5)
        }

        Rectangle {
          anchors.left: dot.right
          anchors.leftMargin: Style.space(12)
          anchors.verticalCenter: parent.verticalCenter
          width: (author.x - x - Style.space(16)) * commit.modelData
          height: Style.space(4)
          color: Util.alpha(root.foreground, 0.3)
        }

        // Who made it: a name, and under it an address.
        Row {
          id: author
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(6)

          Rectangle {
            width: Style.space(12)
            height: width
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            color: root.accent
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Rectangle {
              width: Style.space(52)
              height: Style.space(4)
              color: Util.alpha(root.foreground, 0.7)
            }

            Row {
              spacing: Style.space(2)

              Rectangle {
                width: Style.space(22)
                height: Style.space(3)
                anchors.verticalCenter: parent.verticalCenter
                color: Util.alpha(root.foreground, 0.3)
              }

              Text {
                textFormat: Text.PlainText
                text: "@"
                color: Util.alpha(root.foreground, 0.6)
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.caption
              }

              Rectangle {
                width: Style.space(36)
                height: Style.space(3)
                anchors.verticalCenter: parent.verticalCenter
                color: Util.alpha(root.foreground, 0.3)
              }
            }
          }
        }
      }
    }
  }

  Way {
    x: log.x + log.width + Style.space(8)
    y: (parent.height - height) / 2
    width: hub.x - x - Style.space(8)
    foreground: root.foreground
    accent: root.accent
  }

  Tile {
    id: hub
    x: parent.width * 0.83 - width / 2
    y: (parent.height - height) / 2
    glyph: root.option ? root.option.icon : ""
    glyphFont: root.option ? root.option.iconFont : ""
    lit: true
    foreground: root.foreground
    accent: root.accent

    // Signed in.
    Text {
      textFormat: Text.PlainText
      text: "\u{f00c}"
      color: root.accent
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.caption
      anchors.left: parent.right
      anchors.leftMargin: Style.space(6)
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
