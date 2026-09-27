import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property bool opened: false
  property string title: ""
  property var targetRow: null
  property var actions: []
  property int selectedIndex: 0
  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  property string fontFamily: Style.font.menuFamily
  property int cornerRadius: Style.cornerRadius

  signal canceled()
  signal triggered(var action)

  function openFor(row, availableActions) {
    targetRow = row
    title = row ? row.label : "Actions"
    actions = availableActions || []
    selectedIndex = 0
    opened = actions.length > 0
  }

  function close() {
    opened = false
    targetRow = null
    actions = []
    selectedIndex = 0
  }

  function triggerSelected() {
    if (selectedIndex < 0 || selectedIndex >= actions.length) return
    root.triggered(actions[selectedIndex])
  }

  function handleKey(event) {
    if (!opened) return false
    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace
        || (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier))) {
      root.canceled()
    } else if (event.key === Qt.Key_Up) {
      selectedIndex = (selectedIndex - 1 + actions.length) % actions.length
    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
      selectedIndex = (selectedIndex + 1) % actions.length
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      triggerSelected()
    } else {
      return false
    }
    Qt.callLater(root.revealSelection)
    return true
  }

  function revealSelection() {
    if (selectedIndex >= 0 && selectedIndex < actions.length)
      actionList.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  visible: opened

  Rectangle {
    anchors.fill: parent
    color: root.scrim
    MouseArea { anchors.fill: parent; onClicked: root.canceled() }
  }

  BorderSurface {
    id: card
    width: Math.min(parent.width - Style.space(28), Style.space(360))
    readonly property int desiredHeight: card.contentTopInset + card.contentBottomInset
      + Style.space(26) + root.actions.length * (Style.space(42) + Style.space(8))
    height: Math.min(parent.height - Style.space(28), desiredHeight)
    anchors.centerIn: parent
    color: root.background
    borderSpec: Border.flat(root.selectedText, Style.normalBorderWidth)
    padding: Style.space(12)
    radius: root.cornerRadius

    MouseArea { anchors.fill: parent; onClicked: {} }

    Column {
      anchors.fill: parent
      anchors.topMargin: card.contentTopInset
      anchors.rightMargin: card.contentRightInset
      anchors.bottomMargin: card.contentBottomInset
      anchors.leftMargin: card.contentLeftInset
      spacing: Style.space(8)

      Text {
        width: parent.width
        height: Style.space(26)
        textFormat: Text.PlainText
        text: root.title
        color: root.foreground
        opacity: 0.62
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
      }

      ListView {
        id: actionList
        width: parent.width
        height: parent.height - Style.space(34)
        model: root.actions
        spacing: Style.space(8)
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        delegate: BorderSurface {
          required property int index
          required property var modelData
          readonly property bool selected: root.selectedIndex === index

          width: ListView.view.width
          height: Style.space(42)
          radius: root.cornerRadius
          color: selected ? root.selectedBackground : "transparent"
          borderSpec: selected ? Border.flat(root.selectedText, Style.normalBorderWidth) : Border.none()

          Text {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            width: Style.space(26)
            textFormat: Text.PlainText
            text: modelData.icon || ""
            color: selected ? root.selectedText : root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.icon
            horizontalAlignment: Text.AlignHCenter
          }

          Text {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(46)
            anchors.right: shortcut.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: modelData.label || ""
            color: selected ? root.selectedText : root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            elide: Text.ElideRight
          }

          Text {
            id: shortcut
            anchors.right: parent.right
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: modelData.shortcut || ""
            color: selected ? root.selectedText : root.foreground
            opacity: 0.48
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.selectedIndex = index
            onClicked: root.triggered(modelData)
          }
        }
      }
    }
  }
}
