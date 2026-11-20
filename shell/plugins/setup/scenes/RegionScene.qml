import QtQuick
import qs.Commons
import qs.Commons as Commons

// The three things a region decides, a window each: the script the desktop is
// written in, how a date and a number are set down, and what time it is. The
// one the cursor is on has focus, and runs through what it could be.
Desk {
  id: root

  // The row under the cursor, as SetupModel.optionFor describes it.
  property var option: null

  // The last part of the row's id: language, formats or timezone.
  readonly property string verb: option ? String(option.id).replace(/^.*\./, "") : ""
  property int beat: 0

  // A letter or two of several scripts.
  readonly property var scripts: ["Aa", "\u{3042}", "\u{416}\u{436}", "\u{639}", "\u{d55c}"]
  // One day and one amount, as three conventions write them.
  readonly property var dates: ["12/31/2026", "31.12.2026", "2026-12-31"]
  readonly property var amounts: ["1,234.56", "1.234,56", "1 234,56"]
  // The hour in three places.
  readonly property var hours: [9, 14, 22]

  function at(list, mine) {
    return list[mine ? beat % list.length : 0]
  }

  onVerbChanged: beat = 0

  Timer {
    interval: 1400
    repeat: true
    running: root.visible && !Style.reduceMotion
    onTriggered: root.beat = (root.beat + 1) % 30
  }

  component Tile: Win {
    required property int slot
    property string name: ""

    x: slot * parent.width / 3 + root.gap / 2
    y: root.gap / 2
    width: parent.width / 3 - root.gap
    height: parent.height - root.gap
    active: root.verb === name
    lines: false
    foreground: root.foreground
    accent: root.accent
  }

  Tile {
    id: language
    slot: 0
    name: "language"

    Text {
      textFormat: Text.PlainText
      text: root.at(root.scripts, language.active)
      color: Util.alpha(root.foreground, language.active ? 1 : 0.5)
      font.family: Style.font.menuFamily
      font.pixelSize: Math.min(Style.space(48), language.height * 0.36)
      anchors.centerIn: parent
    }
  }

  Tile {
    id: formats
    slot: 1
    name: "formats"

    Column {
      anchors.centerIn: parent
      spacing: Style.space(8)

      Repeater {
        model: [root.at(root.dates, formats.active), root.at(root.amounts, formats.active)]

        Text {
          required property string modelData
          textFormat: Text.PlainText
          text: modelData
          color: Util.alpha(root.foreground, formats.active ? 1 : 0.5)
          font.family: Style.font.menuFamily
          font.pixelSize: Math.min(Style.font.heading, formats.height * 0.16)
          anchors.horizontalCenter: parent.horizontalCenter
        }
      }
    }
  }

  Tile {
    id: timezone
    slot: 2
    name: "timezone"

    Rectangle {
      id: face
      width: Math.min(parent.width, parent.height) * 0.62
      height: width
      radius: width / 2
      anchors.centerIn: parent
      color: "transparent"
      border.width: Style.spacing.hairline
      border.color: Util.alpha(root.foreground, timezone.active ? 0.8 : 0.4)

      // The hour hand, which is what a timezone moves.
      Rectangle {
        width: Math.max(2, Style.space(3))
        height: face.height * 0.28
        x: (face.width - width) / 2
        y: face.height / 2 - height
        color: timezone.active ? root.accent : Util.alpha(root.foreground, 0.5)
        transformOrigin: Item.Bottom
        rotation: root.at(root.hours, timezone.active) * 30

        Behavior on rotation { NumberAnimation { duration: Style.duration(260); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      }

      Rectangle {
        width: Math.max(1, Style.space(2))
        height: face.height * 0.4
        x: (face.width - width) / 2
        y: face.height / 2 - height
        color: Util.alpha(root.foreground, timezone.active ? 0.8 : 0.4)
        transformOrigin: Item.Bottom
        rotation: 60
      }

      Rectangle {
        width: Style.space(5)
        height: width
        radius: width / 2
        anchors.centerIn: parent
        color: Util.alpha(root.foreground, timezone.active ? 0.8 : 0.4)
      }
    }
  }
}
