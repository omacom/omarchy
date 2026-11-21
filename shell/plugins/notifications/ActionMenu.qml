// The actions behind More, listed under the card's button bar. Drawn inside
// the card, not as a popup surface, so the deck's hover region, input mask and
// clipping cover it like any other part of the card.

import QtQuick
import qs.Commons
import qs.Commons as Commons

import "Delivery.js" as Delivery

Item {
  id: menu

  // Not "card": the toast's id is `card`, so a property of that name would
  // bind to itself and stay null.
  property var toast: null
  property var deeds: []
  // The deed index of the first row, so number hints match the keys.
  property int firstIndex: 1
  // The keyboard's row, or -1 when the pointer decides what is lit.
  property int currentIndex: -1
  property bool showHints: false
  property real rule: 1
  property color ruleColor: "transparent"
  property real rowHeight: Style.spacing.controlHeight + Style.space(6)
  // Room below the button bar before the screen ends. The deck does not
  // scroll, so the list scrolls instead of running off the screen.
  property real maxHeight: Infinity
  // Opaque when it opens over the card's content instead of below the bar.
  property color background: "transparent"
  signal chosen(var deed)

  readonly property real pitch: rule + rowHeight
  implicitHeight: Delivery.menuRows(deeds.length, pitch, maxHeight) * pitch
  clip: true

  // Keeps the keyboard's row in view, also when the room shrinks under it or
  // the menu moves between below and above the bar.
  function revealCurrent() {
    if (currentIndex < 0) return
    var top = currentIndex * pitch
    if (top < list.contentY) list.contentY = top
    else if (top + pitch > list.contentY + list.height) list.contentY = top + pitch - list.height
  }
  onCurrentIndexChanged: revealCurrent()
  onPitchChanged: Qt.callLater(revealCurrent)
  onDeedsChanged: list.contentY = 0

  Rectangle { anchors.fill: parent; color: menu.background }

  Flickable {
    id: list
    anchors.fill: parent
    contentWidth: width
    contentHeight: rows.height
    interactive: contentHeight > height
    boundsBehavior: Flickable.StopAtBounds
    onHeightChanged: Qt.callLater(menu.revealCurrent)

    Column {
      id: rows
      width: menu.width

      Repeater {
        model: menu.deeds

        Item {
          id: entry
          required property var modelData
          required property int index
          width: menu.width
          height: menu.rule + menu.rowHeight

          // The deck's hover region sits above every card, so hover is worked
          // out from the pointer position the deck hands down. The binding
          // cannot see mapToItem() move with the scroll, so it reads contentY
          // itself: scrolling under a still pointer moves the highlight.
          readonly property bool hot: menu.currentIndex >= 0
            ? menu.currentIndex === index
            : (menu.toast && list.contentY > -Infinity
               ? menu.toast.pointerOver(entry) && menu.toast.pointerOver(menu) : false)

          Rectangle {
            anchors { fill: parent; topMargin: menu.rule }
            color: entry.hot ? Style.hoverFillFor(Commons.Color.notifications.text, Commons.Color.accent) : "transparent"
            Behavior on color { ColorAnimation { duration: Style.duration(120) } }
          }

          Rectangle { width: parent.width; height: menu.rule; color: menu.ruleColor }

          Row {
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                      verticalCenterOffset: menu.rule / 2
                      leftMargin: Style.space(14); rightMargin: Style.space(14) }
            spacing: Style.space(8)

            Text {
              id: hintText
              visible: menu.showHints && menu.firstIndex + entry.index < 9
              text: String(menu.firstIndex + entry.index + 1)
              textFormat: Text.PlainText
              color: Commons.Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
            }

            Text {
              width: parent.width - (hintText.visible ? hintText.implicitWidth + parent.spacing : 0)
              text: String(entry.modelData.label || "")
              textFormat: Text.PlainText
              elide: Text.ElideRight
              horizontalAlignment: Text.AlignLeft
              color: entry.hot ? Commons.Color.notifications.text : Qt.darker(Commons.Color.notifications.text, 1.15)
              font.family: Style.font.family
              font.pixelSize: Style.font.body
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: menu.chosen(entry.modelData)
          }
        }
      }
    }
  }
}
