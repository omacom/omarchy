import QtQuick
import qs.Commons
import qs.Commons as Commons

Item {
  id: root

  property bool opened: false
  property string message: ""
  property string cancelText: Commons.I18n.t("common.cancel")
  property string confirmText: Commons.I18n.t("common.confirm")
  property int selectedIndex: 1
  property color background: Commons.Color.background
  property color foreground: Commons.Color.foreground
  property color scrim: Util.alpha(Commons.Color.background, 0.7)
  property color selectedBackground: Util.alpha(Commons.Color.foreground, 0.08)
  property color selectedText: Commons.Color.accent
  property string fontFamily: Style.font.family
  property int cornerRadius: Style.cornerRadius

  signal canceled()
  signal confirmed()

  function handleKey(event) {
    if (!root.opened) return false

    if (event.key === Qt.Key_Escape) {
      root.canceled()
      return true
    } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.text === "h" || event.text === "l" || event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
      root.selectedIndex = root.selectedIndex === 0 ? 1 : 0
      return true
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      if (root.selectedIndex === 0) root.canceled()
      else root.confirmed()
      return true
    }

    return false
  }

  visible: opened

  Rectangle {
    anchors.fill: parent
    color: root.scrim

    MouseArea { anchors.fill: parent; onClicked: root.canceled() }

    BorderSurface {
      id: card
      width: Math.min(parent.width - Style.space(32), Style.space(370))
      // Grows with the wrapped message so narrow hosts (like the menu card)
      // don't squeeze the text into the buttons.
      height: card.contentTopInset + card.contentBottomInset + messageText.implicitHeight + Style.space(20) + Style.space(34)
      anchors.centerIn: parent
      color: root.background
      borderSpec: Border.flat(root.selectedText, Style.normalBorderWidth)
      padding: Style.space(18)
      radius: root.cornerRadius

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: content
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset

        Text {
          id: messageText
          textFormat: Text.PlainText
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          text: root.message
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          wrapMode: Text.WordWrap
        }

        Row {
          id: buttonRow
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          spacing: Style.space(10)

          // A button keeps 88px for short labels and grows to fit a longer
          // one, such as a translation, into the room the other button leaves
          // in the card; each is sure of half. A label past that elides.
          readonly property real minButtonWidth: Style.space(88)
          readonly property real labelPadding: Style.space(12)
          readonly property real available: content.width - spacing
          readonly property real cancelWanted: wantedWidth(cancelMetrics)
          readonly property real confirmWanted: wantedWidth(confirmMetrics)
          readonly property real cancelWidth: fittedWidth(cancelWanted, confirmWanted)
          readonly property real confirmWidth: fittedWidth(confirmWanted, cancelWanted)

          function wantedWidth(metrics) {
            return Math.max(minButtonWidth, Math.ceil(metrics.advanceWidth) + labelPadding * 2)
          }

          function fittedWidth(wanted, otherWanted) {
            var room = Math.max(Math.floor(available / 2), available - otherWanted)
            return Math.max(minButtonWidth, Math.min(wanted, room))
          }

          TextMetrics {
            id: cancelMetrics
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            text: root.cancelText
          }

          TextMetrics {
            id: confirmMetrics
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            text: root.confirmText
          }

          Repeater {
            model: [root.cancelText, root.confirmText]

            BorderSurface {
              required property int index
              required property string modelData

              readonly property bool selected: root.selectedIndex === index
              readonly property bool destructive: index === 1

              width: index === 0 ? buttonRow.cancelWidth : buttonRow.confirmWidth
              height: Style.space(34)
              color: selected
                ? (destructive ? Util.alpha(Commons.Color.urgent, 0.22) : root.selectedBackground)
                : "transparent"
              borderSpec: Border.flat(destructive
                ? (selected ? Commons.Color.urgent : Util.alpha(Commons.Color.urgent, 0.56))
                : (selected ? root.selectedText : Util.alpha(root.foreground, 0.38)), Style.normalBorderWidth)
              radius: 0

              Text {
                id: label
                textFormat: Text.PlainText
                anchors.centerIn: parent
                width: Math.min(implicitWidth, parent.width - buttonRow.labelPadding * 2)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: modelData
                color: destructive ? (selected ? Commons.Color.urgent : root.foreground) : (selected ? root.selectedText : root.foreground)
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selectedIndex = index
                onClicked: {
                  if (index === 0) root.canceled()
                  else root.confirmed()
                }
              }
            }
          }
        }
      }
    }
  }
}
