// One thing a notification can do: a segment of the card's button bar, its
// name centred, filled on hover. It draws its own hairlines, above and on its
// leading side, so the bar lets the card's colour through.

import QtQuick
import qs.Commons
import qs.Commons as Commons

Item {
  id: button

  property var deed: ({})
  // Not "card": the toast's id is `card`, so a property of that name would
  // bind to itself and stay null.
  property var toast: null
  property string hint: ""              // the number key, in keyboard mode
  property real rule: 1
  property color ruleColor: "transparent"
  property bool leftRule: false

  // Matched on the value: a card with two codes has two Copy buttons.
  readonly property bool taken: toast && deed.kind === "code" && toast.copiedCode === String(deed.value)

  // The deck's hover region sits above every card, so hover is worked out
  // from the pointer position the deck hands down.
  readonly property bool hot: toast ? toast.pointerOver(button) : false

  // A tick rather than a past-tense verb, so the width does not change.
  readonly property string labelText: taken ? "\u{f012c}" : String(deed.label || "")

  Rectangle {
    anchors { fill: parent; topMargin: button.rule; leftMargin: button.leftRule ? button.rule : 0 }
    color: button.hot ? Style.hoverFillFor(Commons.Color.notifications.text, Commons.Color.accent) : "transparent"
    Behavior on color { ColorAnimation { duration: Style.duration(120) } }
  }

  Rectangle { width: parent.width; height: button.rule; color: button.ruleColor }
  // Anchored rather than placed, so it moves to the right edge when mirrored.
  Rectangle {
    visible: button.leftRule
    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
    width: button.rule
    color: button.ruleColor
  }

  Row {
    id: content
    anchors.centerIn: parent
    anchors.verticalCenterOffset: button.rule / 2
    spacing: Style.space(6)

    Text {
      id: hintText
      visible: button.hint !== ""
      text: button.hint
      textFormat: Text.PlainText
      color: Commons.Color.accent
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      font.bold: true
    }

    Text {
      id: label
      // Cut short only when it cannot fit: measured apart from the label, as
      // an elided label's own width can come out a hair short of the text.
      readonly property real room: button.width - Style.space(8)
                                   - (hintText.visible ? hintText.implicitWidth + content.spacing : 0)
      readonly property bool tooLong: labelMetrics.advanceWidth > room
      // Never its own implicit width, which would bind the width to itself.
      width: tooLong ? room : Math.ceil(labelMetrics.advanceWidth)
      text: button.labelText
      textFormat: Text.PlainText
      elide: tooLong ? Text.ElideRight : Text.ElideNone
      color: button.hot ? Commons.Color.notifications.text : Qt.darker(Commons.Color.notifications.text, 1.15)
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }
  }

  TextMetrics { id: labelMetrics; font: label.font; text: button.labelText }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: button.toast.doDeed(button.deed)
  }
}
