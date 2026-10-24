// One thing a notification can do: a segment of the card's button bar, its
// name centred, filled on hover.

import QtQuick
import qs.Commons
import qs.Commons as Commons

Rectangle {
  id: button

  property var deed: ({})
  // Not "card": the toast's id is `card`, so a property of that name would
  // bind to itself and stay null.
  property var toast: null

  // Matched on the value: a card with two codes has two Copy buttons.
  readonly property bool taken: toast && deed.kind === "code" && toast.copiedCode === String(deed.value)

  // The deck's hover region sits above every card, so hover is worked out
  // from the pointer position the deck hands down.
  readonly property bool hot: toast ? toast.pointerOver(button) : false

  // A tick rather than a past-tense verb, so the width does not change.
  readonly property string labelText: taken ? "\u{f012c}" : String(deed.label || "")

  color: Commons.Color.notifications.background

  Rectangle {
    anchors.fill: parent
    color: button.hot ? Style.hoverFillFor(Commons.Color.notifications.text, Commons.Color.accent) : "transparent"
    Behavior on color { ColorAnimation { duration: Style.duration(120) } }
  }

  Text {
    anchors.centerIn: parent
    width: Math.min(implicitWidth, parent.width - Style.space(16))
    text: button.labelText
    textFormat: Text.PlainText
    elide: Text.ElideRight
    color: button.hot ? Commons.Color.notifications.text : Qt.darker(Commons.Color.notifications.text, 1.15)
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: button.toast.doDeed(button.deed)
  }
}
